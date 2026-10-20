# syntax=docker/dockerfile:1
FROM node:22-slim AS web
WORKDIR /web
COPY frontend/package.json frontend/tsconfig.json frontend/vite.config.ts frontend/index.html ./
COPY frontend/src ./src
RUN npm install --no-audit --no-fund --ignore-scripts && npm run build

FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/backend \
    CB_HOST=0.0.0.0 \
    CB_PORT=8765 \
    CB_DATA_DIR=/app/data \
    CB_LOG_DIR=/app/data/logs
WORKDIR /app
COPY backend/requirements.txt ./backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt
COPY backend ./backend
COPY --from=web /web/dist ./frontend/dist
COPY data/seed.sqlite3.gz ./data/seed.sqlite3.gz
RUN mkdir -p /app/data/logs && useradd -m -u 10001 cblens && chown -R cblens:cblens /app
USER cblens
EXPOSE 8765
VOLUME ["/app/data"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8765/api/health', timeout=3)" || exit 1
CMD ["python", "-m", "app.server"]
