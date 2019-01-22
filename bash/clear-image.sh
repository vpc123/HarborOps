cd /home/harbor
rm -rf /root/cert/
rm -rf /data
echo "下面的执行结果不影响后续部署"
docker-compose  -f  /home/harbor/docker-compose.yml  -f  /home/harbor/docker-compose.clair.yml -f  /home/harbor/docker-compose.chartmuseum.yml down -v