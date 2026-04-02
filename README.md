# Simple OTel Instrumentation Java Example for Developers

This is a companion repository for Devoxx Greece 2026 talk, "The Lazy Developer’s Guide to Observing Your Own Code"

Java source code courtesy of [mviitane/otel-java-simple](https://github.com/mviitane/otel-java-simple)

Additional reference at [opentelemetry.io getting started guide for Java](https://opentelemetry.io/docs/languages/java/getting-started/)

## Quickstart

1- Build the project

Open up a new terminal window and run:

```bash
./scripts/00-build-java.sh
```

2- Run the OTel Collector

Open up a new terminal window and run:

```bash
./scripts/01-run-otel-collector.sh
```

3- Run the Java example

Open up a new terminal window and run:

```bash
./scripts/02-run-java-server.sh
```

In a new terminal window, run:

```bash
./scripts/03-rolldice.sh
```