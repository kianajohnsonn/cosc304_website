#!/usr/bin/env bash
set -euo pipefail

# start.sh — convenience script to start/stop this project using Docker Compose or Dockerfile.
# Usage: ./start.sh [start|stop|restart|logs|status]

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

action="${1:-start}"

# find docker-compose command (prefer `docker compose` if available)
compose_cmd=""
if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    compose_cmd="docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    compose_cmd="docker-compose"
  fi
fi

usage() {
  echo "Usage: $0 {start|stop|restart|logs|status}"
  exit 1
}

# If docker-compose.yml exists and we have a compose command, drive with compose.
if [[ -f "$cwd/docker-compose.yml" ]] && [[ -n "$compose_cmd" ]]; then
  case "$action" in
    start)
      echo "Using $compose_cmd to build and start services..."
      $compose_cmd -f "$cwd/docker-compose.yml" up --build -d --remove-orphans
      $compose_cmd -f "$cwd/docker-compose.yml" ps
      ;;
    stop)
      echo "Stopping services..."
      $compose_cmd -f "$cwd/docker-compose.yml" down
      ;;
    restart)
      "$0" stop
      "$0" start
      ;;
    logs)
      $compose_cmd -f "$cwd/docker-compose.yml" logs -f
      ;;
    status)
      $compose_cmd -f "$cwd/docker-compose.yml" ps
      ;;
    *)
      usage
      ;;
  esac
  exit 0
fi

# Fallback: if there's a Dockerfile and docker is available, build and run a container.
if [[ -f "$cwd/Dockerfile" ]] && command -v docker >/dev/null 2>&1; then
  image_name="cosc304_website:latest"
  container_name="cosc304_webapp"
  case "$action" in
    start)
      echo "Building Docker image $image_name..."
      docker build -t "$image_name" "$cwd"
      if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Removing existing container $container_name..."
        docker rm -f "$container_name"
      fi
      echo "Running container $container_name (port 8080 -> 8080). Edit script if a different mapping is needed."
      docker run -d --name "$container_name" -p 8080:8080 "$image_name"
      docker logs -f "$container_name"
      ;;
    stop)
      docker rm -f "$container_name" || true
      ;;
    restart)
      "$0" stop
      "$0" start
      ;;
    logs)
      docker logs -f "$container_name"
      ;;
    status)
      docker ps -a --filter "name=$container_name"
      ;;
    *)
      usage
      ;;
  esac
  exit 0
fi

# Nothing we can do automatically
echo "No docker-compose.yml or Dockerfile found, or Docker/compose not available."
echo "Manual options:"
echo "  - Deploy the `WebContent/` directory to a servlet container (Tomcat) or IDE."
echo "  - Add a docker-compose.yml or Dockerfile to enable this script."
exit 1
