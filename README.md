# wattrouterPLC

Implementace funkce "wattrouteru" pro PLC.
Funkční blok je v jazyku ST (IEC 61131-3). Měl by být použitelný pro všechny standardní PLC umožňující programování v jazyce ST, nebo podobném.

Funkční blok kontroluje přetoky elektrického proudu v jednotlivých fázích. Pokud hodnota přetoku překročí nastavenou hodnotu, zvýší výstup pro konkrétní fázi o nastavený krok. Pokud překročí odběr v konkrétní fázi 50 W, je hodnota výkonu snižována. Zvyšování a snižování výkonu probíhá se signálem "edgeSignal". Ten by měl mít délku trvání 1 cyklus PLC za cca 1 sukundu.
Popis jednotlivých vstupů/výstupů je v kódu funkčního bloku.

Blok umožňuje dva režimy řízení HDO/FVE, které se doplňují.

**REŽIM HDO**
- Režim je aktivní, pokud je "signalHdo" true. Signál HDO je však možné simulovat vstupem "hdoSimulation". 
- Režim je možné aktivovat/deaktivovat a nastavit mu časové okno, kdy je aktivní. Okno může být v rámci jednoho dne (např. 17:00 až 18:00), ale i v rámci více dní (např. 20:00 až 04:00).
- Při překročení teploty na vstupu "hdoMaxTemp" se výkon výstupu sníží na 0.
- Maximální výkon nahřívání (v %) je možné oemzit vstupem "hdoMaxPowerLx".
- Krok přidávání/ubírání výkonu je možné nastavit vstupem "hdoPowerStep".
- Režim HDO je možné forsovat signálem hdoForce -  v tomto případě je přihlíženo pouze na teplotu bojleru.

Pokud jsou splněny podmínky startu, stoupá výkon interně až po hodnotu "hdoMaxPowerLx" po krocích "hdoPowerStep".

**REŽIM FVE**
- Režim je možné aktivovat/deaktivovat.
- Při překročení teploty na vstupu "hdoMaxTemp" se výkon výstupu sníží na 0.
- Maximální výkon nahřívání (v %) je možné oemzit vstupem "fveMaxPowerLx".
- Krok přidávání/ubírání výkonu je možné nastavit vstupem "fvePowerStep".
- Nárust výkonu probíhá pouze tehdy, je-li přetok do sítě "currentLxpower" vyšší než "fveMinOverflow". Hodnota "currentLxpower" (typicky signál ze smartmeteru) musí být záporná (=přetok), hodnota "fveMinOverflow" kladná.
- Pokles výkonu probíhá, pokud je odběr ze sítě větší než 50 W (je nutné nastavit v bloku, tato verze nepočítá s uživatelským nastavením).

Pokud jsou splněny podmínky startu, stoupá výkon interně až po hodnotu "fveMaxPowerLx" po krocích "fvePowerStep".


Pokud je aktuální hodnota výkonu ohřevu přes FVE vyšší než 10% je na tuto hodnotu nastaven výstup outputPowerLx.
Jinak je nastaven na větší aktuální hodnota výkonu HDO, nebo FVE. Tato část ještě možná bude vyžadovat optimalizaci!

Jestliže výkon ohřevu dostáhl maximálního výkonu podle proměnné "hdoMaxPowerLx", nebo "fveMaxPowerLx" (podle druhu regulace), je nastavena proměnná "LxFullPower" na true.
