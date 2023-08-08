#!/bin/sh

# Uses jq to:
# - extract New Relic config from VCAP_SERVICES and set env vars
# - [TODO] extract S3 bucket params from a bound service in VCAP_SERVICES and set env vars

export NEW_RELIC_LICENSE_KEY="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "newrelic-creds" ".[][] | select(.name == \$service_name) | .credentials.NEW_RELIC_LICENSE_KEY")"
export NEW_RELIC_LOGS_ENDPOINT="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "newrelic-creds" ".[][] | select(.name == \$service_name) | .credentials.NEW_RELIC_LOGS_ENDPOINT")"

# Add HTTPS_PROXY (example):
export HTTPS_PROXY=$PROXYROUTE

# Include certs for proxy (turned out not to be needed for New Relic output plugin):
# export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
# export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
