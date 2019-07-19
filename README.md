# NGINX-LE - Nginx web and proxy with automatic let's encrypt [![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/t0be/nginx-le/) 

Simple nginx image (alpine based) with integrated [Let's Encrypt](https://letsencrypt.org) support.
Alternative version of original [umputun's](https://github.com/umputun/nginx-le) image, reduced in size and simplified by using [acme.sh](https://github.com/Neilpang/acme.sh) shell-script.


## How to use

- get [docker-compose.yml](https://github.com/2b/nginx-le/blob/master/docker-compose.yml) and change things:
  - set timezone to your local, for example `TZ=UTC`. For more timezone values check `/usr/share/zoneinfo` directory
  - set FQDN, like `LE_FQDN=www.example.com`
  - use provided `conf/service.conf` to make your own `etc/service.conf`. Keep ssl directives as is:
    ```nginx
    ssl_certificate         SSL_CERT;
    ssl_certificate_key     SSL_KEY;
    ssl_trusted_certificate SSL_CHAIN;
    ```
- pull image - `docker-compose pull`
- if you don't want pre-built image, make you own. `docker-compose build` will do it
- start it `docker-compose up`

## Some implementation details

- based on [nginx-le](https://github.com/umputun/nginx-le) image by umputun, reduced in size ~3 times
- image uses [acme.sh](https://github.com/Neilpang/acme.sh) shell-script for certificates issue & renewal
- no multi-domain support at this moment
- original acme.sh cron job will take care of certificate renewal
- nginx-le on [docker-hub](https://hub.docker.com/r/t0be/nginx-le)
- **A+** overall rating on [ssllabs](https://www.ssllabs.com/ssltest/index.html)

![ssllabs](https://github.com/2b/nginx-le/blob/master/rating.png)

## Alternatives

- [Træfik](https://traefik.io) HTTP reverse proxy and load balancer. Supports Let's Encrypt directly.
- [Caddy](https://caddyserver.com) supports Let's Encrypt directly.
- [leproxy](https://github.com/artyom/leproxy) small and nice (stand alone) https reverse proxy with automatic Letsencrypt
- [bunch of others](https://github.com/search?utf8=✓&q=nginx+lets+encrypt)

## Examples

- [Redmine](https://github.com/2b/nginx-le/blob/master/example/docker-compose-redmine.yml). Change TZ, FQDN, database password and run 
    ```
    docker-compose -f example/docker-compose-redmine.yml up -d
    ```