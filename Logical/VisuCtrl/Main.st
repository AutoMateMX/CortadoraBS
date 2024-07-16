
PROGRAM _INIT
	(* Insert code here *)
//Send the Language, which was configured previously
	LanguageSelector:= LanguageAuxiliar;
END_PROGRAM

PROGRAM _CYCLIC
	//Save the current language configuration
	LanguageAuxiliar:=LanguageCurrent;
	(* Insert code here *)
	IF MODE_SELECTED <> 0 THEN
		
		HMI_MODE_SELECTED := MODE_SELECTED;
		
	END_IF;
	
	EncoderModeSelected:= 1;
	TimeModeSelected:= 1;
	SensorModeSelected:= 1;
	SpeedModeSelected := 1;
	
	HideDistanceMode := 1;
	HideSensorMode := 1;
	HideTimeMode := 1;
	HideSpeedMode := 1;
	
	CASE MODE_SELECTED OF
		
		Default:
			
			IF MachineInitializing THEN
	  			MachineStateIndex := 0;
			END_IF;
			
			IF MachineAutotuning THEN
	  			MachineStateIndex := 1;
			END_IF;
			
			IF MachineHoming THEN
	  			MachineStateIndex := 2;
			END_IF;
			
			IF MachineReady THEN
				MachineStateIndex := 3;
				LockDistanceInput := 1;
				LockDistanceMode := 1;
				LockSensorMode := 1;
				LockTimeInput := 1;
				LockTimeMode := 1;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
				LockManualCut := 1;
				LockStartStop := 1;
			END_IF;
		
		//Distance
		Encoder:
			
			HideDistanceMode := 0;
			HideSensorMode := 1;
			HideTimeMode := 1;
			HideSpeedMode := 1;
			
			IF MachineReady THEN
				MachineStateIndex := 3;
			END_IF;
			
			IF MachineHoming THEN
				MachineStateIndex := 2;
			END_IF;
			
			MachineStateIndex := 4;
			EncoderModeSelected:= 0;
			TimeModeSelected:= 1;
			SensorModeSelected:= 1;
			SpeedModeSelected := 1;
			
			IF MachineInOperation THEN
				MachineStateIndex := 7;
				
				LockDistanceInput := 1;
				LockTimeInput := 0;
				LockDistanceMode := 1;
				LockTimeMode := 0;
				LockSensorMode := 0;
				LockSpeedMode := 0;
				LockSpeedInput := 0;
			ELSE
				LockDistanceInput := 1;
				LockTimeInput := 1;
				LockDistanceMode := 1;
				LockTimeMode := 1;
				LockSensorMode := 1;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
			END_IF;
			
		Time:
			
			HideDistanceMode := 1;
			HideSensorMode := 1;
			HideTimeMode := 0;
			HideSpeedMode := 1;
			
			LockDistanceInput := 0;
			LockTimeInput := 1;
			
			IF MachineReady THEN
				MachineStateIndex := 3;
			END_IF;
			
			IF MachineHoming THEN
				MachineStateIndex := 2;
			END_IF;
			
			MachineStateIndex := 5;
			EncoderModeSelected:= 1;
			TimeModeSelected:= 0;
			SensorModeSelected:= 1;
			SpeedModeSelected := 1;
			
			IF MachineInOperation THEN
				MachineStateIndex := 8;
				
				LockDistanceInput := 0;
				LockTimeInput := 1;
				LockDistanceMode := 0;
				LockTimeMode := 1;
				LockSensorMode := 0;
				LockSpeedMode := 0;
				LockSpeedInput := 0;
			ELSE
				LockDistanceInput := 1;
				LockTimeInput := 1;
				LockDistanceMode := 1;
				LockTimeMode := 1;
				LockSensorMode := 1;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
			END_IF;
			
		Sensor:
			
			HideDistanceMode := 1;
			HideSensorMode := 0;
			HideTimeMode := 1;
			HideSpeedMode := 1;
			
			LockDistanceInput := 0;
			LockTimeInput := 0;
			
			IF MachineReady THEN
				MachineStateIndex := 3;
			END_IF;
			
			IF MachineHoming THEN
				MachineStateIndex := 2;
			END_IF;
			
		  	MachineStateIndex := 6;
			EncoderModeSelected:= 1;
			TimeModeSelected:= 1;
			SensorModeSelected:= 0;
			SpeedModeSelected := 1;
			
			IF MachineInOperation THEN
				MachineStateIndex := 9;
				
				LockDistanceInput := 0;
				LockTimeInput := 0;
				LockDistanceMode := 0;
				LockTimeMode := 0;
				LockSensorMode := 1;
				LockSpeedMode := 0;
				LockSpeedInput := 0;
			ELSE
				LockDistanceInput := 1;
				LockTimeInput := 1;
				LockDistanceMode := 1;
				LockTimeMode := 1;
				LockSensorMode := 1;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
			END_IF;
			
			IF SensorSignal THEN
	  			SensorIndicator := 142;
			ELSE
				SensorIndicator := 249;
			END_IF;
		
		Speed:
		
			HideDistanceMode := 1;
			HideSensorMode := 1;
			HideTimeMode := 1;
			HideSpeedMode := 0;
			
			MachineStateIndex := 11;
			EncoderModeSelected:= 1;
			TimeModeSelected:= 1;
			SensorModeSelected:= 1;
			SpeedModeSelected := 0;
		
			IF MachineInOperation THEN
				MachineStateIndex := 10;
				
				LockDistanceInput := 0;
				LockTimeInput := 0;
				LockDistanceMode := 0;
				LockTimeMode := 0;
				LockSensorMode := 0;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
			ELSE
				LockDistanceInput := 1;
				LockTimeInput := 1;
				LockDistanceMode := 1;
				LockTimeMode := 1;
				LockSensorMode := 1;
				LockSpeedMode := 1;
				LockSpeedInput := 1;
			END_IF;
		
	END_CASE;
	
	IF MachineInOperation THEN
		VisualOperationIndicator := 0;
	ELSE
		VisualOperationIndicator := 1;
	END_IF;
	
	HideOpenBoxWarning := NOT BoxIsOpen;
	OpenBoxLock := BoxIsOpen;
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

