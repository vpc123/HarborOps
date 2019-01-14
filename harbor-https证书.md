### 部署示例

#### 获得证书文件

1)产生根证书

    # openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
    -x509 -days 365 -out ca.crt \
    -subj "/C=CN/ST=Guangdong/L=Shenzhen/O=test_company/OU=IT/CN=test/emailAddress=11111111@qq.com"
    
    # ls
    ca.crt  ca.key


2) 产生证书签名请求

    # openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout harbor-ip.key \
    -out harbor-ip.csr \
    -subj "/C=CN/ST=Guangdong/L=Shenzhen/O=test_company/OU=IT/CN=harborIp/emailAddress=212724256@qq.com"
    
    # ls
    ca.crt  ca.key  harbor-registry.csr  harbor-registry.key



3) 为registry产生证书

    # echo subjectAltName = IP:harbor-ip > extfile.cnf
    
    # openssl x509 -req -days 365 -in harbor-ip.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile extfile.cnf -out harbor-ip.crt
    
    # ls
    ca.crt  ca.key  ca.srl  extfile.cnf  harbor-ip.crt  harbor-ip.csr  harbor-ip.key




#### 2 配置及安装

1) 拷贝harbor-registry证书到/root/cert目录

    # mkdir -p /root/cert
    # cp harbor-ip.crt /root/cert/
    # cp harbor-ip.key /root/cert/


2) 修改harbor.cfg配置文件

    #set hostname
    hostname = 192.168.69.128
    #set ui_url_protocol
    ui_url_protocol = https
    ......
    #The path of cert and key files for nginx, they are applied only the protocol is set to https 
    ssl_cert = /root/cert/harbor-registry.crt
    ssl_cert_key = /root/cert/harbor-registry.key


3) 重新产生配置文件

    # ./prepare

4) 关闭harbor

    # docker-compose down 

5) 查看docker daemon是否有--insecure-registry选项

如果仍有该选项，请将其去掉，并执行如下命令重启docker daemon:


    # systemctl daemon-reload
    # systemctl restart docker


6) 重启Harbor

    # docker-compose up -d
    Creating network "harbor_harbor" with the default driver
    Creating harbor-log ... done
    Creating registry   ... done
    Creating harbor-adminserver ... done
    Creating harbor-db  ... done
    Creating harbor-ui  ... done
    Creating harbor-jobservice  ... done
    Creating nginx  ... done
    
    # docker ps
    CONTAINER IDIMAGE  COMMAND  CREATED STATUSPORTS  NAMES
    c7b4d837fefcvmware/nginx-photon:v1.4.0 "nginx -g 'daemon of…"   6 seconds ago   Up 3 seconds  0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:4443->4443/tcp   nginx
    257ec984fc98vmware/harbor-jobservice:v1.4.0"/harbor/start.sh"   6 seconds ago   Up 4 seconds (health: starting)  harbor-jobservice
    331fe98b1623vmware/harbor-ui:v1.4.0"/harbor/start.sh"   8 seconds ago   Up 5 seconds (health: starting)  harbor-ui
    d155d8a3cf00vmware/harbor-db:v1.4.0"/usr/local/bin/dock…"   10 seconds ago  Up 7 seconds (health: starting)   3306/tcp   harbor-db
    183a8f508491vmware/harbor-adminserver:v1.4.0   "/harbor/start.sh"   10 seconds ago  Up 7 seconds (health: starting)  harbor-adminserver
    579642c3ceccvmware/registry-photon:v2.6.2-v1.4.0   "/entrypoint.sh serv…"   10 seconds ago  Up 7 seconds (health: starting)   5000/tcp   registry
    06a1618f789evmware/harbor-log:v1.4.0   "/bin/sh -c /usr/loc…"   10 seconds ago  Up 9 seconds (health: starting)   127.0.0.1:1514->10514/tcp  harbor-log
 

7) 通过https形式访问Harbor

通过浏览器访问
这里首先需要将上面产生的ca.crt导入到浏览器的受信任的根证书中。然后就可以通过https进行访问（这里经过测试，Chrome浏览器、IE浏览器可以正常访问，但360浏览器不能正常访问）

通过docker命令来访问..
首先新建/etc/docker/certs.d/192.168.69.128目录，然后将上面产生的ca.crt拷贝到该目录:

    # mkdir -p /etc/docker/certs.d/harbor-ip
    # cp ca.crt /etc/docker/certs.d/harbor-ip/


然后登录到docker registry:


    # docker login harbor-ip
    Username (admin): admin
    Password: 
    Login Succeeded



### Troubleshooting

2) 在有一些docker daemon运行的操作系统上，你也许需要在操作系统级别信任该证书


在Ubuntu操作系统上，你可以通过如下命令来完成

    # cp youdomain.com.crt /usr/local/share/ca-certificates/reg.yourdomain.com.crt
    # update-ca-certificates
在Redhat(Centos等）操作系统上，你可以通过如下命令来完成

    # cp yourdomain.com.crt /etc/pki/ca-trust/source/anchors/reg.yourdomain.com.crt
    # update-ca-trust

