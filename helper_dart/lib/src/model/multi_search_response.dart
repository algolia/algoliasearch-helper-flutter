import 'package:collection/collection.dart';
import 'facet.dart';

part 'search_response.dart';

part 'facet_search_response.dart';

sealed class MultiSearchResponse {}

//
// class HitsSearchResponseWrapper extends MultiSearchResponse {
//   SearchResponse response;
//
//   HitsSearchResponseWrapper(this.response);
//
//   @override
//   int get hashCode => response.hashCode;
//
//   @override
//   String toString() => response.toString();
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is HitsSearchResponseWrapper &&
//           runtimeType == other.runtimeType &&
//           response == other.response;
// }
//
// extension HitsSearchResponseMultiSearchExt on SearchResponse {
//   HitsSearchResponseWrapper wrapForMultiSearch() =>
//       HitsSearchResponseWrapper(this);
// }
//
// class FacetSearchResponseWrapper extends MultiSearchResponse {
//   FacetSearchResponse response;
//
//   FacetSearchResponseWrapper(this.response);
//
//   @override
//   int get hashCode => response.hashCode;
//
//   @override
//   String toString() => response.toString();
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FacetSearchResponseWrapper &&
//           runtimeType == other.runtimeType &&
//           response == other.response;
// }
//
// extension FacetSearchResponseMultiSearchExt on FacetSearchResponse {
//   FacetSearchResponseWrapper wrapForMultiSearch() =>
//       FacetSearchResponseWrapper(this);
// }
