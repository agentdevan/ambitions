#include "CAmbitionsSQLiteSecureVFS.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdalign.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>

/*
 * This VFS deliberately does not attempt to reimplement SQLite's Darwin VFS.
 * It pins the one namespace Ambitions owns, opens each persistent member with
 * openat(O_NOFOLLOW), and delegates I/O through /dev/fd/<already-open-fd>.
 * The system VFS therefore never receives a mutable Ambitions pathname.
 */

enum {
    kAmbitionsSecurePathCapacity = 1024,
};

struct AmbitionsSQLiteSecureVFSContext {
    int directory_fd;
    uint64_t identifier;
    uint64_t namespace_identifier;
    dev_t main_file_device;
    ino_t main_file_inode;
    int has_main_file_identity;
    char basename[NAME_MAX + 1];
    char virtual_path[kAmbitionsSecurePathCapacity];
    struct AmbitionsSQLiteSecureVFSContext *next;
};

typedef struct AmbitionsSecureFile {
    sqlite3_file base;
    int retained_fd;
    struct AmbitionsSQLiteSecureVFSContext *context;
    uint64_t context_identifier;
    uint64_t namespace_identifier;
    int is_main_file;
    int shm_fd;
    void **shm_regions;
    int shm_region_count;
    int shm_page_size;
    pthread_mutex_t shm_lock;
} AmbitionsSecureFile;

/*
 * POSIX record locks are process-scoped.  Consequently, fcntl() alone does
 * not make separately-opened SQLite connections in this process contend with
 * each other.  Keep the process-local half of SQLite's shm lock protocol in
 * this registry; fcntl remains the cross-process half.
 */
typedef struct AmbitionsSecureShmLock {
    uint64_t context_identifier;
    uint64_t namespace_identifier;
    AmbitionsSecureFile *owner;
    sqlite3_int64 start;
    sqlite3_int64 end;
    short lock_type;
    struct AmbitionsSecureShmLock *next;
} AmbitionsSecureShmLock;

static sqlite3_vfs gVFS;
static sqlite3_vfs *gDefaultVFS;
static pthread_once_t gInstallOnce = PTHREAD_ONCE_INIT;
static pthread_mutex_t gContextLock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t gShmRegistryLock = PTHREAD_MUTEX_INITIALIZER;
static struct AmbitionsSQLiteSecureVFSContext *gContexts;
static AmbitionsSecureShmLock *gShmLocks;
static uint64_t gNextContextIdentifier;
static size_t gUnderlyingOffset;
static int gInstallResult = SQLITE_ERROR;

static sqlite3_file *underlying_file(sqlite3_file *file) {
    return (sqlite3_file *)((unsigned char *)file + gUnderlyingOffset);
}

static int is_regular_single_link_file(int descriptor) {
    struct stat status;
    return fstat(descriptor, &status) == 0 &&
        S_ISREG(status.st_mode) && status.st_nlink == 1;
}

static int is_exclusive_owner_directory(const struct stat *status) {
    return S_ISDIR(status->st_mode) &&
        status->st_uid == geteuid() &&
        (status->st_mode & (S_IWGRP | S_IWOTH)) == 0;
}

static uint64_t namespace_identifier_for(
    const struct stat *directory_status,
    const char *basename
) {
    // FNV-1a combines the pinned directory identity and one safe leaf name.
    // It is only a process-local registry key; the VFS's openat checks remain
    // the authoritative filesystem boundary.
    uint64_t value = UINT64_C(1469598103934665603);
    const unsigned char *bytes = (const unsigned char *)&directory_status->st_dev;
    for (size_t index = 0; index < sizeof(directory_status->st_dev); ++index) {
        value = (value ^ bytes[index]) * UINT64_C(1099511628211);
    }
    bytes = (const unsigned char *)&directory_status->st_ino;
    for (size_t index = 0; index < sizeof(directory_status->st_ino); ++index) {
        value = (value ^ bytes[index]) * UINT64_C(1099511628211);
    }
    for (const unsigned char *cursor = (const unsigned char *)basename;
         *cursor != '\0'; ++cursor) {
        value = (value ^ *cursor) * UINT64_C(1099511628211);
    }
    return value;
}

static int allowed_basename(const char *name) {
    if (name == NULL || name[0] == '\0' || strcmp(name, ".") == 0 ||
        strcmp(name, "..") == 0) {
        return 0;
    }
    for (const unsigned char *cursor = (const unsigned char *)name;
         *cursor != '\0'; ++cursor) {
        if (*cursor == '/' || *cursor == '\0') return 0;
    }
    return strlen(name) <= NAME_MAX;
}

