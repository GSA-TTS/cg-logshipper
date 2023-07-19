#!/bin/sh

# Uses jq to:
# - extract New Relic config from VCAP_SERVICES and set env vars
# - [TODO] extract S3 bucket params from a bound service in VCAP_SERVICES and set env vars

export NEW_RELIC_LICENSE_KEY="$(echo "$VCAP_SERVICES" | jq --raw-output --arg service_name "newrelic-creds" ".[][] | select(.name == \$service_name) | .credentials.NEW_RELIC_LICENSE_KEY")"
export NEW_RELIC_LOGS_ENDPOINT="https://gov-log-api.newrelic.com/log/v1"
