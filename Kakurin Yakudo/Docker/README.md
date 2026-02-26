#  most-widely-used Dockerfile
## RUN Golang Binary
<details>
<summary>Dockerfile</summary>
  
  ```Dockerfile
  FROM golang:alpine
  RUN apk add --no-cache curl libc6-compat
  WORKDIR /app
  COPY app .
  RUN chmod +x app
  CMD ["./app"]
  ```
</details>
