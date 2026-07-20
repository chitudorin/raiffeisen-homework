# Ingress setup

I have previously worked with `ingress-nginx` (even if at a very surface level) and it is probably the most popular so documentation is plenty so I'll go with it.

This step is the first roadblock as I have to define the directories structure, find a way (ways?) to install `ingress-nginx` and read a bunch of Flux documentation (the boring part).

The documentation isn't very beginner friendly (especially if you haven't worked with Kustomize before), but after checking [an example repo](https://github.com/fluxcd/flux2-kustomize-helm-example) I'm starting to understand how it works.

I'll store the nginx-ingress stuff under `infrastructure` so I pointed flux-system `kustomization.yaml` to `../infrastructure` then I also created another `kustomization.yaml` under it including `ingress-nginx.yaml`. It would have been easier to just use [the Kubernetes manifest for installing ingress-nginx](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml), but I'll suffer a bit more reading the documentation to learn how to install it via Helm.

Included `ingress-nginx` namespace creation, the [Helm repo](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start) definition and the HelmRelease itself. If it doesn't work, clearly FluxCD is at fault (and definitely not me not being able to read documentation).

Already my first mistake, I referenced `../ingress-nginx` in the flux-system `kustomization.yaml` but it is already discovered only because it's under `clusters/rke2`. From now on I'll leave it as default and only create necessary directories (like `apps` under `cluster/rke2` so they're automatically discovered).

After fixing the issue the `nginx-ingress` controller is up:

```
dorin@rke2:~$ kubectl get pods --namespace=ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-6c7cd85885-5km7k   1/1     Running   0          26s
```

`curl`ing also works (though it throws 404 because no routes are defined yet):

```
dorin@rke2:~$ curl localhost:80
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

When setting up [cert-manager](3.1-cert-manager.md) I discovered that RKE2 already comes with ingress-nginx (and also metrics server) and it would actually precede my ingress-nginx, so technically the installation wasn't done. Now I disabled both of those prepackaged services:

```
dorin@rke2:~$ cat /etc/rancher/rke2/config.yaml 
disable:
  - rke2-ingress-nginx
  - rke2-metrics-server
```

but now my controller isn't accesible anymore:

```
dorin@rke2:~$ curl localhost:80
curl: (7) Failed to connect to localhost port 80 after 0 ms: Could not connect to server
```

With the default installation, on a bare metal setup, ingress-nginx [only exposes unprivileged ports (30000-32767) through NodePort](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#over-a-nodeport-service). This is not cool, you need to append the NodePort to each service you're accessing. I'll opt for the [hostNetwork solution](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network) (solution that has a security warning, which I'll close my eyes and completely ignore for now; perhaps it's all fine for my usecase) and enable the option:

```
spec:
  values:
    controller:
      hostNetwork: true
```