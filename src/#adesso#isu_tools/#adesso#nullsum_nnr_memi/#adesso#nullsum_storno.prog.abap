*&---------------------------------------------------------------------*
*& Report /ADESSO/NULLSUM_STORNO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /adesso/nullsum_storno.

* Data ALV-Grid
TYPE-POOLS: slis.

DATA: lv_programm TYPE sy-repid,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE LINE OF slis_t_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv,
      g_status    TYPE slis_formname VALUE 'STATUS_STANDARD'.

DATA: gs_tinv_inv_doc    TYPE tinv_inv_doc,
      gt_tinv_inv_doc    TYPE STANDARD TABLE OF tinv_inv_doc,
      gs_tinv_inv_line_a TYPE tinv_inv_line_a,
      gt_tinv_inv_line_a TYPE STANDARD TABLE OF tinv_inv_line_a,
      gs_tinv_inv_docref TYPE tinv_inv_docref,
      gs_tinv_inv_head   TYPE tinv_inv_head.                  "Nuss 11.2018

TYPES: BEGIN OF ty_output,
         sel(1)          TYPE c,
         int_inv_doc_no  TYPE inv_int_inv_doc_no,
         date_of_receipt TYPE inv_date_of_receipt,          "Nuss 11.2018
         ext_invoice_no  TYPE inv_ext_invoice_no,
         crossrefno      TYPE ecrossrefno-crossrefno,
         crn_rev         TYPE ecrossrefno-crn_rev,
         augbl           TYPE augbl_kk,
         storniert       TYPE char1,
         storb           TYPE storb_kk,
       END OF ty_output.
DATA: gs_output TYPE ty_output,
      gt_output TYPE TABLE OF ty_output.

DATA: BEGIN OF gs_sel,
        int_inv_doc_no  TYPE inv_int_inv_doc_no,
        date_of_receipt TYPE inv_date_of_receipt,            "Nuss 11-2018
        ext_invoice_no  TYPE inv_ext_invoice_no,
        inbound_ref     TYPE inv_inbound_ref,
      END OF gs_sel.



DATA: gs_dfkkko TYPE dfkkko.

DATA: gv_fikey TYPE fikey_kk.

DATA: gv_extdat TYPE char10.

DATA: gt_cust_kpf TYPE /adesso/cust_kpf.



*********************************************************************************
* SELECTION-SCREEN
*********************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS so_extid FOR gs_tinv_inv_doc-ext_invoice_no NO-DISPLAY.
SELECT-OPTIONS so_intid FOR gs_tinv_inv_doc-int_inv_doc_no.
SELECT-OPTIONS so_date FOR gs_tinv_inv_head-date_of_receipt.            "Nuss 11.2018
SELECT-OPTIONS so_crsrf FOR gs_tinv_inv_line_a-own_invoice_no.


SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK cnc WITH FRAME TITLE TEXT-002.

PARAMETERS: p_stodt TYPE stodt_kk DEFAULT sy-datum,
            p_blart TYPE blart_kk,
            p_augrd TYPE augrd_kk,
            p_stmet TYPE stmet_kk AS LISTBOX VISIBLE LENGTH 40.


SELECTION-SCREEN END OF BLOCK cnc.


**********************************************************************************
* INITIALIZATION
**********************************************************************************
INITIALIZATION.
  so_extid-sign = 'I'.
  so_extid-option = 'CP'.
  so_extid-low = 'ADESSO_NULLSUM*'.
  APPEND so_extid.

  PERFORM fill_selfields.



***********************************************************************************
* START-OF-SELECTION
***********************************************************************************
START-OF-SELECTION.
  PERFORM select_data.



***********************************************************************************
* END-OF-SELECTION
***********************************************************************************
END-OF-SELECTION.
*Feldkatalog erstellen
  PERFORM fieldcat_build USING gt_fieldcat[].

*Layout erstellen
  PERFORM layout_build USING gs_layout.

*ALV-Grid anzeigen
  PERFORM display_alv.


*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data .

  DATA: lv_lines TYPE i.
  DATA: pack TYPE p.               "Nuss 10.2018-2

*  SELECT a~int_inv_doc_no a~ext_invoice_no b~inbound_ref          "Nuss 11.2018
  SELECT a~int_inv_doc_no c~date_of_receipt a~ext_invoice_no b~inbound_ref       "Nuss 11.2018
    INTO CORRESPONDING FIELDS OF gs_sel
      FROM tinv_inv_doc AS a
 INNER JOIN tinv_inv_head AS c                       "Nuss 11.2018
   ON c~int_inv_no = a~int_inv_no                    "Nuss 11.2018
        INNER JOIN tinv_inv_docref AS b
          ON b~int_inv_doc_no = a~int_inv_doc_no
            AND b~inbound_ref_type = '90'
          WHERE a~int_inv_doc_no IN so_intid
        AND a~ext_invoice_no IN so_extid
        AND c~date_of_receipt IN so_date.           "Nuss 11.2018

