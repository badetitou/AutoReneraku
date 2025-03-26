# Autoreneraku

## Setup

This project uses variables from [Smalltalk-CI](https://github.com/hpi-swa/smalltalkCI) for now.
So one need first to setup smalltalk-ci to test its project.

### Create a PAT token

We cannot use the generic GitHub token when using autoreneraku, so we will define a Personnal token.

1. in https://github.com/settings/tokens/new
2. Select: `repo`
3. Set the variable in your repo `settings/secrets/actions` as PAT

### Update your ci configuration

You need to add

1. Checkout your all project
   ```yml
    - uses: actions/checkout@v2
      with:
        fetch-depth: '0'
   ```
2. Add the AutoReneraku step
    ```yml
    - name: AutoReneraku
      uses: badetitou/AutoReneraku@main
      with:
        pat: ${{ secrets.PAT }}
    ```

Full example:

```yml
name: myCI

# Controls when the action will run. Triggers the workflow on push or pull request
# events but only for the development branch
on:
  pull_request:
    branches: 
      - v*
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      PROJECT_NAME: ${{ matrix.smalltalk }}
      PULL_REQUEST_NUMBER: ${{ github.event.number }}
      COMMIT_SHA: ${{ github.event.pull_request.head.sha }}
    strategy:
      matrix:
        smalltalk: [ Pharo64-12  ]
    name: ${{ matrix.smalltalk }}
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: '0'
      - uses: hpi-swa/setup-smalltalkCI@v1
        id: smalltalkci
        with:
          smalltalk-image: ${{ matrix.smalltalk }}
      - run: smalltalkci -s ${{ steps.smalltalkci.outputs.smalltalk-image }} .smalltalk-autoreneraku.ston
        shell: bash
        timeout-minutes: 15
      - name: AutoReneraku
        uses: badetitou/AutoReneraku@main
        with:
          pat: ${{ secrets.PAT }}
```
