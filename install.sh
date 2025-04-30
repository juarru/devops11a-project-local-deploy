#!/usr/bin/env bash

set -e

# CONSTANTS

readonly KIND_IMAGE=kindest/node:v1.27.3
readonly NAME=flask-cluster

echo "--------------------------------- CREATE CLUSTER ----------------------------------"

kind create cluster --name $NAME --image $KIND_IMAGE --config kind/kind-config.yml --name flask-cluster

kubectl cluster-info --context kind-flask-cluster

echo "---------------------------- INSTALL LOCAL PATH PROVISIONER ------------------------"

# Instala el local-path-provisioner de Rancher
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Esperar a que el provisioner esté disponible
sleep 10

# Aplicar StorageClass personalizado desde archivo local
kubectl apply -f kind/local-storage.yml

# Establecer como StorageClass por defecto
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "-------------------------------- DEPLOY INGRESS-NGINX ----------------------------------"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

sleep 15

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "--------------------------------- DEPLOY ARGOCD ----------------------------------"

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

echo "--------------------------------- CREATE FLASK APP ----------------------------------"

kubectl apply -f manifests/application.yml

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "---------------------------------------------------------------------------------"
echo "Execute the following command to port-forward the ArgoCD server to your localhost:"
echo "- kubectl port-forward svc/argocd-server -n argocd 8081:443"
echo ""
echo "ArgoCD is running and available at http://localhost:8081"
echo "- log in with admin / $ARGOCD_PASSWORD"
echo ""
echo "If password has not loaded please type in a console:"
echo "- kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d"