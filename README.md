Devops tools for qa automtion infrastructure
========
The repo contains step by step guide how test automation infrastructure could 
be improved starting from running test locally to Infrastructure as Code (IaC) practices with using Cloud providers

###Plan: 

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
cd uiTestsJS/selenium-web
npm i
npm run demoTest
```
* Android
```
start appium or Appium Desktop
run Android simulator
cd uiTestsJS/appium-mobile
npm i
npm run demoTest
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
cd dockerBasedTools/selenium-grid
docker-compose up -d                    // run selenium hub with nodes
http://localhost:4444/grid/console      // open in browser
export REMOTE_HOST=http://localhost:4444/wd/hub

run web tests from part 1

docker-compose down                     // stop/delete all containers
```
* Selenoid web
```
cd dockerBasedTools/selenoid-web
cat browsers.json                       // set browsers that you need, ex: selenoid/vnc:chrome_76.0
docker pull selenoid/vnc:chrome_76.0    // pull image  
docker-compose up -d                    // run selenoid server + ui
http://localhost:8080/#/                // open in browser
export REMOTE_HOST=http://localhost:4445/wd/hub

run web tests from part 1

docker-compose down                     // stop/delete all containers
```

* Selenoid Android 

["Android emulator can only be launched on a hardware 
server or a particular type of virtual machines supporting nested 
virtualization."](https://medium.com/@aandryashin/selenium-more-android-sweets-3839148d1bac)

["Docker for Mac does not forward KVM"](https://github.com/aerokube/selenoid/issues/687)

Instruction how to setup VM with KVM via GCP will be in part 4 of this guide.
```
cd dockerBasedTools/selenoid-android
cat browsers.json                   // set simulator that you need, ex: selenoid/android:6.0
docker pull selenoid/android:6.0    // pull image  
docker-compose up -d                // run selenoid server + ui
http://localhost:8081/#/            // open in browser
export USE_SELENOID=true

run android tests from part 1

docker-compose down                 // stop/delete all containers
```

**Links:**
* [docker-selenium](https://github.com/SeleniumHQ/docker-selenium)
* [selenoid](https://github.com/aerokube/selenoid)

**What could be used instead:**

Docker is the most popular container runtime environment.
[Though Docker still made up 83 percent of containers in 2018, that number is
 down from 99 percent in 2017.](https://containerjournal.com/topics/container-ecosystems/5-container-alternatives-to-docker/)
 However in this guide we can use docker as these tools for test running (Selenium grid, Selenoid) are docker based.


### 3. CI/CD system (skip the step if you don't want to run it locally)

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
cd ci/gitlab-ci
cat docker-compose-gitlab-macos.yml                         // check volumes ex: /opt/gitlab/* , for MacOS the directory should be created manually and path should be added to docker File Sharing. For other systems the will be link at the and of the step.
docker-compose -f docker-compose-gitlab-macos.yml up -d     // can take some minutes until server is up
```

* Create project via UI
```
open http://localhost/
set password ex:12345678
username: root
open http://localhost/admin
create a new project with name: local-run
open http://localhost/root/local-run/-/settings/ci_cd
open Variables 
set Type: Variable, Key: WORK_DIRECTORY, Value: path to the current project ex: /Users/alexey/*/devops-tools-for-qa-automation-infrastructure/
click Save variables
```

* Install/run gitlab-runner 
```
open http://localhost/root/local-run/-/settings/ci_cd
open Runners
check instruction: Set up a specific Runner manually 

input ex:
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

cat ~/.gitlab-runner/config.toml  // be sure that added above changes are there
be sure that runner tag is local-run as it is used in .gitlab-ci.yml

gitlab-runner start
open http://localhost/root/local-run/-/settings/ci_cd
open Runners
check that runner is added and active
```

* Push pipeline configuration (.gitlab-ci.yml)
```
git clone http://localhost/root/local-run.git
cp .gitlab-ci.example.local.running.yml local-run/.gitlab-ci.yml
cd local-run/
git add .gitlab-ci.yml
git commit -m "add pipeline config"
git push

open http://localhost/root/local-run/pipelines
check that all jobs are passed (green)
click on each job, check what was executed and compare with .gitlab-ci.yml

gitlab-runner stop                                      // stop runner
cd ../
docker-compose -f docker-compose-gitlab-macos.yml down  // stop gitlab
docker ps                                               // check there are not running containers
```

**Links:**
* [gitlab docs](https://docs.gitlab.com/)
* [install gitlab using docker compose](https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose)
* [gitlab runner docs](https://docs.gitlab.com/runner/)
* [gitlab ci yml](https://docs.gitlab.com/ee/ci/yaml/)

**What could be used instead:**

Whatever you like. CI/CD system is **key part** of test automation infrastructure but it is completely up to you to use that one that you like 
more or used by your compony. 
 
 The most popular systems:
 
 * [Jenkins](https://jenkins.io/)
 * [TeamCity](https://jetbrains.ru/products/teamcity/)
 * [Bamboo](https://www.atlassian.com/software/bamboo)
 * [Travis](https://travis-ci.com/plans)
 