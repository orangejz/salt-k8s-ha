# -*- coding: utf-8 -*-
#******************************************
# Author:       Peter Zhao
# Description:  Docker Install
#******************************************
#{% set docker_version = "17.06.2.ce-1.el7.centos" %}
{% set docker_version = "docker-ce-18.06.3.ce-3.el7" %}
docker-install:
  file.managed:
    - name: /etc/yum.repos.d/docker-ce.repo
    - source: salt://k8s/templates/docker/docker-ce.repo.template
    - user: root
    - group: root
    - mode: 644
yum-install-docker:
  pkg.installed:
    - names:
      - {{ docker_version  }}
    - unless: test -f /usr/lib/systemd/system/docker.service

docker-config:
  file.managed:
    - name: /opt/kubernetes/cfg/docker
    - source: salt://k8s/templates/docker/docker-config.template
    - user: root
    - group: root
    - mode: 644

docker-config-dir:
  file.directory:
    - name: /etc/docker
    
docker-daemon-config:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://k8s/templates/docker/daemon.json.template
    - user: root
    - group: root
    - mode: 644

docker-service:
  file.managed:
    - name: /usr/lib/systemd/system/docker.service
    - source: salt://k8s/templates/docker/docker.service.template
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: systemctl daemon-reload
  service.running:
    - name: docker
    - enable: True
    - watch:
      - file: docker-config
      - file: docker-daemon-config
