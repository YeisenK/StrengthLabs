from datetime import datetime

from pydantic import BaseModel


class ExerciseResponse(BaseModel):
    id: str
    name: str
    muscle_group: str
    is_custom: bool

    model_config = {"from_attributes": True}


class CreateExerciseRequest(BaseModel):
    name: str
    muscle_group: str


class WorkoutSetIn(BaseModel):
    weight: float
    reps: int
    rpe: float | None = None
    order: int = 0


class WorkoutExerciseIn(BaseModel):
    exercise_id: str
    sets: list[WorkoutSetIn]
    order: int = 0


class CreateWorkoutRequest(BaseModel):
    name: str
    date: datetime
    duration_seconds: int
    exercises: list[WorkoutExerciseIn]
    notes: str | None = None


class UpdateWorkoutRequest(BaseModel):
    name: str | None = None
    notes: str | None = None


# ── Response models ──────────────────────────────────────────────────────────

class WorkoutSetResponse(BaseModel):
    id: str
    weight: float
    reps: int
    rpe: float | None
    order: int

    model_config = {"from_attributes": True}


class WorkoutExerciseResponse(BaseModel):
    id: str
    exercise: ExerciseResponse
    sets: list[WorkoutSetResponse]
    order: int

    model_config = {"from_attributes": True}


class WorkoutResponse(BaseModel):
    id: str
    name: str
    date: datetime
    duration_seconds: int
    notes: str | None
    exercises: list[WorkoutExerciseResponse]

    model_config = {"from_attributes": True}


class WorkoutListResponse(BaseModel):
    items: list[WorkoutResponse]
    total: int
    page: int
    per_page: int
