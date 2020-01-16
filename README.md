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

**Links:**
* [Selenium tests](https://github.com/SeleniumHQ/selenium/tree/master/javascript/node/selenium-webdriver/example)
* [Appium tests](https://github.com/appium/appium/tree/master/sample-code/javascript-wd)

**What could be used instead:**
* Any programming languages that you like for selenium/appium tests
* Any tests that you like
* Any test runner 