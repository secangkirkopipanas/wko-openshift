# From Traditional to Cloud-Native: Moving WebLogic to Red Hat OpenShift with WKO

Modernizing WebLogic involves moving away from manual console configurations and toward **Infrastructure as Code (IaC)**. The WebLogic Kubernetes Operator (WKO) simplifies this by managing the lifecycle of WebLogic Server instances within an OpenShift cluster as native Kubernetes objects.

---

## Install WebLogic Kubernetes Operator using Helm

The Operator acts as the "controller" for your environment. It handles complex tasks like starting/stopping servers, managing clusters, and performing rolling updates.

### Add the Helm Repository

First, pull the official Oracle charts. Adding the repository ensures you have access to the latest verified versions of the operator.

```
helm repo add weblogic-operator https://oracle.github.io/weblogic-kubernetes-operator/charts --force-update
helm repo list
```

### Create 'weblogic-operator' namespace for operator purpose

The operator should live in its own isolated namespace to separate management logic from your actual application workloads.

```
oc new-project weblogic-operator
```

### Create ServiceAccount for operator

For the operator to manage resources across the cluster, it needs a specific identity. This `ServiceAccount` will be granted the necessary permissions during the Helm installation.

```
oc create serviceaccount -n weblogic-operator weblogic-sa
```

### Install WKO with few custom arguments

When installing on OpenShift, specific flags are required to ensure compatibility with OpenShift's security constraints and routing.

- `javaLoggingLevel=FINE`: Increases verbosity for easier initial troubleshooting.
- `kubernetesPlatform=OpenShift`: Configures the operator to work with OpenShift-specific Security Context Constraints (SCC).
- `domainNamespaceLabelSelector`: Tells the operator to only manage namespaces that have a specific label, preventing it from interfering with other projects in the cluster.

```
helm install weblogic-operator weblogic-operator/weblogic-operator \
  --namespace weblogic-operator \
  --set "javaLoggingLevel=FINE" \
  --set "serviceAccount=weblogic-sa" \
  --set "kubernetesPlatform=OpenShift" \
  --set "domainNamespaceLabelSelector=weblogic-domain=true" \
  --wait
```

## Preparing the Domain Namespace

The Domain Namespace is the specific OpenShift project where your WebLogic Admin Server and Managed Servers will reside.

### Create the application namespace

Create the project and apply the label defined during the operator installation. This label acts as a "trigger" for the WKO to start monitoring this namespace.

```
oc new-project app1
oc label namespace app1 weblogic-domain=true
```

### Verify Namespace metadata

It is best practice to verify that the label was applied correctly. If this label is missing or mistyped, the operator will ignore any Domain resources you try to deploy here.

```
oc get namespace app1 --show-labels
```

### To check if the required configmap is auto created by WKO

Once the namespace is labeled, the WKO automatically injects a `ConfigMap` containing the helper scripts required to start and manage the WebLogic lifecycle. Finding this `ConfigMap` confirms that the operator has successfully recognized the namespace.

```
oc get configmap | grep weblogic-scripts-cm
```

