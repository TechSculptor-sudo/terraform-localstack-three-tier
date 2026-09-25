"""Application tier of the three-tier demo.

In AWS this code would run on EC2 instances in the private app subnets,
behind the load balancer. Locally it runs as a Docker container.

Configuration comes from environment variables (12-factor style), so the
same image runs unchanged in every environment.
"""

import logging
import os
import socket

from flask import Flask, jsonify

APP_NAME = "Terraform Three-Tier Application"
APP_ENV = os.getenv("APP_ENV", "local")
APP_VERSION = os.getenv("APP_VERSION", "1.0")

app = Flask(__name__)

# Send application logs to the same place as Gunicorn's (stdout/stderr),
# so `docker compose logs app` shows everything.
gunicorn_logger = logging.getLogger("gunicorn.error")
if gunicorn_logger.handlers:
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)


@app.get("/")
def index():
    # socket.gethostname() is the container ID inside Docker -- once there
    # are several app containers, this shows which one answered.
    body = (
        f"{APP_NAME}\n"
        f"Environment: {APP_ENV}\n"
        f"Hostname: {socket.gethostname()}\n"
        f"Version: {APP_VERSION}\n"
    )
    return body, 200, {"Content-Type": "text/plain; charset=utf-8"}


@app.get("/health")
def health():
    # Liveness check: "is this process up and answering?" Deliberately does
    # NOT touch the database, so a DB outage doesn't make every app instance
    # look dead to the load balancer. /db-health (Phase 7) covers the DB.
    return jsonify(status="healthy")


if __name__ == "__main__":
    # Local debugging only (python app.py). The container uses Gunicorn.
    app.run(host="0.0.0.0", port=int(os.getenv("APP_PORT", "8000")))