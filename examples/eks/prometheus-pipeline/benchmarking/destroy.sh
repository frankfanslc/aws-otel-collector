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

aws cloudwatch get-metric-statistics --cli-input-json file://~/open-o11y/aws-otel-collector/examples/eks/prometheus-pipeline/benchmarking/temp.json
aws cloudwatch get-metric-statistics --cli-input-json file://~/open-o11y/aws-otel-collector/examples/eks/prometheus-pipeline/benchmarking/temp2.json

awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_counter0_total"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_counter${metric_load}_total"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_gauge0"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_gauge$metric_load"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_histogram0_bucket"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_histogram${metric_load}_bucket"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_summary0"  > result.txt
grep -o __name__ result.txt | wc -l
awscurl --service "aps" --region "$region" "https://aps-workspaces.$region.amazonaws.com/workspaces/$workspace/api/v1/query?query=benchmarking_test_summary${metric_load}"  > result.txt
grep -o __name__ result.txt | wc -l

kubectl delete -f temp.yaml
kubectl delete -f temp2.yaml
kubectl delete -f cwagent-daemonset.yaml
kubectl delete -f cwagent-configmap.yaml

rm result.txt
rm temp.yaml
rm temp2.yaml
rm temp.json
rm temp2.json