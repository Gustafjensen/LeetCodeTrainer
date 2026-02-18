FROM docker:24-dind

RUN apk add --no-cache nodejs npm

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --production

COPY . .

EXPOSE 3000

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
