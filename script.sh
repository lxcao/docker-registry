###
 # @Author: clingxin
 # @Date: 2021-05-08 15:50:29
 # @LastEditors: clingxin
 # @LastEditTime: 2021-05-08 16:08:01
 # @FilePath: /docker-registry/script.sh
###
mkdir volume
docker-compose -f docker-compose.yml up

docker tag python-web-fastapi-docker_core_api:latest localhost:5000/lxcao/python-web-fastapi-docker_core_api:v1
docker push localhost:5000/lxcao/python-web-fastapi-docker_core_api:v1
