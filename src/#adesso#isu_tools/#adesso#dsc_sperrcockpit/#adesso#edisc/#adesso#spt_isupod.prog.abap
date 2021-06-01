*****           Implementation of object type /ADESSO/PO           *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      POINTOFDELIVERY LIKE EUIHEAD-INT_UI,
  END OF KEY,
      _EGRIDH LIKE EGRIDH.
END_DATA OBJECT. " Do not change.. DATA is generated

BEGIN_METHOD ZEAPODDATA CHANGING CONTAINER.
DATA:
  keydate           TYPE syst-datum,
  ext_ui            TYPE euitrans-ext_ui,
  vertrag           TYPE ever-vertrag,
  regiogroup        TYPE ever-regiogroup,
  aklasse           TYPE eanlh-aklasse,
  h_contract        TYPE swc_object,
  h_contractaccount TYPE swc_object.
*
*
swc_get_element container 'EXT_UI' ext_ui.
swc_get_element container 'Datum' keydate.

CALL FUNCTION '/ADESSO/EA_POD_DATA'
  EXPORTING
    i_keydatum = keydate
    i_ext_ui   = ext_ui
  IMPORTING
    e_vertrag  = vertrag
    e_aklasse  = aklasse
  EXCEPTIONS
    OTHERS     = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
* SELECT SINGLE regiogroup INTO regiogroup FROM ever
*   WHERE vertrag = vertrag.
swc_create_object h_contract 'ISUCONTRCT' vertrag.
swc_get_property h_contract 'ContractAccount' h_contractaccount.
swc_get_property h_contractaccount 'BusinessRegiogroup' regiogroup.

swc_set_element container 'RegioGroup' regiogroup.
swc_set_element container 'Abrechnungsklasse' aklasse.

END_METHOD.

TABLES EGRIDH.
*
GET_TABLE_PROPERTY EGRIDH.
DATA SUBRC LIKE SY-SUBRC.
* Fill TABLES EGRIDH to enable Object Manager Access to Table Properties
  PERFORM SELECT_TABLE_EGRIDH USING SUBRC.
  IF SUBRC NE 0.
    EXIT_OBJECT_NOT_FOUND.
  ENDIF.
END_PROPERTY.
*
* Use Form also for other(virtual) Properties to fill TABLES EGRIDH
FORM SELECT_TABLE_EGRIDH USING SUBRC LIKE SY-SUBRC.
* Select single * from EGRIDH, if OBJECT-_EGRIDH is initial
  IF OBJECT-_EGRIDH-MANDT IS INITIAL
  AND OBJECT-_EGRIDH-GRID_ID IS INITIAL
  AND OBJECT-_EGRIDH-BIS IS INITIAL.

Select single * into corresponding fields of egridh from egridh
inner join euigrid
on egridh~grid_id = euigrid~grid_id
where datefrom  <= sy-datum
and   dateto    >= sy-datum
and   ab        <= sy-datum
and   bis       >= sy-datum
and   INT_UI    = OBJECT-key.

    SUBRC = SY-SUBRC.
    IF SUBRC NE 0. EXIT. ENDIF.
    OBJECT-_EGRIDH = EGRIDH.
  ELSE.
    SUBRC = 0.
    EGRIDH = OBJECT-_EGRIDH.
  ENDIF.
ENDFORM.
