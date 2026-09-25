# Small official Python image (Debian slim). Pinned to a minor version.
FROM python:3.14-slim

# Don't write .pyc files; flush logs straight to `docker logs`.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=8000

WORKDIR /app

# Dedicated unprivileged user. The app never runs as root.
RUN groupadd --system app && useradd --system --gid app --no-create-home app

# Install dependencies first: this layer is cached until requirements.txt
# changes, so editing app.py doesn't reinstall everything.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the code owned by root and read-only for the app user, so a
# compromised process can't modify its own code.
COPY app.py .

USER app

# Documentation only; the port is published in docker-compose.yml.
EXPOSE 8000

# Docker marks the container unhealthy if /health stops answering.
# (python is used because the slim image has no curl.)
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"APP_PORT\"]}/health', timeout=2)"

# Gunicorn = production WSGI server (Flask's built-in server is for dev only).
# --worker-tmp-dir /dev/shm and --no-control-socket let the container
# filesystem be read-only (Gunicorn would otherwise write to /tmp and $HOME).
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${APP_PORT} --workers 2 --worker-tmp-dir /dev/shm --no-control-socket --access-logfile - --error-logfile - app:app"]