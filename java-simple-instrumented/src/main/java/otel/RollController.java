package otel;

import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.api.metrics.LongCounter;
import io.opentelemetry.api.metrics.LongHistogram;
import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.StatusCode;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;

@RestController
public class RollController {
  private static final Logger logger = LoggerFactory.getLogger(RollController.class);
  
  private final Meter meter = GlobalOpenTelemetry.getMeter("otel.rolldice");
  private final Tracer tracer = GlobalOpenTelemetry.getTracer("otel.rolldice");
  
  private final LongCounter rollCounter = meter
      .counterBuilder("dice.rolls")
      .setDescription("Counts the number of times the dice has been rolled")
      .setUnit("1")
      .build();
  
  private final LongHistogram diceResultHistogram = meter
      .histogramBuilder("dice.result.distribution")
      .setDescription("Distribution of dice roll results")
      .setUnit("1")
      .ofLongs()
      .build();

  @GetMapping("/rolldice")
  public String index(@RequestParam("player") Optional<String> player) {
    Span span = tracer.spanBuilder("dice.roll")
        .setAttribute("player.name", player.orElse("anonymous"))
        .setAttribute("player.provided", player.isPresent())
        .startSpan();
    
    try (Scope scope = span.makeCurrent()) {
      rollCounter.add(1);
      span.addEvent("roll_counter_incremented");
      logger.info("Stepping rollCounter");

      int result = this.getRandomNumber(1, 6);

      // Check if result is even and raise exception before recording metrics
      if (result % 2 == 0) {
        throw new EvenRollException("Dice result is even: " + result);
      }

      // Record the result in span and metrics (only for valid odd rolls)
      span.setAttribute("dice.result", result);
      diceResultHistogram.record(result);
      span.addEvent("dice_rolled", 
          Attributes.builder()
              .put("result", result)
              .build());
      
      // Log player info with consolidated event
      var playerAttributes = Attributes.builder().put("result", result);
      if (player.isPresent()) {
        logger.info("[{}] is rolling the dice: {}", player.get(), result);
        playerAttributes.put("player", player.get());
      } else {
        logger.info("[Anonymous player] is rolling the dice: {}", result);
        playerAttributes.put("player", "anonymous");
      }
      span.addEvent("roll_completed", playerAttributes.build());
      
      return Integer.toString(result);
    } catch (EvenRollException e) {
      Span evenRollSpan = tracer.spanBuilder("even.roll")
          .setAttribute("error.type", e.getClass().getSimpleName())
          .setAttribute("error.message", e.getMessage())
          .startSpan();
      
      try (Scope scope = evenRollSpan.makeCurrent()) {
        logger.error("Even dice result error", e);
        evenRollSpan.recordException(e);
        evenRollSpan.setStatus(StatusCode.ERROR, e.getMessage());
        evenRollSpan.addEvent("even_roll_detected");
        span.setStatus(StatusCode.ERROR, e.getMessage());
      } finally {
        evenRollSpan.end();
      }
      return "Error: " + e.getMessage();
    } finally {
      span.end();
    }
  }

  public int getRandomNumber(int min, int max) {
    return ThreadLocalRandom.current().nextInt(min, max + 1);
  }
}
