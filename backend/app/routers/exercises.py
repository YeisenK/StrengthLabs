from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.models.workout import Exercise
from app.schemas.workout import CreateExerciseRequest, ExerciseResponse

router = APIRouter(prefix="/exercises", tags=["exercises"])


@router.get("", response_model=list[ExerciseResponse])
def list_exercises(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Returns the global catalog plus the user's custom exercises."""
    return (
        db.query(Exercise)
        .filter((Exercise.user_id == None) | (Exercise.user_id == current_user.id))  # noqa: E711
        .order_by(Exercise.muscle_group, Exercise.name)
        .all()
    )


@router.post("", response_model=ExerciseResponse, status_code=status.HTTP_201_CREATED)
def create_exercise(
    body: CreateExerciseRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exercise = Exercise(
        name=body.name,
        muscle_group=body.muscle_group,
        is_custom=True,
        user_id=current_user.id,
    )
    db.add(exercise)
    db.commit()
    db.refresh(exercise)
    return exercise
