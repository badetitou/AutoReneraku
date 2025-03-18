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

{ #category : 'running' }
AutoRenerakuTest >> setUp [

	super setUp.
	auto := AutoReneraku new
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticsToSuggestion [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self assert: (result isKindOf: Dictionary)
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticsToSuggestionCheckBody [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self assert: (result at: #body) equals: '```suggestion
outside := 1 > 2
	           ifTrue: [ 3 ]
	           ifFalse: [ 4 ]
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticsToSuggestionCheckPath [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self
		assert: (result at: #path)
		equals: 'src/AutoReneraku-Tests/ARSample2.class.st'
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticsToSuggestionLine [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self assert: (result at: #line) equals: 14
]

{ #category : 'tests' }
AutoRenerakuTest >> testConvertRenerakuCriticsToSuggestionStartLine [

	| critics result |
	critics := auto reviewForMethod: ARSample2 >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self assert: (result at: #start_line) equals: 12
]

{ #category : 'tests' }
AutoRenerakuTest >> testRenerakuOnProtol [

	| critics result |
	critics := auto reviewForMethod: ARSample2SubClass >> #testOutside.
	result := auto convertRenerakuCriticsToSuggestion: critics anyOne.
	self assert: (result isKindOf: Dictionary)
]
