const express = require("express");

const app = express();

app.use(express.json());

app.post("/notify", (req, res) => {

    const { email, message } = req.body;

    console.log(
        `Notification sent to ${email}: ${message}`
    );

    res.json({
        status: "NOTIFICATION_SENT",
        email: email
    });
});

app.get("/health", (req, res) => {
    res.json({
        status: "UP"
    });
});

app.listen(4000, () => {
    console.log(
        "notification-service running on port 4000"
    );
});