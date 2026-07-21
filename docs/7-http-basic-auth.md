# HTTP Basic Auth

As I'm using ingress-nginx I'll follow [their guide for setting HTTP Basic Auth](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/).

After creating the htpasswd file I used it for generating a secret:

```
dorin@rke2:~$ kubectl create secret generic basic-auth -n loadtester --from-file=auth
secret/basic-auth created
dorin@rke2:~$ kubectl -n loadtester get secret
NAME         TYPE     DATA   AGE
basic-auth   Opaque   1      13s
```

Now I'll add these two annotations to my Ingress:

```
metadata:
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
```