* Rechnungsreferenz als FI-CA Beleg ausgeben
    gs_sel-inbound_ref = gs_sel-inbound_ref+1(12).
    MOVE-CORRESPONDING  gs_sel TO gs_output.
    MOVE gs_sel-inbound_ref TO gs_output-augbl.

    CLEAR gt_tinv_inv_line_a.
    SELECT * FROM tinv_inv_line_a INTO TABLE gt_tinv_inv_line_a
       WHERE int_inv_doc_no = gs_output-int_inv_doc_no.
    CHECK sy-subrc = 0.
    DESCRIBE TABLE gt_tinv_inv_line_a LINES lv_lines.

*   --> Nuss 10.2018-2
* Die Anzahl der Zeilen muss gerade sein.
*    CHECK lv_lines = 2.
    pack = lv_lines MOD 2.
    CHECK pack = 0.
*   <-- Nuss 10.2018-2

    CLEAR pack.                    "Nuss 10.2018-2
    LOOP AT gt_tinv_inv_line_a INTO gs_tinv_inv_line_a.
*    --> Nuss 10.2018-2
      pack = sy-tabix MOD 2.
*      IF gs_tinv_inv_line_a-int_inv_line_no = '1'.
      IF pack = 1.
*    <-- Nuss 10.2018-2
        MOVE gs_tinv_inv_line_a-own_invoice_no TO gs_output-crossrefno.
*        CHECK gs_output-crossrefno IN so_crsrf.                            "Nuss 11.2018
*    --> Nuss 10.2018-2
*      ELSEIF gs_tinv_inv_line_a-int_inv_line_no = '2'.
      ELSEIF pack = 0.
*    <-- Nuss 10.2018-2
        MOVE gs_tinv_inv_line_a-own_invoice_no TO gs_output-crn_rev.
        CHECK gs_output-crossrefno IN so_crsrf OR gs_output-crn_rev IN so_crsrf.   "Nuss 11.2018
*     --> Nuss 10.2018-2
        APPEND gs_output TO gt_output.
        CONTINUE.
*     <-- Nuss 10.2018-2
      ENDIF.

      CLEAR gs_dfkkko.

      SELECT SINGLE * FROM dfkkko INTO gs_dfkkko
        WHERE opbel = gs_output-augbl.
      IF gs_dfkkko-storb IS NOT INITIAL.
        gs_output-storniert = 'X'.
        gs_output-storb = gs_dfkkko-storb.
      ENDIF.

    ENDLOOP.

*      APPEND gs_output TO gt_output.           "Nuss 10.2018-2
    CLEAR gs_output.


  ENDSELECT.

  SORT gt_output BY int_inv_doc_no.              "Nuss 10.2018-2

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_build  USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-input = 'X'.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-seltext_s = 'Selektion'.
  ls_fieldcat-seltext_m = 'Selektion'.
  ls_fieldcat-seltext_l = 'Selektion'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-ref_fieldname = 'INT_INV_DOC_NO'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

* --> Nuss 11.2018
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DATE_OF_RECEIPT'.
  ls_fieldcat-ref_fieldname = 'DATE_OF_RECEIPT'.
  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD'.
  APPEND ls_fieldcat TO lt_fieldcat.
