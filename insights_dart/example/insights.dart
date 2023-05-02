import 'package:algolia_insights/algolia_insights.dart';

void main() {
  // Create an Insights instance.
  final insights = Insights('MY_APPLICATION_ID', 'MY_API_KEY');

  /// Set custom user token
  insights.userToken = 'MY_USER_TOKEN';

  /// Track hits click event after search
  insights.clickedObjectsAfterSearch(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    queryID: 'QUERY_ID',
    objectIDs: ['objectID1', 'objectID2', 'objectID3'],
    positions: [5, 6, 7],
  );

  /// Track hits click event
  insights.clickedObjects(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    objectIDs: ['objectID1', 'objectID2', 'objectID3'],
  );

  /// Track hits conversion event after search
  insights.convertedObjectsAfterSearch(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    queryID: 'QUERY_ID',
    objectIDs: ['objectID1', 'objectID2', 'objectID3'],
  );

  /// Track hits conversion event
  insights.convertedObjects(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    objectIDs: ['objectID1', 'objectID2', 'objectID3'],
  );

  /// Track hits view event
  insights.viewedObjects(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    objectIDs: ['objectID1', 'objectID2', 'objectID3'],
  );

  /// Track filters click event
  insights.clickedFilters(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    attribute: 'color',
    values: ['red', 'green', 'blue'],
  );

  /// Track filters view event
  insights.viewedFilters(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    attribute: 'color',
    values: ['red', 'green', 'blue'],
  );

  /// Track filters conversion event
  insights.convertedFilters(
    indexName: 'MY_INDEX_NAME',
    eventName: 'CLICK_OBJECT',
    attribute: 'color',
    values: ['red', 'green', 'blue'],
  );
}
