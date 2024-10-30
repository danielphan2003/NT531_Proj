# NT531_Proj

## Setup guide

Để đơn giản hóa việc triển khai K8s trên máy tính, ta có thể sử dụng tool minikube để tạo máy ảo chứa sẵn K8s đã được triển khai:

```bash
# 1. Setup K8s using minikube. A virtual machine running on QEMU/KVM2 will be created.
minikube start --driver=kvm2 --cpus=6 --ram=8192
```

Lúc này máy ảo K8s đã sẵn sàng, ta sử dụng tool kubectl để định nghĩa các tài nguyên của ELK:

```bash
# 2. Create resource definitions needed to work with Elastic resources
kubectl create -f https://download.elastic.co/downloads/eck/2.14.0/crds.yaml
```

Sau đó ta triển khai một Elastic operator để hướng dẫn K8s cách để triển khai định nghĩa các tài nguyên của ELK:

```bash
# 3. Deploy an Elastic operator to instruct K8s how to deploy Elastic resources
$ kubectl apply -f https://download.elastic.co/downloads/eck/2.14.0/operator.yaml
```

Ta sử dụng tool Helm để quản lý các K8s template (Charts) phục vụ cho việc triển khai các tài nguyên khác một cách dễ dàng hơn, cụ thể là tài nguyên Elastic:

```bash
# 4. A Helm repository from Elastic with Charts (K8s templates) to deploy Elastic resources
$ helm repo add elastic https://helm.elastic.co
```

Cập nhật các Charts từ Elastic:

```bash
# 5. Update with Charts from Elastic
$ helm repo update
```

Triển khai ELK stack bằng template (Chart) của Elastic:

```bash
# 6. Install an eck-managed Elasticsearch, Kibana, Fleet Server, and managed Elastic Agents using custom values.
$ helm install eck-stack elastic/eck-stack --values k8s/elk/elk-stack-values.yaml -n elastic-stack --create-namespace
```

Cuối cùng để theo dõi quá trình triển khai ELK stack, ta dùng minikube để mở trang dashboard của K8s:

```bash
# 7. Open K8s dashboard to see the deployments
$ minikube dashboard
```

Lúc này mật khẩu truy cập ELK sẽ ở `http://127.0.0.1:<dashboard port>/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/secret/elastic-stack/elasticsearch-es-elastic-user?namespace=elastic-stack`

## Deploy a scenario

Either `1-single-tenant-app` or `2-multi-tenant-app` can be deployed.

```bash
$ podman build -t microbin-litefs:latest .
$ podman save -o microbin-litefs.tar microbin-litefs:latest
$ minikube image load microbin-litefs.tar
$ kubectl apply -f k8s/deploy/<scenario>
```
