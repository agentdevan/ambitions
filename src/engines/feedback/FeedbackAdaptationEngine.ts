export interface FeedbackAdaptationEngine {
  recordOutcome(date: string): Promise<void>;
}

export const feedbackAdaptationEngine: FeedbackAdaptationEngine = {
  async recordOutcome() {
    return;
  },
};
