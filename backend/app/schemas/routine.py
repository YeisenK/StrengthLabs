from pydantic import BaseModel

from app.schemas.workout import ExerciseResponse


class RoutineExerciseResponse(BaseModel):
    id: str
    exercise: ExerciseResponse
    sets: int
    reps_scheme: str
    notes: str | None
    order: int

    model_config = {"from_attributes": True}


class RoutineDayResponse(BaseModel):
    id: str
    name: str
    order: int
    exercises: list[RoutineExerciseResponse]

    model_config = {"from_attributes": True}


class RoutineResponse(BaseModel):
    id: str
    name: str
    level: str
    goal: str
    days_per_week: int
    description: str
    days: list[RoutineDayResponse]

    model_config = {"from_attributes": True}


class RoutineListResponse(BaseModel):
    items: list[RoutineResponse]
