from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="STOCK_ANALYSIS_",
        env_file=".env",
        extra="ignore",
    )

    tushare_token: Optional[str] = None
    search_cache_ttl_seconds: int = 60 * 60 * 12
    analysis_cache_ttl_seconds: int = 60 * 5


settings = Settings()
