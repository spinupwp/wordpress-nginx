server {
	# Ports to listen on
	listen 80;
	listen [::]:80;

	# Server name to listen for
	server_name single-site-no-ssl.com;

	# Path to document root
	root /sites/single-site-no-ssl.com/public;

	# File to be used as index
	index index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/single-site-no-ssl.com/logs/access.log;
	error_log /sites/single-site-no-ssl.com/logs/error.log;

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
}

# Redirect www to non-www
server {
	listen 80;
	listen [::]:80;
	server_name www.single-site-no-ssl.com;

	return 301 $scheme://single-site-no-ssl.com$request_uri;
}