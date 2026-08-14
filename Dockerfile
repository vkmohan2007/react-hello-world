# ==========================================
# Stage 1: Build React application
# ==========================================
FROM node:14-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application source
COPY . .

# Create production build
RUN npm run build


# ==========================================
# Stage 2: Production React server
# ==========================================
FROM node:14-alpine

WORKDIR /app

# Install static file server
RUN npm install -g serve@14.2.4

# Copy production build
COPY --from=builder /app/build ./build

# React application port
EXPOSE 3000

# Start React production server
CMD ["serve", "-s", "build", "-l", "3000", "--single"]
