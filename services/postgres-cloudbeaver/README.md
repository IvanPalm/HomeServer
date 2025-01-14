## PostgreSQL + CloudBeaver Setup Guide

This guide provides step-by-step instructions to set up PostgreSQL (with PostGIS) and CloudBeaver in a Dockerized environment, secured using Caddy as a reverse proxy.

---

### Steps to Configure PostgreSQL + CloudBeaver

#### 1. Create Docker Networks

Ensure the necessary Docker networks exist:

```bash
docker network create postgres_network
docker network ls
```
> **Note:** if the network `reverse_proxy` is not listed in the output, [setup Caddy](../caddy/README.md) before continuing. 

---

#### 2. Set Up the PostgreSQL + CloudBeaver Docker Directory

1. Create a directory for the setup:

```bash
mkdir postgres-cloudbeaver
cd postgres-cloudbeaver
```

1. Create a `docker-compose.yaml` file.

```yaml
name: 'Postgres-Postgis+Cloudbeaver'

services:
  postgres:
    image: postgis/postgis:17-3.5
    container_name: postgres
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "${POSTGRES_PORT}:5432"
    networks:
      - postgres_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 3
  
  dbeaver:
    image: dbeaver/cloudbeaver:24.3.2
    container_name: dbeaver
    environment:
      - CB_SERVER_NAME=${CB_SERVER_NAME}
      - CB_ADMIN_NAME=${CB_ADMIN_NAME}
      - CB_ADMIN_PASSWORD=${CB_ADMIN_PASSWORD}
    volumes:
      - dbeaver_data:/opt/cloudbeaver/workspace
    ports:
      - "${DBEAVER_PORT}:8978"
    networks:
      - postgres_network
      - reverse_proxy
    depends_on:
      - postgres
    restart: unless-stopped
volumes:
  postgres_data:
  dbeaver_data:
networks:
  postgres_network:
    external: true
  reverse_proxy:
    external: true
```

> **Note:** A `postgis` image is used for the convenince of having spatial extensions already installed in the container.

2. Create an `.env` file to store environment variables.

```bash
nano .env
```

Example `.env` file:
   
```plaintext
POSTGRES_DB=your_database_name
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password
POSTGRES_PORT=5432
CB_SERVER_NAME=CloudBeaver
CB_ADMIN_NAME=admin
CB_ADMIN_PASSWORD=admin_password
DBEAVER_PORT=8978
```

---

#### 3. Configure the Reverse Proxy with Caddy

1. Add the `Caddyfile` to the reverse proxy setup:

```bash
nano /path/to/caddy/Caddyfile
```

Example entry for **CloudBeaver**:

```
cdbeaver.mydomain.net:443 {
    reverse_proxy dbeaver:8978
}
```

2. Ensure that the `dbeaver` container is connected to the `reverse_proxy` network.

---

#### 4. Launch the Setup

1. Start the PostgreSQL and CloudBeaver containers.

```bash
docker-compose up -d
```

2. Start the Caddy container (if not already running).

```bash
cd /path/to/caddy
docker-compose up -d
```
---

#### 5. Access CloudBeaver and Connect to PostgreSQL

1. Open your browser and navigate to the custom Cloudbeaver subdomain.

```plaintext
https://cdbeaver.mydomain.net
```

2. Log in with your admin credentials from the `.env` file.

3. Add a PostgreSQL connection in CloudBeaver:
   
   - **Host**: Find IP of Postgres server with `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres`
   - **Database**: The value of `POSTGRES_DB` from `.env`.
   - **Username**: The value of `POSTGRES_USER` from `.env`.
   - **Password**: The value of `POSTGRES_PASSWORD` from `.env`.

---

#### 6. Secure the Setup

1. Ensure your `.env` file is not exposed.

```bash
chmod 600 .env
```

2. Test the SSL setup.
   
```bash
curl -I https://cdbeaver.mydomain.net
```
