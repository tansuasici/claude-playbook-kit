# Releasing

How a new version of this repo gets out. The kit is plain markdown: there is no package to publish. A release is a version bump, a `CHANGELOG.md` entry, a `vX.Y.Z` tag and a GitHub Release.

The version lives in three places, and they must match:

- `VERSION`: the line ends in `# x-release-please-version`. Keep that marker.
- `.release-please-manifest.json`
- The newest heading in `CHANGELOG.md`

The website reads `VERSION` at build time, so the version badge on claudeplaybookkit.tansuasici.com only changes after the site is rebuilt.

## Normal path: release-please

`.github/workflows/release.yml` runs on every push to `main`. It uses the self-hosted runner (`[self-hosted, claudeplaybookkit]`).

1. Merge PRs into `main` with Conventional Commit titles (`feat:`, `fix:`, `docs:`…). Only `feat` and `fix` trigger a release.
2. release-please opens or updates a PR named `chore(main): release X.Y.Z`. The PR bumps `VERSION`, updates the manifest and writes the changelog.
3. The same workflow runs markdownlint and the link check on that PR and reports them as status checks.
4. Read the changelog in the PR, then merge it.
5. On that merge, release-please creates the `vX.Y.Z` tag and the GitHub Release.

## Fallback: release by hand

Use this when the runner can't start jobs. Run it from an up-to-date `main`.

1. Pick the version (Semantic Versioning: `fix` → patch, `feat` → minor).
2. Bump it on a branch and open a PR:

   ```bash
   V=1.2.0
   git switch -c chore/release-$V origin/main
   sed -i '' "s/^[0-9.]* # x-release-please-version/$V # x-release-please-version/" VERSION
   printf '{\n  ".": "%s"\n}\n' "$V" > .release-please-manifest.json
   ```

3. Add a `## [X.Y.Z](compare link) (YYYY-MM-DD)` section to the top of `CHANGELOG.md`, in the same format as the entries below it.
4. Run the checks that CI would run:

   ```bash
   npx markdownlint-cli2 "**/*.md" "#CHANGELOG.md" "#node_modules"
   ```

5. Commit as `chore(main): release X.Y.Z`, then open and merge the PR.
6. Tag the merge commit and publish the release:

   ```bash
   git switch main && git pull
   git tag -a v$V -m "v$V" && git push origin v$V
   gh release create v$V --title "v$V" --notes-file <(awk '/^## \[/{n++} n==1' CHANGELOG.md)
   ```

release-please picks up from the manifest, so its next automated release continues from this version.

## After a release

- Rebuild and deploy the website so the version badge and the docs match the release (`pnpm run deploy` in the web repo).
- Go through [checklists/release.md](checklists/release.md) for anything else your release needs.
