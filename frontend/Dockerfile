FROM node:22-slim

# Enable pnpm via corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

# Ensure pnpm runs non-interactively in Docker/CI builds
ENV CI=true

WORKDIR /app

# Install dependencies (layer cached)
COPY package.json pnpm-lock.yaml* pnpm-workspace.yaml* ./
RUN pnpm install --frozen-lockfile

EXPOSE 5173

CMD ["pnpm", "dev", "--host", "0.0.0.0"]
