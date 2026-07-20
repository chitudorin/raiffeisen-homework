# loadtester deployment

This step is pretty straight forward. Created `clusters/rke2/apps/loadtester`, added a `kustomization.yaml` file referencing `loadtester.yaml` which contains the namespace, deployment, service and ingress declaration. Did not add any `tls:` block because of the default certificate flag set up [earlier](3.1-cert-manager.md).

The app should be accessible at `loadtester.home.chitzu.ro` on both `/` and `/burn` endpoints.

Not straight forward, app port is 8080 (not mentioned anywhere but easily found when you do `kubectl logs`). Switched the containerPort and Service targetPort to 8080.

After changing the ports, the app is accessible (and I can hear my Lenovo M720q's fan spinning after hitting the `/burn` endpoint):

```
dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro
HTTP/2 200 
date: Mon, 20 Jul 2026 15:08:09 GMT
content-type: application/json
content-length: 16
strict-transport-security: max-age=31536000; includeSubDomains

dorin@rke2:~$ curl -I https://loadtester.home.chitzu.ro/burn
HTTP/2 202 
date: Mon, 20 Jul 2026 15:08:13 GMT
content-type: application/json
content-length: 76
strict-transport-security: max-age=31536000; includeSubDomains
```