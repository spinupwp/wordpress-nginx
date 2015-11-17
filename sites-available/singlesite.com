server {
    # Ports to listen on
    listen: 80;

    # Server name to listen for
	server_name singlesite.com;

    # Path to document root
    root /sites/singlesite.com/public;

    # File to be used as index
    index index.php;

    # Overrides logs defined in global/logs.conf, allows per site logs.
	access_log /sites/singlesite.com/logs/access.log;
	error_log /sites/singlesite.com/logs/error.log;

	# Exclusions
	include per-site/exclusions.conf;

	# Cache static content
    include per-site/cache.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

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
    server_name: www.singlesite.com;

    return 301 $scheme://singlesite.com$request_uri;
}