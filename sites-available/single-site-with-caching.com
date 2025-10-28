# Define path to cache and memory zone. The memory zone should be unique.
# keys_zone=single-site-with-caching.com:100m creates the memory zone and sets the maximum size in MBs.
# inactive=60m will remove cached items that haven't been accessed for 60 minutes or more.
fastcgi_cache_path /sites/single-site-with-caching.com/cache levels=1:2 keys_zone=single-site-with-caching.com:100m inactive=60m;

server {
	# Ports to listen on
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;

	# Server name to listen for
	server_name single-site-with-caching.com;

	# Path to document root
	root /sites/single-site-with-caching.com/public;

	# Paths to certificate files.
	ssl_certificate /etc/letsencrypt/live/single-site-with-caching.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/single-site-with-caching.com/privkey.pem;

	# File to be used as index
	index index.html index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/single-site-with-caching.com/logs/access.log;
	error_log /sites/single-site-with-caching.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	# Fastcgi cache rules
	include global/server/fastcgi-cache.conf;

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

		# Skip cache based on rules in global/server/fastcgi-cache.conf.
		fastcgi_cache_bypass $skip_cache;
		fastcgi_no_cache $skip_cache;

		# Define memory zone for caching. Should match key_zone in fastcgi_cache_path above.
		fastcgi_cache single-site-with-caching.com;

		# Define caching time.
		fastcgi_cache_valid 200 301 60m;
	}
}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name single-site-with-caching.com www.single-site-with-caching.com;

	return 301 https://single-site-with-caching.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	listen 443 quic;
	listen [::]:443 quic;
	http2 on;
	
	server_name www.single-site-with-caching.com;

	# Advertises support for HTTP/3
	add_header Alt-Svc 'h3=":443"; ma=86400';

	return 301 https://single-site-with-caching.com$request_uri;
}