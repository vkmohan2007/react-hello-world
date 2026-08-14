# ==========================================
# Stage 1: Build React application
# ==========================================
FROM node:14-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install exact dependencies
RUN npm ci

# Copy application source
COPY . .

# Build React application
RUN npm run build


# ==========================================
# Stage 2: Production Nginx server
# ==========================================
FROM nginx:alpine

# Remove default Nginx files
RUN rm -rf /usr/share/nginx/html/*

# CRA creates the build directory
COPY --from=builder /app/build /usr/share/nginx/html

# Custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# HTTP
EXPOSE 80

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1/ || exit 1

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
