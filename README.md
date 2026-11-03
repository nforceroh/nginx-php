# nginx-php

Base image for PHP web applications in the portfolio: nginx + PHP 8.5 (php-fpm) +
composer, on [alpine-base](https://github.com/nforceroh/alpine-base) with s6-overlay
running both daemons.

Consumers: [snappymail](https://github.com/nforceroh/snappymail),
[vimbadmin](https://github.com/nforceroh/vimbadmin). Pin it by tag:

```dockerfile
FROM ghcr.io/nforceroh/nginx-php:3.24
```

## What's inside

- nginx with the full set of Alpine's `nginx-mod-*` dynamic modules
- PHP 8.5 as php-fpm, with the common extension set (`pdo_mysql`, `mysqli`, `gd`,
  `intl`, `imap`, `soap`, plus `pecl-apcu`, `pecl-redis`, `pecl-memcached`)
- `/usr/bin/php` symlinked to `php85`
- composer, installed with a checksum-verified installer

## Runtime layout

| Path | Purpose |
| --- | --- |
| `/data/web` | web root; serve your application from here |
| `/config` | volume; drop-in PHP configs are read from `/config/php/*.conf` |
| `/etc/nginx/nginx.conf`, `/etc/nginx/conf.d/default.conf` | nginx configuration, provided by this image |

nginx logs to stdout/stderr via symlinks, so `docker logs` shows access and error
output.

## Services

s6-overlay runs two longruns, both dependent on the base's `user` init:

- `svc-nginx` — nginx in the foreground
- `svc-php` — php-fpm in the foreground

## Build-time tunables

| ARG | Default | Description |
| --- | --- | --- |
| `BUILD_DATE` | `now` | label metadata |
| `VERSION` | `unknown` | label metadata; CI passes the build date |

There are no runtime `ENV` tunables: PHP's `upload_max_filesize` and friends come from
`/etc/php85/conf.d/upload.ini` (overridable via a `/config` mount), and application
settings belong to the application image that inherits this one.

## Local development

```sh
make build   # build the image
make test    # build, then run tests/run_tests.sh
make run     # run with a /config mount and 8080 published
```

For a deployment, mount the PHP drop-in directory at `/config/php` and your
application files at `/data/web` (or build an image from this base). For
example:

```sh
docker run -d --name php-app \
  --restart unless-stopped \
  -p 8080:8080 \
  -v "$PWD/web:/data/web:ro" \
  -v "$PWD/php-config:/config/php:ro" \
  ghcr.io/nforceroh/nginx-php:latest
```

The local `make run` target expects the sibling `../../nginx-php-config`
directory to exist. The example above can be used when your config lives
elsewhere.

CI is the only publisher — see
[nforceroh/.github](https://github.com/nforceroh/.github) for the shared build and
cleanup workflows. Published tags: `3.24` (stable pin), `latest`, `main`, date and sha
tags.
