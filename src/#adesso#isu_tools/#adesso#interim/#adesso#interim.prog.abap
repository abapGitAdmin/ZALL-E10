*&---------------------------------------------------------------------*
*& Report  /ADESSO/INTERIM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/interim.

DATA: wa_eanl          TYPE eanl,
      wa_eanl_neu      TYPE eanl,
      wa_eanlh         TYPE eanlh,
      it_eanlh         TYPE STANDARD TABLE OF eanlh,
      wa_eanlh_neu     TYPE eanlh,
      it_eanlh_neu     TYPE STANDARD TABLE OF eanlh,
      it_eanlh_old     TYPE STANDARD TABLE OF eanlh,
      gt_eanl          TYPE TABLE OF v_eanl,
      gd_anlorg        TYPE anlage,
      gd_anlneu        TYPE anlage,
      db_update        TYPE c,
      gs_eanl          TYPE v_eanl,
      gy_eastl         TYPE eastl,
      gt_eastl         TYPE STANDARD TABLE OF eastl,
      gs_eastl         TYPE eastl,
      gy_easts         TYPE easts,
      gt_easts         TYPE STANDARD TABLE OF      easts,
      gs_easts         TYPE easts,
      gd_objorg        TYPE elpass-objkey,
      gd_objneu        TYPE elpass-objkey,
      gt_ielpass       TYPE isulp_ielpass,
      gt_ieufass       TYPE isulp_ieufass,
      gs_elpass_neu    TYPE elpass,
      gt_elpass_neu    TYPE STANDARD TABLE OF elpass,
      gs_eufass_neu    TYPE eufass,
      gt_eufass_neu    TYPE STANDARD TABLE OF eufass,
      gt_euitrans      TYPE STANDARD TABLE OF euitrans,
      gs_euitrans      TYPE euitrans,
      gt_euigrid       TYPE STANDARD TABLE OF euigrid,
      gs_euigrid       TYPE euigrid,
      gt_euiinstln_neu TYPE STANDARD TABLE OF euiinstln,
      gs_euiinstln_neu TYPE euiinstln,
      gs_euitrans_neu  TYPE euitrans,
      gt_euitrans_neu  TYPE STANDARD TABLE OF euitrans,
      gt_euigrid_neu   TYPE STANDARD TABLE OF euigrid,
      gs_euigrid_neu   TYPE euigrid.


DATA: gs_obj  TYPE isu01_instln,
      gs_auto TYPE isu01_instln_auto.

DATA: BEGIN OF wa_out,
        anlorg        TYPE anlage,
        extui_org_alt TYPE ext_ui,
        extui_org_neu TYPE ext_ui,
        anlneu        TYPE anlage,
        extui_neu     TYPE ext_ui,
      END OF wa_out.
DATA: it_out LIKE STANDARD TABLE OF wa_out.


SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
PARAMETERS: p_anl TYPE eanl-anlage.
SELECTION-SCREEN END OF BLOCK bl1.


***************************************************************************
* START-OF-SELECTION
***************************************************************************
START-OF-SELECTION.

  MOVE p_anl TO gd_anlorg.

  SELECT * FROM eanlh INTO TABLE it_eanlh WHERE anlage = gd_anlorg.

  PERFORM neue_anlage  TABLES it_eanlh
                              it_eanlh_neu
                        USING gd_anlorg
                        CHANGING gd_anlneu
                                 wa_eanl_neu
                                 wa_out.

************************************************************************
* Profile Kopieren
************************************************************************
  MOVE gd_anlorg TO gd_objorg.
  MOVE gd_anlneu TO gd_objneu.

  CALL FUNCTION 'ISU_DB_ELPASS_SELECT'
    EXPORTING
      x_objkey  = gd_objorg
      x_objtype = 'INSTLN'
*     X_LOGLPRELNO       =
*     X_AB      = CO_DATE_FINITE
*     X_BIS     = CO_DATE_INFINITE
*     X_ACTUAL  = ' '
    IMPORTING
      y_ielpass = gt_ielpass
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'ISU_DB_EUFASS_SELECT'
    EXPORTING
      x_objkey  = gd_objorg
      x_objtype = 'INSTLN'
