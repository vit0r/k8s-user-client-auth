# Create User k8s client auth

## Create kind cluster 

```console
$ kind create cluster --name cluster-test
```

## Generate csr and key per user

```console
$ openssl genrsa -out vitoraraujo.key 4096

$ openssl req -new -key vitoraraujo.key -subj "/CN=vitor.araujo" -out vitoraraujo.csr
```

## Replace spec.request into file vitoraraujo-k8s-csr.yaml
### Paste into request: ....

```console
$ cat vitoraraujo.csr | base64 | tr -d '\n'
```

## Apply the CertificateSigningRequest file per user

```console
$ kubectl apply -f vitoraraujo-k8s-csr.yaml

certificatesigningrequest.certificates.k8s.io/vitor.araujo created
```
## Check user certificate

```console
kubectl get csr vitor.araujo
```

## Approve certificate file

```console
$ kubectl certificate approve vitor.araujo

certificatesigningrequest.certificates.k8s.io/vitor.araujo approved
```

## Copy base kubeconfig and replace values with new user name,cert and key

```console
# READ config.original first
$ cp ~/.kube/config  config-vitoraraujo
```

## Replace values

```console

- context:
    user: kind-cluster-test to user: vitor.araujo 

name: kind-cluster-test@kind-cluster-test to name: vitor.araujo@kind-cluster-test

current-context: kind-cluster-test@kind-cluster-test to current-context: vitor.araujo@kind-cluster-test

users:
- name: kind-cluster-test

to 

users:
- name: vitor.araujo
```

## Install JQ 

```console
$ sudo apt install -y jq 
```

## Paste into client-certificate-data: ....

```console
$ kubectl get csr vitor.araujo -o json | jq .status.certificate | tr -d '"'
```

## Paste into client-key-data: ....

```console
$ cat vitoraraujo.key | base64 | tr -d '\n'
```

## Check new access
```console
$ kubectl get po -A  --kubeconfig config-vitoraraujo

Error from server (Forbidden): pods is forbidden: User "vitor.araujo" cannot list resource "pods" in API group "" at the cluster scope
```
