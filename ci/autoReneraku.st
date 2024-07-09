auto := AutoReneraku new.
auto token: ''.
critics := auto reviewForMethod: ARSample >> #testOutside.

data := auto convertRenerakuCriticsToSuggestion: critics anyOne. 
data at: 'commit_id' put: (Smalltalk os environment at: 'GITHUB_SHA')

client post: 'https://api.github.com/repos/badetitou/AutoReneraku/pulls/1/comments' contents: data