set CamConnection to vessel("Tracking Camera"):connection.


//until not true{
	clearscreen.
        set sending to "Transmission".
	CamConnection:sendmessage(sending).
	print sending.
	wait 0.1.
//}