// Class netPing
// This class will use "ping" utilities on Mac and Windows
// and parse results
// The function will return success if packets send = packets received
//
// Bruno LEGAY - 2025-11-05

/*
If (cs.netPing.new("www.apple.com").execute().success)
  ALERT("ok")
End if 

var $ping : cs.netPing
$ping:=cs.netPing.new("www.apple.com")

$ping.count:=5

var $pingResult : Object
$pingResult:=$ping.execute()
If ($pingResult.success)
  ALERT(JSON Stringify($pingResult))
End if 
*/

property host : Text
property count : Integer
property timeoutSeconds : Integer


Class constructor($host : Text)
	This:C1470.host:=$host
	This:C1470.count:=1
	This:C1470.timeoutSeconds:=5
	
	
Function execute()->$result : Object
	$result:={\
		success: False:C215; \
		packetsTransmitted: 0; \
		packetsReceived: 0; \
		packetLossPct: 0; \
		min: 0; \
		avg: 0; \
		max: 0; \
		duration: 0; \
		host: This:C1470.host; \
		count: This:C1470.count; \
		timeout: This:C1470.timeoutSeconds; \
		response: ""; \
		terminated: False:C215; \
		exitCode: 0}
	
	var $cmd : Text
	$cmd:=This:C1470._getCommand()
	
	var $sw : 4D:C1709.SystemWorker
	var $options : Object
	$options:={encoding: (Is macOS:C1572 ? "utf-8" : "us-ascii")}
	//I think ping on windows returns text in "cp850" (not available in 4D), 
	//"us-ascii" is close enough to get regex working
	
	$ms:=Milliseconds:C459
	
	$sw:=4D:C1709.SystemWorker.new($cmd; $options)  //; $netPingWorker)
	$sw.wait(This:C1470.count*This:C1470.timeoutSeconds)
	
	$result.duration:=(Milliseconds:C459-$ms)/1000
	$result.terminated:=$sw.terminated
	$result.exitCode:=$sw.exitCode
	
	If ($sw.terminated && ($sw.exitCode=0))
		var $responseText : Text
		
		$responseText:=$sw.response
		If (Is macOS:C1572)
			This:C1470._parseResponseMacOS($responseText; $result)
		Else 
			This:C1470._parseResponseWindows($responseText; $result)
		End if 
		
		$result.response:=$responseText
		$result.success:=($result.packetsTransmitted>0) && ($result.packetsTransmitted=$result.packetsReceived)
		
	End if 
	
	
Function _getCommand()->$cmd : Text
	
	If (Is macOS:C1572)
		$cmd:="/sbin/ping "+This:C1470.host+" -c "+String:C10(This:C1470.count)+" -t "+String:C10(This:C1470.timeoutSeconds)
	Else 
		$cmd:="ping "+This:C1470.host+" -n "+String:C10(This:C1470.count)+" -w "+String:C10(This:C1470.timeoutSeconds*1000)
	End if 
	
	
