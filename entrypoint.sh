#!/bin/bash

USERNAME=$1
mkdir -p $USERNAME
cd $USERNAME
openssl genrsa -out $USERNAME.key 4096
openssl req -new -key $USERNAME.key -subj "/CN=${USERNAME}" -out $USERNAME.csr
CSR=$(cat $USERNAME.csr | base64 | tr -d '\n')

cat <<EOM >$USERNAME-k8s-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: 
  name: vitor.araujo
spec:
  request: ${CSR}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - "client auth"
EOM

cat <<EOM >$USERNAME-rbac-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""] 
  resources: ["pods","pods/log"]
  verbs: ["get", "watch", "list"]
EOM

cat <<EOM >$USERNAME-rbac-rolebind.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-$USERNAME
subjects:
- kind: User
  name: $USERNAME
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOM