# RE:TRACE API Documentation

## Overview

This document defines the future backend contract for the RE:TRACE mobile application. The frontend is intentionally implemented with mock repositories and local state only. The API below is a specification for a future production backend and is designed to support the RE:TRACE experience without embedding medical claims or diagnosis logic.

Base URL: /api/v1

All timestamps use ISO 8601 in UTC.
Example: 2026-08-29T09:30:00Z

Authentication: The frontend does not implement authentication yet. The future backend may require a bearer token or session cookie depending on deployment. The API contract assumes a user-specific authenticated session.

Required headers:
- Authorization: Bearer <token> (future auth)
- Content-Type: application/json
- X-Request-Id: optional correlation identifier for tracing

Common conventions:
- Units are kept explicit and consistent.
- Duration values are in minutes unless specified otherwise.
- Energy, stress, fatigue, pain, and symptom intensity values are on a 0-10 scale unless noted otherwise.
- Date/time values are UTC and converted to local time on the client.
- Validation errors should use the shared error envelope.

## Shared error format

{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Energy must be between 0 and 10.",
    "field": "energy",
    "request_id": "req_12345"
  }
}

## HTTP status codes

- 200 OK
- 201 Created
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 409 Conflict
- 422 Unprocessable Entity
- 429 Too Many Requests
- 500 Internal Server Error
- 503 Service Unavailable

## User endpoints

### GET /api/v1/user/profile
Response:
{
  "user_id": "user_001",
  "name": "Alex",
  "preferred_name": "Alex",
  "timezone": "America/New_York",
  "recovery_preferences": {
    "low_stimulation_mode": false,
    "reminder_frequency": "gentle",
    "animation_intensity": "moderate"
  },
  "created_at": "2026-01-14T08:00:00Z"
}

### PATCH /api/v1/user/profile
Request body:
{
  "preferred_name": "Alex",
  "timezone": "America/New_York",
  "recovery_preferences": {
    "low_stimulation_mode": true,
    "reminder_frequency": "gentle",
    "animation_intensity": "low"
  }
}

## Check-in endpoints

### POST /api/v1/check-ins
Request:
{
  "timestamp": "2026-08-29T09:30:00Z",
  "energy": 6,
  "fatigue": 3,
  "stress": 4,
  "mood": "okay",
  "symptoms": {
    "headache": 2,
    "brain_fog": 3,
    "dizziness": 0,
    "sensitivity": 1,
    "fatigue": 3,
    "stress": 4
  },
  "cognitive_load": 6,
  "physical_load": 4,
  "screen_time_minutes": 180,
  "notes": "Felt slightly tired after morning lecture."
}

Field validation:
- timestamp: required, ISO 8601 UTC timestamp
- energy: required, integer, range 0-10
- fatigue: required, integer, range 0-10
- stress: required, integer, range 0-10
- mood: required, enum: great, good, okay, tired, overloaded
- symptoms: optional object; all values are integer 0-10
- cognitive_load: required, integer, range 0-10
- physical_load: required, integer, range 0-10
- screen_time_minutes: optional integer, >= 0
- notes: optional string, max 500 chars

Response:
{
  "check_in_id": "checkin_456",
  "timestamp": "2026-08-29T09:30:00Z",
  "created_at": "2026-08-29T09:31:00Z",
  "status": "submitted"
}

### GET /api/v1/check-ins
Query params:
- start: optional ISO 8601 date-time
- end: optional ISO 8601 date-time
- limit: optional integer, default 30

Response:
{
  "items": [
    {
      "check_in_id": "checkin_456",
      "timestamp": "2026-08-29T09:30:00Z",
      "mood": "okay",
      "energy": 6,
      "fatigue": 3,
      "stress": 4,
      "symptoms": {
        "headache": 2,
        "brain_fog": 3,
        "dizziness": 0,
        "sensitivity": 1
      }
    }
  ]
}

