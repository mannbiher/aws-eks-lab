#!/bin/bash
python cw_download.py /aws/eks/devops-eks-cluster/cluster authenticator-5ff3a3bc70f492c813934732fbff1545 >> authenticator-5ff3a3bc70f492c813934732fbff1545.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster authenticator-fc71191450dae66f11fd9b7cb235bce9 >> authenticator-fc71191450dae66f11fd9b7cb235bce9.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-apiserver-5ff3a3bc70f492c813934732fbff1545 >> kube-apiserver-5ff3a3bc70f492c813934732fbff1545.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-apiserver-audit-5ff3a3bc70f492c813934732fbff1545 >> kube-apiserver-audit-5ff3a3bc70f492c813934732fbff1545.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-apiserver-audit-fc71191450dae66f11fd9b7cb235bce9 >> kube-apiserver-audit-fc71191450dae66f11fd9b7cb235bce9.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-apiserver-fc71191450dae66f11fd9b7cb235bce9 >> kube-apiserver-fc71191450dae66f11fd9b7cb235bce9.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-controller-manager-5ff3a3bc70f492c813934732fbff1545 >> kube-controller-manager-5ff3a3bc70f492c813934732fbff1545.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-controller-manager-fc71191450dae66f11fd9b7cb235bce9 >> kube-controller-manager-fc71191450dae66f11fd9b7cb235bce9.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-scheduler-5ff3a3bc70f492c813934732fbff1545 >> kube-scheduler-5ff3a3bc70f492c813934732fbff1545.txt
python cw_download.py /aws/eks/devops-eks-cluster/cluster kube-scheduler-fc71191450dae66f11fd9b7cb235bce9 >> kube-scheduler-fc71191450dae66f11fd9b7cb235bce9.txt