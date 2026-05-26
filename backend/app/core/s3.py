from functools import lru_cache

import boto3
from botocore.config import Config

from app.core.config import get_settings

settings = get_settings()


@lru_cache
def get_s3_client():
    client_kwargs = {
        "region_name": settings.AWS_REGION,
        "config": Config(
            retries={"max_attempts": 3, "mode": "standard"},
            connect_timeout=5,
            read_timeout=20,
        ),
    }

    # Local development only.
    # In EKS production, do not set static credentials.
    # boto3 will use IRSA automatically.
    if settings.AWS_ACCESS_KEY_ID and settings.AWS_SECRET_ACCESS_KEY:
        client_kwargs["aws_access_key_id"] = settings.AWS_ACCESS_KEY_ID
        client_kwargs["aws_secret_access_key"] = settings.AWS_SECRET_ACCESS_KEY

    return boto3.client("s3", **client_kwargs)