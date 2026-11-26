# Simple OTel Instrumentation .NET Example for Developers

This is a companion repository the NDC London Talk, "The Lazy Developer’s Guide to Observing Your Own Code"

Additional reference at [opentelemetry.io getting started guide for .NET](https://opentelemetry.io/docs/languages/dotnet/getting-started/)

## Quickstart (.NET)

0- Edit `.env` file

If you'd like to run the auto-instrumented version of this code, set `DOTNET_FOLDER=dotnet-rolldice-server`.

If you want to run the auto-instrumented and manually instrumented version of this code, set `DOTNET_FOLDER=dotnet-rolldice-server-instrumented`.

If you are running this example on an AMD64 machine, set `OTEL_DESKTOP_VIEWER_VERSION=latest-amd64`. Otherwise, leave as-is.

1- Build the .NET project

Do this the first time you run the project, or after any code changes.

Open up a new terminal window and run:

```bash
./scripts/dotnet/00-build-dotnet.sh
```

2- Run the OTel Collector

Open up a new terminal window and run:

```bash
docker compose up otel-collector
```

3- Run the .NET example

Start up the .NET server in a new terminal window:

```bash
./scripts/dotnet/01-run-dotnet-server.sh .env
```

Call the `/rolldice` endpont in a new terminal window. The client is its own project (`dotnet/dotnet-rolldice-client`) and works with either server folder:

```bash
./scripts/dotnet/02-run-dotnet-client.sh
```

> **Why do the server and client set up OpenTelemetry differently?**
> The server is an ASP.NET Core web app, which already has a host and dependency injection, so it uses `builder.Services.AddOpenTelemetry()` from the `OpenTelemetry.Extensions.Hosting` package. The client is a plain console app with no host, so it builds its providers directly with `Sdk.CreateTracerProviderBuilder()`, `Sdk.CreateMeterProviderBuilder()` and `LoggerFactory.Create(...)`, and disposes them on exit to flush telemetry. Both patterns are common: use the hosting package for web apps and workers that run in a host, and the standalone SDK builders for scripts and CLIs.

4- Run the [OTel Desktop Viewer](https://github.com/CtrlSpice/otel-desktop-viewer)

Start up the OTel Desktop Viewer container in a new terminal window:

```bash
docker compose up otel-desktop-viewer
```

The app will be available at `http://localhost:8000`. If you're running this in a dev container, you may need to manually forward port `8000` inside the container, if it's not automatically done for you.

OTel Desktop Viewer has a main dashboard showing application topology and a summary of traces, logs, and metrics.

![OTel Desktop Viewer main dashboard Screenshot](./images/otel-desktop-viewer.png)

It also has separate pages for traces:

![OTel Desktop Viewer Screenshot](./images/otel-desktop-viewer-traces.png)


logs:

![OTel Desktop Viewer Screenshot](./images/otel-desktop-viewer-logs.png)

metrics:

![OTel Desktop Viewer Metrics Screenshot](./images/otel-desktop-viewer-metrics.png)


5- Run [otel-tui](https://github.com/ymtdzzz/otel-tui)

Start up the `otel-tui` container in a new terminal window, in daemon mode:

```bash
docker compose up otel-tui -d
```

Start up the UI:

```bash
docker compose attach otel-tui
```

`otel-tui` supports traces:

![otel-tui Traces Screenshot](./images/otel-tui-traces.png)

logs:

![otel-tui Logs Screenshot](./images/otel-tui-logs.png)

metrics:

![otel-tui Metrics Screenshot](./images/otel-tui-metrics.png)

and application topology:

![otel-tui Topology Screenshot](./images/otel-tui-topology.png)


6- Run [OTel Front](https://github.com/mesaglio/otel-front)

Start up the `otel-front` container in a new terminal window, in daemon mode:

```bash
docker compose up otel-front
```

The app will be available at `http://localhost:8001`. If you're running this in a dev container, you may need to manually forward port `8001` inside the container, if it's not automatically done for you.

OTel Front supports traces:

![OTel Front Traces Screenshot](./images/otel-front-traces.png)

logs:

![OTel Front Logs Screenshot](./images/otel-front-logs.png)

and metrics:

![OTel Front Metrics Screenshot](./images/otel-front-metrics.png)

It also has a nice little overview dashboard:

![OTel Front Dashboard Screenshot](./images/otel-front-dashboard.png)

