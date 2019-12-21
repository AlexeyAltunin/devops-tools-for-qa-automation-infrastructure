require('chromedriver');
const {Builder, By, Key, until} = require('selenium-webdriver');

describe('Google Search', function() {
  let driver;

  before(async function() {
    driver = new Builder()
      .forBrowser('chrome')
      .usingServer(process.env.REMOTE_HOST || '')
      .build();
  });

  it('demo', async function() {
    await driver.get('https://www.google.com/ncr');
    await driver.findElement(By.name('q')).sendKeys('webdriver', Key.RETURN);
    await driver.wait(until.titleIs('webdriver - Google Search'), 1000);
  });

  after(() => driver && driver.quit());
});
