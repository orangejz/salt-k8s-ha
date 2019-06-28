ntppkg-install:
  pkg.installed:
    - names:
      - ntpdate
      - net-tools
ntp-crontab-managed: 
  file.append: 
    - name: /etc/crontab
    - text:
      - '*/2 * * * * root /usr/sbin/ntpdate ntp1.aliyun.com'
    - unless: cat /etc/crontab|grep ntpdate
