
// property timestamp : text

// This class handles Universal Time (GMT/Zulu) timestamp

//var $timestamp : cs.timestamp
//$timestamp:=cs.timestamp.new("2024-02-08T06:23:33.619Z")
//$timestamp.getRfc1123() => "Thu, 08 Feb 2024 06:23:33 GMT"
//$timestamp.getIso8601() => "20240208T062333Z"

property timestamp : Text

Class constructor($timestampParam : Text; $utc : Boolean)
	
	This:C1470.utc:=$utc
	
	// "2024-02-08T06:23:33.619Z"
	var $timestamp : Text
	Case of 
		: (Count parameters:C259=0)
			// TODO
			$timestamp:=Timestamp:C1445
			
		: (This:C1470._isValid($timestampParam))
			$timestamp:=$timestampParam
			
		Else 
			//TODO
			$timestamp:=Timestamp:C1445
	End case 
	
	This:C1470.timestamp:=$timestamp
	
Function _isValid($timestampStr : Text)->$isValid : Boolean
	var $regex : Text
	$regex:="^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}"+(This:C1470.utc ? "Z" : "")+"$"
	If (Length:C16($timestampStr)=(This:C1470.utc ? 24 : 23))
		$isValid:=Match regex:C1019($regex; $timestampStr; 1)
	Else 
		$isValid:=False:C215
	End if 
	
Function getIso8601()->$rfc8601 : Text
	// https://www.rfc-editor.org/rfc/rfc8601
	
	// "2024-02-08T06:23:33.619Z" => "20240208T062333Z"
	
	$rfc8601:=Substring:C12(This:C1470.timestamp; 1; 4)+Substring:C12(This:C1470.timestamp; 6; 2)+Substring:C12(This:C1470.timestamp; 9; 5)+Substring:C12(This:C1470.timestamp; 15; 2)+Substring:C12(This:C1470.timestamp; 18; 2)+(This:C1470.utc ? "Z" : "")
	
Function get date()->$date : Date
	$date:=Add to date:C393(!00-00-00!; This:C1470.year; This:C1470.month; This:C1470.day)
	
Function get time()->$time : Time
	var $timestring : Text
	$timestring:=Substring:C12(This:C1470.timestamp; 12; 8)
	$time:=Time:C179($timestring)
	
Function set date($date : Date)
	If ($date#!00-00-00!)
		If (($date>=!1970-01-01!) & ($date<!2038-01-01!))
			// 19 janvier 2038 à 03:14:07 UTC
			This:C1470.year:=Year of:C25($date)
			This:C1470.month:=Month of:C24($date)
			This:C1470.day:=Day of:C23($date)
		End if 
	End if 
	
Function set time($time : Time)
	If (($time>=?00:00:00?) & ($time<=?23:59:59?))
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; Time string:C180($time); 12)
	End if 
	
Function get year()->$year : Integer
	// This function returns the 
	$year:=Num:C11(Substring:C12(This:C1470.timestamp; 1; 4))
	
Function get month()->$month : Integer
	$month:=Num:C11(Substring:C12(This:C1470.timestamp; 6; 2))
	
Function get day()->$day : Integer
	$day:=Num:C11(Substring:C12(This:C1470.timestamp; 9; 2))
	
Function get hour()->$hour : Integer
	$hour:=Num:C11(Substring:C12(This:C1470.timestamp; 12; 2))
	
Function get minute()->$minute : Integer
	$minute:=Num:C11(Substring:C12(This:C1470.timestamp; 15; 2))
	
Function get second()->$second : Integer
	$second:=Num:C11(Substring:C12(This:C1470.timestamp; 18; 2))
	
Function get millisecond()->$millisecond : Integer
	$millisecond:=Num:C11(Substring:C12(This:C1470.timestamp; 21; 3))
	
Function set year($year : Integer)
	If ($year>=1970) & ($year<2038)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($year; "0000"); 1)
	End if 
	
Function set month($month : Integer)
	If ($month>=1) & ($month<=12)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($month; "00"); 6)
	End if 
	
Function set day($day : Integer)
	If ($day>=1) & ($day<=31)
		// test if the day is comptatible with the year/month (2024-02-31 is not valid
		var $testDate : Date
		$testDate:=Add to date:C393(!00-00-00!; This:C1470.year; This:C1470.month; $day)
		If ((Year of:C25($testDate)=This:C1470.year) & (Month of:C24($testDate)=This:C1470.month) & (Day of:C23($testDate)=$day))
			This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($day; "00"); 9)
		End if 
	End if 
	
Function set hour($hour : Integer)
	If ($hour>=0) & ($hour<24)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($hour; "00"); 12)
	End if 
	
Function set minute($minute : Integer)
	If ($minute>=0) & ($minute<60)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($minute; "00"); 15)
	End if 
	
Function set second($second : Integer)
	If ($second>=0) & ($second<60)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($second; "00"); 18)
	End if 
	
Function set millisecond($millisecond : Integer)
	If ($millisecond>=0) & ($millisecond<=999)
		This:C1470.timestamp:=Change string:C234(This:C1470.timestamp; String:C10($millisecond; "000"); 21)
	End if 
	
