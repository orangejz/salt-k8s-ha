#master taint
master-taint:
  cmd.run:
    - name: /opt/kubernetes/bin/kubectl  taint nodes  {{ grains['ip_interfaces']['eth0'][0] }}  node-role.kubernetes.io/master=:NoSchedule
    - unless: /opt/kubernetes/bin/kubectl describe node {{ grains['ip_interfaces']['eth0'][0] }}|grep "node-role" 
master-role:
  cmd.run:
    - name: /opt/kubernetes/bin/kubectl  label node  {{ grains['ip_interfaces']['eth0'][0] }}  node-role.kubernetes.io/master=master
    - unless: /opt/kubernetes/bin/kubectl describe node {{ grains['ip_interfaces']['eth0'][0] }}|grep "master=master"
