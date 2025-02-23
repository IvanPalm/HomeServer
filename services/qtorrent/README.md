## qTorrent Setup Guide

This guide provides instructions to set up a Dockerized torrenting stack using qBittorrent and Transmission behind a VPN for secure and private downloads.

> **Legal Notice:** Torrenting should only be used to exchange royalty-free material or content you have legal rights to share and download.

---

### Features of the qTorrent Stack

This stack consists of the following components:

- **Gluetun (VPN Client):** Routes all torrent traffic through a secure VPN connection.
- **qBittorrent:** A feature-rich torrent client with a web-based UI.
- **Transmission:** A lightweight torrent client with remote access capabilities.

---

### Steps to Configure qTorrent

#### 1. Set Up the qTorrent Docker Directory

1. Create and navigate to the qTorrent directory:

```bash
mkdir qtorrent
cd qtorrent
```

1. Create a `docker-compose.yml` file with the following content:

```yaml
name: "qTorrent"
services:
  nordvpn:
    container_name: gluetun-nord
    image: qmcgaw/gluetun
    cap_add:
      - NET_ADMIN
    ports:
      - "${QBITTORRENT_WEBUI_PORT}:8089"  # qBittorrent UI
      - "${TRANSMISSION_WEBUI_PORT}:9091" # Transmission UI
      - "${TRANSMISSION_PORT}:51413"      # Transmission
      - "${TRANSMISSION_PORT}:51413/udp"  # Transmission (UDP)
      - "${QBITTORRENT_PORT}:51420"      # qBittorrent
      - "${QBITTORRENT_PORT}:51420/udp"  # qBittorrent (UDP)
    environment:
      - VPN_SERVICE_PROVIDER=nordvpn
      - VPN_TYPE=${VPN_TYPE}
      - WIREGUARD_PRIVATE_KEY=${WIREGUARD_PRIVATE_KEY}
      - SERVER_REGIONS=${NORDVPN_COUNTRY}
      - FIREWALL_VPN_INPUT_PORTS=${QBITTORRENT_PORT}
      - FIREWALL_VPN_OUTPUT_PORTS=${QBITTORRENT_PORT}
      - FIREWALL=on
    restart: always

  qbittorrent:
    image: linuxserver/qbittorrent:4.5.2
    network_mode: "service:nordvpn"
    container_name: qbittorrent-nord
    depends_on:
      - nordvpn
    environment:
      - WEBUI_PORT=${QBITTORRENT_WEBUI_PORT}
      - PUID=${QBITTORRENT_PUID}
      - PGID=${QBITTORRENT_PGID}
      - TZ=${TZ}
    volumes:
      - "./config/qtorrent:/config"
      - "./data/qtorrent:/downloads"
    restart: always

  transmission:
    image: ghcr.io/linuxserver/transmission:4.0.2
    network_mode: "service:nordvpn"
    container_name: transmission-nord
    depends_on:
      - nordvpn
    environment:
      - PUID=${TRANSMISSION_PUID}
      - PGID=${TRANSMISSION_PGID}
      - TZ=${TZ}
    volumes:
      - "/config/trans:/config"
      - "/data/trans:/downloads"
      - "/data/trans/watch:/watch"
    restart: always
```

#### 2. Configure Environment Variables

Create a `.env` file in the same directory and enter the relevant variables:

#### 3. Launch the qTorrent Stack

To start the services, run:

```bash
docker compose up -d
```

#### 4. Accessing qBittorrent Web UI

Once the stack is running, you can access the qBittorrent Web UI from your local network by opening a web browser and navigating to:

```plaintext
http://localhost:8089
```

> **Note:** Replace `localhost` with your server's IP if accessing from another device (e.g., `http://192.168.1.X:8089`).

#### 5. Updating the Stack

To update the services, pull the latest images and restart the containers:

```bash
docker compose pull
docker compose up -d
```
