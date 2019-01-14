## harbor磁盘空间占满清理

引题：

Harbor私有仓库运行一段时间后，仓库中存有大量镜像，会占用太多的存储空间。直接通过Harbor界面删除相关镜像，并不会自动删除存储中的文件和镜像。需要停止Harbor服务，执行垃圾回收命令，进行存储空间清理和回收。

#### 1、首先，删除Harbor的UI中的存储库。这是软删除。您可以删除整个存储库或仅删除它的标签。软删除后，Harbour中不再管理存储库，但是存储库的文件仍然保留在Harbour的存储中。 

我们可以查看系统盘的空间是否足够

    [root@k8s-master ~]# df -h
    文件系统 容量  已用  可用 已用% 挂载点
    /dev/mapper/centos-root   17G  5.2G   12G   31% /
    devtmpfs 899M 0  899M0% /dev
    overlay   17G  5.2G   12G   31% /var/lib/docker/overlay2/1b33ff28f53c04e271934479b9682287da7be80ea9250b02763014298d23bba5/merged
    shm   64M 0   64M0% /var/lib/docker/containers/87af6d0c8473edc83e96631ed43115111be632eabc1f0df9c44a049ec313468d/mounts/shm

#### 2、接下来，使用注册表的垃圾回收（GC）删除存储库的实际文件。在执行GC之前，确保没有人推送图像或Harbour根本没有运行。如果有人在GC运行时推送镜像，则存在镜像层被错误删除的风险，从而导致镜像损坏。所以在运行GC之前，首选的方法是先停止Harbour。 
第一步：

    $cd /home/harbor
    $docker-compose stop

第二步： 
在部署Harbour的主机上运行以下命令以预览会影响哪些文件/镜像 
注：上述选项”–dry-run”将打印进度而不删除任何数据。

    $docker run -it --name gc --rm --volumes-from registry vmware/registry-photon:v2.6.2-v1.5.0 garbage-collect --dry-run /etc/registry/config.yml


验证上述测试的结果，然后使用以下命令执行垃圾回收并重新启动Harbour。

    $docker run -it --name gc --rm --volumes-from registry vmware/registry-photon:v2.6.2-v1.5.0 garbage-collect /etc/registry/config.yml

#### 3、重启harbor各组件镜像
    $docker-compose start


#### 4 最后验证： 

    a：du -sh /data/registry/docker/registry/v2/blobs&repositories和之前该目录文件大小做对比 
    b：重新上传之前删除的镜像，如没成功删除会报镜像已存在，能成功上传则一切ok，恭喜 


### harbor镜像磁盘空间清理总结：

解决办法：
1 harbor镜像存储空间的分盘大小，从一开始就规划好harbor分区的大小并且保证足够的存储空间使用量
2 定期的进行harbor镜像垃圾回收，因为harbor1.7之前没有垃圾回收机制，所以垃圾回收需要手动进行，不然可能造成磁盘超额使用。