static int matching_leaf(
    const struct AmbitionsSQLiteSecureVFSContext *context,
    const char *name,
    const char **leaf
) {
    const size_t prefix_length = strlen(context->virtual_path);
    if (strncmp(name, context->virtual_path, prefix_length) != 0) return 0;
    const char *suffix = name + prefix_length;
    if (suffix[0] == '\0') {
        *leaf = context->basename;
        return 1;
    }
    const int is_fixed_sidecar = strcmp(suffix, "-journal") == 0 ||
        strcmp(suffix, "-wal") == 0 || strcmp(suffix, "-shm") == 0;
    const int is_master_journal = strncmp(suffix, "-mj", 3) == 0 &&
        suffix[3] != '\0' && strchr(suffix, '/') == NULL;
    if (is_fixed_sidecar || is_master_journal) {
        static _Thread_local char sidecar[NAME_MAX + 16];
        const int written = snprintf(sidecar, sizeof(sidecar), "%s%s",
            context->basename, suffix);
        if (written < 0 || (size_t)written >= sizeof(sidecar)) return 0;
        *leaf = sidecar;
        return 1;
    }
    return 0;
}

static struct AmbitionsSQLiteSecureVFSContext *context_for_path(
    const char *name,
    const char **leaf
) {
    if (name == NULL) return NULL;
    pthread_mutex_lock(&gContextLock);
    for (struct AmbitionsSQLiteSecureVFSContext *cursor = gContexts;
         cursor != NULL; cursor = cursor->next) {
        if (matching_leaf(cursor, name, leaf)) {
            pthread_mutex_unlock(&gContextLock);
            return cursor;
        }
    }
    pthread_mutex_unlock(&gContextLock);
    return NULL;
}

static int secure_xShmUnmap(sqlite3_file *file, int delete_flag);
static void secure_release_all_shm_locks(AmbitionsSecureFile *secure);

static int secure_close(sqlite3_file *file) {
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    sqlite3_file *underlying = underlying_file(file);
    int result = SQLITE_OK;
    if (secure->shm_fd >= 0 || secure->shm_regions != NULL) {
        const int shm_result = secure_xShmUnmap(file, 0);
        if (shm_result != SQLITE_OK) result = shm_result;
    }
    /* Also cover a partially-initialized shm session that never mapped a page. */
    secure_release_all_shm_locks(secure);
    if (underlying->pMethods != NULL && underlying->pMethods->xClose != NULL) {
        const int close_result = underlying->pMethods->xClose(underlying);
        if (result == SQLITE_OK) result = close_result;
    }
    if (secure->retained_fd >= 0) {
        if (close(secure->retained_fd) != 0 && result == SQLITE_OK) {
            result = SQLITE_IOERR_CLOSE;
        }
        secure->retained_fd = -1;
    }
    (void)pthread_mutex_destroy(&secure->shm_lock);
    file->pMethods = NULL;
    return result;
}

#define FORWARD_IO(name, args, call) \
    static int secure_##name args { \
        sqlite3_file *underlying = underlying_file(file); \
        if (underlying->pMethods == NULL || underlying->pMethods->name == NULL) \
            return SQLITE_IOERR; \
        return underlying->pMethods->name call; \
    }

FORWARD_IO(xRead, (sqlite3_file *file, void *buffer, int amount, sqlite3_int64 offset),
    (underlying, buffer, amount, offset))
FORWARD_IO(xWrite, (sqlite3_file *file, const void *buffer, int amount, sqlite3_int64 offset),
    (underlying, buffer, amount, offset))
FORWARD_IO(xTruncate, (sqlite3_file *file, sqlite3_int64 size), (underlying, size))
FORWARD_IO(xSync, (sqlite3_file *file, int flags), (underlying, flags))
FORWARD_IO(xFileSize, (sqlite3_file *file, sqlite3_int64 *size), (underlying, size))
FORWARD_IO(xLock, (sqlite3_file *file, int lock), (underlying, lock))
FORWARD_IO(xUnlock, (sqlite3_file *file, int lock), (underlying, lock))
FORWARD_IO(xCheckReservedLock, (sqlite3_file *file, int *result), (underlying, result))
static int secure_xFileControl(
    sqlite3_file *file,
    int operation,
    void *argument
) {
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    if (operation == SQLITE_FCNTL_HAS_MOVED && secure->context != NULL &&
        secure->is_main_file) {
        if (argument == NULL) return SQLITE_MISUSE;
        struct stat observed;
        int moved = 1;
        pthread_mutex_lock(&gContextLock);
        if (secure->context->has_main_file_identity &&
            fstatat(
                secure->context->directory_fd,
                secure->context->basename,
                &observed,
                AT_SYMLINK_NOFOLLOW
            ) == 0 &&
            S_ISREG(observed.st_mode) && observed.st_nlink == 1 &&
            observed.st_dev == secure->context->main_file_device &&
            observed.st_ino == secure->context->main_file_inode) {
            moved = 0;
        }
        pthread_mutex_unlock(&gContextLock);
        *(int *)argument = moved;
        return SQLITE_OK;
    }
    sqlite3_file *underlying = underlying_file(file);
    if (underlying->pMethods == NULL || underlying->pMethods->xFileControl == NULL) {
        return SQLITE_NOTFOUND;
    }
    return underlying->pMethods->xFileControl(underlying, operation, argument);
}
FORWARD_IO(xSectorSize, (sqlite3_file *file), (underlying))
FORWARD_IO(xDeviceCharacteristics, (sqlite3_file *file), (underlying))

