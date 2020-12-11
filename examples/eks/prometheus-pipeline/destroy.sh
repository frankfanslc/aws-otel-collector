#!/bin/bash

while getopts s:e: flag
do
    case "${flag}" in
        s) start_time=${OPTARG};;
        e) end_time=${OPTARG};;
    esac
done
echo "start_time: $start_time";
echo "end_time: $end_time";

sed "s/{{start_time}}/$start_time/g" performance_cpu_query.json | sed "s/{{end_time}}/$end_time/g"  > temp.json
sed "s/{{start_time}}/$start_time/g" performance_mem_query.json | sed "s/{{end_time}}/$end_time/g"  > temp2.json

aws cloudwatch get-metric-statistics --cli-input-json file://~/Documents/aws-otel-collector/examples/eks/prometheus-pipeline/temp.json
aws cloudwatch get-metric-statistics --cli-input-json file://~/Documents/aws-otel-collector/examples/eks/prometheus-pipeline/temp2.json

kubectl delete -f temp.yaml
kubectl delete -f cwagent-daemonset.yaml
kubectl delete -f eks-prometheus-sidecar.yaml

rm temp.yaml
rm temp.json
rm temp2.json