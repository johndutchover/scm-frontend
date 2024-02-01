# syntax=docker/dockerfile:1
FROM python:3.11.7-slim-bookworm
WORKDIR /app
ENV PYTHONPATH /app

# Create necessary directories
RUN mkdir /app/.streamlit /app/pages

# Install poetry and project dependencies, upgrade pip first
RUN pip install --upgrade pip \
    && pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create true

# Copy required configuration files
COPY start_streamlit.sh .env .streamlit/secrets.toml pyproject.toml poetry.lock login.py /app/

# Copy the entire frontend project
COPY pages/ /app/pages/

EXPOSE 8501

# Use CMD instead of ENTRYPOINT if you don't need to override the command
CMD ["sh", "/app/start_streamlit.sh"]