static int secure_shm_leaf(
    const struct AmbitionsSQLiteSecureVFSContext *context,
    char output[NAME_MAX + 16]
) {
    const int written = snprintf(output, NAME_MAX + 16, "%s-shm", context->basename);
    return written >= 0 && written < NAME_MAX + 16 && allowed_basename(output);
}

static int secure_shm_open(AmbitionsSecureFile *secure, int extend, int *is_absent) {
    *is_absent = 0;
    if (secure->context == NULL) return SQLITE_IOERR_SHMOPEN;
    if (secure->shm_fd >= 0) return SQLITE_OK;

    char leaf[NAME_MAX + 16];
    if (!secure_shm_leaf(secure->context, leaf)) return SQLITE_IOERR_SHMOPEN;
    int flags = O_RDWR | O_CLOEXEC | O_NOFOLLOW;
    if (extend) flags |= O_CREAT;
    const int descriptor = openat(
        secure->context->directory_fd,
        leaf,
        flags,
        S_IRUSR | S_IWUSR
    );
    if (descriptor < 0) {
        if (!extend && errno == ENOENT) {
            *is_absent = 1;
            return SQLITE_OK;
        }
        return SQLITE_IOERR_SHMOPEN;
    }
    if (!is_regular_single_link_file(descriptor)) {
        (void)close(descriptor);
        return SQLITE_IOERR_SHMOPEN;
    }
    secure->shm_fd = descriptor;
    return SQLITE_OK;
}

static int secure_shm_resize(
    AmbitionsSecureFile *secure,
    int page,
    int page_size,
    int extend
) {
    if (page < 0 || page_size <= 0 ||
        page > INT_MAX / page_size - 1) return SQLITE_IOERR_SHMSIZE;
    const sqlite3_int64 required = (sqlite3_int64)(page + 1) * page_size;
    struct stat status;
    if (fstat(secure->shm_fd, &status) != 0) return SQLITE_IOERR_SHMSIZE;
    if ((sqlite3_int64)status.st_size >= required) return SQLITE_OK;
    if (!extend || ftruncate(secure->shm_fd, (off_t)required) != 0) {
        return SQLITE_IOERR_SHMSIZE;
    }
    return SQLITE_OK;
}

static int secure_xShmMap(
    sqlite3_file *file,
    int page,
    int page_size,
    int extend,
    void volatile **memory
) {
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    if (memory == NULL || secure->context == NULL) return SQLITE_IOERR_SHMMAP;
    *memory = NULL;
    if (pthread_mutex_lock(&secure->shm_lock) != 0) return SQLITE_IOERR_SHMMAP;

    int result = SQLITE_OK;
    if (secure->shm_page_size != 0 && secure->shm_page_size != page_size) {
        result = SQLITE_IOERR_SHMMAP;
        goto done;
    }
    int is_absent = 0;
    result = secure_shm_open(secure, extend, &is_absent);
    if (result != SQLITE_OK) goto done;
    /* SQLite permits a read probe of a not-yet-created shared-memory file. */
    if (is_absent) goto done;
    result = secure_shm_resize(secure, page, page_size, extend);
    if (result != SQLITE_OK) goto done;

    if (page >= secure->shm_region_count) {
        const size_t region_count = (size_t)page + 1;
        if (region_count > SIZE_MAX / sizeof(*secure->shm_regions)) {
            result = SQLITE_NOMEM;
            goto done;
        }
        void **regions = realloc(secure->shm_regions, region_count * sizeof(*regions));
        if (regions == NULL) {
            result = SQLITE_NOMEM;
            goto done;
        }
        memset(regions + secure->shm_region_count, 0,
            (region_count - (size_t)secure->shm_region_count) * sizeof(*regions));
        secure->shm_regions = regions;
        secure->shm_region_count = (int)region_count;
    }
    if (secure->shm_regions[page] == NULL) {
        const off_t offset = (off_t)page * page_size;
        void *region = mmap(NULL, (size_t)page_size, PROT_READ | PROT_WRITE,
            MAP_SHARED, secure->shm_fd, offset);
        if (region == MAP_FAILED) {
            result = SQLITE_IOERR_SHMMAP;
            goto done;
        }
        secure->shm_regions[page] = region;
    }
    secure->shm_page_size = page_size;
    *memory = secure->shm_regions[page];

done:
    (void)pthread_mutex_unlock(&secure->shm_lock);
    return result;
}

static int shm_ranges_overlap(
    sqlite3_int64 left_start,
    sqlite3_int64 left_end,
    sqlite3_int64 right_start,
    sqlite3_int64 right_end
) {
    return left_start < right_end && right_start < left_end;
}