Function _parseResponseMacOS($response : Text; $result : Object)
	
	If ($response#"")
		
		var $regex : Text
		$regex:="\\n(\\d+) packets transmitted, (\\d+) packets received, (\\d+\\.\\d)% packet loss\\n"
		
		ARRAY LONGINT:C221($tl_pos; 0)
		ARRAY LONGINT:C221($tl_len; 0)
		
		If (Match regex:C1019($regex; $response; 1; $tl_pos; $tl_len))
			
			$result.packetsTransmitted:=Num:C11(Substring:C12($response; $tl_pos{1}; $tl_len{1}))
			$result.packetsReceived:=Num:C11(Substring:C12($response; $tl_pos{2}; $tl_len{2}))
			$result.packetLossPct:=Num:C11(Substring:C12($response; $tl_pos{3}; $tl_len{3}); ".")
			
		End if 
		
		// round-trip min/avg/max/stddev = 7.074/7.074/7.074/nan ms
		
		$regex:="\\nround-trip min/avg/max/stddev = (\\d+\\.\\d+)/(\\d+\\.\\d+)/(\\d+\\.\\d+)/(.*) ms\\n"
		
		If (Match regex:C1019($regex; $response; 1; $tl_pos; $tl_len))
			
			$result.min:=Num:C11(Substring:C12($response; $tl_pos{1}; $tl_len{1}); ".")
			$result.avg:=Num:C11(Substring:C12($response; $tl_pos{2}; $tl_len{2}); ".")
			$result.max:=Num:C11(Substring:C12($response; $tl_pos{3}; $tl_len{3}); ".")
			
		End if 
		
		ARRAY LONGINT:C221($tl_pos; 0)
		ARRAY LONGINT:C221($tl_len; 0)
		
/*
$ ping www.apple.com -c 10
PING e6858.dsce9.akamaiedge.net (2.20.169.45): 56 data bytes
64 bytes from 2.20.169.45: icmp_seq=0 ttl=58 time=11.322 ms
64 bytes from 2.20.169.45: icmp_seq=1 ttl=58 time=12.783 ms
64 bytes from 2.20.169.45: icmp_seq=2 ttl=58 time=11.633 ms
64 bytes from 2.20.169.45: icmp_seq=3 ttl=58 time=12.504 ms
64 bytes from 2.20.169.45: icmp_seq=4 ttl=58 time=19.787 ms
64 bytes from 2.20.169.45: icmp_seq=5 ttl=58 time=13.206 ms
64 bytes from 2.20.169.45: icmp_seq=6 ttl=58 time=11.897 ms
64 bytes from 2.20.169.45: icmp_seq=7 ttl=58 time=16.887 ms
64 bytes from 2.20.169.45: icmp_seq=8 ttl=58 time=12.275 ms
64 bytes from 2.20.169.45: icmp_seq=9 ttl=58 time=14.222 ms
		
--- e6858.dsce9.akamaiedge.net ping statistics ---
10 packets transmitted, 10 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 11.322/13.652/19.787/2.553 ms
*/
		
	End if 
	
	
Function _parseResponseWindows($response : Text; $result : Object)
	
	If ($response#"")
		
		var $lines : Collection
		$lines:=Split string:C1554($response; "\r\n"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
		
		var $regex; $regexPackets; $regexStats; $regexType : Text
		$regexPackets:=".* = (\\d+), .* = (\\d+), .* = (\\d+) \\(.* (\\d+)%\\),"
		$regexStats:=".* = (\\d+).*, .* = (\\d+).*, .* = (\\d+).*"
		
		$regex:=$regexStats
		$regexType:="stats"
		
		var $done : Boolean
		$done:=False:C215
		
		var $line : Text
		For each ($line; $lines.reverse()) Until ($done)
			
			ARRAY LONGINT:C221($tl_pos; 0)
			ARRAY LONGINT:C221($tl_len; 0)
			If (Match regex:C1019($regex; $line; 1; $tl_pos; $tl_len))
				
				Case of 
					: ($regexType="stats")
						
						$result.min:=Num:C11(Substring:C12($line; $tl_pos{1}; $tl_len{1}))
						$result.max:=Num:C11(Substring:C12($line; $tl_pos{2}; $tl_len{2}))
						$result.avg:=Num:C11(Substring:C12($line; $tl_pos{3}; $tl_len{3}))
						
						$regex:=$regexPackets
						$regexType:="packets"
						
					: ($regexType="packets")
						
						$result.packetsTransmitted:=Num:C11(Substring:C12($line; $tl_pos{1}; $tl_len{1}))
						$result.packetsReceived:=Num:C11(Substring:C12($line; $tl_pos{2}; $tl_len{2}))
						//$result.lost:=Num(Substring($line; $tl_pos{3}; $tl_len{3}))
						$result.packetLossPct:=Num:C11(Substring:C12($line; $tl_pos{4}; $tl_len{4}); ".")
						
						$done:=True:C214
						
				End case 
				
			End if 
			ARRAY LONGINT:C221($tl_pos; 0)
			ARRAY LONGINT:C221($tl_len; 0)
		End for each 
		
/*
Reply from 17.253.144.10: bytes=32 time=8ms TTL=54
Packets: Sent = 1, Received = 1, Lost = 0 (0% loss),
		
Envoi d’une requête 'ping' sur e6858.dsce9.akamaiedge.net [2.20.169.45] avec 32 octets de données :
Réponse de 2.20.169.45 : octets=32 temps=8 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
Réponse de 2.20.169.45 : octets=32 temps=7 ms TTL=58
		
Statistiques Ping pour 2.20.169.45:
    Paquets : envoyés = 10, reçus = 10, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 7ms, Maximum = 8ms, Moyenne = 7ms
*/
		
	End if 
	