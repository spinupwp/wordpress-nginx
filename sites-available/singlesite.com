server {
	# Ports to listen on
	listen 80;
	listen [::]:80;

	# Server name to listen for
	server_name singlesite.com;

	# Path to document root
	root /sites/singlesite.com/public;

	# File to be used as index
	index index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/singlesite.com/logs/access.log;
	error_log /sites/singlesite.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		# Use the php pool defined in the upstream variable.
		# See global/php-pool.conf for definition.
		fastcgi_pass   $upstream;
	}

	# Rewrite robots.txt
	rewrite ^/robots.txt$ /index.php last;
}

# Redirect www to non-www
server {
	listen 80;
	listen [::]:80;
	server_name www.singlesite.com;

	return 301 $scheme://singlesite.com$request_uri;
}