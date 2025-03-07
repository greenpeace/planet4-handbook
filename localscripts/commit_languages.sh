#!/usr/bin/env bash
set -euo pipefail

export GCLOUD_ZONE=us-central1-a
echo ""
echo "Get connected to gcloud"
echo ""
gcloud container clusters get-credentials "${GCLOUD_CLUSTER}" --zone "${GCLOUD_ZONE}" --project "${GOOGLE_PROJECT_ID}"

echo ""
echo "Lets get the php pod to run the commands against"
echo ""
php=$(kubectl get pods --namespace "${HELM_NAMESPACE}" \
  --sort-by=.metadata.creationTimestamp \
  --field-selector=status.phase=Running \
  -l "release=${HELM_RELEASE},component=php" \
  -o jsonpath="{.items[-1:].metadata.name}")

echo ""
echo "the php pod is $php"
echo ""

if [[ -z "$php" ]]
then
  >&2 echo "ERROR: php pod not found in release ${HELM_RELEASE}"
  exit 1
fi

echo ""
echo "Lets configure git"
echo ""
git config --global user.email "circleci-bot@greenpeace.org"
git config --global user.name "CircleCI Bot"
git config --global push.default simple

echo ""
echo "Lets run the command to copy Master Theme language files from the pod"
echo ""

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/themes/planet4-master-theme/languages" translations/planet4-master-theme/languages/

echo ""
echo "Lets run the command to copy GF plugin language files from the pod"
echo ""

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/plugins/gravityforms/languages" translations/planet4-master-theme/languages/plugins/gravityforms/

echo ""
echo "Lets clone the repository where we will send the translations to"
echo ""
git clone git@github.com:greenpeace/planet4-master-theme.git gitrepos/planet4-master-theme -b main || true

echo ""
echo "Lets delete the tempoarary files that Loco Translate creates"
echo ""
rm -f translations/planet4-master-theme/languages/*.po~
rm -f translations/planet4-master-theme/languages/*.pot~
rm -f translations/planet4-master-theme/languages/blocks/*.po~
rm -f translations/planet4-master-theme/languages/blocks/*.pot~
rm -f translations/planet4-master-theme/languages/plugins/gravityforms/*.po~
rm -f translations/planet4-master-theme/languages/plugins/gravityforms/*.pot~
rm translations/planet4-master-theme/languages/plugins/gravityforms/index.php
# Remove old .json files (including Loco translate generated json files)
rm -f translations/planet4-master-theme/languages/*.json
rm -f translations/planet4-master-theme/languages/blocks/*.json

echo ""
/tmp/workspace/src/localscripts/generate-master-theme-po2json.sh
echo ""

echo ""
echo "Lets copy the modified languages file to the repository"
echo ""
cp translations/planet4-master-theme/languages/ gitrepos/planet4-master-theme/ -r

echo ""
echo "Lets add the new files"
echo ""
git -C gitrepos/planet4-master-theme add languages/*

git -C gitrepos/planet4-master-theme commit -m ":robot: Autocommit new translations" || true

echo ""
echo "Lets push them to the repository"
echo ""
git -C gitrepos/planet4-master-theme push
