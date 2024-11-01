//%attributes = {}
$maxVal:=$1

$fl_WithLegends:=(Count parameters:C259>1)
If ($fl_WithLegends)
	$ar_GradTextsPtr:=$2
End if 

$result:=$maxVal

$flNeg:=False:C215
If ($maxVal<0)
	$flNeg:=True:C214
	$maxVal:=Abs:C99($maxVal)
End if 

$pwr:=Length:C16(String:C10($maxVal))
$result:=10^$pwr

Case of 
	: ($maxVal<($result/5))
		$result:=$result/5
		
	: ($maxVal<($result/2))
		$result:=$result/2
		
End case 

If ($fl_WithLegends)
	$nb:=Size of array:C274($ar_GradTextsPtr->)
	$dif:=$result\$nb
	For ($i; 1; $nb)
		$val:=$i*$dif
		Case of 
			: ($val>=1000000)
				$ar_GradTextsPtr->{$i}:=String:C10($val/1000000)+"M"
			: ($val>=1000)
				$ar_GradTextsPtr->{$i}:=String:C10($val/1000)+"K"
			Else 
				$ar_GradTextsPtr->{$i}:=String:C10($val)
		End case 
		
	End for 
	$ar_GradTextsPtr->{0}:="0"
End if 

$0:=$result  //*(-1*num($flNeg))