import { AdaptationProfile, ReplanSuggestion } from "../../domain/models";
import { DatabaseClient } from "../../data/sqlite/client";
import { decodeJson, encodeJson, entityParams, mapEntityRecord } from "./shared";
import { AdaptationRepository } from "../AdaptationRepository";
import { SQLiteRepository } from "../base";

interface AdaptationProfileRow {
  id: string;
  effective_date: string;
  source: AdaptationProfile["source"];
  capacity_json: string;
  completion_json: string;
  friction_json: string;
  momentum_json: string;
  strategy_json: string;
  history_json: string;
  regression_json: string;
  duration_refinements_json: string;
  planning_directives_json: string;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: AdaptationProfile["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

interface ReplanSuggestionRow {
  id: string;
  plan_date: string;
  type: ReplanSuggestion["type"];
  title: string;
  rationale: string;
  task_id: string | null;
  time_block_id: string | null;
  confidence: number;
  suggested_start_at: string | null;
  suggested_end_at: string | null;
  metadata_json: string;
  owner_user_id: string | null;
  remote_id: string | null;
  sync_state: ReplanSuggestion["syncState"];
  version: number;
  last_synced_at: string | null;
  created_at: string;
  updated_at: string;
}

function fallbackPersonalization() {
  return {
    active: false,
    sampleSize: 0,
    taskSizingStyle: "mixed_tasks" as const,
    openWindowStyle: "mixed" as const,
    lateDayStyle: "steady" as const,
    carryoverStyle: "moderate" as const,
    planStability: "adjusting" as const,
    intensityStyle: "balanced" as const,
    recoveryStyle: "moderate" as const,
    bestFocusWindow: null,
    signals: [],
    summary: {
      planningStyle: "Adaptation is still learning from recent activity.",
      todayApproach: "Recommendations stay conservative until more history builds.",
      insights: "Reflection stays close to recent activity until the signal is stronger.",
    },
    explanation: "Adaptation is still learning from recent activity.",
  };
}

export class SQLiteAdaptationRepository
  extends SQLiteRepository
  implements AdaptationRepository
{
  constructor(database: DatabaseClient) {
    super(database);
  }

  async getLatestProfile() {
    const row = await this.database.getFirst<AdaptationProfileRow>(
      "SELECT * FROM adaptation_profiles ORDER BY effective_date DESC, created_at DESC LIMIT 1;",
    );

    if (!row) {
      return null;
    }

    const metadata = decodeJson(row.metadata_json) as AdaptationProfile["metadata"] & {
      personalization?: AdaptationProfile["personalization"];
    };

    return mapEntityRecord<AdaptationProfile>(row, {
      effectiveDate: row.effective_date,
      source: row.source,
      capacity: decodeJson(row.capacity_json),
      completion: decodeJson(row.completion_json),
      friction: decodeJson(row.friction_json),
      momentum: decodeJson(row.momentum_json),
      strategy: decodeJson(row.strategy_json),
      history: decodeJson(row.history_json),
      regression: decodeJson(row.regression_json),
      personalization: metadata.personalization ?? fallbackPersonalization(),
      durationRefinements: decodeJson(row.duration_refinements_json),
      planningDirectives: decodeJson(row.planning_directives_json),
      metadata,
    });
  }

  async listReplanSuggestions(planDate: string) {
    const rows = await this.database.getAll<ReplanSuggestionRow>(
      "SELECT * FROM replan_suggestions WHERE plan_date = ? ORDER BY confidence DESC;",
      [planDate],
    );
    return rows.map((row) =>
      mapEntityRecord<ReplanSuggestion>(row, {
        planDate: row.plan_date,
        type: row.type,
        title: row.title,
        rationale: row.rationale,
        taskId: row.task_id,
        timeBlockId: row.time_block_id,
        confidence: row.confidence,
        suggestedStartAt: row.suggested_start_at,
        suggestedEndAt: row.suggested_end_at,
        metadata: decodeJson(row.metadata_json),
      }),
    );
  }

  async saveProfiles(profiles: AdaptationProfile[]) {
    await this.database.withTransaction(async (client) => {
      for (const profile of profiles) {
        await client.run(
          `
            INSERT OR REPLACE INTO adaptation_profiles (
              id, effective_date, source, capacity_json, completion_json, friction_json,
              momentum_json, strategy_json, history_json, regression_json,
              duration_refinements_json, planning_directives_json, metadata_json, owner_user_id, remote_id,
              sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $effectiveDate, $source, $capacityJson, $completionJson, $frictionJson,
              $momentumJson, $strategyJson, $historyJson, $regressionJson,
              $durationRefinementsJson, $planningDirectivesJson, $metadataJson, $ownerUserId, $remoteId,
              $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(profile),
            $effectiveDate: profile.effectiveDate,
            $source: profile.source,
            $capacityJson: encodeJson(profile.capacity),
            $completionJson: encodeJson(profile.completion),
            $frictionJson: encodeJson(profile.friction),
            $momentumJson: encodeJson(profile.momentum),
            $strategyJson: encodeJson(profile.strategy),
            $historyJson: encodeJson(profile.history),
            $regressionJson: encodeJson(profile.regression),
            $durationRefinementsJson: encodeJson(profile.durationRefinements),
            $planningDirectivesJson: encodeJson(profile.planningDirectives),
            $metadataJson: encodeJson({
              ...profile.metadata,
              personalization: profile.personalization,
            }),
          },
        );
      }
    });
  }

  async saveReplanSuggestions(suggestions: ReplanSuggestion[]) {
    await this.database.withTransaction(async (client) => {
      for (const suggestion of suggestions) {
        await client.run(
          `
            INSERT OR REPLACE INTO replan_suggestions (
              id, plan_date, type, title, rationale, task_id, time_block_id, confidence,
              suggested_start_at, suggested_end_at, metadata_json, owner_user_id, remote_id,
              sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $planDate, $type, $title, $rationale, $taskId, $timeBlockId, $confidence,
              $suggestedStartAt, $suggestedEndAt, $metadataJson, $ownerUserId, $remoteId,
              $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(suggestion),
            $planDate: suggestion.planDate,
            $type: suggestion.type,
            $title: suggestion.title,
            $rationale: suggestion.rationale,
            $taskId: suggestion.taskId,
            $timeBlockId: suggestion.timeBlockId,
            $confidence: suggestion.confidence,
            $suggestedStartAt: suggestion.suggestedStartAt,
            $suggestedEndAt: suggestion.suggestedEndAt,
            $metadataJson: encodeJson(suggestion.metadata),
          },
        );
      }
    });
  }

  async replaceReplanSuggestions(planDate: string, suggestions: ReplanSuggestion[]) {
    await this.database.withTransaction(async (client) => {
      await client.run("DELETE FROM replan_suggestions WHERE plan_date = ?;", [planDate]);

      for (const suggestion of suggestions) {
        await client.run(
          `
            INSERT OR REPLACE INTO replan_suggestions (
              id, plan_date, type, title, rationale, task_id, time_block_id, confidence,
              suggested_start_at, suggested_end_at, metadata_json, owner_user_id, remote_id,
              sync_state, version, last_synced_at, created_at, updated_at
            ) VALUES (
              $id, $planDate, $type, $title, $rationale, $taskId, $timeBlockId, $confidence,
              $suggestedStartAt, $suggestedEndAt, $metadataJson, $ownerUserId, $remoteId,
              $syncState, $version, $lastSyncedAt, $createdAt, $updatedAt
            );
          `,
          {
            ...entityParams(suggestion),
            $planDate: suggestion.planDate,
            $type: suggestion.type,
            $title: suggestion.title,
            $rationale: suggestion.rationale,
            $taskId: suggestion.taskId,
            $timeBlockId: suggestion.timeBlockId,
            $confidence: suggestion.confidence,
            $suggestedStartAt: suggestion.suggestedStartAt,
            $suggestedEndAt: suggestion.suggestedEndAt,
            $metadataJson: encodeJson(suggestion.metadata),
          },
        );
      }
    });
  }
}
