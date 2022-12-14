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

### Feat

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
