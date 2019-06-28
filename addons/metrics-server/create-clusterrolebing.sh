#!/bin/bash
/opt/kubernetes/bin/kubectl create clusterrolebinding  custom-metric-with-cluster-admin --clusterrole=cluster-admin --user=front-proxy-client
