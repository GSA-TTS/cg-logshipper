#!/bin/sh

# Uses jq to:
# - extract New Relic config from VCAP_SERVICES and set env vars
# - [TODO] extract S3 bucket params from a bound service in VCAP_SERVICES and set env vars
# - Save user/password for HTTP auth to a file for nginx basic auth.

export NEW_RELIC_LICENSE_KEY="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "newrelic-creds" ".[][] | select(.name == \$service_name) | .credentials.NEW_RELIC_LICENSE_KEY")"
export NEW_RELIC_LOGS_ENDPOINT="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "newrelic-creds" ".[][] | select(.name == \$service_name) | .credentials.NEW_RELIC_LOGS_ENDPOINT")"

HTTP_USER="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "cg-logshipper-creds" ".[][] | select(.name == \$service_name) | .credentials.HTTP_USER")"
HTTP_PASS="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "cg-logshipper-creds" ".[][] | select(.name == \$service_name) | .credentials.HTTP_PASS")"
HTTP_PASS_CRYPT="$(openssl passwd ${HTTP_PASS})"
echo "${HTTP_USER}:${HTTP_PASS_CRYPT}" > /home/vcap/app/http_creds
chmod 600 /home/vcap/app/http_creds

# Add HTTPS_PROXY (example):
export HTTPS_PROXY=$PROXYROUTE
