# loadtester deployment

This step is pretty straight forward. Created `clusters/rke2/apps/loadtester`, added a `kustomization.yaml` file referencing `loadtester.yaml` which contains the namespace, deployment, service and ingress declaration. Did not add any `tls:` block because of the default certificate flag set up [earlier](3.1-cert-manager.md).

The app should be accessible at `loadtester.home.chitzu.ro` on both `/` and `/burn` endpoints.