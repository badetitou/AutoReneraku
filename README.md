# Autoreneraku

## Setup

### Create a PAT token

We cannot use the generic GitHub token when using autoreneraku, so we will define a Personnal token.

1. in https://github.com/settings/tokens/new
2. Select: `repo`
3. Set the variable in your repo `settings/secrets/actions` as PAT

### Update your ci configuration

You need to add

1. The loading of AutoReneraku
2. Set an execution file that run AutoReneraku (`ci/autoReneraku.st`)

Full example:

```ston
SmalltalkCISpec {
  #postLoading : [
    'ci/autoReneraku.st'
  ],
  #loading : [
    SCIMetacelloLoadSpec {
      #baseline : 'AutoRenerakuSample',
      #directory : 'src',
      #ignoreImage : true,
      #onConflict : #useIncoming,
      #onUpgrade : #useIncoming
    },
    SCIMetacelloLoadSpec {
      #baseline : 'AutoReneraku',
      #repository : 'github://badetitou/AutoReneraku:main',
      #directory : 'src',
      #ignoreImage : true,
      #onConflict : #useIncoming,
      #onUpgrade : #useIncoming
    }
  ],
  #testing : {
    #failOnZeroTests : false
  }
}
```

The ci file should be like this:

```st
| auto |

auto := AutoReneraku new.
auto prepareAutoReneraku.
auto run
```
