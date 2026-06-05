#!/bin/bash

kubectl port-forward svc/gateway-collector-monitoring 8888:8888 -n observability



chmod +x scripts/port-forward.sh