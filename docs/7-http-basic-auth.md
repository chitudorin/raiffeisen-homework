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

As expected the endpoints now return `401` with no credentials:

```
dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro
HTTP/2 401 
date: Tue, 21 Jul 2026 17:36:47 GMT
content-type: text/html
content-length: 172
www-authenticate: Basic realm=""
strict-transport-security: max-age=31536000; includeSubDomains

dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro/burn
HTTP/2 401 
date: Tue, 21 Jul 2026 17:36:51 GMT
content-type: text/html
content-length: 172
www-authenticate: Basic realm=""
strict-transport-security: max-age=31536000; includeSubDomains
```

Using credentials in the request I get the usual responses:

```
dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro -u foo:bar
HTTP/2 200 
date: Tue, 21 Jul 2026 17:37:58 GMT
content-type: application/json
content-length: 16
strict-transport-security: max-age=31536000; includeSubDomains

dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro/burn -u foo:bar
HTTP/2 202 
date: Tue, 21 Jul 2026 17:38:03 GMT
content-type: application/json
content-length: 76
strict-transport-security: max-age=31536000; includeSubDomains
```