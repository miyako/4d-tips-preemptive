C_OBJECT:C1216($object)

ARRAY LONGINT:C221(ar_StatSlices; 0; 0)
ARRAY LONGINT:C221(ar_StatFibos; 0)
ARRAY LONGINT:C221(ar_MilliStart; 0)
ARRAY LONGINT:C221(ar_MilliEnd; 0)
ARRAY LONGINT:C221(ar_MilliStart; vMaxProcess)
ARRAY LONGINT:C221(ar_MilliEnd; vMaxProcess)

OBJECT SET VISIBLE:C603(*; "_PROCESSLIST_"; Macintosh option down:C545)

$count:=0
For ($i; 1; Size of array:C274(ar_ProcessNb))
	$count:=$count+Num:C11(ar_ProcessNb{$i}#0)
	ar_ProcessValue{$i}:=0
	OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_F_"+String:C10($i))->:=0
End for 

$nbRecords:=Records in table:C83([Cities:1])
If ($count=0)
	$sliceSize:=$nbRecords
Else 
	$sliceSize:=$nbRecords\$count
End if 

OBJECT SET VISIBLE:C603(*; "_TIMER_"; True:C214)

$sliceNb:=0
For ($i; 1; Size of array:C274(ar_ProcessNb))
	If (ar_ProcessNb{$i}>0)
		$sliceNb:=$sliceNb+1
		$first:=(($sliceNb-1)*$sliceSize)+1
		$last:=$first+$sliceSize
		If ($last>$nbRecords)
			$last:=$nbRecords
		End if 
		
		OB SET:C1220($object; "MAXPROCESS"; vMaxProcess)
		OB SET:C1220($object; "THERMOID"; $i)
		OB SET:C1220($object; "TOTNB"; $nbRecords)
		OB SET:C1220($object; "REC_FROM"; $first)
		OB SET:C1220($object; "REC_TO"; $last)
		OB SET:C1220($object; "NBSLICES"; $count)
		OB SET:C1220($object; "REFRESH"; th_RDelay)
		OB SET:C1220($object; "ITERATIONS"; vIterations)
		OB SET:C1220($object; "OPKIND"; vOpKind)
		OB SET:C1220($object; "CHUNK"; (ck_Chunk=1))
		If (OBJECT Get pointer:C1124(Object named:K67:5; "_MODE_PREEMP_")->=1)
			OB SET:C1220($object; "MULTIMODE"; True:C214)
			CALL WORKER:C1389("Worker_"+String:C10($i); "CW_StartDemo_Preemptive"; Current process:C322; Current form window:C827; "START"; $object)
		Else 
			OB SET:C1220($object; "MULTIMODE"; False:C215)
			CALL WORKER:C1389("Worker_"+String:C10($i); "CW_StartDemo_Cooperative"; Current process:C322; Current form window:C827; "START"; $object)
		End if 
	End if 
End for 
