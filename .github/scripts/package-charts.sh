#!/bin/bash

set -eo pipefail

BASE_PATH='helm-chart-sources'
BLSC_HELM_URL='https://bluescape.github.io/helm-charts/packages/.'

find_chart_sources()
{
  say '  Finding and packaging chart sources...'
  find "$BASE_PATH"/ -maxdepth 1 -type d -exec helm package -ud packages/ {} \;
}

generate_index()
{
  say '  Generating index...'
  helm repo index --url "$BLSC_HELM_URL" packages/
}

mv_index()
{
  say '  Moving index.yaml from build location to repo root'
  mv packages/index.yaml .
}

index_charts()
{
  say 'Indexing charts...'
  find_chart_sources
  generate_index
  mv_index
}

say()
{
  echo >&2 "$*"
}

main()
{
  index_charts
}

main
