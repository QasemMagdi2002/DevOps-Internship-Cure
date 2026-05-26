from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_ENV: str = "development"
    APP_NAME: str = "CURE Patient Portal API"
    API_VERSION: str = "1.0.0"

    DATABASE_URL: str
    DB_AUTO_CREATE: bool = False

    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    CORS_ORIGINS: str = "http://localhost:5173,http://127.0.0.1:5173"

    AWS_REGION: str = "me-south-1"
    AWS_ACCESS_KEY_ID: str | None = None
    AWS_SECRET_ACCESS_KEY: str | None = None
    S3_BUCKET_NAME: str
    MAX_UPLOAD_SIZE_MB: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def is_production(self) -> bool:
        return self.APP_ENV.lower() == "production"

    @property
    def cors_origin_list(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.CORS_ORIGINS.split(",")
            if origin.strip()
        ]

    def validate_security(self) -> None:
        if len(self.JWT_SECRET) < 32:
            raise ValueError("JWT_SECRET must be at least 32 characters long.")

        if not self.S3_BUCKET_NAME:
            raise ValueError("S3_BUCKET_NAME environment variable is required.")

        if self.is_production and self.DB_AUTO_CREATE:
            raise ValueError("DB_AUTO_CREATE must be false in production.")

        if self.is_production and "*" in self.cors_origin_list:
            raise ValueError("Wildcard CORS origins are not allowed in production.")


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    settings.validate_security()
    return settings