//v20230810
FUNCTION_BLOCK SolarHeating
   VAR_INPUT
     //funkce HDO - displej
     hdoActive        : bool;   //ohrev pri HDO aktivni
     hdoSimulation    : bool;   //simulace HDO signalu
     hdoForce         : bool;   //spusteni nuceneho ohrevu
     hdoOnTime        : time;   //cas od kdy je ohrev aktivni (hh:mm)
     hdoOffTime       : time;   //cas do kdy je ahrev aktivni (hh:mm)
     hdoMaxTemp       : real;   //maximalni teplota ohrevu pro HDO (0 - 95)
     hdoPowerStep     : real;   //vykonovy skok za 1 s v % (0.1 - 100)
     hdoMaxPowerL1    : real;   //maximalni vykon ohrevu pro HDO v % L1 (0 - 100)
     hdoMaxPowerL2    : real;   //maximalni vykon ohrevu pro HDO v % L2 (0 - 100)
     hdoMaxPowerL3    : real;   //maximalni vykon ohrevu pro HDO v % L3 (0 - 100)

     //funkce FVE - displej
     fveActive        : bool;   //ohrev pretoky z FVE aktivní
     fveMaxTemp       : real;   //maximalni teplota ohrevu pro FVE (0 - 95)
     fveMaxPowerL1    : real;   //maximalni vykon ohrevu pro FVE v % L1 (0 - 100)
     fveMaxPowerL2    : real;   //maximalni vykon ohrevu pro FVE v % L2 (0 - 100)
     fveMaxPowerL3    : real;   //maximalni vykon ohrevu pro FVE v % L3 (0 - 100)
     fvePowerStep     : real;   //vykonovy skok za 1 s v % (0.1 - 100)
     fveMinOverflow   : real;   //minimalni hodnota pretoku, pri kterem je zvysovan vykon ohrevu (napr. 100 W = pretok)
     fveMaxConsumption: real;   //minimalni hodnota odberu, pri kterem je snizovan vykon ohrevu (napr. 100 W = odber)

     //Spolecne promenne
     currentTime            : time;   //aktualni cas (hh:mm)
     currentL1power         : real;   //aktualni vykon L1 (- = pretok, + = odber) W
     currentL2power         : real;   //aktualni vykon L2 (- = pretok, + = odber) W
     currentL3power         : real;   //aktualni vykon L3 (- = pretok, + = odber) W
     signalHdo              : bool;   //signal HDO
     tempNadrz              : real;   //aktualni teplota nadrze
     thermostatHyst         : real := 2.0;  //zaporna hystereze termsostatu
     edgeSignal             : bool;   //signal hrany pro zvysovani/snizovani vykonu (aktivni pouze jeden cyklus kazdou sekundu)
  END_VAR
  VAR_OUTPUT
      outputPowerL1          : real;   //aktualni vykon topne spiraly L1 %
      outputPowerL2          : real;   //aktualni vykon topne spiraly L2 %
      outputPowerL3          : real;   //aktualni vykon topne spiraly L3 %
      
      L1FullPower            : bool;  //vystup L1 na plny vykon
      L2FullPower            : bool;  //vystup L1 na plny vykon
      L3FullPower            : bool;  //vystup L1 na plny vykon
  END_VAR
  VAR_IN_OUT
  END_VAR
  VAR
    timeWindowHdo           : bool;   //okno signalu HDO
    thermostatHdo           : bool;   //termostat pro HDO
    thermostatFve           : bool;   //termostat pro FVE

    hdoL1AtFullPower        : bool;   //L1 HDO na plny vykon
    hdoL2AtFullPower        : bool;   //L1 HDO na plny vykon
    hdoL3AtFullPower        : bool;   //L1 HDO na plny vykon
    fveL1AtFullPower        : bool;   //L1 FVE na plny vykon
    fveL2AtFullPower        : bool;   //L1 FVE na plny vykon
    fveL3AtFullPower        : bool;   //L1 FVE na plny vykon
    
    outputPowerHdoL1        : real;   //pozadavek vykonu pri nahrivani pres HDO L1
    outputPowerHdoL2        : real;   //pozadavek vykonu pri nahrivani pres HDO L2
    outputPowerHdoL3        : real;   //pozadavek vykonu pri nahrivani pres HDO L3
    outputPowerFveL1        : real;   //pozadavek vykonu pri nahrovani pres FVE L1
    outputPowerFveL2        : real;   //pozadavek vykonu pri nahrovani pres FVE L2
    outputPowerFveL3        : real;   //pozadavek vykonu pri nahrovani pres FVE L3
  END_VAR
  VAR_TEMP
  END_VAR
  
  //Limity promennych
  //hdoMaxTemp
  IF(hdoMaxTemp < 0.0) THEN
    hdoMaxTemp := 0.0;
  END_IF;
  
  IF(hdoMaxTemp > 95.0) THEN
    hdoMaxTemp := 95.0;
  END_IF;
  
  //fveMaxTemp
  IF(fveMaxTemp < 0.0) THEN
    fveMaxTemp := 0.0;
  END_IF;

  IF(fveMaxTemp > 95.0) THEN
    fveMaxTemp := 95.0;
  END_IF;
  
  //hdoPowerStep
  IF(hdoPowerStep < 0.1) THEN
    hdoPowerStep := 0.1;
  END_IF;

  IF(hdoPowerStep > 100.0) THEN
    hdoPowerStep := 100.0;
  END_IF;
  
  //fvePowerStep
  IF(fvePowerStep < 0.1) THEN
    fvePowerStep := 0.1;
  END_IF;

  IF(fvePowerStep > 100.0) THEN
    fvePowerStep := 100.0;
  END_IF;
  
  //hdoMaxPowerL1
  IF(hdoMaxPowerL1 < 0.0) THEN
    hdoMaxPowerL1 := 0.0;
  END_IF;

  IF(hdoMaxPowerL1 > 100.0) THEN
    hdoMaxPowerL1 := 100.0;
  END_IF;
  
  //hdoMaxPowerL2
  IF(hdoMaxPowerL2 < 0.0) THEN
    hdoMaxPowerL2 := 0.0;
  END_IF;

  IF(hdoMaxPowerL2 > 100.0) THEN
    hdoMaxPowerL2 := 100.0;
  END_IF;
  
  //hdoMaxPowerL3
  IF(hdoMaxPowerL3 < 0.0) THEN
    hdoMaxPowerL3 := 0.0;
  END_IF;

  IF(hdoMaxPowerL3 > 100.0) THEN
    hdoMaxPowerL3 := 100.0;
  END_IF;
  
  //fveMaxPowerL1
  IF(fveMaxPowerL1 < 0.0) THEN
    fveMaxPowerL1 := 0.0;
  END_IF;

  IF(fveMaxPowerL1 > 100.0) THEN
    fveMaxPowerL1 := 100.0;
  END_IF;

  //fveMaxPowerL2
  IF(fveMaxPowerL2 < 0.0) THEN
    fveMaxPowerL2 := 0.0;
  END_IF;

  IF(fveMaxPowerL2 > 100.0) THEN
    fveMaxPowerL2 := 100.0;
  END_IF;

  //fveMaxPowerL3
  IF(fveMaxPowerL3 < 0.0) THEN
    fveMaxPowerL3 := 0.0;
  END_IF;

  IF(fveMaxPowerL3 > 100.0) THEN
    fveMaxPowerL3 := 100.0;
  END_IF;



  //Casove okno HDO
  IF(hdoOnTime < hdoOffTime) THEN
    //okno v ramci jednoho dne
    IF((currentTime >= hdoOnTime) AND (currentTime < hdoOffTime)) THEN
      timeWindowHdo := true;
      ELSE
      timeWindowHdo := false;
    END_IF;
  ELSE
    //okno v ramci vice dni
    //konec je drive nez zacatek
    IF((currentTime >= hdoOnTime) OR (currentTime < hdoOffTime)) THEN
      timeWindowHdo := true;
      ELSE
      timeWindowHdo := false;
    END_IF;
  END_IF;

  //termostat HDO
  //zadana maximalni teplota je vypinaci teplota
  //hystereze je pouze zaporna, pri poklesu teploty pod uroven (maxTemp - thermostatHyst) se termostat sepne
  //maxTemp = 50,  thermostatHyst = 2
  //pri prekroceni 50 stupnu ohrev vypne, pri poklesu pod 48 stupnu ohrev zapne
  thermostatHyst := ABS(thermostatHyst);
  IF(tempNadrz >= hdoMaxTemp) THEN
    //bojler nahraty
    thermostatHdo := false;
  END_IF;
  IF(tempNadrz <= hdoMaxTemp - thermostatHyst) THEN
    thermostatHdo := true;
  END_IF;

  //termostat FVE
  IF(tempNadrz >= fveMaxTemp) THEN
    //bojler nahraty
    thermostatFve := false;
  END_IF;
  IF(tempNadrz <= fveMaxTemp - thermostatHyst) THEN
    thermostatFve := true;
  END_IF;


  //
  //
  // OHREV NADRZE PRES HDO
  //
  //
  IF (edgeSignal) THEN
    IF((hdoForce AND thermostatHdo) OR (hdoActive AND (signalHdo OR hdoSimulation) AND timeWindowHdo AND thermostatHdo)) THEN
      //simulace natapeni NEBO

      //ohrev pres HDO aktivni
      //je signal HDO, nebo simulace HDO
      //je zaroven aktivni okno pro signal HDO
      //je pozadavek na nahrivani od teploty
      outputPowerHdoL1 := outputPowerHdoL1 + hdoPowerStep;
      outputPowerHdoL2 := outputPowerHdoL2 + hdoPowerStep;
      outputPowerHdoL3 := outputPowerHdoL3 + hdoPowerStep;
    ELSE
      outputPowerHdoL1 := outputPowerHdoL1 - hdoPowerStep;
      outputPowerHdoL2 := outputPowerHdoL2 - hdoPowerStep;
      outputPowerHdoL3 := outputPowerHdoL3 - hdoPowerStep;
    END_IF;
  END_IF;

  //omezeni vykonu
  IF(outputPowerHdoL1 > hdoMaxPowerL1) THEN
    outputPowerHdoL1 := hdoMaxPowerL1;
    hdoL1AtFullPower := TRUE;
  ELSE
    hdoL1AtFullPower := FALSE;
  END_IF;

  IF(outputPowerHdoL2 > hdoMaxPowerL2) THEN
    outputPowerHdoL2 := hdoMaxPowerL2;
    hdoL2AtFullPower := TRUE;
  ELSE
    hdoL2AtFullPower := FALSE;
  END_IF;

  IF(outputPowerHdoL3 > hdoMaxPowerL3) THEN
    outputPowerHdoL3 := hdoMaxPowerL3;
    hdoL3AtFullPower := TRUE;
  ELSE
    hdoL3AtFullPower := FALSE;
  END_IF;

  //ochrana proti zapornemu vykonu
  IF(outputPowerHdoL1 < 0.0) THEN
    outputPowerHdoL1 := 0.0;
  END_IF;

  IF(outputPowerHdoL2 < 0.0) THEN
    outputPowerHdoL2 := 0.0;
  END_IF;

  IF(outputPowerHdoL3 < 0.0) THEN
    outputPowerHdoL3 := 0.0;
  END_IF;


  //
  //
  // OHREV BOJLERU PRES FVE
  //
  //
  fveMinOverflow := ABS(fveMinOverflow) * -1.0;   //uprava hodnoty na zaporny vykon
  //je nutne, aby pretok do site měl zapornou hodnotu
  IF(edgeSignal) THEN
  //cyklovani po 1 s
    IF(fveActive AND thermostatFve) THEN
      //ohrev pres FVE aktivni a pozadavek od teploty
      //rezim regulace
      IF(currentL1power <= fveMinOverflow) THEN
        //pretok vetsi nez minimum
        //zvysovat vykon
        outputPowerFveL1 := outputPowerFveL1 + fvePowerStep;
      END_IF;

      IF(currentL2power <= fveMinOverflow) THEN
        //pretok vetsi nez minimum
        //zvysovat vykon
        outputPowerFveL2 := outputPowerFveL2 + fvePowerStep;
      END_IF;

      IF(currentL3power <= fveMinOverflow) THEN
        //pretok vetsi nez minimum
        //zvysovat vykon
        outputPowerFveL3 := outputPowerFveL3 + fvePowerStep;
      END_IF;

      IF(currentL1power >= fveMaxConsumption) THEN
        //odber ze site vetsi nez 50 W
        outputPowerFveL1 := outputPowerFveL1 - fvePowerStep;
      END_IF;

      IF(currentL2power >= fveMaxConsumption) THEN
        //odber ze site vetsi nez 50 W
        outputPowerFveL2 := outputPowerFveL2 - fvePowerStep;
      END_IF;

      IF(currentL3power >= fveMaxConsumption) THEN
        //odber ze site vetsi nez 50 W
        outputPowerFveL3 := outputPowerFveL3 - fvePowerStep;
      END_IF;
    ELSE
      //ohrev neni aktivni, snizit vykon na 0%
      outputPowerFveL1 := outputPowerFveL1 - fvePowerStep;
      outputPowerFveL2 := outputPowerFveL2 - fvePowerStep;
      outputPowerFveL3 := outputPowerFveL3 - fvePowerStep;
    END_IF;
  END_IF;

  //omezeni vykonu
  IF(outputPowerFveL1 >= fveMaxPowerL1) THEN
    outputPowerFveL1 := fveMaxPowerL1;
    fveL1AtFullPower := TRUE;
  ELSE
    fveL1AtFullPower := FALSE;
  END_IF;

  IF(outputPowerFveL2 >= fveMaxPowerL2) THEN
    outputPowerFveL2 := fveMaxPowerL2;
    fveL2AtFullPower := TRUE;
  ELSE
    fveL2AtFullPower := FALSE;
  END_IF;

  IF(outputPowerFveL3 >= fveMaxPowerL3) THEN
    outputPowerFveL3 := fveMaxPowerL3;
    fveL3AtFullPower := TRUE;
  ELSE
    fveL3AtFullPower := FALSE;
  END_IF;

  //ochrana proti zapornemu vykonu
  IF(outputPowerFveL1 < 0.0) THEN
    outputPowerFveL1 := 0.0;
  END_IF;

  IF(outputPowerFveL2 < 0.0) THEN
    outputPowerFveL2 := 0.0;
  END_IF;

  IF(outputPowerFveL3 < 0.0) THEN
    outputPowerFveL3 := 0.0;
  END_IF;


  //
  //
  // RIZENI PRIORITY ZDROJE
  //
  //
  //priorita vyssiho vykonu
  IF(outputPowerFveL1 > outputPowerHdoL1) THEN
    outputPowerL1 :=  outputPowerFveL1;
    L1FullPower := fveL1AtFullPower;
  ELSE
    outputPowerL1 :=  outputPowerHdoL1;
    L1FullPower := hdoL1AtFullPower;
  END_IF;

  IF(outputPowerFveL2 > outputPowerHdoL2) THEN
    outputPowerL2 :=  outputPowerFveL2;
    L2FullPower := fveL2AtFullPower;
  ELSE
    outputPowerL2 :=  outputPowerHdoL2;
    L2FullPower := hdoL2AtFullPower;
  END_IF;

  IF(outputPowerFveL3 > outputPowerHdoL3) THEN
    outputPowerL3 :=  outputPowerFveL3;
    L3FullPower := fveL3AtFullPower;
  ELSE
    outputPowerL3 :=  outputPowerHdoL3;
    L3FullPower := hdoL3AtFullPower;
  END_IF;


  //pokud je vykon nahrivani pres FVE >= 10 %
  //nastavit prioritne na napajeni pres FVE
  IF(outputPowerFveL1 >= 10.0) THEN
    outputPowerL1 :=  outputPowerFveL1;
    L1FullPower := fveL1AtFullPower;
  END_IF;

  IF(outputPowerFveL2 >= 10.0) THEN
    outputPowerL2 :=  outputPowerFveL2;
    L2FullPower := fveL2AtFullPower;
  END_IF;

  IF(outputPowerFveL1 >= 10.0) THEN
    outputPowerL3 :=  outputPowerFveL3;
    L3FullPower := fveL3AtFullPower;
  END_IF;
  
  
  //ochrana proti prehrati
  //pri ohrati 1 stupen nad maximalni teplotu zablokovat vystupy
  IF (hdoMaxTemp >= fveMaxTemp) THEN
    //vyssi teplota HDO
    IF(tempNadrz > hdoMaxTemp + 1.0) THEN
      outputPowerL1 := 0.0;
      outputPowerL2 := 0.0;
      outputPowerL3 := 0.0;
    END_IF;
  ELSE
    //vyssi teplota FVE
    IF(tempNadrz > fveMaxTemp + 1.0) THEN
      outputPowerL1 := 0.0;
      outputPowerL2 := 0.0;
      outputPowerL3 := 0.0;
    END_IF;
  END_IF;


END_FUNCTION_BLOCK