Function toObject()->$object : Object
	$object:=New object:C1471
	$object.year:=This:C1470.year
	$object.month:=This:C1470.month
	$object.day:=This:C1470.day
	$object.hour:=This:C1470.hour
	$object.minute:=This:C1470.minute
	$object.second:=This:C1470.second
	$object.millisecond:=This:C1470.millisecond
	$object.utc:=This:C1470.utc
	
Function fromObject($object : Object)
	
	If (($object.year>=1970) & ($object.year<2038) & \
		($object.month>=1) & ($object.month<=12) & \
		($object.day>=1) & ($object.day<=31) & \
		($object.hour>=0) & ($object.hour<24) & \
		($object.minute>=0) & ($object.minute<60) & \
		($object.second>=0) & ($object.second<60) & \
		($object.millisecond>=0) & ($object.millisecond<=999))
		
		var $testDate : Date
		$testDate:=Add to date:C393(!00-00-00!; $object.year; $object.month; $object.day)
		If ((Year of:C25($testDate)=$object.year) & (Month of:C24($testDate)=$object.month) & (Day of:C23($testDate)=$object.day))
			// "2024-02-08T06:23:33.619Z"
			This:C1470.timestamp:=String:C10($object.year; "0000")+"-"+String:C10($object.month; "00")+"-"+String:C10($object.day; "00")+"T"+\
				String:C10($object.hour; "00")+":"+String:C10($object.minute; "00")+":"+String:C10($object.second; "00")+"."+String:C10($object.millisecond; "000")+"Z"
			
			This:C1470.utc:=$object.utc
		End if 
		
	End if 
	
Function getDateYYYYMMDD()->$dateYYYYMMDD : Text
	
	// "2024-02-08T06:23:33.619Z" => "20240208"
	
	$dateYYYYMMDD:=Substring:C12(This:C1470.timestamp; 1; 4)+Substring:C12(This:C1470.timestamp; 6; 2)+Substring:C12(This:C1470.timestamp; 9; 2)
	
Function toEpoch()->$epoch : Integer
	// returns the number of seconds since 1970-01-01 UTC
	var $year; $month; $day : Text
	$year:=Substring:C12(This:C1470.timestamp; 1; 4)
	$month:=Substring:C12(This:C1470.timestamp; 6; 2)
	$day:=Substring:C12(This:C1470.timestamp; 9; 2)
	
	var $date : Date
	$date:=Add to date:C393(!00-00-00!; Num:C11($year); Num:C11($month); Num:C11($day))
	
	var $timeStr : Text
	$timeStr:=Substring:C12(This:C1470.timestamp; 12; 8)
	
	var $time : Time
	$time:=Time:C179($timeStr)
	
	$epoch:=($date-!1970-01-01!*86400)+$time
	
Function fromEpoch($epoch : Integer)
	// creates a timestamp since 1970-01-01 UTC
	
	var $date : Date
	$date:=(!1970-01-01!+($epoch\86400))
	
	var $time : Time
	$time:=($epoch%86400)
	
	This:C1470.timestamp:=String:C10(Year of:C25($date); "0000")+"-"+String:C10(Month of:C24($date); "00")+"-"+String:C10(Day of:C23($date); "00")+"T"+Time string:C180($time)+".000Z"
	
	
Function addSeconds($seconds : Integer)
	
	var $epoch : Integer
	$epoch:=This:C1470.toEpoch()+$seconds
	
	var $date : Date
	$date:=(!1970-01-01!+($epoch\86400))
	
	var $time : Time
	$time:=($epoch%86400)
	
	This:C1470.timestamp:=String:C10(Year of:C25($date); "0000")+"-"+String:C10(Month of:C24($date); "00")+"-"+String:C10(Day of:C23($date); "00")+"T"+Time string:C180($time)+"."+Substring:C12(This:C1470.timestamp; 21)
	
Function durationSecondsToObject($duration : Integer)->$object : Object
	$object:=New object:C1471
	
	$object.days:=$duration\86400
	$duration:=$duration%86400
	
	$object.hours:=$duration\3600
	$duration:=$duration%3600
	
	$object.minutes:=$duration\60
	
	$object.seconds:=$duration%60
	
Function durationSecondsToString($duration : Integer)->$durationStr : Text
	
	var $durationObject : Object
	$durationObject:=This:C1470.durationSecondsToObject($duration)
	Case of 
		: ($durationObject.days>0)
			$durationStr:=String:C10($durationObject.days)+"d "+String:C10($durationObject.hours)+"h"
			
		: ($durationObject.hours>0)
			$durationStr:=String:C10($durationObject.hours)+"h "+String:C10($durationObject.minutes)+"m"
			
		: ($durationObject.minutes>0)
			$durationStr:=String:C10($durationObject.minutes)+"m "+String:C10($durationObject.seconds)+"s"
			
		Else 
			$durationStr:=String:C10($durationObject.seconds)+"s"
	End case 
	
Function diff($timestamp : cs:C1710.timestamp)->$diff : Integer
	$diff:=$timestamp.toEpoch()-This:C1470.toEpoch()
	