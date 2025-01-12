## Caddy Setup Guide

This guide provides step-by-step instructions to set up Caddy as a reverse proxy in a Dockerized environment.

---

### Steps to Configure Caddy

#### 1. Create a Docker Network

```bash
docker network create reverse_proxy
docker network ls
```

#### 2. Set Up the Caddy Docker Directory
	
1. Create a directory for Caddy

	   ```bash
	   mkdir caddy
	   cd caddy
	   ```
	
2. Create a `docker-compose.yaml` file

   ```yaml
   version: '3.8'
   services:
     caddy:
       container_name: caddy
       image: caddy:alpine
       restart: always
       ports:
         - 80:80
         - 443:443
       networks:
         - reverse_proxy
       volumes:
         - ./Caddyfile:/etc/caddy/Caddyfile
         - caddy_data:/data
         - caddy_config:/config

   volumes:
     caddy_data:
     caddy_config:

   networks:
     reverse_proxy:
       external: true
   ```
	
3. Add the `Caddyfile` for reverse proxy rules:
	
   ```bash
   nano Caddyfile
   ```

   Example `Caddyfile`:

   ```
   <service1.mydomain.net>:443 {
       reverse_proxy <container_name1>:<service_port1>
   }

   
   <service2.mydomain.net>:443 {
       reverse_proxy <container_name2>:<service_port2>
   }
   ```
	
#### 3. Link Target Containers to the Network

Ensure each target container is added to the `reverse_proxy` network. 

The `docker-compose.yaml` of each service should include:

```yaml
networks:
  reverse_proxy:
    external: true
```

#### 4. Launch Caddy

Run the Caddy container:

```bash
docker-compose up -d
```

**SSL Configuration by Default** 

See [official documentation](https://caddyserver.com/docs/automatic-https) for details.

