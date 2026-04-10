# ------------------- Stage 1: Build Stage ------------------------------
FROM node:18-alpine AS frontend-builder

WORKDIR /app

COPY package*.json ./

# limit memory + avoid dev deps
RUN NODE_OPTIONS="--max-old-space-size=256" npm install --omit=dev

COPY . .

# ADD THIS (you removed earlier)
RUN NODE_OPTIONS="--max-old-space-size=256" npm run build


# ------------------- Stage 2: Final Stage ------------------------------
FROM node:18-alpine

WORKDIR /app

# copy only built files (VERY IMPORTANT)
COPY --from=frontend-builder /app/dist ./dist

# lightweight server
RUN npm install -g serve

EXPOSE 5173

CMD ["serve", "-s", "dist", "-l", "5173"]
