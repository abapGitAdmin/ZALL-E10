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
* Beschreibung:Flugprogramm
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
REPORT zboe_flugprogramm.

DATA: ls_flug   TYPE spfli,
      it_fluege TYPE TABLE OF spfli.

PARAMETERS: p_ges TYPE spfli-carrid.

CALL FUNCTION 'Z_BOE_GET_FLUEGE_FUBA'
  EXPORTING
    iv_carrid = p_ges
  IMPORTING
    et_fluege  = it_fluege.

LOOP AT it_fluege INTO ls_flug.
  WRITE: ls_flug-connid, ls_flug-cityfrom, ls_flug-countryfr, ls_flug-cityto, ls_flug-countryto, /.
ENDLOOP.
