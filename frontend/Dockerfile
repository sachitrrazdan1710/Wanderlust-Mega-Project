# ------------------- Stage 1: Build -------------------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Install all deps (including dev for build)
RUN npm install

COPY . .

RUN npm run build


# ------------------- Stage 2: Production -------------------
FROM node:18-alpine

WORKDIR /app

# Install only serve (lightweight static server)
RUN npm install -g serve

# Copy only build output
COPY --from=builder /app/dist ./dist

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]
