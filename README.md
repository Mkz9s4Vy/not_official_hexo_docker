
# Hexo Docker Image on GHCR (Auto-Updated)

Automatically builds a Docker image for Hexo on GitHub Container Registry (GHCR) every month.

**Image:** `ghcr.io/mkz9s4vy/hexo_docker:latest`

## Basic Docker Run

This runs Hexo but does not persist any data if the container is removed.

```bash
docker run --name hexo --restart always -p 4000:4000 ghcr.io/mkz9s4vy/hexo_docker:latest
```

## Run with Persistent Data

Replace /path/to/your/hexo/data with the actual path to your Hexo source files on your host machine.

```
docker run --name hexo --restart always -p 4000:4000 -v /path/to/your/hexo/data:/user-data ghcr.io/mkz9s4vy/hexo_docker:latest
```

## How Data Persistence Works:

All files within the mounted `/user-data` volume are copied into the container's working directory (`/app`) when the container starts.

Files from `/user-data` will overwrite any existing files with the same name within the container's `/app` directory.

## Access

Visit http://localhost:4000 in your browser.
