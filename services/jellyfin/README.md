## Jellyfin Setup Guide

This guide provides step-by-step instructions to set up Jellyfin as a reverse proxy in a Dockerized environment.

---

### Steps to Configure Jellyfin

#### 1. Set Up the Jellyfin Docker Directory

1. Change directory to the Jellyfin root

    ```bash
        cd jellyfin
    ```

2. Create a `docker-compose.yaml` file:

   ```yaml
   version: '3.8'
   services:
     jellyfin:
       image: lscr.io/linuxserver/jellyfin:latest
       container_name: jellyfin
       environment:
         - PUID=${PUID}
         - PGID=${PGID}
         - TZ=${TZ}
       volumes:
         - ./config:/config
         - /home/hs_admin/media:/media
       ports:
         - ${JFIN_PORT}:8096
       networks:
         - reverse_proxy
       restart: unless-stopped
   
   networks:
     reverse_proxy:
       external: true
   ```

### 2. Configure Environment Variables

Create a `.env` file in the same directory and enter the relevant variables.

For instance:

```plaintext
PUID=0101
PGID=0101
TZ=Your/Timezone
JFIN_PORT=8096
```

> **Note:** Jellyfin uses the mounted `/config` volume to store its database and settings, ensuring data persistence across updates.

#### 3. Reverse Proxy Configuration

To use Caddy as a reverse proxy, add the Jellyfin service to the `Caddyfile`.

For instance:

```json
jellyfin.mydomain.net:443 {
    reverse_proxy jellyfin:8096
}
```

#### 4. Launch Jellyfin

Run the Jellyfin container:

```bash
docker compose up -d
```

#### 5. Initial Setup

1. Access Jellyfin at `https://media.mydomain.net`
2. Follow the setup wizard:
   - Choose your language
   - Set up your admin account
   - Configure your media library by pointing to `/media`
   - Complete the remaining steps as prompted

#### 6. Updating Jellyfin

To update Jellyfin, pull the latest image and recreate the container.

```bash
docker compose pull
docker compose up -d
```