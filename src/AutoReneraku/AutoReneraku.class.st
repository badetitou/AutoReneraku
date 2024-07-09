Class {
	#name : 'AutoReneraku',
	#superclass : 'Object',
	#instVars : [
		'client'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'private' }
AutoReneraku >> buildBodyOf: data basedon: renerakuCritic [

	data at: #body put: (String streamContents: [ :str |
			 str << '```suggestion
'.
			 str << renerakuCritic newNode formattedCode.
			 str << '
```' ])
]

{ #category : 'api' }
AutoReneraku >> buildLineOf: data basedOn: renerakuCritic [

	| startChar sc |
	sc := TonelWriter sourceCodeOf:
		      (self methodConcernedBy: renerakuCritic) methodClass.
	startChar := sc findString: ((renerakuCritic entity source
			               copyFrom: renerakuCritic entity sourceInterval first
			               to: renerakuCritic entity sourceInterval last)
			              copyReplaceAll: String cr
			              with: OSPlatform current lineEnding).

	data at: #line put: ((sc arToLineCharacter:
			  startChar + renerakuCritic entity sourceInterval size) at: #line)
		+ 1
]

{ #category : 'private' }
AutoReneraku >> buildPathOf: data basedOn: renerakuCritic [

	data at: #path put: (String streamContents: [ :str |
			 str << 'src/'.
			 str
			 <<
			 (self methodConcernedBy: renerakuCritic) methodClass package name.
			 str << '/'.
			 str << (self methodConcernedBy: renerakuCritic) methodClass name.
			 str << '.class.st' ])
]

{ #category : 'api' }
AutoReneraku >> buildStartLineOf: data basedOn: renerakuCritic [

	| startChar sc |
	sc := TonelWriter sourceCodeOf:
		      (self methodConcernedBy: renerakuCritic) methodClass.
	startChar := sc findString: ((renerakuCritic entity source
			               copyFrom: renerakuCritic entity sourceInterval first
			               to: renerakuCritic entity sourceInterval last)
			              copyReplaceAll: String cr
			              with: OSPlatform current lineEnding).

	data
		at: #start_line
		put: ((sc arToLineCharacter: startChar) at: #line) + 1
]

{ #category : 'api' }
AutoReneraku >> convertRenerakuCriticsToSuggestion: renerakuCritic [

	| data |
	data := Dictionary new.
	self buildBodyOf: data basedon: renerakuCritic.
	self buildPathOf: data basedOn: renerakuCritic.
	self buildStartLineOf: data basedOn: renerakuCritic.
	self buildLineOf: data basedOn: renerakuCritic.

	^ data
]

{ #category : 'initialization' }
AutoReneraku >> initialize [

	super initialize.
	client := ZnClient new.
	client forJsonREST
]

{ #category : 'private' }
AutoReneraku >> methodConcernedBy: renerakuCritic [

	^ renerakuCritic entity methodNode compiledMethod
]

{ #category : 'api' }
AutoReneraku >> reviewForMethod: aMethodNode [

	^ (aMethodNode ast allChildren flatCollect: [ :node |
		   ReAssignmentInIfTrueRule new check: node ])
]

{ #category : 'accessing' }
AutoReneraku >> token: aToken [

	client headerAt: #Authorization add: 'token' , aToken
]