/* The registry mutex must be held by these helpers. */
static int secure_shm_lock_conflicts(
    const AmbitionsSecureFile *secure,
    sqlite3_int64 start,
    sqlite3_int64 end,
    short lock_type
) {
    for (const AmbitionsSecureShmLock *cursor = gShmLocks;
         cursor != NULL; cursor = cursor->next) {
        if (cursor->namespace_identifier != secure->namespace_identifier ||
            cursor->owner == secure ||
            !shm_ranges_overlap(start, end, cursor->start, cursor->end)) {
            continue;
        }
        if (lock_type == F_WRLCK || cursor->lock_type == F_WRLCK) return 1;
    }
    return 0;
}

static int secure_shm_lock_is_recorded(
    const AmbitionsSecureFile *secure,
    sqlite3_int64 start,
    sqlite3_int64 end,
    short lock_type
) {
    for (const AmbitionsSecureShmLock *cursor = gShmLocks;
         cursor != NULL; cursor = cursor->next) {
        if (cursor->namespace_identifier == secure->namespace_identifier &&
            cursor->owner == secure && cursor->start == start &&
            cursor->end == end && cursor->lock_type == lock_type) return 1;
    }
    return 0;
}

/* The caller owns the prepared node until it links it into gShmLocks. */
static AmbitionsSecureShmLock *secure_prepare_shm_lock(
    AmbitionsSecureFile *secure,
    sqlite3_int64 start,
    sqlite3_int64 end,
    short lock_type
) {
    AmbitionsSecureShmLock *entry = calloc(1, sizeof(*entry));
    if (entry == NULL) return NULL;
    entry->context_identifier = secure->context_identifier;
    entry->namespace_identifier = secure->namespace_identifier;
    entry->owner = secure;
    entry->start = start;
    entry->end = end;
    entry->lock_type = lock_type;
    return entry;
}

static void secure_record_shm_lock(AmbitionsSecureShmLock *entry) {
    entry->next = gShmLocks;
    gShmLocks = entry;
}

/*
 * SQLite releases whole byte ranges.  Trim or split tracked intervals so a
 * later overlapping acquisition sees exactly the locks this connection still
 * owns.  The registry mutex must be held.
 */
static void secure_release_shm_lock_range(
    AmbitionsSecureFile *secure,
    sqlite3_int64 start,
    sqlite3_int64 end
) {
    AmbitionsSecureShmLock **link = &gShmLocks;
    while (*link != NULL) {
        AmbitionsSecureShmLock *entry = *link;
        if (entry->namespace_identifier != secure->namespace_identifier ||
            entry->owner != secure ||
            !shm_ranges_overlap(start, end, entry->start, entry->end)) {
            link = &entry->next;
            continue;
        }
        if (start <= entry->start && end >= entry->end) {
            *link = entry->next;
            free(entry);
            continue;
        }
        if (start <= entry->start) {
            entry->start = end;
            link = &entry->next;
            continue;
        }
        if (end >= entry->end) {
            entry->end = start;
            link = &entry->next;
            continue;
        }
        AmbitionsSecureShmLock *tail = calloc(1, sizeof(*tail));
        if (tail == NULL) {
            /* Preserve a conservative lock rather than falsely releasing it. */
            entry->end = start;
            link = &entry->next;
            continue;
        }
        *tail = *entry;
        tail->start = end;
        tail->next = entry->next;
        entry->end = start;
        entry->next = tail;
        link = &tail->next;
    }
}

static void secure_release_all_shm_locks(AmbitionsSecureFile *secure) {
    if (pthread_mutex_lock(&gShmRegistryLock) != 0) return;
    AmbitionsSecureShmLock **link = &gShmLocks;
    while (*link != NULL) {
        AmbitionsSecureShmLock *entry = *link;
        if (entry->namespace_identifier == secure->namespace_identifier &&
            entry->owner == secure) {
            *link = entry->next;
            free(entry);
        } else {
            link = &entry->next;
        }
    }
    (void)pthread_mutex_unlock(&gShmRegistryLock);
}

