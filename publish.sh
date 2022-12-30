#!/usr/bin/env bash

set -e
my_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
preVersion=$(node -p "require('./package.json').version")
pkgVersion=$(cat ./next-version.txt)
branch=$1

npm config set '//registry.npmjs.org/:_authToken' "$NPM_TOKEN"

echo "Publishing version $pkgVersion - $branch"

echo "pkgVersion: $pkgVersion"
npm version $pkgVersion --no-git-tag-version --allow-same-version --no-commit-hooks --workspace-update=false
npx lerna version $pkgVersion --no-git-tag-version --no-push --yes

# replace old versions in files
find . -type f \( -name '*.js' -or -name '*.ts' -or -name '*.tsx' -or -name '*.json' \) -not -path '*node_modules*' -not -path '*.next*' -exec grep -l "$pkgVersion" {} \; | xargs perl -pi -e "s/$pkgVersion/$newVersion/g"

yarn install --frozen-lockfile || true
yarn install --frozen-lockfile
## todo fix this by hoisting the repo https://github.com/graphql-compose/graphql-compose-examples/tree/master/examples/northwind
# yarn examplecli
#
yarn buildall
#
yarn genall
yarn test

echo "Updating repo..."
command cp -rf CHANGELOG.md LICENSE README.md ./runtime/
command cp -rf CHANGELOG.md LICENSE README.md ./cli/
git add .
git commit -m "chore(release): update packages to $pkgVersion [skip ci]"
if [[ $branch == "master" ]]; then
  git pull origin $branch --ff-only
  git push
  echo "Repo pushed."
fi

cd $my_dir/runtime
runtimeVersion=$(node -p -e "require('./package.json').version")
echo "runtimeVersion: $runtimeVersion"
npm publish --access public

cd $my_dir/cli
cliVersion=$(node -p -e "require('./package.json').version")
echo "cliVersion: $cliVersion"
npm publish --access public

echo "Done."