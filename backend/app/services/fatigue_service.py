from collections import defaultdict
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.models.workout import Exercise, Workout, WorkoutExercise, WorkoutSet
from app.schemas.fatigue import FatigueDataPoint, FatigueSummaryResponse

# Rough weekly volume limits (kg × reps) used to normalise 0–100 scores.
# Based on typical intermediate weekly sets × average volume.
_MUSCLE_LIMITS: dict[str, float] = {
    "chest": 12_000,
    "back": 18_000,
    "legs": 24_000,
    "shoulders": 9_000,
    "arms": 7_000,
    "core": 6_000,
}

_OVERTRAINING_THRESHOLD = 85.0


def get_fatigue_summary(db: Session, user_id: str) -> FatigueSummaryResponse:
    now = datetime.now(timezone.utc)
    seven_days_ago = now - timedelta(days=7)

    rows = (
        db.query(WorkoutSet, Exercise, Workout.date)
        .join(WorkoutExercise, WorkoutSet.workout_exercise_id == WorkoutExercise.id)
        .join(Workout, WorkoutExercise.workout_id == Workout.id)
        .join(Exercise, WorkoutExercise.exercise_id == Exercise.id)
        .filter(Workout.user_id == user_id, Workout.date >= seven_days_ago)
        .all()
    )

    # Accumulate RPE-weighted volume per muscle group
    muscle_raw: dict[str, float] = defaultdict(float)
    for ws, exercise, _ in rows:
        rpe_factor = (ws.rpe or 7.0) / 10.0
        muscle_raw[exercise.muscle_group] += ws.weight * ws.reps * rpe_factor

    # Normalise to 0–100
    weekly_volume: dict[str, float] = {}
    for mg, limit in _MUSCLE_LIMITS.items():
        raw = muscle_raw.get(mg, 0.0)
        weekly_volume[mg] = min(100.0, round((raw / limit) * 100, 1))

    overall = round(sum(weekly_volume.values()) / len(weekly_volume), 1) if weekly_volume else 0.0
    is_overtraining = any(v >= _OVERTRAINING_THRESHOLD for v in weekly_volume.values())

    # Build 7-day trend (one point per day)
    trend = _build_trend(db, user_id, now)

    return FatigueSummaryResponse(
        overall_index=overall,
        is_overtraining=is_overtraining,
        weekly_volume=weekly_volume,
        trend=trend,
    )


def _build_trend(db: Session, user_id: str, now: datetime) -> list[FatigueDataPoint]:
    points: list[FatigueDataPoint] = []
    for days_back in range(6, -1, -1):
        day_end = now - timedelta(days=days_back)
        day_start = day_end - timedelta(days=1)

        rows = (
            db.query(WorkoutSet, Exercise)
            .join(WorkoutExercise, WorkoutSet.workout_exercise_id == WorkoutExercise.id)
            .join(Workout, WorkoutExercise.workout_id == Workout.id)
            .join(Exercise, WorkoutExercise.exercise_id == Exercise.id)
            .filter(Workout.user_id == user_id, Workout.date >= day_start, Workout.date < day_end)
            .all()
        )

        muscle_raw: dict[str, float] = defaultdict(float)
        for ws, exercise in rows:
            rpe_factor = (ws.rpe or 7.0) / 10.0
            muscle_raw[exercise.muscle_group] += ws.weight * ws.reps * rpe_factor

        normalised = {
            mg: min(100.0, (muscle_raw.get(mg, 0.0) / limit) * 100)
            for mg, limit in _MUSCLE_LIMITS.items()
        }
        index = round(sum(normalised.values()) / len(normalised), 1) if normalised else 0.0
        points.append(FatigueDataPoint(date=day_end, index=index))

    return points
