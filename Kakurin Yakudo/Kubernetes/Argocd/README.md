# Argocd (Legacy. Please Create Installation Shell Script)

## ArgoCD
```bash
# argocd namespace 생성
kubectl create namespace argocd
# argocd apply
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# argocd-server service의 타입을 NLB로 변경
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# NLB domain name 확인
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output .status.loadBalancer.ingress[0].hostname`
echo $ARGOCD_SERVER

# argocd 초기 비밀번호 확인
ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGO_PWD
```
