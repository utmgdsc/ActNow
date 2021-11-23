---
sidebar_position: 2
---

# Available Functions

### scrapeEventGivenCity

**Method**: GET  
**Required Query Parameter**: city  
**Permissions**: can only be invoked by application  
**Example usage**: `https://us-central1-actnow-4b2f5.cloudfunctions.net/scrapeEventGivenCity?city=Toronto`  
**Output Format**:

```json
[
  {
    "title": "string",
    "date": "string",
    "location": "string",
    "ticket": "string",
    "organization": "string",
    "img": "string",
    "url": "string"
  }
]
```

**Example Output**:

```json
[
  {
    "title": "Toronto Career Fair and Training Expo",
    "date": "Thu, Nov 25, 10:00 AM",
    "location": "Metro Toronto Convention Centre • Toronto, ON",
    "ticket": "Free",
    "organization": "Career Fair Canada",
    "img": "https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F141853097%2F310079302852%2F1%2Foriginal.20200102-204940?w=512&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C30%2C1250%2C625&s=69210e2290152c54285bbcb2c1606019",
    "url": "https://www.eventbrite.ca/e/toronto-career-fair-and-training-expo-tickets-163655099809?aff=ebdssbdestsearch"
  }
  ...
]
```

### deleteOutdatedUserEvents

**Method**: GET  
**Required Query Parameter**: n/a
**Permissions**: can only be invoked by scheduler
**Example usage**: `https://us-central1-actnow-4b2f5.cloudfunctions.net/scrapeEventGivenCity?city=Toronto`  
**Output Format**:
