---
# SECRETS DIRECTORY
# A directory with very tight permissions to store secrets.  At present there will only be one subdirectory created,
# certbot/ which will be used for storing Certbot secrets.
secrets_dir:
  file.directory:
    - name: /root/.secrets
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600

# CERTBOT DIRECTORY
# Secrets for Certbot, the autonomous TLS certificate deployment tool.  Permissions for this directory are similarly
# very tight because of the sensitive data being stored.
certbot_dir:
  file.directory:
    - name: /root/.secrets/certbot
    - user: root
    - group: root
    - dir_mode: 700
    - file_mode: 600
    - require:
      - file: secrets_dir

{%- set dns_credentials = salt['pillar.get']('letsencrypt:dns_credentials') %}
{%- set testing = salt['pillar.get']('testing') %}

# CLOUDFLARE SECRETS FILE
# CloudFlare API secrets for use by the Certbot CloudFlare DNS plugin.  At present, the package in the Ubuntu
# repositories is old and doesn't support the use of an API token.  When this is updated, the email and API key will not
# need to specified (only the API token).
cloudflare_ini:
  file.managed:
    - name: /root/.secrets/certbot/cloudflare.ini
    - user: root
    - group: root
    - mode: 600
    - require:
      - file: certbot_dir
    - template: jinja
    - contents: |
        # Cloudflare API credentials used by Certbot
        dns_cloudflare_email = {{ dns_credentials.email }}
        dns_cloudflare_api_key = {{ dns_credentials.api_key }}

        # # Cloudflare API token used by Certbot
        # dns_cloudflare_api_token = {{ dns_credentials.api_token }}

# DEPLOY PAGES TLS CERTIFICATE
# Let's Encrypt only permits wildcard certificates when using DNS verification (as this is the only way to ensure you
# have full control over the domain).  As such, GitLab cannot automatically deploy certificates because it doesn't
# currently support DNS verification.
pages_cert:
  acme.cert:
    - name: pages.dylanwilson.dev
    - aliases:
      - "*.pages.dylanwilson.dev"
    - email: webmaster@dylanw.net
    - dns_plugin: cloudflare
    - dns_plugin_credentials: /root/.secrets/certbot/cloudflare.ini
    {% if testing %}
    - server: https://acme-staging-v02.api.letsencrypt.org/directory
    {% endif %}
    - require:
      - file: cloudflare_ini
