Class {
	#name : 'ARSample2',
	#superclass : 'Object',
	#category : 'AutoReneraku-Tests',
	#package : 'AutoReneraku-Tests'
}

{ #category : 'tests' }
ARSample2 >> testOutside [

	| outside |
	1 > 2
		ifTrue: [ outside := 3 ]
		ifFalse: [ outside := 4 ]
]
