package otel;

public class EvenRollException extends Exception {
  public EvenRollException(String message) {
    super(message);
  }

  public EvenRollException(String message, Throwable cause) {
    super(message, cause);
  }
}
