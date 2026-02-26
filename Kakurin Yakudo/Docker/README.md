#  most-widely-used Dockerfile
## RUN Golang Binary
<details>
<summary>Dockerfile</summary>
  
  ```Dockerfile
  FROM golang:alpine
  RUN apk add --no-cache curl libc6-compat
  WORKDIR /app
  COPY customer .
  RUN chmod +x customer
  CMD ["./customer"]
  ```
</details>
