---
sidebar_position: 2
---

# API

### scrapeEventGivenCity

**Method**: GET  
**Purpose**: Scrape the event data from the given city.  
**Required Query Parameter**: city  
**Permissions**: can only be invoked by application  
**Example usage**: `https://us-central1-actnow-4b2f5.cloudfunctions.net/scrapeEventGivenCity?city=Toronto`  
**Output Format**:

```json
[
  {
    "attendees": "string[]",
    "createdByName": "string",
    "dateTime": "string",
    "description": "string",
    "imageUrl": "string",
    "location": "string",
    "latitude": "string",
    "longitude": "string",
    "numAttendees": "number",
    "title": "string",
    }
  },
  }
]
```

**Example Output**:

```json
[
  {
    "attendees": [],
    "createdByName": "Career Fair Canada",
    "dateTime": "Thu, Nov 25, 10:00 AM",
    "description": "Career Fair",
    "imgUrl": "https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F141853097%2F310079302852%2F1%2Foriginal.20200102-204940?w=512&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C30%2C1250%2C625&s=69210e2290152c54285bbcb2c1606019",
    "location": "Metro Toronto Convention Centre • Toronto, ON",
    "latitude": xxx,
    "longitude": xxx,
    "numAttendees": 100,
    "title": "Toronto Career Fair and Training Expo",
  }
  ...
]
```

### deleteOutdatedUserEvents

**Method**: GET  
**Purposes**: Delete all user events that are 2 hours after they were scheduled.  
**Required Query Parameter**: n/a  
**Permissions**: can only be invoked by scheduler  
**Example usage**: `https://us-central1-actnow-4b2f5.cloudfunctions.net/deleteOutdatedUserEvents`  
**Output Format**:

```json
{
  "[city]": {
    "[eventId]": {
      "attendees": "string[]",
      "createdBy": "string",
      "createdByName": "string",
      "description": "string",
      "imageUrl": "string",
      "latitude": "string",
      "location": "string",
      "longitude": "string",
      "numAttendees": "number",
      "title": "string",
    }
  },
  ...
}
```

### periodicRescraper

**Method**: GET  
**Purposes**: Rescrape all the events for the top oldest oldest scraped cities based on the timestamps generated during the initial scraping.  
**Required Query Parameter**: n/a  
**Permissions**: can only be invoked by scheduler  
**Example usage**: `https://us-central1-actnow-4b2f5.cloudfunctions.net/periodicRescraper`  
**Output Format**:

```array
[
  "string",
  ...
]
```