## Recovery endpoints

### GET /api/v1/recovery/current
Response:
{
  "user_id": "user_001",
  "state": "steady",
  "capacity": "moderate",
  "summary": "Your recovery is close to your recent baseline.",
  "recovery_score": 74,
  "confidence": 0.72,
  "baseline_deviation": 0.12,
  "contributors": [
    "sleep",
    "cognitive_load",
    "activity"
  ],
  "timestamp": "2026-08-29T09:00:00Z",
  "is_medical_prediction": false
}

Definitions:
- state: steady | improving | high_load | reduced_capacity
- capacity: low | moderate | high
- baseline_deviation: relative difference from user baseline, numeric and direction-aware
- confidence: statistical confidence for pattern interpretation, 0.0-1.0
- medical certainty: distinct from confidence; this field should never imply a medical diagnosis. The API must not use terms like recovered, cleared, diagnosed, or medically safe.

### GET /api/v1/recovery/history
Response:
{
  "items": [
    {
      "date": "2026-08-29",
      "state": "steady",
      "capacity": "moderate",
      "sleep_minutes": 444,
      "energy": 6,
      "symptom_load": 3
    }
  ]
}

### GET /api/v1/recovery/baseline
Response:
{
  "typical_sleep_minutes": 435,
  "typical_resting_heart_rate_bpm": 68,
  "typical_activity_steps": 6200,
  "typical_energy": 7,
  "confidence": 0.81,
  "baseline_window_days": 30,
  "source": "historical_checkins_and_health_data"
}

### GET /api/v1/recovery/summary
Response:
{
  "period_days": 14,
  "overall": "Improving",
  "sleep": "Improving",
  "energy": "Improving",
  "symptoms": "Stable",
  "activity": "Returning toward baseline",
  "key_observations": [
    "Sleep consistency has improved over the last 14 days.",
    "Energy has recovered close to your recent baseline.",
    "Your symptoms remain stable for this period."
  ],
  "generated_at": "2026-08-29T09:00:00Z"
}

## Insights endpoints

### GET /api/v1/insights
Response:
{
  "items": [
    {
      "id": "insight_01",
      "category": "recovery",
      "title": "Pattern noticed",
      "description": "Your fatigue tends to increase after consecutive high-load days.",
      "severity": "low",
      "generated_at": "2026-08-29T09:00:00Z"
    }
  ]
}

## Plans endpoints

### GET /api/v1/plans/today
Response:
{
  "date": "2026-08-29",
  "items": [
    {
      "plan_id": "plan_001",
      "time": "09:00",
      "title": "Focus session",
      "type": "focus",
      "completed": false
    }
  ]
}

### POST /api/v1/plans
Request:
{
  "date": "2026-08-29",
  "time": "09:00",
  "title": "Focus session",
  "type": "focus",
  "notes": "Deep work block"
}

Response:
{
  "plan_id": "plan_001",
  "status": "created"
}

### PATCH /api/v1/plans/{plan_id}
Request:
{
  "time": "10:00",
  "title": "Recovery break",
  "type": "recovery",
  "completed": true
}

## Simulation endpoints

### POST /api/v1/simulations
Request:
{
  "sleep_minutes": 480,
  "study_minutes": 180,
  "break_frequency": "high",
  "exercise_intensity": "light",
  "workload_context": "study"
}

Response:
{
  "projected_load": "moderate",
  "confidence": 0.69,
  "explanation": "Based on your recent patterns, spreading your study session across two blocks may be easier to manage.",
  "recommendations": [
    "Take a 15-minute recovery break after the first study block.",
    "Consider a lighter evening if sleep is reduced."
  ],
  "is_medical_prediction": false,
  "generated_at": "2026-08-29T09:00:00Z"
}

## TRACE endpoints

