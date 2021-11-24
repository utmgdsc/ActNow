---
sidebar_position: 3
---

# Function Breakdown

### scrapeEventGivenCity
This function uses the puppeteer cluster package to scrape event data from eventbrite. We use `https://www.eventbrite.ca/d/${city}/all-events` as a source. The overall flow is as follows:
1. Scrape raw data from eventbrite using puppeteer (we scrape 3 pages, each page containing 20 events)
2. Cleanup the raw data and add it into an array of events objects
3. Add the events into firestore
4. Update timestamp for when a city events were last updated
5. Return events object array as a response

### deleteOutdatedUserEvents
This function deletes all user events that are 2 hours after they were scheduled. This is to prevent users from seeing events that have already passed. The veral flow is as follows:
1. Get all user events from firestore
2. Check if the current time is greater than the event's scheduled time + 2 hours
3. Delete all outdated events
4. Return an array of deleted events as a response
