package otel;

import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.Meter;

@RestController
public class RollController {
  private static final Logger logger = LoggerFactory.getLogger(RollController.class);
  
  private final Meter meter = GlobalOpenTelemetry.getMeter("otel.rolldice");
  private final LongCounter rollCounter = meter
      .counterBuilder("dice.rolls")
      .setDescription("Counts the number of times the dice has been rolled")
      .setUnit("1")
      .build();

  @GetMapping("/rolldice")
  public String index(@RequestParam("player") Optional<String> player) {
    rollCounter.add(1);
    logger.info("Stepping rollCounter");

    int result = this.getRandomNumber(1, 6);
    if (player.isPresent()) {
      logger.info("{} is rolling the dice: {}", player.get(), result);
    } else {
      logger.info("Anonymous player is rolling the dice: {}", result);
    }
    return Integer.toString(result);
  }

  public int getRandomNumber(int min, int max) {
    return ThreadLocalRandom.current().nextInt(min, max + 1);
  }
}
