"""Trivial smoke test proving the package installs and imports correctly."""

import gridiron_ingestion


def test_package_has_version() -> None:
    assert gridiron_ingestion.__version__ == "0.1.0"