* <-- Nuss 11.2018

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EXT_INVOICE_NO'.
  ls_fieldcat-ref_fieldname = 'EXT_INVOICE_NO'.
  ls_fieldcat-ref_tabname = 'TINV_INV_DOC'.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CROSSREFNO'.
  ls_fieldcat-ref_fieldname = 'CROSSREFNO'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  ls_fieldcat-seltext_s     = 'Orig. PRN'.
  ls_fieldcat-seltext_m     = 'Original PRN'.
  ls_fieldcat-seltext_l     = 'Original PRN'.
  ls_fieldcat-ddictxt       = 'M'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname     = 'CRN_REV'.
  ls_fieldcat-ref_fieldname = 'CRN_REV'.
  ls_fieldcat-ref_tabname   = 'ECROSSREFNO'.
  ls_fieldcat-seltext_s     = 'Storno PRN'.
  ls_fieldcat-seltext_m     = 'Storno PRN'.
  ls_fieldcat-seltext_l     = 'Storno PRN'.
  ls_fieldcat-ddictxt       = 'M'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGBL'.
  ls_fieldcat-ref_fieldname = 'AUGBL'.
  ls_fieldcat-ref_tabname = 'DFKKOP'.
  ls_fieldcat-seltext_s = 'AugBel'.
  ls_fieldcat-seltext_m = 'Ausgleichsbeleg'.
  ls_fieldcat-seltext_l = 'Nullsummen-Ausgleichsbeleg'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STORNIERT'.
  ls_fieldcat-seltext_s = 'Storno'.
  ls_fieldcat-seltext_m = 'Storno'.
  ls_fieldcat-seltext_l = 'Beleg storniert'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STORB'.
  ls_fieldcat-ref_fieldname = 'STORB'.
  ls_fieldcat-ref_tabname = 'DFKKKO'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build  USING ls_layout TYPE slis_layout_alv.

  ls_layout-zebra = 'X'.
  ls_layout-colwidth_optimize = 'X'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  lv_programm = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = lv_programm
      i_callback_pf_status_set = g_status                  "Nuss 07.2018
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_output
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.

  SET PF-STATUS 'STATUS_STANDARD' EXCLUDING extab.

ENDFORM.                    "status_standard


*&---------------------------------------------------------------------*
* ALV-GRID-USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm
                        rs_selfield TYPE slis_selfield.


  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.
  FIELD-SYMBOLS: <wa_out>, <value>.

* --> Nuss 10.2018
*  DATA: lv_type LIKE tinv_inv_doc-doc_type.
  DATA: rspar_tab  TYPE TABLE OF rsparams,
        rspar_line LIKE LINE OF rspar_tab.
* <-- Nuss 10.2018

  rs_selfield-refresh = 'X'.

  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  rev_alv->check_changed_data( ).

  READ TABLE gt_output ASSIGNING <wa_out> INDEX rs_selfield-tabindex.


  IF r_ucomm = 'STORNO'.

    PERFORM storno.





  ELSEIF r_ucomm = 'MARK_ALL'.
    LOOP AT gt_output INTO gs_output.

      gs_output-sel = 'X'.

      MODIFY gt_output FROM gs_output TRANSPORTING sel.
    ENDLOOP.

  ELSEIF r_ucomm = 'DEL_MARK'.

    LOOP AT gt_output INTO gs_output.

      gs_output-sel = ''.

      MODIFY gt_output FROM gs_output TRANSPORTING sel.
    ENDLOOP.



  ELSE.

    CASE rs_selfield-fieldname.

      WHEN 'INT_INV_DOC_NO'.

        ASSIGN COMPONENT 'INT_INV_DOC_NO' OF STRUCTURE <wa_out> TO <value>.

* --> Nuss 10.2018
*        CLEAR lv_type.
*        SELECT SINGLE doc_type FROM tinv_inv_doc INTO lv_type
*          WHERE int_inv_doc_no EQ <value>.

        rspar_line-selname = 'P_INVTP'.
        rspar_line-kind = 'P'.
        rspar_line-sign = 'I'.
        rspar_line-option = 'EQ'.
        CLEAR rspar_line-low.
        APPEND rspar_line TO rspar_tab.

        CLEAR rspar_line.
        rspar_line-selname = 'SE_DOCNR'.
        rspar_line-kind = 'S'.
        rspar_line-sign = 'I'.
        rspar_line-option = 'EQ'.
        rspar_line-low = <value>.
        APPEND rspar_line TO rspar_tab.

        SUBMIT rinv_monitoring
          USING SELECTION-SCREEN '1000'
          WITH SELECTION-TABLE rspar_tab
          AND RETURN.

*        SUBMIT rinv_monitoring
*         WITH se_docnr-low = <value>
*         VIA SELECTION-SCREEN
*        AND RETURN.

* <--  Nuss 10.2018

      WHEN 'AUGBL'.

        ASSIGN COMPONENT 'AUGBL' OF STRUCTURE <wa_out> TO <value>.

        SET PARAMETER ID '80B' FIELD <value>.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.

      WHEN 'STORB'.

        ASSIGN COMPONENT 'STORB' OF STRUCTURE <wa_out> TO <value>.

        CHECK <value> IS NOT INITIAL.                                   "Nuss 11.2018

        SET PARAMETER ID '80B' FIELD <value>.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.

    ENDCASE.

  ENDIF.




ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  STORNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM storno .

  DATA: lv_date    TYPE dats,
        lv_nr(2)   TYPE n   VALUE '01',
        lv_abst(2) TYPE c.

  DATA: ls_dfkksumc TYPE dfkksumc.

  DATA: lv_stblg TYPE storb_kk,
        lv_stodt TYPE stodt.

  lv_date = sy-datum.

  CLEAR lv_abst.
  SELECT SINGLE abst FROM /adesso/cust_kpf
     INTO lv_abst.

  IF lv_abst IS INITIAL.
    lv_abst = 'AD'.
  ENDIF.

  CONCATENATE lv_abst lv_nr lv_date INTO gv_fikey.

