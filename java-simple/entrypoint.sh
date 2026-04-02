#!/bin/bash

# Start the Java application in the background
java -javaagent:/app/opentelemetry-javaagent.jar -jar /app/app.jar &
APP_PID=$!

# Wait for the app to be ready
echo "Waiting for application to start..."
until curl -s http://localhost:8008/actuator/health > /dev/null 2>&1 || curl -s http://localhost:8008/rolldice > /dev/null 2>&1; do
  sleep 2
done
echo "Application is ready!"

# Run curl every 60 seconds in the background
while true; do
  curl -s http://localhost:8008/rolldice
  echo ""
  sleep 60
done &

# Wait for the Java process to exit
wait $APP_PID
