#!/usr/bin/env bash
set -euo pipefail

export GCLOUD_ZONE=${GCLOUD_ZONE:-us-central1-a}

echo ""
echo "Connecting to GKE cluster: ${GCLOUD_CLUSTER}"
echo ""
gcloud container clusters get-credentials "${GCLOUD_CLUSTER}" --zone "${GCLOUD_ZONE}" --project "${GOOGLE_PROJECT_ID}"

echo ""
echo "Deploying RAG services (Elasticsearch 9.x + Ollama) to namespace: ${HELM_NAMESPACE}"
echo ""
kubectl apply -f /home/circleci/checkout/k8s/ -n "${HELM_NAMESPACE}"

echo ""
echo "Waiting for Elasticsearch RAG to be ready..."
echo ""
kubectl rollout status deployment/elasticsearch-rag -n "${HELM_NAMESPACE}" --timeout=300s

echo ""
echo "Waiting for Ollama to be ready..."
echo ""
kubectl rollout status deployment/ollama -n "${HELM_NAMESPACE}" --timeout=300s

echo ""
echo "Pulling Llama 3.2 model into Ollama (this may take a few minutes on first run)..."
echo ""
kubectl exec -n "${HELM_NAMESPACE}" deployment/ollama -- ollama pull llama3.2:3b

echo ""
echo "Configuring RAG Chatbot WordPress plugin settings..."
echo ""
php=$(kubectl get pods --namespace "${HELM_NAMESPACE}" \
  --sort-by=.metadata.creationTimestamp \
  --field-selector=status.phase=Running \
  -l "release=${HELM_RELEASE},component=php" \
  -o jsonpath="{.items[-1:].metadata.name}")

if [[ -z "$php" ]]; then
  >&2 echo "ERROR: PHP pod not found in release ${HELM_RELEASE}"
  exit 1
fi

echo "Found PHP pod: $php"

kubectl exec -n "${HELM_NAMESPACE}" "$php" -- \
  wp option patch update rag_chatbot_settings ollama_url "http://ollama:11434"

kubectl exec -n "${HELM_NAMESPACE}" "$php" -- \
  wp option patch update rag_chatbot_settings elasticsearch_url "http://elasticsearch-rag:9200"

kubectl exec -n "${HELM_NAMESPACE}" "$php" -- \
  wp plugin activate swayam-ai-chatbot

echo ""
echo "RAG Chatbot services deployed and configured successfully!"
echo ""
