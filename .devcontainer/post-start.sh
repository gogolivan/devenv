#!/usr/bin/env bash
set -e

# Start Minikube with containerd runtime and gVisor addon
minikube start --container-runtime=containerd  \
    --docker-opt containerd=/var/run/containerd/containerd.sock

minikube addons enable gvisor

# Enable metrics for cluster monitoring
minikube addons enable metrics-server

# Wait until Kubernetes API is ready
echo "Waiting for Kubernetes cluster to be ready..."
until kubectl get nodes >/dev/null 2>&1; do
    echo -n "."
    sleep 2
done
echo "Kubernetes cluster is ready!"

# Wait until all nodes are Ready
echo "Waiting until all nodes are Ready..."
until kubectl get nodes --no-headers | awk '{print $2}' | grep -q "Ready"; do
    echo -n "."
    sleep 2
done
echo "All nodes are Ready!"

# Check if any Gateway API CRDs are already installed
if kubectl get crds | grep -q 'gateway'; then
    echo "Gateway API already installed. Skipping installation."
else
    echo "Installing Gateway API..."
    kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
    echo "Gateway API installed successfully!"
fi

kubectl get crds | grep gateway

# Install Kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
