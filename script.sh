###
 # @Author: clingxin
 # @Date: 2021-05-08 15:50:29
 # @LastEditors: clingxin
 # @LastEditTime: 2021-05-08 19:38:49
 # @FilePath: /docker-registry/script.sh
###
#create and start registry and dashboard
mkdir volume
docker-compose -f docker-compose.yml up
#push docker image to registry
docker tag python-web-fastapi-docker_core_api:latest localhost:5000/lxcao/python-web-fastapi-docker_core_api:v1
docker push localhost:5000/lxcao/python-web-fastapi-docker_core_api:v1
#start minikube
minikube start
minikube start --insecure-registry='localhost:5000'
#connected local registry
minikube status
kubectl get nodes
minikube stop
#create namespace
kubectl create namespace lxcao
#Create Manifest Files
kubectl create deployment fastapidemo --image=localhost:5000/lxcao/python-web-fastapi-docker_core_api:v1 --dry-run=client -o=yaml > deployment.yaml
kubectl create service clusterip fastapidemo --tcp=8000:8000 --dry-run=client -o=yaml > service.yaml
#Create Pods and services
kubectl create -f deployment.yaml  -n lxcao
kubectl create -f service.yaml  -n lxcao
#get and delete all resources in namespace
kubectl get all -n lxcao
kubectl delete all --all -n lxcao
#debug while create
 kubectl describe pods -n lxcao
 curl http://127.0.0.1:5000/v2/_catalog