*     X_LOGLPRELNO       =
*     X_AB      = CO_DATE_FINITE
*     X_BIS     = CO_DATE_INFINITE
*     X_ACTUAL  = ' '
    IMPORTING
      y_ieufass = gt_ieufass
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  LOOP AT gt_ielpass INTO gs_elpass_neu.
    gs_elpass_neu-objkey = gd_objneu.
    CLEAR gs_elpass_neu-aenam.
    CLEAR gs_elpass_neu-aedat.
    gs_elpass_neu-ernam = sy-uname.
    gs_elpass_neu-erdat = sy-datum.
    APPEND gs_elpass_neu TO gt_elpass_neu.
  ENDLOOP.

  LOOP AT gt_ieufass INTO gs_eufass_neu.
    gs_eufass_neu-objkey = gd_objneu.
    CLEAR gs_eufass_neu-aenam.
    CLEAR gs_eufass_neu-aedat.
    gs_eufass_neu-ernam = sy-uname.
    gs_eufass_neu-erdat = sy-datum.
    APPEND gs_eufass_neu TO gt_eufass_neu.
  ENDLOOP.


  CALL FUNCTION 'ISU_DB_ELPASS_UPDATE'
    EXPORTING
      x_upd_mode = 'I'
    TABLES
      xt_elpass  = gt_elpass_neu.

  CALL FUNCTION 'ISU_DB_EUFASS_UPDATE'
    EXPORTING
      x_upd_mode = 'I'
    TABLES
      xt_eufass  = gt_eufass_neu.

***************************************************************
* Zählpunkt der neuen Anlage zuordnen
**************************************************************
  SELECT * FROM euiinstln INTO TABLE gt_euiinstln_neu
     WHERE anlage = gd_anlneu.
  READ TABLE gt_euiinstln_neu INTO gs_euiinstln_neu INDEX 1.


  SELECT *  INTO CORRESPONDING FIELDS OF TABLE gt_euitrans
     FROM euitrans INNER JOIN euiinstln
       ON euiinstln~int_ui = euitrans~int_ui
        WHERE euiinstln~anlage = gd_anlorg.

  LOOP AT gt_euitrans INTO gs_euitrans_neu.
    MOVE gs_euiinstln_neu-int_ui TO gs_euitrans_neu-int_ui.
    APPEND gs_euitrans_neu TO gt_euitrans_neu.
  ENDLOOP.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_euigrid
    FROM euigrid INNER JOIN euiinstln
      ON euiinstln~int_ui = euigrid~int_ui
        WHERE euiinstln~anlage = gd_anlorg.

  LOOP AT gt_euigrid INTO gs_euigrid_neu.
    MOVE gs_euiinstln_neu-int_ui TO gs_euigrid_neu-int_ui.
    APPEND gs_euigrid_neu TO gt_euigrid_neu.
  ENDLOOP.

* Externen Zählpunkt in neuer Anlage einbauen
  CALL FUNCTION 'ISU_DB_EUITRANS_UPDATE'
   EXPORTING
      EUITRANS_INSERT       = gt_euitrans_neu.
*     EUITRANS_UPDATE       =
*     EUITRANS_DELETE       =
            .
    CALL FUNCTION 'ISU_DB_EUIGRID_UPDATE'
     EXPORTING
        EUIGRID_INSERT       = gt_euigrid_neu.
*       EUIGRID_UPDATE       =
*       EUIGRID_DELETE       =
              .

******************************************************
* Zählpunkt an alter Anlage ändern
*******************************************************

* Hier muss noch ein Nummernkreis rein
  LOOP AT gt_euitrans INTO gs_euitrans.
    gs_euitrans-ext_ui = 'TEST00001'.
    MODIFY gt_euitrans FROM gs_euitrans TRANSPORTING ext_ui.
  ENDLOOP.

  MOVE gs_euitrans-ext_ui TO wa_out-extui_org_neu.


CALL FUNCTION 'ISU_DB_EUITRANS_UPDATE'
 EXPORTING
***   EUITRANS_INSERT       =
     EUITRANS_UPDATE       = gt_euitrans
***   EUITRANS_DELETE       =
  .


**********************************************************
** Geräte in neue Anlage einbauen
*********************************************************
  CALL FUNCTION 'ISU_DB_EASTL_SELECT'
    EXPORTING
      x_anlage      = gd_anlorg
*     X_LOGIKNR     =
      x_ab          = '19000101'
      x_bis         = '99991231'
    IMPORTING
*     Y_COUNT       =
      y_eastl       = gy_eastl
    TABLES
      t_eastl       = gt_eastl
*     T_EASTL_OLD   =
*     T_EASTL_KEY_LOGIKNR       =
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  CALL FUNCTION 'ISU_DB_EASTS_SELECT'
    EXPORTING
      x_anlage      = gd_anlorg
