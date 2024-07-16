(********************************************************************
 * COPYRIGHT -- AutoMate MX
 ********************************************************************
 * Program: IMA_Client
 * File: IMA_Client.st
 * Author: Erick Alcantar
 * Created: July 8, 2024/9:54 PM 
 ********************************************************************
 * Implementation of program IMA_Client
 ********************************************************************)

PROGRAM _INIT
	
	(*IMA Init*)
	pDatObjName := ADR('DataMap');
	statusInit := IMAinit(pDatObjName, errorInfo, ADR(stationId));
	(* Enabling connection automatically every boot-up *)
	enableConnection := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	CASE DataCollectorState OF
		
		ST_IDLE:
			(*IMA Communication*)
			IF (statusInit = IMA_OK) AND enableConnection THEN
				DataCollectorState := ST_CONNECTING;
			END_IF;				
		
		ST_CONNECTING:
			statusComm := IMAcomm(stationId, connInfoPV, connInfoAUX);
			IF  connInfoPV.connectionStatus = IMA_OK THEN
				DataCollectorState := ST_CONNECTED;
			END_IF;
		
		ST_CONNECTED:
			statusComm := IMAcomm(stationId, connInfoPV, connInfoAUX);
			IF statusComm <> 0 THEN
				DataCollectorState := ST_ERROR_ACTIVE;
			ELSIF NOT enableConnection THEN
				DataCollectorState := ST_CLOSE_CONNECTION;
			END_IF
			
		ST_CLOSE_CONNECTION:
			statusClose := IMAclose(stationId);
			IF statusClose = 0 THEN
	  			DataCollectorState := ST_IDLE;
			END_IF;
		
		ST_ERROR_ACTIVE:
			
			timeOutConnection (IN := TRUE, PT := T#5s);
			
			IF resetError OR timeOutConnection.Q THEN
				statusClose 				:= IMAclose(stationId);
				IF statusClose = 0 THEN
					timeOutConnection.IN 	:= FALSE;
					DataCollectorState 		:= ST_RESET_ERROR;
				END_IF
			END_IF		
		
		ST_RESET_ERROR:
			IF statusClose = 0 THEN
				resetError := FALSE;
				statusInit := IMAinit(pDatObjName, errorInfo, ADR(stationId));
				DataCollectorState := ST_IDLE;
			END_IF
		
	END_CASE;
	
	timeOutConnection();

END_PROGRAM

PROGRAM _EXIT
	
	//Close connection
	IMAclose(stationId);
	//Re-init
	pDatObjName := ADR('DataMap');
	statusInit := IMAinit(pDatObjName, errorInfo, ADR(stationId));
	
END_PROGRAM