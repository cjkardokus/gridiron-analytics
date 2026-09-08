# gridiron-ingestion

Extraction, transform, and load logic for the gridiron-analytics ETL/ELT
pipeline (ESPN + Highlightly -> Aurora). Currently a scaffold with no
business logic — see the repo root README for project status.

## Development

```bash
uv sync --locked --all-extras --dev
uv run ruff check .
uv run ruff format --check .
uv run mypy .
uv run pytest
```
