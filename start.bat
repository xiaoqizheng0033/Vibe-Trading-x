@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo ========================================
echo   Vibe-Trading 本地启动脚本
echo ========================================
echo.

REM 释放 8899 端口（若被占用）
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8899" ^| findstr "LISTENING"') do (
    echo [INFO] 端口 8899 被 PID %%a 占用，正在结束...
    taskkill /F /PID %%a >nul 2>&1
)

REM 检查虚拟环境
if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] 未找到 .venv，请先执行：
    echo   python -m venv .venv
    echo   .venv\Scripts\pip install -e .
    pause
    exit /b 1
)

REM 检查 .env
if not exist "agent\.env" (
    echo [WARN] 未找到 agent\.env，正在从模板复制...
    copy "agent\.env.example" "agent\.env" >nul
    echo [WARN] 请编辑 agent\.env 填入 LLM API Key 后重新运行
)

echo [INFO] 启动 API + Web UI 于 http://localhost:8899
echo [INFO] 若 frontend\dist 不存在，请改用 start-full.bat（含自动构建）
echo [INFO] 开发模式前端（可选）：cd frontend ^&^& npm run dev  → http://localhost:5899
echo.

.venv\Scripts\vibe-trading.exe serve --port 8899 --host 127.0.0.1

echo.
echo [INFO] 服务已停止
pause
