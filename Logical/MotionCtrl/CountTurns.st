
ACTION CountTurns: 
	
	
	CalculatedProductSpeed := (((HMICuttingLength/1000)*60)/MaxCount);
	

	

	
	IF (RealTurns ) >= (NeededTurns)  OR ManualCut OR EDGEPOS(oneCutEncoderCutterDieCmd) THEN
		ManualCut 		:= FALSE;
		auxToCut		:= FALSE;
		//DelayTimer_0.IN := TRUE;
		MpAxisBasic_Cutter.MoveAdditive := TRUE;
		RelativeDistance	:=	((((HMICuttingLength/EncoderPerimeter)*Pulses)*CorrectionFactor) + ((CuttingOffset/EncoderPerimeter)*Pulses));
		NeededTurns := (RelativeDistance/Pulses) + RealTurns;
		CurrentProductTurns := 0;
		HMIRelativeDistanceOld := HMIRelativeDistance;
		HMIRelativeDistance	:=	((EncoderActPos) + ((HMICuttingLength/EncoderPerimeter)*Pulses));
		
	ELSE
		
		CurrentProductTurns := FullTurnCount + PartOfTurn;
	END_IF;
	
	
	EncoderActPosOld := EncoderActPos;
	
END_ACTION
