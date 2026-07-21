# Autoscaling

I'm too lazy to look into KEDA (and I'm sure it's great in production) so I'll stick to comparing HPA and VPA. 

RKE2 is a fully fledged K8s distro, but for this challenge I'm running it on a single node. Therefore HPA isn't as relevant here because horizontal-ness is great when you can distribute load on multiple nodes (at first glance scaling horizontally on the same node seems worse than scaling vertically because it's not as smooth).

That being said, the PowerPoint document expects HPA:

```
Send a bunch of requests to the /burn endpoint of the app and make sure more containers are getting spun up.
```

and VPA [isn't part of the core Kubernetes API](https://kubernetes.io/docs/concepts/workloads/autoscaling/vertical-pod-autoscale/) so I guess I'll stick to HPA (plus maybe the pod is feeling lonely and needs some friends).

By default the pod sits at a cool 1m of CPU:

```
dorin@rke2:~$ kubectl -n loadtester top pods
NAME                          CPU(cores)   MEMORY(bytes)   
loadtester-5ffdc9479f-4fmbc   1m           42Mi
```

And after hitting the `/burn` endpoint it peaks at close to 1000m:

```

dorin@rke2:~$ kubectl -n loadtester top pods
NAME                          CPU(cores)   MEMORY(bytes)   
loadtester-5ffdc9479f-4fmbc   971m         42Mi     
```

From what I can see `kubectl top pods` (and hence the metrics server API) isn't spewing metrics in real time so I tried to measure how long the load lasts (starting time when I hear the fans spinning and stopping when CPU goes to 1m):

```
dorin@rke2:~$ time watch kubectl -n loadtester top pods

real	0m49.823s
```

I have no experience setting up resource limits and behaviours of downscaling and upscaling, so I'll go with vibes (vibe scaling?). I am running a single node k8s cluster so I don't feel like setting request resource is relevant (as it's mostly used for scheduling between available nodes). As per [the documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) if you don't set any request limits, they will be equal to your limit.

I'll add 1000m CPU resource limit to my loadtester pods:

```

spec:
  containers:
  - name: loadtester
    resources:
      limits:
        cpu: "1000m"
```

Then I'll use `kubectl autoscale` to avoid writing any YAMLs myself (snippet taken from the before mentioned documentation page) and then copy the YAML itself:

```
dorin@rke2:~$ kubectl -n loadtester autoscale deployment loadtester --cpu=50% --min=1 --max=10

dorin@rke2:~$ kubectl -n loadtester get hpa loadtester -o yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: loadtester
  namespace: loadtester
spec:
  maxReplicas: 10
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: loadtester
```

Now this uses the default behaviour and it is kind of slow (or perhaps fast, depends on the application and load). It's fine for this purpose, but it's probably pretty important (same goes for KEDA).

Turns out you can't just put 1000m limits on your Pods in a 4 CPU node where other stuff is running:

```
dorin@rke2:~$ kubectl describe pod -n loadtester loadtester-5d8777bfb7-prjnz
[...]
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  5m12s  default-scheduler  0/1 nodes are available: 1 Insufficient cpu. no new claims to deallocate, preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.   
```

Turned down to 100m, this is probably enough to schedule pods.

And yes, sure enough, after some requests spam I get more pods:

```
dorin@rke2:~$ kubectl -n loadtester get pods
NAME                         READY   STATUS              RESTARTS   AGE
loadtester-8b64b6dbd-4jprb   1/1     Running             0          99s
loadtester-8b64b6dbd-dv8jc   0/1     ContainerCreating   0          2s
loadtester-8b64b6dbd-q82xd   1/1     Running             0          32s
loadtester-8b64b6dbd-qdzkb   0/1     ContainerCreating   0          2s
```

Now THIS is exciting, take that VPA.