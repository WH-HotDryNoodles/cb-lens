# CB Lens / 转债透镜

把“手工 CSV + 两段式筛选”的旧可转债工具，重构为一个**本地一键运行、可免费部署、准实时、专业筛选**的研究工作台。后端 Flask，前端 React/TypeScript。

核心策略不变：**在可转债总体低迷时，捞低价、低风险、被低估的优质转债，做长线投资。**

## 快速开始（Windows）

```powershell
cd CB_Lens
powershell -ExecutionPolicy Bypass -File .\start.ps1
```

也可以双击 `start.bat`。启动后浏览器打开 `http://127.0.0.1:8765`。

- 需要 Python 3.11+（建议 3.12）与 Node.js 20+（仅首次构建前端需要）。
- 首次启动优先使用自带种子快照（`data/seed.sqlite3.gz`），随后在后台增量刷新；若没有种子，会拉取约 300 只活跃转债、正股行情、财务与历史 K 线。
- 运行数据默认放在 `%LOCALAPPDATA%\CBLens\data`，避免 OneDrive 同步锁住 SQLite；可用 `CB_DATA_DIR` 覆盖。
- 构建前端：`powershell -ExecutionPolicy Bypass -File .\build.ps1`。构建完成后运行只需要 Python。

## 主要功能

### 市场总览
- 中位价、中位溢价、双低中位、低于 100 元数量、涨跌家数、成交额。
- 近 1/3/5 年价格中位数趋势，支持滚轮缩放与底部滑块；P25–P75 区间、P10/P90 虚线。
- 当前价格四分位箱线、价格带分布、评级分布。
- 市场温度（可自定义权重/公式）、历史分位、机会雷达、强赎预警。
- 数据质量与数据源状态提示。

### 转债筛选
- **核心买点锁定**：信用评级、价格、价格全市场分位、转股溢价率、转股价值、剩余年限。
- **风险排除可开关**：资产负债率、流动比率、流动负债/总负债、正股价格、总市值、年度营收、ST、发行规模/市值；有息负债率、现金比率、利息保障、经营现金流/营收可选。
- **自定义增强**：YTM、纯债溢价、纯债价值、双低/双低分位、机会评分、数据完整度、成交额、ROE、净利率、毛利率、营收/利润同比、强赎距离、回售距离、上市天数等，可自由添加/删除。
- 预设：均衡型、保守型、进攻型、深度低估。
- 筛选诊断：告诉你放宽哪一项能增加多少只。
- 结果表支持排序、搜索、CSV 导出、自选、行点击详情。

### 个券研究
- 价格历史、指标卡、评分构成、正股财务（按报告期）、条款摘要、公告风险关键词、数据质量标记。
- YTM、纯债价值、纯债溢价、双低、剩余年限、规模/市值等估算口径均明确标注。
- 支持点击东方财富/集思录外部链接。

### 指标工作室（可自定义）
- 市场温度：回看窗口、低价阈值、权重、公式。
- 机会评分：分项权重、公式、缺失值策略；可预览保存后的温度与 Top 10。
- 纯债折现：评级贴现率表、无风险利率 + 利差模式、赎回价兜底。
- 数据清洗：价格有效/统计边界、财务陈旧阈值、严格缺失模式；高级清洗 JSON。
- 保存前预览、保存后重算、一键恢复默认；公式使用白名单安全表达式，不执行任意代码。

### 其他
- 收益测算：卖出转债 vs 转股卖出、简单年化、盈亏平衡正股价。
- 自选观察：本浏览器 localStorage，不上传。
- 数据与设置：数据源状态、历史回填进度、清洗统计、刷新日志、口径说明。

## 数据来源

免费公开接口，不接付费 API、不申请 Key、不用 Selenium：

| 数据 | 主源 | 备源 |
|---|---|---|
| 转债名录/评级/条款/行情 | 东方财富 `RPT_BOND_CB_LIST` + `quoteColumns` | 新浪转债行情 |
| 正股实时价/涨跌 | 新浪 `hq.sinajs.cn` 批量 | — |
| 正股财务 | 东方财富 `RPT_F10_FINANCE_MAINFINADATA` | 本地缓存 |
| 转债日线 | 新浪 `CN_MarketDataService.getKLineData` | 东财 K 线 |
| 公告风险 | 东方财富公告接口 | 无则显示“未覆盖” |

详见 [docs/DATA_SOURCES.md](docs/DATA_SOURCES.md)。

## 重要口径

- **准实时**：交易时段约 10 秒轮询，行情延迟约 3–15 秒；不是 Level-2/逐笔。
- **规模/市值**：当前无稳定“剩余规模”字段，用**发行规模/总市值**作为剩余规模的保守上限；详情页会标注。
- **YTM / 纯债价值**：估算值；到期赎回价从条款解析，失败时按 110 元；贴现率可在指标工作室修改。
- **年度营收**：阈值使用最新年报；季报/中报只做趋势参考。
- **金融行业**：资产负债率/流动比率口径不同，默认自动跳过这两项阈值并标注。
- **异常值**：极端价格、缺失、停牌、ST、报告期过旧等会打标；中位数/分位只使用有效样本；详见 [docs/DATA_QUALITY.md](docs/DATA_QUALITY.md)。
- 所有温度/评分/风险提示均为研究辅助，**不构成投资建议**；公开数据可能存在延迟、缺失或错误。

## 截图

![市场总览](docs/dashboard.png)
![转债筛选](docs/screener.png)
![个券详情](docs/detail.png)
![数据与质量](docs/data.png)

## 目录结构

```
CB_Lens/
├─ backend/app/        # Flask API、数据源、清洗、指标、公式、SQLite
├─ backend/tests/      # pytest 单元测试
├─ frontend/           # React + TypeScript + ECharts
├─ docs/               # 架构、数据源、指标、公式、质量、部署、UI
├─ scripts/            # 启动/构建/种子/冒烟检查
├─ start.ps1 / start.bat
├─ docker-compose.yml / Dockerfile
└─ README.md
```

## 部署

- 本地：见上文。
- Docker：
  ```bash
  docker compose up -d --build
  ```
- 免费网页：Render / Hugging Face Spaces / Cloudflare Tunnel。详见 [docs/DEPLOY.md](docs/DEPLOY.md)。
- 公网建议设置 `CB_PASSWORD`（HTTP Basic），只读模式 `CB_READ_ONLY=1`；免费平台可能休眠，本地版始终可用。

## 发布到 GitHub

见 [GITHUB_SETUP.md](GITHUB_SETUP.md)（已初始化本地仓库，并给出网页上传 / Git 命令两种方式）。

## 测试

```powershell
$env:PYTHONPATH = (Resolve-Path .\backend).Path
python -m pytest backend\tests -q
```

前端类型检查与构建：

```powershell
cd frontend
npx tsc --noEmit
npm run build
```


## 免责声明

本项目用于个人学习与研究，使用公开网络数据，不保证准确性、完整性与时效性；不构成任何投资建议。请自行核验数据并控制风险。
