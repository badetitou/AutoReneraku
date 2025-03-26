Class {
	#name : 'AutoReneraku',
	#superclass : 'Object',
	#instVars : [
		'client',
		'critiques',
		'projectName'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'api' }
AutoReneraku >> autoCorrectMethod: aMethod [
	"I return true if I applied some modification"

	| toApplyCritique |
	critiques := aMethod critiques.
	toApplyCritique := critiques select: [ :critique |
		                   critique providesChange ].
	toApplyCritique do: [ :critique | critique change execute ].
	^ toApplyCritique isNotEmpty
]

{ #category : 'api' }
AutoReneraku >> autoRenerakuMethod: aMethod [
	"I return true if I applied some modification"

	(self autoCorrectMethod: aMethod) ifTrue: [
		self suggestNewMethod: aMethod ]
]

{ #category : 'private' }
AutoReneraku >> buildBodyOf: data basedOn: aMethod [

	| startChange stopChange |
	data at: #body put: ((String streamContents: [ :str |
			  | changeBody |
			  str << '```suggestion
'.

			  changeBody := String streamContents: [ :ch |
				                TonelWriter new
					                writeMethodDefinition:
					                aMethod asRingDefinition asMCMethodDefinition
					                parent: aMethod methodClass asClassDefinition
					                on: ch ].
			  startChange := self computeDiffStartOffsetFor: aMethod.
			  stopChange := self computeDiffStopOffsetFor: aMethod.
			  str << (String cr join:
				   (changeBody lines allButFirst
					    copyFrom: startChange
					    to: stopChange)).

			  str << '
```' ]) copyReplaceAll: OSPlatform current lineEnding with: String cr)
]

{ #category : 'private' }
AutoReneraku >> buildLineOf: data basedOn: method [

	| startChar sc |
	sc := TonelWriter sourceCodeOf: method methodClass.
	startChar := self extractStartPosOf: method.

	data at: #line put: ((sc arToLineCharacter: startChar) at: #line)
		+ (self computeDiffStopOffsetFor: method) - 1 "-1 pharo"
]

{ #category : 'private' }
AutoReneraku >> buildPathOf: data basedOn: method [

	data at: #path put: (String streamContents: [ :str |
			 str << 'src/'.
			 str
			 <<
			 method methodClass package name.
			 str << '/'.
			 str << method methodClass name.
			 str << '.class.st' ])
]

{ #category : 'private' }
AutoReneraku >> buildStartLineOf: data basedOn: method [

	| startChar sc |
	sc := TonelWriter sourceCodeOf: method methodClass.
	startChar := self extractStartPosOf: method.
	data
		at: #start_line
		put: ((sc arToLineCharacter: startChar) at: #line) + (self computeDiffStartOffsetFor: method) - 1 "-1 diff pharo"
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStartOffsetFor: method [

	| registry iceDiff diffChild realModification differences |
	registry := IceRepository registry detect: [ :r |
		            r name = self projectName ].
	iceDiff := IceDiff new
		           sourceVersion: registry headCommit;
		           targetVersion: registry workingCopy;
		           buildForPackages:
			           { (registry packageNamed: method methodClass package name) }.

	diffChild := (iceDiff tree allChildren select: [ :child |
		              child key = method selector ]) anyOne.
	realModification := diffChild value.
	differences := (DiffMorph
		                from: realModification leftContents
		                to: realModification rightContents) difference.
	^ differences findFirst: [ :diff | diff key ~= 'match' ]
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStopOffsetFor: method [

	| registry iceDiff diffChild realModification differences |
	registry := IceRepository registry detect: [ :r |
		            r name = self projectName ].
	iceDiff := IceDiff new
		           sourceVersion: registry headCommit;
		           targetVersion: registry workingCopy;
		           buildForPackages:
			           { (registry packageNamed: method methodClass package name) }.

	diffChild := (iceDiff tree allChildren select: [ :child |
		              child key = method selector ]) anyOne.
	realModification := diffChild value.
	differences := (DiffMorph
		                from: realModification leftContents
		                to: realModification rightContents) difference.
	^ (differences findLast: [ :diff | diff key ~= 'match' ]) - 3 "-3 to remove the [] and {} of tonel format"
]

{ #category : 'accessing' }
AutoReneraku >> extractStartPosOf: method [

	| startChar startLine sc firstLine aMethodDefinition aClassDefinition |
	sc := TonelWriter sourceCodeOf: method methodClass.
	aMethodDefinition := method asRingDefinition asMCMethodDefinition.
	aClassDefinition := method methodClass asClassDefinition.
	firstLine := String streamContents: [ :str |
		             | fullClassName writer |
		             writer := TonelWriter new.
		             fullClassName := writer
			                              classNameFor: aMethodDefinition
			                              parent: aClassDefinition.
		             TonelWriter new
			             splitMethodSource:
			             method asRingDefinition asMCMethodDefinition
			             into: [ :methodDeclaration :methodBody |
				             str << fullClassName << ' >> ' << methodDeclaration ] ].
	startChar := sc findString: firstLine.
	startLine := startChar.
	^ startLine
]

{ #category : 'private' }
AutoReneraku >> fillData: data withNewMethodData: aMethod [

	self buildBodyOf: data basedOn: aMethod.
	self buildPathOf: data basedOn: aMethod.
	self buildStartLineOf: data basedOn: aMethod.
	self buildLineOf: data basedOn: aMethod.

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

{ #category : 'private' }
AutoReneraku >> post: url contents: someData [

	^ client post: url contents: someData
]

{ #category : 'accessing' }
AutoReneraku >> projectName [

	^ projectName
]

{ #category : 'accessing' }
AutoReneraku >> projectName: anObject [

	projectName := anObject
]

{ #category : 'api' }
AutoReneraku >> suggestNewMethod: aMethod [

	| data prNumber url |
	data := Dictionary new.
	data at: 'commit_id' put: (Smalltalk os environment at: 'COMMIT_SHA').
	self fillData: data withNewMethodData: aMethod.
	prNumber := Smalltalk os environment at: 'PULL_REQUEST_NUMBER'.
	url := 'https://api.github.com/repos/', (Smalltalk os environment at: 'GITHUB_REPOSITORY'), '/pulls/', prNumber, '/comments'.
	self post: url contents: data
]

{ #category : 'accessing' }
AutoReneraku >> token: aToken [

	client headerAt: #Authorization add: 'token ' , aToken
]
