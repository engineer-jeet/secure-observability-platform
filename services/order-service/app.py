from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
import requests
import os

OTEL_ENDPOINT = os.getenv(
    "OTEL_EXPORTER_OTLP_ENDPOINT",
    "localhost:4317"
)

resource = Resource.create(
    {
        "service.name": "order-service",
        "cloud.region": "ap-south-1"
    }
)

provider = TracerProvider(resource=resource)

provider.add_span_processor(
    BatchSpanProcessor(
        OTLPSpanExporter(
            endpoint=OTEL_ENDPOINT,
            insecure=True
        )
    )
)

trace.set_tracer_provider(provider)

app = FastAPI()

FastAPIInstrumentor.instrument_app(app)
RequestsInstrumentor().instrument()

@app.post("/order")
def create_order():

    tracer = trace.get_tracer(__name__)

    with tracer.start_as_current_span("create_order"):

        inventory_response = requests.get(
            "http://inventory-service.apps.svc.cluster.local:8080/inventory"
        )

        inventory_data = inventory_response.json()

        return {
            "orderId": "ORD-12345",
            "status": "CREATED",
            "inventory": inventory_data
        }