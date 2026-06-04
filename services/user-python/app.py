from fastapi import FastAPI
from pydantic import BaseModel
import requests

from opentelemetry import trace

from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)

from opentelemetry.instrumentation.fastapi import (
    FastAPIInstrumentor,
)

from opentelemetry.instrumentation.requests import (
    RequestsInstrumentor,
)

resource = Resource.create({
    "service.name": "user-service",
    "service.version": "1.0.0",
    "cloud.region": "eu-west-1"
})

provider = TracerProvider(resource=resource)

provider.add_span_processor(
    BatchSpanProcessor(
        OTLPSpanExporter(
            endpoint="gateway-collector.observability.svc.cluster.local:4317",
            insecure=True
        )
    )
)

trace.set_tracer_provider(provider)

app = FastAPI()

FastAPIInstrumentor.instrument_app(app)
RequestsInstrumentor().instrument()

tracer = trace.get_tracer("user-service")


class User(BaseModel):
    name: str
    email: str


@app.post("/user")
def create_user(user: User):

    with tracer.start_as_current_span("create_user"):

        notification_response = requests.post(
            "http://notification-service.apps.svc.cluster.local:4000/notify",
            json={
                "email": user.email,
                "message": "Welcome"
            },
            timeout=5
        )

        return {
            "status": "USER_CREATED",
            "notification": notification_response.json()
        }


@app.get("/health")
def health():
    return {
        "status": "UP"
    }