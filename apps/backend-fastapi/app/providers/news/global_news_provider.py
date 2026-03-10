from __future__ import annotations

from email.utils import parsedate_to_datetime
from typing import Dict, List
from xml.etree import ElementTree

import httpx


class GlobalNewsProvider:
    SUPPORTED_SOURCES = {"Reuters", "Bloomberg"}

    def __init__(self, feed_urls: List[str] | None = None, timeout_seconds: float = 6.0) -> None:
        self.feed_urls = feed_urls or []
        self.timeout_seconds = timeout_seconds

    def get_market_news(self) -> List[Dict]:
        items: List[Dict] = []
        for url in self.feed_urls:
            try:
                response = httpx.get(url, timeout=self.timeout_seconds, follow_redirects=True)
                response.raise_for_status()
                items.extend(self._parse_rss(response.text))
            except Exception:
                continue
        return self._normalize(items)

    def _parse_rss(self, xml_text: str) -> List[Dict]:
        root = ElementTree.fromstring(xml_text)
        entries: List[Dict] = []
        for item in root.findall(".//item"):
            title = item.findtext("title", default="")
            summary = item.findtext("description", default="")
            link = item.findtext("link", default="")
            published = item.findtext("pubDate", default="")
            source = item.findtext("source", default="")
            if not source:
                if "reuters.com" in link:
                    source = "Reuters"
                elif "bloomberg.com" in link or "feeds.bloomberg.com" in link:
                    source = "Bloomberg"

            entries.append(
                {
                    "title": title,
                    "summary": summary,
                    "link": link,
                    "source": source,
                    "published": published,
                }
            )
        return entries

    def _normalize(self, entries: List[Dict]) -> List[Dict]:
        items: List[Dict] = []
        for item in entries:
            source = str(item.get("source") or "").strip()
            if source not in self.SUPPORTED_SOURCES:
                continue

            published = str(item.get("published") or "").strip()
            try:
                published = parsedate_to_datetime(published).strftime("%Y-%m-%d %H:%M")
            except Exception:
                pass

            items.append(
                {
                    "title": str(item.get("title") or "").strip(),
                    "summary": str(item.get("summary") or "").strip(),
                    "source": source,
                    "sourceUrl": str(item.get("link") or "").strip(),
                    "publishedAt": published,
                    "region": "global",
                    "category": "macro",
                }
            )

        return [item for item in items if item["title"]]
