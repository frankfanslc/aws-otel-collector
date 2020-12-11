#!/bin/bash

while getopts m:r: flag
do
    case "${flag}" in
        m) metric_count=${OPTARG};;
        r) replicas=${OPTARG};;
    esac
done
echo "metric_count: $metric_count";
echo "replicas: $replicas";

sed "s/{{metric_count}}/$metric_count/g" prometheus-sample-app.yaml | sed "s/{{replicas}}/$replicas/g"  > temp.yaml

kubectl apply -f temp.yaml
kubectl apply -f cwagent-daemonset.yaml
kubectl apply -f eks-prometheus-sidecar.yaml

echo "letting performance tests run"

sleep 300s
