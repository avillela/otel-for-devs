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
          .AddOtlpExporter())
      .WithLogging(logging => logging.AddOtlpExporter(),
        options =>
        {
            options.IncludeScopes = true;
            options.IncludeFormattedMessage = true;
        });

var app = builder.Build();

string HandleRollDice([FromServices]ILogger<Program> logger, string? player)
{
    using var activity = activitySource.StartActivity("RollDice");
    try
    {
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

        if (result % 2 == 0)
        {
            throw new EvenRollException($"Dice result is even: {result}");
        }

        return result.ToString(CultureInfo.InvariantCulture);
    }
    catch (EvenRollException e)
    {
        using var evenRollActivity = activitySource.StartActivity("even.roll");
        evenRollActivity?.SetTag("error.type", e.GetType().Name);
        evenRollActivity?.SetTag("error.message", e.Message);
        evenRollActivity?.AddException(e);
        evenRollActivity?.AddEvent(new ActivityEvent("even_roll_detected"));
        evenRollActivity?.SetStatus(ActivityStatusCode.Error, e.Message);
        activity?.SetStatus(ActivityStatusCode.Error, e.Message);

        logger.LogError(e, "Even dice result error");

        return $"Error: {e.Message}";
    }
}

int RollDice()
{
    return Random.Shared.Next(1, 7);
}

app.MapGet("/rolldice/{player?}", HandleRollDice);

app.Run();

public class EvenRollException : Exception
{
    public EvenRollException(string message) : base(message)
    {
    }
}
