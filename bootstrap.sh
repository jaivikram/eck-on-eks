#!/bin/bash

#Metrics Server (updated)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml
kubectl get deployment metrics-server -n kube-system
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
# Creates admin user for eks
kubectl apply -f eksadmin.yaml

# Start autoscaler (determines whether to add nodes or not based on load)
# first step of cluster.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl create ns nginx
kubectl create ns cert-manager
# kubectl create ns prometheus
# kubectl create ns grafana

#Add helm charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add elastic https://helm.elastic.co
helm repo add jetstack https://charts.jetstack.io
helm repo update

#nginx-ingress, disable this line if Route53 DNS is not supported.  Use the direct load-balancer instead.
helm install my-nginx stable/nginx-ingress -n nginx

#Cert-Manager
cd cert-manager
kubectl apply -f .
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.9.1
cd ..

#Neo4J
# cd neo4j
# kubectl create ns neo4j
# helm install bformat -n neo4j -f values.yaml .
# cd ..

# Elastic Cloud
cd eck
#kubectl apply -f https://download.elastic.co/downloads/eck/1.1.2/all-in-one.yaml
kubectl create -f https://download.elastic.co/downloads/eck/2.4.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.4.0/operator.yaml
kubectl apply -f aio.yaml
# Install ElasticSearch
kubectl apply -f elasticsearch.yaml
# Install Kibana
kubectl apply -f kibana.yaml
# Install direct load-balancer, disable this line if a Route53 DNS is supported.
#kubectl apply -f ext-lb.yaml
# Create default user awtcus:awtcus
kubectl apply -f admin.yaml

#Install logstash
# cd logstash
# helm install logstash elastic/logstash -f values-dev.yaml -n elastic-system
# cd ../..

## Post install

# #### Ingress
# #
# #Ingress rules must be added for HTTP traffic to be routed to the kibana service
# #
# #    * Confirm that hostname is registered with Route53
# #    * Modify `ingress/kibana.yaml` as necessary
# #    * Confirm hostname routes to the Classic Load Balancer created as part of the nginx ingress
# #

# # Create nginx-ingress rule to route traffic to kibana.k8s.east.awtc.us
# cd ingress
# kubectl apply -f kibana.yaml
# cd ..
# #### SSL Certificate
# #
# #    * Modify `post-install/production_issuer.yaml` as necessary
# #    * Confirm hostname is listed `spec.acme.solvers.selector.dnsZones`
# #    * Confirm region is configured under `spec.acme.solvers.dns01.route53.region`
# #
# #Creates linkage between certificate manager and route53 to assign https when reverse proxying from a TLD
# cd post-install
# kubectl apply -f production_issuer.yaml

# # Used because we use spot instances; this allows the spot instance to terminate gracefully (spot instances get a 0 minute grace period before shutting down)
# helm install spot-handler stable/k8s-spot-termination-handler --namespace kube-system

# # Prometheus (k8s monitoring)
# # helm install prometheus stable/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

# # Graphana (more in-detailed k8s monitoring, as well as monitoring of other services on k8s
# # helm install grafana stable/grafana --namespace grafana --set persistence.storageClassName="gp2" --set adminPassword='EKS!sAWSome' --set datasources."datasources\.yaml".apiVersion=1  --set datasources."datasources\.yaml".datasources[0].name=Prometheus  --set datasources."datasources\.yaml".datasources[0].type=prometheus  --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local --set datasources."datasources\.yaml".datasources[0].access=proxy  --set datasources."datasources\.yaml".datasources[0].isDefault=true  --set service.type=ClusterIP
