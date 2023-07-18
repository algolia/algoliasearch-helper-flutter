import '../../algolia_helper.dart';

abstract class MultiSearchService {
  /// Send a list of search request [SearchState] and asynchronously get a list
  /// of corresponding [MultiSearchResponse].
  Future<List<SearchResponse>> search(List<SearchState> states);
}
