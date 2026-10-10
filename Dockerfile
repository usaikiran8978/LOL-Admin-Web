# syntax=docker/dockerfile:1.7
# Build from the repository root:  docker build -t lol-admin .
# API_URL is read at runtime by the Next server (rewrites /api/* → API_URL/v1/*); it never reaches the browser.

ARG NODE_VERSION=22-bookworm-slim

FROM node:${NODE_VERSION} AS deps
WORKDIR /app
COPY package.json package-lock.json tsconfig.base.json ./
COPY scripts/build-shared.cjs scripts/
COPY packages/shared packages/shared
RUN --mount=type=cache,target=/root/.npm npm ci

FROM deps AS build
ENV NEXT_TELEMETRY_DISABLED=1
COPY . .
RUN npm run build

FROM node:${NODE_VERSION} AS admin
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3001 HOSTNAME=0.0.0.0
WORKDIR /app
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static .next/static
USER node
EXPOSE 3001
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s CMD node -e "fetch('http://127.0.0.1:3001/login').then(r=>process.exit(r.status<500?0:1)).catch(()=>process.exit(1))"
CMD ["node", "server.js"]
