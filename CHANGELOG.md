# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2023-10-02

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`algolia_helper_flutter` - `v0.5.0`](#algolia_helper_flutter---v050)
 - [`algolia_insights` - `v0.2.2`](#algolia_insights---v022)

---

#### `algolia_helper_flutter` - `v0.5.0`

 - **FEAT**(GeoSearch): add geospatial query support (#105).

#### `algolia_insights` - `v0.2.2`

 - **FEAT**(GeoSearch): add geospatial query support (#105).


## 2023-09-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`algolia_helper_flutter` - `v0.4.1`](#algolia_helper_flutter---v041)
 - [`algolia_insights` - `v0.2.1`](#algolia_insights---v021)

---

#### `algolia_helper_flutter` - `v0.4.1`

 - **CHORE**: Fix pana issues (#95).

#### `algolia_insights` - `v0.2.1`

 - **CHORE**: Fix pana issues (#95).


## 2023-09-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`algolia_insights` - `v0.2.0`](#algolia_insights---v020)
 - [`algolia_helper_flutter` - `v0.4.0`](#algolia_helper_flutter---v040)

---

#### `algolia_insights` - `v0.2.0`

 - **FEAT**: Insights becomes a Flutter package (#92).
 - **FIX**: Add named parameters for Insights instantiation.

#### `algolia_helper_flutter` - `v0.4.0`

 - **FEAT**: MultiSearcher and FacetSearcher (#92).
 - **FEAT**: Highlighting extension for Facet.
 - **FEAT**: Official Dart client integration.
 - **CHORE**: Merge `algolia_helper_dart` to `algolia_helper_flutter` packages.

## 2023-07-17

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`algolia_helper` - `v0.3.3`](#algolia_helper---v033)
 - [`algolia_helper_flutter` - `v0.3.3`](#algolia_helper_flutter---v033)
 - [`algolia_insights` - `v0.1.2`](#algolia_insights---v012)

---

#### `algolia_helper` - `v0.3.3`

 - **REFACTOR**: Filters/FilterState and add disposables (#31).
 - **REFACTOR**(searcher): responses as published stream (#30).
 - **REFACTOR**: `HitsSearcher` and `FacetList` spec and impl SoC (#24).
 - **REFACTOR**(hierarchical): update group logic (#10).
 - **REFACTOR**(docs): update public API (#9).
 - **REFACTOR**(searcher): update API and tests (#3).
 - **REFACTOR**: rename main entry to algolia.dart.
 - **FIX**: use app documents directory to store the user token if possible (#88).
 - **FIX**: Restore pub points (#75).
 - **FIX**(highlighting): strings with symbols other then letters (#46).
 - **FIX**: allow same search query to be executed (#48).
 - **FIX**: add type alias for deprecated immutable filters (#32).
 - **FIX**: named parameters for Hit.getHighlightedString (#22).
 - **FIX**: remove distinct from search state stream (#21).
 - **FIX**(QueryBuilder): build disjunctive faceting queries exception (#19).
 - **FIX**(searchResponse): facetStats type (#15).
 - **FIX**(queryBuilder): add objectID to attributes for aux queries (#14).
 - **FIX**: tag filter attribute.
 - **FIX**(searcher): search response build.
 - **FIX**(searcher): search operation call.
 - **FIX**: modules types.
 - **FEAT**: Insights (#62).
 - **FEAT**: add rerun search query (#51).
 - **FEAT**: enhance DX and update documentation  (#33).
 - **FEAT**(FacetList): update search state on disjunctive faceting  (#27).
 - **FEAT**(HitsSearcher): expose search state stream (#17).
 - **FEAT**: facet list component (#13).
 - **FEAT**(highlighting): Highlighting feature (#11).
 - **FEAT**(search): update query params build (#8).
 - **FEAT**(filterstate): update and document API (#6).
 - **FEAT**: QueryBuilder (#5).

#### `algolia_helper_flutter` - `v0.3.3`

 - **REFACTOR**(docs): update public API (#9).
 - **REFACTOR**(searcher): update API and tests (#3).
 - **REFACTOR**: rename main entry to algolia.dart.
 - **FIX**: use app documents directory to store the user token if possible (#88).
 - **FIX**: outdated algolia_helper version in the algolia_helper_flutter pubspec' (#81).
 - **FIX**: Restore pub points (#75).
 - **FIX**: modules types.
 - **FEAT**: Insights (#62).
 - **FEAT**: enhance DX and update documentation  (#33).
 - **FEAT**(highlighting): Highlighting feature (#11).

#### `algolia_insights` - `v0.1.2`

 - **FIX**: use app documents directory to store the user token if possible (#88).
 - **FIX**: Restore pub points (#75).
 - **FEAT**: Insights (#62).

