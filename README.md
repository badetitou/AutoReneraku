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
2. The option `#registerInIceberg : true` for your project to be analysed

Full example:

```ston
SmalltalkCISpec {
  #postLoading : [
    'ci/autoReneraku.st'
  ],
  #loading : [
    SCIMetacelloLoadSpec {
      #baseline : 'AutoReneraku',
      #repository : 'github://badetitou/AutoReneraku:main',
      #directory : 'src',
      #ignoreImage : true,
      #onConflict : #useIncoming,
      #onUpgrade : #useIncoming
    },
    SCIMetacelloLoadSpec {
      #baseline : 'AutoRenerakuSample',
      #directory : 'src',
      #ignoreImage : true,
      #onConflict : #useIncoming,
      #onUpgrade : #useIncoming,
      #registerInIceberg : true
    }
  ],
  #testing : {
    #failOnZeroTests : false
  }
}
```
