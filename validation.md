# Validation Guide

## 1. Verify Collectors Running

kubectl get pods -n observability

---

## 2. Verify Metrics Endpoint

kubectl port-forward svc/gateway-collector-monitoring 8888:8888 -n observability

curl localhost:8888/metrics | grep otelcol_receiver_accepted_spans_total

---

## 3. Verify Trace Flow

kubectl logs deployment/gateway -n observability

---

## 4. Verify OpenSearch Indices

curl -k -u admin:<password> https://localhost:9200/_cat/indices?v