*   X_LOGIKZW           =s
      x_ab          = '19000101'
      x_bis         = '99991231'
    IMPORTING
*     Y_COUNT       =
      y_easts       = gy_easts
    TABLES
      t_easts       = gt_easts
*     T_EASTS_OLD   =
*     T_EASTS_KEY   =
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT gt_eastl INTO gs_eastl.
    MOVE gd_anlneu TO gs_eastl-anlage.
    MOVE sy-uname TO gs_eastl-ernam.
    MOVE sy-datum TO gs_eastl-erdat.
    CLEAR gs_eastl-aedat.
    CLEAR gs_eastl-aenam.
    MODIFY gt_eastl FROM gs_eastl.
  ENDLOOP.

  LOOP AT gt_easts INTO gs_easts.
    MOVE gd_anlneu TO gs_easts-anlage.
    MOVE sy-uname TO gs_easts-ernam.
    MOVE sy-datum TO gs_easts-erdat.
    CLEAR gs_easts-aedat.
    CLEAR gs_easts-aenam.
    MODIFY gt_easts FROM gs_easts.
  ENDLOOP.

  CALL FUNCTION 'ISU_DB_EASTL_UPDATE'
   EXPORTING
*     X_EASTL               =
*     X_EASTL_OLD           =
     X_UPD_MODE            =  'I'
*     X_NO_CHANGE_DOC       = ' '
   TABLES
*     T_EASTL_MOD           =
      T_EASTL_INSERT        = gt_Eastl
*     T_EASTL_UPDATE        =
*     T_EASTL_DELETE        =
*     T_EASTL_OLD           =
            .

  CALL FUNCTION 'ISU_DB_EASTS_UPDATE'
   EXPORTING
*     X_EASTS               =
*     X_EASTS_OLD           =
      X_UPD_MODE            = 'I'
*     X_NO_CHANGE_DOC       = ' '
   TABLES
*     T_EASTS_MOD           =
      T_EASTS_INSERT        = gt_easts
*     T_EASTS_UPDATE        =
*     T_EASTS_DELETE        =
*     T_EASTS_OLD           =
            .


END-OF-SELECTION.

  SKIP 4.
  WRITE: /5 'Anlage (alt)',
         20 'ZP (alt)',
         65 'ZP (neu)',
         80 'Anlage (neu)',
         95 'ZP (neue anlage)'.
  ULINE.
  WRITE: /5 wa_out-anlorg,
        20 wa_out-extui_org_alt,
        65 wa_out-extui_org_neu,
        80 wa_out-anlneu,
        95 wa_out-extui_neu.





*&---------------------------------------------------------------------*
*&      Form  NEUE_ANLAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_EANLH  text
*      -->P_IT_EANLH_NEU  text
*      -->P_GD_ANLORG  text
*      <--P_GD_ANLNEU  text
*      <--P_WA_EANL_NEU  text
*----------------------------------------------------------------------*
FORM neue_anlage  TABLES   lt_eanlh STRUCTURE eanlh
                           lt_eanlh_neu STRUCTURE eanlh
                  USING    ld_anlorg  TYPE anlage
                  CHANGING ld_anlneu  TYPE anlage
                           ls_eanl_neu TYPE eanl
                           ls_out STRUCTURE wa_out.

  DATA: ls_eanlh         TYPE eanlh,
        ls_eanlh_neu     TYPE eanlh,
        lt_eanlh_old     TYPE STANDARD TABLE OF eanlh,
        ls_euiinstln     TYPE euiinstln,
        lt_euiinstln     TYPE STANDARD TABLE OF euiinstln,
        lt_euiinstln_neu TYPE STANDARD TABLE OF euiinstln,
        ls_euiinstln_neu TYPE euiinstln,
        ls_euitrans      TYPE euitrans,
        ls_euihead       TYPE euihead,
        ls_euigrid       TYPE euigrid,
        lt_euigrid       TYPE STANDARD TABLE OF euigrid,
        lt_eanl          TYPE STANDARD TABLE OF v_eanl,
        ls_eanl          TYPE v_eanl,
        lv_lines         TYPE i,
        ls_eui_anlage    TYPE eui_auto_anlage.

  DATA: ls_pod_auto TYPE eui_auto.

  MOVE ld_anlorg TO ls_out-anlorg.

* Den ältesten Eintrag ermitteln.
  SORT lt_eanlh BY ab.
  READ TABLE lt_eanlh INTO ls_eanlh INDEX 1.


