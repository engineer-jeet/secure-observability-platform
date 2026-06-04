const express = require("express");

const { NodeSDK } = require("@opentelemetry/sdk-node");

const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-grpc");

const {
  getNodeAutoInstrumentations,
} = require("@opentelemetry/auto-instrumentations-node");

const sdk = new NodeSDK({
  serviceName: "notification-service",

  traceExporter: new OTLPTraceExporter({
    url: "grpc://gateway-collector.observability.svc.cluster.local:4317",
  }),

  instrumentations: [
    getNodeAutoInstrumentations(),
  ],
});

sdk.start();

const app = express();

app.use(express.json());

app.post("/notify", (req, res) => {

  const { email, message } = req.body;

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