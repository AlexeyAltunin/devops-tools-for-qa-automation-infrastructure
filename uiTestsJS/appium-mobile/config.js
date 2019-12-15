const path = require('path');

// Leave the Android platformVersion blank and set deviceName to a random string
// (Android deviceName is ignored by Appium but is still required)
// If we're using SauceLabs, set the Android deviceName and platformVersion to
// the latest supported SauceLabs device and version
const DEFAULT_ANDROID_DEVICE_NAME = 'Android Emulator';
const DEFAULT_ANDROID_PLATFORM_VERSION = null;

const androidCaps = {
  platformName: 'Android',
  automationName: 'UiAutomator2',
  deviceName: process.env.ANDROID_DEVICE_NAME || DEFAULT_ANDROID_DEVICE_NAME,
  platformVersion: process.env.ANDROID_PLATFORM_VERSION || DEFAULT_ANDROID_PLATFORM_VERSION,
  androidInstallTimeout: 90000,
  app: undefined, // Will be added in tests
};

// figure out where the Appium server should be pointing to
const serverConfig = {
    host: process.env.APPIUM_HOST || 'localhost',
    port: process.env.APPIUM_PORT || 4723
  };


// figure out the location of the apps under test
const GITHUB_ASSET_BASE = 'http://appium.github.io/appium/assets';
const LOCAL_ASSET_BASE = path.resolve(__dirname, '..', '..', '..', 'apps');

let androidApiDemos;
if (true) {
  // TODO: Change thes URLs to updated locations
  androidApiDemos = `${GITHUB_ASSET_BASE}/ApiDemos-debug.apk`;
} else {
  androidApiDemos = path.resolve(LOCAL_ASSET_BASE, 'ApiDemos-debug.apk');
}

module.exports = {
  androidApiDemos,
  androidCaps,
  serverConfig,
};