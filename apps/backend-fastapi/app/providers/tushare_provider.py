from __future__ import annotations

from typing import Any, Dict, Optional


class TushareProvider:
    def __init__(self, token: Optional[str] = None) -> None:
        self.token = token

    def get_fundamentals(self, code: str) -> Dict[str, Any]:
        # Tushare remains optional in the first live-data cut. When no token is
        # configured, the analysis endpoint degrades gracefully instead of failing.
        if not self.token:
            return {}

        return {}
