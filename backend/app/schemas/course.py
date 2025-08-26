from pydantic import BaseModel

class CourseCreate(BaseModel):
    title: str
    description: str

class CourseOut(BaseModel):
    id: int
    title: str
    description: str
    teacher_id: int

    model_config = {"from_attributes": True}
