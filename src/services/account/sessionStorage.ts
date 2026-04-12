import * as SecureStore from "expo-secure-store";

const prefix = "ambitions.account.";

async function getWebStorage() {
  if (typeof window === "undefined" || !window.localStorage) {
    return null;
  }

  return window.localStorage;
}

export const accountSessionStorage = {
  async getItem(key: string) {
    const namespacedKey = `${prefix}${key}`;
    const webStorage = await getWebStorage();

    if (webStorage) {
      return webStorage.getItem(namespacedKey);
    }

    return SecureStore.getItemAsync(namespacedKey);
  },
  async setItem(key: string, value: string) {
    const namespacedKey = `${prefix}${key}`;
    const webStorage = await getWebStorage();

    if (webStorage) {
      webStorage.setItem(namespacedKey, value);
      return;
    }

    await SecureStore.setItemAsync(namespacedKey, value);
  },
  async removeItem(key: string) {
    const namespacedKey = `${prefix}${key}`;
    const webStorage = await getWebStorage();

    if (webStorage) {
      webStorage.removeItem(namespacedKey);
      return;
    }

    await SecureStore.deleteItemAsync(namespacedKey);
  },
};
