# Bootstraping FluxCD

Having `kubectl` only on the cluster VM, I installed the Flux cli there as well for ease of use. Created a new GitHub personal access token and bootstrapped Flux. I set it to look in `clusters/rke2` as that was the convention in the documentation.

```
dorin@rke2:~$ flux bootstrap github \
  --token-auth \
  --owner=chitudorin \
  --repository=raiffeisen-homework \
  --branch=main \
  --path=clusters/rke2 \
  --personal
  [...]
► confirming components are healthy
✔ helm-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ all components are health
```

Then I validated the sync:

```
dorin@rke2:~$ flux get source git
NAME       	REVISION          	SUSPENDED	READY	MESSAGE                                           
flux-system	main@sha1:1a736a73	False    	True 	stored artifact for revision 'main@sha1:1a736a73'	
dorin@rke2:~$ flux get kustomizations
NAME       	REVISION          	SUSPENDED	READY	MESSAGE                              
flux-system	main@sha1:1a736a73	False    	True 	Applied revision: main@sha1:1a736a73
```

