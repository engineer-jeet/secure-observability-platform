# Multi-Region OpenTelemetry Observability Platform

## Overview

This project implements a distributed observability platform using OpenTelemetry Collector, Kubernetes, and OpenSearch.

It supports multi-region telemetry ingestion with centralized processing through a gateway collector deployed in the US region.

The system demonstrates real-world observability patterns including distributed tracing, routing, data masking, and service-level indexing.

---

## Architecture

The system is composed of three layers:

### 1. Regional Collectors (EU / APAC)

- Deployed close to application workloads
- Receive telemetry via OTLP (gRPC/HTTP)
- Enrich data with regional metadata (eu-west-1, ap-south-1)
- Forward telemetry to the central gateway collector

### 2. Gateway Collector (US)

- Central processing and routing layer
- Receives telemetry from all regions
- Applies data transformation and PII masking
- Routes telemetry based on service identity
- Forwards processed data to OpenSearch

### 3. OpenSearch Cluster

- Stores traces in service-specific indices
- Provides search and debugging capabilities
- Acts as the central telemetry datastore

---

## Data Flow

Application Services  
→ Regional OpenTelemetry Collectors  
→ US Gateway Collector  
→ OpenSearch Cluster  

---

## Service Routing Logic

Routing is based on:
attributes[“service.name”]

Each service is mapped to a dedicated pipeline:

- payment-service → traces/payment
- user-service → traces/user
- order-service → traces/order
- inventory-service → traces/inventory
- notification-service → traces/notification
- checkout-service → traces/checkout

---

## Data Protection (PII Masking)

The gateway collector enforces sensitive data protection:

- customer.email → REDACTED
- credit_card → MASKED
- password → removed

This ensures no sensitive data is stored in OpenSearch.

---

## OpenSearch Index Strategy

Each service writes to a dedicated index:

- traces-payment
- traces-user
- traces-order
- traces-inventory
- traces-notification
- traces-checkout

Benefits:

- Service-level isolation
- Faster debugging
- Simplified querying
- Scalable indexing strategy

---

## Metrics

The OpenTelemetry Collector exposes internal telemetry metrics in Prometheus format:
http://localhost:8888/metrics

Key metrics:

- otelcol_receiver_accepted_spans_total
- otelcol_exporter_sent_spans_total

Note: No external Prometheus server is required for this setup.

---

## Validation Steps

### Generate Test Traffic

```bash
telemetrygen traces \
  --otlp-endpoint regional-eu-collector:4317 \
  --otlp-insecure \
  --duration=60s

Verify Collector Logs
kubectl logs deployment/gateway -n observability

Verify OpenSearch Indices
curl -k -u admin:<password> https://localhost:9200/_cat/indices?v



Multi-Region Design
Regions:

* eu-west-1 → EU workload region
* ap-south-1 → APAC workload region
* us-east-1 → Central observability gateway

Design Pattern:

Edge Collection -> Regional Enrichment -> Central Processing ->  OpenSearch Indexing

Technology Stack

* OpenTelemetry Collector (contrib)
* Kubernetes (EKS)
* OpenSearch
* OTLP (gRPC / HTTP)


Future Enhancements

* Logs pipeline integration using OpenTelemetry logs signal
* Metrics pipeline integration using Prometheus remote write
* Grafana dashboards for visualization
* Kafka-based buffering for resilience
* Alerting layer for anomaly detection


