using System.Diagnostics;
using System.Globalization;

using Microsoft.Extensions.Logging;

using OpenTelemetry;
using OpenTelemetry.Logs;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace dotnet_rolldice_client;

/// <summary>
/// Client application that calls the rolldice endpoint repeatedly.
/// Similar to the bash script in scripts/03-rolldice.sh
/// </summary>
public class RollDiceClient
{
    private const string ServiceName = "roll-dice-client";
    private const string Url = "http://localhost:8080/rolldice";
    private static readonly TimeSpan SleepInterval = TimeSpan.FromSeconds(5);

    private static readonly string?[] Players =
    [
        null,
        "Jean-Luc Picard",
        "Kathryn Janeway",
        "Michael Burnham",
        "Benjamin Sisko",
        "Beverly Crusher",
        "Mr. Data",
        "Jadzia Dax"
    ];

    private static readonly ActivitySource ActivitySource = new("otel.rolldice.client");

    private readonly ILogger<RollDiceClient> _logger;

    public RollDiceClient(ILogger<RollDiceClient> logger)
    {
        _logger = logger;
    }

    public static async Task<int> Main(string[] args)
    {
        using var tracerProvider = Sdk.CreateTracerProviderBuilder()
            .ConfigureResource(resource => resource.AddService(ServiceName))
            .AddSource(ActivitySource.Name)
            .AddHttpClientInstrumentation()
            .AddConsoleExporter()
            .AddOtlpExporter()
            .Build();

        using var loggerFactory = LoggerFactory.Create(builder =>
        {
            builder.AddOpenTelemetry(options =>
            {
                options
                    .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(ServiceName))
                    .AddConsoleExporter()
                    .AddOtlpExporter();
            });
        });

        var logger = loggerFactory.CreateLogger<RollDiceClient>();
        logger.LogInformation("Starting Rolldice Client");
        logger.LogInformation("Target URL: {url}", Url);

        using var cts = new CancellationTokenSource();
        Console.CancelKeyPress += (_, e) =>
        {
            e.Cancel = true;
            cts.Cancel();
        };

        try
        {
            await new RollDiceClient(logger).RunAsync(cts.Token);
            return 0;
        }
        catch (Exception e)
        {
            logger.LogError(e, "Client error");
            return 1;
        }
    }

    /// <summary>
    /// Randomly select a player from the Players array.
    /// </summary>
    /// <returns>The selected player name or null for anonymous.</returns>
    private static string? GetRandomPlayer() => Players[Random.Shared.Next(Players.Length)];

    /// <summary>
    /// Build the request URL based on the player name.
    /// </summary>
    /// <param name="playerName">The player name or null for anonymous.</param>
    /// <returns>The full request URL.</returns>
    private static string BuildRequestUrl(string? playerName) =>
        playerName is null ? Url : $"{Url}/{Uri.EscapeDataString(playerName)}";

    /// <summary>
    /// Run the client in a loop, calling the endpoint every 5 seconds.
    /// </summary>
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        using var httpClient = new HttpClient();

        while (!cancellationToken.IsCancellationRequested)
        {
            var playerName = GetRandomPlayer();
            var requestUrl = BuildRequestUrl(playerName);

            using var clientSpan = ActivitySource.StartActivity("rolldice.client.request");
            // HTTP attributes (url.full, http.request.method, http.response.status_code)
            // are recorded by the HttpClient instrumentation on its own child span.
            playerName ??= "anonymous";
            clientSpan?.SetTag("player.name", playerName);

            try
            {
                var timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
                _logger.LogInformation("{timestamp}: Calling rolldice with player [{player}]", timestamp, playerName);
                clientSpan?.AddEvent(new ActivityEvent("request_prepared",
                    tags: new ActivityTagsCollection { { "timestamp", timestamp } }));

                // Make the request
                using var response = await httpClient.GetAsync(requestUrl, cancellationToken);
                var body = await response.Content.ReadAsStringAsync(cancellationToken);

                // Log the response
                _logger.LogInformation("Response: {response}", body);
                Console.WriteLine(body);

                // Record response details in span
                clientSpan?.AddEvent(new ActivityEvent("response_received",
                    tags: new ActivityTagsCollection
                    {
                        { "response_body", body }
                    }));

                // Sleep before next call
                await Task.Delay(SleepInterval, cancellationToken);
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Client interrupted");
                clientSpan?.AddEvent(new ActivityEvent("client_interrupted"));
                break;
            }
            catch (Exception e)
            {
                _logger.LogError("Error calling endpoint: {message}", e.Message);
                clientSpan?.AddException(e);
                clientSpan?.SetStatus(ActivityStatusCode.Error, e.Message);
                clientSpan?.AddEvent(new ActivityEvent("error_occurred",
                    tags: new ActivityTagsCollection
                    {
                        { "error_type", e.GetType().Name },
                        { "error_message", e.Message }
                    }));
                try
                {
                    await Task.Delay(SleepInterval, cancellationToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }
        }
    }
}
