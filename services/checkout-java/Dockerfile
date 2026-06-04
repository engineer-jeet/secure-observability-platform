FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

RUN mkdir -p /otel

COPY opentelemetry-javaagent.jar /otel/opentelemetry-javaagent.jar

EXPOSE 8080

CMD ["java", \
"-javaagent:/otel/opentelemetry-javaagent.jar", \
"-Dotel.service.name=checkout-service", \
"-Dotel.exporter.otlp.endpoint=http://gateway-collector.observability.svc.cluster.local:4318", \
"-Dotel.traces.exporter=otlp", \
"-Dotel.metrics.exporter=none", \
"-Dotel.logs.exporter=none", \
"-jar", \
"app.jar"]