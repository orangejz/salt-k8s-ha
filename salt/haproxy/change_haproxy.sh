#!/bin/bash
salt-ssh -L 'ha-1,ha-2' state.sls haproxy.haproxy-outside-install
