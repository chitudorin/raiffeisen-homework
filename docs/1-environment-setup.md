# Environment setup

## Repository

Chose GitHub for hosting the git repository and created one at https://github.com/chitudorin/raiffeisen-homework.

## Kubernetes cluster

After fiddling too much with Oracle Cloud I decided to run a cluster locally on my homelab and go from there. I created a 4 CPU/8GB RAM VM (as per [RKE2 recommended hardware requirements](https://docs.rke2.io/install/requirements#hardware)) and installed [RKE2](https://docs.rke2.io) as my Kubernetes distro as I had previous experience with it and is generally easy to get up and ready.

RKE2 comes by default with `kubectl` so I'll stick with the binary on the VM as I will probably not touch it that much after `Flux` gets installed.

I can see the cluster is up and ready:

```
root@rke2:/home/dorin# export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
root@rke2:/home/dorin# /var/lib/rancher/rke2/bin/kubectl get nodes
NAME   STATUS   ROLES                AGE     VERSION
rke2   Ready    control-plane,etcd   2m27s   v1.35.6+rke2r1
```

Finally, I added `/var/lib/rancher/rke2/bin` to my PATH and the kubeconfig variable in my bashrc.

