//%attributes = {}
C_POINTER:C301($pictPtr; $ar_ValuesPtr)

$pictName:=$1
$ar_ValuesPtr:=$2
$supParameters:=$3  //"[BETWEEN][AUTOLEGEND][DOTLINES][%]'

$pictPtr:=OBJECT Get pointer:C1124(Object named:K67:5; $pictName)

$fl_InBetween:=(Position:C15("[BETWEEN]"; $supParameters)>0)
$fl_AutoYLegends:=(Position:C15("[AUTOLEGEND]"; $supParameters)>0)
$fl_DottedLines:=(Position:C15("[DOTLINES]"; $supParameters)>0)
$fl_Percent:=(Position:C15("[%]"; $supParameters)>0)

//PICTURE PROPERTIES($pictPtr->;$width;$height)
OBJECT GET COORDINATES:C663(*; $pictName; $l; $t; $r; $b)
$width:=$r-$l
$height:=$b-$t
$nbWorkers:=Size of array:C274($ar_ValuesPtr->{1})
$nbSlices:=Size of array:C274($ar_ValuesPtr->)

ARRAY LONGINT:C221($ar_Values; $nbSlices)
ARRAY TEXT:C222($ar_XLegends; $nbSlices)
For ($i; 1; $nbSlices)
	$ar_XLegends{$i}:=String:C10($i)
	$ar_Values{$i}:=Sum:C1($ar_ValuesPtr->{$i})
End for 
$YLegend:="% Cities"
$XLegend:="Cities per city population"

$XNbValues:=$nbSlices
$YNbValues:=10

$VScrollBar:=0
$HScrollBar:=0
$YAxisShift:=50
$lineStyle:="stroke:rgb(128,128,128);stroke-width:2"
$dotLineStyle:="stroke:rgb(128,128,128);stroke-width:1;stroke-dasharray: 1, 4;"

$XText_x:=(($width-$VScrollBar-$YAxisShift)/2)+$YAxisShift
$XText_y:=$height-10
$XTextSize:=12

$gradSize:=5
$gradTextSize:=12
$gradTextShift:=5

$baseLine:=$height-10-$XTextSize-10-$gradTextSize-$gradTextShift-$gradSize
$VLegendPosY:=$baseLine\2

ARRAY TEXT:C222($ar_Percents; 0)
If ($fl_Percent)
	ARRAY TEXT:C222($ar_Percents; 10)
	For ($i; 1; 10)
		$ar_Percents{$i}:=String:C10($i*10)+"%"
	End for 
End if 

OBJECT SET FORMAT:C236(*; $pictName; Char:C90(Truncated non centered:K6:4))

$scheme:=Get Application color scheme:C1763

If ($scheme="dark")
	$fill:="white"
Else 
	$fill:="black"
End if 

$svg:=DOM Create XML Ref:C861("svg"; "http://www.w3.org/2000/svg")

// Legend on X-Axis
$refTextX:=DOM Create XML element:C865($svg; "text"; "id"; "x_Legend"; "x"; $XText_x; "y"; $XText_y; "font-family"; "arial"; "font-size"; $XTextSize; "fill"; $fill; "stroke-width"; 0; "text-anchor"; "middle")
DOM SET XML ELEMENT VALUE:C868($refTextX; $XLegend)
//Legend on Y-Axis
$refTextY:=DOM Create XML element:C865($svg; "text"; "id"; "y_Legend"; "x"; 10; "y"; $VLegendPosY; "font-family"; "arial"; "font-size"; $XTextSize; "fill"; $fill; "stroke-width"; 0; "text-anchor"; "middle")
DOM SET XML ATTRIBUTE:C866($refTextY; "transform"; "rotate(-90 15, "+String:C10($VLegendPosY)+")")
DOM SET XML ELEMENT VALUE:C868($refTextY; $YLegend)

