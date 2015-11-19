# Enable Gzip compression.
gzip on;

# Disable Gzip on IE6.
gzip_disable "msie6";

# Allow proxies to cache both compressed and regular version of file.
# Avoids clients that don't support Gzip outputting gibberish.
gzip_vary on;

# Compress data, even when the client connects through a proxy.
gzip_proxied any;

# The level of compression to apply to files. A higher compression level increases
# CPU usage. Level 5 is a happy medium resulting in roughly 75% compression.
gzip_comp_level 5;

# The minimum HTTP version of a request to perform compression.
gzip_http_version 1.1;

# Don't compress files smaller than 256 bytes, as size reduction will be negligible.
gzip_min_length 256;

# Compress the following MIME types.
gzip_types
	application/atom+xml
	application/javascript
	application/json
	application/ld+json
	application/manifest+json
	application/rss+xml
	application/vnd.geo+json
	application/vnd.ms-fontobject
	application/x-font-ttf
	application/x-web-app-manifest+json
	application/xhtml+xml
	application/xml
	font/opentype
	image/bmp
	image/svg+xml
	image/x-icon
	text/cache-manifest
	text/css
	text/plain
	text/vcard
	text/vnd.rim.location.xloc
	text/vtt
	text/x-component
	text/x-cross-domain-policy;
  # text/html is always compressed when enabled.