static int secure_xShmLock(
    sqlite3_file *file,
    int offset,
    int count,
    int flags
) {
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    if (secure->context == NULL || offset < 0 || count <= 0) return SQLITE_IOERR_SHMLOCK;
    if (flags & ~(SQLITE_SHM_UNLOCK | SQLITE_SHM_LOCK |
            SQLITE_SHM_SHARED | SQLITE_SHM_EXCLUSIVE)) {
        return SQLITE_IOERR_SHMLOCK;
    }
    short lock_type;
    if (flags == (SQLITE_SHM_UNLOCK | SQLITE_SHM_SHARED) ||
        flags == (SQLITE_SHM_UNLOCK | SQLITE_SHM_EXCLUSIVE)) lock_type = F_UNLCK;
    else if (flags == (SQLITE_SHM_LOCK | SQLITE_SHM_SHARED)) lock_type = F_RDLCK;
    else if (flags == (SQLITE_SHM_LOCK | SQLITE_SHM_EXCLUSIVE)) lock_type = F_WRLCK;
    else return SQLITE_IOERR_SHMLOCK;
    if (pthread_mutex_lock(&secure->shm_lock) != 0) return SQLITE_IOERR_SHMLOCK;
    if (secure->shm_fd < 0) {
        int is_absent = 0;
        const int open_result = secure_shm_open(secure, 1, &is_absent);
        if (open_result != SQLITE_OK || is_absent) {
            (void)pthread_mutex_unlock(&secure->shm_lock);
            return SQLITE_IOERR_SHMLOCK;
        }
    }
    const sqlite3_int64 start = (sqlite3_int64)offset;
    const sqlite3_int64 end = start + (sqlite3_int64)count;
    if (pthread_mutex_lock(&gShmRegistryLock) != 0) {
        (void)pthread_mutex_unlock(&secure->shm_lock);
        return SQLITE_IOERR_SHMLOCK;
    }
    AmbitionsSecureShmLock *prepared = NULL;
    if (lock_type != F_UNLCK) {
        if (secure_shm_lock_conflicts(secure, start, end, lock_type)) {
            (void)pthread_mutex_unlock(&gShmRegistryLock);
            (void)pthread_mutex_unlock(&secure->shm_lock);
            return SQLITE_BUSY;
        }
        if (!secure_shm_lock_is_recorded(secure, start, end, lock_type)) {
            prepared = secure_prepare_shm_lock(secure, start, end, lock_type);
            if (prepared == NULL) {
                (void)pthread_mutex_unlock(&gShmRegistryLock);
                (void)pthread_mutex_unlock(&secure->shm_lock);
                return SQLITE_NOMEM;
            }
        }
    }
    struct flock lock = {
        .l_type = lock_type,
        .l_whence = SEEK_SET,
        .l_start = offset,
        .l_len = count,
    };
    const int locked = fcntl(secure->shm_fd, F_SETLK, &lock);
    const int saved_errno = errno;
    if (locked == 0) {
        if (lock_type == F_UNLCK) {
            secure_release_shm_lock_range(secure, start, end);
        } else if (prepared != NULL) {
            secure_record_shm_lock(prepared);
            prepared = NULL;
        }
    }
    free(prepared);
    (void)pthread_mutex_unlock(&gShmRegistryLock);
    (void)pthread_mutex_unlock(&secure->shm_lock);
    if (locked == 0) return SQLITE_OK;
    if (saved_errno == EACCES || saved_errno == EAGAIN) return SQLITE_BUSY;
    return SQLITE_IOERR_SHMLOCK;
}

static void secure_xShmBarrier(sqlite3_file *file) {
    (void)file;
    atomic_thread_fence(memory_order_seq_cst);
}

static int secure_delete_shm(
    const struct AmbitionsSQLiteSecureVFSContext *context,
    int descriptor
) {
    char leaf[NAME_MAX + 16];
    struct stat descriptor_status;
    struct stat path_status;
    if (!secure_shm_leaf(context, leaf) ||
        fstat(descriptor, &descriptor_status) != 0 ||
        !S_ISREG(descriptor_status.st_mode) || descriptor_status.st_nlink != 1 ||
        fstatat(context->directory_fd, leaf, &path_status, AT_SYMLINK_NOFOLLOW) != 0 ||
        !S_ISREG(path_status.st_mode) || path_status.st_nlink != 1 ||
        descriptor_status.st_dev != path_status.st_dev ||
        descriptor_status.st_ino != path_status.st_ino) {
        return SQLITE_IOERR_DELETE;
    }
    if (unlinkat(context->directory_fd, leaf, 0) != 0 ||
        fsync(context->directory_fd) != 0) return SQLITE_IOERR_DELETE;
    return SQLITE_OK;
}

static int secure_xShmUnmap(sqlite3_file *file, int delete_flag) {
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    if (pthread_mutex_lock(&secure->shm_lock) != 0) return SQLITE_IOERR_SHMMAP;

    int result = SQLITE_OK;
    for (int index = 0; index < secure->shm_region_count; ++index) {
        if (secure->shm_regions[index] != NULL &&
            munmap(secure->shm_regions[index], (size_t)secure->shm_page_size) != 0) {
            result = SQLITE_IOERR_SHMMAP;
        }
    }
    free(secure->shm_regions);
    secure->shm_regions = NULL;
    secure->shm_region_count = 0;
    secure->shm_page_size = 0;
    const int descriptor = secure->shm_fd;
    secure->shm_fd = -1;
    secure_release_all_shm_locks(secure);
    if (descriptor >= 0 && delete_flag && secure->context != NULL) {
        const int delete_result = secure_delete_shm(secure->context, descriptor);
        if (result == SQLITE_OK) result = delete_result;
    }
    if (descriptor >= 0 && close(descriptor) != 0 && result == SQLITE_OK) {
        result = SQLITE_IOERR_CLOSE;
    }
    (void)pthread_mutex_unlock(&secure->shm_lock);
    return result;
}
FORWARD_IO(xFetch, (sqlite3_file *file, sqlite3_int64 offset, int amount, void **memory),
    (underlying, offset, amount, memory))
FORWARD_IO(xUnfetch, (sqlite3_file *file, sqlite3_int64 offset, void *memory),
    (underlying, offset, memory))

