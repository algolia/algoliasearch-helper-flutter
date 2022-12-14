import 'package:algolia_helper/algolia_helper.dart' as dart;

import 'constants.dart';
import 'delegate_searcher.dart';

/// Algolia Flutter Helper main entry point, the component handling search
/// requests and managing search sessions.
///
/// [HitsSearcher] component has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
/// 3. On new search request, previous ongoing search calls are cancelled
///
/// ## Create Hits Searcher
///
/// Instantiate [HitsSearcher] using default constructor:
///
/// ```dart
/// final hitsSearcher = HitsSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   indexName: 'MY_INDEX_NAME',
/// );
/// ```
/// Or, using [HitsSearcher.create] factory:
///
/// ```dart
/// final hitsSearcher = HitsSearcher.create(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   state: const SearchState(indexName: 'MY_INDEX_NAME', query: 'shoes'),
/// );
/// ```
///
/// ## Run search requests
///
/// Execute search queries using [query] method:
///
/// ```dart
/// hitsSearcher.query('book');
/// ```
///
/// Or, using [applyState] for more parameters:
///
/// ```dart
/// hitsSearcher.applyState((state) => state.copyWith(query: 'book', page: 0));
/// ```
///
/// ## Get search state
///
/// Listen to [state] to get search state changes:
///
/// ```dart
/// hitsSearcher.state.listen((searchState) => print(searchState.query));
/// ```
///
/// ## Get search results
///
/// Listen to [responses] to get search responses:
///
/// ```dart
/// hitsSearcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['objectID']}");
///   }
/// });
/// ```
///
/// Use [snapshot] to get the latest search response value submitted
/// by [responses] stream:
///
/// ```dart
/// var response = hitsSearcher.snapshot();
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// hitsSearcher.dispose();
/// ```
class HitsSearcher extends DelegateHitsSearcher {
  factory HitsSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
    List<String> extraUserAgents = const [],
  }) =>
      HitsSearcher._with(
        dart.HitsSearcher(
          applicationID: applicationID,
          apiKey: apiKey,
          indexName: indexName,
          disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
          debounce: debounce,
          extraUserAgents: [...extraUserAgents, libUserAgent],
        ),
      );

  /// HitsSearcher's factory.
  factory HitsSearcher.create({
    required String applicationID,
    required String apiKey,
    required dart.SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
    List<String> extraUserAgents = const [],
  }) =>
      HitsSearcher._with(
        dart.HitsSearcher.create(
          applicationID: applicationID,
          apiKey: apiKey,
          state: state,
          disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
          debounce: debounce,
          extraUserAgents: [...extraUserAgents, libUserAgent],
        ),
      );

  /// Delegating constructor.
  HitsSearcher._with(super.searcher);
}
