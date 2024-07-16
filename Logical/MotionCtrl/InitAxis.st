
ACTION InitAxis: 

	MachineInitializing := TRUE;
				
	IF MpAxisBasic_Cutter.Info.ReadyToPowerOn THEN
		
		MpAxisBasic_Cutter.Power := TRUE;
		MachineInitializing := FALSE;
		
	END_IF;
				
	IF MpAxisBasic_Cutter.PowerOn AND NOT MpAxisBasic_Cutter.IsHomed THEN
		
		ReadyToInitHome := TRUE;
		ReadyToPower := FALSE;
		
	END_IF;	
			
	IF ReadyToInitHome THEN
				
		MC_BR_InitHome_AcpAx_0.Execute := TRUE;
		
		IF MC_BR_InitHome_AcpAx_0.Done THEN
			MC_BR_InitHome_AcpAx_0.Execute := FALSE;
			ReadyToHome := TRUE;
			ReadyToInitHome := FALSE;
		END_IF;
				
		MC_BR_InitHome_AcpAx_0();
				
	END_IF;
			
	IF ReadyToHome AND (MpAxisBasic_Cutter.Info.PLCopenState = mcAXIS_STANDSTILL) THEN
				
		MachineHoming := TRUE;
		MpAxisBasic_Cutter.Home := TRUE;
		
		IF MpAxisBasic_Cutter.IsHomed THEN
			MachineHoming := FALSE;
			MpAxisBasic_Cutter.Home := FALSE;
			MODE_SELECTED := HMI_MODE_SELECTED;
			MachineReady := TRUE;
			ReadyToHome := FALSE;
		END_IF;
				
	END_IF;
	
	IF NOT (MpAxisBasic_Cutter.Info.DigitalInputsStatus.DriveEnable) THEN
		
		MpAxisBasic_Cutter.Stop := TRUE;
		MpAxisBasic_Cutter.Home := FALSE;
		MpAxisBasic_Cutter.AutoTune := FALSE;
		
	ELSE
		
		MpAxisBasic_Cutter.Stop := FALSE;
		
	END_IF;
	
END_ACTION
