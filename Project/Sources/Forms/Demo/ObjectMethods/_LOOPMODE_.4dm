Case of 
	: ((Self:C308->)=2)
		vOpKind:="DB"
	: ((Self:C308->)=3)
		vOpKind:="DB+CALC"
	: ((Self:C308->)=4)
		vOpKind:="DB+GRAPH"
	Else 
		Self:C308->:=1
		vOpKind:="CALC"
End case 
