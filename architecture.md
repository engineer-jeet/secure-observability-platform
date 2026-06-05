# Architecture - Multi-Region OpenTelemetry Platform

## 1. System Overview

This platform implements a multi-region observability pipeline using OpenTelemetry Collector, Kubernetes, and OpenSearch.

It is designed to centralize telemetry data from multiple regions into a single processing and indexing gateway.

---

## 2. High-Level Architecture
[Application Services]
|
v
+–––––––––––+
| Regional Collectors  |
| (EU / APAC)          |
+–––––––––––+
|
v
+–––––––––––+
| US Gateway Collector |
| (Central Processor)  |
+–––––––––––+
|
v
+–––––––––––+
| OpenSearch Cluster   |
| (Index Storage)      |
+–––––––––––+


---

## 3. Data Flow

1. Services emit telemetry (traces/logs/metrics via OTLP)
2. Regional collectors receive and enrich data with:
   - region metadata (eu-west-1 / ap-south-1)
3. Data is forwarded to US gateway collector
4. Gateway collector:
   - masks sensitive attributes
   - applies routing logic per service
   - forwards to OpenSearch
5. OpenSearch stores data in service-specific indices

---

## 4. Routing Strategy (Gateway)

Routing is based on:
attributes[“service.name”]

Mapping:

| Service | Pipeline | Index |
|--------|----------|-------|
| payment-service | traces/payment | traces-payment |
| user-service | traces/user | traces-user |
| order-service | traces/order | traces-order |
| inventory-service | traces/inventory | traces-inventory |
| notification-service | traces/notification | traces-notification |
| checkout-service | traces/checkout | traces-checkout |

---

## 5. Data Protection Layer

The gateway applies attribute processors:

- customer.email → REDACTED
- credit_card → MASKED
- password → removed

This ensures PII protection before indexing.

---

## 6. OpenSearch Index Strategy

Each service writes to a dedicated index:

- traces-payment
- traces-user
- traces-order
- traces-inventory
- traces-notification
- traces-checkout

This enables:

- service-level debugging
- performance isolation
- easier query filtering

---

## 7. Observability Metrics

Collector exposes Prometheus metrics:
http://localhost:8888/metrics


Key metrics:

- otelcol_receiver_accepted_spans_total
- otelcol_exporter_sent_spans_total

---

## 8. Multi-Region Design

### Regions:
- eu-west-1 (EU)
- ap-south-1 (APAC)
- us-east-1 (Gateway)

### Pattern:
- Regional collectors reduce latency
- US gateway centralizes processing
- OpenSearch acts as global source of truth

---

## 9. Future Enhancements

- Add logs pipeline (OTel logs → OpenSearch logs indexes)
- Add metrics pipeline (Prometheus remote write)
- Add Grafana dashboards
- Add Kafka buffering layer for resilience
- Add alerting on trace anomalies


