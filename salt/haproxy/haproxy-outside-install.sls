include:
  - haproxy.pkg 
  - haproxy.keepalived-install 
haproxy-install:
  file.managed:
    - name: /usr/local/src/haproxy-1.8.19.tar.gz
    - source: salt://haproxy/soft/haproxy-1.8.19.tar.gz
  cmd.run:
    - name:  cd  /usr/local/src && tar zxf haproxy-1.8.19.tar.gz && cd  haproxy-1.8.19  && make  ARCH=x86_64 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 PREFIX=/usr/local/haproxy && make install PREFIX=/usr/local/haproxy
    - unless: test -d /usr/local/haproxy
    - require:
      - file: haproxy-install
haproxy-start-scripts:
  file.managed: 
    - name: /usr/lib/systemd/system/haproxy.service
    - source: salt://haproxy/files/haproxy.service
    - mode: 755
    - user: root
    - group: root
    - require:
      - cmd: haproxy-install
  cmd.run:
    - name: systemctl daemon-reload
haproxy-sbin-conf:
  cmd.run:
    - name: cp -rfa  /usr/local/haproxy/sbin/haproxy  /usr/sbin/
    - unless: test -f /usr/sbin/haproxy
    - require:
      - cmd: haproxy-install
sysctl-conf:
  file.managed:
    - name: /etc/sysctl.conf
    - source: salt://haproxy/files/sysctl.conf
    - user: root
    - group: root
    - mode: 644
limits-conf:
  file.managed:
    - name: /etc/security/limits.conf
    - source: salt://haproxy/files/limits.conf  
    - user: root
    - group: root
    - mode: 644
haproxy-config-dir:
  file.directory:
    - name: /etc/haproxy
    - mode: 755
    - user: root
    - group: root
#haproxy-init:
#  cmd.run:
#    - name: chkconfig --add haproxy && sysctl -p
#    - unless: chkconfig --list|grep haproxy
#    - require:
#      - file: /etc/init.d/haproxy
haproxy-service:
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/files/haproxy-outside.cfg
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - file: haproxy-service
#haproxy syslog
rsyslog-options:
  file.managed:
    - name: /etc/sysconfig/rsyslog
    - source: salt://haproxy/files/rsyslog
    - user: root
    - group: root
    - mode: 644

rsyslog-conf:
  file.managed:
    - name: /etc/rsyslog.conf
    - source: salt://haproxy/files/rsyslog.conf
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: systemctl restart  rsyslog
