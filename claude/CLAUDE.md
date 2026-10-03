# Environment

- Debian 13 (trixie), LXQt on X11, bash.
- Runtimes are managed by mise (per-project `mise.toml`). Never install
  language runtimes with apt.
- Python: always use uv (`uv add`, `uv run`). Never `pip install` globally.
- Rust via rustup, Go via mise.
- Debian names: use `fdfind` and `batcat`. Shell aliases are not available
  in non-interactive shells.
- Docker is available without sudo. GPU in containers: `--gpus all`.

# Preferences

- Keep dependencies and configuration minimal. Explain the trade-off before
  adding a new tool or library.
