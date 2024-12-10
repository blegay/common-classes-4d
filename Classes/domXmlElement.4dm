
property _domElementRef : Text

//TODO: cdata

Class constructor($domElementRef : Text)
	If (This:C1470._domElementRefIsValid($domElementRef))
		This:C1470._domElementRef:=$domElementRef
	Else 
		This:C1470._domElementRef:=""
	End if 
	
	
	//MARK:- getter functions
	
Function get isValid->$isValid : Boolean
	If (Length:C16(This:C1470._domElementRef)>0)
		$isValid:=This:C1470._domElementRefIsValid(This:C1470._domElementRef)
	End if 
	
Function get value()->$value : Variant
	If (This:C1470.isValid)
		DOM GET XML ELEMENT VALUE:C731(This:C1470._domElementRef; $value)
	End if 
	
Function get attributes()->$attributes : Object
	If (This:C1470.isValid)
		$attributes:=New object:C1471
		
		var $domElementRef : Text
		$domElementRef:=This:C1470._domElementRef
		
		var $attrName : Text
		var $attrValue : Variant
		var $i : Integer
		For ($i; 1; DOM Count XML attributes:C727($domElementRef))
			DOM GET XML ATTRIBUTE BY INDEX:C729($domElementRef; $i; $attrName; $attrValue)
			$attributes[$attrName]:=$attrValue
		End for 
		
	End if 
	
Function get name->$elementName : Text
	If (This:C1470.isValid)
		DOM GET XML ELEMENT NAME:C730(This:C1470._domElementRef; $elementName)
	End if 
	
Function get attributeExists($attrNameSearch : Text)->$exists : Boolean
	$exists:=False:C215
	If (This:C1470.isValid)
		
		var $domElementRef : Text
		$domElementRef:=This:C1470._domElementRef
		
		var $attrName : Text
		var $attrValue : Variant
		var $i; $count : Integer
		$count:=DOM Count XML attributes:C727($domElementRef)
		For ($i; 1; $count)
			DOM GET XML ATTRIBUTE BY INDEX:C729($domElementRef; $i; $attrName; $attrValue)
			If (($attrName=$attrNameSearch) && This:C1470._textIsEqualStrict($attrName; $attrNameSearch))
				$exists:=True:C214
				$i:=$count
			End if 
		End for 
		
	End if 
	
Function get domRef->$domElement : Text
	$domElement:=This:C1470._domElementRef
	
	
	//MARK:- modifying functions
	
Function set value($value : Variant)
	If (This:C1470.isValid)
		DOM SET XML ELEMENT VALUE:C868(This:C1470._domElementRef; $value)
	End if 
	
