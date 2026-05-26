from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator


class UserRegister(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=72)

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, value: str) -> str:
        if not any(char.isupper() for char in value):
            raise ValueError("Password must contain at least one uppercase letter.")
        if not any(char.islower() for char in value):
            raise ValueError("Password must contain at least one lowercase letter.")
        if not any(char.isdigit() for char in value):
            raise ValueError("Password must contain at least one number.")
        return value


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=72)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    full_name: str


class DoctorCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    specialty: str = Field(min_length=2, max_length=120)
    location: str = Field(min_length=2, max_length=120)
    available: bool = True


class DoctorResponse(BaseModel):
    id: int
    name: str
    specialty: str
    location: str
    available: bool

    model_config = {"from_attributes": True}


class AppointmentCreate(BaseModel):
    doctor_id: int = Field(gt=0)
    appointment_date: datetime
    reason: str = Field(min_length=5, max_length=1000)


class AppointmentStatusUpdate(BaseModel):
    status: Literal["pending", "confirmed", "cancelled", "completed"]


class AppointmentResponse(BaseModel):
    id: int
    doctor_id: int
    appointment_date: datetime
    reason: str
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class DocumentResponse(BaseModel):
    id: int
    file_name: str
    content_type: str
    uploaded_at: datetime

    model_config = {"from_attributes": True}


class DocumentDownloadResponse(BaseModel):
    download_url: str


class ReadinessResponse(BaseModel):
    status: str
    database: str