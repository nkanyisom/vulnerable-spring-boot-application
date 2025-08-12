# Use OpenJDK 8 as the base image
FROM openjdk:8-jdk-alpine

# Set working directory
WORKDIR /app

# Copy the pom.xml and download dependencies (for better caching)
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

# Make mvnw executable
RUN chmod +x mvnw

# Download dependencies (this layer will be cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# Expose port 8081 (as configured in application.properties)
EXPOSE 8081

# Run the application
CMD ["java", "-jar", "target/provider-search-0.0.1-SNAPSHOT.jar"]
