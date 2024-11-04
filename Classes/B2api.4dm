
property timeout : Integer
property maxRetry : Integer
property errors : Collection

// https://www.backblaze.com/apidocs/introduction-to-the-b2-native-api

Class constructor()
	This:C1470._authorizationObject:=Null:C1517
	This:C1470._bucket:=Null:C1517
	This:C1470.timeout:=120
	This:C1470.maxRetry:=3
	This:C1470.errors:=New collection:C1472
	
Function authorizeAccount($applicationKeyId : Text; $applicationKey : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="GET"
	$httpOptions.serverAuthentication:=New object:C1471("method"; "basic"; \
		"name"; $applicationKeyId; \
		"password"; $applicationKey)
	
	var $url : Text
	$url:="https://api.backblazeb2.com/b2api/v3/b2_authorize_account"
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$result.success:=True:C214
		This:C1470._authorizationObject:=$request.response.body
	Else 
		This:C1470._authorizationObject:=Null:C1517
	End if 
	
Function setBucket($bucketName : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_list_buckets"
	$url:=This:C1470._apiUrl($uri)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
	$httpOptions.body:=New object:C1471(\
		"accountId"; This:C1470._authorizationObject.accountId; \
		"bucketName"; $bucketName)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$result.success:=True:C214
		This:C1470._bucket:=$request.response.body.buckets[0]
	Else 
		This:C1470._bucket:=Null:C1517
	End if 
	
Function setBucketById($bucketId : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_list_buckets"
	$url:=This:C1470._apiUrl($uri)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
	$httpOptions.body:=New object:C1471(\
		"accountId"; This:C1470._authorizationObject.accountId; \
		"bucketId"; $bucketId)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$result.success:=True:C214
		This:C1470._bucket:=$request.response.body.buckets[0]
	Else 
		This:C1470._bucket:=Null:C1517
	End if 
	
Function uploadFile($file : 4D:C1709.File; $key : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	$result.duration:=0
	
	If ($file.exists)
		
		
		$key:=$key || $file.fullName
		
		var $maxSize : Integer
		$maxSize:=\
			This:C1470._authorizationObject.apiInfo.storageApi.recommendedPartSize+\
			This:C1470._authorizationObject.apiInfo.storageApi.absoluteMinimumPartSize
		
		var $ms : Integer
		$ms:=Milliseconds:C459
		
		If ($file.size>$maxSize)  // do a multipart upload
			$result:=This:C1470._multipartUploadFile($file; $key)
		Else   // upload file in one http request
			
			var $uploadUrlObject : Object
			$uploadUrlObject:=This:C1470._getUploadUrl()
			If ($uploadUrlObject#Null:C1517)
				
				var $url : Text
				$url:=$uploadUrlObject.uploadUrl
				// "https://pod-031-2024-19.backblaze.com/b2api/v3/b2_upload_file/72********************18/c003_v0312024_t0014"
				
				var $blob : Blob
				$blob:=$file.getContent()
				
				var $httpOptions : Object
				$httpOptions:=New object:C1471
				$httpOptions.method:="POST"
				$httpOptions.headers:=New object:C1471(\
					"authorization"; $uploadUrlObject.authorizationToken; \
					"content-type"; "b2/x-auto"; \
					"content-length"; BLOB size:C605($blob); \
					"X-Bz-File-Name"; This:C1470._filenameEscape($key); \
					"X-Bz-Content-Sha1"; Generate digest:C1147($blob; SHA1 digest:K66:2))
				
				$httpOptions.body:=$blob
				SET BLOB SIZE:C606($blob; 0)
				
				var $request : 4D:C1709.HTTPRequest
				$request:=This:C1470._httpRequest($url; $httpOptions)
				
				If (Bool:C1537($request.terminated) && ($request.response.status=200))
					$result.success:=True:C214
				End if 
				
			End if 
			
		End if 
		
		$result.duration:=(Milliseconds:C459-$ms)/1000
		
	End if 
	
Function listFiles($options : Object)->$result : Object
	
	$result:=New object:C1471
	$result.success:=False:C215
	$result.files:=Null:C1517
	$result.duration:=0
	
	var $error : Boolean
	$error:=False:C215
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_list_file_names"
	
	var $queryString : Object
	$queryString:=$options || New object:C1471
	$queryString.bucketId:=This:C1470._bucket.bucketId
	
	var $ms : Integer
	$ms:=Milliseconds:C459
	
	Repeat 
		$url:=This:C1470._apiUrl($uri; $queryString)
		
		var $httpOptions : Object
		$httpOptions:=New object:C1471
		$httpOptions.method:="GET"
		$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
		
		var $request : 4D:C1709.HTTPRequest
		$request:=This:C1470._httpRequest($url; $httpOptions)
		
		If (Bool:C1537($request.terminated) && ($request.response.status=200))
			
			If ($result.files=Null:C1517)
				$result.files:=$request.response.body.files
			Else 
				$result.files:=$result.files.combine($request.response.body.files)
			End if 
			
			If ($request.response.body.nextFileName=Null:C1517)
				$result.success:=True:C214
			Else 
				$queryString.startFileName:=$request.response.body.nextFileName
			End if 
			
		Else   // error
			$error:=True:C214
		End if 
		
	Until ($result.success | $error)
	
	$result.duration:=(Milliseconds:C459-$ms)/1000
	
Function _multipartUploadFile($file : 4D:C1709.File; $key : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $uploadLargeFileStartObject : Object
	$uploadLargeFileStartObject:=This:C1470._uploadLargeFileStart($file; $key)
	If ($uploadLargeFileStartObject#Null:C1517)
		
		var $recommendedPartSize; $absoluteMinimumPartSize; $nextPartSize : Integer
		$recommendedPartSize:=This:C1470._authorizationObject.apiInfo.storageApi.recommendedPartSize
		$absoluteMinimumPartSize:=This:C1470._authorizationObject.apiInfo.storageApi.absoluteMinimumPartSize
		
		var $fileHandle : 4D:C1709.FileHandle
		$fileHandle:=$file.open("read")
		
		var $finishObject : Object
		$finishObject:=New object:C1471
		$finishObject.fileId:=$uploadLargeFileStartObject.fileId
		$finishObject.partSha1Array:=New collection:C1472
		
		var $partNumber : Integer
		$partNumber:=0
		
		var $finished; $cancel : Boolean
		$finished:=False:C215
		$cancel:=False:C215
		Repeat 
			
			var $left : Real
			$left:=$fileHandle.getSize()-$fileHandle.offset
			If ($left>($recommendedPartSize+$absoluteMinimumPartSize))
				$nextPartSize:=$recommendedPartSize
			Else 
				$nextPartSize:=$left
			End if 
			
			$partNumber+=1
			
			var $blob : Blob  //4D.Blob
			$blob:=$fileHandle.readBlob($nextPartSize)
			
			var $sha1 : Text
			$sha1:=Generate digest:C1147($blob; SHA1 digest:K66:2)
			
			$finishObject.partSha1Array.push($sha1)
			
			var $uploadPartUrlObject : Object
			$uploadPartUrlObject:=This:C1470._getUploadPartUrl($uploadLargeFileStartObject.fileId)
			If ($uploadPartUrlObject#Null:C1517)
				
				var $url : Text
				$url:=$uploadPartUrlObject.uploadUrl
				// "https://pod-000-1016-09.backblaze.com/b2api/v3/b2_upload_part/4_ze73ede9c9c8412db49f60715_f200b4e93fbae6252_d20150824_m224353_c900_v8881000_t0001/0037"
				
				var $partUploadOk : Boolean
				$partUploadOk:=False:C215
				
				var $retryCount : Integer
				$retryCount:=0
				
				Repeat 
					var $httpOptions : Object
					$httpOptions:=New object:C1471
					$httpOptions.method:="POST"
					$httpOptions.dataType:="blob"
					$httpOptions.headers:=New object:C1471(\
						"authorization"; $uploadPartUrlObject.authorizationToken; \
						"content-length"; BLOB size:C605($blob); \
						"X-Bz-Part-Number"; $partNumber; \
						"X-Bz-Content-Sha1"; $sha1)
					
					$httpOptions.body:=$blob
					
					var $request : 4D:C1709.HTTPRequest
					$request:=This:C1470._httpRequest($url; $httpOptions)
					
					If (Bool:C1537($request.terminated) && ($request.response.status=200))
						$partUploadOk:=True:C214
					Else 
						$retryCount+=1
					End if 
					
					If ($retryCount>=This:C1470.maxRetry)
						$cancel:=True:C214
					End if 
					
				Until ($partUploadOk || $cancel)
				
				If ($partUploadOk && ($fileHandle.offset>=($fileHandle.getSize())))
					$finished:=True:C214
				End if 
				
			Else 
				$cancel:=True:C214
			End if 
			
		Until ($finished || $cancel)
		
		Case of 
			: ($finished)
				$result:=This:C1470._finishLargeFile($finishObject)
				
			: ($cancel)
				This:C1470._cancelLargeFile($uploadLargeFileStartObject.fileId)
		End case 
		
	End if 
	
Function _uploadLargeFileStart($file : 4D:C1709.File; $key : Text)->$uploadLargeFileStartObject : Object
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_start_large_file"
	var $queryString : Object
	$queryString:=New object:C1471("bucketId"; This:C1470._bucket.bucketId)
	$url:=This:C1470._apiUrl($uri; $queryString)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.body:=New object:C1471(\
		"bucketId"; This:C1470._bucket.bucketId; \
		"fileName"; This:C1470._filenameEscape($key); \
		"contentType"; "b2/x-auto")
	$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$uploadLargeFileStartObject:=$request.response.body
	End if 
	
Function _finishLargeFile($finishObject : Object)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_finish_large_file"
	$url:=This:C1470._apiUrl($uri)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
	$httpOptions.body:=$finishObject
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$result.success:=True:C214
	End if 
	
Function _cancelLargeFile($fileId : Text)->$result : Object
	$result:=New object:C1471
	$result.success:=False:C215
	
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_cancel_large_file"
	$url:=This:C1470._apiUrl($uri)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="POST"
	$httpOptions.headers:=New object:C1471("authorization"; This:C1470._authorizationObject.authorizationToken)
	$httpOptions.body:=New object:C1471("fileId"; $fileId)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$result.success:=True:C214
	End if 
	
Function _getUploadUrl()->$uploadUrlObject : Object
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_get_upload_url"
	var $queryString : Object
	$queryString:=New object:C1471("bucketId"; This:C1470._bucket.bucketId)
	$url:=This:C1470._apiUrl($uri; $queryString)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="GET"
	$httpOptions.headers:=New object:C1471
	$httpOptions.headers["authorization"]:=This:C1470._authorizationObject.authorizationToken
	
	$httpOptions.body:=$blob
	SET BLOB SIZE:C606($blob; 0)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$uploadUrlObject:=$request.response.body
	End if 
	
Function _getUploadPartUrl($fileId : Text)->$uploadUrlObject : Object
	var $url; $uri : Text
	$uri:="/b2api/v3/b2_get_upload_part_url"
	var $queryString : Object
	$queryString:=New object:C1471("fileId"; $fileId)
	$url:=This:C1470._apiUrl($uri; $queryString)
	
	var $httpOptions : Object
	$httpOptions:=New object:C1471
	$httpOptions.method:="GET"
	$httpOptions.headers:=New object:C1471
	$httpOptions.headers["authorization"]:=This:C1470._authorizationObject.authorizationToken
	
	$httpOptions.body:=$blob
	SET BLOB SIZE:C606($blob; 0)
	
	var $request : 4D:C1709.HTTPRequest
	$request:=This:C1470._httpRequest($url; $httpOptions)
	
	If (Bool:C1537($request.terminated) && ($request.response.status=200))
		$uploadUrlObject:=$request.response.body
	End if 
	
Function _apiUrl($uri : Text; $queryString : Object)->$url : Text
	If (String:C10(This:C1470._authorizationObject.apiInfo.storageApi.apiUrl)#"")
		$url:=This:C1470._authorizationObject.apiInfo.storageApi.apiUrl+$uri
		If ($queryString#Null:C1517)
			var $index : Integer
			$index:=0
			var $paramKey : Text
			
			var $urlEncoder : cs:C1710.urlEncoder
			$urlEncoder:=cs:C1710.urlEncoder.new()
			$urlEncoder.encodeSlash:=True:C214  //encode "/" to "%2F"
			$urlEncoder.rawUrlEncoding:=True:C214  // SP => "%20"
			
			For each ($paramKey; $queryString)
				$index+=1
				$url+=(($index=1) ? "?" : "&")+$urlEncoder.encode($paramKey)+"="+$urlEncoder.encode($queryString[$paramKey])
			End for each 
		End if 
	End if 
	
Function _httpRequest($url : Text; $httpOptions : Object)->$request : 4D:C1709.HTTPRequest
	
	If ($url#"")
		Try
			var $ms : Integer
			$ms:=Milliseconds:C459
			
			$request:=4D:C1709.HTTPRequest.new($url; $httpOptions)
			$request.wait(This:C1470.timeout)
			
			$ms:=Milliseconds:C459-$ms
			
			Case of 
				: (Not:C34(Bool:C1537($request.terminated)))  // timeout
					throw:C1805(-200; "timeout - duration "+String:C10($ms/1000)+"s, timeout "+String:C10(This:C1470.timeout)+"s, url : "+$url)
					
				: ($request.errors.length>0)  // other errors
					This:C1470.errors:=This:C1470.errors.combine($request.errors)
					
				: ($request.terminated && ($request.response.status=200))  // sucess
					
				Else   // unexpected status
					throw:C1805($request.response.status; "error")
			End case 
			
		Catch
			This:C1470.errors:=This:C1470.errors.combine(Last errors:C1799)
		End try
	End if 
	
Function _filenameEscape($filename : Text)->$filenameEscaped : Text
	
	// https://www.backblaze.com/docs/cloud-storage-files
	
	$filenameEscaped:=""
	var $i; $charCode : Integer
	var $char : Text
	
	// first loop to remove filtered characters
	For ($i; Length:C16($filename); 1; -1)
		$charCode:=Character code:C91($filename[[$i]])
		If (($charCode<32) || ($charCode=92) || ($charCode=127))
			$filename:=Delete string:C232($filename; $i; 1)
		End if 
	End for 
	
	var $regex : Text
	var $start : Integer
	
	ARRAY LONGINT:C221($tl_pos; 0)
	ARRAY LONGINT:C221($tl_length; 0)
	
	// remove leading "/"
	$regex:="^(/+)"
	$start:=1
	If (Match regex:C1019($regex; $filename; $start; $tl_pos; $tl_length))
		$filename:=Delete string:C232($filename; $tl_pos{1}; $tl_length{1})
	End if 
	
	// remove trailing "/"
	$regex:="(/+)$"
	$start:=1
	If (Match regex:C1019($regex; $filename; $start; $tl_pos; $tl_length))
		$filename:=Delete string:C232($filename; $tl_pos{1}; $tl_length{1})
	End if 
	
	// remove double "/"
	$regex:="/(/+)"
	$start:=1
	While (Match regex:C1019($regex; $filename; $start; $tl_pos; $tl_length))
		$filename:=Delete string:C232($filename; $tl_pos{1}; $tl_length{1})
		$start:=$tl_pos{1}
	End while 
	
	ARRAY LONGINT:C221($tl_pos; 0)
	ARRAY LONGINT:C221($tl_length; 0)
	
	var $urlEncoder : cs:C1710.urlEncoder
	$urlEncoder:=cs:C1710.urlEncoder.new()
	$urlEncoder.encodeSlash:=False:C215  // don't encode "/" to "%2F"
	$urlEncoder.rawUrlEncoding:=True:C214  // SP => "%20"
	
	$filenameEscaped:=$urlEncoder.encode($filename)
	
	// "test/Photo Remote Desktop, 2 octobre 2024 à 12.28.28 UTC+2-rotated.png"
	// "test/Photo%20Remote%20Desktop%2C%202%20octobre%202024%20%C3%A0%2012.28.28%20UTC%2B2-rotated.png"
	
	
	
	