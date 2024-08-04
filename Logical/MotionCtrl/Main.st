
PROGRAM _INIT
	(* Insert code here *)
	MpAxisBasic_Cutter.MpLink := ADR(Cutter);
	MpAxisBasic_Cutter.Parameters := ADR(MpAxisBasicPar_Cutter);
	
	MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
	MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
	MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
	MpAxisBasicPar_Cutter.Distance := DefaultDistance;
	MpAxisBasicPar_Cutter.Position := DefaultPosition;
	
	MC_BR_InitHome_AcpAx_0.Axis := ADR(Cutter);
	MC_BR_InitHome_AcpAx_0.HomingParameters := McAcpAxHomingPar_0;
	McAcpAxHomingPar_0.HomingMode := InitHomingMode;
	
	MC_BR_InitHome_AcpAx_0.Axis := ADR(Cutter);
	MC_BR_InitHome_AcpAx_0.HomingParameters.HomingMode := InitHomingMode;
	MC_BR_InitHome_AcpAx_0.HomingParameters.Position := DefaultPosition;
	MC_BR_InitHome_AcpAx_0.HomingParameters.StartVelocity := 50;
	MC_BR_InitHome_AcpAx_0.HomingParameters.HomingVelocity := 50;
	MC_BR_InitHome_AcpAx_0.HomingParameters.Acceleration := 500;
	MC_BR_InitHome_AcpAx_0.HomingParameters.SwitchEdge := 0;
	MC_BR_InitHome_AcpAx_0.HomingParameters.StartDirection := 1;
	MC_BR_InitHome_AcpAx_0.HomingParameters.HomingDirection := 0;
	
	MpAxisBasicPar_Cutter.Homing.Mode := HomingMode;
	MpAxisBasicPar_Cutter.Homing.Position := DefaultPosition;
	
	//Autotune settings
	MpAxisBasicPar_Cutter.AutoTune.MaxCurrentPercent := 75;
	MpAxisBasicPar_Cutter.AutoTune.MaxDistance := 5;
	MpAxisBasicPar_Cutter.AutoTune.MaxPositionError := 2000;
	
	//Reading external encoder
	MC_BR_CyclicProcessParID_AcpAx_0.Axis := ADR(ExtEncod);
	MC_BR_CyclicProcessParID_AcpAx_0.DataAddress := ADR(McAcpAxCycParID_0);
	MC_BR_CyclicProcessParID_AcpAx_0.Mode := mcACPAX_CYCLIC_PARID_READ;
	MC_BR_CyclicProcessParID_AcpAx_0.NumberOfParIDs := 1;
	
	McAcpAxCycParID_0.DataType:= mcACPAX_PARTYPE_DINT;
	McAcpAxCycParID_0.ParID := 246;//423 Actual Position, 246 Actual Position per Revolution
	McAcpAxCycParID_0.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
	McAcpAxCycParID_0.VariableAddress := ADR(EncoderActPos);
	
	MpAxisBasic_Cutter.Enable := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC

	Pulses := REAL_TO_UINT(HMIPulses * 4);
	
	vAxisEncoderActPos;
	//Basic calculation of encoder perimeter adjusted via HMI
	EncoderPerimeter := (amPI * EncoderDiameter);
	
	//Cutting Offset - Not used
	DelayTimer_0.PT := UDINT_TO_TIME(SensorCutDelay);
	
	//mapping for visu
	BoxIsOpen := NOT MpAxisBasic_Cutter.Info.DigitalInputsStatus.DriveEnable;
	
	  
	CASE MODE_SELECTED OF
		
		Default:
				
			InitAxis;
				
			CutterTimer.IN := FALSE;
			CutterTimer.PT := DINT_TO_TIME(0);
			
		Encoder:
			
			MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
			MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
			MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
	
			
			//Start Encoder Position Reading
			MC_BR_CyclicProcessParID_AcpAx_0.Enable := TRUE;
			
			IF CorrectDistance THEN
				ActualProductLength := HMICuttingLength + (CuttingOffset *-1);
				CorrectionFactor := (HMICuttingLength/ActualProductLength);
				HMICorrectionFactorPercentage := (CorrectionFactor *100) - 100;
				CuttingOffset := 0;
				CorrectDistance := FALSE;
			END_IF;
			
			HMICorrectionFactorMilimeters :=((HMICorrectionFactorPercentage/100) * HMICuttingLength);
			
			IF ClockwiseCount THEN
	  
				IF EDGEPOS(EncoderActPosOld > EncoderActPos) AND ((EncoderActPosOld - EncoderActPos) > (Pulses*0.995)) THEN
					FullTurnCount := FullTurnCount + 1;
				END_IF;
			
				PartOfTurn := (DINT_TO_REAL(EncoderActPos)/Pulses);
				
			ELSE
				
				IF EDGEPOS(EncoderActPos > EncoderActPosOld) AND ((EncoderActPos - EncoderActPosOld) > (Pulses*0.995)) THEN
					FullTurnCount := FullTurnCount + 1;
				END_IF;
				
				PartOfTurn := 1 - (DINT_TO_REAL(EncoderActPos)/Pulses);
				
			END_IF;

			IF PartOfTurn >= (0.99) OR PartOfTurn < 0 THEN
				PartOfTurn := 0;
			END_IF;
			
			
			RealTurns := FullTurnCount + PartOfTurn;
			
			IF Empezar THEN
				
				MachineInOperation := TRUE;
				
				CycleTimeSum := CycleTimeSum + CycleTime;
				
				CountTurns;				
				
				IF MpAxisBasic_Cutter.MoveDone THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
				END_IF;
				
				IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
					NumberOfCuts_Distance := NumberOfCuts_Distance + 1;
				END_IF;
				
				RemainingDistance := ((NeededTurns - RealTurns) * EncoderPerimeter);
				TraveledDistance := HMICuttingLength - RemainingDistance;				
				
				HMITraveledDistance := TraveledDistance ;
				HMIRemainingDistance := RemainingDistance;
				
				MC_BR_CyclicProcessParID_AcpAx_0();
				
				IF MpAxisBasic_Cutter.Error THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
					MpAxisBasic_Cutter.ErrorReset := TRUE;
				ELSE
					MpAxisBasic_Cutter.ErrorReset := FALSE;
				END_IF;
				
			END_IF;	
			
			IF NOT Empezar THEN
				
				
				HMITraveledDistance := 0 ;
				HMIRemainingDistance := 0;
				CurrentProductTurns := 0;
				NeededTurns := 0;
				
				MC_BR_CyclicProcessParID_AcpAx_0.Enable := FALSE;
				
			END_IF;	
			
			TotalCutsPerMode := NumberOfCuts_Distance;

			
		Time:
			
			MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
			MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
			MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
			
			CycleTimeSum := CycleTimeSum + CycleTime;
			
			IF Empezar THEN
				
				MachineInOperation := TRUE;
				CycleTimeSum := CycleTimeSum + CycleTime;
				UserTime := REAL_TO_DINT(HMITime*1000);
				TimeIsOver := CutterTimer.Q;
				CutterTimer.PT := DINT_TO_TIME(UserTime);
				ElapsedTime := (TIME_TO_REAL(CutterTimer.ET)/1000);
				RemainingTime := (REAL_TO_DINT(HMITime) - ElapsedTime);
				
				IF TimeIsOver THEN
					DelayTimer_0.IN := TRUE;
					CutterTimer.IN := FALSE;
				ELSE
					CutterTimer.IN := TRUE;
				END_IF;	
		
				IF MpAxisBasic_Cutter.MoveDone THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
				END_IF;
				
				IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
					NumberOfCuts_Time := NumberOfCuts_Time + 1;
				END_IF;
					
			ELSE
				
				ElapsedTime := 0;
				RemainingTime := 0;
				
			END_IF;	
			
			TotalCutsPerMode := NumberOfCuts_Time;
			CutsPerMinute_Time := (60/HMITime);
			
			CutterTimer();
			
		Sensor:
				
			MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
			MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
			MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
			
			CycleTimeSum := CycleTimeSum + CycleTime;
			
			IF Empezar THEN
				
				MachineInOperation := TRUE;
				SensorSignal := MpAxisBasic_Cutter.Info.DigitalInputsStatus.Trigger1;
				FilterTimer_0.PT := UINT_TO_TIME(FilterTime);
				
				IF NOT FilterActive THEN
					
					IF EDGEPOS(MpAxisBasic_Cutter.Info.DigitalInputsStatus.Trigger1 OR inputTest) THEN
						FilterTimer_0.IN := TRUE;
						DelayTimer_0.IN := TRUE;
						FilterActive := TRUE;
					END_IF;
					
				END_IF;
						
				IF FilterTimer_0.Q THEN
					FilterActive := FALSE;
					FilterTimer_0.IN := FALSE;
				END_IF;	
					
				FilterActive := FilterTimer_0.IN;
				
				FilterTimer_0();
				
				IF MpAxisBasic_Cutter.MoveDone THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
					SensorSignal := FALSE;
				END_IF;
				
				IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
					NumberOfCuts_Sensor := NumberOfCuts_Sensor + 1;
				END_IF;
				
			END_IF;
		
			TotalCutsPerMode := NumberOfCuts_Sensor;
			CutsPerMinute_Sensor := NumberOfCuts_Sensor/CycleTimeSum;
			
		Speed:
		
			MachineInOperation := TRUE;
			
			CycleTimeSum := CycleTimeSum + CycleTime;
			
			IF Empezar THEN
	  	
				MpAxisBasicPar_Cutter.Velocity := HMIRevolutionsPerSecond * UnitsPerRevolution;
				MpAxisBasicPar_Cutter.Acceleration := MpAxisBasicPar_Cutter.Velocity * 10;
				MpAxisBasicPar_Cutter.Deceleration := MpAxisBasicPar_Cutter.Velocity * 10;
				MpAxisBasic_Cutter.MoveVelocity := TRUE;
				
			ELSE
				
				IF NOT MpAxisBasic_Cutter.IsHomed THEN
					ManualMoveAbsolute := TRUE;
				END_IF;
				
				MpAxisBasic_Cutter.MoveVelocity := FALSE;
				
			END_IF;
		
			IF (MpAxisBasic_Cutter.Velocity <> MpAxisBasicPar_Cutter.Velocity) AND Empezar THEN
				MpAxisBasic_Cutter.Update := TRUE;
			END_IF;
		
			IF MpAxisBasic_Cutter.UpdateDone THEN
				MpAxisBasic_Cutter.Update := FALSE;
			END_IF;
		
		SensorDieCutter:
			
			MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
			MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
			MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
			
			CycleTimeSum := CycleTimeSum + CycleTime;
			
			IF Empezar AND cutEnabled THEN
				
				MachineInOperation := TRUE;
				SensorSignal := MpAxisBasic_Cutter.Info.DigitalInputsStatus.Trigger1;
				FilterTimer_0.PT := UINT_TO_TIME(FilterTime);
				
				IF NOT FilterActive THEN
					
					IF EDGEPOS(MpAxisBasic_Cutter.Info.DigitalInputsStatus.Trigger1 OR inputTest) OR auxToCut THEN
						auxToCut := FALSE;
						FilterTimer_0.IN := TRUE;
						DelayTimer_0.IN := TRUE;
						FilterActive := TRUE;
					END_IF;
					
				END_IF;
						
				IF FilterTimer_0.Q THEN
					FilterActive := FALSE;
					FilterTimer_0.IN := FALSE;
				END_IF;	
					
				FilterActive := FilterTimer_0.IN;
				
				FilterTimer_0();
				
				IF MpAxisBasic_Cutter.MoveDone THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
					SensorSignal := FALSE;
				END_IF;
				
				IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
					NumberOfCuts_Sensor := NumberOfCuts_Sensor + 1;
				END_IF;
				
			END_IF;
		
			TotalCutsPerMode := NumberOfCuts_Sensor;
			CutsPerMinute_Sensor := NumberOfCuts_Sensor/CycleTimeSum;
		
		EncoderDieCutter:
		
			MpAxisBasicPar_Cutter.Velocity := DefaultVelocity;
			MpAxisBasicPar_Cutter.Acceleration := DefaultAcceleration;
			MpAxisBasicPar_Cutter.Deceleration := DefaultDeceleration;
	
			
			//Start Encoder Position Reading
			encActPosPerRev;
			
			IF CorrectDistance THEN
				ActualProductLength := HMICuttingLength + (CuttingOffset *-1);
				CorrectionFactor := (HMICuttingLength/ActualProductLength);
				HMICorrectionFactorPercentage := (CorrectionFactor *100) - 100;
				CuttingOffset := 0;
				CorrectDistance := FALSE;
			END_IF;
			
			HMICorrectionFactorMilimeters :=((HMICorrectionFactorPercentage/100) * HMICuttingLength);
			
			IF ClockwiseCount THEN
	  
				IF EDGEPOS(EncoderActPosOld > EncoderActPos) AND ((EncoderActPosOld - EncoderActPos) > (Pulses*0.995)) THEN
					FullTurnCount := FullTurnCount + 1;
				END_IF;
			
				PartOfTurn := (DINT_TO_REAL(EncoderActPos)/Pulses);
				
			ELSE
				
				IF EDGEPOS(EncoderActPos > EncoderActPosOld) AND ((EncoderActPos - EncoderActPosOld) > (Pulses*0.995)) THEN
					FullTurnCount := FullTurnCount + 1;
				END_IF;
				
				PartOfTurn := 1 - (DINT_TO_REAL(EncoderActPos)/Pulses);
				
			END_IF;

			IF PartOfTurn >= (0.99) OR PartOfTurn < 0 THEN
				PartOfTurn := 0;
			END_IF;
			
			
			RealTurns := FullTurnCount + PartOfTurn;
			
			IF Empezar AND cutEnabled THEN
				
				MachineInOperation := TRUE;
				
				CycleTimeSum := CycleTimeSum + CycleTime;
				
				CountTurns;				
				
				IF MpAxisBasic_Cutter.MoveDone THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
				END_IF;
				
				IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
					NumberOfCuts_Distance := NumberOfCuts_Distance + 1;
				END_IF;
				
				RemainingDistance := ((NeededTurns - RealTurns) * EncoderPerimeter);
				TraveledDistance := HMICuttingLength - RemainingDistance;				
				
				HMITraveledDistance := TraveledDistance ;
				HMIRemainingDistance := RemainingDistance;
				
				MC_BR_CyclicProcessParID_AcpAx_0();
				
				IF MpAxisBasic_Cutter.Error THEN
					MpAxisBasic_Cutter.MoveAdditive := FALSE;
					MpAxisBasic_Cutter.ErrorReset := TRUE;
				ELSE
					MpAxisBasic_Cutter.ErrorReset := FALSE;
				END_IF;
				
			END_IF;	
			
			IF NOT Empezar THEN
				
				
				HMITraveledDistance := 0 ;
				HMIRemainingDistance := 0;
				CurrentProductTurns := 0;
				NeededTurns := 0;
				
				MC_BR_CyclicProcessParID_AcpAx_0.Enable := FALSE;
				
			END_IF;	
			
			TotalCutsPerMode := NumberOfCuts_Distance;
		
	END_CASE;	

	//Whenever the operator presses Manual Cut the motor should do a full turn unless there is an active movement
	IF ManualCut AND (MpAxisBasic_Cutter.Info.PLCopenState = AxisStandstill) THEN
		
		MpAxisBasic_Cutter.MoveAdditive := TRUE;
		
		IF MpAxisBasic_Cutter.MoveDone THEN
			MpAxisBasic_Cutter.MoveAdditive := FALSE;
			ManualCut := FALSE;
		END_IF;
		
	END_IF;
	
	//For Visu
	IF Empezar THEN
		
		Count := Count + 0.0016;
		IF CountOld > Count THEN
			MaxCount := CountOld;
		END_IF;
				
		CountOld := Count;
		
	ELSE
		
		MachineInOperation := FALSE;
		MpAxisBasic_Cutter.MoveVelocity := FALSE;
		MpAxisBasic_Cutter.MoveAdditive := FALSE;
		CycleTimeSum := 0;
		MaxCount := 0;
		Count := 0;
		
	END_IF;
	
	//Sum of total cuts
	IF EDGEPOS(MpAxisBasic_Cutter.MoveDone) THEN
		
		Count := 0;
		TotalCuts := TotalCuts + 1;
		
	END_IF;
	
	IF MaxCount = 0 THEN
		ProductionSpeed := 0;
	ELSE
		ProductionSpeed := 60/MaxCount;
	END_IF;
	
	
	TotalCurrentCuts := NumberOfCuts_Time + NumberOfCuts_Sensor + NumberOfCuts_Distance;
	
	IF ResetCutsPerMode THEN
		NumberOfCuts_Time := 0;
		NumberOfCuts_Sensor := 0;
		NumberOfCuts_Distance := 0;
		ResetCutsPerMode := FALSE;
	END_IF;
	
	IF ResetTotalCuts THEN
		
		TotalCuts := 0;
		ResetTotalCuts := FALSE;
		
	END_IF;
	
	
	//Manual Controls
	IF NOT Empezar AND NOT MpAxisBasic_Cutter.MoveActive AND (CurrentPage = 1) THEN
		
		IF ManualMoveAdditivePos THEN
			ManualMoveAdditivePos := FALSE;
			MpAxisBasic_Cutter.MoveAdditive := TRUE;
			MpAxisBasicPar_Cutter.Distance := HMIDistance;
		END_IF;
		
		IF ManualMoveAdditiveNeg THEN
			ManualMoveAdditiveNeg := FALSE;
			MpAxisBasic_Cutter.MoveAdditive := TRUE;
			MpAxisBasicPar_Cutter.Distance := HMIDistance * -1;
		END_IF;
		
		IF ManualMoveAbsolute THEN
			MpAxisBasic_Cutter.MoveAbsolute := TRUE;
			MpAxisBasicPar_Cutter.Position := HomePosition;
			MpAxisBasicPar_Cutter.Direction := 0;
		END_IF;
		
	END_IF;
	
	IF MpAxisBasic_Cutter.MoveDone THEN
			
		ManualMoveAdditivePos := FALSE;
		ManualMoveAdditiveNeg := FALSE;
		ManualMoveAbsolute := FALSE;
		MpAxisBasic_Cutter.MoveAdditive := FALSE;
		MpAxisBasic_Cutter.MoveAbsolute := FALSE;
			
	END_IF;
	
	IF DelayTimer_0.Q THEN
		
		DelayTimer_0.IN := FALSE;
		MpAxisBasic_Cutter.MoveAdditive := TRUE;
		
	END_IF;
	
	IF (CurrentPage = 0) THEN
		
		MpAxisBasicPar_Cutter.Distance := DefaultDistance;
		MpAxisBasicPar_Cutter.Position := DefaultPosition;
		
	END_IF;
	
	IF NOT MpAxisBasic_Cutter.Info.DigitalInputsStatus.DriveEnable THEN
		  
		Empezar := FALSE;
		MpAxisBasic_Cutter.Power := FALSE;
		MpAxisBasic_Cutter.Home := FALSE;
		MpAxisBasic_Cutter.MoveAdditive := FALSE;
		MpAxisBasic_Cutter.MoveAbsolute := FALSE;
		MpAxisBasic_Cutter.MoveVelocity := FALSE;
		ManualMoveAdditivePos := FALSE;
		ManualMoveAdditiveNeg := FALSE;
		ManualMoveAbsolute := FALSE;
		MODE_SELECTED := Default;
			
	ELSE
			
		MpAxisBasic_Cutter.Stop := FALSE;
			
	END_IF;
	
	IF MpAxisBasic_Cutter.Error THEN
		MpAxisBasic_Cutter.ErrorReset := TRUE;
	ELSE
		MpAxisBasic_Cutter.ErrorReset := FALSE;
	END_IF;
	
	IF Empezar THEN
		OperationSignal := OperationSignal + CycleTime;
		IF (OperationSignal >= (CycleTime * 625)) THEN
			IF OperationSignalOut = 1 THEN
				OperationSignalOut := 0;
			ELSE
				OperationSignalOut := 1;
			END_IF;
			OperationSignal := 0;
		END_IF;
	ELSE
		OperationSignalOut := 1;
	END_IF;

	
	IF CycleTimeSum >= MinuteInMiliseconds THEN
		CycleTimeSum := 0;
	END_IF;
	
	//Auxiliar para hacer un primer corte cuando se habilite desde la troqueladora
	IF NOT(cutEnabled) THEN
		auxToCut := TRUE;
	END_IF;
	
	DelayTimer_0();
	MpAxisBasic_Cutter();

	
END_PROGRAM

PROGRAM _EXIT
	
	MpAxisBasic_Cutter.Enable := FALSE;
	MpAxisBasic_Cutter();
	
END_PROGRAM

