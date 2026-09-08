-- Runs once on first container start (via postgres's
-- docker-entrypoint-initdb.d mechanism). Creates a second database
-- alongside Airflow's metadata DB, as a local stand-in for what will
-- eventually be Aurora PostgreSQL. Kept on its own role, entirely
-- separate from Airflow's internal bookkeeping. No schema lives here
-- yet - see GRIDIRON_DATABASE_URL in docker-compose.yml and the README
-- for how ingestion code and the Go API are meant to connect to it.
CREATE DATABASE gridiron;
CREATE USER gridiron WITH PASSWORD 'gridiron';
GRANT ALL PRIVILEGES ON DATABASE gridiron TO gridiron;
