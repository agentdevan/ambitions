export interface IntelligenceLayer {
  refinePlan(date: string): Promise<void>;
}

export const intelligenceLayer: IntelligenceLayer = {
  async refinePlan() {
    return;
  },
};
