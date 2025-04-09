## Immich Setup Guide

This guide provides step-by-step instructions to set up Immich as a reverse proxy in a Dockerized environment. For the most up-to-date installation guide, refer to the official documentation:

[Immich Installation Guide](https://immich.app/docs/install/docker-compose)

---

### Steps to Configure Immich

#### 1. Set Up the Immich Docker Directory

1. Change directory to the Immich root:
   
   ```bash
   cd immich
   ```

2. Download the latest stable `docker-compose.yml` from the official release:
   
   ```bash
   curl -o docker-compose.yml -L https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
   ```

> **Warning:** Do not use the `docker-compose.yml` from the `main` branch, as it may not be compatible with the latest stable release.

### 2. Configure Environment Variables

Create a `.env` file in the same directory and enter the relevant variables.

For instance:

```
UPLOAD_LOCATION=/path/to/media
DB_PASSWORD=yourpassword
DB_USERNAME=yourusername
DB_DATABASE_NAME=immich
DB_DATA_LOCATION=/path/to/database
```

### 3. Reverse Proxy Configuration

To enable access through a reverse proxy, the `reverse_proxy` network has been added to the entire Immich stack. This allows seamless integration with Caddy or any other reverse proxy.

For Caddy, add the following entry to your `Caddyfile`:

```
immich.mydomain.net:443 {
    reverse_proxy immich-server:2283
}
```

### 4. Launch Immich

Run the Immich container:

```bash
docker compose up -d
```

### 5. Initial Setup

1. Access Immich at `https://immich.mydomain.net`
2. Follow the setup process as outlined in the [official documentation](https://immich.app/docs/install/docker-compose)
3. Configure user accounts and media libraries

### 6. Updating Immich

To update Immich, pull the latest image and recreate the container:

```bash
docker compose pull
docker compose up -d
```

