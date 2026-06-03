require("./tracing");

const express = require("express");
const axios = require("axios");

const { trace } = require("@opentelemetry/api");

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({
    status: "UP",
  });
});

app.post("/payment", async (req, res) => {

  const tracer = trace.getTracer("payment-service");

  await tracer.startActiveSpan(
    "process_payment",
    async (span) => {

      try {

        console.log("Processing payment...");

        const response = await axios.post(
          "http://order-service.apps.svc.cluster.local:8000/order"
        );

        res.json({
          paymentStatus: "SUCCESS",
          order: response.data,
        });

      } catch (err) {

        console.error(
          "Order service call failed:",
          err.message
        );

        res.status(500).json({
          paymentStatus: "FAILED",
          error: err.message,
        });

      } finally {

        span.end();

      }

    }
  );

});

app.listen(3000, () => {
  console.log(
    "payment-service running on port 3000"
  );
});