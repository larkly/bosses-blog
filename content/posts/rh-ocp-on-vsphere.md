---
title: "Automating installation of Red Hat OpenShift 4 on VSphere"
date: 2023-03-04
postkind: Technical
dek: "My writedown of a howto for installing OCP on VMware. I'd avoid that whole thing unless you have to."
toc: true
tags: [howto, openshift, technical]
categories: [Howto]
hideOnHome: true
dropcap: false
---

## Prerequisites
- Infrastructure set up and available
  - VLANs
  - Load balancers (API + apps)
  - Remote access (to bastion/jumphost)
  - Firewalls
- VMware vSphere set up and ready
- Bastion host installed and configured

## Download auth file from Red Hat and modify it to disable telemetry
:dart: **BASTION**

Log on to https://cloud.redhat.com with a Red Hat account with the proper subscriptions attached, or get it from someone with such access. The auth file is
JSON file containing tokens providing access to vendor registries.

The JSON file contains a reference to cloud.redhat.com. This needs to be removed in order to disable OpenShift's telemetry option where an unacceptable
amount of data about the cluster is shared with the vendor.

`jq -c 'del(.["auths"]["cloud.openshift.com"])' authfile.json > new-authfile.json`

The cluster type to be created is bare metal user-provisioned infrastructure (UPI).

## Download openshift-installer and openshift client (oc)
:dart: **BASTION**

Log on to https://cloud.redhat.com with a Red Hat account with the proper subscriptions attached, or get it from someone with such access in order to get
updated download URLs.

- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux.tar.gz
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz

## Download Red Hat Core OS OVA template
:dart: **BASTION**

Fetch the latest version (https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/) of the OVA template. This template must be added to
the vCenter Content Library. The OVA template is then used to create a VM, which is used as the source when creating a new VM later in these
instructions. After cloning it to VM, mark the VM as a template.

The template should be placed in vc01.example.com > ocp > templates. Name it accordingly, e.g.: rhcos-4.9

Do not start the VM after it is generated from the OVA template. It will taint the disk and it can not be used a source for new VMs. This is why you'll mark the
VM as a template after it is cloned from the OVA template.

## Generate a ED25519 SSH key
:dart: **BASTION**

`ssh-keygen -t ed25519 -f <destination>`

## Create the install-config.yaml file
:dart: **BASTION**

Fill out the install-config.yaml with required information

