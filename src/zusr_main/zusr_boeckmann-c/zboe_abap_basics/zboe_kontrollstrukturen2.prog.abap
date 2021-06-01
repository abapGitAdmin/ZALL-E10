************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 15.05.2019
*
* Beschreibung: Kontrollstrukturen
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_kontrollstrukturen2. "Verarbeitungsblock 1 = Hauptprogramm

PARAMETERS: p_name TYPE string,
            p_alter TYPE i.

DATA: lv_i TYPE i.

WRITE p_name.

**********************************************************************
* IF-Abfrage
**********************************************************************
IF p_alter >= 6 AND p_alter < 20. "Weiterer Verarbeitungsblock 1.1 = IF Verzweigung
  WRITE / 'Schüler'.
ELSEIF p_alter <= 25 OR p_name = 'Kevin'.
    WRITE / 'Student'.
ELSE.
    WRITE / 'Mitarbeiter'.
ENDIF.

**********************************************************************
* Verzweigungen
**********************************************************************
CASE p_alter.
  WHEN 6.
    WRITE / 'Alter ist 6 Jahre!'.
  WHEN 7 OR 8.
    WRITE / 'Alter ist 7 oder 8 Jahre!'.
  WHEN OTHERS.
    WRITE / 'Alter weder 6 noch 7 oder 8 Jahre!'.
ENDCASE.

**********************************************************************
* Schleifen
**********************************************************************
DO 5 TIMES. " Verarbeitungsblock 1.3 = DO Schleife
*  IF lv_i > 100.
*    CONTINUE.
*  ENDIF.
  CHECK lv_i <= 100. "CHECK wie IF Abfrage darüber
  lv_i = lv_i + p_alter.
ENDDO.

WRITE: /, 'Ergebnis der Addition: ', lv_i.

**********************************************************************
* WHILE Schleife
**********************************************************************

WHILE lv_i > 50.
  lv_i = lv_i - 1.
ENDWHILE.
