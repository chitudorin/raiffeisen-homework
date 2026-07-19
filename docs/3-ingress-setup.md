# Ingress setup

I have previously worked with `ingress-nginx` (even if at a very surface level) and it is probably the most popular so documentation is plenty so I'll go with it.

This step is the first roadblock as I have to define the directories structure, find a way (ways?) to install `ingress-nginx` and read a bunch of Flux documentation (the boring part).

The documentation isn't very beginner friendly (especially if you haven't worked with Kustomize before), but after checking [an example repo](https://github.com/fluxcd/flux2-kustomize-helm-example) I'm starting to understand how it works.

I'll store the nginx-ingress stuff under `infrastructure` so I pointed flux-system `kustomization.yaml` to `../infrastructure` then I also created another `kustomization.yaml` under it including `ingress-nginx.yaml`. It would have been easier to just use [the Kubernetes manifest for installing ingress-nginx](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/cloud/deploy.yaml), but I'll suffer a bit more reading the documentation to learn how to install it via Helm.

Included `ingress-nginx` namespace creation, the [Helm repo](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start) definition and the HelmRelease itself. If it doesn't work, clearly FluxCD is at fault (and definitely not me not being able to read documentation).



