import json
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional


@lru_cache(maxsize=1)
def load_stock_fixtures() -> List[Dict[str, Any]]:
    fixtures_path = (
        Path(__file__).resolve().parents[4] / "shared" / "product-spec" / "stock-fixtures.json"
    )
    return json.loads(fixtures_path.read_text(encoding="utf-8"))


def find_stock_fixture(code: str) -> Optional[Dict[str, Any]]:
    for item in load_stock_fixtures():
        if item["code"] == code:
            return item
    return None
