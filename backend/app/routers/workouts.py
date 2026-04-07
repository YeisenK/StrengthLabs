from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.models.workout import Exercise, Workout, WorkoutExercise, WorkoutSet
from app.schemas.workout import (
    CreateWorkoutRequest,
    UpdateWorkoutRequest,
    WorkoutListResponse,
    WorkoutResponse,
)

router = APIRouter(prefix="/workouts", tags=["workouts"])


@router.get("", response_model=WorkoutListResponse)
def list_workouts(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = (
        db.query(Workout)
        .filter(Workout.user_id == current_user.id)
        .order_by(Workout.date.desc())
    )
    total = query.count()
    items = query.offset((page - 1) * per_page).limit(per_page).all()
    return WorkoutListResponse(items=items, total=total, page=page, per_page=per_page)


@router.post("", response_model=WorkoutResponse, status_code=status.HTTP_201_CREATED)
def create_workout(
    body: CreateWorkoutRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    workout = Workout(
        user_id=current_user.id,
        name=body.name,
        date=body.date,
        duration_seconds=body.duration_seconds,
        notes=body.notes,
    )
    db.add(workout)
    db.flush()  # get workout.id before adding children

    for ex_in in body.exercises:
        exercise = db.get(Exercise, ex_in.exercise_id)
        if not exercise:
            raise HTTPException(status_code=404, detail=f"Exercise {ex_in.exercise_id} not found")

        we = WorkoutExercise(
            workout_id=workout.id,
            exercise_id=ex_in.exercise_id,
            order=ex_in.order,
        )
        db.add(we)
        db.flush()

        for s in ex_in.sets:
            db.add(
                WorkoutSet(
                    workout_exercise_id=we.id,
                    weight=s.weight,
                    reps=s.reps,
                    rpe=s.rpe,
                    order=s.order,
                )
            )

    db.commit()
    db.refresh(workout)
    return workout


@router.get("/{workout_id}", response_model=WorkoutResponse)
def get_workout(
    workout_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    workout = _get_or_404(db, workout_id, current_user.id)
    return workout


@router.put("/{workout_id}", response_model=WorkoutResponse)
def update_workout(
    workout_id: str,
    body: UpdateWorkoutRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    workout = _get_or_404(db, workout_id, current_user.id)
    if body.name is not None:
        workout.name = body.name
    if body.notes is not None:
        workout.notes = body.notes
    db.commit()
    db.refresh(workout)
    return workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_workout(
    workout_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    workout = _get_or_404(db, workout_id, current_user.id)
    db.delete(workout)
    db.commit()


def _get_or_404(db: Session, workout_id: str, user_id: str) -> Workout:
    workout = (
        db.query(Workout)
        .filter(Workout.id == workout_id, Workout.user_id == user_id)
        .first()
    )
    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")
    return workout