* Zu Kopierende Anlage holen
  CALL FUNCTION 'ISU_S_INSTLN_PROVIDE'
    EXPORTING
      x_anlage        = ls_eanlh-anlage
      x_keydate       = ls_eanlh-ab
      x_wmode         = '1'
      x_prorate       = 'X'
      x_no_dialog     = 'X'
*     X_CALLED_BY     =
    IMPORTING
*     y_obj           = gs_obj
      y_auto          = gs_auto
    EXCEPTIONS
      not_found       = 1
      invalid_keydate = 2
      foreign_lock    = 3
      not_authorized  = 4
      invalid_wmode   = 5
      general_fault   = 6
      OTHERS          = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    gs_auto-data-ab          = ls_eanlh-ab.
    gs_auto-contr-use-data   = 'X'.
    gs_auto-contr-use-rcat   = 'X'.
    gs_auto-contr-use-facts  = 'X'.
    gs_auto-contr-use-okcode = 'X'.
    gs_auto-contr-okcode     = 'SAVE'.
  ENDIF.

*  BREAK-POINT.

** Zählpunkt ermitteln
*  CLEAR ls_euiinstln.
*  SELECT * FROM euiinstln INTO ls_euiinstln
*      WHERE anlage = ld_anlorg
*    AND dateto = '99991231'
*    AND timeto = '235959'.
*
*    EXIT.
*
*  ENDSELECT.
*
*  CALL FUNCTION 'ISU_EDM_READ_EUI_COMPL_INT'
*    EXPORTING
*      x_int_ui      = ls_euiinstln-int_ui
*      x_dateto      = '99991231'
*      x_timeto      = '235959'
*      x_datefrom    = '19000101'
*      x_timefrom    = '000000'
*      x_spras       = sy-langu
*    IMPORTING
*      y_euitrans    = ls_euitrans
*      y_euihead     = ls_euihead
**     Y_TEXT        =
**     Y_EUILNR      =
**     Y_EUILZW      =
*      y_euiinstln   = lt_euiinstln
*    EXCEPTIONS
*      not_found     = 1
*      not_qualified = 2
*      system_error  = 3
*      OTHERS        = 4.
*
*  IF sy-subrc = 0.
*
*    SELECT *  FROM euigrid INTO TABLE lt_euigrid
*      WHERE int_ui = ls_euiinstln-int_ui
*       AND dateto = '99991231'
*       AND timeto = '235959'.
**
*    CLEAR ls_euiinstln_neu.
*    READ TABLE lt_euiinstln INTO ls_euiinstln_neu
*    WITH KEY anlage = gs_auto-key-anlage.
*    IF ls_euiinstln_neu IS INITIAL.
*      READ TABLE lt_euiinstln INTO ls_euiinstln_neu INDEX 1.
*    ENDIF.
*    READ TABLE lt_euigrid    INTO ls_euigrid    INDEX 1.
***    wa_auto-pod-int_ui =
*    CLEAR gs_auto-pod-int_ui.
*    gs_auto-pod-datefrom      = ls_euiinstln_neu-datefrom.  "Ab-Datum
*    gs_auto-pod-timefrom      = ls_euiinstln_neu-timefrom.  "Ab-Zeit
*    gs_auto-pod-euirole_tech  = ls_euihead-euirole_tech. "tech. ZP
*    gs_auto-pod-euirole_dereg = ls_euihead-euirole_dereg."dereg. ZP
*    gs_auto-pod-uitype        = ls_euihead-uitype.       "Zählpunktart
*    gs_auto-pod-ext_ui        = ls_euitrans-ext_ui.      "Zählpunktbez
*    gs_auto-pod-uistrutyp     = ls_euitrans-uistrutyp."Struktur d.ZP Bez
*    gs_auto-pod-grid_id       = ls_euigrid-grid_id.      "Netz
*    gs_auto-pod-grid_level    = ls_euigrid-grid_level.   "Netzebene
*  ENDIF.
*
**  MOVE gs_auto-pod-ext_ui  TO ls_out-extui_org_alt.

* Neue Anlage aufbauen
  CLEAR gs_auto-key-anlage.
  CLEAR gs_auto-key-bis.

  gs_auto-data-erdat = sy-datum.
  gs_auto-data-ernam = sy-uname.

  CLEAR gs_auto-data-aenam.
  CLEAR gs_auto-data-aedat.

  CLEAR gs_auto-data-service.

*  BREAK-POINT.

  CALL FUNCTION 'ISU_S_INSTLN_CREATE'
    EXPORTING
