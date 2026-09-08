-- Runs once on first container start (via postgres's
-- docker-entrypoint-initdb.d mechanism). Creates a second database
-- alongside Airflow's metadata DB, as a local stand-in for what will
-- eventually be Aurora PostgreSQL. No schema lives here yet.
CREATE DATABASE gridiron;
