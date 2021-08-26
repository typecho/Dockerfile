# Quick reference

* Maintained by: [Typecho Dev Team](https://github.com/typecho)
* Where to get help: [the Typecho Docker Github issues](https://github.com/typecho/Dockerfile/issues)

# Supported tags and respective `Dockerfile` links

* [nightly-php7.3, nightly-php7.3-cli, nightly-php7.3-fpm, nightly-php7.3-apache, nightly-php7.4, nightly-php7.4-cli, nightly-php7.4-fpm, nightly-php7.4-apache, nightly-php8.0, nightly-php8.0-cli, nightly-php8.0-fpm, nightly-php8.0-apache, nightly-php7.3-alpine, nightly-php7.3-cli-alpine, nightly-php7.3-fpm-alpine, nightly-php7.4-alpine, nightly-php7.4-cli-alpine, nightly-php7.4-fpm-alpine, nightly-php8.0-alpine, nightly-php8.0-cli-alpine, nightly-php8.0-fpm-alpine](https://github.com/typecho/Dockerfile)

# How to use this image

## start a typecho instance

```bash
$ docker run --name typecho-server -e TYPECHO_SITE_URL=https://your-domain.com -d joyqi/typecho:nightly-php7.4-apache
```

# How to extend this image

## Environment Variables

### `TYPECHO_DB_ADAPTER`

default: `Pdo_Mysql`

Database driver for typecho, could be: `Pdo_Mysql`, `Pdo_SQLite`, `Pdo_Pgsql`, `Mysqli`, `SQLite`, `Pgsql`.

### `TYPECHO_DB_HOST`

default: `localhost` 

Database server host, only available for mysql and pgsql drivers.

### `TYPECHO_DB_PORT`

default: `3306`(for mysql) or `5432`(for pgsql)

Database server port, only available for mysql and pgsql drivers.

### `TYPECHO_DB_USER`

`*` required for mysql and pgsql drivers

Database username, only available for mysql and pgsql drivers.

### `TYPECHO_DB_PASSWORD`

`*` required for mysql and pgsql drivers

Database password, only available for mysql and pgsql drivers.

### `TYPECHO_DB_FILE`

`*` required for sqlite driver

Database file storage path, only available for sqlite driver.

### `TYPECHO_DB_DATABASE`

`*` required for mysql and pgsql drivers

Database name of typecho, only available for mysql and pgsql drivers.

### `TYPECHO_DB_PREFIX`

default: `typecho_`

The prefix of all tables.

### `TYPECHO_DB_ENGINE`

default: `InnoDB`

Mysql database engine, only available for mysql driver.

### `TYPECHO_DB_CHARSET`

default: `utf8`(for pgsql) or `utf8mb4`(for mysql)

Database charset, only available for mysql and pgsql drivers.

### `TYPECHO_DB_NEXT`

default: `none`

The action to perform when there are already having some application tables in database.

* `none`: Do nothing, just exit.
* `keep`: Keep these tables, and skip the init step.
* `force`: Delete these tables, and init data again.

### `TYPECHO_SITE_URL`

`*` required

Your website url, for example: `https://your-domain.com`

### `TYPECHO_USER_NAME`

default: `typecho`

The admin username to create.

### `TYPECHO_USER_PASSOWRD`

default: a random 8 characters string.

The admin password to create.

### `TYPECHO_USER_MAIL`

default: `admin@localhost.local`

The email address of admin to create.

## Port

### FPM Image

You can expose fastcgi port `9000` for those image tags who have suffix with `*-fpm`.

```bash
$ docker run --name typecho-server -p 9000:9000 -e TYPECHO_SITE_URL=https://your-domain.com -d joyqi/typecho:nightly-php7.4-fpm
```

### Apache Image

You can expose http port `80` for those image tags who have suffix with `*-apache`.

```bash
$ docker run --name typecho-server -p 8080:80 -e TYPECHO_SITE_URL=https://your-domain.com -d joyqi/typecho:nightly-php7.4-apache
```

## Volume

```bash
$ docker run --name typecho-server -v /var/typecho:/app/usr -e TYPECHO_SITE_URL=https://your-domain.com -d joyqi/typecho:nightly-php7.4
```