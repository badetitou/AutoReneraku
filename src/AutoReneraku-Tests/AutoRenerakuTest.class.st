"
An AutoRenerakuTest is a test class for testing the behavior of AutoReneraku
"
Class {
	#name : 'AutoRenerakuTest',
	#superclass : 'TestCase',
	#instVars : [
		'autoreneraku'
	],
	#category : 'AutoReneraku-Tests',
	#package : 'AutoReneraku-Tests'
}

{ #category : 'running' }
AutoRenerakuTest >> setUp [

	super setUp.

	autoreneraku := AutoReneraku new.
	autoreneraku projectName: 'AutoReneraku-Sample'
]

{ #category : 'running' }
AutoRenerakuTest >> tearDown [

	| registry |
	registry := IceRepository registry detect: [ :r |
		            r name = 'AutoReneraku-Sample' ].
	registry loadedPackages do: [ :package |
		package
			unload;
			load ].
	super tearDown
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOn [

	| method data |
	method := ARSample >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	self assert: (data at: #body) equals: '```suggestion
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForProtocol [

	| method data |
	method := ARSampleSubClass >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	self assert: (data at: #body) equals: '```suggestion
{ #category : ''tests'' }
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetFor [

	| method |
	method := ARSample >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 5.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetForProtocolUpdate [

	| method |
	method := ARSampleSubClass >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 1.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetFor [

	| method |
	method := ARSample >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 7.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetForProtocolUpdate [

	| method |
	method := ARSampleSubClass >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 1.
]
