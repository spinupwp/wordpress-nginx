# WordPress Nginx

This config kit contains the Nginx configurations used in the [Install WordPress on Ubuntu 24.04](https://spinupwp.com/install-wordpress-ubuntu/) guide. It contains best practices from various sources, including the [WordPress Developer Resources](https://developer.wordpress.org/advanced-administration/server/web-server/nginx/) and [H5BP](https://github.com/h5bp/server-configs-nginx). The following example sites are included:

* [multisite-subdirectory.com](sites-available/multisite-subdirectory.com) - WordPress multisite install using subdirectories
* [multisite-subdomain.com](sites-available/multisite-subdomain.com) - WordPress multisite install using subdomains
* [single-site.com](sites-available/single-site.com) - WordPress single site install
* [single-site-with-caching.com](sites-available/single-site-with-caching.com) - WordPress single site install with FastCGI caching

## Usage

### Site configuration

You can use these sample configurations as reference or directly by replacing your existing nginx directory. Follow the steps below to replace your existing Nginx configuration.

Backup any existing config:

`sudo mv /etc/nginx /etc/nginx.backup`

Copy these configs to `/etc/nginx`.

Symlink the default file from _sites-available_ to _sites-enabled_, which will setup a catch-all server block. This will ensure unrecognised domains return a 444 response.

`sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default`

Copy one of the example configurations from _sites-available_ to _sites-available/yourdomain.com_:

`sudo cp /etc/nginx/sites-available/single-site.com /etc/nginx/sites-available/yourdomain.com`

Edit the site accordingly, paying close attention to the server name and paths.

To enable the site, symlink the configuration into the _sites-enabled_ directory:

`sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/yourdomain.com`

Test the configuration:

`sudo nginx -t`

If the configuration passes, restart Nginx:

`sudo systemctl reload nginx.service`

### PHP configuration

The php-fpm pool configuration is located in `global/php-pool.conf` and defaults to PHP 8.3. It will need modifying if you want the default php-fpm pool service to be a different PHP version. Additional PHP version upstream definitions can be added to the `/upstreams` folder (a PHP 8.4 sample is provided there). You can either use the default pool using `$upstream` in your nginx configurations or the specific upstream definition (i.e. php84) setup by your custom upstream definitions.

For example, currently the nginx configuration for `single-site.com` has the following set for php requests:

```
fastcgi_pass    $upstream
```

You could change that to the following to use the php 8.4 PHP service instead (assuming that php8.4-fpm service is running).

```
fastcgi_pass    php84
```

This effectively allows you to have different server blocks execute different versions of PHP if needed.

## Directory Structure

This config kit has the following structure, which is based on the conventions used by a default Nginx install on Debian:

```
.
├── conf.d
├── global
    └── server
├── sites-available
├── sites-enabled
```

__conf.d__ - configurations for additional modules.

__global__ - configurations within the `http` block.

__global/server__ - configurations within the `server` block. The `defaults.conf` file should be included on the majority of sites, which contains sensible defaults for caching, file exclusions and security. Additional `.conf` files can be included as needed on a per-site basis.

__sites-available__ - configurations for individual sites (virtual hosts).

__sites-enabled__ - symlinks to configurations within the `sites-available` directory. Only sites which have been symlinked are loaded.

### Recommended Site Structure

The following site structure is used throughout these configs:

```
.
├── yourdomain1.com
    └── cache
    └── logs
    └── public
├── yourdomain2.com
    └── cache
    └── logs
    └── public
```
