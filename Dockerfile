# Use Maven with OpenJDK 11 as the base image for building
FROM maven:3.6-openjdk-11 AS build

# Set working directory
WORKDIR /app

# Copy the pom.xml and download dependencies (for better caching)
COPY pom.xml .

# Download dependencies (this layer will be cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src src

# Build the application without compiling tests
RUN mvn clean package -Dmaven.test.skip=true -Dmaven.test.compile.skip=true -U

# Use Eclipse Temurin 11 (more secure and maintained)
FROM eclipse-temurin:11-jre

# Set working directory
WORKDIR /app

# Create entrypoint script
RUN echo '#!/bin/sh' > /app/entrypoint.sh && \
    echo 'exec java -Dserver.port=$PORT -Djava.security.egd=file:/dev/./urandom --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/java.security=ALL-UNNAMED --add-opens java.base/java.util.concurrent=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED --add-opens java.base/sun.security.util=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED -jar app.jar' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Copy the built JAR from the build stage
COPY --from=build /app/target/provider-search-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8081 (as configured in application.properties)
EXPOSE 8081

# Run the application with Heroku port configuration and module access
CMD ["/app/entrypoint.sh"]
