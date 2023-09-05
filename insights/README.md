## Algolia Insights for Dart

Algolia Insights is a Flutter library for tracking and analyzing user behavior on search and discovery experiences powered
by Algolia. The purpose of Algolia Insights is to provide a simple and flexible way to track events such as clicks,
conversions, and views on search results. This data can then be used to personalize the search experience for each user
by providing insights into what users are searching for and how they are interacting with the search results.
Additionally, Algolia Insights provides a way to track user behavior across multiple devices and sessions, allowing you
to get a complete picture of how users interact with your search and discovery experiences over time.

### Getting started

Add the Algolia Insights package to your pubspec.yaml file:

```yaml
dependencies:
  algolia_insights: ^0.1.0
```

### Initializing the Insights

To start using Algolia Insights, you will first need to initialize an instance of the Insights class and pass in your
Algolia application ID and API key.

```dart
import 'package:algolia_insights/algolia_insights.dart';

Insights insights = Insights(
  'YourApplicationID',
  'YourAPIKey',
);
```

### Sending events

To send events to Algolia Insights, use the methods available on the Insights instance. For example, to send a click
event:

```dart
insights.clickedObjects
(
  indexName: 'YourIndexName',
  objectIDs: ['object-123'],
eventName: 'click',
);
```

### Event Types

The following event types are supported by Algolia Insights:

- `click`: Track when a user clicks on a search result
- `conversion`: Track when a user converts on a search result
- `view`: Track when a user views a search result

### Customizing the user token

You can set a custom user token by setting the userToken property on the Insights instance. The user token is used to
track events for a specific user.

```dart
insights.userToken = 'user-123';
```

### Documentation

For more information on how to use Algolia Insights with Flutter, see the [official documentation](https://www.algolia.com/doc/guides/building-search-ui/going-further/send-insights-events/flutter/).

### Contributions

Contributions are welcome! If you find a bug or want to request a new feature, please open an issue. If you want to
contribute, please open a pull request.
