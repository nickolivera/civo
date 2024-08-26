# Civo

## Tools
- Mac Sonoma
- OpenTofu
- Spot (https://github.com/umputun/spot)

## How to:

1. Configure `terraform.tfvars.example` with the IDs for your network, SSH, etc. Alternatively, you could use names and Terraform data resources.
   ```bash
   tofu init
   tofu apply
   ```

2. Use Spot to run the following commands:
   ```bash
   spot -p base.yaml -t control -t nodes -n prep -n kubeadm
   spot -p base.yaml -t control -n boostrap-control -n boostrap-control-flannel
   spot -p base.yaml -t control -n node-creds
   spot -p base.yaml -t control -n node-creds-clean
   spot -p base.yaml -t nodes -n node-boostrap
   spot -p base.yaml -t nodes -n node-boostrap-join
   spot -p base.yaml -t control -n verify
   ```

OpenTofu will create instances and generate configuration files with the IP addresses. Spot is a command runner that connects to these IPs to perform various tasks and configure the control plane and nodes. While Spot is used for its simplicity, it is important to ensure the idempotency of the commands to avoid failures.


## Kubevirt
```
civo@main:~$ kubectl get pods -n kubevirt
NAME                               READY   STATUS    RESTARTS   AGE
virt-api-f97fbdff-ktxxf            1/1     Running   0          101s
virt-api-f97fbdff-xtd4x            1/1     Running   0          101s
virt-controller-6bf9f4477f-82grp   1/1     Running   0          66s
virt-controller-6bf9f4477f-fbkv2   1/1     Running   0          66s
virt-handler-92kmg                 1/1     Running   0          66s
virt-handler-rh55d                 1/1     Running   0          66s
virt-operator-59f5558dcd-58jv6     1/1     Running   0          2m22s
virt-operator-59f5558dcd-dp5jb     1/1     Running   0          2m22s
```

Warning  FailedDataVolumeCreate  43s (x15 over 2m5s)  virtualmachine-controller  Error creating DataVolume alpine-dv: the server could not find the requested resource (post datavolumes.cdi.kubevirt.io)
https://bugzilla.redhat.com/show_bug.cgi?id=1751193

Needs to install https://kubevirt.io/user-guide/storage/containerized_data_importer/

Currently stuck in provisioning

## Chart

```
nick@nicks-Personal-MacBook-Air my-chart % helm template my-release . -f values.yaml
---
# Source: my-chart/templates/vmgroup.yaml
apiVersion: v1
kind: Pod
metadata:
  name: first-01
spec:
  containers:
  - name: first-01
    image: "httpd"
    resources:
      requests:
        memory: "128Mi"
        cpu: "1"
---
# Source: my-chart/templates/vmgroup.yaml
apiVersion: v1
kind: Pod
metadata:
  name: first-02
spec:
  containers:
  - name: first-02
    image: "httpd"
    resources:
      requests:
        memory: "128Mi"
        cpu: "1"
---
# Source: my-chart/templates/vmgroup.yaml
apiVersion: v1
kind: Pod
metadata:
  name: second-01
spec:
  containers:
  - name: second-01
    image: "httpd"
    resources:
      requests:
        memory: "128Mi"
        cpu: "2"
```


```
nick@nicks-Personal-MacBook-Air my-chart % kubectl  --insecure-skip-tls-verify=true describe pod second-01 
Name:             second-01
Namespace:        default
Priority:         0
Service Account:  default
Node:             node1/192.168.1.24
Start Time:       Mon, 26 Aug 2024 01:11:43 -0600
Labels:           app.kubernetes.io/managed-by=Helm
Annotations:      meta.helm.sh/release-name: test
                  meta.helm.sh/release-namespace: default
Status:           Running
IP:               10.244.1.11
IPs:
  IP:  10.244.1.11
Containers:
  second-01:
    Container ID:   containerd://d05af66068c76c5b4ca027416016114cbfc15e988f516aa48be2aa521d5d975d
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:3f71777bcfac3df3aff5888a2d78c4104501516300b2e7ecb91ce8de2e3debc7
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 26 Aug 2024 01:11:44 -0600
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:        2
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vjtmh (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-vjtmh:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m23s  default-scheduler  Successfully assigned default/second-01 to node1
  Normal  Pulling    6m23s  kubelet            Pulling image "httpd"
  Normal  Pulled     6m22s  kubelet            Successfully pulled image "httpd" in 555ms (555ms including waiting)
  Normal  Created    6m22s  kubelet            Created container second-01
  Normal  Started    6m22s  kubelet            Started container second-01
nick@nicks-Personal-MacBook-Air my-chart % 
```