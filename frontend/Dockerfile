# ------------------- Stage 1: Build -------------------
FROM node:18-alpine AS builder

WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./

# Install deps with low memory usage
RUN NODE_OPTIONS="--max-old-space-size=256" \
    npm install --omit=dev --no-audit --no-fund

# Copy rest of code
COPY . .

# Build app with limited memory
RUN NODE_OPTIONS="--max-old-space-size=256" \
    npm run build


# ------------------- Stage 2: Production -------------------
FROM node:18-alpine

WORKDIR /app

# Install lightweight static server
RUN npm install -g serve

# Copy ONLY built output (VERY IMPORTANT)
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 5173

# Run production server
CMD ["serve", "-s", "dist", "-l", "5173"]
