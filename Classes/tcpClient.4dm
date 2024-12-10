// This class implements a TCP client using 4D Internet Commands plugin TCP commands
// This class is 4D v19+ compatible

Class constructor($host : Text; $port : Integer; $timeoutSeconds : Integer; $paramsSession : Integer)
	This:C1470.host:=$host
	This:C1470.port:=$port
	This:C1470.timeoutSeconds:=$timeoutSeconds
	This:C1470.paramsSession:=$paramsSession
	This:C1470.timeoutSecondsDefault:=0
	This:C1470.responseTimeoutSeconds:=10
	This:C1470.connexionRef:=0
	This:C1470.connectedTimestamp:=""
	This:C1470.lastState:=0
	This:C1470.uuid:=Generate UUID:C1066
	This:C1470.bufferBase64:=""
	This:C1470.bytesSent:=0
	This:C1470.bytesReceived:=0
	This:C1470.errorCount:=0
	This:C1470.debugBinary:=True:C214
	This:C1470.debugTextCharset:="UTF-8"
	
	// convert error code to error message
Function errorText($error : Integer)->$errorText : Text
	If ($error#0)
		$errorText:=IT_ErrorText($error)
	End if 
	
	// open tcp connexion
Function open()->$isOpened : Boolean
	
	If (This:C1470.host#"") & (This:C1470.port#0)
		This:C1470.timeoutSet()
		
		This:C1470.debug("open"; 4; "Connexion open host : "+This:C1470.host+", port : "+String:C10(This:C1470.port)+", paramsSession : "+String:C10(This:C1470.paramsSession)+"...")
		
		var $durationMs : Integer
		$durationMs:=Milliseconds:C459
		
		var $error; $mode; $connRef : Integer
		$mode:=0  // synchroneous
		$error:=TCP_Open(This:C1470.host; This:C1470.port; $connRef; This:C1470.paramsSession)
		
		var $synchronous; $tls : Boolean
		$synchronous:=(This:C1470.paramsSession=0) | (This:C1470.paramsSession=2)
		$tls:=(This:C1470.paramsSession=2) | (This:C1470.paramsSession=3)
		
		// asynchronous mode
		If (($error=0) & Not:C34($synchronous))
			
			var $stop : Boolean
			$stop:=False:C215
			
			var $timeout; $iters : Integer
			$timeout:=Tickcount:C458+(This:C1470.timeoutSeconds*60)
			$iters:=0
			
			Repeat 
				var $state : Integer
				$error:=TCP_State($connRef; $state)
				$iters:=$iters+1
				
				Case of 
					: ($error#0)
						$stop:=True:C214
						This:C1470.debug("open"; 4; "Connexion open (asynchronous, iters : "+String:C10($iters)+") error "+String:C10($error)+" : "+JSON Stringify:C1217(This:C1470))
						
					: ($state=8)
						$stop:=True:C214
						This:C1470.debug("open"; 4; "Connexion open (asynchronous, iters : "+String:C10($iters)+") success : "+JSON Stringify:C1217(This:C1470))
						
					: (Tickcount:C458>$timeout)
						$stop:=True:C214
						//$error:=61
						$error:=10064
						This:C1470.debug("open"; 2; "Connexion open (asynchronous, iters : "+String:C10($iters)+") failed : "+JSON Stringify:C1217(This:C1470))
						
					Else 
						IDLE:C311
						DELAY PROCESS:C323(Current process:C322; 1)
				End case 
			Until ($stop)
			
		End if 
		
		$durationMs:=Milliseconds:C459-$durationMs
		
		If ($error=0)
			$isOpened:=True:C214
			
			This:C1470.connexionRef:=$connRef
			This:C1470.connectedTimestamp:=Timestamp:C1445
			
			This:C1470.bufferSet()
			
			This:C1470.debug("open"; 4; "Connexion open success : "+JSON Stringify:C1217(This:C1470)+", duration : "+This:C1470.millisecondsFormatter($durationMs))
			
			This:C1470.connexionRegister()
			
			This:C1470.stateUpdate()
		Else 
			This:C1470.debug("open"; 2; "Connexion open failure : "+JSON Stringify:C1217(This:C1470)+", error : "+This:C1470.errorText($error)+" ("+String:C10($error)+"), duration : "+This:C1470.millisecondsFormatter($durationMs))
		End if 
		
		This:C1470.timeoutReset()
	Else 
		This:C1470.debug("open"; 2; "No connexion : "+JSON Stringify:C1217(This:C1470)+", error : no param")
	End if 
	
	// close tcp connexion
Function close()
	
	var $error; $connRef : Integer
	$connRef:=This:C1470.connexionRef
	If ($connRef#0)
		
		var $debug : Text
		$debug:="Connexion "+String:C10($connRef)
		If (This:C1470.connectedTimestamp#"")
			$debug:=$debug+" (open timestamp : "+This:C1470.connectedTimestamp+")"
		End if 
		$debug:=$debug+" state "+String:C10(This:C1470.lastState)+" => 0"
		
		$error:=TCP_Close($connRef)
		// $connRef is cleared (set to 0)
		
		If ($error=0)
			This:C1470.debug("close"; 4; $debug)
			This:C1470.debug("close"; 4; "Connexion "+String:C10(This:C1470.connexionRef)+" close success : "+JSON Stringify:C1217(This:C1470))
		Else 
			This:C1470.debug("close"; 4; "Connexion "+String:C10(This:C1470.connexionRef)+" close failure : "+JSON Stringify:C1217(This:C1470)+", error : "+This:C1470.errorText($error)+" ("+String:C10($error)+")")
		End if 
		
		//This.stateUpdate()
		
		This:C1470.connexionDeregister()
		
		This:C1470.connexionRef:=0
		This:C1470.connectedTimestamp:=""
		
		This:C1470.bytesSent:=0
		This:C1470.bytesReceived:=0
		This:C1470.errorCount:=0
		
		This:C1470.bufferSet()
	End if 
	
	// keep a list of opened connexion in the Storage
Function connexionRegister()
	
	var $connexionObj : Object
	$connexionObj:=New object:C1471
	$connexionObj.host:=This:C1470.host
	$connexionObj.port:=This:C1470.port
	$connexionObj.connexionRef:=This:C1470.connexionRef
	$connexionObj.connectedTimestamp:=This:C1470.connectedTimestamp
	$connexionObj.uuid:=This:C1470.uuid
	
	Case of 
		: (Storage:C1525.tcpClient=Null:C1517)
			
			var $tcp : Object
			$tcp:=New object:C1471("connexionList"; New collection:C1472($connexionObj))
			
			Use (Storage:C1525)
				Storage:C1525.tcpClient:=OB Copy:C1225($tcp; ck shared:K85:29)
			End use 
			
		: (Storage:C1525.tcpClient.connexionList#Null:C1517)
			
			$connexionObj:=OB Copy:C1225($connexionObj; ck shared:K85:29)
			Use (Storage:C1525.tcpClient.connexionList)
				Storage:C1525.tcpClient.connexionList.push($connexionObj)
			End use 
			
		Else 
			
	End case 
	
	// remove connexion from the list of opened connexion (in Storage)
Function connexionDeregister()
	
	If (Storage:C1525.tcpClient.connexionList#Null:C1517)
		
		Use (Storage:C1525.tcpClient.connexionList)
			var $found : Collection
			$found:=Storage:C1525.tcpClient.connexionList.indices("uuid = :1"; This:C1470.uuid).orderBy(ck descending:K85:8)
			//$found:=Storage.tcpClient.connexionList.indices("host = :1 and port = :2"; This.host; This.port).orderBy(ck descending)
			var $index : Integer
			For each ($index; $found)
				Storage:C1525.tcpClient.connexionList.remove($index)
			End for each 
		End use 
		
	End if 
	
	// update tcp connexion state
Function stateUpdate()->$state : Integer
	// mise à jour du statut de la connexion
	
	$state:=0
	
	var $error; $connRef : Integer
	$connRef:=This:C1470.connexionRef
	
	$error:=TCP_State($connRef; $state)
	If ($error=0)
		
		If (This:C1470.lastState#$state)
			var $debug : Text
			$debug:="Connexion "+String:C10($connRef)
			If (This:C1470.connectedTimestamp#"")
				$debug:=$debug+" (open timestamp : "+This:C1470.connectedTimestamp+")"
			End if 
			$debug:=$debug+" state "+String:C10(This:C1470.lastState)+" => "+String:C10($state)
			This:C1470.debug("stateUpdate"; 4; $debug)
			
			This:C1470.lastState:=$state
			
		End if 
		
	Else 
		This:C1470.debug("stateUpdate"; 2; "Connexion "+String:C10($connRef)+" state failure, error : "+This:C1470.errorText($error)+" ("+String:C10($error)+")")
		This:C1470.errorCount:=This:C1470.errorCount+1
	End if 
	
	// returns true if the tcp connexion is opend
Function connexionOpened()->$connexionOpened : Boolean
	$connexionOpened:=(This:C1470.stateUpdate()=8)
	
	// receive binary data from tcp stream
Function receiveBlob()->$blob : Blob
	
	var $error; $connRef : Integer
	$connRef:=This:C1470.connexionRef
	
	$error:=TCP_ReceiveBLOB($connRef; $blob)
	
	Case of 
		: (($error=0) & (BLOB size:C605($blob)=0))
			This:C1470.debug("receiveBlob"; 8; ">>> nothing to receive")
			
		: (($error=0) & (BLOB size:C605($blob)>0))
			This:C1470.debug("receiveBlob"; 8; ">>> received "+String:C10(BLOB size:C605($blob))+" bytes")
			This:C1470.bytesReceived:=This:C1470.bytesReceived+BLOB size:C605($blob)
			
		Else 
			This:C1470.debug("receiveBlob"; 2; "receive blob error "+String:C10($error)+" : "+This:C1470.errorText($error)+" ("+String:C10($error)+")")
			This:C1470.errorCount:=This:C1470.errorCount+1
	End case 
	
	This:C1470.stateUpdate()
	
	// read blob until last delimiter found
	// if extra data is received after last delimiter on buffer, it will be returned in next calls (when delimiter is received)
	// data is returned with delimiter included
Function receiveBlobUntilLast($delimiter : Blob)->$blob : Blob
	
	ASSERT:C1129(BLOB size:C605($delimiter)>0; "empty delimiter")
	
	SET BLOB SIZE:C606($blob; 0)
	
	If (This:C1470.connexionOpened())
		
		// there is no warranty that the data is fully received in one block until delimiter.
		// data can be received in chunks
		// we are going to use a buffer to accumulate received data until we received a delimiter
		// we will do a reverse blob search (from the end) to find the last delimiter
		// if delimiter is found what is after the last delimiter will be added to the buffer for subsequent calls
		// If no delimiter is found, received bytes will be added to the buffer.
		
		$blob:=This:C1470.receiveBlob()
		If (BLOB size:C605($blob)>0)
			
			This:C1470.debug("receiveBlobUntilLast"; 6; "received blob : "+This:C1470.debugBlobToText($blob))
			
			// retrieve $buffer from previous calls
			C_BLOB:C604($buffer)
			$buffer:=This:C1470.bufferGet()
			
			If (BLOB size:C605($buffer)>0)
				This:C1470.debug("receiveBlobUntilLast"; 6; "buffer get : "+This:C1470.debugBlobToText($buffer))
				
				// insert $buffer at begining of $blob
				INSERT IN BLOB:C559($blob; 0; BLOB size:C605($buffer); 0x00FF)
				COPY BLOB:C558($buffer; $blob; 0; 0; BLOB size:C605($buffer))
				
				This:C1470.debug("receiveBlobUntilLast"; 6; "received blob (with buffer) : "+This:C1470.debugBlobToText($blob))
			End if 
			
			var $blobSize; $delimiterSize; $offset; $delimiterOffset; $offsetPosition; $blobOffset; $newBufferSize : Integer
			$blobSize:=BLOB size:C605($blob)
			$delimiterSize:=BLOB size:C605($delimiter)
			$offsetPosition:=-1
			
			// do the reverse search (search for $delimiter in $blob from the end)
			
			//### Setting Execution Control OFF  -  Bruno LEGAY 2023.07.30
			//%R-
			//###    
			
			If (($blobSize>0) & ($blobSize>=$delimiterSize))
				
				For ($offset; $blobSize-1; $delimiterSize-1; -1)
					
					If ($blob{$offset}=$delimiter{$delimiterSize-1})
						
						If ($delimiterSize>1)  // mutlibytes delimiter
							
							$blobOffset:=$offset
							For ($delimiterOffset; $delimiterSize-2; 0; -1)
								$blobOffset:=$blobOffset-1
								
								Case of 
									: ($blob{$blobOffset}#$delimiter{$delimiterOffset})  // data is not a delimiter...
										$delimiterOffset:=0  //get out of the inner loop
										
									: ($delimiterOffset=0)  // last byte of mutlibytes delimiter found at offset $blobOffset (all matching)
										$offsetPosition:=$blobOffset
										$offset:=0
								End case 
								
							End for 
							
						Else 
							$offsetPosition:=$offset  // 1 byte delimiter found at offset $offset
							$offset:=0
						End if 
						
					End if 
					
				End for 
				
			End if 
			
			//### Setting Execution Control ON  -  Bruno LEGAY 2023.07.30
			//%R+
			//### 
			
			If ($offsetPosition>=0)  // the $delimiter has been found in the $blob at offset $offsetPosition
				
				// calculate number of bytes after the $delimiter
				$newBufferSize:=BLOB size:C605($blob)-$offsetPosition-$delimiterSize
				
				// $buffer is used, lets clear it.
				SET BLOB SIZE:C606($buffer; 0)
				
				If ($newBufferSize>0)
					// if there is a new buffer, lets copy this buffer bytes from $blob
					COPY BLOB:C558($blob; $buffer; $offsetPosition+$delimiterSize; 0; $newBufferSize)
					
					// and truncate the blob to remove the bytes after the last $delimiter
					SET BLOB SIZE:C606($blob; BLOB size:C605($blob)-$newBufferSize)
					
					//Else 
					//$blob:=$blob
				End if 
				
			Else 
				// $delimiter not found in the $blob. Add the received bytes to the buffer
				// insert $blob at the end of $buffer
				$buffer:=$blob
				$newBufferSize:=BLOB size:C605($buffer)
				
				// no $delimiter means no significant data to process
				SET BLOB SIZE:C606($blob; 0)
			End if 
			
			If ($newBufferSize>0)
				This:C1470.debug("receiveBlobUntilLast"; 6; "new buffer : "+This:C1470.debugBlobToText($buffer))
			End if 
			
			// store the buffer for next calls
			This:C1470.bufferSet($buffer)
			
		Else 
			IDLE:C311
			DELAY PROCESS:C323(Current process:C322; 1)
		End if 
		
	End if 
	
	// read blob until first delimiter found
	// if extra data is received after first delimiter on buffer, it will be returned in next calls (when delimiter is received)
	// data is returned with delimiter included
Function receiveBlobUntilFirst($delimiter : Blob)->$blob : Blob
	
	ASSERT:C1129(BLOB size:C605($delimiter)>0; "empty delimiter")
	
	SET BLOB SIZE:C606($blob; 0)
	
	// there is no warranty that the data is fully received in one block until delimiter.
	// data can be received in chunks
	// we are going to use a buffer to accumulate received data until we received a delimiter
	// we will do a blob search (from the start) to find the first delimiter
	// if delimiter is found what is after the first delimiter will be added to the buffer for subsequent calls
	// If no delimiter is found, received bytes will be added to the buffer.
	
	$blob:=This:C1470.receiveBlob()
	If ((BLOB size:C605($blob)>0) | (This:C1470.bufferBase64#""))
		
		This:C1470.debug("receiveBlobUntilFirst"; 6; "received blob : "+This:C1470.debugBlobToText($blob))
		
		// retrieve $buffer from previous calls
		C_BLOB:C604($buffer)
		$buffer:=This:C1470.bufferGet()
		
		If (BLOB size:C605($buffer)>0)
			This:C1470.debug("receiveBlobUntilLast"; 6; "buffer get : "+This:C1470.debugBlobToText($buffer))
			
			// insert $buffer at begining of $blob
			INSERT IN BLOB:C559($blob; 0; BLOB size:C605($buffer); 0x00FF)
			COPY BLOB:C558($buffer; $blob; 0; 0; BLOB size:C605($buffer))
			
			This:C1470.debug("receiveBlobUntilLast"; 6; "received blob (with buffer) : "+This:C1470.debugBlobToText($blob))
		End if 
		
		var $blobSize; $delimiterSize; $offset; $delimiterOffset; $offsetPosition; $startOffset; $blobOffset; $newBufferSize : Integer
		$blobSize:=BLOB size:C605($blob)
		$delimiterSize:=BLOB size:C605($delimiter)
		$offsetPosition:=-1
		$startOffset:=0
		
		// search (search for $delimiter in $blob from the start)
		
		//### Setting Execution Control OFF  -  Bruno LEGAY 2023.07.30
		//%R-
		//###   
		
		For ($offset; $startOffset; $blobSize-$delimiterSize)
			
			If ($blob{$offset}=$delimiter{0})
				
				If ($delimiterSize>1)
					
					For ($delimiterOffset; $delimiterSize-1; 1; -1)
						
						Case of 
							: ($blob{$offset+$delimiterOffset}#$delimiter{$delimiterOffset})
								$delimiterOffset:=0  //$delimiterSize  `get out of the inner ($delimiterOffset) loop
								
							: ($delimiterOffset=1)
								$offsetPosition:=$offset
								$offset:=$blobSize
						End case 
						
					End for 
					
				Else 
					$offsetPosition:=$offset
					$offset:=$blobSize
				End if 
				
			End if 
			
		End for 
		
		//### Setting Execution Control ON  -  Bruno LEGAY 2023.07.30
		//%R+
		//### 
		
		If ($offsetPosition>=0)  // the $delimiter has been found in the $blob at offset $offsetPosition
			
			// calculate number of bytes after the $delimiter
			$newBufferSize:=BLOB size:C605($blob)-$offsetPosition-$delimiterSize
			
			// $buffer is used, lets clear it.
			SET BLOB SIZE:C606($buffer; 0)
			
			If ($newBufferSize>0)
				// if there is a new buffer, lets copy this buffer bytes from $blob
				COPY BLOB:C558($blob; $buffer; $offsetPosition+$delimiterSize; 0; $newBufferSize)
				
				// and truncate the blob to remove the bytes after the last $delimiter
				SET BLOB SIZE:C606($blob; BLOB size:C605($blob)-$newBufferSize)
				
				//Else 
				//$blob:=$blob
			End if 
			
		Else 
			// $delimiter not found in the $blob. Add the received bytes to the buffer
			// insert $blob at the end of $buffer
			$buffer:=$blob
			$newBufferSize:=BLOB size:C605($buffer)
			
			// no $delimiter means no significant data to process
			SET BLOB SIZE:C606($blob; 0)
		End if 
		
		If ($newBufferSize>0)
			This:C1470.debug("receiveBlobUntilFirst"; 6; "new buffer : "+This:C1470.debugBlobToText($buffer))
		End if 
		
		// store the buffer for next calls
		This:C1470.bufferSet($buffer)
		
	Else 
		IDLE:C311
		DELAY PROCESS:C323(Current process:C322; 1)
	End if 
	
	// read blob until data size
	// if extra data is received after size on buffer, it will be returned in next calls
Function receiveBlobSize($size : Integer)->$blob : Blob
	
	ASSERT:C1129($size>0; "invalid size : "+String:C10($size))
	
	SET BLOB SIZE:C606($blob; 0)
	
	$blob:=This:C1470.receiveBlob()
	If (BLOB size:C605($blob)>0)
		
		// retrieve $buffer from previous calls
		C_BLOB:C604($buffer)
		$buffer:=This:C1470.bufferGet()
		
		If (BLOB size:C605($buffer)>0)
			// NOTE : TCP_ReceiveBLOB seem to receive 172 032 bytes at a time max
			This:C1470.debug("receiveBlobSize"; 6; "received blob : "+String:C10(BLOB size:C605($blob))+" byte(s),"+\
				" buffer : "+String:C10(BLOB size:C605($buffer))+" byte(s),"+\
				" total size : "+String:C10(BLOB size:C605($buffer)+BLOB size:C605($blob))+" byte(s),"+\
				" expected size : "+String:C10($size)+" byte(s)")
			
			// insert $buffer at begining of $blob
			INSERT IN BLOB:C559($blob; 0; BLOB size:C605($buffer); 0x00FF)
			COPY BLOB:C558($buffer; $blob; 0; 0; BLOB size:C605($buffer))
			
		Else 
			This:C1470.debug("receiveBlobSize"; 6; "received blob : "+String:C10(BLOB size:C605($blob))+" byte(s),"+\
				" expected size : "+String:C10($size)+" byte(s)")
		End if 
		
		If (BLOB size:C605($blob)>=$size)
			
			var $newBufferSize : Integer
			$newBufferSize:=BLOB size:C605($blob)-$size
			
			// $buffer is used, lets clear it.
			SET BLOB SIZE:C606($buffer; 0)
			
			If ($newBufferSize>0)
				// if there is a new buffer, lets copy this buffer bytes from $blob
				COPY BLOB:C558($blob; $buffer; $size+1; 0; $newBufferSize)
				
				// and truncate the blob to remove the bytes after the desired length
				SET BLOB SIZE:C606($blob; $size)
			End if 
			
		Else 
			$buffer:=$blob
			SET BLOB SIZE:C606($blob; 0)
		End if 
		
		If (BLOB size:C605($buffer)>0)
			This:C1470.debug("receiveBlobSize"; 8; "new buffer : "+String:C10(BLOB size:C605($buffer))+" byte(s)")
		End if 
		
		// store the buffer for next calls
		This:C1470.bufferSet($buffer)
		
	Else 
		IDLE:C311
		DELAY PROCESS:C323(Current process:C322; 1)
	End if 
	
	// sends binary data to tcp stream
Function sendBlob($blob : Blob)->$result : Object
	$result:=New object:C1471
	
	$result.success:=False:C215
	$result.errorCode:=0
	$result.error:=""
	
	If (BLOB size:C605($blob)>0)
		var $error; $connRef : Integer
		$connRef:=This:C1470.connexionRef
		$error:=TCP_SendBLOB($connRef; $blob)
		
		$result.success:=($error=0)
		$result.errorCode:=$error
		$result.error:=Choose:C955($error=0; ""; This:C1470.errorText($error)+" ("+String:C10($error)+")")
		
		Case of 
			: (($error=0) & (BLOB size:C605($blob)=0))
				This:C1470.debug("sendBlob"; 8; ">>> nothing to send")
				
			: (($error=0) & (BLOB size:C605($blob)>0))
				This:C1470.debug("sendBlob"; 8; ">>> sent "+String:C10(BLOB size:C605($blob))+" bytes")
				This:C1470.bytesSent:=This:C1470.bytesSent+BLOB size:C605($blob)
				
			Else 
				This:C1470.debug("sendBlob"; 2; "send blob ("+String:C10(BLOB size:C605($blob))+" bytes) error "+String:C10($error)+" : "+This:C1470.errorText($error)+" ("+String:C10($error)+")")
				This:C1470.errorCount:=This:C1470.errorCount+1
		End case 
		
		This:C1470.stateUpdate()
		
	Else 
		$result.success:=True:C214
		This:C1470.debug("sendBlob"; 2; ">>> nothing to send")
	End if 
	
	// some bytes were received beyond the last delimiter, keep them for later
Function bufferSet($buffer : Blob)
	Case of 
		: (Count parameters:C259=0)  //($buffer=Null)
			This:C1470.bufferBase64:=""
			
		: (BLOB size:C605($buffer)=0)
			This:C1470.bufferBase64:=""
			
		Else 
			var $base64 : Text
			BASE64 ENCODE:C895($buffer; $base64)
			This:C1470.bufferBase64:=$base64
	End case 
	
	// get the last bytes reveived after the last delimiter
Function bufferGet()->$buffer : Blob
	If (This:C1470.bufferBase64="")
		SET BLOB SIZE:C606($buffer; 0)
	Else 
		var $base64 : Text
		$base64:=This:C1470.bufferBase64
		BASE64 DECODE:C896($base64; $buffer)
	End if 
	
	// set timeout
Function timeoutSet()
	var $timeout; $error : Integer
	$error:=IT_GetTimeOut($timeout)
	If ($error=0)
		This:C1470.timeoutSecondsDefault:=$timeout
		
		$timeout:=This:C1470.timeoutSeconds
		If (($timeout>0) & ($timeout<128))
			$error:=IT_SetTimeOut($timeout)
			This:C1470.debug("timeoutSet"; 4; "previous timeout : "+String:C10(This:C1470.timeoutSecondsDefault)+"s, new timeout : "+String:C10($timeout)+"s")
		End if 
		
	End if 
	
	// reset timeout
Function timeoutReset()
	
	var $timeout; $error : Integer
	$timeout:=This:C1470.timeoutSecondsDefault
	If (($timeout>0) & ($timeout<128))
		
		$error:=IT_SetTimeOut($timeout)
		This:C1470.debug("timeoutReset"; 4; "restore previous timeout : "+String:C10($timeout)+"s")
	End if 
	
	// debug
Function debug($method : Text; $level : Integer; $message : Text)
	//DBG_module_Debug_DateTimeLine("tcp"; $level; $method; $message)
	
Function millisecondsFormatter($milliseconds : Integer)->$millisecondsStr : Text
	$millisecondsStr:=String:C10($milliseconds)+"ms"
	//$millisecondsStr:=DBG_timer_MillisecFormatter($milliseconds)
	
Function debugBlobToText($blob : Blob)->$debugText : Text
	If (This:C1470.debugBinary)
		$debugText:=String:C10(BLOB size:C605($blob))+" byte(s)"
	Else 
		$debugText:=Replace string:C233(Replace string:C233(Convert to text:C1012($blob; This:C1470.debugTextCharset); "\n"; "<LF>"; *); "\r"; "<CR>"; *)
	End if 
	