# Use Maven with OpenJDK 8 as the base image for building
FROM maven:3.6.3-openjdk-8-alpine AS build

# Set working directory
WORKDIR /app

# Copy the pom.xml and download dependencies (for better caching)
COPY pom.xml .

# Download dependencies (this layer will be cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN mvn clean package -DskipTests

# Use OpenJDK 8 runtime for the final image
FROM openjdk:8-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/provider-search-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8081 (as configured in application.properties)
EXPOSE 8081

# Run the application
CMD ["java", "-jar", "app.jar"]
