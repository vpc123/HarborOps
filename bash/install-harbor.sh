echo "******************使用方式***************"
echo "命令如下："
echo "         # bash  install.sh Harbor_ip    "
echo "*****************************************"




echo "清空可能存在问题的镜像"
docker rmi goharbor/harbor-jobservice:v1.6.0
docker rmi goharbor/harbor-ui:v1.6.0
docker rmi goharbor/harbor-adminserver:v1.6.0
docker rmi goharbor/harbor-db:v1.6.0
echo "清空问题镜像完成"

echo "加载Harbor需要使用的本地镜像"


docker load -i harbor-db-dev.tar.gz
docker load -i harbor-ui-dev.tar.gz
docker load -i harbor-adminserver-dev.tar.gz
docker load -i harbor-jobservice-dev.tar.gz
docker load -i chartmuseum-photon-v0.7.1-v1.6.0.tar.gz
docker load -i clair-photon-v2.0.5-v1.6.0.tar.gz
docker load -i harbor-clarity-ui-builder-1.6.0.tar.gz
docker load -i harbor-log-v1.6.0.tar.gz
docker load -i nginx-photon-v1.6.0.tar.gz
docker load -i redis-photon-v1.6.0.tar.gz
docker load -i registry-photon-v2.6.2-v1.6.0.tar.gz

echo "加载Harbor需要使用的本地镜像完成"

echo "开始执行证书自动构建生成"
Harbor_ip=$1
echo $Harbor_ip
#生成根证书
echo "生成根证书"
openssl req \
-newkey rsa:4096 -nodes -sha256 -keyout ca.key \
-x509 -days 365 -out ca.crt \
-subj "/C=CN/ST=Guangdong/L=Shenzhen/O=test_company/OU=IT/CN=test/emailAddress=212724256@qq.com"

echo "产生证书签名请求"

openssl req \
-newkey rsa:4096 -nodes -sha256 -keyout $Harbor_ip.key \
-out $Harbor_ip.csr \
-subj "/C=CN/ST=Guangdong/L=Shenzhen/O=test_company/OU=IT/CN="$Harbor_ip"/emailAddress=212724256@qq.com"

echo "为registry产生证书"

echo subjectAltName = IP:$Harbor_ip > extfile.cnf

openssl x509 -req -days 365 -in $Harbor_ip.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out $Harbor_ip.crt

echo "迁移证书文件"
echo "新建证书文件目录/root/cert"
mkdir  /root/cert
echo "拷贝所有证书文件到/root/cert 中。"

mv   $Harbor_ip.crt   /root/cert/

mv   $Harbor_ip.key   /root/cert/

mv   $Harbor_ip.csr   /root/cert/

mv ca.crt /root/cert

mv ca.key /root/cert

mv ca.srl /root/cert

mv extfile.cnf /root/cert


echo "恭喜已经完成Harbor镜像导入和证书生成工作!"
echo "请继续下面的操作。。。。。