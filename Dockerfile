# syntax=docker/dockerfile:1
# Keep this syntax directive! It's used to enable Docker BuildKit

################################
# PYTHON-BASE
# Sets up all our shared environment variables
################################
FROM python:3.11-slim as python-base

# Set environment variables related to Python, pip, and Poetry
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.7.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Prepend poetry and venv to the PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

################################
# BUILDER-BASE
# Used to build deps + create our virtual environment
################################
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN --mount=type=cache,target=/root/.cache \
    curl -sSL https://install.python-poetry.org | python3 -

# Copy project requirement files here to ensure they will be cached
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN --mount=type=cache,target=/root/.cache \
    poetry install --only main

################################
# PRODUCTION
# Final image used for runtime
################################
FROM python-base as production
ENV STREAMLIT_ENV=production

# Copy the Poetry and virtual environment from the builder-base stage
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

WORKDIR /app
COPY scm_frontend/ /app/
COPY scm_frontend/.env /app/

# Set the script as executable
RUN chmod +x /app/start_streamlit.sh

# Activate the virtual environment and install Streamlit
RUN /opt/pysetup/.venv/bin/pip install streamlit

# Use CMD instead of ENTRYPOINT if you don't need to override the command
CMD ["sh", "/app/start_streamlit.sh"]
