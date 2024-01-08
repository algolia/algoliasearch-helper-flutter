## 1.0.0

 - **REFACTOR**(FacetList): refactor facet list component (#118).
 - **FIX**(facetlist): multiple facet toggle (#120).
 - **FIX**(facet): export facet model (#112).

## 0.5.0

 - **FEAT**(GeoSearch): add geospatial query support (#105).
 - **CHORE**: Update dependencies to be more relaxed.

## 0.4.1

 - **CHORE**: Fix pana issues (#95).

## 0.4.0

 - **FEAT**: MultiSearcher and FacetSearcher (#92).
 - **FEAT**: Highlighting extension for Facet.
 - **FEAT**: Official Dart client integration.
 - **CHORE**: Merge `algolia_helper_dart` to `algolia_helper_flutter` packages.

## 0.3.3

- **FIX**: use app documents directory to store the user token if possible (#88).

## [0.3.2](https://github.com/algolia/algoliasearch-helper-flutter/compare/0.3.1...0.3.2) (2022-05-30)

### Fix
- Outdated algolia_helper version in the algolia_helper_flutter pubspec

## [0.3.1](https://github.com/algolia/algoliasearch-helper-flutter/compare/0.3.0...0.3.1) (2022-05-19)

### Fix
- Restore Pub points

## [0.3.0](https://github.com/algolia/algoliasearch-helper-flutter/compare/0.2.3...0.3.0) (2022-04-07)

### Feat

- Add eventTracker instances to `HitsSearcher` and `FacetList` performing automatic hit view and filter click events
  tracking and facilitating manual Insights event tracking.

## [0.2.3](https://github.com/algolia/algoliasearch-helper-flutter/compare/0.2.2...0.2.3) (2022-12-22)

### Feat

- add rerun search query (#51) ([5348341](https://github.com/algolia/algoliasearch-helper-flutter/commit/5348341))

# 0.2.2

## Fix

- Allow same search query to be executed (#48)
- Highlighting of strings with non-alphanumeric characters (#46)

# 0.2.1

## Fix

- `FacetList` redundant `facets` submissions (#33)

## Changed

- `CompositeDisposable#add` method generic (#33)

# 0.2.0

## Feat

- Add `Disposable` and `CompositeDisposable` (#31)

## Fix

- `HitsSearcher`'s `responses` as published stream (#30)

## Changed

- `ImmutableFilters` renamed to `StatelessFilters` (#32)

# 0.1.5

## Feat

- Update `HitsSearcher`'s `disjunctiveFacets` property when disjunctive `FacetList` is connected (#27)

# 0.1.4

## Refactor

- `HitsSearcher` and `FacetList` specification and implementation (#24)

# 0.1.3

## Fix

- Named parameters for `Hit.getHighlightedString` (#22)

# 0.1.2

## Fix

- Rewrite the build disjunctive faceting queries to avoid exception  (#19)

# 0.1.1

## Feat

- Expose search state stream (#17)

## Fix

- Add objectID to attributes for auxiliary queries (#14)
- Fix `facetStats` type (#15)

# 0.1.0

Initial release.
