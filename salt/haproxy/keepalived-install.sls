keepalived-install:
  file.managed:
    - name: /usr/local/src/keepalived-2.0.4.tar.gz
    - source: salt://haproxy/soft/keepalived-2.0.4.tar.gz
    - mode: 755
    - user: root
    - group: root
  cmd.run:
    - name: cd  /usr/local/src && tar zxf keepalived-2.0.4.tar.gz && cd  keepalived-2.0.4 && ./configure --prefix=/usr/local/keepalived --disable-fwmark && make && make install
    - unless: test -d /usr/local/keepalived
    - require:
      - file: keepalived-install
/etc/keepalived:
  file.directory:
    - user: root
    - group: root
    - mode: 755
keepalived-sysconf-file:
  file.managed:
    - name: /etc/sysconfig/keepalived
    - source: salt://haproxy/files/keepalived.sysconfig
    - mode: 644
    - user: root
    - group: root
keepalived-start-script:
  file.managed:
    - name: /etc/init.d/keepalived
    - source: salt://haproxy/files/keepalived.init
    - mode: 755
    - user: root
    - group: root
keepalived-sbin-conf:
  cmd.run:
    - name: cp -rfa  /usr/local/keepalived/sbin/keepalived  /usr/sbin/ 
    - unless: test -f /usr/sbin/keepalived
    - require:
      - file: keepalived-install
add-keepalivd-service:
  cmd.run:
    - name: chkconfig --add keepalived
    - unless: chkconfig --list|grep keepalived
    - require:
      - file: keepalived-start-script
keepalived-conf:
{% if grains['fqdn'] == 'haproxy-1'  %}
  file.managed:
    - name: /etc/keepalived/keepalived.conf
    - source: salt://haproxy/files/master-keepalived.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      VIP: 192.168.56.20
      ROUTEID: haproxy_ha
      STATEID: MASTER
      PRIORITYID: 150
{% elif  grains['fqdn'] == 'haproxy-2' %}
  file.managed:
    - name: /etc/keepalived/keepalived.conf
    - source: salt://haproxy/files/slave-keepalived.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
      VIP: 192.168.56.20
      ROUTEID: haproxy_ha
      STATEID: BACKUP
      PRIORITYID: 100
    {%  endif %}
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: keepalived-conf
check-keepalived-service:
  file.managed:
    - name: /etc/keepalived/notify.sh 
    - source: salt://haproxy/files/notify.sh
    - mode: 755
    - user: root
    - group: root   


