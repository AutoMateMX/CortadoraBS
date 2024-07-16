
ACTION InitParIDWrite: 

	MpAxisBasic_Cutter.Enable := FALSE;
	//Write encoder values
	
	//Bus voltage
	MC_BR_ProcessParID_AcpAx_0.Axis := ADR(Cutter);
	MC_BR_ProcessParID_AcpAx_0.Execute := TRUE;
	MC_BR_ProcessParID_AcpAx_0.DataAddress := ADR(McAcpAxProcessParIDType_0);
	MC_BR_ProcessParID_AcpAx_0.NumberOfParIDs := 1;
	MC_BR_ProcessParID_AcpAx_0.Mode := mcACPAX_PARID_SET;
	
	McAcpAxProcessParIDType_0.DataType := mcACPAX_PARTYPE_REAL;
	McAcpAxProcessParIDType_0.ParID := 390;
	McAcpAxProcessParIDType_0.VariableAddress := ADR(BusVoltage);
	
	//Scale Units
	MC_BR_ProcessParID_AcpAx_1.Axis := ADR(extEncod);
	MC_BR_ProcessParID_AcpAx_1.Execute := TRUE;
	MC_BR_ProcessParID_AcpAx_1.DataAddress := ADR(McAcpAxProcessParIDType_0);
	MC_BR_ProcessParID_AcpAx_1.NumberOfParIDs := 1;
	MC_BR_ProcessParID_AcpAx_1.Mode := mcACPAX_PARID_SET;
	
	McAcpAxProcessParIDType_1.DataType := mcACPAX_PARTYPE_UDINT;
	McAcpAxProcessParIDType_1.ParID := 420;
	McAcpAxProcessParIDType_1.VariableAddress := ADR(LoadUnits);
	
	//Pulses
	MC_BR_ProcessParID_AcpAx_2.Axis := ADR(extEncod);
	MC_BR_ProcessParID_AcpAx_2.Execute := TRUE;
	MC_BR_ProcessParID_AcpAx_2.DataAddress := ADR(McAcpAxProcessParIDType_0);
	MC_BR_ProcessParID_AcpAx_2.NumberOfParIDs := 1;
	MC_BR_ProcessParID_AcpAx_2.Mode := mcACPAX_PARID_SET;
	
	McAcpAxProcessParIDType_2.DataType := mcACPAX_PARTYPE_UDINT;
	McAcpAxProcessParIDType_2.ParID := 289;
	McAcpAxProcessParIDType_2.VariableAddress := ADR(Pulses);
	
	IF MC_BR_ProcessParID_AcpAx_0.Done AND MC_BR_ProcessParID_AcpAx_1.Done AND MC_BR_ProcessParID_AcpAx_2.Done THEN
		
		MC_BR_ProcessParID_AcpAx_0.Execute := FALSE;
		MC_BR_ProcessParID_AcpAx_1.Execute := FALSE;
		MC_BR_ProcessParID_AcpAx_2.Execute := FALSE;
		InitWrite := FALSE;
		
	END_IF;
	
	MC_BR_ProcessParID_AcpAx_0();
	MC_BR_ProcessParID_AcpAx_1();
	MC_BR_ProcessParID_AcpAx_2();
	
END_ACTION
