from pathlib import Path
from uuid import uuid4

from botocore.exceptions import BotoCoreError, ClientError
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.s3 import get_s3_client
from app.core.security import get_current_user
from app.db.database import get_db
from app.db.models import MedicalDocument, User
from app.schemas import DocumentDownloadResponse, DocumentResponse

router = APIRouter(prefix="/documents", tags=["Documents"])

settings = get_settings()

ALLOWED_CONTENT_TYPES = {
    "application/pdf",
    "image/png",
    "image/jpeg",
}

ALLOWED_EXTENSIONS = {
    ".pdf",
    ".png",
    ".jpg",
    ".jpeg",
}


def validate_upload_file(file: UploadFile) -> None:
    file_extension = Path(file.filename or "").suffix.lower()

    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF, PNG, JPG, and JPEG files are allowed.",
        )

    if file_extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file extension.",
        )


@router.post("/upload", response_model=DocumentResponse, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    validate_upload_file(file)

    max_size_bytes = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024
    file_bytes = await file.read()

    if len(file_bytes) > max_size_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File size must not exceed {settings.MAX_UPLOAD_SIZE_MB} MB.",
        )

    safe_extension = Path(file.filename or "").suffix.lower()
    s3_key = f"patients/{current_user.id}/documents/{uuid4()}{safe_extension}"

    s3_client = get_s3_client()

    try:
        s3_client.put_object(
            Bucket=settings.S3_BUCKET_NAME,
            Key=s3_key,
            Body=file_bytes,
            ContentType=file.content_type,
            ServerSideEncryption="AES256",
        )
    except (BotoCoreError, ClientError):
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to upload document to secure object storage.",
        )

    document = MedicalDocument(
        patient_id=current_user.id,
        file_name=file.filename or "uploaded-document",
        content_type=file.content_type or "application/octet-stream",
        s3_key=s3_key,
    )

    db.add(document)
    db.commit()
    db.refresh(document)

    return document


@router.get("/my", response_model=list[DocumentResponse])
def list_my_documents(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return (
        db.query(MedicalDocument)
        .filter(MedicalDocument.patient_id == current_user.id)
        .order_by(MedicalDocument.uploaded_at.desc())
        .all()
    )


@router.get("/{document_id}/download", response_model=DocumentDownloadResponse)
def generate_download_url(
    document_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    document = (
        db.query(MedicalDocument)
        .filter(
            MedicalDocument.id == document_id,
            MedicalDocument.patient_id == current_user.id,
        )
        .first()
    )

    if not document:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Document not found.",
        )

    s3_client = get_s3_client()

    try:
        download_url = s3_client.generate_presigned_url(
            ClientMethod="get_object",
            Params={
                "Bucket": settings.S3_BUCKET_NAME,
                "Key": document.s3_key,
            },
            ExpiresIn=300,
        )
    except (BotoCoreError, ClientError):
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to generate secure download URL.",
        )

    return DocumentDownloadResponse(download_url=download_url)