# Build stage
FROM node:18-alpine AS builder

# Tạo thư mục làm việc
WORKDIR /app

# Copy package files
COPY package*.json ./

# Cài đặt dependencies
RUN npm install --omit=dev

# Copy source code
COPY . .

# Production stage
FROM node:18-alpine

# Cài đặt các package cần thiết và dọn dẹp cache
RUN apk --no-cache add curl \
    && rm -rf /var/cache/apk/*

# Tạo user non-root
RUN addgroup -g 1001 nodejs \
    && adduser -S -u 1001 -G nodejs nodejs

# Tạo thư mục làm việc và set quyền
WORKDIR /app
RUN chown nodejs:nodejs /app

# Switch sang user non-root
USER nodejs

# Copy từ build stage
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

# Set ENV cho production
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:3000/ || exit 1

# Start application
CMD ["node", "server.js"] 