static const sqlite3_io_methods gIOMethods = {
    3,
    secure_close,
    secure_xRead,
    secure_xWrite,
    secure_xTruncate,
    secure_xSync,
    secure_xFileSize,
    secure_xLock,
    secure_xUnlock,
    secure_xCheckReservedLock,
    secure_xFileControl,
    secure_xSectorSize,
    secure_xDeviceCharacteristics,
    secure_xShmMap,
    secure_xShmLock,
    secure_xShmBarrier,
    secure_xShmUnmap,
    secure_xFetch,
    secure_xUnfetch,
};

static int secure_open(
    sqlite3_vfs *vfs,
    sqlite3_filename name,
    sqlite3_file *file,
    int flags,
    int *out_flags
) {
    (void)vfs;
    memset(file, 0, gVFS.szOsFile);
    AmbitionsSecureFile *secure = (AmbitionsSecureFile *)file;
    secure->retained_fd = -1;
    secure->shm_fd = -1;
    if (pthread_mutex_init(&secure->shm_lock, NULL) != 0) return SQLITE_NOMEM;

    const char *leaf = NULL;
    struct AmbitionsSQLiteSecureVFSContext *context = context_for_path(name, &leaf);
    if (context == NULL) {
        sqlite3_file *underlying = underlying_file(file);
        const int result = gDefaultVFS->xOpen(
            gDefaultVFS, name, underlying, flags, out_flags
        );
        if (result != SQLITE_OK) {
            if (underlying->pMethods != NULL && underlying->pMethods->xClose != NULL) {
                (void)underlying->pMethods->xClose(underlying);
            }
            (void)pthread_mutex_destroy(&secure->shm_lock);
            return result;
        }
        /* Unmanaged files may use ordinary I/O, but never inherit xShm. */
        file->pMethods = &gIOMethods;
        return SQLITE_OK;
    }
    secure->context = context;
    secure->context_identifier = context->identifier;
    secure->namespace_identifier = context->namespace_identifier;
    secure->is_main_file = strcmp(leaf, context->basename) == 0;
    if (!allowed_basename(leaf)) {
        (void)pthread_mutex_destroy(&secure->shm_lock);
        return SQLITE_CANTOPEN;
    }

    int open_flags = O_CLOEXEC | O_NOFOLLOW;
    if (flags & SQLITE_OPEN_READONLY) open_flags |= O_RDONLY;
    else open_flags |= O_RDWR;
    if (flags & SQLITE_OPEN_CREATE) open_flags |= O_CREAT;
    if (flags & SQLITE_OPEN_EXCLUSIVE) open_flags |= O_EXCL;
    const int descriptor = openat(
        context->directory_fd,
        leaf,
        open_flags,
        S_IRUSR | S_IWUSR
    );
    if (descriptor < 0 || !is_regular_single_link_file(descriptor)) {
        if (descriptor >= 0) close(descriptor);
        (void)pthread_mutex_destroy(&secure->shm_lock);
        return SQLITE_CANTOPEN;
    }

    char descriptor_path[64];
    const int path_length = snprintf(
        descriptor_path, sizeof(descriptor_path), "/dev/fd/%d", descriptor
    );
    if (path_length < 0 || (size_t)path_length >= sizeof(descriptor_path)) {
        close(descriptor);
        (void)pthread_mutex_destroy(&secure->shm_lock);
        return SQLITE_CANTOPEN;
    }
    sqlite3_file *underlying = underlying_file(file);
    int delegated_flags = flags & ~(SQLITE_OPEN_CREATE | SQLITE_OPEN_EXCLUSIVE | SQLITE_OPEN_NOFOLLOW);
    const int result = gDefaultVFS->xOpen(
        gDefaultVFS, descriptor_path, underlying, delegated_flags, out_flags
    );
    if (result != SQLITE_OK) {
        if (underlying->pMethods != NULL && underlying->pMethods->xClose != NULL) {
            (void)underlying->pMethods->xClose(underlying);
        }
        close(descriptor);
        (void)pthread_mutex_destroy(&secure->shm_lock);
        return result;
    }
    if (secure->is_main_file) {
        struct stat status;
        const int has_descriptor_identity = fstat(descriptor, &status) == 0;
        int identity_accepted = 0;
        if (has_descriptor_identity) {
            pthread_mutex_lock(&gContextLock);
            if (!context->has_main_file_identity) {
                context->main_file_device = status.st_dev;
                context->main_file_inode = status.st_ino;
                context->has_main_file_identity = 1;
                identity_accepted = 1;
            } else {
                identity_accepted =
                    context->main_file_device == status.st_dev &&
                    context->main_file_inode == status.st_ino;
            }
            pthread_mutex_unlock(&gContextLock);
        }
        if (!identity_accepted) {
            if (underlying->pMethods != NULL && underlying->pMethods->xClose != NULL) {
                (void)underlying->pMethods->xClose(underlying);
            }
            close(descriptor);
            (void)pthread_mutex_destroy(&secure->shm_lock);
            return SQLITE_CANTOPEN;
        }
    }
    secure->retained_fd = descriptor;
    file->pMethods = &gIOMethods;
    return SQLITE_OK;
}