//Draw Axis and Arrows
$refAxisX:=DOM Create XML element:C865($svg; "line"; "id"; "x_Axis"; "x1"; $YAxisShift+10; "y1"; $baseLine; "x2"; $width-10-$VScrollBar; "y2"; $baseLine; "style"; $lineStyle)
$refAxisX_Arrow:=DOM Create XML element:C865($svg; "line"; "id"; "x_AxisArrow"; "x1"; $width-10-$VScrollBar; "y1"; $baseLine; "x2"; $width-10-$VScrollBar-10; "y2"; $baseLine+5; "style"; $lineStyle)
$refAxisY:=DOM Create XML element:C865($svg; "line"; "id"; "Y_Axis"; "x1"; $YAxisShift+10; "y1"; $baseLine; "x2"; $YAxisShift+10; "y2"; 10; "style"; $lineStyle)
$refAxisY_Arrow:=DOM Create XML element:C865($svg; "line"; "id"; "Y_AxisArrow"; "x1"; $YAxisShift+10; "y1"; 10; "x2"; $YAxisShift+10-5; "y2"; 10+10; "style"; $lineStyle)

//Calculate actual ploting Values
$n:=Size of array:C274($ar_Values)
ARRAY LONGINT:C221($arPlotValues; $n)
C_LONGINT:C283($maxValue)
If ($fl_Percent)
	$maxValue:=100
Else 
	$maxValue:=0
	For ($i; 1; $n)
		If ($ar_Values{$i}>$maxValue)
			$maxValue:=$ar_Values{$i}
		End if 
	End for 
	If ($fl_AutoYLegends)
		ARRAY TEXT:C222($ar_GradTexts; $YNbValues)
		$maxValue:=gnl_GetBestMaxValue($maxValue; ->$ar_GradTexts)
	Else 
		ARRAY TEXT:C222($ar_GradTexts; 0)
		$maxValue:=gnl_GetBestMaxValue($maxValue)
	End if 
End if 

//Draw Scale Graduations X-Axis
$vPos:=$baseLine
$hPosMax:=$width-10-$VScrollBar-30
$hUnits:=($hPosMax-$YAxisShift)\($XNbValues)
ARRAY TEXT:C222($ar_HGradRefs; $XNbValues)
ARRAY TEXT:C222($ar_HTextRefs; $XNbValues)
For ($i; 0; $XNbValues)
	$hPos:=$YAxisShift+10+($i*$hUnits)
	$ar_HGradRefs{$i}:=DOM Create XML element:C865($svg; "line"; "id"; "X_AxisMark_"+String:C10($i; "000"); "x1"; $hPos; "y1"; $vPos; "x2"; $hPos; "y2"; $vPos+$gradSize; "style"; $lineStyle)
	$ar_HTextRefs{$i}:=DOM Create XML element:C865($svg; "text"; "id"; "X_AxisText_"+String:C10($i; "000"); "x"; $hPos; "y"; $vPos+$gradSize+$gradTextShift+10; "font-family"; "arial"; "font-size"; $XTextSize; "fill"; $fill; "stroke-width"; 0; "text-anchor"; "middle")
	DOM SET XML ELEMENT VALUE:C868($ar_HTextRefs{$i}; $ar_XLegends{$i})
	
End for 

//Draw Scale Graduations Y-Axis
$hPos:=$YAxisShift+10
$vPosMax:=10+30
$vUnits:=($baseLine-$vPosMax)\($YNbValues)
ARRAY TEXT:C222($ar_VGradRefs; $YNbValues)
ARRAY TEXT:C222($ar_VTextRefs; $YNbValues)
Case of 
	: ($fl_Percent)
		$arPtr:=->$ar_Percents
	: ($fl_AutoYLegends)
		$arPtr:=->$ar_GradTexts
	Else 
		
