#!/bin/bash

while getopts r:w:s:e:m: flag
do
    case "${flag}" in
        r) region=${OPTARG};;
        w) workspace=${OPTARG};;
        s) start_time=${OPTARG};;
        e) end_time=${OPTARG};;
        m) metric_load=${OPTARG};;
    esac
done
echo "region: $region";
echo "workspace: $workspace";
echo "start_time: $start_time";
echo "end_time: $end_time";
echo "metric_load: $metric_load";

((metric_load--))

sed "s/{{start_time}}/$start_time/g" performance_cpu_query.json | sed "s/{{end_time}}/$end_time/g"  > temp.json
sed "s/{{start_time}}/$start_time/g" performance_mem_query.json | sed "s/{{end_time}}/$end_time/g"  > temp2.json

aws cloudwatch get-metric-statistics --cli-input-json file://~/Documents/aws-otel-collector/examples/eks/prometheus-pipeline/temp.json
aws cloudwatch get-metric-statistics --cli-input-json file://~/Documents/aws-otel-collector/examples/eks/prometheus-pipeline/temp2.json

awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_counter0"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_counter$metric_load"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_gauge0"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_gauge$metric_load"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_histogram0_bucket"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_histogram${metric_load}_bucket"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_summary0"
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=test_summary${metric_load}"

kubectl delete -f temp.yaml
kubectl delete -f temp2.yaml
kubectl delete -f cwagent-daemonset.yaml

rm temp.yaml
rm temp.json
rm temp2.json