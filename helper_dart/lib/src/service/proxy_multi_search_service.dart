import '../model/multi_search_response.dart';

abstract class ProxyMultiSearchService {
  void updateMultiResponse(MultiSearchResponse response);
  void dispose();
}
