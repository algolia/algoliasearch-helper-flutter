# Algolia Helpers for Dart

[![pub package](https://img.shields.io/pub/v/algolia_helper.svg)](https://pub.dev/packages/algolia_helper)

Provides patterns and APIs that make it possible to customize search experiences at a deeper level, in pure **Dart**.

## Principles

* **Simple**: provide simple and easy-to-use utilities to build advanced search experiences
* **Abstraction**: manage common search logic and state use-cases
* **Integration**: leverage SoC, without assumptions on how the app is built

## Features

* Search query and hits list
* Filters and facets handling, disjunctive faceting
* Search metadata (i.e. highlighting)

## Components

| Component         | Description                                                                                                    |
|-------------------|----------------------------------------------------------------------------------------------------------------|
| [HitsSearcher][0] | Component handling search requests.                                                                            |
| [FilterState][1]  | Component providing a friendly interface to manage search filters.                                             |
| [FacetList][2]    | Component to get and manage facets, lets the user refine their search results by filtering on specific values. |
| [Highlighting][3] | Set of tools to highlight relevant parts of the search results.                                                |


[0]: lib/src/hits_searcher.dart
[1]: lib/src/filter_state.dart
[2]: lib/src/facet_list.dart
[3]: lib/src/highlighting.dart
