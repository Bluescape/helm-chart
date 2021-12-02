#!/bin/bash

set -eo pipefail

# See which files have changed in this commit
#changed_chart_files=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD origin/main) -- helm-chart-sources )
# git --no-pager diff --stat=300 --compact-summary "$(git merge-base HEAD origin/main)" HEAD -- helm-chart-sources | \
#    awk -F '|' '{print $1}' | \
#    perl -lpe 's#helm-chart-sources/(.*?)/(.*).*\((new|gone)\)?.*#\1^\2^\3#g'
#changed_chart="$(git --no-pager diff --compact-summary "$(git merge-base HEAD origin/main)" HEAD -- helm-chart-sources | \
#                       grep -Pv '(gone)' | \
#                       grep -iv 'files changed')"
#echo "Changed chart files: $changed_chart_files"

declare -a all_charts

BASE_PATH='helm-chart-sources'
gitdiff=''
newdiff=''
deleteddiff=''


# Create a temporary directory to store new package changes in
mkdir -p .tmp/packages

chart_exists()
{
  echo "${all_charts[*]}" | grep -q "$chart"
}

# performs a git diff and grabs everything
git_diff_all()
{
  git --no-pager diff --stat=300 --compact-summary \
    "$(git merge-base HEAD origin/main)" HEAD -- helm-chart-sources
}

# get and store git diff for this commit
store_git_diff()
{
  gitdiff=$(git_diff_all)
  newdiff="$(git diff --name-only --diff-filter=A "$(git merge-base HEAD origin/main)" HEAD -- helm-chart-sources)"
  deleteddiff="$(git diff --name-only --diff-filter=D "$(git merge-base HEAD origin/main)" HEAD -- helm-chart-sources)"
}

uniq_charts_from_gitdiff()
{
  gitlist="$1"
  all_charts=()

  while IFS='/' read -r _ chart _; do
    [[ -z "$chart" ]] && continue
    if ! chart_exists; then
      say "...found chart: $chart"
      all_charts+=("$chart")
    fi
  done <<<"${gitlist[*]}"
}

extract_chart_name()
{
  yq -Mr .name "$BASE_PATH/$repo/Chart.yaml"
}

delete_entry()
{
  chart_name="$(extract_chart_name "$1")"

  # such a hack...but unfortunately, I believe I've found a bug
  # in jq thus this hack.
  #yq --arg chart "$chart_name" -Mr -Y 'del(.[$chart]?)' index.yaml > new-index.yaml
  yq -Mr -Y 'del(.entries."'"$chart_name"'")' index.yaml > new-index.yaml
  say "   extracted chart name from '$repo': '$chart_name'"
  if ! diff -q index.yaml new-index.yaml >/dev/null 2>&1; then
    # might want to make this a better, more bulletproof method of validating
    # the specific entry is deleted...
    mv new-index.yaml index.yaml
    echo '... entry successfully removed.'
    return 0
  fi
  return 1
}

remove_deleted_charts_from_repo()
{
  say "Seeking out deleted charts in this commit..."
  uniq_charts_from_gitdiff "$deleteddiff"

  for repo in "${all_charts[@]}"; do
    echo " Verifying that chart directory '$repo' is non-existent..."
    if [[ ! -d "$BASE_PATH/$repo" ]]; then
      # temporary checkout of deleted Chart.yaml to extract name of chart.
      git checkout origin/main -- "$BASE_PATH/$repo/Chart.yaml"
      say "  will delete chart '$repo' from index.yaml"
      if delete_entry "$repo"; then
        rm -rf "${BASE_PATH:?}/$repo"
        git restore --staged "${BASE_PATH:?}/$repo"
      fi
    fi
  done
}

add_new_charts_from_repo()
{
  say "Seeking out new charts in this commit..."
  uniq_charts_from_gitdiff "$newdiff"

  for repo in "${all_charts[@]}"; do
    chart="$BASE_PATH/$repo"
    say " Creating new package for: $chart"
    helm package -u -d .tmp/packages "$chart"
  done
}

generate_helm_index()
{
  echo Generating new index
  helm repo index --url https://bluescape.github.io/helm-charts/. --merge index.yaml .tmp

  echo Moving .tmp packages to packages...
  find .tmp/ -name '*.tgz' -print0 -exec mv {} packages/ \;

  echo Moving the new merged index to overwrite the old one...
  if [[ -f .tmp/index.yaml ]]; then
    mv .tmp/index.yaml index.yaml
  fi

  rm -rf .tmp
}

say()
{
  echo >&2 "$*"
}

main()
{
  store_git_diff
  remove_deleted_charts_from_repo
  add_new_charts_from_repo
  generate_helm_index
}

main
