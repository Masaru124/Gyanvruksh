from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class BadgeBase(BaseModel):
    name: str
    description: str
    category: str
    criteria_type: str
    criteria_value: int
    gyan_coins_reward: int

class BadgeCreate(BadgeBase):
    icon_url: Optional[str] = None

class BadgeRead(BadgeBase):
    id: int
    icon_url: Optional[str]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class UserBadgeBase(BaseModel):
    user_id: int
    badge_id: int

class UserBadgeCreate(UserBadgeBase):
    pass

class UserBadgeRead(UserBadgeBase):
    id: int
    badge_name: str
    badge_description: str
    earned_at: datetime
    category: str

    class Config:
        from_attributes = True

class StreakBase(BaseModel):
    user_id: int
    streak_type: str
    current_streak: int
    longest_streak: int

class StreakCreate(StreakBase):
    pass

class StreakRead(StreakBase):
    id: int
    last_activity: datetime
    created_at: datetime

    class Config:
        from_attributes = True

class DailyChallengeBase(BaseModel):
    title: str
    description: str
    challenge_type: str
    target_value: int
    gyan_coins_reward: int
    date: datetime.date

class DailyChallengeCreate(DailyChallengeBase):
    pass

class DailyChallengeRead(DailyChallengeBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class UserChallengeBase(BaseModel):
    user_id: int
    challenge_id: int
    progress: int

class UserChallengeCreate(UserChallengeBase):
    pass

class UserChallengeRead(UserChallengeBase):
    id: int
    challenge_title: str
    challenge_description: str
    target_value: int
    completed: bool
    completed_at: Optional[datetime]

    class Config:
        from_attributes = True

class LeaderboardEntry(BaseModel):
    user_id: int
    user_name: str
    gyan_coins: int
    rank: int
    badges_count: int
