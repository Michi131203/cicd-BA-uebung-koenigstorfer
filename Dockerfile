# ---------- Stage 1: Build ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src

COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src

RUN mvn -B package -DskipTests \
    && ls -la target

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Run as non-root user
RUN groupadd --system app && useradd --system --gid app app

COPY --from=build /src/target/*.jar /app/app.jar
USER app

ENTRYPOINT ["java", "-cp", "/app/app.jar", "com.example.cicd.App"]
