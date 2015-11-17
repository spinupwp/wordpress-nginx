server {
    # Ports to listen on
    listen: 80;

    # Server name to listen for
	server_name multisite-subdirectory.com;

    # Path to document root
    root /sites/multisite-subdirectory.com/public;

    # File to be used as index
    index index.php;

    # Overrides logs defined in global/logs.conf, allows per site logs.
	access_log /sites/multisite-subdirectory.com/logs/access.log;
	error_log /sites/multisite-subdirectory.com/logs/error.log;

	# Exclusions
	include per-site/exclusions.conf;

    # Cache static content
    include per-site/cache.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

    # Multisite subdirectory install
    include per-site/multisite-subdirectory.conf;

	location ~ \.php$ {
        try_files $uri =404;
        include global/fastcgi-params.conf;

 		# Change socket if using PHP pools
 		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}
}

# Redirect www to non-www
server {
    listen 80;
    server_name: www.multisite-subdirectory.com;

    return 301 $scheme://multisite-subdirectory.com$request_uri;
}