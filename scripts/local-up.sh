#!/usr/bin/env bash
# Spin up the whole platform locally on kind (no AWS account needed).
# Requires: docker, kind, kubectl, helm, git
set -euo pipefail
cd "$(dirname "$0")/.."

CLUSTER=ml-platform
IMAGE=mlops-yolo-fastapi:local

echo "==> 1/5 kind cluster"
kind get clusters | grep -qx "$CLUSTER" || kind create cluster --config kind/cluster.yaml

echo "==> 2/5 build the inference image from the companion repo"
[ -d .build/mlops-yolo-fastapi ] || git clone --depth 1 https://github.com/asmakerkouri/mlops-yolo-fastapi .build/mlops-yolo-fastapi
docker build -t "$IMAGE" .build/mlops-yolo-fastapi
kind load docker-image "$IMAGE" --name "$CLUSTER"

echo "==> 3/5 monitoring stack (Prometheus + Grafana)"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update >/dev/null
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace -f monitoring/kube-prometheus-stack-values.yaml --wait
kubectl -n monitoring create configmap ml-inference-dashboard \
  --from-file=monitoring/dashboards/ml-inference.json --dry-run=client -o yaml \
  | kubectl label --local -f - grafana_dashboard=1 -o yaml | kubectl apply -f -

echo "==> 4/5 metrics-server (needed by the HPA on kind)"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' || true

echo "==> 5/5 inference service"
helm upgrade --install inference helm/ml-inference -n ml --create-namespace \
  --set image.repository=mlops-yolo-fastapi --set image.tag=local \
  --set serviceMonitor.enabled=true --wait

cat <<MSG

Done.
  API      : kubectl -n ml port-forward svc/inference-ml-inference 8000:80   -> http://localhost:8000/docs
  Grafana  : kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80 -> admin / admin
  Load test: scripts/load-test.sh   (watch the HPA: kubectl -n ml get hpa -w)
MSG
