//%attributes = {}
$firstColor:=$1  // Hexa string 0xFFFFFF or #FFFFFF or FFFFFF
$lastColor:=$2
$arColorsPtr:=$3

$n:=Size of array:C274($arColorsPtr->)
$prefix:=""
$lastColorOrg:=$lastColor
Case of 
	: ($firstColor="0x@")
		$prefix:="0x"
		$firstColor:=Substring:C12($firstColor; 3)
		$lastColor:=Substring:C12($lastColor; 3)
		
	: ($firstColor="#@")
		$prefix:="#"
		$firstColor:=Substring:C12($firstColor; 2)
		$lastColor:=Substring:C12($lastColor; 2)
		
	: (Length:C16($firstColor)=8)
		$firstColor:=Substring:C12($firstColor; 3)
		$lastColor:=Substring:C12($lastColor; 3)
		
End case 

$red1:=Convert_Hex2Num(Substring:C12($firstColor; 1; 2))
$green1:=Convert_Hex2Num(Substring:C12($firstColor; 3; 2))
$blue1:=Convert_Hex2Num(Substring:C12($firstColor; 5; 2))
$red2:=Convert_Hex2Num(Substring:C12($lastColor; 1; 2))
$green2:=Convert_Hex2Num(Substring:C12($lastColor; 3; 2))
$blue2:=Convert_Hex2Num(Substring:C12($lastColor; 5; 2))
$difR:=($red2-$red1)\($n-1)
$difG:=($green2-$green1)\($n-1)
$difB:=($blue2-$blue1)\($n-1)

For ($i; 1; $n)
	$sR:=String:C10($red1+(($i-1)*$difR); "&x")
	$sG:=String:C10($green1+(($i-1)*$difG); "&x")
	$sB:=String:C10($blue1+(($i-1)*$difB); "&x")
	$arColorsPtr->{$i}:=$prefix+Substring:C12($sR; Length:C16($sR)-1)+Substring:C12($sG; Length:C16($sG)-1)+Substring:C12($sB; Length:C16($sB)-1)
End for 

$arColorsPtr->{$n}:=$lastColorOrg