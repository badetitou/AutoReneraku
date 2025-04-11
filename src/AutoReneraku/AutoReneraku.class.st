Class {
	#name : 'AutoReneraku',
	#superclass : 'Object',
	#instVars : [
		'client',
		'critiques',
		'projectName',
		'methodsToConsider',
		'url',
		'commitSha'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'api' }
AutoReneraku >> autoCorrectMethod: aMethod [
	"I return true if I applied some modification"

	| toApplyCritique |
	(self isMethodFormatted: aMethod) ifFalse: [ ^ false ].
	critiques := aMethod critiques.
	toApplyCritique := critiques select: [ :critique |
		                   critique providesChange ].
	toApplyCritique do: [ :critique | critique change execute ].
	^ toApplyCritique isNotEmpty
]

{ #category : 'api' }
AutoReneraku >> autoRenerakuMethod: aMethod [
	"I return true if I applied some modification"

	| savedDefinition |
	savedDefinition := aMethod.
	^ (self autoCorrectMethod: aMethod) ifTrue: [
		  self suggestNewMethod: aMethod.
		  savedDefinition methodClass compile: savedDefinition sourceCode ]
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
			  str << (String cr join: (changeBody lines allButFirst
					    copyFrom: startChange
					    to: startChange + stopChange - 1)).

			  str << '
```' ]) copyReplaceAll: OSPlatform current lineEnding with: String cr)
]

{ #category : 'private' }
AutoReneraku >> buildLineOf: data basedOn: method [

	| startChar sc diffStop line |
	sc := TonelWriter sourceCodeOf: method methodClass.
	startChar := self extractStartPosOf: method.
	diffStop := self computeDiffStopOffsetFor: method.
	line := ((sc arToLineCharacter: startChar) at: #line)
	        + (self computeDiffStartOffsetFor: method) - 1.
	diffStop ~= 0 ifTrue: [ line := line + diffStop - 1 ].
	data at: #line put: line
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
AutoReneraku >> commitSha [

	^ commitSha
]

{ #category : 'accessing' }
AutoReneraku >> commitSha: anObject [

	commitSha := anObject
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStartOffsetFor: method [

	| differences |
	differences := self computeDifferencesFor: method.
	^ differences findFirst: [ :diff | diff key ~= 'match' ]
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStopOffsetFor: method [

	| differences insert remove |
	differences := self computeDifferencesFor: method.
	insert := differences count: [ :diff | diff key = 'insert' ].
	remove := differences count: [ :diff | diff key = 'remove' ].
	^ remove min: insert
]

{ #category : 'accessing' }
AutoReneraku >> computeDifferencesFor: method [

	| registry iceDiff diffChild realModification differences |
	registry := IceRepository registry detect: [ :r |
		            r name = self projectName ].
	iceDiff := IceDiff new
		           sourceVersion: registry headCommit;
		           targetVersion: registry workingCopy;
		           buildForPackages:
			           { (registry packageNamed:
					            method methodClass package name) }.

	diffChild := (iceDiff tree allChildren select: [ :child |
		              child key = method selector and: [
			              child parent key = method methodClass name ] ])
		             anyOne.
	realModification := diffChild value.
	^ differences := (DiffMorph
		                  from: realModification leftContents
		                  to: realModification rightContents) difference
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

	(data at: #start_line) >= (data at: #line) ifTrue: [
		data at: #line put: (data at: #start_line).
		data removeKey: #start_line ].

	^ data
]

{ #category : 'initialization' }
AutoReneraku >> initialize [

	super initialize.
	client := ZnClient new.
	client forJsonREST
]

{ #category : 'accessing' }
AutoReneraku >> isMethodFormatted: aMethod [
	"Autoreneraku cannot apply on method not formatted. So we need to check this information first"

	^ aMethod sourceCode = aMethod ast formattedCode
]

{ #category : 'private' }
AutoReneraku >> methodConcernedBy: renerakuCritic [

	^ renerakuCritic entity methodNode compiledMethod
]

{ #category : 'private' }
AutoReneraku >> post: url contents: someData [

	^ client post: url contents: someData
]

{ #category : 'api' }
AutoReneraku >> prepareAutoReneraku [

	| filesNames classesNames classes prNumber |
	projectName := ((Smalltalk os environment at: 'GITHUB_REPOSITORY')
		                splitOn: '/') last.

	[
	(IceRepositoryCreator new
		 location: '.' asFileReference;
		 subdirectory: 'src';
		 createRepository)
		name: projectName;
		register ]
		on: IceDuplicatedRepository
		do: [
			Stdio stderr << 'Repository already installed in the image'.
			Stdio stderr << IceRepository registry printString ].



	filesNames := (Smalltalk os environment at: 'changed_files')
		              splitOn: ' '.
	classesNames := filesNames collect: [ :file |
		                ((file splitOn: '/') last splitOn: '.') first ].
	classes := classesNames collect: [ :className |
		           Smalltalk classNamed: className ].
	methodsToConsider := (classes reject: [ :clazz |
		                      clazz isNil "in case class is not found" ])
		                     flatCollect: [ :clazz | clazz methods ].
	self token: (Smalltalk os environment at: 'PAT').
	prNumber := Smalltalk os environment at: 'PULL_REQUEST_NUMBER'.
	url := 'https://api.github.com/repos/'
	       , (Smalltalk os environment at: 'GITHUB_REPOSITORY')
	       , '/pulls/' , prNumber , '/comments'.
	commitSha := Smalltalk os environment at: 'COMMIT_SHA'
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
AutoReneraku >> run [

	methodsToConsider do: [ :method | self autoRenerakuMethod: method ]
]

{ #category : 'api' }
AutoReneraku >> suggestNewMethod: aMethod [

	| data |
	data := Dictionary new.
	data at: 'commit_id' put: commitSha.
	self fillData: data withNewMethodData: aMethod.
	^ self post: url contents: data
]

{ #category : 'accessing' }
AutoReneraku >> token: aToken [

	client headerAt: #Authorization add: 'token ' , aToken
]

{ #category : 'accessing' }
AutoReneraku >> url [

	^ url
]

{ #category : 'accessing' }
AutoReneraku >> url: anObject [

	url := anObject
]
