from __future__ import annotations

from datetime import date, timedelta
from typing import Dict, List

import akshare as ak


class AkshareProvider:
    def search_stocks(self, query: str) -> List[Dict]:
        dataframe = ak.stock_info_a_code_name()
        keyword = query.strip()
        if keyword:
            dataframe = dataframe[
                dataframe["code"].astype(str).str.contains(keyword)
                | dataframe["name"].astype(str).str.contains(keyword)
            ]

        return dataframe.head(20).to_dict("records")

    def get_stock_profile(self, code: str) -> Dict:
        dataframe = ak.stock_individual_info_em(symbol=code)
        data = {row["item"]: row["value"] for row in dataframe.to_dict("records")}

        return {
            "code": data.get("股票代码", code),
            "name": data.get("股票简称", code),
            "industry": data.get("行业"),
            "latest_price": float(data.get("最新", 0) or 0),
            "market_cap": float(data.get("总市值", 0) or 0),
            "listing_date": str(data.get("上市时间", "")),
        }

    def get_price_history(self, code: str, days: int = 30) -> List[Dict]:
        end = date.today()
        start = end - timedelta(days=days * 2)
        dataframe = ak.stock_zh_a_hist(
            symbol=code,
            period="daily",
            start_date=start.strftime("%Y%m%d"),
            end_date=end.strftime("%Y%m%d"),
            adjust="qfq",
        )

        records = dataframe.tail(days).to_dict("records")
        return [
            {
                "date": str(row["日期"]),
                "open": float(row["开盘"]),
                "close": float(row["收盘"]),
                "high": float(row["最高"]),
                "low": float(row["最低"]),
                "volume": float(row["成交量"]),
                "change_percent": float(row["涨跌幅"]),
                "turnover_rate": float(row["换手率"]),
            }
            for row in records
        ]
