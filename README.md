## Upgrading dependencies results in inconsistent yarn.lock files

This repo contains a script that reproduces a case where upgrading a package
with yarn in three different situations results in inconsistent yarn.lock
files.

The script is in `test.sh`, and should be easy to follow. I've included a more
detailed explanation of what it's doing below.

### Running

1. Clone the project
2. Run `./test.sh`
3. Observe the results and inspect the `yarn.lock` files in `project`,
   `regular-upgrade`, and `isolated-upgrade`

### Explanation

1. Create a clean directory (`project/`), and copy in a `package.json` and
   `yarn.lock` that depend on (among other things) react-scripts v0.9.5.
2. Run `yarn install` in the directory to pull down all the packages,
   populating `node_modules`.
3. Copy the directory in its entirety (including `node_modules`) into a new
   directory (`regular-upgrade/`).
4. Inside `regular-upgrade/`, use `yarn add` to upgrade react-scripts to
   v1.0.6.
5. Create another clean directory (`isolated-upgrade/`), and copy over the
   `package.json` and `yarn.lock` from the original directory (`project/`).
   Note that this is similar to `regular-upgrade/` at the end of step 3, except
   it doesn't include the original directory's `node_modules`.
6. Inside `isolated-upgrade/`, use `yarn add` to upgrade react-scripts to
   v1.0.6.
7. Copy the `package.json` and `yarn.lock` from the `isolated-upgrade/`
   directory back to the `project/` directory
8. Inside `project/`, use `yarn install` to upgrade react-scripts, as it now
   has the updated dependency files.

At the end, we have three `yarn.lock` files:

1. `regular-upgrade/yarn.lock`: the result of effectively doing a simple
   `yarn add react-scripts@1.0.6` in the original project
2. `isolated-upgrade/yarn.lock`: the result of doing a
   `yarn add react-scripts@1.0.6` in a clean state (no existing `node_modules`)
3. `project/yarn.lock`: the result of taking an upgraded `yarn.lock`, and doing
   a `yarn install`

I'd expect all three of these files to be the same, but - at least when I run
this on my machine - they're all different.

I've tried this test with several different sets of dependencies.

With simple dependency sets, the files all match.

With slightly more complex dependency sets (e.g. just `react-scripts` and
`isomorphic-fetch`), yarn 0.24 produces inconsistent results, but yarn 0.26
produces consistent results (possibly as a result of [this
PR](https://github.com/yarnpkg/yarn/pull/3477)).

With the more complex files I've included in this repo, even yarn 0.26 produces
inconsistent results.
