C_POINTER:C301($ptr)
C_OBJECT:C1216($object)
C_LONGINT:C283(th_MaxFreq)

Case of 
	: (Form event code:C388=On Load:K2:1)
		vMaxProcess:=16
		th_MaxFreq:=100
		th_RDelay:=30
		vDuration:=0
		ck_Chunk:=1
		
		ARRAY TEXT:C222(pu_LoopMode; 4)
		pu_LoopMode{1}:="Calculations"
		pu_LoopMode{2}:="DB Access"
		pu_LoopMode{3}:="Both (DB & Calc)"
		pu_LoopMode{4}:="Statistics"
		
		pu_LoopMode:=1
		vOpKind:="CALC"  //CALC or DB or both
		vIterations:=1
		
		For ($i; 1; vMaxProcess)
			$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_F_"+String:C10($i))
			$ptr->:=0
			$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_ACTIVE_"+String:C10($i))
			$ptr->:=0
			OBJECT SET TITLE:C194(*; "_PRNB_"+String:C10($i); "")
		End for 
		
		$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_ACTIVE_1")
		$ptr->:=1
		$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_00")
		$ptr->:=0
		
		OBJECT SET VISIBLE:C603(*; "_GRAPH_STATS_"; False:C215)
		
		OBJECT SET VISIBLE:C603(*; "_COMPILED_"; Is compiled mode:C492)
		OBJECT SET VISIBLE:C603(*; "_NOTCOMPILED_"; Not:C34(Is compiled mode:C492))
		//OBJECT SET ENABLED(*;"_MODE_@";Is compiled mode)
		OBJECT Get pointer:C1124(Object named:K67:5; "_MODE_PREEMP_")->:=0
		OBJECT Get pointer:C1124(Object named:K67:5; "_MODE_COOP_")->:=1
		OBJECT SET VISIBLE:C603(*; "_MULTI_@"; False:C215)
		OBJECT SET VISIBLE:C603(*; "_MONO_@"; False:C215)
		ARRAY INTEGER:C220(ar_ProcessNb; vMaxProcess)
		ARRAY INTEGER:C220(ar_ProcessMode; vMaxProcess)
		OB SET:C1220($object; "MAXPROCESS"; vMaxProcess)
		OB SET:C1220($object; "THERMOID"; 1)
		OB SET:C1220($object; "MULTIMODE"; False:C215)
		OB SET:C1220($object; "REFRESH"; th_RDelay)
		OB SET:C1220($object; "ITERATIONS"; vIterations)
		OB SET:C1220($object; "OPKIND"; vOpKind)
		OB SET:C1220($object; "CHUNK"; (ck_Chunk=1))
		CALL WORKER:C1389("Worker_1"; "DEMO_Statistics"; Current process:C322; Current form window:C827; "IDENT"; $object)
		
		ARRAY REAL:C219(ar_ProcessValue; vMaxProcess)
		ARRAY LONGINT:C221(ar_MilliStart; 0)
		ARRAY LONGINT:C221(ar_MilliEnd; 0)
		ARRAY LONGINT:C221(ar_StatSlices; 0; 0)
		ARRAY LONGINT:C221(ar_StatFibos; 0)
		
	: (Form event code:C388=On Unload:K2:2)
		OB SET:C1220($object; "MULTIMODE"; False:C215)
		OB SET:C1220($object; "ITERATIONS"; vIterations)
		For ($i; 0; Size of array:C274(ar_ProcessNb))
			OB SET:C1220($object; "THERMOID"; $i)
			CALL WORKER:C1389(ar_ProcessNb{$i}; "DEMO_Statistics"; Current process:C322; Current form window:C827; "BANG"; $object)
		End for 
		ARRAY INTEGER:C220(ar_ProcessNb; 0)
		ARRAY INTEGER:C220(ar_ProcessMode; 0)
		
	: ((Form event code:C388=On Outside Call:K2:11) | (Form event code:C388=On Timer:K2:25))
		SET TIMER:C645(0)
		$fl_Preemptive:=((OBJECT Get pointer:C1124(Object named:K67:5; "_MODE_PREEMP_")->)=1)
		
		For ($i; 1; Size of array:C274(ar_ProcessNb))
			$ptr:=OBJECT Get pointer:C1124(Object named:K67:5; "_ACTIVE_"+String:C10($i))
			If (($ptr->)=0)
				OBJECT SET TITLE:C194(*; "_PRNB_"+String:C10($i); "")
				OBJECT SET VISIBLE:C603(*; "_MULTI_"+String:C10($i); False:C215)
				OBJECT SET VISIBLE:C603(*; "_MONO_"+String:C10($i); False:C215)
			Else 
				$state:=Process state:C330(ar_ProcessNb{$i})
				$active:=($state>=0) & ($state#2)
				Case of 
					: (ar_ProcessMode{$i}=1)
						$fl_PreemptiveState:=False:C215
					: (ar_ProcessMode{$i}=2)
						$fl_PreemptiveState:=True:C214
					Else 
						$fl_PreemptiveState:=$fl_Preemptive
				End case 
				OBJECT SET TITLE:C194(*; "_PRNB_"+String:C10($i); String:C10(ar_ProcessNb{$i}))
				OBJECT SET VISIBLE:C603(*; "_MULTI_"+String:C10($i); $active & $fl_PreemptiveState)
				OBJECT SET VISIBLE:C603(*; "_MONO_"+String:C10($i); $active & Not:C34($fl_PreemptiveState))
			End if 
		End for 
		
		If (vOpKind="@GRAPH@")
			OBJECT SET VISIBLE:C603(*; "_GRAPH_STATS_"; True:C214)
			OBJECT SET VISIBLE:C603(*; "_THERMO_F_@"; False:C215)
			If (Size of array:C274(ar_StatSlices)>0)
				graph_PlotChart("_GRAPH_STATS_"; ->ar_StatSlices; "[DOTLINES][%]")
			End if 
		Else 
			OBJECT SET VISIBLE:C603(*; "_GRAPH_STATS_"; False:C215)
			OBJECT SET VISIBLE:C603(*; "_THERMO_F_@"; True:C214)
		End if 
		
		$fl_Finished:=True:C214
		For ($i; 1; Size of array:C274(ar_ProcessNb))
			If (Process state:C330(ar_ProcessNb{$i})=Executing:K13:4)
				$fl_Finished:=False:C215
			End if 
		End for 
		If ($fl_Finished)
			If ((Sum:C1(ar_MilliStart)+Sum:C1(ar_MilliEnd))>0)
				OBJECT Get pointer:C1124(Object named:K67:5; "_THERMO_00")->:=100
			End if 
			$start:=MAXLONG:K35:2
			$end:=0
			For ($i; 1; Size of array:C274(ar_MilliStart))
				If (ar_MilliStart{$i}#0)
					If (ar_MilliStart{$i}<$start)
						$start:=ar_MilliStart{$i}
					End if 
				End if 
			End for 
			For ($i; 1; Size of array:C274(ar_MilliEnd))
				If (ar_MilliEnd{$i}#0)
					If (ar_MilliEnd{$i}>$end)
						$end:=ar_MilliEnd{$i}
					End if 
				End if 
			End for 
			If ($start#MAXLONG:K35:2)
				vDuration:=$end-$start
			End if 
			OBJECT SET VISIBLE:C603(*; "_TIMER_"; False:C215)
		End if 
End case 
