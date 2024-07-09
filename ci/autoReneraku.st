auto := AutoReneraku new.
auto token: ''.
critics := auto reviewForMethod: ARSample >> #testOutside.
data := auto convertRenerakuCriticsToSuggestion: critics anyOne. 

client post: 'https://api.github.com/repos/badetitou/AutoReneraku/pulls/1/comments' contents: data