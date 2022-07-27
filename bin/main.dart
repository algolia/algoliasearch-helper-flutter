
import 'dart:async';
import 'dart:io';

import 'package:algolia_helper/src/filter.dart';
import 'package:algolia_helper/src/filter_group.dart';
import 'package:algolia_helper/src/filter_state.dart';

void main(List<String> arguments) {
  final filterState = FilterState();

  StreamSubscription<Filters> listen = filterState.filters.listen((event) {
    print(event.toString());
  });

  filterState.apply((filters) => {
    filters.add(FilterGroupID("a", FilterOperator.and), [FilterFacet("a", "b")])
  });

  sleep(const Duration(seconds: 1));

  filterState.apply((filters) => {
    filters.add(FilterGroupID("A", FilterOperator.or), [FilterFacet("A", "B")])
  });

  print("done");
}
