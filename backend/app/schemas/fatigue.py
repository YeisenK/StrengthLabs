from datetime import datetime

from pydantic import BaseModel


class FatigueDataPoint(BaseModel):
    date: datetime
    index: float


class FatigueSummaryResponse(BaseModel):
    overall_index: float          # 0–100
    is_overtraining: bool
    weekly_volume: dict[str, float]   # muscle_group → 0–100 % of weekly limit
    trend: list[FatigueDataPoint]     # last 7 days


class MuscleVolumeResponse(BaseModel):
    muscle_group: str
    volume_kg: float
    sets: int
    percentage: float             # 0–100 % of recommended weekly limit
