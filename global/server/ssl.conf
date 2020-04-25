# Generic SSL enhancements. Use https://www.ssllabs.com/ssltest/ to test
# and recommend further improvements.

# Don't use outdated SSLv3 protocol. Protects against BEAST and POODLE attacks.
ssl_protocols TLSv1.2;

# Use secure ciphers
ssl_ciphers EECDH+CHACHA20:EECDH+AES;
ssl_ecdh_curve X25519:prime256v1:secp521r1:secp384r1;
ssl_prefer_server_ciphers on;

# Define the size of the SSL session cache in MBs.
ssl_session_cache shared:SSL:10m;

# Define the time in minutes to cache SSL sessions.
ssl_session_timeout 1h;

# Use HTTPS exclusively for 1 year, uncomment one. Second line applies to subdomains.
add_header Strict-Transport-Security "max-age=31536000;";
# add_header Strict-Transport-Security "max-age=31536000; includeSubdomains;";
