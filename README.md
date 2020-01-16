Devops tools for qa automation infrastructure
========
The repo contains step by step guide how test automation infrastructure could 
be improved starting from running test locally to Infrastructure as Code (IaC) practices with using Cloud providers

**Plan**: 

1. Prepare web / mobile demo tests and run it locally ```Node.js, Selenium, Appium```

2. Docker based Tools ```Selenium grid, Selenoid (Web, Android)```

3. CI/CD system ```Gitlab CI```

4. Cloud platforms ```Google Cloud Platform```

5. Orchestration tool ```Kubernetes```

6. Infrastructure as a code tools ```Terraform, Ansible```

### 1. Prepare web / mobile demo tests and run it locally

The first step is just to prepare demo tests for web/android and run it locally.

**Preconditions:**
* Installed [Node.js](https://nodejs.org/en/)
* Installed [Chrome](https://www.google.com/intl/ru/chrome/)
* Installed [Appium](http://appium.io/docs/en/about-appium/getting-started/)
* Installed [Android emulator](https://developer.android.com/studio/run/emulator)

**Steps to execute tests:**
* Web
```
$ cd uiTestsJS/selenium-web
$ npm i
$ npm run demoTest
```
* Android
```
- start appium or Appium Desktop
- run Android simulator

$ cd uiTestsJS/appium-mobile
$ npm i
$ npm run demoTest
```


Be sure that tests are started and passed. We will not run it via local 
browsers/emulators anymore!

**Links:**
* [Selenium tests](https://github.com/SeleniumHQ/selenium/tree/master/javascript/node/selenium-webdriver/example)
* [Appium tests](https://github.com/appium/appium/tree/master/sample-code/javascript-wd)

**What could be used instead:**
* Any programming languages that you like for selenium/appium tests
* Any tests that you like
* Any test runner 

### 2. Docker based Tools

The second step is to run tests via popular docker based tools 

**Preconditions:**
* Installed / run [Docker](https://www.docker.com)
* Installed [Docker Compose](https://docs.docker.com/compose/install/)

**Steps to execute tests:**
* Selenium grid
```
$ cd dockerBasedTools/selenium-grid
$ docker-compose up -d                    // run selenium hub with nodes

- http://localhost:4444/grid/console      // open in browser

$ export REMOTE_HOST=http://localhost:4444/wd/hub

- run web tests from part 1

$ docker-compose down                     // stop/delete all containers
```
* Selenoid web
```
$ cd dockerBasedTools/selenoid-web
$ cat browsers.json                       // set browsers that you need, ex: selenoid/vnc:chrome_76.0
$ docker pull selenoid/vnc:chrome_76.0    // pull image  
$ docker-compose up -d                    // run selenoid server + ui

- http://localhost:8080/#/                // open in browser

$ export REMOTE_HOST=http://localhost:4445/wd/hub

- run web tests from part 1

$ docker-compose down                     // stop/delete all containers
```

* Selenoid Android 

["Android emulator can only be launched on a hardware 
server or a particular type of virtual machines supporting nested 
virtualization."](https://medium.com/@aandryashin/selenium-more-android-sweets-3839148d1bac)

["Docker for Mac does not forward KVM"](https://github.com/aerokube/selenoid/issues/687)

Instruction how to setup VM with KVM via GCP will be in part 4 of this guide.
```
$ cd dockerBasedTools/selenoid-android
$ cat browsers.json                   // set simulator that you need, ex: selenoid/android:6.0
$ docker pull selenoid/android:6.0    // pull image  
$ docker-compose up -d                // run selenoid server + ui

- http://localhost:8081/#/            // open in browser

$ export USE_SELENOID=true

- run android tests from part 1

$ docker-compose down                 // stop/delete all containers
```

**Links:**
* [docker-selenium](https://github.com/SeleniumHQ/docker-selenium)
* [selenoid](https://github.com/aerokube/selenoid)

**What could be used instead:**

Docker is the most popular container runtime environment.
[Though Docker still made up 83 percent of containers in 2018, that number is
 down from 99 percent in 2017.](https://containerjournal.com/topics/container-ecosystems/5-container-alternatives-to-docker/)
 However in this guide we can use docker as these tools for test running (Selenium grid, Selenoid) are docker based.


### 3. CI/CD system

The third step is to run tests via CI system (Gitlab CI) that will be setup 
locally . There will be 2 jobs to run test via selenium-grid and selenoid-web
. Android test will be executed in next step as we are going to setup GCP VM 
with KVM support.

**Preconditions:**
* Installed / run [Docker](https://www.docker.com)
* Installed [Docker Compose](https://docs.docker.com/compose/install/)

**Steps to execute tests:**

* Run Gitlab server
```
$ cd ci/gitlab-ci
$ cat docker-compose-gitlab-macos.yml                         // check volumes ex: /opt/gitlab/* , for MacOS the directory should be created manually and path should be added to docker File Sharing. For other systems the will be link at the and of the step.
$ docker-compose -f docker-compose-gitlab-macos.yml up -d     // can take some minutes until server is up
```

* Create project via UI
```
- open http://localhost/
- set password ex:12345678
- username: root
- open http://localhost/admin
- create a new project with name: local-run
- open http://localhost/root/local-run/-/settings/ci_cd
- open Variables 
- set Type: Variable, Key: WORK_DIRECTORY, Value: path to the current project ex: /Users/alexey/*/devops-tools-for-qa-automation-infrastructure/
- click Save variables
```

* Install/run gitlab-runner 
```
- open http://localhost/root/local-run/-/settings/ci_cd
- open Runners
- check instruction: Set up a specific Runner manually
```

input ex:
```
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://localhost/
Please enter the gitlab-ci token for this runner:
<TOKEN>
Please enter the gitlab-ci description for this runner:
[Mac-Mini-ALEXEY]: test
Please enter the gitlab-ci tags for this runner (comma separated):
local-run
Registering runner... succeeded                     runner=6tMT7ztw
Please enter the executor: custom, parallels, shell, ssh, docker+machine, docker-ssh+machine, docker, docker-ssh, virtualbox, kubernetes:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
```

```
$ cat ~/.gitlab-runner/config.toml  // be sure that added above changes are there

- be sure that runner tag is local-run as it is used in .gitlab-ci.yml

$ gitlab-runner start

- open http://localhost/root/local-run/-/settings/ci_cd
- open Runners
- check that runner is added and active
```

* Push pipeline configuration (.gitlab-ci.yml)
```
$ git clone http://localhost/root/local-run.git
$ cp .gitlab-ci.example.local.running.yml local-run/.gitlab-ci.yml
$ cd local-run/
$ git add .gitlab-ci.yml
$ git commit -m "add pipeline config"
$ git push

- open http://localhost/root/local-run/pipelines
- check that all jobs are passed (green)
- click on each job, check what was executed and compare with .gitlab-ci.yml

$ gitlab-runner stop                                      // stop runner
$ cd ../
$ docker-compose -f docker-compose-gitlab-macos.yml down  // stop gitlab
$ docker ps                                               // check there are not running containers
```

**Links:**
* [gitlab docs](https://docs.gitlab.com/)
* [install gitlab using docker compose](https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose)
* [gitlab runner docs](https://docs.gitlab.com/runner/)
* [gitlab ci yml](https://docs.gitlab.com/ee/ci/yaml/)

**What could be used instead:**

Whatever you like. CI/CD system is **key part** of test automation infrastructure but it is completely up to you to use that one that you like 
more or used by your company. 
 
 The most popular systems:
 
 * [Jenkins](https://jenkins.io/)
 * [TeamCity](https://jetbrains.ru/products/teamcity/)
 * [Bamboo](https://www.atlassian.com/software/bamboo)
 * [Travis](https://travis-ci.com/plans)
 
 
 ### 4. Cloud platforms (GCP)

The fourth step is to use Google Cloud Platform to run each docker based tool on separate VM:
* VM with Selenoid (web)
* VM with Selenoid (android) with KVM support
* K8s cluster with Selenium grid **(will be setup in the next step)**

Home work (in this step we will run it locally from step 3 setup): 
* VM with Gitlab server
* VM with gitlab runner 

**Preconditions:**
* Created [GCP account](https://console.cloud.google.com), use 300$ trial
* Created GCP project, ex: **devops-tools**
* Added [SSH keys](https://console.cloud.google.com/compute/metadata/sshKeys) that can be used to connect to the VM instances of a project
* Installed [gcloud](https://cloud.google.com/sdk/docs/)

**Steps to execute tests:**

* Create VM with Selenoid web
```
$ gcloud auth list                        // get account list
$ gcloud config set account `ACCOUNT`     // setup gcloud to use your account

// create instance:
$ gcloud compute instances create selenoid-web \
    --boot-disk-size=50GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags selenium \
    --preemptible \
    --restart-on-failure
``` 

* Access selenoid-web VM via SSH
```
$ ssh user@<instace_public_ip> -i ~/.ssh/publicKey
$ sudo su --
```

* Install docker, docker-compose, pull selenoid components
```
$ apt update
$ apt install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ apt update
$ apt-cache policy docker-ce
$ apt install docker-ce
$ systemctl status docker

$ docker pull selenoid/android:6.0
$ docker pull selenoid/vnc:chrome_76.0

$ curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
```  
  
* Clone the project with selenoid docker-compose
```
$ git clone https://github.com/AlexeyAltunin/devops-tools-for-qa-automation-infrastructure.git

- exit VM
```

* Create image for Selenoid Android with KVM support based on disk for selenoid-web
```
$ gcloud compute instances stop selenoid-web
$ gcloud compute images create docker--selenoid-kvm-vm-ubuntu-1604-image --source-disk selenoid-web --source-disk-zone europe-west4-a --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
```

* Create VM with Selenoid Android based on previously created KVM image
```
$ gcloud compute instances create selenoid-android \
    --boot-disk-size=50GB \
    --image docker-selenoid-kvm-vm-ubuntu-1604-image \
    --image-project=devops-tools-263410 \
    --machine-type=n1-standard-4 \
    --tags selenium \
    --preemptible \
    --restart-on-failure
```

* Access selenoid-android VM via SSH and [turn on KVM](https://www.server-world.info/en/note?os=Ubuntu_18.04&p=kvm&f=8) 
```
$ ssh user@<instace_public_ip> -i ~/.ssh/publicKey
$ sudo su --
$ cat /sys/module/kvm_intel/parameters/nested 
$ echo 'options kvm_intel nested=1' >> /etc/modprobe.d/qemu-system-x86.conf

- exit VM

$ gcloud compute instances stop selenoid-android
```

* Create firewall rules to open ports
```
$ gcloud compute firewall-rules create selenium-docker-based \
    --target-tags selenium \
    --source-ranges 0.0.0.0/0 \
    --allow tcp:4444,tcp:4445,tcp:4446,tcp:8080,tcp:5900,tcp:7070,tcp:9090,tcp:8081
```

* Start VMs 
```
$ gcloud compute instances list
$ gcloud compute instances start selenoid-web
$ gcloud compute instances start selenoid-android
```

* Run Selenoid web
```
$ ssh user@<instace_public_ip> -i ~/.ssh/publicKey
$ sudo su --
$ cd devops-tools-for-qa-automation-infrastructure/dockerBasedTools/selenoid-web/
$ docker-compose up -d

$ docker-compose ps
```

output:
```
selenoid-web_selenoid-ui_1_dd6873036cac   /selenoid-ui --selenoid-ur ...   Up (healthy)   0.0.0.0:8080->8080/tcp          
selenoid-web_selenoid_1_d8308aba93e6      /usr/bin/selenoid -listen  ...   Up             4444/tcp, 0.0.0.0:4445->4445/tcp
```

```
- exit from VM
- open in browser http://<instace_public_ip>:8080
```

* Run Selenoid Android
```
$ ssh user@<instace_public_ip> -i ~/.ssh/publicKey
$ sudo su --

- check KVM:

$ cat /sys/module/kvm_intel/parameters/nested 
- output: Y

$ cd devops-tools-for-qa-automation-infrastructure/dockerBasedTools/selenoid-android/
$ docker-compose up -d

$ docker-compose ps
```

output:
```
selenoid-android_selenoid-ui_1_888c3c8c22ed   /selenoid-ui --selenoid-ur ...   Up (healthy)   0.0.0.0:8081->8080/tcp          
selenoid-android_selenoid_1_cc45d1fd456d      /usr/bin/selenoid -listen  ...   Up             4444/tcp, 0.0.0.0:4446->4446/tcp
```

```
- exit from VM
- open in browser http://<instace_public_ip>:8080
```

* Run gitlab server and runner from part 3

* Push pipeline configuration (.gitlab-ci.yml)
```
$ git clone http://localhost/root/local-run.git

- open cloudProviders/gcp/.gitlab-ci.example.gcp.selenoid.web.android.yml and set <instace_public_ip> for each job

$ cp cloudProviders/gcp/.gitlab-ci.example.gcp.selenoid.web.android.yml local-run/.gitlab-ci.yml
$ cd local-run/
$ git add .gitlab-ci.yml
$ git commit -m "add pipeline config with selenoid web/android in GCP"
$ git push

- open http://localhost/root/local-run/pipelines
- check that all jobs are passed (green)
- click on each job, check what was executed and compare with .gitlab-ci.yml

$ gitlab-runner stop                                      // stop runner
$ cd ../
$ docker-compose -f docker-compose-gitlab-macos.yml down  // stop gitlab
$ docker ps                                               // check there are not running containers
```

* Stop VMs
```
$ gcloud compute instances stop selenoid-web
$ gcloud compute instances stop selenoid-android
```

**Links:**
* [GCP](https://cloud.google.com/)
* [Cloud SDK](https://cloud.google.com/sdk/docs/)

**What could be used instead:**

Whatever you like. Public cloud is very valuable and flexible part of 
automation infrastructure but it is completely up to you to use that provider that you like more or used by your company.  
 
 The most popular cloud providers:
 
 * [Amazon AWS](https://aws.amazon.com/)
 * [Microsoft Azure](https://azure.microsoft.com/en-us/)
 * [Openstack](https://www.openstack.org)
 
### 5.Orchestration tool (K8s)

The fifth step is to use Google Cloud Platform to run Selenium grid in Kubernetes cluster.

**Preconditions:**
* Enabled [Kubernetes Engine API](https://console.cloud.google.com/apis/library/)
* Installed [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

**Steps to execute tests:**

* create gcp cluster: 
```
$ gcloud container clusters create \
    --machine-type n1-standard-2 \
    --num-nodes 2 \
    --zone europe-west4-a \
    --cluster-version latest \
    selenium-grid   
```

* check kubectl context
```
$ gcloud container clusters get-credentials selenium-grid --zone europe-west4-a --project devops-tools-263410
$ kubectl config current-context
```

* create Selenium grid components
```   
$ cd cloudProviders/gcp/K8s/selenium/

$ kubectl create -f selenium-hub-deployment.yaml
$ kubectl create -f selenium-hub-svc.yaml
$ kubectl create -f selenium-node-chrome-deployment.yaml
```

* expose your hub via the internet
```
$ kubectl expose deployment selenium-hub --name=selenium-hub-external --labels="app=selenium-hub,external=true" --type=LoadBalancer
$ kubectl get svc selenium-hub-external // wait EXTERNAL-IP
```

* check self healing feature (delete pod and check that it is recreated)
```
$ kubectl get pods
```

output:
```
NAME                                    READY   STATUS    RESTARTS   AGE
selenium-hub-7ff45ff687-f4xr6           1/1     Running   0          43s
selenium-node-chrome-69fbcd9bf5-bn9nh   1/1     Running   0          37s
selenium-node-chrome-69fbcd9bf5-ttk4w   1/1     Running   0          37s
```

```
$ kubectl delete pod selenium-node-chrome-69fbcd9bf5-bn9nh
```

output:
```
$ pod "selenium-node-chrome-69fbcd9bf5-bn9nh" deleted
```

```
$ kubectl get pods
```

output:
```
NAME                                    READY   STATUS    RESTARTS   AGE
selenium-hub-7ff45ff687-f4xr6           1/1     Running   1          6m3s
selenium-node-chrome-69fbcd9bf5-qfz5c   1/1     Running   0          4m58s
selenium-node-chrome-69fbcd9bf5-ttk4w   1/1     Running   0          5m57s
```

* open browser and check scaling feature
```
- open http://<instace_public_ip>:4444/grid/console
- check there are 2 pods with chrome

$ kubectl scale deployment selenium-node-chrome --replicas=3  

- open http://<instace_public_ip>:4444/grid/console
- check there are 3 pods with chromes 

$ kubectl get pods
$ kubectl scale deployment selenium-node-chrome --replicas=2 // return back
```

* run tests from step 1
```
$ export REMOTE_HOST=http://<instace_public_ip>:4444/wd/hub

$ cd uiTestsJS/selenium-web
$ npm i
$ npm run demoTest
```

* open browser and check auto scaling feature (HorizontalPodAutoscaler)
```
$ kubectl autoscale deployment selenium-node-chrome --max 4 --min 1 --cpu-percent 1

$ run tests

- open http://<instace_public_ip>:4444/grid/console
- check that number of pods with chromes automatically increased 

$ kubectl get pods

$ kubectl get hpa selenium-node-chrome        // get created pod autoscaling
$ kubectl delete hpa selenium-node-chrome     // delete autoscaling 
```

* delete cluster (in the next step it will be recreated via Terraform)
```
$ gcloud container clusters delete selenium-grid
```

**Links:**
* [Kubernetes engine](https://cloud.google.com/kubernetes-engine/docs/)
* [Selenium grid K8s example](https://github.com/kubernetes/examples/tree/master/staging/selenium)
* [Medium Getting Started guide](https://medium.com/@subbarao.pilla/k8s-selenium-grid-selenium-grid-with-docker-on-kubernetes-42af8b9a2cba)
* [Scaling an application](https://cloud.google.com/kubernetes-engine/docs/how-to/scaling-apps)

**What could be used instead:**

You can use [any another way](https://kubernetes.io/docs/setup/) to get K8s cluster instead of GCP. 

The most popular Container Orchestration Tools:
 
 * [Docker Swarm](https://www.docker.com/products/docker-swarm)
 * [Marathon](https://mesosphere.github.io/marathon/)
 
 Instead of Selenium grid in K8s you can use [Moon:](https://aerokube.com/moon/latest/)

 "Moon is a browser automation solution compatible with Selenium Webdriver protocol and using Kubernetes to launch browsers."
 But [it takes money.](https://aerokube.com/moon/latest/#_pricing)
 
 ### 6. IaC
 
The sixth step is to use Infrastructure as code (IaC) practices and tools to create all that we did in previous 
steps by typing one magic command. We will use **Terrafrom** to create infrastructure in GCP (VMs, cluster, firewall 
etc) + 
Terraform will use **Ansible** as configuration management tool to install all required software. There we will setup, 
configure and run of Selenium-grid, Selenoid(web/android). 
To do the same to run Gitlab or any CI system is still your 
homework :)

**Preconditions:**
* Installed [Terrafrom](https://learn.hashicorp.com/terraform/getting-started/install.html)
* Installed [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Get [GCP project credential](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform) 
(generate file `IaC/terraform/account.json` analogically with `IaC/terraform/account.example.json`)
 
**Steps to execute tests:**

* set correct variables: 
```
- open IaC/terraform/variables.tf
- set correct public_key_path, private_key_path, project_name, ssh_user
```

* setup Ansible config to turn off host checking to avoid script getting stuck
```
- open /etc/ansible/ansible.cfg or ~/.ansible.cfg file:

[defaults]
host_key_checking = False
```
 
* apply terraform
```
$ cd IaC/terraform/
$ terraform init
$ terraform apply --auto-approve
```


output:
```
Cluster-Endpoint = 35.198.157.214
Selenoid-Android = http://35.234.100.248:8081/#/
Selenoid-Android-ssh = ssh alexey@35.204.80.129 -i ~/.ssh/devopsTools
Selenoid-Web = http://35.204.80.129:8081/#/
Selenoid-Web-ssh = ssh alexey@35.204.80.129 -i ~/.ssh/devopsTools
```

* apply terraform to setup selenium grid cluster
```
$ cd IaC/terraform/selenium-grid-k8s-resources
$ terraform init
$ terraform apply --auto-approve
```

output:
```
Selenium-Grid = http://35.198.143.162:4444/grid/console
```

That's all! It works like magic, save a lot of time and observable. You can start to run tests. Take your time to 
investigate *.tf files.

* destroy all resources after work to avoid wasting of money
```
$ cd IaC/terraform/selenium-grid-k8s-resources
$ terraform destroy --auto-approve

$ cd IaC/terraform/
$ terraform destroy --auto-approve
```

**Links:**
* [Terrafrom](https://www.terraform.io)
* [Ansible](https://docs.ansible.com)
* [Ansible and HashiCorp: Better Together](https://www.hashicorp.com/resources/ansible-terraform-better-together)
* [How to use Ansible with Terraform](https://alex.dzyoba.com/blog/terraform-ansible/)
* [Ansible Selenoid](https://github.com/SergeyPirogov/selenoid-ansible) instead of docker-compose that is used in this guide

**What could be used instead:**

Whatever you like again. Actually Ansible could be used instead of Terraform in a lot of cases and vice versa. But these
 tools have their specific destination. You can check comparison [here](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c).
 
 The most popular IaC tools:
 
 * [Chef](https://www.chef.io)
 * [Puppet](https://puppet.com)
 * [SaltStack](https://saltstack.com)
 * [CloudFormation](https://aws.amazon.com/cloudformation/)
 * [Vagrant](https://www.vagrantup.com)