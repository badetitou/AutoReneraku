# Autoreneraku

[![Coverage Status](https://coveralls.io/repos/github/badetitou/AutoReneraku/badge.svg?branch=main)](https://coveralls.io/github/badetitou/AutoReneraku?branch=main)

## Setup

This project uses variables from [Smalltalk-CI](https://github.com/hpi-swa/smalltalkCI) for now.
So one need first to setup smalltalk-ci to test its project.

### Create token

We cannot use the generic GitHub token when using autoreneraku, so we will define a fine-grained token.
There is two options: a Personal Access Token, or creating a GitHub app that will act instead of a user.

#### Personal Access Token

> This token can also be created as part of organization for better usability

1. in https://github.com/settings/personal-access-tokens/new
2. Select the repositories for this token (one, or all the repository you wanna use AutoReneraku)
3. Select: `Pull Requests` with Read and Write access
4. Set the variable in your repo `settings/secrets/actions` as PAT

#### GitHub app

If you want to use a github app:

1. First create one attached to [your personal account](https://github.com/settings/apps) or an organisation account.
2. Unckeck all options, and select for permissions: `Pull Requests` with Read and Write access
3. Create a Private Key and keep it
4. Keep the AppID
5. Install the app in the repositories you want to use the project.
6. Add as secrets the Private Key and AppID (for instance with secrets `AUTO_RENERAKU_APP_ID`, and `AUTO_RENERAKU_PRIVATE_KEY`)

Then, check the next section with the possible adaptation.


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
      if: github.event_name == 'pull_request'
    ```

If you use the *GitHub app* approach, consider this piece of code for the Autoreneraku step

```yml
# Auto Reneraku
- name: Generate a token
  id: generate-token
  uses: actions/create-github-app-token@v1
  with:
    app-id: ${{ secrets.AUTO_RENERAKU_APP_ID }}
    private-key: ${{ secrets.AUTO_RENERAKU_PRIVATE_KEY }}
- name: AutoReneraku
  uses: badetitou/AutoReneraku@main
  with:
    pat:  ${{ steps.generate-token.outputs.token }}
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
        if: github.event_name == 'pull_request'
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
