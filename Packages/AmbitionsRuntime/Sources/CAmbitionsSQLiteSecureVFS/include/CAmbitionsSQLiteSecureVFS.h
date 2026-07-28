#ifndef C_AMBITIONS_SQLITE_SECURE_VFS_H
#define C_AMBITIONS_SQLITE_SECURE_VFS_H

#include <sqlite3.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct AmbitionsSQLiteSecureVFSContext AmbitionsSQLiteSecureVFSContext;

/* Installs the process-wide descriptor-rooted VFS. Idempotent and thread-safe. */
int AmbitionsSQLiteSecureVFSInstall(void);

/*
 * Takes a duplicate of directory_file_descriptor. `database_basename` must be
 * one path component. The directory must be owned by the effective user and
 * not writable by group or other. The returned context owns that duplicate and
 * remains valid until AmbitionsSQLiteSecureVFSDestroyContext is called.
 */
AmbitionsSQLiteSecureVFSContext *AmbitionsSQLiteSecureVFSCreateContext(
    int directory_file_descriptor,
    const char *database_basename
);

/* The context's stable virtual absolute pathname and registered VFS name. */
const char *AmbitionsSQLiteSecureVFSDatabasePath(
    const AmbitionsSQLiteSecureVFSContext *context
);
const char *AmbitionsSQLiteSecureVFSName(void);

/* Call only after SQLite has closed every connection using the context. */
void AmbitionsSQLiteSecureVFSDestroyContext(
    AmbitionsSQLiteSecureVFSContext *context
);

#ifdef __cplusplus
}
#endif

#endif
