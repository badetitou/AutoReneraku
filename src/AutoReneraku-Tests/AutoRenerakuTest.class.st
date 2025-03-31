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
	registry loadedPackages do: #reload.
	super tearDown
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetFor [

	| method |
	method := ARSample >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 5.
]
