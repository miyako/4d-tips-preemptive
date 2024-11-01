//%attributes = {}
//Converts a Hex string into a decimal one
C_LONGINT:C283($0; $l; $i; $long; $sign; $result)
$hex:=$1
$result:=0
$l:=Length:C16($hex)
If ($l>0)
	$hex:=Uppercase:C13($hex)
	$digit:=0
	$sign:=1
	For ($i; 1; $l)
		$asc:=Character code:C91($hex[[$i]])
		$good:=True:C214
		If (($asc>47) & ($asc<58))
			$digit:=$asc-48
		Else 
			If (($asc>64) & ($asc<71))
				$digit:=$asc-55
			Else 
				$good:=False:C215
			End if 
		End if 
		If (($l=8) & ($i=1))  //uLong8 -> Have to test the sign bit
			If ($digit>7)
				$sign:=-1
				$digit:=$digit-8
			End if 
		End if 
		If ($good)
			$long:=($digit*(16^($l-$i)))
			$result:=$result+$long
		End if 
	End for 
	If ($sign=-1)
		$result:=($result-MAXLONG:K35:2-1)
	End if 
End if 
$0:=$result