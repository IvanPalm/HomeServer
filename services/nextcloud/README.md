## Nextcloud AIO Installation Guide

This guide provides a brief overview of setting up Nextcloud All-In-One (AIO) with IPv6 support and a Caddy reverse proxy configuration.

---

### Key Configuration Details

#### 1. IPv6 Support

The installation follows the guidance provided in the [Nextcloud AIO IPv6 Support Documentation](https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md) to ensure compatibility with IPv6 networking.

#### 2. Reverse Proxy Setup

The Caddy reverse proxy was configured as per the [Nextcloud AIO Reverse Proxy Documentation](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md#1-configure-the-reverse-proxy). Specifically, the setup under section **1.3.ii** was implemented by adding the following to the `Caddyfile`:  

```plaintext
cloud.mydomain.net:443 {
    reverse_proxy nextcloud-aio-apache:$APACHE_PORT
}
```

---

#### 3. Accessing the AIO Interface

Once the `mastercontainer` is running, the AIO interface can be accessed at `https://ip.address.of.the.homeserver:8080`.

There, the custom domain configured in the `Caddyfile` can be entered and validated to complete the setup.

---

This configuration enables secure access to Nextcloud via a custom domain with HTTPS.
