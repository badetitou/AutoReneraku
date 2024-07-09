| auto critics data prNumber |

auto := AutoReneraku new.
auto token: (Smalltalk os environment at: 'PAT').

critics := auto reviewForMethod: ARSample >> #testOutside.
Stdio stderr << (ARSample >> #testOutside) sourceCode printString.

critics do: [ :critic | 
	data := auto convertRenerakuCriticsToSuggestion: critic. 
	data at: 'commit_id' put: (Smalltalk os environment at: 'GITHUB_SHA').

	prNumber := (Smalltalk os environment at: 'PULL_REQUEST_NUMBER').

	Stdio stderr <<
		(auto post: ('https://api.github.com/repos/badetitou/AutoReneraku/pulls/', prNumber printString, '/comments') contents: data) printString ]
