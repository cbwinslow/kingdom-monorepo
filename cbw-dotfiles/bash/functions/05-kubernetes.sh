#!/usr/bin/env bash
# Kubernetes Operations and Shortcuts

# Kubectl get pods
kgp() {
    kubectl get pods "$@"
}

# Kubectl get pods all namespaces
kgpa() {
    kubectl get pods --all-namespaces "$@"
}

# Kubectl get services
kgs() {
    kubectl get services "$@"
}

# Kubectl get deployments
kgd() {
    kubectl get deployments "$@"
}

# Kubectl get nodes
kgn() {
    kubectl get nodes "$@"
}

# Kubectl get namespaces
kgns() {
    kubectl get namespaces "$@"
}

# Kubectl describe pod
kdp() {
    kubectl describe pod "$@"
}

# Kubectl describe service
kds() {
    kubectl describe service "$@"
}

# Kubectl describe deployment
kdd() {
    kubectl describe deployment "$@"
}

# Kubectl logs
kl() {
    kubectl logs "$@"
}

# Kubectl logs follow
klf() {
    kubectl logs -f "$@"
}

# Kubectl logs previous
klp() {
    kubectl logs -p "$@"
}

# Kubectl exec
kex() {
    kubectl exec -it "$@" -- /bin/bash
}

# Kubectl exec sh
kexsh() {
    kubectl exec -it "$@" -- /bin/sh
}

# Kubectl apply
ka() {
    kubectl apply -f "$@"
}

# Kubectl delete
kdel() {
    kubectl delete "$@"
}

# Kubectl delete pod
kdelp() {
    kubectl delete pod "$@"
}

# Kubectl delete deployment
kdeld() {
    kubectl delete deployment "$@"
}

# Kubectl delete service
kdels() {
    kubectl delete service "$@"
}

# Kubectl get events
kge() {
    kubectl get events --sort-by=.metadata.creationTimestamp
}

# Kubectl get all resources
kga() {
    kubectl get all "$@"
}

# Kubectl get all in namespace
kgan() {
    kubectl get all -n "$@"
}

# Kubectl scale deployment
kscale() {
    kubectl scale deployment "$1" --replicas="$2"
}

# Kubectl rollout status
krs() {
    kubectl rollout status "$@"
}

# Kubectl rollout history
krh() {
    kubectl rollout history "$@"
}

# Kubectl rollout undo
kru() {
    kubectl rollout undo "$@"
}

# Kubectl port forward
kpf() {
    kubectl port-forward "$@"
}

# Kubectl top pods
ktop() {
    kubectl top pods "$@"
}

# Kubectl top nodes
ktopn() {
    kubectl top nodes "$@"
}

# Kubectl config get contexts
kctx() {
    kubectl config get-contexts
}

# Kubectl config use context
kusectx() {
    kubectl config use-context "$@"
}

# Kubectl config current context
kcurrent() {
    kubectl config current-context
}

# Kubectl config set namespace
kns() {
    kubectl config set-context --current --namespace="$@"
}

# Kubectl get pods with node info
kgpn() {
    kubectl get pods -o wide
}

# Kubectl get all pods in all namespaces
kgpaa() {
    kubectl get pods -A
}

# Kubectl create namespace
kcns() {
    kubectl create namespace "$@"
}

# Kubectl label
klabel() {
    kubectl label "$@"
}

# Kubectl annotate
kannotate() {
    kubectl annotate "$@"
}

# Kubectl get config maps
kgcm() {
    kubectl get configmaps "$@"
}

# Kubectl get secrets
kgsec() {
    kubectl get secrets "$@"
}

# Kubectl describe node
kdnode() {
    kubectl describe node "$@"
}

# Kubectl get ingress
kgi() {
    kubectl get ingress "$@"
}

# Kubectl get persistent volumes
kgpv() {
    kubectl get pv "$@"
}

# Kubectl get persistent volume claims
kgpvc() {
    kubectl get pvc "$@"
}

# Kubectl get endpoints
kgep() {
    kubectl get endpoints "$@"
}

# Kubectl get replicasets
kgrs() {
    kubectl get replicasets "$@"
}

# Kubectl get statefulsets
kgss() {
    kubectl get statefulsets "$@"
}

# Kubectl get daemonsets
kgds() {
    kubectl get daemonsets "$@"
}

