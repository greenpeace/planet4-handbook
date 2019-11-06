#!/usr/bin/env bash
set -euo pipefail

export GCLOUD_ZONE=us-central1-a
echo ""
echo "Get connected to gcloud"
echo ""
gcloud container clusters get-credentials ${GCLOUD_CLUSTER} --zone ${GCLOUD_ZONE} --project ${GOOGLE_PROJECT_ID}

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
echo " ########### Master Theme ####################"
echo ""

echo ""
echo "Lets run the command to copy everything from the pod"
echo ""

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/themes/planet4-master-theme/languages" translations/planet4-master-theme/languages/

echo ""
echo "Lets clone the repository where we will send the translations to"
echo ""
git clone git@github.com:greenpeace/planet4-master-theme.git gitrepos/planet4-master-theme -b languages || true

echo ""
echo "Lets delete the tempoarary files that Loco Translate creates"
echo ""
rm -f translations/planet4-master-theme/languages/*.po~

echo ""
echo "Lets copy the modified languages file to the repository"
echo ""
cp translations/planet4-master-theme/languages/ gitrepos/planet4-master-theme/ -r

echo ""
echo "Lets add the new files"
echo ""
git -C gitrepos/planet4-master-theme add languages/*

git -C gitrepos/planet4-master-theme commit -m "Autocommit - Language files" || true

echo ""
echo "Lets push them to the repository"
echo ""
git -C gitrepos/planet4-master-theme push


echo ""
echo " ########### Plugin Gutenberg Blocks ####################"
echo ""

echo ""
echo "Lets run the command to copy everything from the pod"
echo ""

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/plugins/planet4-plugin-gutenberg-blocks/languages" translations/planet4-plugin-gutenberg-blocks/languages/


echo ""
echo "Lets clone the repository where we will send the translations to"
echo ""
git clone git@github.com:greenpeace/planet4-plugin-gutenberg-blocks.git gitrepos/planet4-plugin-gutenberg-blocks -b languages || true

echo ""
echo "Lets delete the tempoarary files that Loco Translate creates"
echo ""
rm -f translations/planet4-plugin-gutenberg-blocks/languages/*.po~

echo ""
echo "Lets copy the modified languages file to the repository"
echo ""
cp translations/planet4-plugin-gutenberg-blocks/languages/ gitrepos/planet4-plugin-gutenberg-blocks/ -r

echo ""
echo "Lets add the new files"
echo ""
git -C gitrepos/planet4-plugin-gutenberg-blocks add languages/*

git -C gitrepos/planet4-plugin-gutenberg-blocks commit -m "Autocommit - Language files" || true

echo ""
echo "Lets push them to the repository"
echo ""
git -C gitrepos/planet4-plugin-gutenberg-blocks push


echo ""
echo " ########### Plugin Gutenberg Engagingnetworks ####################"
echo ""

echo ""
echo "Lets run the command to copy everything from the pod"
echo ""

kubectl -n "${HELM_NAMESPACE}" cp "$php://app/source/public/wp-content/plugins/planet4-plugin-gutenberg-engagingnetworks/languages" translations/planet4-plugin-gutenberg-engagingnetworks/languages/


echo ""
echo "Lets clone the repository where we will send the translations to"
echo ""
git clone git@github.com:greenpeace/planet4-plugin-gutenberg-engagingnetworks.git gitrepos/planet4-plugin-gutenberg-engagingnetworks -b languages || true

echo ""
echo "Lets delete the tempoarary files that Loco Translate creates"
echo ""
rm -f translations/planet4-plugin-gutenberg-engagingnetworks/languages/*.po~

echo ""
echo "Lets copy the modified languages file to the repository"
echo ""
cp translations/planet4-plugin-gutenberg-engagingnetworks/languages/ gitrepos/planet4-plugin-gutenberg-engagingnetworks/ -r

echo ""
echo "Lets add the new files"
echo ""
git -C gitrepos/planet4-plugin-gutenberg-engagingnetworks add languages/*

git -C gitrepos/planet4-plugin-gutenberg-engagingnetworks commit -m "Autocommit - Language files" || true

echo ""
echo "Lets push them to the repository"
echo ""
git -C gitrepos/planet4-plugin-gutenberg-engagingnetworks push


