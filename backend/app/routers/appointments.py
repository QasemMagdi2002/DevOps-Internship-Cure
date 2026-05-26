from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user, require_admin
from app.db.database import get_db
from app.db.models import Appointment, Doctor, User
from app.schemas import AppointmentCreate, AppointmentResponse, AppointmentStatusUpdate

router = APIRouter(prefix="/appointments", tags=["Appointments"])


@router.post("", response_model=AppointmentResponse, status_code=status.HTTP_201_CREATED)
def create_appointment(
    payload: AppointmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    doctor = db.query(Doctor).filter(Doctor.id == payload.doctor_id).first()

    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor not found.",
        )

    if not doctor.available:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This doctor is currently unavailable.",
        )

    appointment = Appointment(
        patient_id=current_user.id,
        doctor_id=payload.doctor_id,
        appointment_date=payload.appointment_date,
        reason=payload.reason.strip(),
        status="pending",
    )

    db.add(appointment)
    db.commit()
    db.refresh(appointment)

    return appointment


@router.get("/my", response_model=list[AppointmentResponse])
def list_my_appointments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return (
        db.query(Appointment)
        .filter(Appointment.patient_id == current_user.id)
        .order_by(Appointment.created_at.desc())
        .all()
    )


@router.get("", response_model=list[AppointmentResponse])
def list_all_appointments(
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    return db.query(Appointment).order_by(Appointment.created_at.desc()).all()


@router.patch("/{appointment_id}/status", response_model=AppointmentResponse)
def update_appointment_status(
    appointment_id: int,
    payload: AppointmentStatusUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()

    if not appointment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment not found.",
        )

    appointment.status = payload.status

    db.commit()
    db.refresh(appointment)

    return appointment