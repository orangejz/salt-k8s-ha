#close swap && selinux
cloe-all-swap-selinux:
  cmd.run:
    - name:  swapoff -a  && sed -i 's/.*swap.*/#&/' /etc/fstab  && sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux && sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config && systemctl disable firewalld && systemctl stop firewalld 
sysctl-conf:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://k8s/files/system/sysctl.conf
    - user: root
    - group: root
    - mode: 644
limits-conf:
  file.managed:
    - name: /etc/security/limits.conf
    - source: salt://k8s/files/system/limits.conf
    - user: root
    - group: root
    - mode: 644
