# tsps: game server + browser client in one container.
# Build:  docker compose build      Run:  docker compose up -d
FROM node:24-bookworm

WORKDIR /app
RUN corepack enable

# Ports match the root .env used on Windows, so the two setups behave the same.
# The client swaps "localhost" for whatever host the browser opened the page on,
# so these work from any device on the LAN.
ENV WEBSOCKET_PORT=49598 \
    GATEWAY_PORT=43599 \
    PORT=3000 \
    REACT_APP_DEFAULT_WS_URL=ws://localhost:49598 \
    REACT_APP_DEFAULT_SERVER_ADDRESS=localhost:49598 \
    FAST_REFRESH=false \
    GATEWAY_LOGIN_HTTP_PORT=0 \
    GATEWAY_LOGIN_TRUST_LOOPBACK_PROXY=false

# Install dependencies first so code-only changes reuse this layer.
COPY package.json yarn.lock .yarnrc.yml ./
COPY server/package.json server/yarn.lock ./server/
COPY client/package.json client/yarn.lock ./client/
RUN npm run setup

COPY . .
RUN yarn --cwd server build \
 && yarn --cwd client build \
 && node client/scripts/serve-build.mjs --precompress

ENV NODE_ENV=production
EXPOSE 49598 3000
CMD ["yarn", "start:prod"]
