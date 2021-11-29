const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Cluster } = require('puppeteer-cluster');

admin.initializeApp();

const timeout = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const lowercase = (string) => string.toLowerCase();

const scrapeCityEvents = async (city) => {
  let eventsArray = [];
  let collectiveEventsArray = [];

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
      for (let i = 1; i <= 60; i += 1) {

        let parsedDate = '';
        let parsedImgUrl = '';

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
        const followers = document.querySelector(
          `#root > div > div.eds-structure__body > div > div > div > div.eds-fixed-bottom-bar-layout__content > div > main > div > div > section.search-base-screen__search-panel > div.search-results-panel-content > div > ul > li:nth-child(${i.toString()}) > div > div > div.search-event-card-rectangle-image > div > div > div > article > div.eds-event-card-content__content-container.eds-l-pad-right-4 > div > div > div.eds-event-card-content__sub-content > div:nth-child(3) > div > div.eds-event-card__sub-content--signal.eds-text-color--ui-800.eds-text-weight--heavy`,
        );

        let ticketInfo = cost ? cost.innerText : '';
        if (ticketInfo.substring(0, 4) === 'Free' || ticketInfo.substring(0, 9) === 'Starts at') {
          ticketInfo = `Registration Cost: ${ticketInfo}. `;
        } else {
          ticketInfo = '';
        }

        let numAttendees = 0;
        if (followers && followers.innerText) {
          numAttendees = followers.innerText.includes('k')
            ? parseInt(parseFloat(followers.innerText) * 1000, 10)
            : parseInt(followers.innerText, 10);
        }

        if (eventDate) {
          if (eventDate.innerText.indexOf('+') !== -1) {
            parsedDate = eventDate.innerText.substring(0, eventDate.innerText.indexOf('+') - 1);
          } else {
            parsedDate = eventDate.innerText;
          }
        }

        if (imgUrl) {
          parsedImgUrl = imgUrl.getAttribute('data-src');
        }


        const newEvent = {
          attendees: [],
          numAttendees,
          title: eventTitle ? eventTitle.innerText : '',
          dateTime: parsedDate,
          location: eventLoc ? eventLoc.innerText : '',
          createdByName: organizedBy ? organizedBy.innerText : '',
          imageUrl: parsedImgUrl,
          description: eventUrl
            ? `${ticketInfo}To register for the event go to the following link: ${eventUrl.getAttribute(
              'href',
            )}`
            : ticketInfo,
        };

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

  // delete all current events from city collection
  const batch = admin.firestore().batch();
  const allCityDoc = await admin
    .firestore()
    .collection('events')
    .doc('scraped-events')
    .collection(city)
    .listDocuments();

  allCityDoc.forEach((val) => batch.delete(val));
  await batch.commit();

  const allEventsPromises = [];

  functions.logger.info('adding in progress');
  collectiveEventsArray.forEach((currPageEvents) =>
    currPageEvents.forEach((event) =>
      allEventsPromises.push(
        admin
          .firestore()
          .collection('events')
          .doc('scraped-events')
          .collection(city)
          .add(event)
          .catch((err) => functions.logger.info(err)),
      ),
    ),
  );

  await Promise.all(allEventsPromises);
  functions.logger.info('Uploaded to firestore');

  const today = new Date();
  await admin
    .firestore()
    .collection('events')
    .doc('scraped-events')
    .collection('timestamp')
    .doc(city)
    .set({ location: city, timestamp: today.toString() })
    .catch((err) => functions.logger.info(err));

  return collectiveEventsArray.flat();
};

exports.scrapeEventGivenCity = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '2GB',
  })
  .https.onRequest(async (req, res) => {
    functions.logger.info('Starting to scrape...');

    let city = '';
    if (req.method === 'GET') {
      if (req.query.city && req.query.city.length !== 0) {
        city = lowercase(req.query.city);
        functions.logger.info('City: ' + city);
      } else {
        functions.logger.error('No city name provided');
        return res.status(400).send('No city name provided');
      }
    }

    const collectiveEventsArray = await scrapeCityEvents(city);

    res.send(collectiveEventsArray.flat());
    functions.logger.info('Scraping Successful');
  });

exports.deleteOutdatedUserEvents = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '256MB',
  })
  .https.onRequest(async (_, res) => {
    functions.logger.info('Deleting outdated events...');
    const currTime = new Date();
    const deletedEvents = {};
    currTime.setHours(currTime.getHours() + 2);

    const cityCollections = await admin
      .firestore()
      .collection('events')
      .doc('custom')
      .listCollections();

    try {
      if (cityCollections) {
        const cityCollectionsDataPromises = [];
        const eventToDeletePromises = [];

        cityCollections.forEach((cityCollection) =>
          cityCollectionsDataPromises.push(cityCollection.get()),
        );

        const cityCollectionsData = await Promise.all(cityCollectionsDataPromises);

        cityCollectionsData.forEach((allEvents) => {
          allEvents.docs.forEach((event) => {
            const eventTime = new Date(event.data().dateTime);
            if (eventTime < currTime) {
              if (!(event.ref.parent.id in deletedEvents)) {
                deletedEvents[event.ref.parent.id] = {};
              }
              deletedEvents[event.ref.parent.id][event.id] = event.data();
              eventToDeletePromises.push(event.ref.delete());
            }
          });
        });

        await Promise.all(eventToDeletePromises);
      }
    } catch (error) {
      functions.logger.error(error);
    }

    functions.logger.info('Deleting Successful', deletedEvents);
    res.send(deletedEvents);
  });

exports.periodicRescraper = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '2GB',
  })
  .https.onRequest(async (_, res) => {
    const timestamp = await admin
      .firestore()
      .collection('events')
      .doc('scraped-events')
      .collection('timestamp')
      .get();

    const sortedTimestamp = timestamp.docs
      .sort((a, b) => new Date(a.data().timestamp) - new Date(b.data().timestamp))
      .map((doc) => doc.data());

    const scrapePromises = [];
    sortedTimestamp.forEach((currTimestamp) =>
      scrapePromises.push(scrapeCityEvents(currTimestamp.location)),
    );

    await Promise.all(scrapePromises);
    res.send(sortedTimestamp);
  });
