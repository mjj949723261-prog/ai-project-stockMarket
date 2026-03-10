from __future__ import annotations

from typing import Dict, List

import akshare as ak


class AkshareNewsProvider:
    def get_company_news(self, code: str) -> List[Dict]:
        try:
            rows = ak.stock_news_em(symbol=code).head(8).to_dict("records")
        except Exception:
            return []
        return self._normalize(rows)

    def _normalize(self, rows: List[Dict]) -> List[Dict]:
        items: List[Dict] = []
        for row in rows:
            title = row.get("新闻标题") or row.get("title") or ""
            summary = row.get("新闻内容") or row.get("摘要") or row.get("content") or title
            items.append(
                {
                    "title": str(title).strip(),
                    "summary": str(summary).strip(),
                    "source": str(row.get("文章来源") or row.get("source") or "东方财富").strip(),
                    "sourceUrl": str(row.get("新闻链接") or row.get("url") or ""),
                    "publishedAt": str(row.get("发布时间") or row.get("date") or ""),
                    "region": "domestic",
                    "category": "company",
                }
            )
        return [item for item in items if item["title"]]