# Kubectl get jobs
kgj() {
    kubectl get jobs "$@"
}

# Kubectl get cronjobs
kgcj() {
    kubectl get cronjobs "$@"
}

# Kubectl edit
ked() {
    kubectl edit "$@"
}

# Kubectl patch
kpatch() {
    kubectl patch "$@"
}

# Kubectl get yaml
kgy() {
    kubectl get "$@" -o yaml
}

# Kubectl get json
kgj() {
    kubectl get "$@" -o json
}

# Kubectl wait for pod ready
kwait() {
    kubectl wait --for=condition=Ready pod "$@"
}

# Kubectl debug
kdebug() {
    kubectl debug -it "$@" --image=busybox
}

# Kubectl diff
kdiff() {
    kubectl diff -f "$@"
}

# Kubectl explain
kexplain() {
    kubectl explain "$@"
}

# Kubectl api resources
kapi() {
    kubectl api-resources "$@"
}

# Kubectl cluster info
kinfo() {
    kubectl cluster-info
}

# Kubectl version
kversion() {
    kubectl version "$@"
}

# Kubectl drain node
kdrain() {
    kubectl drain "$@" --ignore-daemonsets --delete-emptydir-data
}

# Kubectl cordon node
kcordon() {
    kubectl cordon "$@"
}

# Kubectl uncordon node
kuncordon() {
    kubectl uncordon "$@"
}

# Kubectl taint node
ktaint() {
    kubectl taint node "$@"
}

# Kubectl get pod with labels
kgpl() {
    kubectl get pods --show-labels "$@"
}

# Kubectl get pods by label
kgpbl() {
    kubectl get pods -l "$@"
}

# Kubectl logs from all pods in deployment
kld() {
    kubectl logs -l "app=$1" "$@"
}

# Kubectl restart deployment
krestart() {
    kubectl rollout restart deployment "$@"
}

# Kubectl create deployment
kcd() {
    kubectl create deployment "$@"
}

# Kubectl expose deployment
kexpose() {
    kubectl expose deployment "$@"
}

# Kubectl run pod
krun() {
    kubectl run "$@"
}

# Kubectl attach to pod
kattach() {
    kubectl attach -it "$@"
}

# Kubectl copy from pod
kcp_from() {
    kubectl cp "$1":"$2" "$3"
}

# Kubectl copy to pod
kcp_to() {
    kubectl cp "$1" "$2":"$3"
}

# Kubectl auth can-i
kauth() {
    kubectl auth can-i "$@"
}

# Kubectl get service accounts
kgsa() {
    kubectl get serviceaccounts "$@"
}

# Kubectl get roles
kgrole() {
    kubectl get roles "$@"
}

# Kubectl get cluster roles
kgcrole() {
    kubectl get clusterroles "$@"
}

# Kubectl get role bindings
kgrb() {
    kubectl get rolebindings "$@"
}

# Kubectl get cluster role bindings
kgcrb() {
    kubectl get clusterrolebindings "$@"
}

# Show pod resource usage
kres() {
    kubectl top pod "$1" --containers
}

# Get pod logs for all containers
klogs_all() {
    kubectl logs "$1" --all-containers=true
}

# Show failing pods
kfailing() {
    kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
}

# Show pending pods
kpending() {
    kubectl get pods --all-namespaces --field-selector=status.phase=Pending
}

# Quick pod shell
kshell() {
    local pod="$1"
    shift
    kubectl exec -it "$pod" -- "${@:-/bin/bash}"
}

# Get pod by partial name
kgpn() {
    kubectl get pods | grep "$1"
}

# Delete pods by pattern
kdelp_pattern() {
    kubectl get pods | grep "$1" | awk '{print $1}' | xargs kubectl delete pod
}

# Watch pods
kwp() {
    watch kubectl get pods "$@"
}

# Watch all resources
kwa() {
    watch kubectl get all "$@"
}

# Get external IP of service
ksvcip() {
    kubectl get svc "$1" -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

# Get node IPs
knodeips() {
    kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
}

# Show resource quotas
kquota() {
    kubectl get resourcequota "$@"
}

# Show limit ranges
klimit() {
    kubectl get limitrange "$@"
}

# Get pod with sorted by age
kgpage() {
    kubectl get pods --sort-by=.metadata.creationTimestamp
}
