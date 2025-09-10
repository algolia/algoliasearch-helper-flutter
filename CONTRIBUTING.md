# Contributing to the algoliasearch-helper-flutter repository

Hello and welcome to this contributing guide. Thanks for considering participating in our project 🙇.

If this guide does not contain what you are looking for and thus prevents you from contributing, don't hesitate to [open an issue](https://github.com/algolia/algoliasearch-helper-flutter/issues/new/choose).

## Setup

To set up this project, you will need to install the [Flutter SDK](https://docs.flutter.dev/get-started/install).

We use [melos](https://github.com/invertase/melos) to maintain multiple packages in a single repository and link internal dependencies. Execute the following commands in a terminal set at the root directory:

```sh
flutter pub get
flutter pub global activate melos
melos bootstrap
```

## Code contribution process

For any code contribution, you need to:

- Fork and clone the project
- Create a new branch for what you want to solve (fix/_issue-number_, feat/_name-of-the-feature_)
- Make your changes
- Open a pull request

Then:

- Peer review of the pull request (by at least one core contributor)
- Automatic checks
- When everything is green, your contribution is merged 🚀

## Commit conventions

This project follows the [conventional changelog](https://conventionalcommits.org/) approach. This means that all commit messages should be formatted using the following scheme:

```
type(scope): description
```

In most cases, we use the following types:

- `fix`: for any resolution of an issue (identified or not)
- `feat`: for any new feature
- `refactor`: for any code change that neither adds a feature nor fixes an issue
- `chore`: for any change that has no impact on the published packages

Finally, if your work is based on an issue on GitHub, please add in the body of the commit message "fix #1234" if it solves the issue #1234 (read "[Closing issues using keywords](https://help.github.com/en/articles/closing-issues-using-keywords)").

Some examples of valid commit messages (used as first lines):

> - feat(helper): implement method X
> - chore(deps): update dependency Y to v1.2.3
> - fix(insights): ensure proeprty Z is valid

## Publish

The packages are published automatically with [GitHub Actions](./.github/workflows/publish.yml). All packages in this project are published on [pub.dev](https://pub.dev/publishers/algolia.com/packages). To manually publish a stable version, go on `main` (`git checkout main`) and use:

```sh
melos version
```

It will ask to confirm the updated version numbers, then it will prepare the packages by:

- updating version numbers in relevant locations
- updating CHANGELOG.md files
- creating git tags

Once the process succeeds, run the following command to push the changes and trigger the [**publish** Github Action](.github/workflows/publish.yml):

```sh
git push && git push --tags
```

Packages can also be published manually with an account authorized to publish on behalf of Algolia:

```sh
flutter pub login
melos publish --no-dry-run
```

> [!NOTE]
> It is a good practice to run it once without the `--no-dry-run` to catch any issues.
