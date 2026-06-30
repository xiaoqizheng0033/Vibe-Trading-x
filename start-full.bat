@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo ========================================
echo   Vibe-Trading 一键构建 + 启动
echo ========================================
echo.

REM ---- 1. 释放 8899 端口 ----
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8899" ^| findstr "LISTENING"') do (
    echo [INFO] 端口 8899 被 PID %%a 占用，正在结束...
    taskkill /F /PID %%a >nul 2>&1
)

REM ---- 2. 检查 Python 虚拟环境 ----
if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] 未找到 .venv，请先执行：
    echo   python -m venv .venv
    echo   .venv\Scripts\pip install -e .
    pause
    exit /b 1
)

REM ---- 3. 检查 agent/.env ----
if not exist "agent\.env" (
    echo [WARN] 未找到 agent\.env，从模板复制...
    copy "agent\.env.example" "agent\.env" >nul
    echo [WARN] 请编辑 agent\.env 填入 LLM API Key 后重新运行
    pause
    exit /b 1
)

REM ---- 4. 检查 Node.js ----
where npm >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未找到 npm，请先安装 Node.js 20+：https://nodejs.org/
    pause
    exit /b 1
)

REM ---- 5. 构建前端 ----
echo [INFO] 正在构建前端（首次较慢，请稍候）...
cd frontend
if not exist "node_modules\" (
    echo [INFO] 首次运行，执行 npm install...
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install 失败
        cd ..
        pause
        exit /b 1
    )
)
call npm run build
if errorlevel 1 (
    echo [ERROR] npm run build 失败
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo [OK] 前端已构建到 frontend\dist
echo [INFO] 启动服务：http://localhost:8899
echo [INFO] 聊天页：http://localhost:8899/agent
echo [INFO] API 文档：http://localhost:8899/docs
echo [TIP] 开发热更新：另开终端 cd frontend ^&^& npm run dev → http://localhost:5899
echo.

.venv\Scripts\vibe-trading.exe serve --port 8899 --host 127.0.0.1

echo.
echo [INFO] 服务已停止
pause
