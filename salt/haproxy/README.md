## 注意 网卡为eth0
vi keepalived-install.sls
salt-ssh '*' grains.get fqdn 获取FQDN 
修改 {% if grains['fqdn'] == 'haproxy-1'  %} 和 {% elif  grains['fqdn'] == 'haproxy-2' %}
