Class {
	#name : 'ARSample',
	#superclass : 'Object',
	#category : 'AutoReneraku-Sample',
	#package : 'AutoReneraku-Sample'
}

{ #category : 'tests' }
ARSample >> testOutside [

	| outside |
	1 > 2
		           ifTrue: [ outside :=  3 ]
		           ifFalse: [ outside :=  4 ]
]