### POST /api/v1/trace/chat
Request:
{
  "message": "Why is my capacity lower today?",
  "conversation_id": "conversation_001",
  "context": {
    "include_recovery": true,
    "include_recent_insights": true,
    "include_today_plan": true
  }
}

Response:
{
  "conversation_id": "conversation_001",
  "message_id": "msg_001",
  "response": "Your recent pattern suggests a heavier day than usual, with sleep and cognitive load likely contributing.",
  "suggested_actions": [
    "Adjust my day",
    "Why?",
    "Plan my day"
  ],
  "safety_notice": "This guidance is not a diagnosis and should not be treated as medical clearance.",
  "generated_at": "2026-08-29T09:00:00Z"
}

## Health data endpoint

### POST /api/v1/health-data/sync
Request:
{
  "source": "health_connect",
  "synced_at": "2026-08-29T09:00:00Z",
  "data": {
    "sleep": {
      "duration_minutes": 444,
      "start": "2026-08-28T23:10:00Z",
      "end": "2026-08-29T06:34:00Z"
    },
    "activity": {
      "steps": 5840,
      "active_minutes": 42
    },
    "heart_rate": {
      "resting_bpm": 68
    }
  }
}

Response:
{
  "status": "accepted",
  "synced_at": "2026-08-29T09:00:00Z",
  "processed_count": 3
}

Rules:
- Missing values should be omitted, not set to zero unless the source explicitly reports zero.
- Unsupported metrics should be ignored with no error if the source is not relevant.
- Sensor data ingestion should not block user-facing access to the current app experience.

## Relaxation endpoints

### GET /api/v1/relaxation/content
Response:
{
  "items": [
    {
      "type": "breathing",
      "id": "calm_01",
      "title": "Calm",
      "description": "A slower breath pattern for easing tension."
    },
    {
      "type": "fidget",
      "id": "bubble_01",
      "title": "Floating bubble",
      "description": "A quiet sensory interaction for short decompression."
    }
  ]
}

### GET /api/v1/relaxation/breathing
Response:
{
  "id": "calm_01",
  "name": "Calm",
  "inhale_seconds": 4,
  "hold_seconds": 2,
  "exhale_seconds": 6,
  "rest_seconds": 2,
  "session_durations_minutes": [1, 3, 5],
  "voice_guidance": true,
  "sound_enabled": true
}

## Screen / endpoint mapping

- Home -> /api/v1/recovery/current
- Check-in -> /api/v1/check-ins
- Recovery -> /api/v1/recovery/history
- Baseline -> /api/v1/recovery/baseline
- Insights -> /api/v1/insights
- Daily Plan -> /api/v1/plans/today
- What If -> /api/v1/simulations
- TRACE -> /api/v1/trace/chat
- Health Sync -> /api/v1/health-data/sync
- Recovery Summary -> /api/v1/recovery/summary
- Breathing -> /api/v1/relaxation/breathing

## Safety and policy notes

- RE:TRACE must never claim to diagnose or medically clear a user.
- Language must use phrases like: "Your recent pattern suggests...", "Based on your recent data...", and "One possible pattern is..."
- The system should not present recovery advice as a medical prescription.
- If symptoms are persistent or concerning, the app should encourage speaking with a healthcare professional.

## JSON enum reference

Mood values:
- great
- good
- okay
- tired
- overloaded

Recovery state values:
- steady
- improving
- high_load
- reduced_capacity

Capacity values:
- low
- moderate
- high

Plan types:
- focus
- physical
- social
- recovery
- routine

## Notes for backend implementation

- Store user-level preference data separately from historical recovery data.
- Preserve timezone and local conversion logic in the client layer.
- Keep all confidence and recommendation fields explicit and non-diagnostic.
- Return user-friendly summaries rather than raw digital metrics only.
- Implement graceful degradation for missing health data and partial check-ins.

This contract intentionally separates machine-readable health signals from non-diagnostic user guidance so the app remains clear, safe, and respectful of the user’s recovery journey.
