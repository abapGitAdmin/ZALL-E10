************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 20.05.2019
*
* Beschreibung: Datenbanken / OpenSQL
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
REPORT zboe_datenbanken.

DATA: gt_spfli TYPE TABLE OF spfli,
      gs_spfli TYPE spfli.

*SELECT SINGLE * FROM spfli INTO gs_spfli WHERE carrid = 'LH'.
SELECT * FROM spfli INTO TABLE gt_spfli WHERE carrid = 'LH'.

IF sy-subrc <> 0.
  WRITE: 'Fehler beim Lesen des Datensatzes!'.
ELSE.
  LOOP AT gt_spfli INTO gs_spfli.
    WRITE: gs_spfli-carrid, gs_spfli-connid, /.
  ENDLOOP.
ENDIF.
