## Navidrome Setup Guide

This guide provides step-by-step instructions to set up Navidrome in a Dockerized environment behind a reverse proxy.

---

### Steps to Configure Navidrome

#### 1. Set Up the Navidrome Docker Directory

1. Create and navigate to the Navidrome directory:

 ```bash
 mkdir navidrome
 cd navidrome
 ```

2. Create a `docker-compose.yml` file with the following content:

```yaml
ND_CONFIGFILE="/config/navidrome.toml"
ND_BASEURL="https://music.olivesnsun.net"
ND_PORT="4533"
ND_BACKUP_SCHEDULE="0 4 2 * *"
ND_BACKUP_COUNT=3
ND_IMAGECACHESIZE="50MB"
ND_SCANSCHEDULE="@every 1m"
ND_LOGLEVEL="info"  
ND_SESSIONTIMEOUT="12h"
```

#### 2. Configure Environment Variables

Create a `.env` file in the same directory and enter the relevant variables:

```plaintext
ND_CONFIGFILE="/config/navidrome.toml"
ND_BASEURL="https://music.mydomain.net"
ND_PORT="4533"
ND_BACKUP_SCHEDULE="0 4 2 * *"
ND_BACKUP_COUNT=3
ND_IMAGECACHESIZE="50MB"
ND_SCANSCHEDULE="@every 1m"
ND_LOGLEVEL="info"  
ND_SESSIONTIMEOUT="12h"
```

#### 3. Reverse Proxy Configuration

To use Caddy as a reverse proxy, add the Navidrome service to the `Caddyfile`. For instance:

```plaintext
music.mydomain.net:443 {
    reverse_proxy navidrome:4533
}
```

> **Note:** Ensure that the `reverse_proxy` network is properly configured and that the Caddy service is part of this network.

#### 4. Launch Navidrome

Start the Navidrome container:

```bash
docker compose up -d
```

#### 5. Initial Setup

1. Access Navidrome at `https://music.mydomain.net`.
2. Follow the setup wizard:
   - Create an account.
   - [Configure](https://www.navidrome.org/docs/usage/configuration-options/) the service, and enable external extensions like [Last FM](https://www.navidrome.org/docs/usage/external-integrations/).
   - Start populating the music library.

#### 6. Updating Navidrome

To update Navidrome, pull the latest image and recreate the container:

```bash
docker compose pull
docker compose up -d
```
