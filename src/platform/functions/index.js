const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Cluster } = require('puppeteer-cluster');

admin.initializeApp();

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

exports.scrapeEventGiveCity = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '1GB',
  })
  .https.onRequest(async (req, res) => {
    functions.logger.info('Starting to scrape...');
    let eventsArray = [];
    let collectiveEventsArray = [];

    let city = '';
    if (req.method === 'GET') {
      if (req.query.city && req.query.city.length !== 0) {
        city = req.query.city;
        functions.logger.info('City: ' + city);
      } else {
        return functions.logger.error('No city name provided');
      }
    }

    const cluster = await Cluster.launch({
      concurrency: Cluster.CONCURRENCY_CONTEXT,
      maxConcurrency: 3,
    });

    await cluster.task(async ({ page, data: webpageUrl }) => {
      await page.setViewport({
        width: 1920,
        height: 1080,
      });

      await page.goto(webpageUrl, { waitUntil: 'networkidle2' });
      await timeout(2000);

      eventsArray = await page.evaluate(async () => {
        const events = [];
        // for (let x = 1; x <= 3; x += 1) {
        for (let i = 1; i <= 60; i += 1) {
          // console.log(i);
          const eventTitle = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a > h3 > div > div.eds-event-card__formatted-name--is-clamped.eds-event-card__formatted-name--is-clamped-three.eds-text-weight--heavy`,
          );
          const eventDate = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > div`,
          );
          const eventLoc = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(1) > div`,
          );
          const cost = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(2)`,
          );
          const organizedBy = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--organizer.eds-text-color--ui-800.eds-text-weight--heavy.card-text--truncated__two`,
          );
          const imgUrl = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.image-action-container > aside > a > div > div > img`,
          );
          const eventUrl = document.querySelector(
            `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__primary-content > a`,
          );

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
        return events;
      });

      if (eventsArray.length === 0) {
        functions.logger.error('No events scrapped');
      } else {
        functions.logger.info('Number of scrapper events:', eventsArray.length);
      }
      return eventsArray;
    });

    collectiveEventsArray = await Promise.all([
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=1`),
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=2`),
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=3`),
    ]);

    await cluster.idle();
    await cluster.close();

    // many more page
    functions.logger.info('starting upload');

    collectiveEventsArray.forEach((currPageEvents) => {
      functions.logger.info('adding in progress');
      currPageEvents.forEach((event) => {
        (async () => {
          await admin
            .firestore()
            .collection('events')
            .doc('scraped-events')
            .collection(city)
            .add(event)
            .catch((err) => functions.logger.info(err));
        })();
      });
      functions.logger.info('Uploaded to firestore');
    });

    const today = new Date();
    (async () => {
      await admin
        .firestore()
        .collection('events')
        .doc('scraped-events')
        .collection('timestamp')
        .add({ location: city, timestamp: today })
        .catch((err) => functions.logger.info(err));
    })();

    res.send(collectiveEventsArray);
    functions.logger.info('Scraping Successful');
  });

exports.deleteOutdatedUserEvents = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '1GB',
  })
  .https.onRequest(async (req, res) => {
    functions.logger.info('Deleting outdated events...');
    const checkTime = new Date();
    checkTime.setHours(checkTime.getHours() + 2)
    const cityCollections = await admin.firestore().collection("events").doc("custom").listCollections()

    for (const cityColection of cityCollections) {
      const allEvents = await cityColection.get()
      for (const event in allEvents) { // for event in allEvents
        const eventTime = new Date(event.dateTime)
        if (eventTime < checkTime) { // if event.dateTime is less than checkTime (if event )
          event.delete() // remove event from collection
        }
      }
    }


    // const query = itemsRef.whereLessThan("dateTime", today);

    // // many more page
    // functions.logger.info('starting upload');

    // collectiveEventsArray.forEach((currPageEvents) => {
    //     functions.logger.info('adding in progress');
    //     currPageEvents.forEach((event) => {
    //         (async () => {
    //             await admin
    //                 .firestore()
    //                 .collection('events')
    //                 .doc('scraped-events')
    //                 .collection(city)
    //                 .add(event)
    //                 .catch((err) => functions.logger.info(err));
    //         })();
    //     });
    //     functions.logger.info('Uploaded to firestore');
    // });

    // res.send(collectiveEventsArray);
    functions.logger.info('Deleting Successful');
  });