End case 
For ($i; 0; $YNbValues; 2)
	$vPos:=$baseLine-($i*$vUnits)
	$ar_VGradRefs{$i}:=DOM Create XML element:C865($svg; "line"; "id"; "Y_AxisMark_"+String:C10($i; "000"); "x1"; $hPos; "y1"; $vPos; "x2"; $hPos-$gradSize; "y2"; $vPos; "style"; $lineStyle)
	$ar_VTextRefs{$i}:=DOM Create XML element:C865($svg; "text"; "id"; "Y_AxisText_"+String:C10($i; "000"); "x"; $hPos-10; "y"; $vPos; "font-family"; "arial"; "font-size"; $XTextSize; "fill"; $fill; "stroke-width"; 0; "text-anchor"; "middle")
	DOM SET XML ATTRIBUTE:C866($ar_VTextRefs{$i}; "transform"; "rotate(-90 "+String:C10($hPos-10)+", "+String:C10($vPos)+")")
	DOM SET XML ELEMENT VALUE:C868($ar_VTextRefs{$i}; $arPtr->{$i})
	If ($fl_DottedLines)
		$ref:=DOM Create XML element:C865($svg; "line"; "id"; "Y_AxisDots_"+String:C10($i; "000"); "x1"; $hPos; "y1"; $vPos; "x2"; $width-10-$VScrollBar; "y2"; $vPos; "style"; $dotLineStyle)
	End if 
End for 

//Draw Graph itself
$barWidth:=($hUnits*2)\3
$barMaxHeight:=($baseLine-$vPosMax)
For ($i; 1; $n)
	$ar_Values{$i}:=$ar_Values{$i}+(Random:C100/4)
End for 
$max:=Max:C3($ar_Values)
C_REAL:C285($log; $value)
For ($i; 1; $n)
	$value:=$ar_Values{$i}/$max
	$log:=Log:C22($i*10)/Log:C22(10)  //1->2.5
	$value:=$value/($log^2)
	$arPlotValues{$i}:=$value*$barMaxHeight
End for 

ARRAY TEXT:C222($ar_FillColors; $n-Num:C11($fl_InBetween)+1+1)
gnl_ComputeColorGradient("#FFFF00"; "#FF0000"; ->$ar_FillColors)
$barStyle:="stroke: #666666; stroke-width: 1; fill-opacity: 0.8; fill:"  //stroke-dasharray: 10 5;fill: none; rx="10" ry="5"  fill-opacity: 0.5
ARRAY TEXT:C222($ar_BarsRefs; $n)

$fl_InBetween:=True:C214

For ($i; 1; $n-Num:C11($fl_InBetween)+1)
	If ($fl_InBetween)
		$x:=$YAxisShift+10+(($hUnits-$barWidth)\2)+(($i-1)*$hUnits)
	Else 
		$x:=$YAxisShift+10+($hUnits-($barWidth\2))+(($i-1)*$hUnits)
	End if 
	$y:=$baseLine-$arPlotValues{$i}
	$h:=$arPlotValues{$i}
	$w:=$barWidth
	$barStyleX:=$barStyle+$ar_FillColors{$i}+";"
	$ar_BarsRefs{$i}:=DOM Create XML element:C865($svg; "rect"; "id"; "Bar_"+String:C10($i; "000"); "x"; $x; "y"; $y; "width"; $w; "height"; $h; "rx"; 5; "ry"; 5; "style"; $barStyleX)
End for 

//Comment Text
$refComment:=DOM Create XML element:C865($svg; "text"; "id"; "MOComment"; "x"; $XText_x; "y"; $XTextSize+2; "font-family"; "arial"; "font-size"; $XTextSize+2; "fill"; "#0000AA"; "stroke-width"; 0; "text-anchor"; "middle")
DOM SET XML ELEMENT VALUE:C868($refComment; "")

//$ar_XLegendsPtr;$ar_YLegendsPt;,$ar_ValuesPtr  $fl_InBetween

SVG EXPORT TO PICTURE:C1017($svg; $pictPtr->; Copy XML data source:K45:17)
DOM CLOSE XML:C722($svg)

$z:=0

//SVG SET ATTRIBUTE($pictPtr->;"x_Axis";"y1";10;*)
//fill="#000000" stroke-width="0" stroke-dasharray="null" stroke-linejoin="null" stroke-linecap="null" 
//x="145" y="37" id="svg_7" font-size="24" font-family="serif" text-anchor="middle" xml:space="preserve" transform="rotate(30 20,40)
//transform="matrix(1.14935 0 0 1.03571 -14.6557 -0.535714)" 

//DOM SET XML ATTRIBUTE($refText;"y";"20px")
//DOM SET XML ATTRIBUTE($refText;"x";"100px")


