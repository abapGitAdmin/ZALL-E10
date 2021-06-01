************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
* INIT         appel-h  24.02.2020
* EDIT         kasdorf-l
************************************************************************
*******
REPORT /adz/dcm_update_fkkvkp.
TABLES fkkvkp.

" Selektionsparameter
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS s_vkont FOR fkkvkp-vkont.
PARAMETERS     p_kofiz TYPE fkkvkp-kofiz_sd.
select-OPTIONS p_gsberc FOR fkkvkp-gsber  DEFAULT ' ' OPTION EQ SIGN I no INTERVALS.
SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK upval WITH FRAME TITLE TEXT-002.
PARAMETERS p_newgsb TYPE fkkvkp-gsber.
SELECTION-SCREEN END OF BLOCK upval.

SELECTION-SCREEN BEGIN OF BLOCK tech WITH FRAME TITLE TEXT-003.
PARAMETERS p_selsiz TYPE integer DEFAULT 200000.
PARAMETERS p_updsiz TYPE integer DEFAULT 5000.
PARAMETERS p_test   AS CHECKBOX  DEFAULT 'X'.
PARAMETERS  p_v1str   RADIOBUTTON GROUP aaw.
PARAMETERS  p_v2sin   RADIOBUTTON GROUP aaw.
SELECTION-SCREEN END OF BLOCK tech.

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  DATA lt_fkkvkp     TYPE SORTED TABLE OF fkkvkp WITH UNIQUE KEY vkont gpart.
  DATA lt_upd_fkkvkp TYPE SORTED TABLE OF fkkvkp WITH UNIQUE KEY vkont gpart.
  DATA lv_ctr        TYPE integer.
  DATA lv_all_upd_ctr TYPE integer.
  lt_fkkvkp = VALUE #( ( vkont = '1' gpart = '1'  ) ).



  WHILE lt_fkkvkp IS NOT INITIAL.
    " Quelle in Paketen lesen
    SELECT * FROM fkkvkp INTO TABLE lt_fkkvkp UP TO p_selsiz ROWS
    WHERE vkont IN s_vkont
      AND kofiz_sd EQ p_kofiz
      AND gsber    EQ p_gsberc.

    " Neuen Wert setzen
    " und in Pakten updaten
    DATA(lv_anz_rows) = lines( lt_fkkvkp ).
    lv_ctr = 0.
    LOOP AT lt_fkkvkp ASSIGNING FIELD-SYMBOL(<ls_fkkvkp>).
      <ls_fkkvkp>-gsber = p_newgsb.
      INSERT <ls_fkkvkp> INTO TABLE lt_upd_fkkvkp.

      lv_ctr = lv_ctr + 1.
      " Update Paket voll oder letzte Zeile im Paket
      IF lines( lt_upd_fkkvkp ) >= p_updsiz OR  ( lv_ctr = lv_anz_rows ).
        IF p_test EQ abap_false.
          IF p_v1str EQ abap_true.
            " Variante 1.
            UPDATE fkkvkp FROM TABLE lt_upd_fkkvkp.
          ELSEIF p_v2sin EQ abap_true.
            " Variante 2.
            LOOP AT lt_upd_fkkvkp ASSIGNING FIELD-SYMBOL(<ls_upd_fkkvkp>).
              UPDATE fkkvkp SET gsber = p_newgsb WHERE vkont = <ls_upd_fkkvkp>-vkont AND gpart = <ls_upd_fkkvkp>-gpart.
            ENDLOOP.
          ENDIF.
          COMMIT WORK.
        ENDIF.
        lv_all_upd_ctr = lv_all_upd_ctr + lines( lt_upd_fkkvkp ).
        CLEAR lt_upd_fkkvkp.
      ENDIF.

    ENDLOOP.

  ENDWHILE.

  DATA(lv_action) = COND string( WHEN p_test = 'X' THEN 'selected' ELSE 'updated' ).
  WRITE : / lv_all_upd_ctr, 'rows', lv_action.
