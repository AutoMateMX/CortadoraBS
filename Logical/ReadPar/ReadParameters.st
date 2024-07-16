(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: ReadParameters
 * File: ReadParameters.st
 * Author: murguiaj
 * Created: March 08, 2013
 ********************************************************************
 * Implementation of program ReadParameters
 ********************************************************************)

PROGRAM _INIT


(* TODO : Add your code here *)


END_PROGRAM


PROGRAM _CYCLIC

	MC_BR_CyclicProcessParID_AcpAx_0.Enable := EnablePar;
	MC_BR_CyclicProcessParID_AcpAx_0.Axis := ADR(Cutter);
	MC_BR_CyclicProcessParID_AcpAx_0.DataAddress := ADR(McAcpAxCycParID_0);
	MC_BR_CyclicProcessParID_AcpAx_0.Mode := ParIdAccessMode;//mcACPAX_CYCLIC_PARID_READ;
	MC_BR_CyclicProcessParID_AcpAx_0.NumberOfParIDs := 1;
	
	McAcpAxCycParID_0.DataType:= ParIdDataType;
	McAcpAxCycParID_0.ParID := motorTempParID; //381;
	McAcpAxCycParID_0.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
	McAcpAxCycParID_0.VariableAddress := ADR(motorTemp);
	
	MC_BR_CyclicProcessParID_AcpAx_1.Enable := TRUE;
	MC_BR_CyclicProcessParID_AcpAx_1.Axis := ADR(Cutter);
	MC_BR_CyclicProcessParID_AcpAx_1.DataAddress := ADR(McAcpAxCycParID_1);;
	MC_BR_CyclicProcessParID_AcpAx_1.NumberOfParIDs := 1;
	MC_BR_CyclicProcessParID_AcpAx_1.Mode := mcACPAX_CYCLIC_PARID_READ;
	
	McAcpAxCycParID_1.DataType:= ParIdDataType;
	McAcpAxCycParID_1.ParID := 377;
	McAcpAxCycParID_1.RefreshMode := mcACPAX_CYCLIC_EVERY_RECORD;
	McAcpAxCycParID_1.VariableAddress := ADR(cargaAcopos);

	MC_BR_CyclicProcessParID_AcpAx_0();
	MC_BR_CyclicProcessParID_AcpAx_1();
	
END_PROGRAM
