# Rewrite requests to `/wp-.*` on subdirectory installs.
if (!-e $request_filename) {
	rewrite /wp-admin$ $scheme://$host$uri/ permanent;
	rewrite ^/[_0-9a-zA-Z-]+(/wp-.*) $1 last;
	rewrite ^/[_0-9a-zA-Z-]+(/.*\.php)$ $1 last;
}