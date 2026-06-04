from fastapi import FastAPI
from pydantic import BaseModel
import requests

app = FastAPI()


class User(BaseModel):
    name: str
    email: str


@app.post("/user")
def create_user(user: User):

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
    return {"status": "UP"}