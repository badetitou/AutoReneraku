Extension { #name : 'String' }

{ #category : '*AutoReneraku' }
String >> arToLineCharacter: position [
	"given a position, return a dictionnary with the line and character of the cursor at this position"

	| copy |
	copy := (self first: (position min: self size)) lines.
	copy
		ifEmpty: [ ^ {(#line -> 0).
			(#character -> 0)} asDictionary ].
	^ {(#line -> (copy size - 1)).
	(#character -> (copy last size max: 0))} asDictionary
]

{ #category : '*AutoReneraku' }
String >> toLineCharacter: position [
	"given a position, return a dictionnary with the line and character of the cursor at this position"

	| copy |
	copy := (self first: (position min: self size)) lines.
	copy
		ifEmpty: [ ^ {(#line -> 0).
			(#character -> 0)} asDictionary ].
	^ {(#line -> (copy size - 1)).
	(#character -> (copy last size max: 0))} asDictionary
]
