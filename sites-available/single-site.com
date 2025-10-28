server {
	# Ports to listen on
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;

	# Server name to listen for
	server_name single-site.com;

	# Path to document root
	root /sites/single-site.com/public;

	# Paths to certificate files.
	ssl_certificate /etc/letsencrypt/live/single-site.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/single-site.com/privkey.pem;

	# File to be used as index
	index index.html index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/single-site.com/logs/access.log;
	error_log /sites/single-site.com/logs/error.log;

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
	server_name single-site.com www.single-site.com;

	return 301 https://single-site.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;
	
	server_name www.single-site.com;

	# Advertises support for HTTP/3
	add_header Alt-Svc 'h3=":443"; ma=86400';

	return 301 https://single-site.com$request_uri;
}
