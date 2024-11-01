//%attributes = {}
gError:=Error
If (Caps lock down:C547)
	ALERT:C41(String:C10(gError))
End if 