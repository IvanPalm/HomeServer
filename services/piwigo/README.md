
## Piwigo Setup Guide

This guide provides step-by-step instructions to set up Piwigo, a web-based photo gallery, in a Dockerized environment.

---

### Steps to Configure Piwigo

#### 1. Create Docker Network

Ensure the necessary Docker network exists.

```bash
docker network create db_network
docker network ls
```

> **Note:** if the network `reverse_proxy` is not listed in the output, [setup Caddy](../caddy/README.md) before continuing.

---

#### 2. Set Up the Piwigo Docker Directory

1. Create a directory for the setup, if it doesn't exist.

```bash
mkdir piwigo
cd piwigo
```

2. Create a `docker-compose.yaml` file:

```yaml
name: 'Piwigo'

services:
  piwigo:
    image: lscr.io/linuxserver/piwigo:15.3.0-ls290
    container_name: piwigo
    environment:
      - PUID=${PUID}          
      - PGID=${PGID}          
      - TZ=${TIMEZONE}
    volumes:
      - ./config/piwigo_config:/config
      - ./gallery:/gallery
    ports:
      - ${PIWIGO_PORT}:80
    networks:
      - db_network
      - reverse_proxy
    restart: unless-stopped

  mariadb:
    image: lscr.io/linuxserver/mariadb:11.4.4-r1-ls169
    container_name: mariadb
    environment:
      - PUID=${PUID}
      - PGID=${PUID}
      - TZ=${TIMEZONE}
      - MYSQL_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}
      - MYSQL_PASSWORD=${MARIADB_PASSWORD}
      - MYSQL_USER=${MARIADB_USER}
      - MYSQL_DATABASE=${MARIADB_DATABASE}
    volumes:
      - ./config/mariadb_config:/config
    ports:
      - ${MARIADB_PORT}:3306
    networks:
      - db_network
    restart: unless-stopped

networks:
  db_network:
    external: true
  reverse_proxy:
    external: true
```

> **Note:** Make sure the directories passed as volumes exist in the root directory of this service.

3. Create an `.env` file to store environment variables.

```bash
nano .env
```

Example `.env` file:

```plaintext
PUID=0101          
PGID=1010          
TIMEZONE=Europe/Berlin                 
PIWIGO_PORT=8888

MARIADB_ROOT_PASSWORD=your_root_password
MARIADB_PASSWORD=your_password
MARIADB_USER=your_username
MARIADB_DATABASE=your_database_name
MARIADB_PORT=0633
```

---

#### 3. Configure the Reverse Proxy with Caddy

1. Add the service to the `Caddyfile` for enabling reverse proxy.

```bash
nano /path/to/caddy/Caddyfile
```

Example entry for **Piwigo**:

```plaintext
photo.mydomain.net:443 {
    reverse_proxy piwigo:80
}
```

**Note:** The `docker-compose` shown above will connect the `piwigo` container to the `reverse_proxy` network.

2. Start the Caddy container (if not already running).

```bash
cd /path/to/caddy
docker-compose up -d
```

---

#### 3. Launch the Setup

Start the Piwigo and MariaDB containers.

```bash
docker-compose up -d
```

---

#### 4. Access Piwigo

1. Open your browser and navigate to:

```plaintext
https://photo.mydomain.net
```

2. Follow the on-screen instructions to complete the Piwigo installation, using the database credentials specified in the `.env` file.

---

#### 5. Secure the Setup

1. Ensure your `.env` file (if used) is not exposed:

```bash
chmod 600 .env
```

2. Test the SSL setup.

```bash
curl -I https://photo.mydomain.net
```
