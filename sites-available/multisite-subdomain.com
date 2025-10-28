server {
	# Ports to listen on
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;

	# Server name to listen for
	server_name multisite-subdomain.com *.multisite-subdomain.com;

	# Path to document root
	root /sites/multisite-subdomain.com/public;

	# Paths to certificate files.
	ssl_certificate /etc/letsencrypt/live/multisite-subdomain.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/multisite-subdomain.com/privkey.pem;

	# File to be used as index
	index index.html index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/multisite-subdomain.com/logs/access.log;
	error_log /sites/multisite-subdomain.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	# SSL rules
	include global/server/ssl.conf;

	# Advertises support for HTTP/3
	add_header Alt-Svc 'h3=":443"; ma=86400';

	location / {
		try_files $uri $uri/ /index.php$is_args$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		# Use the php pool defined in the upstream variable.
		# See global/php-pool.conf for definition.
		fastcgi_pass   $upstream;
	}
}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name multisite-subdomain.com *.multisite-subdomain.com;

	return 301 https://$host$request_uri;
}

# Redirect www to non-www
server {
	listen 80;
	listen [::]:80;
	server_name www.multisite-subdomain.com;

	return 301 $scheme://multisite-subdomain.com$request_uri;
}