const wd = require('wd');
const chai = require('chai');
const path = require('path');
const {androidCaps, serverConfig, androidApiDemos} = require(path.resolve(__dirname, 'config'));

const {assert} = chai;
const SEARCH_ACTIVITY = '.app.SearchInvoke';

describe('Basic Android interactions', function () {
  let driver;
  let allPassed = true;

  before(async function () {
    driver = await wd.promiseChainRemote(serverConfig)

    androidCaps.app = androidApiDemos
    androidCaps['appActivity'] = SEARCH_ACTIVITY, // Android-specific capability. Can open a specific activity.

    await driver.init(androidCaps);
  });

  it('should send keys to search box and then check the value', async function () {
    // Enter text in a search box
    const searchBoxElement = await driver.elementById('txt_query_prefill');
    await searchBoxElement.sendKeys('Hello world!');

    // Press on 'onSearchRequestedButton'
    const onSearchRequestedButton = await driver.elementById('btn_start_search');
    await onSearchRequestedButton.click();

    // Check that the text matches the search term
    const searchText = await driver.waitForElementById('android:id/search_src_text');
    const searchTextValue = await searchText.text();
    assert.equal(searchTextValue, 'Hello world!');
  });

  afterEach(function () {
    // keep track of whether all the tests have passed, since mocha does not do this
    allPassed = allPassed && (this.currentTest.state === 'passed');
  });

  after(async function () {
    await driver.quit();
  });
});