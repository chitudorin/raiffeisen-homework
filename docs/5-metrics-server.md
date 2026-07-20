# Metrics Server

This should, again, be straight forward. Will add the Metrics Server Helm repo and install the HelmRelease like I did for ingress-nginx and cert-manager, adding the `metrics-server.yaml` in `kustomization.yaml`.

Pretty easy installation and confirmed it worked:

```
dorin@rke2:~$ kubectl top pods -A
NAMESPACE        NAME                                                    CPU(cores)   MEMORY(bytes)   
cert-manager     cert-manager-8fcb9d456-plqxr                            1m           36Mi            
cert-manager     cert-manager-cainjector-85c8bf6d8b-qg4bk                1m           22Mi            
cert-manager     cert-manager-webhook-85d7d5497-9bcp2                    1m           16Mi            
flux-system      helm-controller-58f59645b4-ngr5z                        4m           130Mi           
flux-system      kustomize-controller-896684bb7-dtl4m                    1m           156Mi           
flux-system      notification-controller-79779dcdf6-c6psd                1m           83Mi            
flux-system      source-controller-78cd677d4c-9lpf5                      2m           107Mi           
ingress-nginx    ingress-nginx-controller-6b87fbd6b6-nvd8q               1m           69Mi            
kube-system      cloud-controller-manager-rke2                           2m           23Mi            
kube-system      etcd-rke2                                               26m          88Mi            
kube-system      kube-apiserver-rke2                                     68m          614Mi           
kube-system      kube-controller-manager-rke2                            12m          93Mi            
kube-system      kube-proxy-rke2                                         1m           18Mi            
kube-system      kube-scheduler-rke2                                     4m           84Mi            
kube-system      rke2-canal-nsfvf                                        23m          211Mi           
kube-system      rke2-coredns-rke2-coredns-54c96855bc-slqkd              2m           72Mi            
kube-system      rke2-coredns-rke2-coredns-autoscaler-785f6bc8fb-ms4z7   1m           46Mi            
kube-system      rke2-snapshot-controller-85f96574d5-wlv25               1m           68Mi            
loadtester       loadtester-5ffdc9479f-4fmbc                             1m           42Mi            
metrics-server   metrics-server-79b98c8ddc-wt7q7                         80m          15Mi            
dorin@rke2:~$ kubectl top nodes
NAME   CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
rke2   250m         6%       3392Mi          42%
```
---
\* RKE2 already comes with metrics-server installed which I've previously disabled (and confirmed with kubectl top nodes before installing it again).