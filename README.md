# cg-logshipper

Drain logs from cloud.gov into S3 and New Relic Logs
## Why this project

Apps with a GSA ATO developed in GSA-TTS typically need to ship their logs to two places:

- An s3 bucket, for ingestion into the GSA SOCaaS
  - This is required by OMB Circular M-21-31, which says that system logs should be collected centrally at each agency
- New Relic Logs, for alerting purposes

To accomplish this for systems hosted on cloud.gov, the code in this repository can be deployed as an additional app in cloud.gov, then [configured as a log-drain](https://docs.cloudfoundry.org/devguide/services/log-management.html#user-provided).

## Deploying

Note: Instructions currently assume you will ship to _both_ New Relic and S3. Better configuration is TODO.

All of the following steps take place in the same cf space where the logshipper will reside.

Commands in .profile look for a specific tag in relation to the service. The names of the specific services can be unique, without impacting the `.profile`.
Current Supported Tags:
- The "newrelic-creds" user provided service = `newrelic`
- The "log-storage" s3 bucket = `logshipper-s3`
- The "cg-logshipper-creds" user provided service = `logshipper-creds`

1. Create a user-provided service "newrelic-creds" with your New Relic license key
    ```sh
    cf create-user-provided-service my-newrelic-credential-name -p '{"NEW_RELIC_LICENSE_KEY":"[your key]", "NEW_RELIC_LOGS_ENDPOINT": "[your endpoint]"}'
    ```
    NB: Use the correct NEW_RELIC_LOGS_ENDPOINT for your account. Refer to https://docs.newrelic.com/docs/logs/log-api/introduction-log-api/#endpoint

2. Create an s3 bucket "log-storage" to receive log files:
    ```sh
    cf create-service s3 basic my-s3-name
    ```

3. Create a user-provided service "cg-logshipper-creds" to provide HTTP basic auth creds. These will be provided to the logshipper by the service; you will also need to supply them to the log drain service(s) as part of the URL:
    ```sh
    cf create-user-provided-service my-logshipper-credential-name -p '{"HTTP_USER": "Some_username_you_provide", "HTTP_PASS": "Some_password"}'
    ```

4. Push the application
    ```sh
    cf push
    ```

5. Bind the services to the app (now that it exists) and restage it:
    ```sh
    cf bind-service fluentbit-drain my-newrelic-credential-name
    cf bind-service fluentbit-drain my-s3-name
    cf bind-service fluentbit-drain my-logshipper-credential-name
    cf restage fluentbit-drain
    ```

6. Check the logs to see if there were any problems
    ```sh
    cf logs fluentbit-drain --recent
    ```

7. If you are using an egress proxy, set the $HTTPS_PROXY variable. (TODO; current .profile assumes a $PROXYROUTE in the app's env)

At this point you should have a running app, but nothing is sending logs to it.

## Setting up a log drain service

Set up one or more log drain services to transmit files to the logshipper app. You will need the basic auth credentials you generated while deploying the app, as well as the URL of the fluentbit-drain app.

The log drain service should be in the space with the app(s) from which you want to collect logs. The name of the log drain service doesn't matter; "log-drain-to-fluentbit" is just an example.

The `drain-type=all` query parameter tells Cloud Foundry to send both logs and metrics, which is probably what you want. See [Cloud Foundry's log management documentation](https://docs.cloudfoundry.org/devguide/services/log-management.html#:~:text=Where%20%60DRAIN%2DTYPE%2DVALUE%60%20is%20one%20of%20the%20following%3A).

1. Set up a log drain service:
    ```sh
    cf create-user-provided-service my-logdrain-name -l 'https://${HTTP_USER}:${HTTP_PASS}@fluentbit-drain-some-random-words.app.cloud.gov/?drain-type=all'
    ```

2. Bind the log drain service to the app(s):
    ```sh
    cf bind-service hello-world-app my-logdrain-name
    cf bind-service another-app my-logdrain-name
    ```

Logs should begin to flow after a short delay. You will be able to see traffic hitting the fluent-bit app's web server. The logshipper uses New Relic's Logs API to transfer individual log entries as it processes them. For s3, it batches log entries into files that are transferred to the s3 bucket when they reach a certain size (default 50M) or when the upload timeout period (default 10 minutes) has passed.

## Status

- Can run `cf push` and see fluentbit running with the supplied configuration
- We have tested with a legit NR license key and seen logs appearing in NR.
- Input configured to accept logs from a cf log-drain service.
- Web server accepts HTTP request and proxies them to fluent-bit (using TCP).
  - Web server requires HTTP basic auth.
- Look for and use `HTTPS_PROXY` for egress connections (New Relic's plugin provides this).

### TODO

- Maybe restrict incoming traffic to cloud.gov egress ranges (52.222.122.97/32, 52.222.123.172/32)?
- Document parsing of logs, maybe add examples for parsing common formats.
- Port over all the [`datagov-logstack`](https://github.com/GSA/datagov-logstack) utility scripts for registering drains on apps/spaces
- Add tests?

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
