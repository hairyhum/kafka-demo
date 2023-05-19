#!/usr/bin/env sh

minikube start --mount --mount-string="$(pwd)/mnt:/mnt/minikube"

helm install kafka oci://registry-1.docker.io/bitnamicharts/kafka

kubectl apply -f kafka-outlet.yaml

## Start your consumer application pod with ockam sidecar
kubectl apply -f kafka-consumer.yaml

## Start your producer applicaiton pod with ockam sidecar
kubectl apply -f kafka-producer.yaml

## Monitor consumed messages
kubectl logs -f kafka-consumer

## Start kafka-console-producer on producer pod to send messages to the topic
kubectl exec --tty -i kafka-producer --namespace default -- kafka-console-producer.sh --topic demo-topic --bootstrap-server localhost:9092
