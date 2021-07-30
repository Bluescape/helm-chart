# Add new grafana dashboards

NOTE: You must helm version 3.x

## Manual Addition

This part is purposefully sparse but enough is given to give the reader a sufficient overview
of the process.

 * export dashboard JSON from grafana dashboard using the export tool
   * make sure "Export for sharing external externally" is not set to on
 * save the JSON somewhere well-known on your laptop/computer
 * use the templates in `<repo>/helm-charts/helm-chart-sources/bluescape-monitoring-dashboards/templates/0_template`
   * create a new dashboard directory in `<repo>/helm-charts/helm-chart-sources/bluescape-monitoring-dashboards/templates`
   * within that newly created directory, copy the templates from `0_template`.
   * chdir to the new directory
   * put the exported JSON in the `configmap.yaml` using the example data
     provided in the `configmap.yaml` template
   * update the necessary fields in `configmap.yaml`
 * fix the necessary fields in `dashboard.yaml`

Jump down to verify dashboards below.

## Automatic Addition

These instructions cover how to use the `add_dashboard` script located
in `<repo>/helm-charts/helm-chart-sources/bluescape-monitoring-dashboards`

### Pre-requisites

The following are necessary in order for this script to function
properly:

  * yaml2json
  * json2yaml
  * jq
  * gnu sed
  * gnu grep

### Synopsis

This script must be run from this directory. It will verify as much
and if it isn't in the proper directory then it will exit with an error


```
Usage: ./add_dashboard <path/to/exported/dashboard.json> <new_dashboard_directory>

```

The first argument is the path to the exported JSON from grafana.

The second argument is the name of the dashboard directory into which
the new configmap and dashboard manifests will be placed. This argument requires
pathing. A simple name such as `65_dashboard_name` is sufficient.

### Example

```
$ cd <repo>/helm-charts/helm-chart-sources/bluescape-monitoring-dashboards
./add_dashboard $HOME/Downloads/Redis.json 44_redis_dashboard
```

### Validations performed at runtime

A cursory check of the following is performed at runtime:

  * the script is running from the expected directory
  * the JSON imported will have `__inputs` and `__requires` removed
  * the dashboard JSON is valid JSON
  * pre-requisite binaries are on the running machine

Note that any gotmpls (go templating) in the JSON will be fixed so that helm will
not interpolate them (IE it will error on run).

#### yaml2json and json2yaml

These scripts are in [ops scripts repo][1] and require ruby installed on
your laptop. Most OSes will automatically have a proper Ruby interpreter installed.

## Verify Dashboards

Validate the configmap:

```
cat 44_redis_dashboard/configmap.yaml
```

Validate the dashboard manifest:

```
cat 44_redis_dashboard/dashboad.yaml
```

### Lint validation

```
$ cd <repo>/helm-charts/helm-chart-sources
$ helm template ./bluescape-monitoring-dashboards | yamllint -
```

You should get no errors from `yamllint` and you should get no errors
from `helm`.

This check is also mildly a good chart check.

### Chart validation

The following will perform a dry-run of the chart.

```
# for good practice you should make sure you're using the correct cluster
# on which to test!
# use your favorite method...
$ kctx atreus
Switched to context "arn:aws:eks:us-west-2:429863676324:cluster/atreus".

$ cd <repo>/helm-charts/helm-chart-sources
$ helm upgrade --install grafana-dashboards-a-atreus bluescape-monitoring-dashboards -n grafana --dry-run
```

This should give a lot of useful output and no errors.

Now install the chart in a test cluster. We'll continue to use Atreus.

```
$ kctx atreus
Switched to context "arn:aws:eks:us-west-2:429863676324:cluster/atreus".

$ cd <repo>/helm-charts/helm-chart-sources
$ helm upgrade --install grafana-dashboards-a-atreus bluescape-monitoring-dashboards -n grafana
```

This should not fail. Once this completes, login to grafana on the test cluster
and verify your dashboards:

 #. installed
 #. work properly.

if the dashboards need tweaking, wash, rinse, repeat. Once all is working, push a
commit and PR the push to this repo.

## commit, push, and PR

### Chart.yaml version bump

Update/bump the versions of the `Chart.yaml` (in this directory). The `Chart.yaml` contains
decent comments about the version bump. It's sufficient to just bump the minor. The comments
state that semver is not being used, however the versions themselves seem to follow a semver
convention, which is likely sufficient for the bump.

### commit and push

Make sure you're doing work in a feature branch! When all is done and tested, commit the
branch and push. Create a pull request. The Infra team is the owner of this repo. Only they
can merge PRs. Make sure you've properly tested everything before creating the PR and request
a merge.

## Notes

This script should function properly on Linux and Darwin

[1]:https://github.com/Bluescape/ops/tree/develop/scripts
