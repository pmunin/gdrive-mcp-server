# Stage 1: Build
FROM node:20-slim AS builder
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies WITHOUT running the build script yet
RUN npm install --ignore-scripts

# Now copy the source code
COPY . .

# Manually trigger the build now that the files exist
RUN npm run build

# Stage 2: Run
FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

RUN mkdir -p /app/credentials

ENTRYPOINT ["node", "dist/index.js"]