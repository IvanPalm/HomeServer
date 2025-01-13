## Caddy Setup Guide

This guide provides step-by-step instructions to set up Caddy as a reverse proxy in a Dockerized environment.

---

### Steps to Configure FreshRSS

#### 1. Set Up the FreshRSS Docker Directory

1. Change directory to FreshRSS root
   
   ```bash
   cd freshrss
   ```

2. Create a `docker-compose.yaml` file:
   
   ```yaml
   version: '3.8'
   services:
     freshrss:
       image: lscr.io/linuxserver/freshrss:latest
       container_name: freshrss
       environment:
         - PUID=${PUID}
         - PGID=${PGID}
         - TZ=${TZ}
       volumes:
         - ./config:/config
       ports:
         - ${TO_PORT_80}:80
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

```
PUID=0101
PGID=0101
TZ=Your/Timezone
TO_PORT_80=0808
```

> **Note:** FreshRSS is configured to use the built-in SQLite database by default. No additional database setup is required.
The SQLite database and all configurations are stored in the mounted volumes, ensuring data persistence across updates.

#### 3. Reverse Proxy Configuration

To use Caddy as a reverse proxy, add the freshrss service to the `Caddyfile`.

For instance:

```
rss.mydomain.net:443 {
    reverse_proxy freshrss:80
}
```

#### 4. Launch FreshRSS

Run the FreshRSS container

```bash
docker compose up -d
```

#### 5. Initial Setup

1. Access FreshRSS at `https://rss.mydomain.net`
1. Follow the setup wizard:
   - Choose your language
   - Set up your admin account
   - For the database, select "SQLite" (built-in)
   - Complete the remaining steps as prompted

#### 6. Updating FreshRSS

To update FreshRSS, pull the latest image and recreate the container.

```bash
docker compose pull
docker compose up -d
```
