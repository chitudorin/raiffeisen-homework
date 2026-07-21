# Validate YAML

If a simple YAML linter like [YAML Lint](https://github.com/marketplace/actions/yaml-lint) is enough, using their example is as eaasy as copy and paste:

```
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: yaml-lint
        uses: ibiqlik/action-yamllint@v3
```

That being said, I've only pushed directly on main so far so this wouldn't help because the validation happens *after* the push. Perhaps there's a workflow involving branches and PRs while still taking advantage of GitOps (maybe a separate cluster just for pre-merge applying stuff?), but for my usecase this was the easiest way. For this lint to work, I'll go ahead and enable Branch Protection on main and only use PRs from now on.

I get some errors because of too long lines in `clusters/rke2/flux-system/gotk-components.yaml` so I'll ignore that in the `.yamllint` file:

```
extends: default

ignore: |
  **/gotk-components.yaml
```