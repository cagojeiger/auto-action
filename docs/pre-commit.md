# Using pre-commit

This repository relies on [pre-commit](https://pre-commit.com/) to lint and format files such as YAML, Dockerfiles and Helm charts.

## Installation

Install the tool with `pip` and register the Git hook:

```bash
pip install pre-commit
pre-commit install
```

## Manual execution

Run all hooks against the entire repository:

```bash
pre-commit run --all-files
```

The hooks are executed automatically in GitHub Actions when you open a pull request. Any fixes will be committed automatically if necessary.
