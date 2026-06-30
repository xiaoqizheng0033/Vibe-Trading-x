"""Probe market data loaders — used by scripts/network-check.bat."""

from __future__ import annotations

from backtest.loaders.registry import get_loader_cls_with_fallback

CASES = [
    ("okx", "BTC-USDT", "2024-06-01", "2024-06-10"),
    ("yahoo", "AAPL.US", "2024-06-01", "2024-06-10"),
    ("eastmoney", "AAPL.US", "2024-06-01", "2024-06-10"),
    ("sina", "AAPL.US", "2024-06-01", "2024-06-10"),
    ("tencent", "000001.SZ", "2024-06-01", "2024-06-10"),
    ("ccxt", "BTC/USDT", "2024-06-01", "2024-06-10"),
]


def main() -> None:
    print(f"{'source':12} {'symbol':12} {'rows':>6}  note")
    print("-" * 50)
    for src, sym, start, end in CASES:
        note = ""
        try:
            cls = get_loader_cls_with_fallback(src)
            inst = cls()
            data = inst.fetch([sym], start, end)
            df = data.get(sym)
            if df is None and data:
                df = next(iter(data.values()))
            n = 0 if df is None else len(df)
            if n == 0:
                note = "empty"
        except Exception as e:
            n = -1
            note = str(e).replace("\n", " ")[:60]
        rows = "ERR" if n < 0 else str(n)
        print(f"{src:12} {sym:12} {rows:>6}  {note}")


if __name__ == "__main__":
    main()
