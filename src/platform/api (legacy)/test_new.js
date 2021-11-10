// import stabel from 'core-js/stable';
// import regenerator from 'regenerator-runtime';
const express = require('express');
const puppeteer = require('puppeteer');

const app = express();
const port = 3000;

// Location will be defined dynamically when calling the scraping using a controller. Using "Toronto" for testing.
const location = "Toronto"

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

app.get('/', (req, res) => {
    let eventsArray = [];
    (async () => {
        const webpageUrl = `https://www.eventbrite.ca/d/${location}/all-events/?page=1`;

        const browser = await puppeteer.launch({ headless: false });
        const page = await browser.newPage();
        await page.setViewport({
            width: 1920,
            height: 1080,
        });

        await page.goto(webpageUrl, { waitUntil: 'networkidle2' });
        await timeout(2000);

        eventsArray = await page.evaluate(async () => {
            const events = [];
            // for (let x = 1; x <= 3; x += 1) {
            for (let i = 1; i <= 20; i += 1) {
                console.log(i);
                const eventTitle = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy`);
                const eventDate = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > div`);
                const eventLoc = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div`);
                const cost = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(2)`);
                const organizedBy = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two`);
                const imgUrl = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.image-action-container > aside > a > div > div > img`);
                const eventUrl = document.querySelector(`#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a`);

                const newEvent = {
                    title: eventTitle ? eventTitle.innerText : '',
                    date: eventDate ? eventDate.innerText : '',
                    location: eventLoc ? eventLoc.innerText : '',
                    ticket: cost ? cost.innerText : '',
                    organization: organizedBy ? organizedBy.innerText : '',
                    img: imgUrl ? imgUrl.getAttribute('src') : '',
                    url: eventUrl ? eventUrl.getAttribute('href') : '',
                };

                if (
                    !(
                        newEvent.ticket.substring(0, 4) === 'Free' ||
                        newEvent.ticket.substring(0, 9) === 'Starts at'
                    )
                ) {
                    newEvent.ticket = '';
                }

                if (!(newEvent.title === '')) {
                    events.push(newEvent);
                }
            }
            // const button = document.querySelector("#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > footer > div > div > ul > li:nth-child(3) > button");
            // await button.click();
            // await timeout(2000);
            // }
            return events;
        });
        console.log(eventsArray);
        res.send(eventsArray);
        await browser.close();
    })();
});

app.listen(port, () => {
    console.log(`Eventbrite Webscraper API listening at http://localhost:${port}`);
});
