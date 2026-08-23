# Monorepo-X with Bazel

A monorepo build example using **Bazel**, demonstrating how to structure multiple
packages (core services and microservices) under a single build graph.

## What's inside

- `WORKSPACE.bazel` — the Bazel workspace definition.
- `BUILD.bazel` — root build file (kept empty, per Bazel conventions).
- `deps.bzl` — external dependency declarations.
- `Core-Services/` and `Microservices/` — the individual packages.
- `Jenkinsfile`, `JenkinsFile.CI` — CI pipeline that drives the Bazel build.
- `Bazel-Notes.txt`, `Bazel-Commands.txt` — notes and command reference.
- `bazel/`, `bazel-bin/`, `bazel-out/`, `bazel-testlogs/` — Bazel output caches.

## What you'll learn

- Organizing a monorepo into Bazel packages.
- Declaring dependencies and build targets.
- Building a monorepo from CI with Bazel.

## Tools covered

- Bazel (WORKSPACE, BUILD files, packages)
- Jenkins (CI)

## How to use

Read `Bazel-Notes.txt` for the rules (e.g. keep the root `BUILD.bazel` empty),
then run builds with:

```bash
bazel build //...
```

## Related

- Bazel docs: https://bazel.build/docs
