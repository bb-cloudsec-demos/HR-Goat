# Use a Node.js image
FROM node:16-alpine

# Install socat for port redirection
RUN apk add --no-cache bash curl wget socat dos2unix


# Create app directory
WORKDIR /app

# Copy frontend build
COPY dist/ ./dist/

# Copy backend files
COPY server/ ./server/

# Copy src directory with SQL files
COPY src/ ./src/


COPY public/ ./public/

COPY scripts/ ./scripts/

# Create default avatar file
RUN echo '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="128" height="128"><circle cx="32" cy="32" r="32" fill="#e0e0e0"/><path d="M32 16c-5.5 0-10 4.5-10 10s4.5 10 10 10 10-4.5 10-10-4.5-10-10-10zm0 38c-6.7 0-12.8-3.1-17-8 0-5.5 11.3-8.5 17-8.5s17 3 17 8.5c-4.2 4.9-10.3 8-17 8z" fill="#bdbdbd"/></svg>' > ./dist/default-avatar.svg

# Install backend dependencies
WORKDIR /app/server
RUN npm install

# Return to app directory and install frontend dependencies
WORKDIR /app
RUN npm init -y && \
    npm install express@4.18.2 \
    http-proxy-middleware@2.0.6 \
    node-fetch@2.6.1 \
    cors@2.8.5 \
    path-to-regexp@3.2.0

# Copy frontend server file
COPY frontend-server.js /app/frontend-server.js

# Create log directory
RUN mkdir -p /var/log && \
    touch /var/log/frontend.log /var/log/backend.log /var/log/socat.log && \
    chmod 666 /var/log/frontend.log /var/log/backend.log /var/log/socat.log

# Copy and prepare entrypoint script
COPY entrypoint.sh.unix /app/entrypoint.sh
RUN dos2unix /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh && \
    sed -i 's/\r$//' /app/entrypoint.sh

# Expose ports
EXPOSE 80 5001 5002

# Set entrypoint to our script
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"] 