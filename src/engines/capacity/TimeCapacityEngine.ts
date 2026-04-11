export interface TimeCapacityEngine {
  calculateDailyCapacity(date: string): Promise<void>;
}

export const timeCapacityEngine: TimeCapacityEngine = {
  async calculateDailyCapacity() {
    return;
  },
};
