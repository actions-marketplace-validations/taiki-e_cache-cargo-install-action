#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")"/..

# shellcheck disable=SC2154
trap 's=$?; echo >&2 "$0: Error on line "${LINENO}": ${BASH_COMMAND}"; exit ${s}' ERR

# Publish a new release.
#
# USAGE:
#    ./tools/publish.sh <VERSION>
#
# Note: This script requires the following tools:
# - parse-changelog <https://github.com/taiki-e/parse-changelog>

bail() {
    echo >&2 "error: $*"
    exit 1
}

version="${1:?}"
version="${version#v}"
tag="v${version}"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z\.-]+)?(\+[0-9A-Za-z\.-]+)?$ ]]; then
    bail "invalid version format '${version}'"
fi
if [[ $# -gt 1 ]]; then
    bail "invalid argument '$2'"
fi

# Make sure there is no uncommitted change.
git diff --exit-code
git diff --exit-code --staged

# Make sure the same release has not been created in the past.
if gh release view "${tag}" &>/dev/null; then
    bail "tag '${tag}' has already been created and pushed"
fi

if ! git branch | grep -q '\* main'; then
    bail "current branch is not 'main'"
fi

tags=$(git --no-pager tag)
if [[ -n "${tags}" ]]; then
    # Make sure the same release does not exist in CHANGELOG.md.
    release_date=$(date -u '+%Y-%m-%d')
    if grep -Eq "^## \\[${version//./\\.}\\] - ${release_date}$" CHANGELOG.md; then
        bail "release ${version} already exist in CHANGELOG.md"
    fi
    if grep -Eq "^\\[${version//./\\.}\\]: " CHANGELOG.md; then
        bail "link to ${version} already exist in CHANGELOG.md"
    fi

    # Update changelog.
    remote_url=$(grep -E '^\[Unreleased\]: https://' CHANGELOG.md | sed 's/^\[Unreleased\]: //; s/\.\.\.HEAD$//')
    before_tag="${remote_url#*/compare/}"
    remote_url="${remote_url%/compare/*}"
    sed -i "s/^## \\[Unreleased\\]/## [Unreleased]\\n\\n## [${version}] - ${release_date}/" CHANGELOG.md
    sed -i "s#^\[Unreleased\]: https://.*#[Unreleased]: ${remote_url}/compare/v${version}...HEAD\\n[${version}]: ${remote_url}/compare/${before_tag}...v${version}#" CHANGELOG.md
    if ! grep -Eq "^## \\[${version//./\\.}\\] - ${release_date}$" CHANGELOG.md; then
        bail "failed to update CHANGELOG.md"
    fi
    if ! grep -Eq "^\\[${version//./\\.}\\]: " CHANGELOG.md; then
        bail "failed to update CHANGELOG.md"
    fi
fi

# Make sure that a valid release note for this version exists.
# https://github.com/taiki-e/parse-changelog
echo "============== CHANGELOG =============="
parse-changelog CHANGELOG.md "${version}"
echo "======================================="

if [[ -n "${tags}" ]]; then
    # Create a release commit.
    git add CHANGELOG.md
    git commit -m "Release ${version}"
fi

set -x

git tag "${tag}"
git push origin main
git push origin --tags

major_version_tag="v${version%%.*}"
git checkout -b "${major_version_tag}"
git push origin refs/heads/"${major_version_tag}"
if git --no-pager tag | grep -Eq "^${major_version_tag}$"; then
    git tag -d "${major_version_tag}"
    git push --delete origin refs/tags/"${major_version_tag}"
fi
git tag "${major_version_tag}"
git checkout main
git branch -d "${major_version_tag}"

git push origin --tags
