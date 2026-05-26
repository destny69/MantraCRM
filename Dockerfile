FROM python:3.12-slim-bookworm

# Prevent Python from buffering stdout/stderr (useful for Docker logs)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies for WeasyPrint (cairo, pango) and PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install uv (fast Python package manager).
COPY --from=ghcr.io/astral-sh/uv:0.11 /uv /usr/local/bin/uv

# Install Python dependencies into /app/.venv (layer cached on lockfile changes)
COPY backend/pyproject.toml backend/uv.lock backend/.python-version ./
# Create the venv during build and move it to /opt so runtime mounts don't hide it
RUN uv sync --frozen --no-install-project && mv /app/.venv /opt/.venv || true

# Provide stable entrypoint wrappers that won't break when /app is mounted
# (some entry scripts use absolute shebangs pointing to /app/.venv)
RUN printf '%s\n' '#!/bin/sh' 'exec /opt/.venv/bin/python -m celery "${@}"' > /usr/local/bin/celery \
    && chmod +x /usr/local/bin/celery || true
RUN if [ -d /opt/.venv/bin ]; then \
            find /opt/.venv/bin -type f -exec sed -i "1s|^#!.*python.*$|#!/opt/.venv/bin/python|" {} \; || true; \
        fi

# Copy backend source
COPY backend/ .

# Put the venv's binaries on PATH so `python`, `gunicorn`, `celery` etc. resolve.
ENV PATH="/opt/.venv/bin:$PATH"

EXPOSE 8000
