# 注意
- 执行脚本前需要提前修改 K8S.sls  roster 中的IP为你所在环境的IP，切记！！！
- 注意网卡必须是eth0,否则需要提前修改！！！
# 环境准备
最低配置 1C-CPU 2G-内存 40G-磁盘（2个haproxy,3个master节点,2个node节点）
# SaltStack自动化部署Kubernetes
- SaltStack自动化部署Kubernetes v1.12.7版本（支持TLS双向认证、RBAC授权、Flannel网络、ETCD集群、Kuber-Proxy使用LVS等）。
# 功能说明
- 自动部署3台etcd集群，2个haproxy 3个master节点，2个node节点

## 版本明细：Release-v1.12.7
- 测试通过系统：CentOS 7.4
- salt-ssh:     >=2017.7.4
- Kubernetes：  v1.12.7
- Etcd:         v3.3.1
- Docker:       17.06.2-ce
- Flannel：     v0.10.0
- CNI-Plugins： v0.7.0
建议部署节点：最少三个节点，请配置好主机名解析（必备）

## 架构介绍
1. 使用Salt Grains进行角色定义，增加灵活性。
2. 使用Salt Pillar进行配置项管理，保证安全性。
3. 使用Salt SSH执行状态，不需要安装Agent，保证通用性。
4. 使用Kubernetes当前稳定版本v1.12.7，保证稳定性。
  
## 0.系统初始化
1. 设置主机名
2. 设置/etc/hosts保证主机名能够解析
3. 关闭SELinux和防火墙

## 1.设置部署节点到其它所有节点的SSH免密码登录（包括本机）
```
[root@linux-node1 ~]# ssh-keygen -t rsa
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.15
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.16
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.11
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.17
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.18
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.12
[root@linux-node1 ~]# ssh-copy-id -i 192.168.56.13
```

## 2.安装Salt-SSH并克隆本项目代码。

2.1 安装Salt SSH（注意：老版本的Salt SSH不支持Roster定义Grains，需要2017.7.4以上版本）
```
[root@linux-node1 ~]# cd /opt && wget  https://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm && rpm -ivh epel-release-latest-7.noarch.rpm
[root@linux-node1 ~]# cd /opt && wget  https://mirrors.aliyun.com/saltstack/yum/redhat/salt-repo-latest-2.el7.noarch.rpm && rpm -ivh salt-repo-latest-2.el7.noarch.rpm
[root@linux-node1 ~]# yum install -y salt-ssh git
```

2.2 获取本项目代码，并放置在/srv目录
```
cd /opt && unzip salt-k8s-master.zip #(github自行下载)
[root@linux-node1 ~]# cd salt-k8s-master
[root@linux-node1 ~]# mv * /srv/
[root@linux-node1 srv]# /bin/cp /srv/roster /etc/salt/roster
[root@linux-node1 srv]# /bin/cp /srv/master /etc/salt/master
```
```
[root@linux-node1 ~]# cd /srv/salt/k8s/
下载二进制安装包：
https://pan.baidu.com/s/1-ohqxXbKP_8XxSmTeeB5lA
提取码：s0y1
[root@linux-node1 k8s]# tar -zxvf files-k8s-v1.12.7.tar.gz
```
## 3.Salt SSH管理的机器以及角色分配

- k8s-role: 用来设置K8S的角色
- etcd-role: 用来设置etcd的角色，如果只需要部署一个etcd，只需要在一台机器上设置即可
- etcd-name: 如果对一台机器设置了etcd-role就必须设置etcd-name



