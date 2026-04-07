from uuid import uuid4

from sqlalchemy import ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Routine(Base):
    __tablename__ = "routines"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    level: Mapped[str] = mapped_column(String(20), nullable=False)       # beginner|intermediate|advanced
    goal: Mapped[str] = mapped_column(String(30), nullable=False)        # strength|hypertrophy|endurance|general_fitness
    days_per_week: Mapped[int] = mapped_column(Integer, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    days: Mapped[list["RoutineDay"]] = relationship(
        "RoutineDay", back_populates="routine", order_by="RoutineDay.order", cascade="all, delete-orphan"
    )


class RoutineDay(Base):
    __tablename__ = "routine_days"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid4()))
    routine_id: Mapped[str] = mapped_column(String, ForeignKey("routines.id", ondelete="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(60), nullable=False)
    order: Mapped[int] = mapped_column(Integer, default=0)

    routine: Mapped["Routine"] = relationship("Routine", back_populates="days")
    exercises: Mapped[list["RoutineExercise"]] = relationship(
        "RoutineExercise", back_populates="day", order_by="RoutineExercise.order", cascade="all, delete-orphan"
    )


class RoutineExercise(Base):
    __tablename__ = "routine_exercises"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid4()))
    day_id: Mapped[str] = mapped_column(String, ForeignKey("routine_days.id", ondelete="CASCADE"), nullable=False)
    exercise_id: Mapped[str] = mapped_column(String, ForeignKey("exercises.id"), nullable=False)
    sets: Mapped[int] = mapped_column(Integer, nullable=False)
    reps_scheme: Mapped[str] = mapped_column(String(20), nullable=False)  # e.g. "5", "8-12", "5/3/1+"
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    order: Mapped[int] = mapped_column(Integer, default=0)

    day: Mapped["RoutineDay"] = relationship("RoutineDay", back_populates="exercises")
    exercise: Mapped["Exercise"] = relationship("Exercise")