- The file *must* be named install-config.yaml
- Be aware that when this file will be deleted by the create manifest operation later, so keep a copy around
- Review IP ranges as these can not be changed after installation. They must not be in use elsewhere in the organization (other than other Kubernetes clusters)
- Verify that the noProxy IPs include the LB VIPs and (importantly) the vCenter IP
- Verify that the noProxy IPs includes 169.254.0.0/16
- networkType can be either OpenShiftSDN or OVNKubernetes, but there has been varying issues with installing with OVN. It will be the default SDN in OpenShift 4.8, so a migration path is already documented by the vendor, but due to the installation issues avoid installing it for now.
- PS: noProxy auto-adds several entries automagically:, node, cluster and service CIDRs, localhost, internal API url (e.g. api-int.ocp.example.com), .cluster.local and .svc. (Source: [link1](https://github.com/openshift/installer/blob/41523104b2907648e9aa357b50de557712b90c9d/pkg/asset/manifests/proxy.go#L108-L112) [link2](https://github.com/openshift/cluster-network-operator/blob/c02b3c8a1d9afa953fe42b5dedf5c62881b7c468/pkg/util/proxyconfig/no_proxy.go#L17-L21))

```
apiVersion: v1
baseDomain: lab.example.com
proxy:
  httpProxy: http://proxy.example.com:3128
  httpsProxy: http://proxy.example.com:3128
  noProxy: <bastion>,.example.com,10.,192.168.,10.20.30.40,10.20.30.0/24
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ocp1
networking:
  clusterNetwork:
  - cidr: 10.229.0.0/16
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  vsphere:
  vcenter: address.to.vcenter.api
  username: username@vsphere.local
  password: password
  datacenter: DCxx
  defaultDatastore: datastorename
fips: false
pullSecret: '<auth json from above>'
sshKey: '<ssh pubkey from above>'
```

## Create manifests
:dart: **BASTION**

Create <manifestdir>, and copy the install-config.yaml into <manifestdir>
mkdir /path/to/manifest

```
cp install-config.yaml /path/to/manifest
openshift-install create manifests --dir=/path/to/manifest
```

> [!WARNING]
> This install-config.yaml in /path/to/manifest will be deleted as part of the conversion to manifest files

### Remove master Machine and worker MachineSet files

Delete the master Machine and worker MachineSet files - these are generated because the installer assumes that we're using installer-provisioned
infrastructure (IPI) while we're actually using user-provisioned infrastructure (UPI)

```
cd /path/to/manifest
rm openshift/99_openshift-cluster-api_master-machines-* openshift/99_openshift-cluster-api_worker-machineset-0.
yaml
```

### Modify master schedulability
Modify the cluster-scheduler-02-config.yml file so that the masters won't schedule normal workloads when the cluster starts up.

> [!NOTE]
> This can be ignored if you're building a small test cluster with only three nodes.
> It can be changed later by modifying the configuration of the running cluster, but in this case the master nodes will need to be evicted or rebooted one by one to remove these workloads.

```
cd /path/to/manifest
sed -i 's,mastersSchedulable: true,mastersSchedulable: false,g' manifests/cluster-scheduler-02-config.yml
```

Add NTP configuration as MachineConfig
BASTION
The NTP configuration needs to be applied as MachineConfigs, with the /etc/chrony.conf as a base64 string. The same base64-string can be applied to
both files.

```
echo """pool 10.123.30.25
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony""" | base64 -w0

cG9vbCAxMC4xMjMuMzAuMjUKZHJpZnRmaWxlIC92YXIvbGliL2Nocm9ueS9kcmlmdAptYWtlc3RlcCAxLjAgMwpydGNzeW5jCmxvZ2RpciAvdmFyL2xvZy9jaHJvbnkK
```

Place the following files under: /path/to/manifest/openshift

```yaml title="99-masters-chrony-configuration.yaml"
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 99-masters-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 3.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
        source: data:text/plain;charset=utf-8;base64,cG9vbCAxMC4xMjMuMzAuMjUKZHJpZnRmaWxlIC92YXIvbGliL2Nocm9ueS9kcmlmdAptYWtlc3RlcCAxLjAgMwpydGNzeW5jCmxvZ2RpciAvdmFyL2xvZy9jaHJvbnkK
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
  osImageURL: ""
```

```yaml title="99-workers-chrony-configuration.yaml"
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-workers-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 3.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
        source: data:text/plain;charset=utf-8;base64,cG9vbCAxMC4xMjMuMzAuMjUKZHJpZnRmaWxlIC92YXIvbGliL2Nocm9ueS9kcmlmdAptYWtlc3RlcCAxLjAgMwpydGNzeW5jCmxvZ2RpciAvdmFyL2xvZy9jaHJvbnkK
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
  osImageURL: ""
```

## Create ignition files
:dart: **BASTION**

The ignition files are what we will provide to the nodes to allow them to configure themselves as part of the bootstrapping process. This will also generate
authentication files for the cluster.

> [!WARNING]
> - The manifest files will be removed as part of the conversion to ignition files.
> - Do not lose these ignition and auth files, as they are required to scale up the cluster in the future.

## Configure the cluster identifier in vSphere directory
:dart: **VCENTER**

When the ignition files are created, a unique identifier is generated in the metadata.json file. This identifier needs to be used to create a directory in vSphere and in the common config in the Ansible playbook.

```
jq .infraID /path/to/manifests/metadata.json

"ocp1-f9lkm"
```

> [!WARNING]
> Concequences of skipping this part is that VMware integrations will not work until the folder is renamed, like storage provisioning towards VMDK, or that OpenShift will not delete worker nodes from the cluster that's deleted from vCenter.

## Convert the ignition files to base64
:dart: **BASTION**

The ignition files needs to be applied as base64-formatted variables in vCenter to the Red Hat CoreOS template.

```
cd /path/to/manifests
for foo in master worker bootstrap; do base64 -w0 ${foo}.ign > ${foo}.64; done
```

## Create DNS A and PTR records for all required nodes and load balancer VIPs
:dart: **NAMESERVER**

> [!WARNING]
> This is very important to do right. Double check DNS entries before installing the cluster. Nodes will name themselves in the cluster based on the PTR record during the first boot, and changing this later is not straightforward.

In this implementation, the DNS will be handled by a private DNS server with dnsmasq. It can also be handled by the generic DNS if that is feasible.

In /etc/dnsmasq.conf on the nameserver, every node and VIP has an address and a ptr-record entry.



```title="nameserver:/etc/dnsmasq.conf"
local=/.ocp2.lab.example.com/
local=/.30.20.10.in-addr.arpa./
listen-address=127.0.0.1,10.20.30.40
...
address=/worker6.ocp2.lab.example.com/10.20.30.10
ptr-record=10.30.20.10.in-addr.arpa.,"worker6.ocp2.lab.example.com"
...
```

## Create Ansible playbook for provisioning nodes
:dart: **BASTION**

Create an ansible subdirectory and create the playbook file playbook.yaml in it.

> [!CAUTION]
> There is one important reason why we're using Ansible for provisioning the nodes, and it's not just because it saves time. The main reason is because the variables (needed for configuring the nodes) that can be entered through the vCenter GUI is limited to 64K, while the bootstrap ignition file is about 300K. Similar limitations also applies to the govc CLI. If later researching alternative ways for automating this process (for example with Terraform) this variable limitation needs to be explicitly verified.

> [!WARNING]
> This playbook is currently **not idempotent after the cluster has storage workloads**, due to how VMware provisions storage by attaching VMDKs to the nodes, and this playbook conflicts with those mounts. After the cluster is created, comment out nodes that has been provisioned before using the playbook again later, i.e. to add more worker or infra nodes.
> If the playbook is run with nodes uncommented on a cluster with VMDK storage workloads attached to pods, the PVs in the cluster may be screwed up.
> This doesn't apply if another storage solution is applied (like Ceph or NetApp) as these are not interfacing with the hypervisor, and won't be affected by this playbook.

<!--
> [!NOTE]
> **Notes about how "kickstart" works**
> To better understand how the provisioning process works, in case there is an issue with it, some notes are written to help other understand the process when they at some point will have an issue with it.
> 
> The RHCOS OVA template used for installation uses cloud-init as a config source when the cloned VM is started for the first time. This support enables FIXME
-->

```yaml title="/path/to/ansible/playbook.yaml"
- hosts: localhost
  vars_files:
    - vars/bootstrap.yaml
    - vars/master.yaml
    - vars/worker.yaml
  vars:
    vsphere:
      vcenter_hostname: vcenter.address
      vcenter_username: username@vsphere.local
      vcenter_password: password
      datacenter_name: DCXX
      cluster_name: vcenter-clustername
      target_folder: 'ocp1-xxxxx'
      template_name: 'rhcos-4.9'
  tasks:
    - name: 'Create a virtual machine from the template'
      vmware_guest:
        hostname: '{{ vsphere.vcenter_hostname }}'
        username: '{{ vsphere.vcenter_username }}'
        password: '{{ vsphere.vcenter_password }}'
        datacenter: '{{ vsphere.datacenter_name }}'
        cluster: '{{ vsphere.cluster_name }}'
        folder: '{{ vsphere.target_folder }}'
        name: '{{ item.name }}'
        template: '{{ vsphere.template_name }}'
        advanced_settings:
          - key: guestinfo.ignition.config.data.encoding
            value: base64
          - key: guestinfo.ignition.config.data
            value: '{{ item.ignite }}'
          - key: disk.EnableUUID
            value: 'TRUE'
          - key: 'guestinfo.afterburn.initrd.network-kargs'
            value: 'ip={{ item.ip }}::{{ item.gw }}:{{ item.mask }}:::none nameserver=<nameserver ip>'
        disk:
          - size_gb: "{{ item.disk }}"
            type: thin
            datastore: datastore01
        hardware:
          memory_mb: "{{ item.mem }}"
          num_cpus: "{{ item.cpu }}"
          scsi: paravirtual
          hotadd_cpu: False
          hotremove_cpu: False
          hotadd_memory: False
          version: 19
        networks:
          - name: '{{ item.network }}'
            start_connected: yes'
            type: static
        validate_certs: False
        #state: poweredon
        state: present
        #state: absent
      with_items:
        - { name: bootstrap.ocp2.domain.name, ip: 10.20.6.102, gw: 10.20.6.97, mask: 255.255.255.240, disk: 120, mem: 65536, cpu: 16, network: 'VLAN-1234-XXXX-MASTER2', ignite: "{{ b_ignite }}" }
        - { name: master0.ocp2.domain.name, ip: 10.20.6.98, gw: 10.20.6.97, mask: 255.255.255.240, disk: 120, mem: 16384, cpu: 8, network: 'VLAN-1234-XXXX-MASTER2', ignite: "{{ m_ignite }}" }
        - { name: master1.ocp2.domain.name, ip: 10.20.6.99, gw: 10.20.6.97, mask: 255.255.255.240, disk: 120, mem: 16384, cpu: 8, network: 'VLAN-1234-XXXX-MASTER2', ignite: "{{ m_ignite }}" }
        - { name: master2.ocp2.domain.name, ip: 10.20.6.100, gw: 10.20.6.97, mask: 255.255.255.240, disk: 120, mem: 16384, cpu: 8, network: 'VLAN-1234-XXXX-MASTER2', ignite: "{{ m_ignite }}" }
        - { name: infra0.ocp2.domain.name, ip: 10.20.6.66, gw: 10.20.6.65, mask: 255.255.255.240, disk: 64, mem: 65536, cpu: 16, network: 'VLAN-1111-XXXX-INFRA2', ignite: "{{ w_ignite }}" }
        - { name: infra1.ocp2.domain.name, ip: 10.20.6.67, gw: 10.20.6.65, mask: 255.255.255.240, disk: 64, mem: 65536, cpu: 16, network: 'VLAN-1111-XXXX-INFRA2', ignite: "{{ w_ignite }}" }
        - { name: worker0.ocp2.domain.name, ip: 10.20.7.4, gw: 10.20.7.1, mask: 255.255.255.0, disk: 64, mem: 65536, cpu: 16, network: 'VLAN-2222-XXXX-WORKER2', ignite: "{{ w_ignite }}" }
        - { name: worker1.ocp2.domain.name, ip: 10.20.7.5, gw: 10.20.7.1, mask: 255.255.255.0, disk: 64, mem: 65536, cpu: 16, network: 'VLAN-2222-XXXX-WORKER2', ignite: "{{ w_ignite }}" }
```

## Create Ansible variable files based on the base64 ignite configs
:dart: **BASTION**

These ignition configs will be available for Ansible, depending on the role defined by the ignite-parameter in the with_items list above.

```
echo "b_ignite: '$(cat /path/to/manifests/bootstrap.64)'" > /path/to/ansible/vars/bootstrap.yaml
echo "m_ignite: '$(cat /path/to/manifests/master.64)'" > /path/to/ansible/vars/master.yaml
echo "w_ignite: '$(cat /path/to/manifests/worker.64)'" > /path/to/ansible/vars/worker.yaml
```

## Install required Python prerequisites for vSphere integration in Ansible
:dart: **BASTION**

```
yum install python3
pip3 install pyvmomi
```

## Run playbook to create nodes
:dart: **BASTION**

```
cd /path/to/ansible
ansible-playbook playbook.yaml
```

> [!TIP]
> If Ansible groans about interpreter, try adding `-e 'ansible_python_interpreter=/usr/bin/python3'` to the command above.

## Start bootstrap and master node and verify that it has started up properly
:dart: **VCENTER** **LOADBALANCER**

First, start the bootstrap node in vCenter, and go into the VM console to monitor the boot process. If it arrives at the login prompt with correct IP address specified, you can assume it has booted properly.
Verify on the load balancer that it has entered the pool. Only then, start the master nodes in vCenter and go into the VM console to monitor the boot process in the same way as with the bootstrap node.

## Wait for the bootstrap process to complete
:dart: **BASTION**

Use the openshift-installer utility to get feedback when the cluster has been bootstrapped.
`openshift-install wait-for bootstrap-complete --dir=/path/to/manifests`
When the bootstrap is finished, set the environment variable to point to the kube-admin KUBECONFIG:
`export KUBECONFIG=/path/to/manifests/auth/kubeconfig`
Run oc get nodes to verify that the API can be accessed and that the masters are in a "Ready" state.

## Stop and delete the bootstrap node
:dart: **VCENTER**

Right click the bootstrap node in vCenter and forcibly stop it, then delete it. It is not needed anymore.

> [!WARNING]
> Do not do this before all three masters have joined the cluster and is in a "Ready" state

## Start worker/infra nodes and authorize them to join the cluster
:dart: **VCENTER** **BASTION**

Start the nodes in vCenter, then check for CSR that need to be approved

`oc get csr`

When there are certificates pending, approve them all with

`oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs --no-run-if-empty oc adm certificate approve`

There are several certificates that need to be approved for each node. Rerun the approve command above to approve them all.

> [!WARNING]
> **Security note**
> In proper operations, each CSR should be verified that it is legitimate and expected. The current procedure described above does not verify anything. However, the CSR wouldn't be submitted unless the node has presented a proper certificate from the ignition file, so the risk for approving illegitimate requests is pretty low. It would be beneficial to include some output of CSR data fields in the command above.
> If some certificates aren't signed, OpenShift will resubmit new CSRs every hour. Each such certificate needs to be signed even though it's for the same node, according to the documentation.

Verify that the nodes eventually join the cluster and go into a "Ready" state (or new certicates pop in) with:

`watch -n1 'oc get nodes; oc get csr'`

## Label worker nodes to allow them to handle egress traffic
:dart: **BASTION**

When using EgressIP, we need a set of nodes to handle routing of traffic out from the cluster. All outgoing traffic must be from the worker nodes.

The following command will label all worker nodes as able to host egress traffic.

`oc label nodes -l node-role.kubernetes.io/worker="" k8s.ovn.org/egress-assignable=""`

## Configure build proxy settings
:dart: **BASTION**

By default the build containers in OpenShift does not use proxy settings, which will in most cases make the build process fail as they don't have a route to
get external resources/dependencies.

Update the cluster-wide build.config object to use the same proxy settings set on the cluster level. Restrict builds to worker nodes.

```bash title="Update build config settings"
OCP_HTTP_PROXY=$(oc get proxy cluster -o json | jq '.spec.httpProxy')
OCP_HTTPS_PROXY=$(oc get proxy cluster -o json | jq '.spec.httpsProxy')
OCP_NO_PROXY=$(oc get proxy cluster -o json | jq '.status.noProxy')

oc patch build.config cluster --type merge --patch "
{\"spec\":{
    \"buildDefaults\": {
        \"defaultProxy\": {
            \"httpProxy\": $OCP_HTTP_PROXY ,
            \"httpsProxy\": $OCP_HTTPS_PROXY ,
            \"noProxy\": $OCP_NO_PROXY
            }
        },
        \"buildOverrides\": {
            \"nodeSelector\": {
                \"node-role.kubernetes.io/worker\": \"\"
            }
        }
    }}"
```

Note that NO_PROXY uses the status entry, not the spec entry. The reason for that is that Openshifts adds platform-known CIDRs and hostnames.

## Log in to the cluster web GUI with the kubeadmin password
:dart: **BROWSER**

Find the URL with

`oc get route -n openshift-console`

Log in with user kubeadmin. Password is in the /path/to/manifests/auth/kubeadmin-password file.

## Check cluster operator status
:dart: **BROWSER**

Go to Administration > Cluster Settings > ClusterOperators. 

Sort list by status and monitor operators not in "Available" status.

## Configure authentication
:dart: **BROWSER** **BASTION**

Go to Administration > Cluster settings > Global configuration and select OAuth.

Define an authorization based on requirements (OIDC, LDAP etc). Temporary access can be provided through the htpasswd provider.

### htpasswd
Install httpd-utils on the bastion, and create a htpasswd file with credentials

```
yum -y httpd-utils
htpasswd -B /path/to/htpasswd username
```

You can enter this password into the authentication provider mentioned before. If the htpasswd provider is already defined and you need to edit it (add/modify/delete users), you need to update the htpasswd secret in openshift-config

### LDAP
For manual configuration, use the GUI through Administration > Cluster Settings > Global Configuration > OAuth and add an LDAP provider, or use add an LDAP entry to the spec.identityProviders of the OAuth.config.openshift.io

```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
    - ldap:
      attributes:
        email:
          - mail
        id:
          - sAMAccountName
        name:
          - cn
        preferredUsername:
          - sAMAccountName
        bindDN: '...'
        bindPassword:
          name: ldap-bind-password-kxp5s
        ca:
          name: ldap-ca-kjxnk
          insecure: false
        url: 'ldaps://ldap.example.com:636/OU=UsersOU,DC=dc1,DC=example,DC=com?sAMAccountName?sub'
      mappingMethod: claim
      name: LDAP
      type: LDAP
```

- The bindPassword secret is in the openshift-config namespace and has the key bindPassword
- The LDAP CA configmap is in the openshift-config namespace and has the key ca.crt

## Remove the kubeadmin user
:dart: **BASTION**

> [!CAUTION]
> Do **not** do this before additional authentication providers are in place

When one or more authentication providers has been provided, the kubeadmin access can be removed

`oc delete secrets kubeadmin -n kube-system`

Docs: https://docs.openshift.com/container-platform/4.8/authentication/remove-kubeadmin.html

## Verify that the installer has configured vSphere storage properly
:dart: **BROWSER**

- Go to Storage > PersistentVolumeClaims > Create PersistentVolumeClaim
- Create a 1GB or so test volume
- Verify that it gets provisioned (bound)

## Enable the internal image registry
:dart: **BASTION**

When installing UPI on platforms without available shared (ReadWriteMany) storage, the internal registry will be *removed*. After shared storage capabilities has been added to the cluster, the registry can be reenabled if desired. If external registries like Harbor is in use as part of a strengthened container supply chain, the internal registry may be omitted.

> [!CAUTION]
> This part of this documentation has issues with how registry is scheduled, and needs more information related to ReadWriteMany storage on the pods, which is storage dependant. Refer to the [documentation](https://docs.openshift.com/container-platform/4.8/registry/configuring_registry_storage/configuring-registry-storage-vsphere.html).

```
echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: image-registry-storage
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 250Gi
  storageClassName: nfs
  volumeMode: Filesystem' | oc create -f -

oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch {"spec":{"managementState":"Managed","storage":{"pvc":{"claim":"image-registry-storage"}}}}
```

## Optional: Disable IPv6 platform wide
:dart: **BASTION**

If IPv6 is not desired to run on the nodes, it must be disabled expliclity by modifying the CoreOS kernel parameters. This is done through a MachineConfig definition.

```bash title="Create Machineconfig for IPv6"
echo '---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-openshift-machineconfig-worker-kargs
spec:
  kernelArguments:
    - ipv6.disable=1
---
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 99-openshift-machineconfig-master-kargs
spec:
  kernelArguments:
    - ipv6.disable=1
' | oc apply -f -
```

