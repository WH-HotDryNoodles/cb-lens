# 把 CB Lens 发布到 GitHub（手动操作版）

## 已经准备好的

- `CB_Lens` 已经初始化为本地 Git 仓库，分支为 `main`，并完成首次提交。
- 已配置：
  - `user.name = CB Lens`
  - `user.email = cb-lens@users.noreply.github.com`
  - `credential.helper = manager`（Windows Git Credential Manager）
  - `core.quotepath = false`（中文文件名正常显示）
  - `core.autocrlf = false`（保持脚本原样）
- 已排除：运行时数据库、日志、`node_modules`、`.env`、缓存。
- 已包含：源码、预构建前端 `frontend/dist`、种子数据 `data/seed.sqlite3.gz`、截图与文档。
- 仓库约 16 MB、约 60 个文件，满足 GitHub 网页上传限制（单文件 <25 MB、单次 <100 个文件）。

## 方案 A：网页上传（推荐，直接用你已登录的 Edge）

1. 在 Edge 打开 <https://github.com/new>。
2. Repository name 填 `cb-lens`（或你喜欢的名字）；Public / Private 自选。
3. **不要**勾选 “Add a README file / Add .gitignore / Choose a license”；直接 Create repository。
4. 在新仓库页面点击 **uploading an existing file**（或 Add file → Upload files）。
5. 在资源管理器打开：

   ```text
   ...\旧可转债Shiny\CB_Lens
   ```

   打开“查看 → 显示 → 隐藏的项目”，选中除 `.git` 之外的所有文件和文件夹（`.gitignore`、`.dockerignore` 也要选），拖进浏览器上传区域。
6. 等待上传完成（`data/seed.sqlite3.gz` 约 13 MB，可能需要几十秒），Commit message 填：

   ```text
   Initial commit: CB Lens v1.0
   ```

   点击 **Commit changes**。
7. 回到仓库首页，确认根目录有：
   `README.md`、`backend/`、`frontend/`、`data/`、`docs/`、`start.ps1`、`Dockerfile`。
8. 如果隐藏文件 `.gitignore` / `.dockerignore` 没上传成功：在 GitHub 仓库点 **Add file → Create new file**，文件名分别填 `.gitignore`、`.dockerignore`，把本地内容粘贴进去并提交即可。

> 重要：不要把 `.git` 文件夹拖进网页；它是本地版本库元数据，不是项目文件。

## 方案 B：Git 命令（先创建空仓库，不要初始化 README）

1. 同样先在 Edge 创建空仓库（同方案 A 第 1–3 步）。
2. 在 PowerShell 执行：

   ```powershell
   cd "...\旧可转债Shiny\CB_Lens"
   git remote add origin https://github.com/<你的GitHub用户名>/cb-lens.git
   git push -u origin main
   ```

3. 第一次 push 会弹出 Git Credential Manager 登录窗口，选择 GitHub / 浏览器，用 Edge 已登录的账号授权。
4. 如果提示连不上 GitHub（当前这台机器的 shell 直连 GitHub 会超时，而 Edge 能打开），**不要反复重试**，直接改用方案 A 网页上传。

如果创建仓库时误勾选了 README，push 前先执行：

```powershell
git pull --rebase origin main
```

## 修改提交作者（可选，push 前做）

当前首次提交的作者是占位身份。如果希望显示你自己的 GitHub 身份：

```powershell
cd "...\旧可转债Shiny\CB_Lens"
git config user.name "你的名字"
git config user.email "你的GitHub邮箱"
git commit --amend --reset-author --no-edit
```

然后再 push（或改用网页上传；网页上传不依赖这个提交作者）。

## 部署到 Render（免费网页版）

仓库上传成功后：

1. Render → New → Web Service → 选择该仓库 → Runtime 选 Docker。
2. 健康检查路径：`/api/health`。
3. 免费档会休眠；首次访问冷启动约 30–60 秒。
4. 可选环境变量：`CB_PASSWORD`（访问密码）、`CB_READ_ONLY=1`。
5. 更多：见 [docs/DEPLOY.md](docs/DEPLOY.md)。

## 安全与注意

- 种子里是公开市场数据，不含你的个人信息；`.env`、运行时数据库、日志不会提交。
- 不要把 GitHub 密码或 Token 发到聊天里；用浏览器官网登录即可。
- 不要删除本地 `.git` 目录，否则本地版本历史会丢失。
- 如果之后修改代码，推荐流程：

  ```powershell
  git add -A
  git commit -m "描述这次修改"
  git push
  ```

  网页上传方式则每次重新上传变更文件（适合不熟悉 Git 的情况）。
