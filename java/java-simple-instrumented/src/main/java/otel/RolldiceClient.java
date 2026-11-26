package otel;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ThreadLocalRandom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;

/**
 * Client application that calls the rolldice endpoint repeatedly.
 * Similar to the bash script in scripts/03-rolldice.sh
 */
public class RolldiceClient {
  private static final Logger logger = LoggerFactory.getLogger(RolldiceClient.class);
  private static final String URL = "http://localhost:8080/rolldice";
  private static final int SLEEP_INTERVAL_MS = 5000; // 5 seconds
  
  private static final String[] PLAYERS = {
      null,
      "Jean-Luc Picard",
      "Kathryn Janeway",
      "Michael Burnham",
      "Benjamin Sisko",
      "Beverly Crusher",
      "Mr. Data",
      "Jadzia Dax"
  };
  
  private final Tracer tracer = GlobalOpenTelemetry.getTracer("otel.rolldice.client");

  public static void main(String[] args) {
    logger.info("Starting Rolldice Client");
    logger.info("Target URL: {}", URL);

    try {
      RolldiceClient client = new RolldiceClient();
      client.run();
    } catch (Exception e) {
      logger.error("Client error", e);
      System.exit(1);
    }
  }

  /**
   * Randomly select a player from the PLAYERS array.
   * @return the selected player name or null for anonymous
   */
  private String getRandomPlayer() {
    return PLAYERS[ThreadLocalRandom.current().nextInt(PLAYERS.length)];
  }

  /**
   * Build the request URL and span attributes based on the player name.
   * @param playerName the player name or null for anonymous
   * @return the full request URL
   */
  private String buildRequestUrl(String playerName) {
    if (playerName != null) {
      return URL + "?player=" + playerName.replace(" ", "%20");
    }
    return URL;
  }

  /**
   * Run the client in an infinite loop, calling the endpoint every 5 seconds.
   */
  public void run() {
    HttpClient httpClient = HttpClient.newHttpClient();

    while (true) {
      String playerName = getRandomPlayer();
      String requestUrl = buildRequestUrl(playerName);
      
      Span clientSpan = tracer.spanBuilder("rolldice.client.request")
          .setAttribute("http.url", requestUrl)
          .setAttribute("http.method", "GET")
          .startSpan();
      
      if (playerName == null) {
        playerName = "anonymous";
      }
      clientSpan.setAttribute("player.name", playerName);

      try (Scope scope = clientSpan.makeCurrent()) {
        String timestamp = LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        logger.info("{}: Calling rolldice with player [{}]", timestamp, playerName);
        clientSpan.addEvent("request_prepared",
            Attributes.builder()
                .put("timestamp", timestamp)
                .build());

        // Make the request
        HttpRequest request = HttpRequest.newBuilder()
            .uri(java.net.URI.create(requestUrl))
            .GET()
            .build();

        HttpResponse<String> response = httpClient.send(request,
            HttpResponse.BodyHandlers.ofString());

        // Log the response
        logger.info("Response: {}", response.body());
        System.out.println(response.body());
        
        // Record response details in span
        clientSpan.setAttribute("http.status_code", response.statusCode());
        clientSpan.addEvent("response_received",
            Attributes.builder()
                .put("status_code", response.statusCode())
                .put("response_body", response.body())
                .build());

        // Sleep before next call
        Thread.sleep(SLEEP_INTERVAL_MS);
      } catch (InterruptedException e) {
        logger.info("Client interrupted");
        clientSpan.addEvent("client_interrupted");
        Thread.currentThread().interrupt();
        break;
      } catch (Exception e) {
        logger.error("Error calling endpoint: {}", e.getMessage());
        clientSpan.recordException(e);
        clientSpan.addEvent("error_occurred",
            Attributes.builder()
                .put("error_type", e.getClass().getSimpleName())
                .put("error_message", e.getMessage())
                .build());
        try {
          Thread.sleep(SLEEP_INTERVAL_MS);
        } catch (InterruptedException ie) {
          Thread.currentThread().interrupt();
          break;
        }
      } finally {
        clientSpan.end();
      }
    }
  }
}
