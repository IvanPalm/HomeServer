## Table of Contents


- [Install Docker](#install-docker)
- [Caddy](#caddy)
- [FreshRSS](#freshrss)
- [Nextcloud](#nextcloud)
- [Calibre](#calibre)
- [Piwigo](#piwigo)
- [Torrent Client](#torrent-client)
- [Jellyfin](#jellyfin)

---

## Dockerized Services

### Install Docker

Installation of Docker Engine can be performed as per [official documentation (using the `apt` repository)][docker_install]. Follow [post-installation instructions][docker_postinstall] for running Docker as a non-root user, and for starting Docker on boot with `systemd`.

Docker Compose should be installed as a plugin following the [official documentation][docker_compose_plugin].

### Caddy

**Purpose**  
Caddy is a web server and reverse proxy, known for its simplicity and automatic HTTPS capabilities.

- **Features**
  - Reverse proxy with automatic SSL certificate management.
  - Easy configuration using a `Caddyfile`.
  - HTTP/2 and IPv6 support by default.

- **Dedicated documentation**  
  [Caddy Setup Guide](./services/caddy/README.md)

---

### FreshRSS

**Purpose**  
FreshRSS is a self-hosted RSS and Atom feed aggregator, designed for efficient content curation and reading.

- **Features**
  - Lightweight and customizable feed reader
  - Powerful search and filtering options
  - Multi-user support with access controls
  - Mobile-friendly with responsive design
  - Extensions and themes for personalization
  - API for third-party integrations

- **Dedicated documentation**  
  [FreshRSS Setup Guide](./services/freshrss/README.md)

---

### Nextcloud

**Purpose**  
Nextcloud is a self-hosted platform for file sharing, calendar, and contact management.

- **Features**
  - File storage and synchronization.
  - Collaborative document editing.
  - Calendar and contacts integration.

- **Dedicated Documentation**  
  [Nextcloud Setup Guide](#)

---

### Calibre

**Purpose**  
Calibre is an e-book management application, ideal for organizing, converting, and accessing a personal library.

- **Features**
  - E-book library management.
  - Format conversion for e-readers.
  - Web-based access to your collection.

- **Dedicated Documentation**  
  [Calibre Setup Guide](#)

---

### Piwigo

**Purpose**  
Piwigo is an open-source photo gallery solution for hosting and sharing your personal photo collection.

- **Features**
  - Album creation and tagging.
  - User and permission management.
  - Plugins for added functionality.

- **Dedicated Documentation**  
  [Piwigo Setup Guide](#)

---

### Torrent Client

**Purpose**  
A torrent client allows efficient downloading and management of files via the BitTorrent protocol.

- **Features**
  - Remote torrent management.
  - Bandwidth and connection controls.
  - Integration with media servers.

- **Dedicated Documentation**  
  [Torrent Client Setup Guide](#)

---

### Jellyfin

**Purpose**  
Jellyfin is an open-source media server for streaming movies, TV shows, music, and more.

- **Features**
  - Cross-platform media playback.
  - Metadata organization.
  - Support for multiple users and devices.

- **Dedicated Documentation**  
  [Jellyfin Setup Guide](#)

---

## Resources and Links

- Docker Documentation: [https://docs.docker.com](https://docs.docker.com)  
- Let's Encrypt: [https://letsencrypt.org](https://letsencrypt.org)  
- Links to individual service guides will be included in their respective sections.
  
[docker_install]:https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository  
[docker_postinstall]:https://docs.docker.com/engine/install/linux-postinstall/  
[docker_compose_plugin]:https://docs.docker.com/compose/install/linux/  
