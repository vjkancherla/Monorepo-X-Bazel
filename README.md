# Monorepo-X (Bazel)

A **Bazel** monorepo demonstrating a CI/CD service platform with a Jenkins shared
library, SonarQube, and k3d-based core services.

## What's inside

- `BUILD.bazel` — the top-level Bazel build definition.
- `Core-Services/` — shared services:
  - `Jenkins/` — Jenkins with a shared library (`JenkinsSharedLibrary`) exposing
    build, test, lint, image publish, and Helm dry/wet-run steps, plus pipeline
    variables (`continuousIntegration*.groovy`, `continuousDelivery.groovy`).
  - `Sonarqube/` — SonarQube on Docker.
  - `start-core-services.sh`, `stop-core-services.sh` — lifecycle scripts.
- `JenkinsFile.CI` — the CI pipeline.
- `.bazelversion`, `Bazel-Commands.txt`, `Bazel-Notes.txt` — Bazel version and references.

## Tools covered

- Bazel (monorepo build system)
- Jenkins shared libraries and pipelines
- SonarQube, k3d

## How to use

Use `BUILD.bazel` and the `Core-Services/` Jenkins shared library as reference
implementations for a Bazel-based monorepo CI/CD setup.
