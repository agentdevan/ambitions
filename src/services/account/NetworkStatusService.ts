import * as Network from "expo-network";

export class NetworkStatusService {
  static async isConnected() {
    try {
      const state = await Network.getNetworkStateAsync();
      return state.isConnected === true && state.isInternetReachable !== false;
    } catch {
      return true;
    }
  }
}
