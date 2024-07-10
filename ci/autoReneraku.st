| auto critics data prNumber url |

auto := AutoReneraku new.
auto token: (Smalltalk os environment at: 'PAT').

critics := auto reviewForMethod: ARSample >> #testOutside.
Stdio stderr << (ARSample >> #testOutside) sourceCode printString.

critics do: [ :critic | 
	data := auto convertRenerakuCriticsToSuggestion: critic. 
	data at: 'commit_id' put: (Smalltalk os environment at: 'GITHUB_SHA').

	prNumber := (Smalltalk os environment at: 'PULL_REQUEST_NUMBER').
	
	Stdio stderr << String crlf.
	
	url := String streamContents: [ :str |  str << 'https://api.github.com/repos/badetitou/AutoReneraku/pulls/'.
		str << 12 printString.
		str <<  '/comments' ].
	Stdio stderr << url.
	Stdio stderr << String crlf.

	Stdio stderr << (auto post: url contents: data) printString ]

