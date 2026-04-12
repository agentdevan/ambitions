function createDeferred() {
  let resolve!: () => void;
  const promise = new Promise<void>((nextResolve) => {
    resolve = nextResolve;
  });

  return { promise, resolve };
}

let startupReady = false;
let startupReadyDeferred = createDeferred();

export function markStartupReady() {
  if (startupReady) {
    return;
  }

  startupReady = true;
  startupReadyDeferred.resolve();
}

export function resetStartupReady() {
  startupReady = false;
  startupReadyDeferred = createDeferred();
}

export async function waitForStartupReady() {
  if (startupReady) {
    return;
  }

  await startupReadyDeferred.promise;
}
