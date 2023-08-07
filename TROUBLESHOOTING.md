# Troubleshooting

## New Relic (nrlogs)

### TODO: replace with "newrelic" examples

These examples use the default "dummy" input and the "nrlogs" output in fluentbit.conf, with  `log_level info`.

Follow the instructions in README.md to push the app and display the logs.

You can get the full set of options for the nrlogs plugin by running this command:

  `/home/vcap/deps/0/apt/opt/fluent-bit/bin/fluent-bit -o nrlogs -h`

### Success
A successful startup for output to New Relic will show messages like this:

```
   2023-07-21T16:04:30.85-0700 [CELL/0] OUT Downloaded droplet (28.6M)
   2023-07-21T16:04:30.99-0700 [APP/PROC/WEB/0] ERR Fluent Bit v2.1.7
   [ ... ]
   2023-07-21T16:04:30.99-0700 [APP/PROC/WEB/0] ERR [2023/07/21 23:04:30] [ info] [input:dummy:dummy.0] initializing
   2023-07-21T16:04:30.99-0700 [APP/PROC/WEB/0] ERR [2023/07/21 23:04:30] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
   2023-07-21T16:04:31.00-0700 [APP/PROC/WEB/0] ERR [2023/07/21 23:04:30] [ info] [output:nrlogs:nrlogs.0] configured, hostname=gov-log-api.newrelic.com:443
   2023-07-21T16:04:31.00-0700 [APP/PROC/WEB/0] ERR [2023/07/21 23:04:30] [ info] [sp] stream processor started
   2023-07-21T16:04:32.94-0700 [APP/PROC/WEB/0] ERR [2023/07/21 23:04:32] [ info] [output:nrlogs:nrlogs.0] gov-log-api.newrelic.com:443, HTTP status=202
   2023-07-21T16:04:32.94-0700 [APP/PROC/WEB/0] ERR {"requestId":"8f7fe1fb-0001-bdd4-0651-01897ab29b7d"}
   2023-07-21T16:04:33.22-0700 [CELL/SSHD/0] OUT Exit status 0
```

Specifically, you should see:
* `[output:nrlogs:nrlogs.0] gov-log-api.newrelic.com:443, HTTP status=202`

### Malformed Endpoint URL
In this example, the NEW_RELIC_LOGS_ENDPOINT was specified incorrectly (Just the host and port were included. It should be a full URL including the /logs/v1 path.)

```
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR Fluent Bit v2.1.7
   [ ... ]
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [ info] [input:dummy:dummy.0] initializing
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [error] [output:nrlogs:nrlogs.0] error parsing base_uri 'gov-log-api.newrelic.com:443'
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [error] [output:nrlogs:nrlogs.0] cannot initialize configuration
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [error] [output] failed to initialize 'nrlogs' plugin
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [error] [engine] output initialization failed
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [ info] [input] pausing dummy.0
   2023-07-21T15:52:34.91-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:52:34] [error] [lib] backend failed
   2023-07-21T15:52:34.93-0700 [APP/PROC/WEB/0] OUT Exit status 255
```

The key messages here are:
* `[error] [output:nrlogs:nrlogs.0] error parsing base_uri 'gov-log-api.newrelic.com:443'`
* `[error] [output] failed to initialize 'nrlogs' plugin`

### "No upstream connections available"
"No upstream connections available" indicates inability to connect to the endpoint. (Check whether the "hostname" listed a couple of lines above looks right.) If you are testing in a sandbox space, you must [bind the `public_networks_egress` security group to your space](https://cloud.gov/docs/management/space-egress/#managing-egress-settings-for-your-org-or-space) so traffic can get out. In a non-sandbox space, you should probably be running this app in a space with restricted egress and specify `https_proxy` to reach an egress proxy (see https://github.com/GSA-TTS/cg-egress-proxy).

```
   2023-07-21T15:41:03.68-0700 [APP/PROC/WEB/0] ERR Fluent Bit v2.1.7
   [ ... ]
   2023-07-21T15:41:03.68-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:03] [ info] [input:dummy:dummy.0] initializing
   2023-07-21T15:41:03.68-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:03] [ info] [input:dummy:dummy.0] storage_strategy='memory' (memory only)
   2023-07-21T15:41:03.68-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:03] [ info] [output:nrlogs:nrlogs.0] configured, hostname=gov-log-api.newrelic.com:443
   2023-07-21T15:41:03.68-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:03] [ info] [sp] stream processor started
   2023-07-21T15:41:05.36-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:05] [error] [output:nrlogs:nrlogs.0] no upstream connections available
   2023-07-21T15:41:05.36-0700 [APP/PROC/WEB/0] ERR [2023/07/21 22:41:05] [ warn] [engine] failed to flush chunk '54-1689979264.364652547.flb', retry in 8 seconds: task_id=0, input=dummy.0 > output=nrlogs.0 (out_id=0)
   2023-07-21T15:41:05.72-0700 [CELL/SSHD/0] OUT Exit status 0
```

Key message:
* `[output:nrlogs:nrlogs.0] no upstream connections available`