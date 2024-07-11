Class {
	#name : 'ARSample',
	#superclass : 'Object',
	#category : 'AutoReneraku-Sample',
	#package : 'AutoReneraku-Sample'
}

{ #category : 'tests' }
ARSample >> testOutside [

	| outside |
outside := 1 > 2
	           ifTrue: [ 3 ]
	           ifFalse: [ 4 ]
]