*     X_ANLAGE        =
      x_sparte        = gs_auto-data-sparte
      x_keydate       = ls_eanlh-ab
      x_upd_online    = 'X'
      x_no_dialog     = 'X'
      x_auto          = gs_auto
    IMPORTING
      y_db_update     = db_update
*     Y_EXIT_TYPE     =
    TABLES
      yt_new_eanl     = lt_eanl
    EXCEPTIONS
      existing        = 1
      foreign_lock    = 2
      not_authorized  = 3
      invalid_keydate = 4
      invalid_sparte  = 5
      input_error     = 6
      general_fault   = 7
      OTHERS          = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  READ TABLE lt_eanl INTO ls_eanl INDEX 1.
  MOVE ls_eanl-anlage TO ld_anlneu.
  MOVE ld_anlneu TO ls_out-anlneu.

* Zählpunkt ermitteln
  CLEAR ls_euiinstln.
  SELECT * FROM euiinstln INTO ls_euiinstln
      WHERE anlage = ld_anlorg
    AND dateto = '99991231'
    AND timeto = '235959'.

    EXIT.

  ENDSELECT.


*  BREAK-POINT.
*
*  CALL FUNCTION 'ISU_EDM_READ_EUI_COMPL_INT'
*    EXPORTING
*      x_int_ui      = ls_euiinstln-int_ui
*      x_dateto      = '99991231'
*      x_timeto      = '235959'
*      x_datefrom    = '19000101'
*      x_timefrom    = '000000'
*      x_spras       = sy-langu
*    IMPORTING
*      y_euitrans    = ls_euitrans
*      y_euihead     = ls_euihead
**     Y_TEXT        =
**     Y_EUILNR      =
**     Y_EUILZW      =
*      y_euiinstln   = lt_euiinstln
*    EXCEPTIONS
*      not_found     = 1
*      not_qualified = 2
*      system_error  = 3
*      OTHERS        = 4.
*
*  IF sy-subrc = 0.
*
*    SELECT *  FROM euigrid INTO TABLE lt_euigrid
*      WHERE int_ui = ls_euiinstln-int_ui
*       AND dateto = '99991231'
*       AND timeto = '235959'.
**
*    CLEAR ls_euiinstln_neu.
*    select * from euiinstln into ls_euiinstln_neu
*      where anlage = ld_anlneu
*        and dateto = '99991231'
*        and timeto = '235959'.
*      exit.
*    endselect.
*
*
**    READ TABLE lt_euiinstln INTO ls_euiinstln_neu
**    WITH KEY anlage = gs_auto-key-anlage.
**    IF ls_euiinstln_neu IS INITIAL.
**      READ TABLE lt_euiinstln INTO ls_euiinstln_neu INDEX 1.
**    ENDIF.
*    READ TABLE lt_euigrid    INTO ls_euigrid    INDEX 1.
*
****    wa_auto-pod-int_ui =
**    CLEAR gs_auto-pod-int_ui.
*     gs_auto-pod-int_ui        = ls_euiinstln_neu-int_ui.
*    gs_auto-pod-datefrom      = ls_euiinstln_neu-datefrom.  "Ab-Datum
*    gs_auto-pod-timefrom      = ls_euiinstln_neu-timefrom.  "Ab-Zeit
*    gs_auto-pod-euirole_tech  = ls_euihead-euirole_tech. "tech. ZP
*    gs_auto-pod-euirole_dereg = ls_euihead-euirole_dereg."dereg. ZP
*    gs_auto-pod-uitype        = ls_euihead-uitype.       "Zählpunktart
*    gs_auto-pod-ext_ui        = ls_euitrans-ext_ui.      "Zählpunktbez
*    gs_auto-pod-uistrutyp     = ls_euitrans-uistrutyp."Struktur d.ZP Bez
*    gs_auto-pod-grid_id       = ls_euigrid-grid_id.      "Netz
*    gs_auto-pod-grid_level    = ls_euigrid-grid_level.   "Netzebene
*  ENDIF.
*
*
*
*
*
*  BREAK-POINT.
*  gs_auto-key-anlage = ld_anlneu.
*  gs_auto-key-bis = '99991231'.
*
*  CALL FUNCTION 'ISU_S_INSTLN_CHANGE'
*    EXPORTING
*      x_anlage       = ld_anlneu
*      x_keydate      = ls_eanlh-ab
**     X_PRORATE      = 'X'
**     X_UPD_ONLINE   =
*      X_NO_DIALOG    = 'X'
*      x_auto         = gs_auto
**     X_OBJ          =
**     X_NO_OTHER     =
**     X_MASS_CHANGE_INST       =
**   IMPORTING
**     Y_DB_UPDATE    =
**     Y_EXIT_TYPE    =
*    TABLES
*      yt_new_eanl    = lt_eanl
*    EXCEPTIONS
*      not_found      = 1
*      foreign_lock   = 2
*      not_authorized = 3
*      cancelled      = 4
*      input_error    = 5
*      general_fault  = 6
*      OTHERS         = 7.
*  IF sy-subrc <> 0.
**        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  BREAK-POINT.
*


  READ TABLE lt_eanl INTO ls_eanl INDEX 1.

  MOVE ls_eanl-anlage TO ld_anlneu.
  MOVE ld_anlneu TO ls_out-anlneu.

  MOVE gs_auto-pod-ext_ui  TO ls_out-extui_neu.

