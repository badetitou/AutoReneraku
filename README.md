# Autoreneraku

## Setup

This project uses variables from [Smalltalk-CI](https://github.com/hpi-swa/smalltalkCI) for now.
So one need first to setup smalltalk-ci to test its project.

### Create a PAT token

We cannot use the generic GitHub token when using autoreneraku, so we will define a fine-grained personnal access token.

> This token can also be created as part of organization for better usability

1. in https://github.com/settings/personal-access-tokens/new
2. Select the repositories for this token (one, or all the repository you wanna use AutoReneraku)
3. Select: `Pull Requests` with Read and Write access
4. Set the variable in your repo `settings/secrets/actions` as PAT

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

## Developer

It is possible to debug locally with a script like this one:

```st
auto := AutoReneraku new.
auto projectName: 'AutoReneraku-Sample'.
auto token: '<token>'.
auto url: 'https://api.github.com/repos/badetitou/AutoReneraku-Sample/pulls/3/comments'.
auto commitSha: '5f2c0995a5c9d19b679f77fd5d3f496d4c668d72'.
class := ARSample.
methods := class methods.
methods do: [ :method | auto autoRenerakuMethod: method ]
```
