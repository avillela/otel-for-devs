plugins {
  java
  id("org.springframework.boot") version "3.2.0"
  id("io.spring.dependency-management") version "1.1.4"
}

group = "otel"
// version = "1.0.0"
java.sourceCompatibility = JavaVersion.VERSION_17

repositories {
  mavenCentral()
}

val opentelemetryVersion = "1.32.0"

dependencies {
  // Spring Boot
  implementation("org.springframework.boot:spring-boot-starter-web")
  
  // OpenTelemetry
  implementation("io.opentelemetry:opentelemetry-api:$opentelemetryVersion")
  implementation("io.opentelemetry:opentelemetry-sdk:$opentelemetryVersion")
  implementation("io.opentelemetry:opentelemetry-exporter-otlp:$opentelemetryVersion")
  
  // Logging
  implementation("org.springframework.boot:spring-boot-starter-logging")
  
  // Testing
  testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.test {
  useJUnitPlatform()
}

springBoot {
  mainClass.set("otel.DiceApplication")
}
