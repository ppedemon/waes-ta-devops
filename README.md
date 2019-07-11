# Waes Technical Assignment Devops
This project defines scripts required to deploy the [waes-ta](https://github.com/ppedemon/waes-ta) 
project to [Kubernetes](https://kubernetes.io/). For this I'm using a free single node cluster 
hosted by [IBM Cloud](https://www.ibm.com/cloud/).

Scripts in this projects are organized into three categories:

  1. [Helm](https://helm.sh/) setup, where we prepare the cluster to process Heml charts.
  2. Cluster provision, where we install waes-ta prerequisites.
  3. Deployment, where waes-ta is deployed.

## Helm Setup
At this stage we prepare the cluster to be able to process Helm charts. This amounts to 
configuring a [Tiller](https://helm.sh/docs/install/) service account in the cluster, 
and set the appropriate permissions for such account.

## Cluster Provision
The cluster is provisioned by installing a Keycloak server from a Helm chart.

Such chart is configured to to deploy to the cluster a Keycloak server with Postgress storage. 
The Keycloak server will be initialized with a predefined realm, and exposed to the outside world 
by means of a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) 
Kubernetes service at port `30900` on the cluster's single node external IP address.

You can execute the following to store in a `HOST` environment variable the external IP address of 
the cluster's node:

```bash
export HOST=`kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type == "ExternalIP")].address}'`
```

Having the external IP address at hand, the script `util/token.sh` can be used to create a `TOKEN` 
environment variable holding a waes-ta realm JWT:

```bash
source util/token.sh ${HOST}:30900
```

## Deploying Technical Assignment Code
We start by preparing the storage configuration. Storage will be provided by a three node 
MongoDB cluster hosted at [MongoDB Atlas](https://cloud.mongodb.com). The configuration 
for connecting to such cluster is defined in `config/staging.json`, and it's deployed as a 
file-based secret to the cluster.

We then deploy waes-ta by specifying a deployment asking for two active pods. Each pod includes
just a single [waes-ta Docker image](https://cloud.docker.com/repository/docker/ppedemon/waes-ta). 
Images are automatically submitted to Docker Hub by [waes-ta CI pipeline](https://github.com/ppedemon/waes-ta/blob/master/.travis.yml).

Lastly, We define yet another `NodePort` service to provide a uniform access point to the waes-ta API. 
The current cluster serves the API at `${HOST}:30800`. So after negotiating a token as explained above, 
you can execute for example:

```
curl -X PUT -H "Authorization: Bearer ${TOKEN}" -d $(echo Hi | base64) "http://${HOST}:30800/v1/diff/1/left"
```

Alternatively you can point your browser at the API's OAS 3.0 specification URL: `http://{$HOST}:30800/swagger`
to invoke the API using the Swagger UI.

## Todos
The main missing part is an [Ingress resource](https://kubernetes.io/docs/concepts/services-networking/ingress/) 
providing a externally reachable URL for the Rest API and more importantly, TLS termination.

The API uses bearer JWT authentication. Since JWTs are _signed_ but **not** _encrypted_, they must not
be exchanged in clear text form. This means we should be using HTTPS instead of HTTP. In a clustered
setting the proper way to embrace HTTPS is by configuring a secure Ingress with the proper private 
key and certificates for TLS termination.

Unfortunately IBM Cloud doesn't support Ingress on free clusters, so this is not implemented in the current 
solution. That's why I consider this cluster as a `staging` environment, instead of production ready.
