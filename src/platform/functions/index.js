require('dotenv').config();
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Cluster } = require('puppeteer-cluster');
const axios = require('axios');

admin.initializeApp();

const formatCity = (string) => string.toLowerCase();

const scrapeCityEvents = async (city) => {
  let eventsArray = [];
  let collectiveEventsArray = [];

  const cluster = await Cluster.launch({
    concurrency: Cluster.CONCURRENCY_CONTEXT,
    maxConcurrency: 3,
    timeout: 70000,
  });

  await cluster.task(async ({ page, data: webpageUrl }) => {
    await page.setViewport({
      width: 1920,
      height: 1080,
    });

    const { API_KEY } = process.env;

    await page.goto(webpageUrl, { waitUntil: 'networkidle2', timeout: 0 });

    await page.waitForSelector('ul.search-main-content__events-list', { timeout: 40000 });

    // eslint-disable-next-line no-shadow
    eventsArray = await page.evaluate((API_KEY) => {
      const rawAllEvents = document
        .getElementsByClassName('search-main-content__events-list')[0]
        .querySelectorAll('li');

      const events = Array.from(rawAllEvents).map((rawEvent) => {
        const eventTitle = rawEvent.querySelector('div.eds-event-card__formatted-name--is-clamped');

        const eventDate = rawEvent.querySelector('div.eds-event-card-content__sub-title');

        const eventLoc = rawEvent.querySelector('div.card-text--truncated__one');

        const cost = rawEvent.querySelectorAll(
          'div.eds-event-card-content__sub.eds-text-bm.eds-text-color--ui-600.eds-l-mar-top-1',
        )[1];

        const organizedBy = rawEvent.querySelector('div.eds-event-card__sub-content--organizer');

        const imgUrl = rawEvent.querySelector('img.eds-event-card-content__image');

        const eventUrl = rawEvent.querySelector('a');

        const followers = rawEvent.querySelector(
          'div.eds-event-card__sub-content--signal.eds-text-color--ui-800.eds-text-weight--heavy',
        );

        let ticketInfo = cost ? cost.innerText : '';
        if (ticketInfo.substring(0, 4) === 'Free' || ticketInfo.substring(0, 9) === 'Starts at') {
          ticketInfo = `Registration Cost: ${ticketInfo}. `;
        } else {
          ticketInfo = '';
        }

        let numAttendees = 0;
        if (followers && followers.childNodes) {
          const followerNodeValue = followers.childNodes[3].nodeValue;

          numAttendees = followerNodeValue.includes('k')
            ? parseInt(parseFloat(followerNodeValue) * 1000, 10)
            : parseInt(followerNodeValue, 10);
        }

        let parsedDate = '';
        if (eventDate) {
          if (eventDate.innerText.indexOf('+') !== -1) {
            parsedDate = eventDate.innerText.substring(0, eventDate.innerText.indexOf('+') - 1);
          } else {
            parsedDate = eventDate.innerText;
          }
        }

        const parsedImgUrl =
          imgUrl && imgUrl.getAttribute('data-src')
            ? imgUrl.getAttribute('data-src')
            : 'https://wp-rocket.me/wp-content/uploads/fly-images/1483304/placeholder-feature-image-490x205-c.png';

        let parsedAPIUrl = '';
        if (eventUrl) {
          const parsedLocationString = encodeURI(eventLoc.innerText);
          parsedAPIUrl = `https://maps.googleapis.com/maps/api/geocode/json?address=${parsedLocationString}&key=${API_KEY}`;
        }

        return {
          locationAPIUrl: parsedAPIUrl,
          attendees: [],
          numAttendees,
          title: eventTitle.innerText || '',
          dateTime: parsedDate,
          location: {
            address: eventLoc.innerText || '',
            latitude: '',
            longitude: '',
          },
          createdByName: organizedBy ? organizedBy.innerText : '',
          imageUrl: parsedImgUrl,
          description: eventUrl
            ? `${ticketInfo}To register for the event go to the following link: ${eventUrl.href}`
            : ticketInfo,
        };
      });

      return events;
    }, API_KEY);

    const eventsLocationPromises = [];

    // remove all event with no dates
    eventsArray = eventsArray.filter((event) => event.dateTime !== '');

    eventsArray.forEach(({ locationAPIUrl }) =>
      eventsLocationPromises.push(
        axios(locationAPIUrl).catch((error) => functions.logger.error(error)),
      ),
    );

    let resolvedEventsLocations = [];
    resolvedEventsLocations = await Promise.all(eventsLocationPromises);

    resolvedEventsLocations.forEach((resolvedEventLocation, index) => {
      if (resolvedEventLocation && resolvedEventLocation.data.status === 'OK') {
        const locationData = resolvedEventLocation.data.results[0];
        const {
          geometry: {
            location: { lat, lng },
          },
        } = locationData;

        eventsArray[index].location.latitude = lat;
        eventsArray[index].location.longitude = lng;
      } else {
        functions.logger.info(resolvedEventLocation.data.error_message);
      }
    });

    eventsArray.forEach((event) => {
      // eslint-disable-next-line no-param-reassign
      delete event.locationAPIUrl;
    });

    if (eventsArray.length === 0) {
      functions.logger.error('No events scrapped');
    } else {
      functions.logger.info('Number of scrapper events:', eventsArray.length);
    }
    return eventsArray;
  });

  try {
    collectiveEventsArray = await Promise.all([
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=1`),
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=2`),
      cluster.execute(`https://www.eventbrite.ca/d/${city}/all-events/?page=3`),
    ]);

    await cluster.idle();
    await cluster.close();
  } catch (error) {
    functions.logger.error(error);
  }

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
        city = formatCity(req.query.city);
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
    timeoutSeconds: 300,
    memory: '2GB',
  })
  .https.onRequest(async (_, res) => {
    const REGION = 'us-central1';
    const PROJECT_ID = 'actnow-4b2f5';
    const RECEIVING_FUNCTION = 'scrapeEventGivenCity';
    const functionURL = `https://${REGION}-${PROJECT_ID}.cloudfunctions.net/${RECEIVING_FUNCTION}`;

    const timestamp = await admin
      .firestore()
      .collection('events')
      .doc('scraped-events')
      .collection('timestamp')
      .get();

    const sortedTimestamp = timestamp.docs
      .sort((a, b) => new Date(a.data().timestamp) - new Date(b.data().timestamp))
      .map((doc) => doc.data())
      .slice(0, 10);

    functions.logger.info(
      `scraping: ${sortedTimestamp.map((currTimestamp) => currTimestamp.location)}`,
    );

    const scrapePromises = [];
    sortedTimestamp.forEach((currTimestamp) =>
      scrapePromises.push(
        axios(`${functionURL}?city=${currTimestamp.location}`).catch((err) =>
          functions.logger.error(err),
        ),
      ),
    );

    await Promise.all(scrapePromises);
    res.send(sortedTimestamp);
  });
