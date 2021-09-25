const { SSL_OP_EPHEMERAL_RSA } = require('constants');
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({defaultViewport: {width: 1920, height: 1080}});
  const page = await browser.newPage();
  await page.goto('https://eventbrite.ca');
  await page.type('#locationPicker', 'Mississauga');
  // Xpath for the first Mississauga suggestion
  await page.waitForXPath('//*[@id="ChIJtwVr559GK4gR22ZZ175sFAM"]/div/button');
  await page.screenshot({path: 'example.png'});
  const [elements] = await page.$x('//*[@id="ChIJtwVr559GK4gR22ZZ175sFAM"]/div/button');
  await elements.click();
    await page.waitForTimeout(2000)

  // Xpath for the first event under Mississauga suggestion
//   await page.waitForXPath('//*[@id="panel0"]/div/div[1]/div[2]/div[1]/div/div/article/div[1]/div[1]/div/div[1]/a/h3/div/div[2]');
//   await page.screenshot({path: 'example2.png'})


// //   const elements = await page.$x('//*[@id="ChIJtwVr559GK4gR22ZZ175sFAM"]/div/button');
// //   await elements.click;
//   await page.keyboard.press('Enter');

//   await page.screenshot({path: 'example2.png'})

  await browser.close();
})();