#!/bin/bash

while getopts r:w:m:p: flag
do
    case "${flag}" in
        r) region=${OPTARG};;
        w) workspace=${OPTARG};;
        m) metric_count=${OPTARG};;
        p) replicas=${OPTARG};;
    esac
done
echo "region: $region";
echo "workspace: $workspace";
echo "metric_count: $metric_count";
echo "replicas: $replicas";

sed "s/{{metric_count}}/$metric_count/g" prometheus-sample-app.yaml | sed "s/{{replicas}}/$replicas/g"  > temp.yaml
sed "s/{{region}}/$region/g" eks-prometheus-sidecar.yaml | sed "s/{{workspace}}/$workspace/g"  > temp2.yaml

kubectl apply -f temp.yaml
kubectl apply -f temp2.yaml
kubectl apply -f cwagent-daemonset.yaml
kubectl apply -f cwagent-configmap.yaml

echo "letting performance tests run"

sleep 300s
