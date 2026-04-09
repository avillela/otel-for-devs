package otel;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Client application that calls the rolldice endpoint repeatedly.
 * Similar to the bash script in scripts/03-rolldice.sh
 */
public class RolldiceClient {
  private static final Logger logger = LoggerFactory.getLogger(RolldiceClient.class);
  private static final String URL = "http://localhost:8080/rolldice";
  private static final int SLEEP_INTERVAL_MS = 5000; // 5 seconds

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
   * Run the client in an infinite loop, calling the endpoint every 5 seconds.
   */
  public void run() {
    HttpClient httpClient = HttpClient.newHttpClient();

    while (true) {
      try {
        String timestamp = LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        logger.info("{}: Calling rolldice", timestamp);

        // Make the request
        HttpRequest request = HttpRequest.newBuilder()
            .uri(java.net.URI.create(URL))
            .GET()
            .build();

        HttpResponse<String> response = httpClient.send(request,
            HttpResponse.BodyHandlers.ofString());

        // Log the response
        logger.info("Response: {}", response.body());
        System.out.println(response.body());

        // Sleep before next call
        Thread.sleep(SLEEP_INTERVAL_MS);
      } catch (InterruptedException e) {
        logger.info("Client interrupted");
        Thread.currentThread().interrupt();
        break;
      } catch (Exception e) {
        logger.error("Error calling endpoint: {}", e.getMessage());
        try {
          Thread.sleep(SLEEP_INTERVAL_MS);
        } catch (InterruptedException ie) {
          Thread.currentThread().interrupt();
          break;
        }
      }
    }
  }
}
