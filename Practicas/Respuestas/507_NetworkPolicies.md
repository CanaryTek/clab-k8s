# Solucion de NetworkPolicies

  * NetworkPolicy de mysql:

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mysql-policy
spec:
  podSelector:
    matchLabels:
      name: mysql
  policyTypes:
  - Ingress
  - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            name: webapp-pod
      ports:
      - protocol: TCP
        port: 3306
  egress: []
```

  * NetworkPolicy de webapp

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-policy
spec:
  podSelector:
    matchLabels:
      name: webapp-pod
  policyTypes:
  - Ingress
  - Egress
  ingress:
    - from: []
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
      - podSelector:
          matchLabels:
            name: mysql
      ports:
        - protocol: TCP
          port: 3306
    - ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

