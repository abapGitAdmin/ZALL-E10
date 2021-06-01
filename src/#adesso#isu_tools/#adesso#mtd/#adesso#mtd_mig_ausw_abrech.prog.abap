*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_MIG_AUSW_ABRECH
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /adesso/mtd_mig_ausw_abrech.



* ALV
TYPE-POOLS: slis.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      gs_keyinfo  TYPE slis_keyinfo_alv,
      gt_sort     TYPE slis_t_sortinfo_alv,
      gt_sp_group TYPE slis_t_sp_group_alv,
      gt_events   TYPE slis_t_event.


DATA: g_repid LIKE sy-repid.
DATA: g_tabname_header TYPE slis_tabname.
DATA: g_tabname TYPE slis_tabname.
DATA: g_error  TYPE char1.
DATA: g_noprot TYPE char1.

* Strukturen und Tabellen
DATA: wa_datab TYPE /adesso/mte_dtab,
      wa_rel TYPE /adesso/mte_rel,
      it_rel TYPE STANDARD TABLE OF /adesso/mte_rel,
      wa_ever TYPE ever,
      wa_eanl TYPE v_eanl,
      wa_etrg TYPE etrg,
      wa_eablg TYPE eablg,
      it_eablg TYPE STANDARD TABLE OF eablg,
      wa_eabl   TYPE eabl,
      wa_erch  TYPE erch,
      it_erch TYPE STANDARD TABLE OF erch,
      wa_erchc TYPE erchc,
      it_erchc TYPE STANDARD TABLE OF erchc,
      wa_erdk TYPE erdk.

DATA: p_stich LIKE sy-datum.

* Ausgabestruktur
DATA: BEGIN OF wa_out,
       vertrag TYPE vertrag,
       sparte TYPE sparte,
       auszdat TYPE auszdat,
       anlage  TYPE anlage,
       trigstat   TYPE trigstat,
       belnr    TYPE e_belnr,
       opbel   TYPE opbel_kk,
       total_amnt TYPE betr2_kk,
       fikey   type fikey_kk,
       error(2) TYPE c,
       komment(100) TYPE c,
      END OF wa_out.
DATA: it_out LIKE STANDARD TABLE OF wa_out.


***********************************************************************
* Selektionsbildschirm
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE text-001.
SELECT-OPTIONS: so_vert FOR wa_ever-vertrag.
PARAMETERS: p_firma LIKE temfirma-firma DEFAULT 'WBD',
*            p_stich LIKE sy-datum,
            p_err radiobutton group 001,
            p_all radiobutton group 001.
SELECTION-SCREEN END OF BLOCK sel.


**********************************************************************
* INITIALIZATION
**********************************************************************
INITIALIZATION.
  SELECT SINGLE * FROM /adesso/mte_dtab INTO wa_datab.


**********************************************************************
* START-OF-SELECTIONS
**********************************************************************
START-OF-SELECTION.
  PERFORM main.

**********************************************************************
* END-OF-SELECTIONS
**********************************************************************
END-OF-SELECTION.
  PERFORM layout_build USING gs_layout.
  PERFORM fieldcat_build USING gt_fieldcat.
  PERFORM display_alv.


*&---------------------------------------------------------------------*
*&      Form  MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM main .

  SELECT * FROM /adesso/mte_rel INTO TABLE it_rel
   WHERE firma = p_firma
     AND object = 'MOVE_IN'
     and obj_key in so_vert.

* Alle Abrechnungsbelege lesen

  LOOP AT it_rel INTO wa_rel.

* Verträge selektieren
    CLEAR wa_ever.
    SELECT SINGLE * FROM ever INTO wa_ever
      WHERE vertrag = wa_rel-obj_key.

    MOVE wa_ever-vertrag TO wa_out-vertrag.
    MOVE wa_ever-sparte TO wa_out-sparte.
    MOVE wa_ever-anlage TO wa_out-anlage.
    MOVE wa_ever-auszdat TO wa_out-auszdat.




    IF wa_ever-auszdat =  '99991231'.
      wa_out-error = '01'.
      wa_out-komment = 'kein Auszug vorhanden'.
    ENDIF.

    IF wa_out-error IS INITIAL.


*   Stichtag der Abrechnung ermitteln
      CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
        EXPORTING
          x_anlage          = wa_ever-anlage
*         X_DPC_MR          =
        IMPORTING
*         Y_BEGABRPE        =
*         Y_BEGNACH         =
*         Y_BEGEND          =
          y_last_endabrpe   = p_stich
*         Y_NEXT_CONTRACT   =
*         Y_PREVIOUS_BILL   =
*         Y_NO_CONTRACT     =
*         y_default_date    =
        EXCEPTIONS
          no_contract_found = 1
          general_fault     = 2
          parameter_fault   = 3
          OTHERS            = 4.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

