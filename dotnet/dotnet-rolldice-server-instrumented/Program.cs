using System.Diagnostics;
using System.Diagnostics.Metrics;
using System.Globalization;

using Microsoft.AspNetCore.Mvc;

using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

const string serviceName = "roll-dice-server";

var activitySource = new ActivitySource(serviceName);
var meter = new Meter(serviceName);
var rollCounter = meter.CreateCounter<long>("dice.rolls", description: "Number of dice rolls");

builder.Logging.AddOpenTelemetry(options =>
{
    options
        .SetResourceBuilder(
            ResourceBuilder.CreateDefault()
                .AddService(serviceName))
        .AddConsoleExporter()
        .AddOtlpExporter();
});
builder.Services.AddOpenTelemetry()
      .ConfigureResource(resource => resource.AddService(serviceName))
      .WithTracing(tracing => tracing
          .AddSource(serviceName)
          .AddAspNetCoreInstrumentation()
          .AddConsoleExporter()
          .AddOtlpExporter())
      .WithMetrics(metrics => metrics
          .AddMeter(serviceName)
          .AddAspNetCoreInstrumentation()
          .AddConsoleExporter()
          .AddOtlpExporter());

var app = builder.Build();

string HandleRollDice([FromServices]ILogger<Program> logger, string? player)
{
    using var activity = activitySource.StartActivity("RollDice");
    var result = RollDice();
    activity?.SetTag("dice.value", result);
    activity?.SetTag("dice.player", string.IsNullOrEmpty(player) ? "anonymous" : player);
    rollCounter.Add(1, new KeyValuePair<string, object?>("dice.value", result));

    if (string.IsNullOrEmpty(player))
    {
        logger.LogInformation("Anonymous player is rolling the dice: {result}", result);
    }
    else
    {
        logger.LogInformation("{player} is rolling the dice: {result}", player, result);
    }

    return result.ToString(CultureInfo.InvariantCulture);
}

int RollDice()
{
    return Random.Shared.Next(1, 7);
}

app.MapGet("/rolldice/{player?}", HandleRollDice);

app.Run();
