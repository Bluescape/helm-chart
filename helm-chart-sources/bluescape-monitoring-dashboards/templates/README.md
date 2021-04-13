# Add new grafana dashboards

This script must be run from this directory. It will verify as much
and if it isn't int he proper directory then it will exit with an error

## Using add_dashboard script

```
Usage: ./add_dashboard <path/to/exported/dashboard.json> <new_dashboard_directory>

```


## Example

```
./add_dashboard $HOME/Downloads/Redis.json 44_redis_dashboard
```

## Verify

Validate the configmap:

```
cat 44_redis_dashboard/configmap.yaml
```

Validate the dashboard manifest:

```
cat 44_redis_dashboard/dashboad.yaml
```
## Validations

A cursory check is performed validating:

  #. the script is running from the expected directory
  #. the dashboard JSON is valid JSON
  #. pre-requisite binaries are on the running machine

## Pre-requisite binaries

The following are necessary in order for this script to function
properly:

  * yaml2json
  * json2yaml
  * jq
  * gnu sed
  * gnu grep


## Notes

This script should function properly on Linux and Darwin

## yaml2json and json2yaml

These scripts are in [1][ops scripts repo] and require ruby installed on
your laptop.


[1]:https://github.com/Bluescape/ops/tree/develop/scripts
