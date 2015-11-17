# WordPress Nginx

Nginx configuration geared towards hosting WordPress sites. Contains best practices from various sources, including the [WordPress Codex](https://codex.wordpress.org/Nginx) and [H5BP](https://github.com/h5bp/server-configs-nginx). The following example sites are included:

* singlesite.com - WordPress single site install (no SSL or page caching)
* ssl.com - WordPress on HTTPS
* fastcgi-cache.com - WordPress with [FastCGI caching](https://deliciousbrains.com/hosting-wordpress-yourself-server-monitoring-caching/#page-cache)
* multisite-subdomain.com - WordPress Multisite install using subdomains
* multisite-subdirectory.com - WordPress Multisite install using subdirectories

## Usage

You can use these sample configurations as reference or directly by replacing your existing nginx directory. Follow the steps below to replace your existing nginx configuration.

Backup any existing config:

`sudo mv /etc/nginx /etc/nginx.backup`

Clone the repo:

`sudo git clone https://github.com/A5hleyRich/wordpress-nginx.git /etc/nginx`

Symlink the default file from _sites-available_ to _sites-enabled_, which will setup a catch-all server block. This will ensure unrecognised domains return a 444 response.

`sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default`

Copy one of the example configurations from _sites-available_ to _sites-available/yourdomain.com_:

sudo cp /etc/nginx/sites-available/singlesite.com /etc/nginx/sites-available/yourdomain.com`

Edit the site accordingly, paying close attention to the server name and paths.

To enable the site, symlink the configuration into the _sites-enabled_ directory:

`sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/yourdomain.com`

Test the configuration:

`sudo nginx -t`

If the configuration passes, restart Nginx:

`sudo /etc/init.d/nginx reload`