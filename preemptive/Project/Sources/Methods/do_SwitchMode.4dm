//%attributes = {}
//Switches between cooperative and preemptive
C_OBJECT:C1216($object)

$self:=$1
$selfName:=$2

$fl_Preemptive:=($selfName="_MODE_PREEMP_")

OB SET:C1220($object; "MAXPROCESS"; vMaxProcess)
OB SET:C1220($object; "MULTIMODE"; $fl_Preemptive)
OB SET:C1220($object; "REFRESH"; th_RDelay)
OB SET:C1220($object; "ITERATIONS"; vIterations)
For ($i; 1; Size of array:C274(ar_ProcessNb))
	If (ar_ProcessNb{$i}#0)
		CALL WORKER:C1389("Worker_"+String:C10($i); "do_KillWorker")
	End if 
End for 

Repeat 
	$rest:=0
	For ($i; 1; Size of array:C274(ar_ProcessNb))
		If (ar_ProcessNb{$i}#0)
			$rest:=$rest+Num:C11(Process state:C330(ar_ProcessNb{$i})>=0)
		End if 
	End for 
Until ($rest<1)

For ($i; 1; Size of array:C274(ar_ProcessNb))
	If (ar_ProcessNb{$i}#0)
		OB SET:C1220($object; "THERMOID"; $i)
		If ($fl_Preemptive)
			CALL WORKER:C1389("Worker_"+String:C10($i); "CW_StartDemo_Preemptive"; Current process:C322; Current form window:C827; "IDENT"; $object)
		Else 
			CALL WORKER:C1389("Worker_"+String:C10($i); "CW_StartDemo_Cooperative"; Current process:C322; Current form window:C827; "IDENT"; $object)
		End if 
	End if 
End for 

