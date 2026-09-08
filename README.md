# gridiron-analytics

**Status: work in progress — structure and tooling scaffold only.** No DAGs,
API endpoints, or frontend logic exist yet; this branch proves the tooling
(CI, local dev environment, package layout) works end to end so later
branches can build on it.

## Architecture

```
ESPN + Highlightly APIs -> Airflow (extraction/transform/load) -> Aurora PostgreSQL -> Go API -> React frontend
```

- **`dags/`** — Airflow DAG definitions.
- **`ingestion/`** — Python package (`gridiron_ingestion`) with the
  extraction/transform/load logic the DAGs call into. uv-managed, ruff +
  mypy (strict) + pytest.
- **`api/`** — Go HTTP API service sitting in front of Aurora.
- **`frontend/`** — React frontend (not scaffolded yet — far-off phase).
- **`infra/terraform/`** — AWS infrastructure as code.
  - `bootstrap/` creates the S3 bucket used for remote state and itself
    keeps state local (chicken-and-egg: something has to create the
    bucket before anything else can point its backend at it).
  - `environments/dev/` is the actual environment config, backed by
    remote state in that bucket.
- **`docker/`** — Dockerfiles and init scripts for local dev.

## Local dev setup

Requires Docker and Docker Compose.

```bash
docker compose up --build
```

This starts:
- `postgres` — one Postgres instance: the `airflow` database is Airflow's
  metadata DB, and a second `gridiron` database (created by
  `docker/postgres/init-gridiron-db.sql`) is a local stand-in for what
  will eventually be Aurora.
- `airflow-init` — runs `airflow db migrate` and creates an `admin`/`admin`
  user, then exits.
- `airflow-webserver` — Airflow UI at http://localhost:8080 (log in with
  `admin` / `admin`). `dags/` is mounted as a volume, so it should come up
  with an empty DAGs list.
- `airflow-scheduler` — LocalExecutor scheduler.

Tear down with:

```bash
docker compose down -v
```

## Python package (`ingestion/`)

```bash
cd ingestion
uv sync --locked --all-extras --dev
uv run ruff check .
uv run ruff format --check .
uv run mypy .
uv run pytest
```

## Go service (`api/`)

```bash
cd api
go vet ./...
go build ./...
go test ./...
```

## Terraform (`infra/terraform/`)

Nothing has been applied yet — both configs are scaffolds validated in CI
via `fmt -check` / `validate` only (no `plan`/`apply`, since that needs AWS
credentials that aren't configured). To actually stand up the state
bucket, from `infra/terraform/bootstrap/`:

```bash
terraform init
terraform apply -var="account_suffix=<your-suffix>"
```

Then fill in the real bucket name in
`infra/terraform/environments/dev/main.tf`'s backend block before running
Terraform there.

## CI

Three independent GitHub Actions workflows, each path-filtered to only run
when its own directory changes: `.github/workflows/python.yml`,
`.github/workflows/go.yml`, `.github/workflows/terraform.yml`.

## License

MIT — see [LICENSE](LICENSE).
