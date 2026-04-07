from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.schemas.fatigue import FatigueSummaryResponse
from app.services.fatigue_service import get_fatigue_summary

router = APIRouter(prefix="/fatigue", tags=["fatigue"])


@router.get("/summary", response_model=FatigueSummaryResponse)
def fatigue_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_fatigue_summary(db, current_user.id)


@router.get("/weekly")
def fatigue_weekly(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Returns per-muscle-group weekly volume breakdown."""
    summary = get_fatigue_summary(db, current_user.id)
    return [
        {"muscle_group": mg, "percentage": pct}
        for mg, pct in summary.weekly_volume.items()
    ]
