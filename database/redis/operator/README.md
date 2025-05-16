```shell
helm repo add ot-helm https://ot-container-kit.github.io/helm-charts/

# Deploy the redis-operator
helm upgrade redis-operator ot-helm/redis-operator \
  --install --create-namespace --namespace ot-operators

helm test redis-operator --namespace ot-operators

```
```shell
helm upgrade redis-cluster ot-helm/redis-cluster \
  --set redisCluster.clusterSize=3 \
  --set image.repository=registry.cn-hangzhou.aliyuncs.com/macroldj/redis \
  --set image.tag=v7.0.15 \
  --set imagePullSecrets[0].name=macroldj \
  --install \
  --namespace ot-operators
```

# 卸载
```shell
helm uninstall redis-cluster \
  --namespace ot-operators
```

```shell
kubectl exec -it redis-cluster-leader-0 -n ot-operators \
    -- redis-cli cluster nodes
```

```shell
kubectl delete pod redis-cluster-leader-0 -n ot-operators
```

```shell
kubectl exec -it redis-cluster-follower-1 -n ot-operators \
    -- redis-cli -c get tony
```
