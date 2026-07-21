# Load testing script

I'm not sure what "concurrent" means here (if I'm being pedantic it might mean not waiting for a curl request to end before sending another one so instead using `&` to send the process in the background).

A quick solution could look like this:

```
#!/bin/bash

set -a
. credentials
set +a

for i in {1..10}; do
  curl https://loadtester.home.chitzu.ro/burn -u $USER:$PASS &
done

wait
```

The problem is this will result in one 202 (the first request) and a bunch of 409s because HPA is not that fast to handle the load increase and create more replicas.

Instead if we focus on "run it long enough to activate the autoscaler" it might look like this (after roughly measuring how quick HPA scales replicas and how long the load lasts):

```
#!/bin/bash

set -a
. credentials
set +a

for count in 1 2 5 10; do
  for ((i=1; i<=count; i++)); do
    curl https://loadtester.home.chitzu.ro/burn -u $USER:$PASS &
  done
  wait
  sleep 35
done
```

This matches the requirement of concurrent and long enough:

```
dorin@rke2:~$ ./test.sh 
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"status":"already burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"status":"already burning"}
{"status":"already burning"}
{"status":"already burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"status":"already burning"}
{"cpu_percent":80,"duration_seconds":30,"ram_percent":0,"status":"burning"}
{"status":"already burning"}
{"status":"already burning"}
{"status":"already burning"}
{"status":"already burning"}
{"status":"already burning"}
{"status":"already burning"}
```

and I can see how new replicas are created by HPA:

```
dorin@rke2:~$ kubectl -n loadtester get pods -w
NAME                         READY   STATUS    RESTARTS   AGE
loadtester-8b64b6dbd-whngk   1/1     Running   0          38m
loadtester-8b64b6dbd-bplm9   0/1     Pending             0          0s
loadtester-8b64b6dbd-bplm9   0/1     Pending             0          0s
loadtester-8b64b6dbd-bplm9   0/1     ContainerCreating   0          0s
loadtester-8b64b6dbd-bplm9   0/1     ContainerCreating   0          1s
loadtester-8b64b6dbd-bplm9   1/1     Running             0          2s
loadtester-8b64b6dbd-8nj82   0/1     Pending             0          0s
loadtester-8b64b6dbd-8nj82   0/1     Pending             0          0s
loadtester-8b64b6dbd-8nj82   0/1     ContainerCreating   0          0s
loadtester-8b64b6dbd-8nj82   0/1     ContainerCreating   0          1s
loadtester-8b64b6dbd-8nj82   1/1     Running             0          2s
loadtester-8b64b6dbd-wc7jc   0/1     Pending             0          0s
loadtester-8b64b6dbd-gx828   0/1     Pending             0          0s
loadtester-8b64b6dbd-gsqtl   0/1     Pending             0          0s
loadtester-8b64b6dbd-wc7jc   0/1     Pending             0          0s
loadtester-8b64b6dbd-gx828   0/1     Pending             0          0s
loadtester-8b64b6dbd-gsqtl   0/1     Pending             0          0s
loadtester-8b64b6dbd-wc7jc   0/1     ContainerCreating   0          0s
loadtester-8b64b6dbd-gx828   0/1     ContainerCreating   0          0s
loadtester-8b64b6dbd-gsqtl   0/1     ContainerCreating   0          0s
loadtester-8b64b6dbd-wc7jc   0/1     ContainerCreating   0          1s
loadtester-8b64b6dbd-gx828   0/1     ContainerCreating   0          1s
loadtester-8b64b6dbd-gsqtl   0/1     ContainerCreating   0          1s
loadtester-8b64b6dbd-gx828   1/1     Running             0          2s
loadtester-8b64b6dbd-gsqtl   1/1     Running             0          2s
loadtester-8b64b6dbd-wc7jc   1/1     Running             0          2s
```


