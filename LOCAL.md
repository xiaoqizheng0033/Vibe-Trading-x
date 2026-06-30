# LOCAL.md — 本 Fork 本地维护笔记

> **仅记录差异与运维信息，勿写入 API Key、Token、密码。**  
> 建议提交到 **你的 origin 仓库**；`agent/.env` 永不提交。

---

## 仓库

| Remote | URL | 用途 |
|--------|-----|------|
| **origin** | https://github.com/xiaoqizheng0033/Vibe-Trading-x.git | 我的 fork，日常 push |
| **upstream** | https://github.com/HKUDS/Vibe-Trading.git | 官方源，只 fetch 不同步 push |

| 分支 | 用途 |
|------|------|
| **main** | 与 upstream 对齐的稳定基线 + 已合并的定制 |
| **dev** | 日常开发，功能/Bug 在此完成后再 merge 到 main |

---

## 相对 upstream 的定制（持续更新）

| 类型 | 路径/说明 | 原因 |
|------|-----------|------|
| 启动脚本 | `start.bat`, `start-full.bat` | Windows 一键启动 + 构建前端 |
| 运维脚本 | `scripts/smoke_agent_e2e.py`, `scripts/network-check.bat`, `scripts/network_data_probe.py` | 冒烟测试与网络诊断 |
| 学习文档 | `docs/research/` | 本地研究笔记（**upstream .gitignore 忽略 docs/**，fork 若需版本管理见下方） |
| 配置 | `agent/.env` | DeepSeek 等 LLM / 可选 Tushare（**仅本地，不提交**） |

### 计划中的改动

- [ ] 功能定制：_（填写）_
- [ ] 配置适配：_（填写）_
- [ ] Bug 修复：_（填写）_

---

## 本地环境与启动

| 项 | 值 |
|----|-----|
| OS | Windows |
| Python | `.venv` 3.12+（系统 python 可能为 3.10，勿直接用） |
| 安装 | `pip install -e .` |
| 一键启动 | `start-full.bat`（构建前端 + serve :8899） |
| 快速启动 | `start.bat`（需已有 `frontend/dist`） |
| Web | http://127.0.0.1:8899/agent |
| Docker | `docker compose up --build`（需 `agent/.env`） |

---

## 上游同步记录

| 日期 | upstream commit | 说明 | 验证 |
|------|-----------------|------|------|
| _YYYY-MM-DD_ | _hash_ | 首次 fork 初始化 | _待填_ |

### 上次 sync 后验证命令

```powershell
cd C:\Myfiles\codesrun\Vibe-Trading
.\.venv\Scripts\pip install -e .
cd frontend; npm install; npm run build; cd ..
.\.venv\Scripts\python.exe scripts\smoke_agent_e2e.py
```

---

## 已知本地差异 / 坑

- **DNS**：本机 `www.okx.com` 可能被解析到 `169.254.x.x`，OKX 直连失败；`auto` 模式可 fallback ccxt/eastmoney 等。
- **Yahoo**：偶发 429 限流，Preflight 可能 FAIL 但不影响 A 股与部分 fallback。
- **docs/**：官方 `.gitignore` 整目录忽略；若要在 fork 里提交 `docs/research/`，在 `.gitignore` 增加 `!docs/research/`。

---

## 冲突处理备忘

| 文件/区域 | 倾向 |
|-----------|------|
| `start*.bat`, `scripts/`, `LOCAL.md` | **保留我的** |
| `agent/.env` | **永不提交**；冲突时删出版本控制 |
| `agent/src/`, `agent/backtest/`, 安全相关 | **优先 upstream**，再重放我的定制 |
| `pyproject.toml`, `frontend/package.json` | 合并后重装依赖再测 |
| `README*.md` | upstream 为主，定制说明放 LOCAL.md 或 README 末尾小节 |
