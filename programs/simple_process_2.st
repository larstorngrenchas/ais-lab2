PROGRAM SimpleProcess
  VAR_EXTERNAL
    Tank_Level : INT;
    Pump_On : BOOL;
    Valve_Open : BOOL;
    Setpoint : INT;    (* Nu extern *)
    High_Alarm : INT;  (* Nu extern *)
  END_VAR
  VAR
    Low_Alarm : INT := 200; (* Denna kan vara kvar lokalt om du inte vill styra den *)
  END_VAR

  IF Tank_Level < Setpoint THEN
    Pump_On := TRUE;
    Valve_Open := FALSE;
  ELSIF Tank_Level > High_Alarm THEN
    Pump_On := FALSE;
    Valve_Open := TRUE;
  ELSE
    Pump_On := FALSE;
    Valve_Open := FALSE;
  END_IF;
END_PROGRAM

CONFIGURATION Config0
  VAR_GLOBAL
    Tank_Level AT %MW0 : INT;   (* ScadaBR Offset 1024 *)
    Setpoint AT %MW1 : INT;     (* ScadaBR Offset 1025 *)
    High_Alarm AT %MW2 : INT;   (* ScadaBR Offset 1026 *)
    Pump_On AT %QX0.0 : BOOL;   (* ScadaBR Coil Offset 0 *)
    Valve_Open AT %QX0.1 : BOOL; (* ScadaBR Coil Offset 1 *)
  END_VAR

  RESOURCE Res0 ON PLC
    TASK TaskMain(INTERVAL := T#50ms, PRIORITY := 0);
    PROGRAM Inst0 WITH TaskMain : SimpleProcess;
  END_RESOURCE
END_CONFIGURATION