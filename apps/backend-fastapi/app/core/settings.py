from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="STOCK_ANALYSIS_",
        env_file=".env",
        extra="ignore",
    )

    tushare_token: Optional[str] = None
    global_news_feed_urls: str = "https://feeds.reuters.com/reuters/businessNews,https://feeds.bloomberg.com/markets/news.rss"
    global_news_timeout_seconds: float = 6.0
    search_cache_ttl_seconds: int = 60 * 60 * 12
    analysis_cache_ttl_seconds: int = 60 * 5


settings = Settings()
