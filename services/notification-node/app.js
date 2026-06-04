process.env.OTEL_LOG_LEVEL = "debug";

process.env.OTEL_METRICS_EXPORTER = "none";
process.env.OTEL_LOGS_EXPORTER = "none";

const grpc = require("@grpc/grpc-js");

const { NodeSDK } = require("@opentelemetry/sdk-node");
const { trace } = require("@opentelemetry/api");

const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-grpc");

const {
  getNodeAutoInstrumentations,
} = require("@opentelemetry/auto-instrumentations-node");

const sdk = new NodeSDK({
  serviceName: "notification-service",

  traceExporter: new OTLPTraceExporter({
    url: "gateway-collector.observability.svc.cluster.local:4317",
    credentials: grpc.credentials.createInsecure(),
  }),

  instrumentations: [
    getNodeAutoInstrumentations(),
  ],
});

sdk.start();

console.log("OTEL SDK STARTED");

const express = require("express");

const app = express();

app.use(express.json());

app.post("/notify", (req, res) => {

  const { email, message } = req.body;

  const span = trace.getActiveSpan();

  console.log(
    "active span =",
    span ? span.spanContext().traceId : "NO_SPAN"
  );

  console.log(
    `Notification sent to ${email}: ${message}`
  );

  res.json({
    status: "NOTIFICATION_SENT",
    email: email
  });

});

app.get("/health", (req, res) => {

  res.json({
    status: "UP"
  });

});

app.listen(4000, () => {

  console.log(
    "notification-service running on port 4000"
  );

});