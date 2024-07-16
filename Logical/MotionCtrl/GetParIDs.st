
ACTION ReadParIDs: 

	CASE ParameterReading OF
		RESET:
			MC_BR_CyclicProcessParID_AcpAx_1.Enable := FALSE;
			MC_BR_CyclicProcessParID_AcpAx_1();
			IF ParCount = 0 THEN
				ParameterReading := TORQUE;
				ParCount := ParCount + 1;
			ELSIF ParCount = 1 THEN
				ParameterReading := REVS_PER_MINUTE;
				ParCount := ParCount + 1;
			ELSIF ParCount = 2 THEN
				(*ParameterReading := PRODUCTION_SPEED;*)
				ParCount := 0(*ParCount + 1*);
			ELSIF ParCount = 3 THEN
				ParCount :=0;
			END_IF;
			
		TORQUE:
			McAcpAxCycParID_1.ParID := MotorTorque;
			McAcpAxCycParID_1.VariableAddress := ADR(Torque);
			McAcpAxCycParID_1.DataType:= mcACPAX_PARTYPE_DINT;
			ParCount:= 1;
			ParameterReading := RESET;
		REVS_PER_MINUTE:
			McAcpAxCycParID_1.ParID := 298(*331*);
			McAcpAxCycParID_1.VariableAddress := ADR(RPM);
			McAcpAxCycParID_1.DataType:= mcACPAX_PARTYPE_DINT;
			ParCount:= 2;
			ParameterReading := RESET;
		PRODUCTION_SPEED:
			McAcpAxCycParID_1.ParID := 7760;
			McAcpAxCycParID_1.VariableAddress := ADR(ProductionSpeed);
			McAcpAxCycParID_1.DataType:= mcACPAX_PARTYPE_REAL;
			ParCount:= 3;
			ParameterReading := RESET;
	END_CASE;
	
	MC_BR_CyclicProcessParID_AcpAx_1.Enable := TRUE;
	MC_BR_CyclicProcessParID_AcpAx_1.Axis := ADR(Cutter);
	MC_BR_CyclicProcessParID_AcpAx_1.DataAddress := ADR(McAcpAxCycParID_1);
	MC_BR_CyclicProcessParID_AcpAx_1.Mode := mcACPAX_CYCLIC_PARID_READ;
	MC_BR_CyclicProcessParID_AcpAx_1.NumberOfParIDs := 1;
	
	McAcpAxCycParID_1.DataType:= mcACPAX_PARTYPE_DINT;
	McAcpAxCycParID_1.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
	
	MC_BR_CyclicProcessParID_AcpAx_1();
	
//	McAcpAxCycParID_1.ParID := MotorTorque;//423 Actual Position, 246 Actual Position per Revolution
//	McAcpAxCycParID_1.VariableAddress := ADR(Torque);
//	MC_BR_CyclicProcessParID_AcpAx_2.Enable := TRUE;
//	MC_BR_CyclicProcessParID_AcpAx_2.Axis := ADR(Cutter);
//	MC_BR_CyclicProcessParID_AcpAx_2.DataAddress := ADR(McAcpAxCycParID_2);
//	MC_BR_CyclicProcessParID_AcpAx_2.Mode := mcACPAX_CYCLIC_PARID_READ;
//	MC_BR_CyclicProcessParID_AcpAx_2.NumberOfParIDs := 1;
//	
//	McAcpAxCycParID_2.DataType:= mcACPAX_PARTYPE_DINT;
//	McAcpAxCycParID_2.ParID := 331;//423 Actual Position, 246 Actual Position per Revolution
//	McAcpAxCycParID_2.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
//	McAcpAxCycParID_2.VariableAddress := ADR(RPM);
//	
//	MC_BR_CyclicProcessParID_AcpAx_3.Enable := TRUE;
//	MC_BR_CyclicProcessParID_AcpAx_3.Axis := ADR(Cutter);
//	MC_BR_CyclicProcessParID_AcpAx_3.DataAddress := ADR(McAcpAxCycParID_3);
//	MC_BR_CyclicProcessParID_AcpAx_3.Mode := mcACPAX_CYCLIC_PARID_READ;
//	MC_BR_CyclicProcessParID_AcpAx_3.NumberOfParIDs := 1;
//	
//	McAcpAxCycParID_3.DataType:= mcACPAX_PARTYPE_REAL;
//	McAcpAxCycParID_3.ParID := 7760;//423 Actual Position, 246 Actual Position per Revolution
//	McAcpAxCycParID_3.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
//	McAcpAxCycParID_3.VariableAddress := ADR(ProductionSpeed);
	

//	MC_BR_CyclicProcessParID_AcpAx_2();
//	MC_BR_CyclicProcessParID_AcpAx_3();
	
END_ACTION
