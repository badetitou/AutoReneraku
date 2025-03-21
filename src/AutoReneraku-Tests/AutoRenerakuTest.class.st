"
An AutoRenerakuTest is a test class for testing the behavior of AutoReneraku
"
Class {
	#name : 'AutoRenerakuTest',
	#superclass : 'TestCase',
	#instVars : [
		'auto'
	],
	#category : 'AutoReneraku-Tests',
	#package : 'AutoReneraku-Tests'
}

{ #category : 'tests' }
AutoRenerakuTest >> setUp [

	super setUp.
	auto := AutoReneraku new
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticToSuggestion [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticToSuggestion: critics anyOne.
	self assert: (result isKindOf: Dictionary)
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticToSuggestionCheckBody [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticToSuggestion: critics anyOne.
	self assert: (result at: #body) equals: '```suggestion
outside := 1 > 2
	           ifTrue: [ 3 ]
	           ifFalse: [ 4 ]
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticToSuggestionCheckPath [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticToSuggestion: critics anyOne.
	self
		assert: (result at: #path)
		equals: 'src/AutoReneraku-Tests/ARSample2.class.st'
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticToSuggestionLine [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticToSuggestion: critics anyOne.
	self assert: (result at: #line) equals: 14
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticToSuggestionStartLine [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticToSuggestion: critics anyOne.
	self assert: (result at: #start_line) equals: 12
]

{ #category : 'tests' }
AutoRenerakuTest >> testEqualsTrue [

	| critics result |
	critics := auto reviewForMethod: ARSample1 >> #testEqualsTrue.
	result := auto convertRenerakuCriticsToSuggestion: critics
]
