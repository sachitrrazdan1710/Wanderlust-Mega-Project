# ------------------- Stage 1: Build -------------------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install --omit=dev

COPY . .

RUN npm run build


# ------------------- Stage 2: Production -------------------
FROM node:18-alpine

WORKDIR /app

# Only copy build output (VERY IMPORTANT)
COPY --from=builder /app/dist ./dist

# Install lightweight server
RUN npm install -g serve

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]
