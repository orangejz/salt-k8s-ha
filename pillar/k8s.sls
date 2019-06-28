# -*- coding: utf-8 -*-
#********************************************
# Author:       Peter Zhao
# Email:        13810339808@163.com
# Description:  Kubernetes Config with Pillar
#********************************************

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
