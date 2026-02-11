# ---------- build stage ----------
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY . .

# ---------- runtime stage ----------
FROM gcr.io/distroless/nodejs20-debian12:nonroot
WORKDIR /app

ENV NODE_ENV=development
ENV PORT=3000

COPY --from=build /app /app

EXPOSE 3000

CMD ["server.js"]

