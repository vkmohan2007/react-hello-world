# ==========================================
# Stage 1: Build the Vite application
# ==========================================
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first
# This improves Docker layer caching
COPY package*.json ./

# Install exact dependencies from package-lock.json
RUN npm ci

# Copy application source
COPY . .

# Build the Vite application
RUN npm run build


# ==========================================
# Stage 2: Production web server
# ==========================================
FROM nginx:alpine

# Remove default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy Vite build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1/ || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