## 4.修改对应的配置参数，本项目使用Salt Pillar保存配置
```
[root@linux-node1 ~]# vim /srv/pillar/k8s.sls
#设置Master的IP地址(必须修改),如果使用HA请修改为VIP地址
MASTER_IP: "192.168.56.20"
#master list
MASTER1: "192.168.56.11"
MASTER2: "192.168.56.17"
MASTER3: "192.168.56.18"
#设置ETCD集群访问地址（必须修改）
ETCD_ENDPOINTS: "https://192.168.56.11:2379,https://192.168.56.17:2379,https://192.168.56.18:2379"

#设置ETCD集群初始化列表（必须修改）
ETCD_CLUSTER: "etcd-node1=https://192.168.56.11:2380,etcd-node2=https://192.168.56.17:2380,etcd-node3=https://192.168.56.18:2380"
#任意配置一个ETCD成员即可
ETCD_NODE: "192.168.56.18"

#通过Grains FQDN自动获取本机IP地址，请注意保证主机名解析到本机IP地址
NODE_IP: {{ grains['ip_interfaces']['eth0'][0] }}

#haproxy vip,添加所有HA的节点ip
HA_VIP: "192.168.56.20"
MASTER_HAIP: "192.168.56.15"
SLAVE_HAIP:  "192.168.56.16"
#设置BOOTSTARP的TOKEN，可以自己生成
BOOTSTRAP_TOKEN: "ad6d5bb607a186796d8861557df0d17f"

#配置Service IP地址段
SERVICE_CIDR: "10.147.0.0/20"

#Kubernetes服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_KUBERNETES_SVC_IP: "10.147.0.1"

#Kubernetes DNS 服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_DNS_SVC_IP: "10.147.0.2"

#设置Node Port的端口范围
NODE_PORT_RANGE: "30000-32766"

#设置POD的IP地址段
POD_CIDR: "10.147.224.0/20"

#设置集群的DNS域名
CLUSTER_DNS_DOMAIN: "cluster.local."

#设置Docker Registry地址
DOCKER_REGISTRY: "http://172.16.101.49:80"
```

## 5.执行SaltStack状态
```
测试Salt SSH联通性
[root@linux-node1 ~]# salt-ssh '*' test.ping

部署haproxy+keepalived
salt-ssh -L 'ha-1,ha-2' state.sls haproxy.haproxy-outside-install

5.1 部署Etcd，需要先部署，目标为部署etcd的节点。
[root@linux-node1 ~]# salt-ssh -L 'k8s-node1,k8s-node2,k8s-master1' state.sls k8s.etcd

5.2 部署K8S集群
[root@linux-node1 ~]# salt-ssh '*' state.highstate
```
由于包比较大，这里执行时间较长，15分钟+，如果执行有失败可以再次执行即可！

## 6.测试Kubernetes安装
```
[root@linux-node1 ~]# source /etc/profile
[root@linux-node1 ~]# kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   
[root@linux-node1 ~]# kubectl get node
NAME            STATUS    ROLES     AGE       VERSION
192.168.56.12   Ready     <none>    1m        v1.12.7
192.168.56.13   Ready     <none>    1m        v1.12.7
```
## 7.测试Kubernetes集群和Flannel网络
```
[root@linux-node1 ~]# kubectl run net-test --image=alpine --replicas=2 sleep 360000
deployment "net-test" created
需要等待拉取镜像，可能稍有的慢，请等待。
[root@linux-node1 ~]# kubectl get pod -o wide
NAME                        READY     STATUS    RESTARTS   AGE       IP          NODE
net-test-5786f8b986-77jq7   1/1       Running   0          14s       10.147.233.3   192.168.56.13
net-test-5786f8b986-p29tq   1/1       Running   0          14s       10.147.235.3   192.168.56.12

测试联通性，如果都能ping通，说明Kubernetes集群部署完毕。
[root@linux-node1 ~]# ping 10.147.233.3 
ping -c 2 10.147.233.3 
PING 10.147.233.3 (10.147.233.3) 56(84) bytes of data.
64 bytes from 10.147.233.3: icmp_seq=1 ttl=61 time=3.11 ms
64 bytes from 10.147.233.3: icmp_seq=2 ttl=61 time=0.917 ms

--- 10.147.233.3 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.917/2.013/3.110/1.097 ms
```
## 8.如何新增Kubernetes节点

- 1.设置SSH无密码登录
- 2.在/etc/salt/roster里面，增加对应的机器
- 3.执行SaltStack状态salt-ssh '*' state.highstate。
```
[root@linux-node1 ~]# vim /etc/salt/roster 
linux-node4:
  host: 192.168.56.14
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
[root@linux-node1 ~]# salt-ssh '*' state.sls k8s.node
```
