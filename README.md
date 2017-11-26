# WordPress Nginx

This repository contains the Nginx configurations used within the series [Hosting WordPress Yourself](https://deliciousbrains.com/hosting-wordpress-setup-secure-virtual-server/). It contains best practices from various sources, including the [WordPress Codex](https://codex.wordpress.org/Nginx) and [H5BP](https://github.com/h5bp/server-configs-nginx). The following example sites are included:

* singlesite.com - WordPress single site install (no SSL or page caching)
* ssl.com - WordPress on HTTPS
* fastcgi-cache.com - WordPress with [FastCGI caching](https://deliciousbrains.com/hosting-wordpress-yourself-server-monitoring-caching/#page-cache)
* ssl-fastcgi-cache.com - WordPress on HTTPS with FastCGI caching
* multisite-subdomain.com - WordPress Multisite install using subdomains
* multisite-subdirectory.com - WordPress Multisite install using subdirectories

Looking for a modern hosting environment provisioned using Ansible? Check out [WordPress Ansible](https://github.com/A5hleyRich/wordpress-ansible).

## Usage

### PHP configuration

The php-fpm pool configuration is located in `global/php-pool.conf` and defaults to PHP 7.1.  It will need modified if you want the default php-fpm pool service to be a different PHP version.  Additional PHP version upstream definitions can be added to the `/upstreams` folder (a PHP 7.0 sample is provided there).  You can either use the default pool using `$upstream` in your nginx configurations or the specific upstream definition (i.e. php71, php70) setup by your custom upstream definitions.

For example, currently the nginx configuration for `singlesite.com` has the following set for php requests:

```
fastcgi_pass    $upstream
```

You could change that to the following to use the php 7.0 php service instead (assuming that php7.0-fpm service is running).

```
fastcgi_pass    php70
```

This effectively allows you to have different server blocks execute different versions of PHP if needed.

### Site configuration

You can use these sample configurations as reference or directly by replacing your existing nginx directory. Follow the steps below to replace your existing nginx configuration.

Backup any existing config:

`sudo mv /etc/nginx /etc/nginx.backup`

Clone the repo:

`sudo git clone https://github.com/A5hleyRich/wordpress-nginx.git /etc/nginx`

Symlink the default file from _sites-available_ to _sites-enabled_, which will setup a catch-all server block. This will ensure unrecognised domains return a 444 response.

`sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default`

Copy one of the example configurations from _sites-available_ to _sites-available/yourdomain.com_:

`sudo cp /etc/nginx/sites-available/singlesite.com /etc/nginx/sites-available/yourdomain.com`

Edit the site accordingly, paying close attention to the server name and paths.

To enable the site, symlink the configuration into the _sites-enabled_ directory:

`sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/yourdomain.com`

Test the configuration:

`sudo nginx -t`

If the configuration passes, restart Nginx:

`sudo /etc/init.d/nginx reload`

## Directory Structure

This repository has the following structure, which is based on the conventions used by a default Nginx install on Debian:

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

The following site structure is used throughout this repository:

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