*  Abrechnungsauftrag lesen.
      CLEAR wa_etrg.
      SELECT SINGLE * FROM etrg INTO wa_etrg
           WHERE anlage = wa_ever-anlage
             AND abrdats = p_stich
             AND abrvorg = '03'.

      MOVE wa_etrg-trigstat TO wa_out-trigstat.

*    Nicht abrechnungsfähiger Abrechnungsauftrag.
      IF wa_etrg-trigstat = '1'.
*     Hier erst einmal den nicht abrechnungsfähigen Trigger eintragen
        wa_out-error = '02'.
        wa_out-komment = 'nicht abrechnungsfähiger Abrechnungfsauftrag'.

*       Text übersteueren, wann Ableseergebnis unplausibel
        CLEAR: it_eablg, wa_eablg.
        SELECT * FROM eablg INTO TABLE it_eablg
          WHERE anlage = wa_ever-anlage
            AND ablesgr = '03'.

        LOOP AT it_eablg INTO wa_eablg.
          CLEAR wa_eabl.
          SELECT SINGLE * FROM eabl INTO wa_eabl
            WHERE ablbelnr = wa_eablg-ablbelnr.

          IF wa_eabl-ablstat = '2'.
            wa_out-error = '03'.
            wa_out-komment = 'Schlussablesung(en) unplausibel'.
          ENDIF.
          EXIT.

        ENDLOOP.
      ENDIF.

    ENDIF.

*  Abrechnungsbeleg lesen.
    IF wa_out-error IS INITIAL.
      CLEAR wa_erch.
      SELECT SINGLE * FROM erch INTO wa_erch
        WHERE vertrag = wa_ever-vertrag
          AND simulation = ''
          AND stornodat = '00000000'
          AND abrvorg = '03'
          AND abrdats GE p_stich.

      IF sy-subrc NE 0.
        wa_out-error = '04'.
        wa_out-komment = 'kein Abrechnungsbeleg vorhanden'.
      ELSE.
*       Abrechnungsbeleg ausgesteuert.
        wa_out-belnr = wa_erch-belnr.
        IF wa_erch-tobreleasd = 'X'.
          wa_out-error = '05'.
          wa_out-komment = 'Abrechnungsbeleg ausgesteuert'.
        ELSE.
          IF wa_erch-erchc_v IS INITIAL.
            wa_out-error = '06'.
            wa_out-komment = 'Keine Fakturahistorie vorhanden'.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.

*   Druckbelege lesen
    IF wa_out-error IS INITIAL.
      CLEAR: it_erchc, wa_erchc.
      SELECT * FROM erchc INTO TABLE it_erchc
        WHERE belnr = wa_erch-belnr
        AND intopbel = space
        AND simulated = space.

      READ TABLE it_erchc INTO wa_erchc INDEX 1.

      CLEAR wa_erdk.
      SELECT SINGLE * FROM erdk INTO wa_erdk
         WHERE opbel  = wa_erchc-opbel.

      wa_out-opbel = wa_erdk-opbel.
      wa_out-total_amnt = wa_erdk-total_amnt.
      wa_out-fikey = wa_erdk-fikey.


      IF wa_erdk-tobreleasd = 'X'.
        wa_out-error = '07'.
        wa_out-komment = 'Druckbeleg ausgesteuert'.
      ENDIF.

    ENDIF.







    IF p_err IS NOT INITIAL.
      IF wa_out-error IS NOT INITIAL.
        APPEND wa_out TO it_out.
      ENDIF.
    ELSE.
      APPEND wa_out TO it_out.
    ENDIF.




    CLEAR wa_out.

  ENDLOOP.

  IF p_err IS NOT INITIAL.
    SORT it_out BY error.
  ENDIF.

ENDFORM.                    " MAIN

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING  ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.                    " LAYOUT_BUILD


*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_build  USING  lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

* Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VERTRAG'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Sparte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPARTE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Auszugsdatum alter Vertrag
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUSZDAT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Anlage
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ANLAGE'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'EVER'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Triggerstatus
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TRIGSTAT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ETRG'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Abrechnungsbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERCH'.
  APPEND ls_fieldcat TO lt_fieldcat.


* Druckbeleg
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'OPBEL'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERDK'.
  APPEND ls_fieldcat TO lt_fieldcat.

*  Summe
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TOTAL_AMNT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERDK'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Abstimmschlüssel
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FIKEY'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-ref_tabname = 'ERDK'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Fehler
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ERROR'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Fehler'.
  ls_fieldcat-seltext_m = 'Fehler'.
  APPEND ls_fieldcat TO lt_fieldcat.

* Kommentar
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOMMENT'.
  ls_fieldcat-tabname = 'IT_OUT'.
  ls_fieldcat-seltext_s = 'Komment'.
  ls_fieldcat-seltext_m = 'Kommentar'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    " FIELDCAT_BUILD


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
      i_callback_program                = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      =
*     I_GRID_SETTINGS                   =
      is_layout                         = gs_layout
      it_fieldcat                       = gt_fieldcat
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          =  it_out
   EXCEPTIONS
     program_error                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " DISPLAY_ALV
