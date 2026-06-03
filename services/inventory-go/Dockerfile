FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY . .

RUN go mod tidy
RUN go build -o inventory-service .

FROM alpine:3.22

WORKDIR /app

COPY --from=builder /app/inventory-service .

EXPOSE 8080

CMD ["./inventory-service"]