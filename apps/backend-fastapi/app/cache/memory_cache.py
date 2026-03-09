import time
from dataclasses import dataclass
from typing import Any, Dict, Optional


@dataclass
class CacheItem:
    value: Any
    expires_at: float


class MemoryCache:
    def __init__(self) -> None:
        self._values: Dict[str, CacheItem] = {}

    def set(self, key: str, value: Any, ttl_seconds: int) -> None:
        self._values[key] = CacheItem(value=value, expires_at=time.time() + ttl_seconds)

    def get(self, key: str) -> Optional[Any]:
        item = self._values.get(key)
        if item is None:
            return None

        if time.time() > item.expires_at:
            self._values.pop(key, None)
            return None

        return item.value
