#!/bin/bash

if [[ "$(uname)" == "Darwin" ]]; then
  sed_arg=('-i' '' '-e')
else
  sed_arg=('-i' '-e')
fi

packages=(
  "insights"
  "helper"
)

for dir in ${packages[@]}; do
  dir=${dir%/}
  version=$(grep "^version:" "${dir}/pubspec.yaml" | sed 's/version: //')
  sed "${sed_arg[@]}" "s/^const libVersion = .*;$/const libVersion = '$version';/" "${dir}/lib/src/lib_version.dart";
  git add "${dir}/lib/src/lib_version.dart"
done
