from typing import Optional

from pydantic import BaseModel


class SearchStock(BaseModel):
    code: str
    name: str
    market: str = "A-share"
    industry: Optional[str] = None
