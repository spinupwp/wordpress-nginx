# Define path to cache and memory zone.
# keys_zone=fastcgi-cache.com:100m creates the memory zone and sets the maximum size in MBs.
# inactive=60m will remove cached items that haven't been accessed for 60 minutes or more.
fastcgi_cache_path /sites/fastcgi-cache.com/cache levels=1:2 keys_zone=fastcgi-cache.com:100m inactive=60m;

server {
	# Ports to listen on
	listen 80;

	# Server name to listen for
	server_name fastcgi-cache.com;

	# Path to document root
	root /sites/fastcgi-cache.com/public;

	# File to be used as index
	index index.php;

	# Overrides logs defined in global/logs.conf, allows per site logs.
	access_log /sites/fastcgi-cache.com/logs/access.log;
	error_log /sites/fastcgi-cache.com/logs/error.log;

	# Exclusions
	include per-site/exclusions.conf;

	# Static content
	include per-site/static-files.conf;

	# Fastcgi cache rules
	include per-site/fastcgi-cache.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		# Change socket if using PHP pools
		fastcgi_pass unix:/var/run/php5-fpm.sock;

		# Skip cache based on rules in per-site/fastcgi-cache.conf.
		fastcgi_cache_bypass $skip_cache;
		fastcgi_no_cache $skip_cache;

		# Define memory zone for caching. Should match key_zone in fastcgi_cache_path above.
		fastcgi_cache fastcgi-cache.com;

		# Define caching time.
		fastcgi_cache_valid 60m;
	}
}

# Redirect www to non-www
server {
	listen 80;
	server_name www.fastcgi-cache.com;

	return 301 $scheme://fastcgi-cache.com$request_uri;
}