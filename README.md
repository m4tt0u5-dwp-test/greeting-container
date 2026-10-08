# DevOps Interview Task (Part 1): Containerize

**This is a take-home task.** Please submit by the date given when the task was
issued.

## Overview

You are given a small web application (`app/`). A working `Dockerfile` is
provided, but it was written quickly and does **not** follow container best
practices. Your job is to refactor it into a production-quality image and push
it to a container registry.

You do **not** need to modify the application code.

## What we provide

Clone this repository into your local account.

> **Do Not** fork this repository. Clone it and re-push it into your local account.

The following is provided as part of this repository:

```text
Dockerfile            # a working but non-production Dockerfile — improve it
app/
  app.py              # a minimal Python Flask web app (do not modify)
  requirements.txt    # the app's dependencies (do not modify)
```

The application:

-   Listens on the port given by the `PORT` environment variable (default `8080`).
-   Reads a `GREETING` environment variable used in its response.
-   Exposes `GET /`, `GET /healthz`, and `GET /info`.

## Production Refactoring and Improvements

## 1. Security & Hardening

- Created a dedicated system user/group (`appuser`) to run the application.

- Removed extraneous debugging and build tools (`curl`, `vim`, compilers) from the final image.

- Selected `python:3.12-alpine` pinned with SHA256 digest for immutability.

### Notes on the base image 

- For a production image I would want to use a minimal base image such as from Chainguard: https://www.chainguard.dev/chainguard-images but to use their tagged versions requires a subscription. They do provide the `latest` tag for free use but this is not recommended for production as it is not immutable.

- Another consideration is a distroless container image, however this would require making changes to the application code and this task specifically requests no changes to the application code. 

### 2. Build Efficiency & Image Size

- **Multi-Stage Build:** Isolated dependency installation in a build stage, copying only the virtual environment into the runtime image.

- **Layer Caching:** Copied `requirements.txt` prior to application code to optimize Docker layer caching during code iterations.

- **Build Context:** Added `.dockerignore` to exclude repository metadata (`.git`, markdown files, etc.).

### 3. Observability & Runtime

- **Logging:** Added `--access-logfile -` and `PYTHONUNBUFFERED=true` to stream application access logs directly to `stdout`.

- **Health Probing:** Added a `HEALTHCHECK` to `/healthz` for standalone container verification.