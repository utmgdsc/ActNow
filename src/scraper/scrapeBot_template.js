const puppeteer = require('puppeteer');

(async () => {
    // ADD WEBPAGE LINK HERE
    let webpageUrl = '';

    // SET HEADLESS TO TRUE TO NOT HAVE THE BROWSER OPEN
    let browser = await puppeteer.launch({ headless = false });
    let page = await browser.newPage();

    await page.goto(webpageUrl, { waitUntil: 'networkidle2' });

    const Event = await page.evaluate(() => {

        // ADD QUERIES INSIDE THE EMPTY STRINGS BELOW
        let eventTitle = document.querySelector('').innerText;
        let eventDate = document.querySelector('').innerText;
        let eventLoc = document.querySelector('').innerText;
        let eventImg = document.querySelector('').innerText;
        let eventDesc = document.querySelector('').innerText;

        return {
            title: eventTitle,
            date: eventDate,
            location: eventLoc,
            img: eventImg,
            description: eventDesc
        };
    })
    console.log(Event);

    await browser.close();
})