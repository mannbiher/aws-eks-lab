#!/bin/bash
kubectl patch -n kube-system -p '{ "spec": {"template": { "spec": { "containers": [ { "name": "aws-node", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset aws-node
kubectl patch -n kube-system -p '{ "spec": {"template":{ "spec": { "containers": [ { "name": "kube-proxy", "envFrom": [ { "configMapRef": {"name": "proxy-environment-variables"} } ] } ] } } } }' daemonset kube-proxy
# kubectl set env daemonset/kube-proxy --namespace=kube-system --from=configmap/proxy-environment-variables --containers='*'
# kubectl set env daemonset/aws-node --namespace=kube-system --from=configmap/proxy-environment-variables --containers='*'
