| auto critics data prNumber |

auto := AutoReneraku new.
auto token: '376d25f418439cbc92674e64b2c63fd3e2f56794' "(Smalltalk os environment at: 'GITHUB_TOKEN')".

critics := auto reviewForMethod: ARSample >> #testOutside.
Stdio stderr << (ARSample >> #testOutside) sourceCode printString.

critics do: [ :critic | 
	data := auto convertRenerakuCriticsToSuggestion: critics anyOne. 
	data at: 'commit_id' put: (Smalltalk os environment at: 'GITHUB_SHA').

	prNumber := (Smalltalk os environment at: 'PULL_REQUEST_NUMBER').

	Stdio stderr <<
		(auto post: ('https://api.github.com/repos/badetitou/AutoReneraku/pulls/', prNumber printString, '/comments') contents: data) printString ]
