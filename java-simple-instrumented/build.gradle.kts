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

// Task to build a fat JAR for the Rolldice Client
tasks.register<Jar>("clientJar") {
  archiveBaseName.set("java-simple-instrumented-client")
  archiveVersion.set("")
  archiveClassifier.set("")
  duplicatesStrategy = DuplicatesStrategy.EXCLUDE
  
  manifest {
    attributes["Main-Class"] = "otel.RolldiceClient"
    attributes["Implementation-Title"] = "Rolldice Client"
    attributes["Implementation-Version"] = project.version
  }
  
  from(sourceSets.main.get().output)
  
  dependsOn(configurations.runtimeClasspath)
  from({
    configurations.runtimeClasspath.get().filter { it.isFile }.map { zipTree(it) }
  })
}

tasks.assemble {
  dependsOn("clientJar")
}

tasks.build {
  dependsOn("clientJar")
}
