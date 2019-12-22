Devops tools for qa automtion infrastructure
========
The repo contains step by step guide how test automation infrastructure could 
be improved starting from running test locally to Infrastructure as Code (IaC) practices with using Cloud providers

####Plan: 

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

More examples:
* [Selenium tests](https://github.com/SeleniumHQ/selenium/tree/master/javascript/node/selenium-webdriver/example)
* [Appium tests](https://github.com/appium/appium/tree/master/sample-code/javascript-wd)

What could be used instead:
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
