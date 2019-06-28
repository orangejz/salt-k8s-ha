# -*- coding: utf-8 -*-
#******************************************
# Author:       Peter Zhao
# Description:  aggregator-key
#******************************************

aggregator-key:
  file.managed:
    - name: /opt/kubernetes/ssl/aggregator-csr.json
    - source: salt://k8s/templates/aggregator/aggregator-csr.json.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes aggregator-csr.json | /opt/kubernetes/bin/cfssljson -bare aggregator
    - unless: test -f /opt/kubernetes/ssl/aggregator.pem
k8s-prom-adapter-key:
  file.managed:
    - name: /opt/kubernetes/ssl/serving-csr.json
    - source: salt://k8s/templates/aggregator/serving-csr.json.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cd /opt/kubernetes/ssl && /opt/kubernetes/bin/cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem -ca-key=/opt/kubernetes/ssl/ca-key.pem -config=/opt/kubernetes/ssl/ca-config.json -profile=kubernetes serving-csr.json | /opt/kubernetes/bin/cfssljson -bare serving
    - unless: test -f /opt/kubernetes/ssl/serving.pem


