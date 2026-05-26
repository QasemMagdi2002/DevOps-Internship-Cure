from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import require_admin
from app.db.database import get_db
from app.db.models import Doctor, User
from app.schemas import DoctorCreate, DoctorResponse

router = APIRouter(prefix="/doctors", tags=["Doctors"])


@router.get("", response_model=list[DoctorResponse])
def list_doctors(db: Session = Depends(get_db)):
    return db.query(Doctor).order_by(Doctor.id.asc()).all()


@router.post("", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
def create_doctor(
    payload: DoctorCreate,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    doctor = Doctor(
        name=payload.name.strip(),
        specialty=payload.specialty.strip(),
        location=payload.location.strip(),
        available=payload.available,
    )

    db.add(doctor)
    db.commit()
    db.refresh(doctor)

    return doctor


@router.delete("/{doctor_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_doctor(
    doctor_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(require_admin),
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()

    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor not found.",
        )

    db.delete(doctor)
    db.commit()

    return None