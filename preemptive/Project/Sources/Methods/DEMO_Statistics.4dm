//%attributes = {}
C_OBJECT:C1216($object; $obj_Parameters)
C_LONGINT:C283($thermoID; $process2call; $window2call; $nbOfSlices; $lastRecNb)
C_REAL:C285($total; $average)
C_BOOLEAN:C305($lotOfCalcs; $fl_Preemptive; $fl_Chunk)

$process2call:=$1
$window2call:=$2
$what2Do:=$3
$obj_Parameters:=$4  //Here you get a COPY of the original object.
//Any modification done on it will NOT be reported onto the original!

$curProcess:=Current process:C322
$timeSliceCount:=5

OB SET:C1220($object; "CURPROCESS"; $curProcess)
$fl_Preemptive:=OB Get:C1224($obj_Parameters; "MULTIMODE")
OB SET:C1220($object; "MULTIMODE"; $fl_Preemptive)
$thermoID:=OB Get:C1224($obj_Parameters; "THERMOID")
OB SET:C1220($object; "THERMOID"; $thermoID)

Case of 
	: ($what2Do="IDENT")
		C_LONGINT:C283($status)
		$mode:="NUL"
		$error:=_O_Gestalt:C488("4thr"; $status)
		If ($error=0)
			$mode:=Choose:C955($status; "COOP"; "PREEMP")
		End if 
		OB SET:C1220($object; "WHAT2DO"; "IDENT_PROCESS")
		OB SET:C1220($object; "THERMOID"; $thermoID)
		OB SET:C1220($object; "WORKERMODE"; $mode)
		CALL FORM:C1391($window2call; "CF_Talk2Form"; $object)
		
	: (($what2Do="START") | ($what2Do="CHUNK"))
		$nbOfSlices:=OB Get:C1224($obj_Parameters; "NBSLICES")
		$startRecord:=OB Get:C1224($obj_Parameters; "REC_FROM")
		$endRecord:=OB Get:C1224($obj_Parameters; "REC_TO")
		$lastRecNb:=OB Get:C1224($obj_Parameters; "TOTNB")
		$refreshDelay:=OB Get:C1224($obj_Parameters; "REFRESH")
		$vOpKind:=OB Get:C1224($obj_Parameters; "OPKIND")
		$vIterations:=OB Get:C1224($obj_Parameters; "ITERATIONS")
		OB SET:C1220($object; "ITERATIONS"; $vIterations)
		$fl_Chunk:=OB Get:C1224($obj_Parameters; "CHUNK")
		OB SET:C1220($object; "CHUNK"; $fl_Chunk)
		
		ARRAY LONGINT:C221($ar_StatSlices; 25)  //Max in a city : 250 000 ->Each Slice is 10000 inhabitants
		//Result will be nb of cities per slice of 10000 people
		
		$flCompiled:=Is compiled mode:C492
		$fl_UseDB:=($vOpKind="@DB@")
		$fl_UseCalcs:=($vOpKind="@CALC@")
		$fl_UseGraph:=($vOpKind="@GRAPH@")
		If ($flCompiled)
			$loops:=10
		Else 
			$loops:=1
		End if 
		
		//Because a loop can run for a long time, and because we may need to interrupt it...
		//...we will CALL WORKER itself every 5 intervals in order to give a chance for the worker to get...
		//...another message from other processes. We will time-slice it in 5*$refreshDelay slices
		
		If ($what2Do="START")
			$millisecondsStart:=Milliseconds:C459
			$curRecNb:=$startRecord
			$iterations:=0
			$count:=0
			$total:=0
			$frequency:=0
			OB SET:C1220($object; "FREQUENCY"; $frequency)
		Else   //means CHUNK
			$millisecondsStart:=OB Get:C1224($obj_Parameters; "MS_START")
			$curRecNb:=OB Get:C1224($obj_Parameters; "CUR_CURRECORD")
			$iterations:=OB Get:C1224($obj_Parameters; "CUR_ITERATION")
			$count:=OB Get:C1224($obj_Parameters; "CUR_COUNT")
			$total:=OB Get:C1224($obj_Parameters; "CUR_TOTAL")
			OB SET:C1220($object; "FREQUENCY"; OB Get:C1224($obj_Parameters; "CUR_FREQUENCY"))
			$frequency:=0  //
			If ($fl_UseGraph)
				OB GET ARRAY:C1229($obj_Parameters; "STATS"; $ar_StatSlices)
			End if 
		End if 
		
		
		$ticks1:=Tickcount:C458
		$ticks2:=Tickcount:C458
		$fl_End:=True:C214
		
		Repeat   //We will iterate the same loop as many times as requested...
			gError:=0
			Repeat 
				If ($fl_UseDB)
					gError:=0
					ON ERR CALL:C155("Handle_Error")
					GOTO RECORD:C242([Cities:1]; $curRecNb)
					ON ERR CALL:C155("")
				End if 
				$curRecNb:=$curRecNb+1
				If ($curRecNb>$endRecord)
					$fl_StopMainLoop:=True:C214
					$iterations:=$iterations+1
					$fl_StopIterLoop:=($iterations>=$vIterations)
					$curRecNb:=$startRecord-1
				Else 
					$fl_StopMainLoop:=False:C215
					$fl_StopIterLoop:=False:C215
				End if 
				
				If ((gError#0) | $fl_StopMainLoop)
					gError:=0
				Else 
					If ($fl_UseDB)
						$population:=[Cities:1]Population:7
					Else 
						$population:=Random:C100*Random:C100\100
					End if 
					$total:=$total+$population
					
					//Here we calculate the Frequency (i.e. Nb of loops per second
					//The FREQUENCY attribute will be ready for the next delivery to the main dialog
					$frequency:=$frequency+1
					If ((Tickcount:C458-$ticks1)>=30)
						$ticks1:=Tickcount:C458
						OB SET:C1220($object; "FREQUENCY"; $frequency*2)
						$frequency:=0
					End if 
					$count:=$count+1
					$average:=$total\$count
					
					If ($fl_UseCalcs)  //We will perform useless calculations, but we could do useful ones in the same way...
						$fibonacci1:=1
						$fibonacci2:=1
						$fiboRank:=1
						Repeat 
							$temp:=$fibonacci2
							$fibonacci2:=$fibonacci2+$fibonacci1
							$fibonacci1:=$temp
							$fiboRank:=$fiboRank+1
						Until ($fibonacci2>=$population)
						For ($z; 1; $loops)
							$txt0:="Comme une onde qui bout dans une urne trop pleine"
							$pos:=Position:C15(" "; $txt0)
							//$txt1:=Uppercase($txt0)
							//$txt2:=Lowercase($txt1)
							IDLE:C311
						End for 
					End if 
					//Here more useless calculations ?
					If ($fl_UseGraph)
						$statIndex:=($population\10000)+1
						$ar_StatSlices{$statIndex}:=$ar_StatSlices{$statIndex}+1
					End if 
				End if   //gError=0  $fl_StopMainLoop
				
				$fl_End:=True:C214
				//Now we will CALL FORM by calling CF_Talk2Form Method inside the main dialog context
				//We pass all the parameters at once in one object
				If ((Tickcount:C458-$ticks2)>=$refreshDelay)
					$ticks2:=Tickcount:C458
					OB SET:C1220($object; "WHAT2DO"; "DISPLAY")
					OB SET:C1220($object; "COUNT"; $count\$vIterations)
					OB SET:C1220($object; "TOTNB"; $lastRecNb)
					OB SET:C1220($object; "TOTAL"; $total)
					OB SET:C1220($object; "AVERAGE"; $average)
					OB SET:C1220($object; "THERMOID"; $thermoID)
					OB SET:C1220($object; "OPKIND"; $vOpKind)
					If ($fl_UseGraph)
						OB SET ARRAY:C1227($object; "STATS"; $ar_StatSlices)
					End if 
					CALL FORM:C1391($window2call; "CF_Talk2Form"; $object)
					$timeSliceCount:=$timeSliceCount-1
					If (($timeSliceCount<=0) & ($curRecNb<$endRecord) & $fl_Chunk)
						OB SET:C1220($object; "REC_FROM"; $startRecord)
						OB SET:C1220($object; "REC_TO"; $endRecord)
						OB SET:C1220($object; "NBSLICES"; $nbOfSlices)
						OB SET:C1220($object; "REFRESH"; $refreshDelay)
						OB SET:C1220($object; "CUR_CURRECORD"; $curRecNb)
						OB SET:C1220($object; "CUR_TOTAL"; $total)
						OB SET:C1220($object; "CUR_FREQUENCY"; $frequency)
						OB SET:C1220($object; "CUR_ITERATION"; $iterations)
						OB SET:C1220($object; "CUR_COUNT"; $count)
						OB SET:C1220($object; "MS_START"; $millisecondsStart)
						
						CALL WORKER:C1389("Worker_"+String:C10($thermoID); "DEMO_Statistics"; $process2call; $window2call; "CHUNK"; $object)
						$fl_End:=False:C215
						$fl_StopMainLoop:=True:C214
						$fl_StopIterLoop:=True:C214
					End if 
				End if 
			Until ($fl_StopMainLoop)
		Until ($fl_StopIterLoop)
		
		If ($fl_End)
			$millisecondsEnd:=Milliseconds:C459
			OB SET:C1220($object; "WHAT2DO"; "ENDJOB")
			OB SET ARRAY:C1227($object; "STATS"; $ar_StatSlices)
			OB SET:C1220($object; "TOTNB"; $lastRecNb)
			OB SET:C1220($object; "THERMOID"; $thermoID)
			OB SET:C1220($object; "MILLISTART"; $millisecondsStart)
			OB SET:C1220($object; "MILLIEND"; $millisecondsEnd)
			OB SET:C1220($object; "OPKIND"; $vOpKind)
			CALL FORM:C1391($window2call; "CF_Talk2Form"; $object)
		End if 
		
	: ($what2Do="STOP")
		
	: ($what2Do="BANG")
		OB SET:C1220($object; "WHAT2DO"; "AGONY")
		CALL FORM:C1391($window2call; "CF_Talk2Form"; $object)
		KILL WORKER:C1390
		//CALL WORKER(1;"myMessage";Current process name)
		
	Else 
		
		
End case 