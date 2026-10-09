FROM python:3.12.15-alpine@sha256:1b668429b3511ab407d8e00648891631b0b1a4d7e15e3ca70f38ab5b91ad4ab4 AS build

WORKDIR /app

COPY app/requirements.txt .

RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.12.15-alpine@sha256:1b668429b3511ab407d8e00648891631b0b1a4d7e15e3ca70f38ab5b91ad4ab4

WORKDIR /app

RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

COPY --chown=10001:10001 --from=build /opt/venv /opt/venv
COPY --chown=10001:10001 app/ .  

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED="1" \
    PYTHONDONTWRITEBYTECODE="1"

USER 10001:10001

LABEL org.opencontainers.image.title="greeting-container" \
    org.opencontainers.image.description="Production-grade container for the DWP DevOps assessment" \
    org.opencontainers.image.source="https://github.com/m4tt0u5-dwp-test/greeting-container" \
    org.opencontainers.image.licenses="MIT"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD [ "wget", "--no-verbose", "--tries=1", "--spider", "http://127.0.0.1:8080/healthz" ]

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--access-logfile", "-", "app:app"]
