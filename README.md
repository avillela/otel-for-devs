# Simple OTel Instrumentation Java Example for Developers

This is a companion repository for Devoxx Greece 2026 talk, "The Lazy Developer’s Guide to Observing Your Own Code"

Java source code courtesy of [mviitane/otel-java-simple](https://github.com/mviitane/otel-java-simple)

Additional reference at [opentelemetry.io getting started guide for Java](https://opentelemetry.io/docs/languages/java/getting-started/)

## Quickstart

1- Build the Java project

Open up a new terminal window and run:

```bash
./scripts/00-build-java.sh
```

2- Run the OTel Collector

Open up a new terminal window and run:

```bash
docker compose up otel-collector
```

3- Run the Java example

Start up the Java server in a new terminal window:

```bash
./scripts/02-run-java-server.sh
```

Call the `/rolldice` endpont in a new terminal window:

```bash
./scripts/03-rolldice.sh
```

4- Run the OTel desktop viewer

Start up the OTel Desktop viewer process in a new terminal window:

```bash
docker compose up otel-desktop-viewer
```

The app will be available at `http://localhost:8000`. If you're running this in a dev container, you may need to manually forward port `8000` inside the container, if it's not automatically done for you.