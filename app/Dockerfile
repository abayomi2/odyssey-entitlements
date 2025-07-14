# --- Stage 1: Build ---
# Use an official Maven image with Java 17 to build the application JAR
FROM maven:3.8.5-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven project file and download dependencies. This leverages Docker's
# layer caching, so dependencies are only re-downloaded if pom.xml changes.
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY src ./src

# Package the application, skipping the tests as they should be run in the CI pipeline
RUN mvn package -DskipTests

# --- Stage 2: Runtime ---
# Use a slim Java 17 runtime image for a smaller final image size
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the executable JAR from the 'build' stage
COPY --from=build /app/target/*.jar ./app.jar

# Expose the port the application runs on
EXPOSE 8080

# The command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]