Function set attributes($attributes : Object)
	If (This:C1470.isValid)
		If ($attributes#Null:C1517)
			var $domElementRef : Text
			$domElementRef:=This:C1470._domElementRef
			
			var $attrName : Text
			var $attrValue : Variant
			For each ($attrName; $attributes)
				$attrValue:=$attributes[$attrName]
				DOM SET XML ATTRIBUTE:C866($domElementRef; $attrName; $attrValue)
			End for each 
		End if 
	End if 
	
Function set name($elementName : Text)
	
	//If (This.isValid)
	Try
		DOM SET XML ELEMENT NAME:C867(This:C1470._domElementRef; $elementName)
	Catch
		var $errors : Collection
		$errors:=Last errors:C1799
	End try
	//Else 
	//$result.errors:=
	//End if 
	
Function appendChildElement($elementName : Text; $elementValue : Variant; $attributes : Object)->$domElement : cs:C1710.domXmlElement
	
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Append XML child node:C1080(This:C1470._domElementRef; XML ELEMENT:K45:20; $elementName)
		If (This:C1470._domElementRefIsValid($domElementRef))
			If ((Count parameters:C259>1) & ($elementValue#Null:C1517))
				DOM SET XML ELEMENT VALUE:C868($domElementRef; $elementValue)
			End if 
			If ((Count parameters:C259>2) & ($attributes#Null:C1517))
				var $attrName : Text
				var $attrValue : Variant
				For each ($attrName; $attributes)
					$attrValue:=$attributes[$attrName]
					DOM SET XML ATTRIBUTE:C866($domElementRef; $attrName; $attrValue)
				End for each 
				
			End if 
			
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function appendChildNode($childType : Integer; $childValue : Variant)->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Append XML child node:C1080(This:C1470._domElementRef; $childType; $childValue)
		If (($childType=XML ELEMENT:K45:20) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function appendElement($domElementSource : cs:C1710.domXmlElement)->$domElement : cs:C1710.domXmlElement
	//TODO: renommer appendElement => copyElement ?
	
	If (This:C1470.isValid)
		If ($domElementSource.isValid)
			var $domElementRef : Text
			$domElementRef:=DOM Append XML element:C1082(This:C1470._domElementRef; $domElementSource.domRef)
			If (This:C1470._domElementRefIsValid($domElementRef))
				$domElement:=cs:C1710.domXmlElement.new($domElementRef)
			End if 
		End if 
	End if 
	
Function insertElement($domElementSource : cs:C1710.domXmlElement; $childIndex : Integer)->$domElement : cs:C1710.domXmlElement
	
	If (This:C1470.isValid)
		If ($domElementSource.isValid)
			var $domElementRef : Text
			$domElementRef:=DOM Insert XML element:C1083(This:C1470._domElementRef; $domElementSource.domRef; $childIndex)
			If (This:C1470._domElementRefIsValid($domElementRef))
				$domElement:=cs:C1710.domXmlElement.new($domElementRef)
			End if 
		End if 
	End if 
	
Function createElementByXpath($xpath : Text; $attributes : Object)->$domElement : cs:C1710.domXmlElement
	
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Create XML element arrays:C1097(This:C1470._domElementRef; $xpath)
		If (This:C1470._domElementRefIsValid($domElementRef))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
			$domElement.attributes:=$attributes
		End if 
		
	End if 
	
Function remove()
	// This function removes the current element
	
	If (This:C1470.isValid)
		DOM REMOVE XML ELEMENT:C869(This:C1470._domElementRef)
	End if 
	
Function removeAttribute($attrName : Text)
	// This function removes an attribute
	
	If (This:C1470.isValid)
		DOM REMOVE XML ATTRIBUTE:C1084(This:C1470._domElementRef; $attrName)
	End if 
	
	//MARK:- navigation functions
	
Function get parent->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get parent XML element:C923(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get root->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get root XML element:C1053(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get xmlDocument->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get XML document ref:C1088(This:C1470._domElementRef)
		If (This:C1470._domElementRefIsValid($domElementRef))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get previousSibling->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get previous sibling XML element:C924(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get nextSibling->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get next sibling XML element:C724(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get firstChild->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get first child XML element:C723(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get lastChild->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Get last child XML element:C925(This:C1470._domElementRef)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function get childElements->$domElementColl : Collection
	
	If (This:C1470.isValid)
		$domElementColl:=New collection:C1472
		
		ARRAY LONGINT:C221($tl_domElementType; 0)
		ARRAY TEXT:C222($tt_domElementRefs; 0)
		
		DOM GET XML CHILD NODES:C1081(This:C1470._domElementRef; $tl_domElementType; $tt_domElementRefs)
		
		var $i : Integer
		For ($i; 1; Size of array:C274($tt_domElementRefs))
			If ($tl_domElementType{$i}=XML ELEMENT:K45:20)
				$domElementColl.push(cs:C1710.domXmlElement.new($tt_domElementRefs{$i}))
			End if 
		End for 
		
		ARRAY LONGINT:C221($tl_domElementType; 0)
		ARRAY TEXT:C222($tt_domElementRefs; 0)
	End if 
	
Function get childNodes->$nodes : Collection
	
	If (This:C1470.isValid)
		$domElementColl:=New collection:C1472
		
		ARRAY LONGINT:C221($tl_domElementType; 0)
		ARRAY TEXT:C222($tt_domElementRefs; 0)
		
		DOM GET XML CHILD NODES:C1081(This:C1470._domElementRef; $tl_domElementType; $tt_domElementRefs)
		
		var $i : Integer
		For ($i; 1; Size of array:C274($tt_domElementRefs))
			var $node : Object
			$node:=New object:C1471
			$node.type:=$tl_domElementType{$i}
			
			Case of 
				: ($tl_domElementType{$i}=XML CDATA:K45:13)  //7
					$node.cdata:=$tt_domElementRefs{$i}
					
				: ($tl_domElementType{$i}=XML comment:K45:8)  // 2
					$node.comment:=$tt_domElementRefs{$i}
					
				: ($tl_domElementType{$i}=XML DATA:K45:12)  // 6
					$node.data:=$tt_domElementRefs{$i}
					
				: ($tl_domElementType{$i}=XML DOCTYPE:K45:19)  //10
					$node.doctype:=$tt_domElementRefs{$i}
					
				: ($tl_domElementType{$i}=XML processing instruction:K45:9)  // 3
					$node.processingInstruction:=$tt_domElementRefs{$i}
					
				: ($tl_domElementType{$i}=XML ELEMENT:K45:20)  // 11
					$node.element:=cs:C1710.domXmlElement.new($tt_domElementRefs{$i})
			End case 
			
			$domElementColl.push($node)
		End for 
		
		ARRAY LONGINT:C221($tl_domElementType; 0)
		ARRAY TEXT:C222($tt_domElementRefs; 0)
	End if 
	
Function getElementByName($elementName : Text; $index : Integer)->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		var $value : Variant
		$domElementRef:=DOM Get XML element:C725(This:C1470._domElementRef; $elementName; $index>0 ? $index : 1; $value)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
	
	//MARK:- searching functions
	
Function findElement($xpath : Text)->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Find XML element:C864(This:C1470._domElementRef; $xpath)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
Function findElements($xpath : Text)->$domElementColl : Collection
	If (This:C1470.isValid)
		// $domElement : cs.domXmlElement
		$domElementColl:=New collection:C1472
		
		ARRAY TEXT:C222($tt_domElementRefs; 0)
		var $domElementRef : Text
		$domElementRef:=DOM Find XML element:C864(This:C1470._domElementRef; $xpath; $tt_domElementRefs)
		If (ok=1)
			var $i : Integer
			For ($i; 1; Size of array:C274($tt_domElementRefs))
				$domElementColl.push(cs:C1710.domXmlElement.new($tt_domElementRefs{$i}))
			End for 
		End if 
		ARRAY TEXT:C222($tt_domElementRefs; 0)
	End if 
	
Function findElementById($id : Text)->$domElement : cs:C1710.domXmlElement
	If (This:C1470.isValid)
		var $domElementRef : Text
		$domElementRef:=DOM Find XML element by ID:C1010(This:C1470._domElementRef; $id)
		If ((ok=1) && (This:C1470._domElementRefIsValid($domElementRef)))
			$domElement:=cs:C1710.domXmlElement.new($domElementRef)
		End if 
	End if 
	
	
	//MARK:- private functions
	
Function _newXpathSyntax()->$newXpathSyntax : Boolean
	
	$newXpathSyntax:=False:C215
	
	var $domRef : Text
	$domRef:=DOM Create XML Ref:C861("test")
	If (ok=1)
		
		var $domRefChild; $domRefGrandChild : Text
		$domRefChild:=DOM Append XML child node:C1080($domRef; XML ELEMENT:K45:20; "child")
		$domRefGrandChild:=DOM Append XML child node:C1080($domRefChild; XML ELEMENT:K45:20; "grandchild")
		
		ARRAY TEXT:C222($tt_domRefList; 0)
		
		var $xpath : Text
		$xpath:="grandchild"  // new xpath syntax
		//$xpath:="child/grandchild" // old xpath syntax
		
		var $domRefDummy : Text
		$domRefDummy:=DOM Find XML element:C864($domRefChild; $xpath; $tt_domRefList)
		If (Size of array:C274($tt_domRefList)=1)
			$newXpathSyntax:=True:C214
		Else   // $va_domRefDummy = "00000000000000000000000000000000" and $tt_domRefList size = 0
			
		End if 
		
		ARRAY TEXT:C222($tt_domRefList; 0)
		
		DOM CLOSE XML:C722($domRef)
	End if 
	
Function _domElementRefIsValid($domElementRef : Text)->$isValid : Boolean
	// This function checks that a domRef looks valid...
	//DONE: en faire une fonction de la classe
	//$isValid:=xml_domRefIsValid($domElementRef)  //($domElementRef#"")
	
	$isValid:=False:C215
	If (Length:C16($domElementRef)=32)
		
		var $domRefNull; $regex : Text
		$domRefNull:="00000000000000000000000000000000"
		$regex:="^[:xdigit:]{32}$"  // check that the string is made of 32 hex char
		
		If ($domElementRef#$domRefNull)
			$isValid:=Match regex:C1019($regex; $domElementRef; 1; *)
		End if 
		
	End if 
	
Function _textIsEqualStrict($text1 : Text; $text2 : Text)->$isEqualStrict : Boolean
	$isEqualStrict:=False:C215
	
	var $length : Integer
	$length:=Length:C16($text1)
	
	Case of 
		: ($vl_length#Length:C16($text2))
			//If the two string are not of the same length
			//no need to look further
			
		: ($vl_length=0)
			//two empty strings are equal
			$isEqualStrict:=True:C214
			
		Else 
			//we use diacritic-sensitive option for Position
			//if the result = 1 (and we know the strings are of same length)
			//then the strings are strictly equal
			
			$isEqualStrict:=(Position:C15($text1; $text2; 1; *)=1)
	End case 
	
	