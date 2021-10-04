# WhoAmI container (PHP Symphony Request)
Use it to test that proxies and load balancers are passing on the right things, such as the client IP and schema, 
etc. Supports https using a self-signed certificate out of the box.

Fairly lightweight. All values are returned via the de-facto standard 'Request' class in symfony/http-foundation. 
With all proxies trusted.

Note: In order to keep it as a single container, apache2 is used rather than nginx, which typically requires you to set 
up separate containers.

## Usage

```
docker run -d -p 80:80 -p 443:443 --restart unless-stopped ghcr.io/jimcronqvist/whoami:latest
```

## Build

```
docker build -t whoami .
```