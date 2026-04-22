from datetime import datetime
from typing import Optional
from uuid import uuid4

from sqlalchemy import DateTime, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    # Nullable to support OAuth users who have no password
    hashed_password: Mapped[Optional[str]] = mapped_column(String, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    workouts: Mapped[list] = relationship("Workout", back_populates="user", cascade="all, delete-orphan")
    custom_exercises: Mapped[list] = relationship(
        "Exercise", back_populates="user", foreign_keys="Exercise.user_id"
    )
