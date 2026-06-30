@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo   网络诊断：OKX / Yahoo / 备用数据源
echo ========================================
echo.

echo [DNS] www.okx.com
nslookup www.okx.com 2>nul
echo.
echo [DNS] query1.finance.yahoo.com
nslookup query1.finance.yahoo.com 2>nul
echo.

echo [HTTP] OKX 首页
curl.exe -sI --connect-timeout 5 https://www.okx.com 2>nul | findstr /I "HTTP"
echo [HTTP] Yahoo Finance API
curl.exe -sI --connect-timeout 5 https://query1.finance.yahoo.com 2>nul | findstr /I "HTTP"
echo.

echo [Python] 实测各数据源拉数（需 .venv）
if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python.exe scripts\network_data_probe.py
) else (
    echo [SKIP] 未找到 .venv，跳过 Python 探针
)

echo.
echo ========================================
echo 常见结论：
echo   OKX 解析到 169.254.x.x  → DNS 污染，需换 DNS/VPN 或改 hosts
echo   Yahoo 返回 429          → 限流，auto 模式会 fallback 到 eastmoney/sina
echo   加密 ccxt/binance 失败  → 网络限制，与本机环境有关
echo ========================================
pause