static int secure_delete(sqlite3_vfs *vfs, const char *name, int sync_directory) {
    (void)vfs;
    const char *leaf = NULL;
    struct AmbitionsSQLiteSecureVFSContext *context = context_for_path(name, &leaf);
    if (context == NULL) return gDefaultVFS->xDelete(gDefaultVFS, name, sync_directory);
    if (!allowed_basename(leaf)) return SQLITE_IOERR_DELETE;
    struct stat status;
    if (fstatat(context->directory_fd, leaf, &status, AT_SYMLINK_NOFOLLOW) != 0 ||
        !S_ISREG(status.st_mode) || status.st_nlink != 1) return SQLITE_IOERR_DELETE;
    if (unlinkat(context->directory_fd, leaf, 0) != 0) return SQLITE_IOERR_DELETE;
    if (sync_directory && fsync(context->directory_fd) != 0) return SQLITE_IOERR_DELETE;
    return SQLITE_OK;
}

static int secure_access(sqlite3_vfs *vfs, const char *name, int flags, int *result) {
    (void)vfs;
    const char *leaf = NULL;
    struct AmbitionsSQLiteSecureVFSContext *context = context_for_path(name, &leaf);
    if (context == NULL) return gDefaultVFS->xAccess(gDefaultVFS, name, flags, result);
    if (!allowed_basename(leaf)) {
        *result = 0;
        return SQLITE_OK;
    }
    struct stat status;
    if (fstatat(context->directory_fd, leaf, &status, AT_SYMLINK_NOFOLLOW) != 0 ||
        !S_ISREG(status.st_mode) || status.st_nlink != 1) {
        *result = 0;
        return SQLITE_OK;
    }
    /*
     * This is an advisory existence query. Permission is authoritatively
     * checked by the later openat() against the pinned directory. Calling
     * access() on the virtual pathname would both fail incorrectly and risk
     * reintroducing pathname resolution outside the descriptor root.
     */
    *result = flags == SQLITE_ACCESS_EXISTS || flags == SQLITE_ACCESS_READ ||
        flags == SQLITE_ACCESS_READWRITE;
    return SQLITE_OK;
}

static int secure_full_pathname(
    sqlite3_vfs *vfs,
    const char *name,
    int output_size,
    char *output
) {
    (void)vfs;
    const char *leaf = NULL;
    struct AmbitionsSQLiteSecureVFSContext *context = context_for_path(name, &leaf);
    if (context == NULL) {
        return gDefaultVFS->xFullPathname(gDefaultVFS, name, output_size, output);
    }
    if (!allowed_basename(leaf) || strlen(name) + 1 > (size_t)output_size) {
        return SQLITE_CANTOPEN;
    }
    memcpy(output, name, strlen(name) + 1);
    return SQLITE_OK;
}

#define FORWARD_VFS(name, args, call) \
    static int secure_vfs_##name args { return gDefaultVFS->name call; }

static void *secure_dl_open(sqlite3_vfs *vfs, const char *filename) {
    (void)vfs;
    return gDefaultVFS->xDlOpen(gDefaultVFS, filename);
}
static void secure_dl_error(sqlite3_vfs *vfs, int size, char *message) {
    (void)vfs;
    gDefaultVFS->xDlError(gDefaultVFS, size, message);
}
static void (*secure_dl_sym(sqlite3_vfs *vfs, void *handle, const char *symbol))(void) {
    (void)vfs;
    return gDefaultVFS->xDlSym(gDefaultVFS, handle, symbol);
}
static void secure_dl_close(sqlite3_vfs *vfs, void *handle) {
    (void)vfs;
    gDefaultVFS->xDlClose(gDefaultVFS, handle);
}
FORWARD_VFS(xRandomness, (sqlite3_vfs *vfs, int bytes, char *output), (gDefaultVFS, bytes, output))
FORWARD_VFS(xSleep, (sqlite3_vfs *vfs, int microseconds), (gDefaultVFS, microseconds))
FORWARD_VFS(xCurrentTime, (sqlite3_vfs *vfs, double *time), (gDefaultVFS, time))
FORWARD_VFS(xGetLastError, (sqlite3_vfs *vfs, int bytes, char *output), (gDefaultVFS, bytes, output))
FORWARD_VFS(xCurrentTimeInt64, (sqlite3_vfs *vfs, sqlite3_int64 *time), (gDefaultVFS, time))
static int secure_set_system_call(sqlite3_vfs *vfs, const char *name, sqlite3_syscall_ptr pointer) {
    (void)vfs;
    return gDefaultVFS->xSetSystemCall(gDefaultVFS, name, pointer);
}
static sqlite3_syscall_ptr secure_get_system_call(sqlite3_vfs *vfs, const char *name) {
    (void)vfs;
    return gDefaultVFS->xGetSystemCall(gDefaultVFS, name);
}
static const char *secure_next_system_call(sqlite3_vfs *vfs, const char *name) {
    (void)vfs;
    return gDefaultVFS->xNextSystemCall(gDefaultVFS, name);
}

