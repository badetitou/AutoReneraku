Class {
	#name : 'BaselineOfAutoReneraku',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfAutoReneraku',
	#package : 'BaselineOfAutoReneraku'
}

{ #category : 'baselines' }
BaselineOfAutoReneraku >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.

		self definePackages: spec.

		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> defineDependencies: spec [
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> defineGroups: spec [
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> definePackages: spec [

	spec
		package: 'AutoReneraku';
		package: 'AutoReneraku-Tests'
		with: [ spec requires: #( 'AutoReneraku' ) ];
		package: 'AutoReneraku-Sample'
]
