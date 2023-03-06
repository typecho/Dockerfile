# Quick reference

* Maintained by: [Typecho Dev Team](https://github.com/typecho)
* Where to get help: [the Typecho Docker Github issues](https://github.com/typecho/Dockerfile/issues)

# Supported tags and respective `Dockerfile` links

* [nightly-php7.3, nightly-php7.3-cli, nightly-php7.3-fpm, nightly-php7.3-apache, nightly-php7.4, nightly-php7.4-cli, nightly-php7.4-fpm, nightly-php7.4-apache, nightly-php8.0, nightly-php8.0-cli, nightly-php8.0-fpm, nightly-php8.0-apache, nightly-php7.3-alpine, nightly-php7.3-cli-alpine, nightly-php7.3-fpm-alpine, nightly-php7.4-alpine, nightly-php7.4-cli-alpine, nightly-php7.4-fpm-alpine, nightly-php8.0-alpine, nightly-php8.0-cli-alpine, nightly-php8.0-fpm-alpine](https://github.com/typecho/Dockerfile)

# How to use this image

## Start via `docker run`

```bash
$ docker run --name typecho-server -e TYPECHO_SITE_URL=https://your-domain.com -d joyqi/typecho:nightly-php7.4-apache
```

## Start via `docker-compose`

```yaml
version: '3.7'

services:
  typecho:
    image: joyqi/typecho:nightly-php7.4-apache
    container_name: typecho-server
    restart: always
    environment:
      - TYPECHO_SITE_URL=https://your-domain.com
    ports:
      - 8080:80
    volumes:
      - /var/typecho:/app/usr
```

1. Replace `your-domain.com` with your own domain name.
2. Port `8080` is just an example, you can change it to any port you want.
3. Mount local directory `/var/typecho` to container directory `/app/usr` for persistent data.

# How to extend this image

## Environment Variables

| Name                    | Description                                                                                          |
|-------------------------|------------------------------------------------------------------------------------------------------|
| TIMEZONE                | default: `UTC`<br>Server timezone, eg: `Asia/Shanghai`                                               |
| MEMORY_LIMIT            | PHP memory limit, eg: `100M`                                                                         |
| MAX_POST_BODY           | eg: `50M`                                                                                            |
| TYPECHO_INSTALL         | default: `0`<br>Set to `1` if you want to run installation script automatically.                      |
| TYPECHO_DB_ADAPTER      | default: `Pdo_Mysql`<br>Database driver for typecho, could be: `Pdo_Mysql`, `Pdo_SQLite`, `Pdo_Pgsql`, `Mysqli`, `SQLite`, `Pgsql`.|
| TYPECHO_DB_HOST         | default: `localhost`<br>Database server host, only available for mysql and pgsql drivers.             |
| TYPECHO_DB_PORT         | default: `3306`(for mysql) or `5432`(for pgsql)<br>Database server port, only available for mysql and pgsql drivers.|
| TYPECHO_DB_USER         | `*` required for mysql and pgsql drivers<br>Database username, only available for mysql and pgsql drivers.|
| TYPECHO_DB_PASSWORD     | `*` required for mysql and pgsql drivers<br>Database password, only available for mysql and pgsql drivers.|
| TYPECHO_DB_FILE         | `*` required for sqlite driver<br>Database file storage path, only available for sqlite driver.       |
| TYPECHO_DB_DATABASE     | `*` required for mysql and pgsql drivers<br>Database name of typecho, only available for mysql and pgsql drivers.|
| TYPECHO_DB_PREFIX       | default: `typecho_`<br>The prefix of all tables.                                                     |
| TYPECHO_DB_ENGINE       | default: `InnoDB`<br>Mysql database engine, only available for mysql driver.                          |
| TYPECHO_DB_CHARSET      | default: `utf8`(for pgsql) or `utf8mb4`(for mysql)<br>Database charset, only available for mysql and pgsql drivers.|
| TYPECHO_DB_NEXT         | default: `none`<br>The action to perform when there are already having some application tables in database.<br>* `none`: Do nothing, just exit.<br>* `keep`: Keep these tables, and skip the init step.<br>* `force`: Delete these tables, and init data again.|
| TYPECHO_SITE_URL        | `*` required<br>Your website url, for example: `https://your-domain.com`                             |
| TYPECHO_USER_NAME       | default: `typecho`<br>The admin username to create.                                                  |
| TYPECHO_USER_PASSWORD   | default: a random 8 characters string.<br>The admin password to create.                              |
| TYPECHO_USER_MAIL       | default: `admin@localhost.local`<br>The email address of admin to create.                            |

## Port

| Image Tag               | Port | Desscription                                                                                       |
|-------------------------|------|----------------------------------------------------------------------------------------------------|
| `*-fpm`                 | 9000 | FastCGI port for php-fpm.                                                                          |
| `*-apache`              | 80   | Http port for apache.                                                                              |
| `*-cli`                 |      | No port exposed.                                                                                   |

## Volume

You can mount some local directories to these container directories for persistent data.

| Container Directory     | Desscription                                                                                       |
|-------------------------|----------------------------------------------------------------------------------------------------|
| `/app/usr`              | Typecho data directory. If you mount this directory to local, the following directories will be included. |
| `/app/usr/plugins`      | Typecho plugins directory.                                                                         |
| `/app/usr/themes`       | Typecho themes directory.                                                                          |
| `/app/usr/uploads`      | Typecho uploads directory.                                                                         |
