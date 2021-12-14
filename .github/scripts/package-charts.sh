#!/bin/bash

set -eo pipefail

BASE_PATH='helm-chart-sources'
BLSC_HELM_URL='https://bluescape.github.io/helm-charts/packages/.'

find_chart_sources()
{
  say '  Finding and packaging chart sources...'
  if ! pushd "$BASE_PATH/" >/dev/null; then
    say "Not able to chdir to $BASE_PATH/"
    return 1
  fi

  find . -maxdepth 1 -type d -print -exec helm package -ud ../packages/ {} \;
  if ! popd >/dev/null; then
    say "Not able to chdir up one from $BASE_PATH/"
    return 1
  fi
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
