# Stage 1: Install Node.js dependencies
FROM node:20-slim AS node-deps
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --production

# Stage 2: Final image with Python + Node.js
FROM python:3.11-slim

# Install Node.js runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get purge -y curl gnupg && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Remove dangerous tools
RUN rm -f /usr/bin/wget /usr/bin/apt* /usr/bin/dpkg* \
          /usr/bin/pip* /usr/local/bin/pip* \
          /usr/bin/perl* /usr/bin/gcc* /usr/bin/cc* /usr/bin/make* && \
    rm -rf /usr/lib/python*/ensurepip && \
    rm -rf /usr/local/lib/python*/dist-packages/pip* && \
    rm -rf /usr/local/lib/python*/dist-packages/setuptools*

# Create non-root user for running Python code
RUN useradd -m -s /bin/false -u 1000 runner

# Set up app directory (owned by root, not readable by runner)
WORKDIR /app
COPY --from=node-deps /app/node_modules ./node_modules
COPY . .
RUN chmod -R 700 /app

# Create temp directory for code execution (owned by runner)
RUN mkdir -p /tmp/leetcode && chown runner:runner /tmp/leetcode

ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080

CMD ["node", "/app/server.js"]
