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
- `postgres` — one Postgres instance holding **two separate databases**:
  - `airflow` — Airflow's own metadata (DAG runs, task state, connections,
    etc.). Nothing outside Airflow itself should read or write here.
  - `gridiron` — the application database (created by
    `docker/postgres/init-gridiron-db.sql`, owned by its own `gridiron`
    role). This is a local stand-in for what will eventually be Aurora
    PostgreSQL, and is where ingestion code and the Go API read and write
    — see **Application database** below. No schema exists yet; that
    lands in `feat/aurora-schema`.
- `airflow-init` — runs `airflow db migrate` and creates an `admin`/`admin`
  user, then exits.
- `airflow-webserver` — Airflow UI at http://localhost:8080 (log in with
  `admin` / `admin`). `dags/` is mounted as a volume, so it should come up
  with an empty DAGs list.
- `airflow-scheduler` — LocalExecutor scheduler.

Postgres is also published on `localhost:5432` for connecting with `psql`
or a GUI client directly from the host.

Tear down with:

```bash
docker compose down -v
```

### Application database

Ingestion code and the Go API are meant to connect to the application
database (`gridiron` locally, Aurora in production) through a single
environment variable, `GRIDIRON_DATABASE_URL`, defined in
`docker-compose.yml` and passed to the Airflow containers (ingestion runs
as Airflow tasks). Locally it's:

```
postgresql://gridiron:gridiron@postgres:5432/gridiron
```

This is deliberately the *only* thing that has to change to move from
local dev to production: swap this one variable to point at Aurora's
endpoint instead of the local Postgres container, and no application code
changes. That's also why it's a separate database and role from
`airflow` — Airflow's metadata DB has no production equivalent and should
never be conflated with the application's own data.

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