* Existiert der Abstimmschlüssel schon?
  DO.
    CLEAR ls_dfkksumc.
    SELECT SINGLE * FROM dfkksumc INTO ls_dfkksumc
      WHERE fikey = gv_fikey.
    IF sy-subrc NE 0.
* Anlegen
      CALL FUNCTION 'FKK_FIKEY_CHECK'
        EXPORTING
          i_fikey                = gv_fikey
          i_open_on_request      = ' '
          i_open_without_dialog  = 'X'
          i_non_existing_allowed = 'X'
        EXCEPTIONS
          non_existing           = 1
          OTHERS                 = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        EXIT.
      ENDIF.
    ELSE.
      IF ls_dfkksumc-cpudt EQ lv_date AND ls_dfkksumc-xclos IS INITIAL.
        EXIT.
      ENDIF.
      lv_nr = lv_nr + 1.
      CONCATENATE lv_abst lv_nr lv_date INTO gv_fikey.
    ENDIF.
  ENDDO.


  LOOP AT gt_output INTO gs_output.
    CHECK gs_output-sel IS NOT INITIAL.
    CHECK gs_output-storniert IS INITIAL.

* --> Nuss 10.2018-2
* Bei aggregierten Belegen können mehrere Zeilen die gleiche
* Belegnunner haben - Nur einmal stornieren
    READ TABLE gt_output TRANSPORTING NO FIELDS
      WITH KEY augbl = gs_output-augbl
               storniert = 'X'.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
* <-- Nuss 10.2018-2

    CALL FUNCTION 'FKK_REVERSE_DOC'
      EXPORTING
        i_opbel       = gs_output-augbl
*       I_BUDAT       =
        i_blart       = p_blart
        i_augrd       = p_augrd
*       I_RLGRD       = ' '
*       I_VOIDR       = ' '
        i_stmet       = p_stmet
*       I_XCOPA       = ' '
        i_fikey       = gv_fikey
        i_herkf       = '02'
*       I_XBLNR       = ' '
*       I_AWSYS       = ' '
*       I_AWTYP       = ' '
*       I_AWKEY       = ' '
        i_stodt       = p_stodt
*       I_PRTID       =
*       I_CHECK_ARCHIVE          = ' '
*       I_OPEN_REPEATINGS        = ' '
*       I_NO_PARTIAL  = ' '
*       I_UPDATE_TASK = ' '
*       I_RESOB       = ' '
*       I_RESKY       = ' '
*       I_CALLR       = ' '
*       I_TEST        = ' '
*       I_IGNORE_CLEARINGS       = ' '
*       I_SEND_NOTES  = ' '
*       I_DIALOG      = ' '
*       I_WF4EYE      = ' '
*       I_CLARIFY     = ' '
*       I_NO_4EYES    = ' '
*       I_RA_EXTENDED = ' '
*       I_CHECK_MEMORY           = ' '
*       I_VOID_PDC    = 'X'
*       I_EXT_STORB   = ' '
*       I_WNPER       =
*       I_OPORD       = ' '
*       I_EXC_DOC_LOCK           = ' '
      IMPORTING
        e_opbel       = lv_stblg
*       E_C4EYE       =
        e_stodt       = lv_stodt
*       E_BUDAT       =
*       E_BLDAT       =
*     TABLES
*       T_CLETAB      =
*       T_FKKOP_NEW   =
*       T_FKKOPK_NEW  =
      EXCEPTIONS
        cleared_items = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      COMMIT WORK.
      gs_output-storniert = 'X'.
      gs_output-storb = lv_stblg.
      MODIFY gt_output FROM gs_output
       TRANSPORTING storniert storb.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_SELFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_selfields .

  DATA: ls_rfk00   TYPE rfk00,
        ls_tfk033d TYPE tfk033d.

  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk = ls_rfk00-applk.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ls_tfk033d-applk = ls_rfk00-applk.
  ls_tfk033d-buber = '1050'.

  CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
    EXPORTING
      i_tfk033d = ls_tfk033d
    IMPORTING
      e_tfk033d = ls_tfk033d.

  p_blart = ls_tfk033d-fun01.
  p_augrd = ls_tfk033d-fun02.
  p_stmet = ls_tfk033d-fun04.

ENDFORM.
