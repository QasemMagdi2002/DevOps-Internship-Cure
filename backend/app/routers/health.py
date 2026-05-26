from fastapi import APIRouter, HTTPException, status

from app.db.database import check_database_connection
from app.schemas import ReadinessResponse

router = APIRouter(tags=["Health"])


@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "cure-backend",
    }


@router.get("/ready", response_model=ReadinessResponse)
def readiness_check():
    database_ok = check_database_connection()

    if not database_ok:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database is not ready.",
        )

    return ReadinessResponse(
        status="ready",
        database="connected",
    )