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

## Finding your logs in New Relic

Start by looking in "Logs -> All Logs." If you already have other logs feeding New Relic, you can filter by `plugin.type:"Fluent Bit"`. The default fluentbit.conf includes a "dummy" input that produces a single message. 

## Status

- Can run `cf push` and see fluentbit running with the supplied configuration
- No INPUT specified; we're just logging a dummy entry
- Test with a legit NR license key, and see logs appearing at the far side. (Single "dummy" message.) 

### TODO

- Configure the app to recognize a bound S3 bucket service in VCAP_SERVICES, and ship logs there as well
- Set the INPUT clause to be what it should be for drained logs, following [this example for fluentd](https://docs.cloudfoundry.org/devguide/services/fluentd.html#config)
- Port over all the [`datagov-logstack`](https://github.com/GSA/datagov-logstack) utility scripts for registering drains on apps/spaces
- Configure tls on the INPUT? 
- Look for and [use `https_proxy` for egress connections](https://docs.fluentbit.io/manual/administration/http-proxy). Problem here: fluent-bit supports http_proxy/HTTP_PROXY but does not support the https protocol. See  [Note: "currently only HTTP is supported."](https://github.com/fluent/fluent-bit/blob/5686334b56ee9d92f0654b0a621113943b175b94/src/flb_utils.c#L1123)
- Add tests?

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
