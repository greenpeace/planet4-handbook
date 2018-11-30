#!/usr/bin/env bash
set -euo pipefail

# First parameter is name of script to execute in the PHP pod
shift

php=$(kubectl get pods --namespace "${HELM_NAMESPACE}" \
  --sort-by=.metadata.creationTimestamp \
  --field-selector=status.phase=Running \
  -l "app=wordpress-php,release=${HELM_RELEASE}" \
  -o jsonpath="{.items[-1:].metadata.name}")

if [[ -z "$php" ]]
then
  >&2 echo "ERROR: php pod not found in release ${HELM_RELEASE}"
  exit 1
fi

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/themes/planet4-master-theme/languages" translations/planet4-master-theme/languages/

git config --global user.email "circleci-bot@greenpeace.org"
git config --global user.name "CircleCI Bot"
git config --global push.default simple


git clone git@github.com:greenpeace/planet4-master-theme.git gitrepos/planet4-master-theme -b languages || true

rm -f translations/planet4-master-theme/languages/*.po~

cp translations/planet4-master-theme/languages/ gitrepos/planet4-master-theme/ -r

git -C gitrepos/planet4-master-theme add languages/*

git -C gitrepos/planet4-master-theme commit -m "Autocommit - Language files" || true

git -C gitrepos/planet4-master-theme push

