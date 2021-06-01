************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: RICHTER-D                                     Datum: 02.06.2020
*
* Beschreibung: Udemy Schulung
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_zeichenartige_dt.

**********************************************************************
* Datendeklaration
**********************************************************************
data: gv_char(10) type c,
      gv_numc(10) type n,
      gv_string   type string.

**********************************************************************
* Variablenbelegung
**********************************************************************
gv_char = 'TestTestTest'.
gv_numc = '12345'.
gv_string = 'Dies ist ein String'.

**********************************************************************
* Ausgabe
**********************************************************************
write: gv_char, /, gv_numc, /, gv_string, /.

**********************************************************************
* Zusammenfügen von Zeichenketten
**********************************************************************
concatenate gv_char gv_numc into gv_string separated by ' '.
write / gv_string.

**********************************************************************
* Suche in Zeichenketten
**********************************************************************
find 'Test' in gv_string.
if sy-subrc = 0.
  write / 'Gefunden!'.
endif.

*search gv_string for '123'. Veraltet!!!

**********************************************************************
* Ersetzen von Zeichen in Zeichenketten
**********************************************************************
replace all occurrences of 'Test' in gv_string with 'Hallo!'.
if sy-subrc = 0.
  write / gv_string.
endif.

**********************************************************************
* Zerlegen von Zeichenketten
**********************************************************************
data: gv_ganzer_name type string value 'Hanz Meyer',
      gv_vorname     type string,
      gv_nachname    type string.

split gv_ganzer_name at ' ' into gv_vorname gv_nachname.
if sy-subrc = 0.
  skip. uline.
  write: 'Vorname: ', gv_vorname, /, 'Nachname:', gv_nachname.
endif.

**********************************************************************
* Verdichten von Zeichenketten
**********************************************************************
data: gv_verdichtung type string value ' Das   ist  ein Verdichtungstest  '.

uline.
write gv_verdichtung.
condense gv_verdichtung no-gaps.
write / gv_verdichtung.

**********************************************************************
* Umwandeln von Zeichenketten
**********************************************************************
translate gv_verdichtung to upper case.
uline.
write gv_verdichtung.

***

**********************************************************************
* Verwendung von Textsymbolen
**********************************************************************
uline.
write text-001.
