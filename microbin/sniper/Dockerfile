# Dockerfile

FROM golang:alpine

WORKDIR /app

COPY . .

RUN go build -o sniper .

ENTRYPOINT ["./sniper"]

