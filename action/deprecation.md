# ⚠️ New Aura action available

The Aura action `tapasrc123/aura@main` will replaced by a new action at [tapasrc123/aura-action](https://github.com/tapasrc123/aura-action).
Moving to a new action allows us to better document the action in the marketplace and proper versioning of the action.

> [!NOTE]
> For now, the old action `tapasrc123/aura@main` will continue to work (and in fact it will call the new action under the hood), but it will not get any new features or fixes.

## Migrate to new action

In your workflow file, replace the following bit:

```yaml
- name: Run Aura 🔥
  uses: tapasrc123/aura@main # this line needs to change
  with:
    # your parameters here

- name: Run Aura 🔥
  uses: tapasrc123/aura-action@v1.1.0 # to this line
  with:
    # your parameters here
    include_private_tests: true # this will checkout the current repository and was the default behavior of the old action
    # if you used install_prerelease: true you should add this line and remove the old one
    aura_version: preview # pick the exact version of the Aura module you want to use or 'latest' or 'preview'
```
