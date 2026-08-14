# ==========================================
# Stage 1: Build React application
# ==========================================
FROM node:14-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY . .

# Create production build
RUN npm run build


# ==========================================
# Stage 2: Run React application
# ==========================================
FROM node:14-alpine

WORKDIR /app

# Install lightweight static web server
RUN npm install -g serve@14.2.4

# Copy production build from builder
COPY --from=builder /app/build ./build

# React application port
EXPOSE 3000

# Start production server
CMD ["serve", "-s", "build", "-l", "3000"]
