//%attributes = {}
C_POINTER:C301($ptr)
C_OBJECT:C1216($object)

$self:=$1
$selfName:=$2

$thermoID:=Num:C11(Replace string:C233($selfName; "_ACTIVE_"; ""))

$value:=$self->

If ($value=1)
	$message:="IDENT"
Else 
	$message:="BANG"
End if 

$flPropagate:=Macintosh option down:C545

If ($flPropagate)
	$first:=2
	$last:=vMaxProcess
Else 
	$first:=$thermoID
	$last:=$thermoID
End if 
$orgThermoID:=$thermoID
$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_MODE_PREEMP_")
$flPreemptive:=($ptr->=1)

For ($thermoID; $first; $last)
	$flOK:=True:C214
	If ($flPropagate)
		$value:=Num:C11($thermoID<=$orgThermoID)
		If ($value=1)
			$message:="IDENT"
		Else 
			$message:="BANG"
		End if 
	End if 
	$checkBoxPtr:=OBJECT Get pointer:C1124(Object named:K67:5; "_ACTIVE_"+String:C10($thermoID))
	$flStatusChanged:=($checkBoxPtr->#$value)
	
	If ($flOK & (($orgThermoID=$thermoID) | $flStatusChanged))
		$checkBoxPtr->:=$value
		OB SET:C1220($object; "MAXPROCESS"; vMaxProcess)
		OB SET:C1220($object; "THERMOID"; $thermoID)
		OB SET:C1220($object; "REFRESH"; th_RDelay)
		OB SET:C1220($object; "ITERATIONS"; vIterations)
		If ($flPreemptive)
			OB SET:C1220($object; "MULTIMODE"; True:C214)
			CALL WORKER:C1389("Worker_"+String:C10($thermoID); "CW_StartDemo_Preemptive"; Current process:C322; Current form window:C827; $message; $object)
		Else 
			OB SET:C1220($object; "MULTIMODE"; False:C215)
			CALL WORKER:C1389("Worker_"+String:C10($thermoID); "CW_StartDemo_Cooperative"; Current process:C322; Current form window:C827; $message; $object)
		End if 
	End if 
End for 