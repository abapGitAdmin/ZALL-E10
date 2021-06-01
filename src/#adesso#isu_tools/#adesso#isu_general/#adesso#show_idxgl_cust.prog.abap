***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: THIMEL-R                                                                Datum: 01.11.2019
*
* Beschreibung: IDXGL Customizing anzeigen
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
REPORT /ADESSO/SHOW_IDXGL_CUST.

CALL FUNCTION 'STREE_EXTERNAL_DISPLAY'
  EXPORTING
    structure_id      = '005056B69B591ED6B9D9C72A3DD1C66E'
    language          = sy-langu
    display_structure = 'X'.
