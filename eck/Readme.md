# Elastic Cloud on
## Install Elastic System
This will install ECK onto your k8s cluster under the namespace `elastic-system`

```bash
kubectl apply -f https://download.elastic.co/downloads/eck/1.0.1/all-in-one.yaml
```

## Create namespace elastic-apps (depreciated)
Do everything in elastic-system namespace

```bash
kubectl create ns elastic-apps
```

## Install ElasticSearch
This will install 3 ElasticSearch nodes with volume of size 100gb onto k8s cluster

```bash
kubectl apply -f elasticsearch.yaml --namespace elastic-system
```

## Install Kibana
This will install 1 Kibana node with a http loadbalancer specified

```bash
kubectl apply -f kibana.yaml --namespace elastic-system
```

## Logstash (Helm Installation)

* Use Dockerfile to create logstash image with Kinesis plugin
* Push created image to ECR
* Fill in ECR repo path in values.yaml
* Fill in AWS environment variables in values.yaml (needed for Kinesis auth)

```bash
helm repo add elastic https://helm.elastic.co
helm install logstash elastic/logstash -f values.yaml --namespace elastic-system
```

* [AWS ECR reference](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth)
* [Push ECR image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 522950658565.dkr.ecr.us-east-2.amazonaws.com
docker build --build-arg logstash_version="7.6.0" -t logstash:template .
docker tag <IMAGE_ID> 522950658565.dkr.ecr.us-east-2.amazonaws.com/logstash:template
docker push 522950658565.dkr.ecr.us-east-2.amazonaws.com/logstash:template
```

## Index Templates

* https://discuss.elastic.co/t/multiple-templates-in-one-logstash-conf/46230/3
* https://discuss.elastic.co/t/specifying-with-elasticsearch-template-and-file-to-use/33362/2
* https://discuss.elastic.co/t/how-to-apply-index-templates-by-using-config-templates-dir/181668/5

## Kibana API

* get indices and templates

```bash
# get all indices matching wildcard expression
GET /_cat/indices/*21mm*?v&s=index
# get all templates matching wildcard expression
GET /_cat/templates/*21mm*?v&s=name
```

* get specific mapping

```bash
GET /21mm_preprocess_dev-awtc-index/_mapping
GET /21mm_preprocess_dev-awtc-index/_mapping
```

* delete mappings and templates

```bash
# delete all indices matching wildcard expression
DELETE *21mm*
# delete all templates matching wildcard expression
DELETE /_template/*21mm*
```
