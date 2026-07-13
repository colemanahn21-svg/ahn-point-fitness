import Foundation

// MARK: - OAuth

/// Response body from POST /oauth/oauth2/token (auth-code or refresh).
/// `refresh_token` is optional defensively — WHOOP only issues one when
/// the `offline` scope is requested.
struct WhoopTokenResponse: Decodable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int            // seconds, typically 3600
    let scope: String?
    let token_type: String?
}

// MARK: - API records (skeleton — full schemas filled in step 6)
//
// These are placeholders so the Services layer compiles end-to-end while
// auth is being verified. Each will be expanded against the WHOOP v1 docs
// (developer.whoop.com/api) once OAuth is confirmed working.

struct RecoveryRecord: Decodable, Identifiable {
    let cycle_id: Int
    let sleep_id: String?     // UUID linking to the sleep that produced this recovery
    let user_id: Int
    let created_at: String
    let updated_at: String
    let score_state: String?
    let score: RecoveryScore?

    var id: Int { cycle_id }  // Recovery is identified by its parent cycle

    struct RecoveryScore: Decodable {
        let user_calibrating: Bool?
        let recovery_score: Double?
        let resting_heart_rate: Double?
        let hrv_rmssd_milli: Double?
        let spo2_percentage: Double?
        let skin_temp_celsius: Double?
    }
}

struct CycleRecord: Decodable, Identifiable {
    let id: Int
    let user_id: Int
    let created_at: String
    let updated_at: String
    let start: String
    let end: String?
    let timezone_offset: String?
    let score_state: String?
    let score: CycleScore?

    struct CycleScore: Decodable {
        let strain: Double?
        let kilojoule: Double?
        let average_heart_rate: Int?
        let max_heart_rate: Int?
    }
}

struct SleepRecord: Decodable, Identifiable {
    let id: String                  // v2: UUID
    let cycle_id: Int?
    let v1_id: Int?
    let user_id: Int
    let created_at: String
    let updated_at: String
    let start: String
    let end: String
    let timezone_offset: String?
    let nap: Bool?
    let score_state: String?
    let score: SleepScore?

    struct SleepScore: Decodable {
        let stage_summary: StageSummary?
        let sleep_needed: SleepNeeded?
        let respiratory_rate: Double?
        let sleep_performance_percentage: Double?
        let sleep_consistency_percentage: Double?
        let sleep_efficiency_percentage: Double?
    }

    struct StageSummary: Decodable {
        let total_in_bed_time_milli: Int?
        let total_awake_time_milli: Int?
        let total_no_data_time_milli: Int?
        let total_light_sleep_time_milli: Int?
        let total_slow_wave_sleep_time_milli: Int?
        let total_rem_sleep_time_milli: Int?
        let sleep_cycle_count: Int?
        let disturbance_count: Int?
    }

    struct SleepNeeded: Decodable {
        let baseline_milli: Int?
        let need_from_sleep_debt_milli: Int?
        let need_from_recent_strain_milli: Int?
        let need_from_recent_nap_milli: Int?
    }
}

struct WorkoutRecord: Decodable, Identifiable {
    let id: Int
    let user_id: Int
    let created_at: String
    let updated_at: String
    let start: String
    let end: String
    let timezone_offset: String?
    let sport_id: Int?
    let score_state: String?
    let score: WorkoutScore?

    struct WorkoutScore: Decodable {
        let strain: Double?
        let average_heart_rate: Int?
        let max_heart_rate: Int?
        let kilojoule: Double?
        let percent_recorded: Double?
        let distance_meter: Double?
        let altitude_gain_meter: Double?
        let altitude_change_meter: Double?
    }
}

struct ProfileRecord: Decodable {
    let user_id: Int
    let email: String?
    let first_name: String?
    let last_name: String?
}

// MARK: - Paged response wrapper

struct WhoopCollection<T: Decodable>: Decodable {
    let records: [T]
    let next_token: String?
}
