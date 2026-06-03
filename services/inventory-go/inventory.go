package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/propagation"

	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"

	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"

	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

func initTracer() {

	ctx := context.Background()

	exporter, err := otlptracegrpc.New(
		ctx,
		otlptracegrpc.WithEndpoint(
			"gateway-collector.observability.svc.cluster.local:4317",
		),
		otlptracegrpc.WithInsecure(),
	)

	if err != nil {
		log.Fatal(err)
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(
			resource.NewWithAttributes(
				semconv.SchemaURL,
				semconv.ServiceName("inventory-service"),
				semconv.ServiceVersion("5.0.0"),
				attribute.String(
					"cloud.region",
					"us-east-1",
				),
			),
		),
	)

	otel.SetTracerProvider(tp)

	// Enable W3C Trace Context propagation
	otel.SetTextMapPropagator(
		propagation.NewCompositeTextMapPropagator(
			propagation.TraceContext{},
			propagation.Baggage{},
		),
	)
}

func inventoryHandler(
	w http.ResponseWriter,
	r *http.Request,
) {

	fmt.Println(
		"incoming traceparent =",
		r.Header.Get("traceparent"),
	)

	tracer := otel.Tracer("inventory-service")

	ctx, span := tracer.Start(
		r.Context(),
		"reserve_inventory",
	)
	defer span.End()

	traceID := span.SpanContext().TraceID().String()

	fmt.Println(
		"active trace id =",
		traceID,
	)

	fmt.Println(
		"span id =",
		span.SpanContext().SpanID().String(),
	)

	response := map[string]string{
		"itemId":  "ITEM-001",
		"status":  "RESERVED",
		"traceId": traceID,
	}

	w.Header().Set(
		"Content-Type",
		"application/json",
	)

	_ = ctx

	json.NewEncoder(w).Encode(response)
}

func healthHandler(
	w http.ResponseWriter,
	r *http.Request,
) {
	w.Write([]byte("UP"))
}

func main() {

	initTracer()

	http.Handle(
		"/inventory",
		otelhttp.NewHandler(
			http.HandlerFunc(inventoryHandler),
			"inventory",
		),
	)

	http.HandleFunc(
		"/health",
		healthHandler,
	)

	log.Println(
		"inventory-service running on :8080",
	)

	log.Fatal(
		http.ListenAndServe(
			":8080",
			nil,
		),
	)
}