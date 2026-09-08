# Local dev Airflow image: the official Airflow image plus the
# gridiron_ingestion package, so DAGs can import it directly.
FROM apache/airflow:2.10.5-python3.12

COPY ingestion/pyproject.toml ingestion/README.md /tmp/ingestion/
COPY ingestion/src /tmp/ingestion/src

RUN pip install --no-cache-dir /tmp/ingestion
