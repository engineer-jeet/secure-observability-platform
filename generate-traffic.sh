#!/bin/bash

telemetrygen traces \
  --otlp-endpoint regional-eu-collector:4317 \
  --otlp-insecure \
  --duration=60s

Make executable:
chmod +x scripts/generate-traffic.sh