## Bluescape Helm Repo

- **bluescape-eks-aux**
    * vault-custom-resource templates
    * cert-manager-cluster-issuer templates
    * external-secret templates
    * kubeDB catalogs (mongodb 3.6.13, mongodb 4.0.11, mysql 5.6, postgres 11.1)
    
- **bluescape-monitoring-crds**
    * For deploying monitoring CRDs to enable servicemonitors.

- **bluescape-monitoring-dashboards**
    * Custom dashboards created for Bluescape Application Stack.
    * Monitoring for infrastructure components.

- **bluescape-monitoring-grafana**
    * For customized dashboard for the namespaces.

- **cortex-helm-chart**
    * Cortex: https://github.com/cortexproject/cortex-helm-chart
    * Memcached : https://artifacthub.io/packages/helm/bitnami/memcached
    
- **kube-oidc-proxy**
    * https://github.com/jetstack/kube-oidc-proxy/tree/master/deploy/charts/kube-oidc-proxy

- **gatekeeper-policy-manager**
    * Gatekeeper Policy Manager is a simple read-only web UI for viewing OPA Gatekeeper 
      policies status in a Kubernetes Cluster.
        - Reference: https://github.com/sighupio/gatekeeper-policy-manager

- **host-redirect**
    * [README.md](/helm-chart-sources/host-redirect/README.md) 

- **istio-additions**
    * For deploying supporting configurations for Istio Service Mesh.

#### Ported for internal hosting to address Helm chart deprecation issue.
  - **dex**
  - **gangway**
  - **oauth2-proxy**
