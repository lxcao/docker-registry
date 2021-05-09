###
 # @Author: clingxin
 # @Date: 2021-05-08 15:50:29
 # @LastEditors: clingxin
 # @LastEditTime: 2021-05-09 20:49:04
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
#following minikube docs
minikube start --insecure-registry "10.0.0.0/24"
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
##############################################
#cannot connect to local registry which running in docker container
#install and run registry service in minikube
#following minikube docs
 minikube addons enable registry
 # or
 #Grab UPDATED kube-registry.yaml from this gist on github. https://gist.github.com/coco98/b750b3debc6d517308596c248daf3bb1
 kubectl create -f kube-registry.yaml
 #check the kube-registry service in minikube
 minikube service list
 #Map the host port 5000 to minikube registry pod
 kubectl port-forward --namespace kube-system pod/$(kubectl get po -n kube-system | grep kube-registry-v0 | awk '{print $1;}') 5000:5000
 #direct port 5000 on the docker virtual machine over to port 5000 on the minikube machine
 docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

 ##########################华丽地分割线#########################
 #finally, the following scripts work well on registry service in minikube
 #by learning https://dev.to/rohansawant/how-to-setup-a-local-docker-registry-with-kubernetes-on-windows-includes-1-hidden-step-that-official-docs-doesn-t-320f
 #Start the cluster and allow insecure registries
 minikube start --insecure-registry "10.0.0.0/24"
 #minikube to start a registry inside a pod in the Kubernetes cluster
 minikube addons enable registry
 #get the registry service pod name and fill in the next script
 kubectl get pods --namespace kube-system
 #Forward all traffic to the registry by following two scripts
 kubectl port-forward --namespace kube-system registry-s4h7n 5000:5000
 docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
 #check
 curl http://127.0.0.1:5000/v2/_catalog
