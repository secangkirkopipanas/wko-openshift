# From Traditional to Cloud-Native: Moving WebLogic to Red Hat OpenShift with WKO

## Install WebLogic Kubernetes Operator using Helm

### Add weblogic-operator repo into the repo list
```
helm repo add weblogic-operator https://oracle.github.io/weblogic-kubernetes-operator/charts --force-update
helm repo list
```

### Create 'weblogic-operator' namespace for operator purpose
```
oc new-project weblogic-operator
```

### Create ServiceAccount for operator
```
oc create serviceaccount -n weblogic-operator weblogic-sa
```

### Install WKO with few custom arguments
```
helm install weblogic-operator weblogic-operator/weblogic-operator \
  --namespace weblogic-operator \
  --set "javaLoggingLevel=FINE" \
  --set "serviceAccount=weblogic-sa" \
  --set "kubernetesPlatform=OpenShift" \
  --set "domainNamespaceLabelSelector=weblogic-domain=true" \
  --wait
```

## Preparing Domain Namespace

### Create new domain namespace for application
```
oc new-project app1
oc label namespace app1 weblogic-domain=true
```

### To check if the required label to make it a domain namespace is successfully added
```
oc get namespace app1 --show-labels
```

### To check if the required configmap is auto created by WKO
```
oc get configmap | grep weblogic-scripts-cm
```

