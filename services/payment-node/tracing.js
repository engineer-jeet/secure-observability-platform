const { NodeSDK } = require("@opentelemetry/sdk-node");

const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-grpc");

const {
  getNodeAutoInstrumentations,
} = require("@opentelemetry/auto-instrumentations-node");

const {
  resourceFromAttributes,
} = require("@opentelemetry/resources");

const {
  SemanticResourceAttributes,
} = require("@opentelemetry/semantic-conventions");

const {
  diag,
  DiagConsoleLogger,
  DiagLogLevel,
} = require("@opentelemetry/api");

diag.setLogger(
  new DiagConsoleLogger(),
  DiagLogLevel.DEBUG
);

const resource = resourceFromAttributes({
  [SemanticResourceAttributes.SERVICE_NAME]: "payment-service",
  [SemanticResourceAttributes.SERVICE_VERSION]: "4.0.0",
  "cloud.region": "us-east-1",
});

const sdk = new NodeSDK({
  resource,

  traceExporter: new OTLPTraceExporter({
    url: "http://gateway-collector.observability.svc.cluster.local:4317",
  }),

  instrumentations: [
    getNodeAutoInstrumentations(),
  ],
});

sdk.start();

console.log("OpenTelemetry initialized");