* Gibt es in der Originalanlage mehrere Zeitscheiben ?
  DESCRIBE TABLE it_eanlh LINES lv_lines.

  IF lv_lines GT 1.
    SELECT SINGLE * FROM eanl INTO ls_eanl_neu
      WHERE anlage = ld_anlneu.

    SELECT * FROM eanlh INTO TABLE lt_eanlh_old
       WHERE anlage = ld_anlneu.

    LOOP AT lt_eanlh INTO ls_eanlh_neu.

      ls_eanlh_neu-anlage = gd_anlneu.
      APPEND ls_eanlh_neu TO lt_eanlh_neu.
    ENDLOOP.


    CALL FUNCTION 'ISU_DB_EANL_UPDATE'
      EXPORTING
        x_eanl          = ls_eanl_neu
        x_eanl_old      = ls_eanl_neu
        x_upd_mode      = 'U'
      TABLES
        xt_eanlh_delete = lt_eanlh_old
        xt_eanlh_insert = lt_eanlh_neu
**        xt_eanlh_update =
        xt_eanlh_old    = lt_eanlh_old.
*
*
  ENDIF.


** Zählpunkt zur neuen Anlage mit dem Externen Zählpunkt der alten Anlage
*  CALL FUNCTION 'ISU_S_UI_PROVIDE'
*    EXPORTING
*      x_int_ui      = ls_euiinstln-int_ui
**     X_EXT_UI      =
**     X_KEYDATE     = SY-DATUM
**     X_KEYTIME     =
*      x_wmode       = '1'
**     X_UPD_ONLINE  =
**     X_INST_CALL   =
*    IMPORTING
**     Y_OBJ         =
*      y_auto        = ls_pod_auto
*    EXCEPTIONS
*      not_found     = 1
*      not_qualified = 2
*      foreign_lock  = 3
*      system_error  = 4
*      OTHERS        = 5.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
*
*  BREAK-POINT.
*
*  SELECT * FROM euiinstln INTO TABLE lt_euiinstln_neu WHERE anlage = gd_anlneu.
*
*  CLEAR ls_pod_auto-dereg_anlage.
*  LOOP AT lt_euiinstln_neu INTO ls_euiinstln_neu.
*    MOVE-CORRESPONDING ls_euiinstln_neu TO ls_eui_anlage.
*    APPEND ls_eui_anlage TO ls_pod_auto-dereg_anlage.
*  ENDLOOP.
*
*  ls_pod_auto-control-use_extui = 'X'.
*  ls_pod_auto-control-use_header = 'X'.
*  ls_pod_auto-control-use_dereg_anlage = 'X'.
*  ls_pod_auto-control-use_grid = 'X'.
*
*  BREAK-POINT.
*
*
**  CALL FUNCTION 'ISU_S_UI_CREATE'
**    EXPORTING
***     X_KEYDATE     =
***     x_upd_online  = 'X'
***     X_NO_OTHER    =
**      x_no_dialog   = 'X'
**      x_auto        = ls_pod_auto
***     X_INST_CALL   =
*** IMPORTING
***     Y_INT_UI      =
***     Y_DB_UPDATE   =
***     Y_EXIT_TYPE   =
**    EXCEPTIONS
**      not_qualified = 1
**      foreign_lock  = 2
**      input_error   = 3
**      system_error  = 4
**      OTHERS        = 5.
**  IF sy-subrc <> 0.
*** Implement suitable error handling here
**  ENDIF.
*
*
*  BREAK-POINT.



ENDFORM.
