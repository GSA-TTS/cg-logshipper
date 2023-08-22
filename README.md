# cg-logshipper

Drain logs from cloud.gov into S3 and New Relic Logs
## Why this project

Apps with a GSA ATO developed in GSA-TTS typically need to ship their logs to two places:

- An s3 bucket, for ingestion into the GSA SOCaaS
  - This is required by OMB Circular M-21-31, which says that system logs should be collected centrally at each agency
- New Relic Logs, for alerting purposes

To accomplish this for systems hosted on cloud.gov, the code in this repository can be deployed as an additional app in cloud.gov, then [configured as a log-drain](https://docs.cloudfoundry.org/devguide/services/log-management.html#user-provided).

## Deploying

1. Create a user-provided service with your New Relic license key
    ```sh
    cf create-user-provided-service newrelic-creds -p '{"NEW_RELIC_LICENSE_KEY":"[your key]", "NEW_RELIC_LOGS_ENDPOINT": "[your endpoint]"}'
    ```
    NB: Use the correct NEW_RELIC_LOGS_ENDPOINT for your account. Refer to https://docs.newrelic.com/docs/logs/log-api/introduction-log-api/#endpoint

2. Push the application
    ```sh
    cf push
    ```
3. Check the logs to see if there were any problems
    ```sh
    cf logs fluentbit-drain --recent
    ```

## Status

- Can run `cf push` and see fluentbit running with the supplied configuration
- We have tested with a legit NR license key and seen logs appearing in NR.
- Input configured to accept logs from a cf log-drain service.
- Look for and use `HTTPS_PROXY` for egress connections (New Relic's plugin provides this) 

### TODO

- Improve the parsing of logs, to send appropriately structured data forward. 
- Configure the app to recognize a bound S3 bucket service in VCAP_SERVICES, and ship logs there as well
- Port over all the [`datagov-logstack`](https://github.com/GSA/datagov-logstack) utility scripts for registering drains on apps/spaces
- Restrict incoming traffic (by credentials if possible). 

- Add tests?

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
