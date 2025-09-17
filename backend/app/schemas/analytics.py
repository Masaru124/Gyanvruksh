from pydantic import BaseModel
from datetime import datetime

class AnalyticsBase(BaseModel):
    analytics_type: str
    category: str
    metric_name: str
    metric_value: float
    period: str = "daily"

class AnalyticsRead(AnalyticsBase):
    id: int
    user_id: int
    recorded_at: datetime

    class Config:
        from_attributes = True

class ParentDashboardRead(BaseModel):
    id: int
    parent_id: int
    child_id: int
    report_data: str
    generated_at: datetime

    class Config:
        from_attributes = True
