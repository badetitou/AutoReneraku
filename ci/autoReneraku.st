| auto critics data prNumber |

auto := AutoReneraku new.
auto token: (Smalltalk os environment at: 'GITHUB_TOKEN').

critics := auto reviewForMethod: ARSample >> #testOutside.

critics do: [ :critic | 
	data := auto convertRenerakuCriticsToSuggestion: critics anyOne. 
	data at: 'commit_id' put: (Smalltalk os environment at: 'GITHUB_SHA').

	prNumber := (Smalltalk os environment at: 'PULL_REQUEST_NUMBER').

	auto post: ('https://api.github.com/repos/badetitou/AutoReneraku/pulls/', prNumber printString, '/comments') contents: data ]
