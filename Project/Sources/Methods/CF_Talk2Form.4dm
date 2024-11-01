//%attributes = {}
C_OBJECT:C1216($object)
C_BOOLEAN:C305($multiMode)
C_LONGINT:C283($thermoID; $frequency; $thermoValue; $totNb; $timer; $vIterations)
C_REAL:C285($total)

$object:=$1

$what2do:=OB Get:C1224($object; "WHAT2DO")
$multiMode:=OB Get:C1224($object; "MULTIMODE")
$thermoID:=OB Get:C1224($object; "THERMOID")

Case of 
	: ($what2do="IDENT_PROCESS")
		ar_ProcessNb{$thermoID}:=OB Get:C1224($object; "CURPROCESS")
		$mode:=OB Get:C1224($object; "WORKERMODE")
		Case of 
			: ($mode="COOP")
				ar_ProcessMode{$thermoID}:=1
			: ($mode="PREEMP")
				ar_ProcessMode{$thermoID}:=2
			Else 
				ar_ProcessMode{$thermoID}:=0
		End case 
		
	: ($what2do="DISPLAY")
		$vOpKind:=OB Get:C1224($object; "OPKIND")
		$frequency:=OB Get:C1224($object; "FREQUENCY")
		$maxThermo:=th_MaxFreq*1000
		$thermoValue:=($frequency/$maxThermo)*100
		If ($thermoValue>0)
			OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_F_"+String:C10($thermoID))->:=$thermoValue
		End if 
		$count:=OB Get:C1224($object; "COUNT")
		$totNb:=OB Get:C1224($object; "TOTNB")
		ar_ProcessValue{$thermoID}:=$count
		$total:=Sum:C1(ar_ProcessValue)
		$percent:=($total*100)/$totNb
		OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_00")->:=$percent
		$timer:=OBJECT Get pointer:C1124(Object named:K67:5; "_TIMER_")->
		OBJECT Get pointer:C1124(Object named:K67:5; "_TIMER_")->:=$timer+1
		If (Position:C15("GRAPH"; $vOpKind)>0)
			OB SET:C1220($object; "WHAT2DO"; "GRAPHIT")
			CALL FORM:C1391(Current form window:C827; "CF_Talk2Form"; $object)
		End if 
		
	: ($what2do="GRAPHIT")
		ARRAY LONGINT:C221($ar_StatSlices; 0)
		$totNb:=OB Get:C1224($object; "TOTNB")
		OB GET ARRAY:C1229($object; "STATS"; $ar_StatSlices)
		$n:=Size of array:C274($ar_StatSlices)
		ARRAY LONGINT:C221(ar_StatSlices; $n; 16)
		For ($i; 1; $n)
			ar_StatSlices{$i}{$thermoID}:=$ar_StatSlices{$i}
		End for 
		//OB SET($object;"WHAT2DO";"ARRAY2SVG")
		//CALL FORM(Current form window;"CF_Talk2Form";$object)
		
	: ($what2do="ARRAY2SVG")
		
		OB SET:C1220($object; "WHAT2DO"; "ENDJOB")
		CALL FORM:C1391(Current form window:C827; "CF_Talk2Form"; $object)
		
	: ($what2do="ENDJOB")
		ar_MilliStart{$thermoID}:=OB Get:C1224($object; "MILLISTART")
		ar_MilliEnd{$thermoID}:=OB Get:C1224($object; "MILLIEND")
		
	: ($what2do="AGONY")
		ar_ProcessNb{$thermoID}:=0
		
	: ($what2do="CLOSE")
		CANCEL:C270
		
End case 
//CALL PROCESS(Current process)
SET TIMER:C645(5)