static void install_vfs_once(void) {
    gDefaultVFS = sqlite3_vfs_find(NULL);
    if (gDefaultVFS == NULL || gDefaultVFS->xOpen == NULL ||
        gDefaultVFS->xDelete == NULL || gDefaultVFS->xAccess == NULL ||
        gDefaultVFS->xFullPathname == NULL) {
        gInstallResult = SQLITE_ERROR;
        return;
    }
    gUnderlyingOffset = (sizeof(AmbitionsSecureFile) + alignof(max_align_t) - 1) &
        ~(alignof(max_align_t) - 1);
    memset(&gVFS, 0, sizeof(gVFS));
    gVFS.iVersion = gDefaultVFS->iVersion;
    gVFS.szOsFile = (int)(gUnderlyingOffset + (size_t)gDefaultVFS->szOsFile);
    gVFS.mxPathname = gDefaultVFS->mxPathname;
    gVFS.zName = "ambitions-secure-descriptor-root";
    gVFS.xOpen = secure_open;
    gVFS.xDelete = secure_delete;
    gVFS.xAccess = secure_access;
    gVFS.xFullPathname = secure_full_pathname;
    gVFS.xDlOpen = secure_dl_open;
    gVFS.xDlError = secure_dl_error;
    gVFS.xDlSym = secure_dl_sym;
    gVFS.xDlClose = secure_dl_close;
    gVFS.xRandomness = secure_vfs_xRandomness;
    gVFS.xSleep = secure_vfs_xSleep;
    gVFS.xCurrentTime = secure_vfs_xCurrentTime;
    gVFS.xGetLastError = secure_vfs_xGetLastError;
    gVFS.xCurrentTimeInt64 = secure_vfs_xCurrentTimeInt64;
    gVFS.xSetSystemCall = secure_set_system_call;
    gVFS.xGetSystemCall = secure_get_system_call;
    gVFS.xNextSystemCall = secure_next_system_call;
    gInstallResult = sqlite3_vfs_register(&gVFS, 0);
}

int AmbitionsSQLiteSecureVFSInstall(void) {
    pthread_once(&gInstallOnce, install_vfs_once);
    return gInstallResult;
}

AmbitionsSQLiteSecureVFSContext *AmbitionsSQLiteSecureVFSCreateContext(
    int directory_file_descriptor,
    const char *database_basename
) {
    if (AmbitionsSQLiteSecureVFSInstall() != SQLITE_OK ||
        !allowed_basename(database_basename)) return NULL;
    const int retained_directory_fd = fcntl(directory_file_descriptor, F_DUPFD_CLOEXEC, 3);
    if (retained_directory_fd < 0) return NULL;
    struct stat status;
    if (fstat(retained_directory_fd, &status) != 0 ||
        !is_exclusive_owner_directory(&status)) {
        close(retained_directory_fd);
        return NULL;
    }
    struct AmbitionsSQLiteSecureVFSContext *context = calloc(1, sizeof(*context));
    if (context == NULL) {
        close(retained_directory_fd);
        return NULL;
    }
    context->directory_fd = retained_directory_fd;
    memcpy(context->basename, database_basename, strlen(database_basename) + 1);
    context->namespace_identifier = namespace_identifier_for(&status, database_basename);
    pthread_mutex_lock(&gContextLock);
    const uint64_t identifier = ++gNextContextIdentifier;
    context->identifier = identifier;
    const int written = snprintf(
        context->virtual_path, sizeof(context->virtual_path),
        "/ambitions-secure-sqlite/%ld-%llu/%s", (long)getpid(),
        (unsigned long long)identifier, context->basename
    );
    if (written < 0 || (size_t)written >= sizeof(context->virtual_path)) {
        pthread_mutex_unlock(&gContextLock);
        close(retained_directory_fd);
        free(context);
        return NULL;
    }
    context->next = gContexts;
    gContexts = context;
    pthread_mutex_unlock(&gContextLock);
    return context;
}

const char *AmbitionsSQLiteSecureVFSDatabasePath(
    const AmbitionsSQLiteSecureVFSContext *context
) {
    return context == NULL ? NULL : context->virtual_path;
}

const char *AmbitionsSQLiteSecureVFSName(void) {
    return "ambitions-secure-descriptor-root";
}

void AmbitionsSQLiteSecureVFSDestroyContext(
    AmbitionsSQLiteSecureVFSContext *context
) {
    if (context == NULL) return;
    pthread_mutex_lock(&gContextLock);
    struct AmbitionsSQLiteSecureVFSContext **link = &gContexts;
    while (*link != NULL && *link != context) link = &(*link)->next;
    if (*link == context) *link = context->next;
    pthread_mutex_unlock(&gContextLock);
    close(context->directory_fd);
    free(context);
}
