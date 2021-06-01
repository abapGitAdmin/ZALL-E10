*&---------------------------------------------------------------------*
*& Report  /ADESSO/SPLIT_ZAHLSTAPEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/split_zahlstapel MESSAGE-ID /adesso/zs_split.


CONSTANTS: gc_stype_hdr LIKE bfkkzgr00-stype VALUE '1'.

CONSTANTS:
  gc_phname LIKE filename-fileextern VALUE '',
  gc_lgname LIKE filename-fileintern
            VALUE 'FICA_DATA_TRANSFER_DIR',
  gc_dirzst TYPE c LENGTH 4 VALUE 'ABZL'.


TYPES:  t_tbiline_data TYPE TABLE OF file_structure.

TYPES:
  BEGIN OF tbidata_attr,
    stype           TYPE stype_z_kk,  " Type of record
    structname_orig TYPE tabname, " Name of file line structure
    structname      TYPE tabname,     " Default structure
    text            TYPE as4text,     " Descriptive text (otherwise taken
    " from structure description
    colo            TYPE lvc_s_colo,  "Table for colors
    dd03p           TYPE dd03ttyp,
  END OF tbidata_attr.

TYPES: t_tbidata_attr TYPE TABLE OF tbidata_attr.

DATA: gv_selection TYPE c.

DATA: lv_name      LIKE filename-fileextern. "phys.(ext.) file name
DATA: selectlist LIKE spopli OCCURS 5 WITH HEADER LINE.

DATA: gt_file   TYPE t_tbiline_data,
      gs_file   TYPE file_structure,
      gs_header TYPE file_structure.

DATA: gt_file_new TYPE t_tbiline_data,
      gs_file_new TYPE file_structure.

DATA: gv_position TYPE i.

DATA:  mpt_attr   TYPE t_tbidata_attr.

DATA: gs_biline TYPE bilinetext,
      gt_biline TYPE STANDARD TABLE OF bilinetext.


* Felder für Übernahme FPB3
DATA: r_norm  LIKE fkkzepar-rnorm,
      r_err   LIKE fkkzepar-rfehl,
      r_rst   LIKE fkkzepar-rwied,
      p_xcont LIKE fkkzepar-xcont,
      p_xclos LIKE fkkzepar-xclos,
      p_xbuch LIKE fkkzepar-xbuch,
      p_xprot LIKE fkkzepar-xprot VALUE 'X'.

DATA: gs_cust       TYPE /adesso/zs_split,
      gt_cust       TYPE STANDARD TABLE OF /adesso/zs_split,
      gv_cust_ok(1) TYPE c.


* Sichern Variablen für Varianten
DATA: gs_tvarvc TYPE tvarvc,
      gt_tvarvc LIKE TABLE OF tvarvc.

* Aufbau Identifikation
DATA: gv_lfdnr   TYPE n LENGTH 2,
      gv_zlrunid TYPE fkkzest-runid.

DATA: gv_subrc TYPE sy-subrc.

* --> Nuss 16.01.2018 Ergebnisausgabe
DATA: BEGIN OF gs_out,
        zs_old TYPE bfkkzk-keyz1,
        zs_new TYPE bfkkzk-keyz1,
        posnew TYPE i,
      END OF gs_out.
DATA: gt_out LIKE STANDARD TABLE OF gs_out.
* <-- Nuss 16.01.2018


* Selektionsbildschirm
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
PARAMETERS: ph_name LIKE filename-fileextern DEFAULT gc_phname.
PARAMETERS: ph_new  LIKE filename-fileextern OBLIGATORY.
SELECTION-SCREEN SKIP 1.
** --> Nuss 17.01.2018
PARAMETERS: p_uni  RADIOBUTTON GROUP uni,
            p_nuni RADIOBUTTON GROUP uni.
** <-- Nuss 17.01.2018
SELECTION-SCREEN END OF BLOCK bl1.
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_stap AS CHECKBOX.
*PARAMETER: p_runid LIKE fkkzest-runid.
PARAMETERS: p_vari TYPE variant.
SELECTION-SCREEN END OF BLOCK bl2.

************************************************************************
* AT SELECTION-SCREEN ON VALUE...
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.

  CALL FUNCTION 'RS_VARIANT_CATALOG'
    EXPORTING
      report               = 'RFKKZE00'
*     NEW_TITLE            = ' '
*     DYNNR                =
*     INTERNAL_CALL        = ' '
*     MASKED               = 'X'
*     VARIANT              = ' '
*     POP_UP               = ' '
    IMPORTING
      sel_variant          = p_vari
*     SEL_VARIANT_TEXT     =
*    TABLES
*     BELONGING_DYNNR      =
    EXCEPTIONS
      no_report            = 1
      report_not_existent  = 2
      report_not_supplied  = 3
      no_variants          = 4
      no_variant_selected  = 5
      variant_not_existent = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



***********************************************************************
* AT-SELECTION-SCREEN
***********************************************************************
AT SELECTION-SCREEN.

  CLEAR gv_selection.
  CLEAR selectlist.

* Validate physical filename
  CALL FUNCTION 'FILE_VALIDATE_NAME'           " note 1509883
    EXPORTING
      logical_filename  = gc_lgname
    CHANGING
      physical_filename = ph_name
    EXCEPTIONS
      OTHERS            = 1.                  " note 1509883
  IF sy-subrc <> 0.                            " note 1509883
    MESSAGE i800(29) WITH ph_name.
    EXIT.
  ENDIF.

  PERFORM read_customizing.
  IF gv_cust_ok IS INITIAL.
    MESSAGE e001.
  ENDIF.

AT SELECTION-SCREEN ON ph_new.
  IF ph_new EQ ph_name.
    SET CURSOR FIELD ph_new.
    MESSAGE e004.
  ENDIF.

AT SELECTION-SCREEN ON p_vari.
  IF p_stap IS NOT INITIAL.
    IF p_vari IS INITIAL.
      SET CURSOR FIELD 'P_VARI'.
      MESSAGE e002.
    ENDIF.
    CALL FUNCTION 'RS_VARIANT_EXISTS'
      EXPORTING
        report              = 'RFKKZE00'
        variant             = p_vari
      IMPORTING
        r_c                 = gv_subrc
      EXCEPTIONS
        not_authorized      = 1
        no_report           = 2
        report_not_existent = 3
        report_not_supplied = 4
        OTHERS              = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    IF gv_subrc NE 0.
      SET CURSOR FIELD p_vari.
      MESSAGE e003 WITH p_vari.
    ENDIF.
  ENDIF.





*************************************************************************
* Start-OF-SELECTION
**************************************************************************
START-OF-SELECTION.


  MOVE ph_name TO lv_name.


  PERFORM read_file USING lv_name.


  PERFORM split_file.
*  PERFORM split_file_new.

  PERFORM process_file.


  LOOP AT gt_file INTO gs_file.
    MOVE gs_file-biline TO gs_biline.
    APPEND gs_biline TO gt_biline.
  ENDLOOP.

  PERFORM create_file TABLES gt_biline
                      USING  ph_new.

  CLOSE DATASET ph_new.


  IF p_stap = 'X'.
    CLEAR:  gv_lfdnr.
    DO.
      CONCATENATE gc_dirzst sy-datum+6(2) sy-datum+4(2) sy-datum+2(2) '-' gv_lfdnr
        INTO gv_zlrunid.
      SELECT COUNT(*)
        FROM  fkkzest
        WHERE runid = gv_zlrunid.
      IF sy-subrc = 0.
        gv_lfdnr = gv_lfdnr + 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

* Sperren setzen
    CALL FUNCTION 'ENQUEUE_E_LOCK_TVARVC'.

* Zahlstapel
    CLEAR gs_tvarvc.
    gs_tvarvc-name = 'Z_FPB3_AB_ZST_IDENT'.
    gs_tvarvc-type = 'P'.
    gs_tvarvc-low  = gv_zlrunid.
    MODIFY tvarvc FROM gs_tvarvc.
    APPEND gs_tvarvc TO gt_tvarvc.


    COMMIT WORK AND WAIT.

* Entsperren
    CALL FUNCTION 'DEQUEUE_E_LOCK_TVARVC'.





    SUBMIT rfkkze00 VIA SELECTION-SCREEN USING SELECTION-SET p_vari
*    with p_runid = gv_zlrunid
     WITH r_norm = 'X'
     WITH as_fname = ph_new
*          WITH r_err = r_err
*          WITH r_rst = r_rst
      WITH p_xprot = p_xprot
      WITH p_xclos = p_xclos
      WITH p_xbuch = p_xbuch
      WITH p_xcont = p_xcont
*          WITH p_xsofst = p_xsofst
*          WITH p_strdt = p_strdt
*          WITH p_strtm = p_strtm
*          WITH p_xpara = p_xpara
*          WITH p_xfltr = p_xfltr
*          WITH p_xlist = p_xlist
*          WITH p_mekey = p_mekey
*          WITH p_tgserv = p_tgserv
*          WITH max_jobs = max_jobs                   " Note 1835848
*          WITH p_uc    = p_uc
*          WITH p_nuc   = p_nuc.
             AND RETURN.
  ENDIF.


*---------------------------------------------------------------------
* END-OF-SELECTION
*---------------------------------------------------------------------
END-OF-SELECTION.
  PERFORM ausgabe.



*&---------------------------------------------------------------------*
*&      Form  READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_NAME  text
*----------------------------------------------------------------------*
FORM read_file  USING    plv_name TYPE filename-fileextern.

  DATA: ls_file_line TYPE bilinetext,
        ls_file      TYPE file_structure,
        cnt_pc       TYPE i,
        ls_attr      TYPE tbidata_attr.

  DATA: lv_file_bom      TYPE sychar01,
        lv_file_encoding TYPE sychar01.

  DATA: lv_header TYPE i.
  DATA: lv_stype TYPE bfkkzk-stype.

*   Validate physical file name
  CALL FUNCTION 'FILE_VALIDATE_NAME'
    EXPORTING
      logical_filename  = gc_lgname
    CHANGING
      physical_filename = plv_name
    EXCEPTIONS
      OTHERS            = 99.
  IF sy-subrc <> 0.
    MESSAGE i800(29) WITH plv_name.
    EXIT.
  ENDIF.


* Check if File is UTF-8
  TRY.
      CALL METHOD cl_abap_file_utilities=>check_utf8
        EXPORTING
          file_name = plv_name
          max_kb    = 0
        IMPORTING
          bom       = lv_file_bom
          encoding  = lv_file_encoding.

    CATCH  cx_sy_file_open
           cx_sy_file_authority
           cx_sy_file_io.
      CLEAR: lv_file_bom, lv_file_encoding.
  ENDTRY.

  IF p_nuni = 'X'.
    OPEN DATASET plv_name FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
    IF sy-subrc GT 0.
      MESSAGE i800(29) WITH plv_name.
      IF sy-batch = 'X'.
        EXIT.
      ELSE.
        LEAVE TO SCREEN 1000.
      ENDIF.
    ENDIF.
  ELSEIF p_uni = 'X'.
    OPEN DATASET plv_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc GT 0.
      MESSAGE i800(29) WITH plv_name.
      IF sy-batch = 'X'.
        EXIT.
      ELSE.
        LEAVE TO SCREEN 1000.
      ENDIF.
    ENDIF.
  ENDIF.

  REFRESH gt_file.

  cnt_pc = 1.

  DO.
    CLEAR: ls_file.
    READ DATASET plv_name INTO ls_file-biline.
    IF sy-subrc GT 0.
      EXIT.
    ENDIF.
*     Only files for data transfer can be opened here
*     Every line of the input file can begin with allowed characters only
    IF NOT ls_file-biline(1) CO '0123456789'.
      MESSAGE e801(29) WITH plv_name.
    ENDIF.                                               " Note 1509883
    MOVE ls_file-biline(1) TO lv_stype.
    MOVE lv_stype TO ls_file-stype.

    IF lv_stype EQ '0'.
      PERFORM descriptions_fill USING ls_file-stype
                                CHANGING ls_attr.
    ELSE.

      MOVE ls_file-biline+1(30) TO ls_file-structname.
      PERFORM get_attributes USING ls_file-stype
                                   ls_file-structname
                             CHANGING ls_attr.

    ENDIF.
    MOVE: ls_attr-text TO ls_file-ddtext,
          ls_attr-structname TO ls_file-structname.

    IF ls_file-biline(1) = gc_stype_hdr.
      lv_header = lv_header + 1.
    ENDIF.
    APPEND ls_file TO gt_file.


  ENDDO.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DESCRIPTIONS_FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_FILE_STYPE  text
*      <--P_LS_ATTR  text
*----------------------------------------------------------------------*
FORM descriptions_fill  USING    pls_file_stype TYPE stype_z_kk
                        CHANGING pls_attr TYPE tbidata_attr.

  DATA: ld_dd02v TYPE dd02v,
        lt_dd03p TYPE dd03ttyp.
  DATA: lv_structname TYPE ddobjname.

  DATA: lv_attr TYPE tbidata_attr.

* Struktue Zahlungsstapel fest vorgegeben
  lv_structname = 'BFKKZGR00'.

  MOVE pls_file_stype TO lv_attr-stype.
  MOVE: lv_structname TO lv_attr-structname_orig,
        lv_structname TO lv_attr-structname.

  IF lv_structname IS NOT INITIAL.
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = lv_structname
        langu         = sy-langu
      IMPORTING
        dd02v_wa      = ld_dd02v
      TABLES
        dd03p_tab     = lt_dd03p
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF ld_dd02v IS INITIAL.
      CLEAR lv_attr-structname.
    ELSE.
      IF lv_attr-text IS INITIAL.
        MOVE ld_dd02v-ddtext TO lv_attr-text.
      ENDIF.
      IF lv_attr-dd03p[] IS INITIAL.
        MOVE lt_dd03p TO lv_attr-dd03p.
      ENDIF.
    ENDIF.
  ELSE.
*    MESSAGE e464.
  ENDIF.

  MOVE lv_attr TO pls_attr.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_ATTRIBUTES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_FILE_STYPE  text
*      -->P_LS_FILE_STRUCTNAME  text
*      <--P_LS_ATTR  text
*----------------------------------------------------------------------*
FORM get_attributes  USING    pls_file_stype TYPE stype_z_kk
                              pls_file_structname TYPE bi_structname
                     CHANGING pls_attr  TYPE tbidata_attr.

  DATA: ld_dd02v TYPE dd02v,
        lt_dd03p TYPE dd03ttyp.
  DATA: ld_tabix  TYPE sy-tabix.
  DATA: lv_attr TYPE tbidata_attr.

  CLEAR pls_attr.
  READ TABLE mpt_attr INTO lv_attr
  WITH KEY stype = pls_file_stype
           structname_orig = pls_file_structname.

*  if found, nothing more to do.
  IF sy-subrc NE 0.
*   Not found in attrs, must be constructed
    MOVE pls_file_stype TO lv_attr-stype.
    MOVE: pls_file_structname TO lv_attr-structname_orig,
          pls_file_structname TO lv_attr-structname.
  ELSE.
    MOVE sy-tabix TO ld_tabix.
  ENDIF.

  IF ( NOT lv_attr-structname IS INITIAL ) AND
     ( lv_attr-dd03p[] IS INITIAL ).
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = lv_attr-structname
        langu         = sy-langu
      IMPORTING
        dd02v_wa      = ld_dd02v
      TABLES
        dd03p_tab     = lt_dd03p
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    IF ld_dd02v IS INITIAL.
      CLEAR lv_attr-structname.
    ELSE.
      IF lv_attr-text IS INITIAL.
        MOVE ld_dd02v-ddtext TO lv_attr-text.
      ENDIF.
      IF lv_attr-dd03p[] IS INITIAL.
        MOVE lt_dd03p TO lv_attr-dd03p.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE lv_attr TO pls_attr.

  IF ld_tabix GT 0.
    MODIFY mpt_attr FROM pls_attr INDEX ld_tabix.
  ELSE.
    APPEND pls_attr TO mpt_attr.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SPLIT_FILE_OLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM split_file_old.


*  DATA: ls_bfkkzk TYPE bfkkzk,
*        ls_bfkkzp TYPE bfkkzp.
*
*  DATA: h_tabix TYPE sy-tabix.
*  DATA: ls_file_h TYPE file_structure.
*
*  DATA: lv_counter(6) TYPE n,
*        lv_betrz      TYPE betrz_kk.
*
*  DATA: lv_add TYPE char1.
*
*
*  LOOP AT gt_cust INTO gs_cust.
*    LOOP AT gt_file INTO gs_file.
*
*      h_tabix = sy-tabix.
*
*
*      ON CHANGE OF  gs_file-stype.
*
*        IF gs_file-stype = '1'.           "Header
*          CLEAR lv_add.
*          MOVE gs_file TO gs_header.
**          IF gt_file_new IS NOT INITIAL.
**            INSERT LINES OF gt_file_new INTO gt_file.
**            CLEAR gt_file_new.
**          ENDIF.
*        ENDIF.
*
*
*        IF gs_file-stype = '2'.          "Positionen
*
*          MOVE gs_file-biline TO ls_bfkkzp.
*          IF ls_bfkkzp-selt1 = gs_cust-selt1.
*            APPEND gs_file TO gt_file_del.
**            h_tabix = sy-tabix.
***          Kopfdaten werden nur einmal aufgebaut.
*            IF lv_add = space.
*              MOVE gs_header-biline TO ls_bfkkzk.
***            Neuer Zahlstapel und Abstimmschlüssel für HEADER
*              PERFORM get_new_zs_and_as CHANGING ls_bfkkzk.
*              MOVE gs_cust-xzaus TO ls_bfkkzk-xzaus.              "Feld XZSAUS
**             Belegart in den neuen Header
*              IF gs_cust-blart IS NOT INITIAL.
*                MOVE gs_cust-blart TO ls_bfkkzk-blart.
*              ENDIF.
*              MOVE ls_bfkkzk TO gs_header-biline.
*              APPEND gs_header TO gt_file_new.
*              lv_add = 'X'.
*            ENDIF.
***          Aufbereiten der Positioen
*
*            APPEND gs_file TO gt_file_new.
*
**            DELETE TABLE gt_file FROM gs_file.
*            LOOP AT gt_file INTO gs_file_new
*             FROM ( h_tabix + 1 ).
*              IF gs_file_new-structname = 'BFKKZS' OR
*                 gs_file_new-structname = 'BFKKZV'.
*                APPEND gs_file_new TO gt_file_new.
*                APPEND gs_file_new TO gt_file_del.
**                DELETE TABLE gt_file FROM gs_file_new.
*              ELSE.
*                EXIT.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
*
*      ENDON.
*
*    ENDLOOP.
*
*    LOOP AT gt_file_del INTO gs_file_del.
*
*      DELETE TABLE gt_file FROM gs_file_del.
*
*
*    ENDLOOP.
*
*    CLEAR gt_file_del.
*
*
**    IF gt_file_new IS NOT INITIAL.
**      APPEND LINES OF gt_file_new TO gt_file.
**    ENDIF.
*
*  ENDLOOP.
*




*  READ TABLE gt_file INTO gs_file WITH
*  KEY structname = 'BFKKZK'.
*  MOVE gs_file TO gs_header.
*
*  LOOP AT gt_file INTO gs_file.
*    IF gs_file-structname = 'BFKKZP'.
*      ADD 1 TO gv_position.
*      IF gv_position GT p_split.
***      Hier den neuen Zahlstapel und den neuen Abstimmschlüssel in den Header schreiben ??
*        MOVE gs_header-biline TO ls_bfkkzk.
*        PERFORM get_new_zs_and_as CHANGING ls_bfkkzk.
*        MOVE ls_bfkkzk TO gs_header-biline.
*        INSERT gs_header INTO gt_file.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*  LOOP AT gt_file INTO gs_file.
*    CLEAR: lv_counter, lv_betrz.
*
*    IF gs_file-structname = 'BFKKZK'.
*      h_tabix = sy-tabix.
*      MOVE gs_file-biline TO ls_bfkkzk.
*      LOOP AT gt_file INTO ls_file_h FROM ( h_tabix + 1 ).
*        IF ls_file_h-structname = 'BFKKZP'.
*          MOVE ls_file_h-biline TO ls_bfkkzp.
*          ADD 1 TO lv_counter.
*          ADD ls_bfkkzp-betrz TO lv_betrz.
*        ENDIF.
*        IF ls_file_h-structname = 'BFKKZK'.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*      MOVE lv_counter TO ls_bfkkzk-ksump.
*      CLEAR: ls_bfkkzk-ktsus, ls_bfkkzk-ktsuh.
*      IF lv_betrz GE 0.
*        MOVE lv_betrz TO ls_bfkkzk-ktsus.
*      ELSE.
*        MOVE lv_betrz TO ls_bfkkzk-ktsuh.
*      ENDIF.
*      MOVE ls_bfkkzk TO gs_file-biline.
*      MODIFY gt_file FROM gs_file.
*    ENDIF.
*
*    MOVE gs_file-biline TO gs_biline.
*    APPEND gs_biline TO gt_biline.
*
*  ENDLOOP.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  GET_NEW_ZS_AND_AS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_BFKKZK  text
*----------------------------------------------------------------------*
FORM get_new_zs_and_as  CHANGING pls_bfkkzk STRUCTURE bfkkzk.

  DATA: sign(1) TYPE c.
  DATA: vorne      TYPE string,
        hinten     TYPE string,
        helpstring TYPE string.

  DATA: len TYPE i.
  DATA  cnt TYPE i.
  DATA: hcnt TYPE i.
  DATA: len2 TYPE i.    "Nuss 26.10.2017

  DATA: keyz1_safe TYPE keyz1_kk.
  DATA: fikey_safe TYPE fikey_kk.
  DATA: ls_dfkkzk   TYPE dfkkzk,
        ls_dfkksumc TYPE dfkksumc.

  DATA: ls_bfkkzk TYPE bfkkzk,
        lt_bfkkzk TYPE TABLE OF bfkkzk.

  DATA: lt_file TYPE t_tbiline_data,
        ls_file TYPE file_structure.

  DATA: lv_lfdnr  TYPE n LENGTH 4.

* Tabelle mit den Köpfen Sammeln
  LOOP AT gt_file INTO ls_file
       WHERE stype = '1'.
    MOVE ls_file-biline TO ls_bfkkzk.
    APPEND ls_bfkkzk TO lt_bfkkzk.
  ENDLOOP.

  IF gs_cust-prefix IS INITIAL.
    MOVE pls_bfkkzk-keyz1 TO keyz1_safe.
* Neuer Zahlstapel.
    len = strlen( keyz1_safe ).
    CLEAR cnt.
    DO len TIMES.
      IF cnt GE 1.
        hcnt = ( cnt - 1 ).
      ENDIF.
      sign = pls_bfkkzk-keyz1+cnt(1).
      IF sign CN '123456789'.
        CONCATENATE vorne sign INTO vorne.
        SHIFT keyz1_safe LEFT BY 1 PLACES.
      ENDIF.
      IF sign CO '123456789'.
        EXIT.
      ENDIF.
      ADD 1 TO cnt.
    ENDDO.
    MOVE keyz1_safe TO hinten.


    ADD 1 TO hinten.
    CONCATENATE vorne hinten INTO keyz1_safe.

* Prüfen, ob der neue Zahlstapel in der Datenbank vorliegt.
    DO.
      CLEAR ls_dfkkzk.
      SELECT SINGLE * FROM dfkkzk INTO ls_dfkkzk
        WHERE keyz1 = keyz1_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO keyz1_safe.
      ENDIF.
    ENDDO.

* Prüfen, ob der neue Zahlstapel in der Datei vorliegt.
    DO.
      READ TABLE lt_bfkkzk INTO ls_bfkkzk
        WITH KEY keyz1 = keyz1_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO keyz1_safe.
      ENDIF.
    ENDDO.

    MOVE keyz1_safe TO pls_bfkkzk-keyz1.


* Abstimmschlüssel = neuer Zahlstapel
* Prüfen, ob der Abstimmschlüssel in der Datenbank vorliegt.
    MOVE keyz1_safe TO fikey_safe.
    DO.
      SELECT SINGLE * FROM dfkksumc INTO ls_dfkksumc
        WHERE fikey = fikey_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO fikey_safe.
      ENDIF.
    ENDDO.

* Ist der Abstimmschlüssel in der Tabelle
    DO.
      READ TABLE lt_bfkkzk INTO ls_bfkkzk
        WITH KEY fikey = fikey_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO fikey_safe.
      ENDIF.
    ENDDO.

    MOVE fikey_safe TO pls_bfkkzk-fikey.

  ELSE.

** Nuss Anpassung 26.10.2017
*   lv_lfdnr = '0001'.
*** Ist der Zahlstapel bereits in der Datenbank?
*    DO.
*      CONCATENATE gs_cust-prefix lv_lfdnr INTO keyz1_safe.
*      SELECT COUNT(*)
*        FROM  dfkkzk
*        WHERE keyz1 = keyz1_safe.
*      IF sy-subrc = 0.
*        lv_lfdnr = lv_lfdnr + 1.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
***  Ist der Zahlstapel in der Datei enthalten?
*    DO.
*      CONCATENATE gs_cust-prefix lv_lfdnr INTO keyz1_safe.
*      READ TABLE lt_bfkkzk INTO ls_bfkkzk
*        WITH KEY keyz1 = keyz1_safe.
*      IF sy-subrc = 0.
*        lv_lfdnr = lv_lfdnr + 1.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
*
*    MOVE keyz1_safe TO pls_bfkkzk-keyz1.
*
***  Abstimmschlüssel
***  Bereits in Datenbank?
*    MOVE keyz1_safe TO fikey_safe.
*    DO.
*      SELECT COUNT(*) FROM dfkksumc
*        WHERE fikey = fikey_safe.
*      IF sy-subrc = 0.
*        lv_lfdnr = lv_lfdnr + 1.
*        CONCATENATE gs_cust-prefix lv_lfdnr INTO fikey_safe.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
**   In der Tabelle ?
*    DO.
*      READ TABLE lt_bfkkzk INTO ls_bfkkzk
*        WITH KEY fikey = fikey_safe.
*      IF sy-subrc EQ 0.
*        lv_lfdnr = lv_lfdnr + 1.
*        CONCATENATE gs_cust-prefix lv_lfdnr INTO fikey_safe.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDDO.
*
*    MOVE fikey_safe TO pls_bfkkzk-fikey.
    len2 = strlen( gs_cust-prefix ).
    MOVE pls_bfkkzk-keyz1 TO hinten.
    MOVE gs_cust-prefix TO vorne.
    SHIFT hinten LEFT BY len2 PLACES.
    MOVE hinten TO helpstring.

* Neuer Zahlstapel.
    len = strlen( helpstring ).
    CLEAR cnt.
    DO len TIMES.
      sign = helpstring(1).
      IF sign CN '123456789'.
        CONCATENATE vorne sign INTO vorne.
        SHIFT helpstring LEFT BY 1 PLACES.
      ENDIF.
      IF sign CO '123456789'.
        EXIT.
      ENDIF.
      ADD 1 TO cnt.
    ENDDO.
    MOVE helpstring TO hinten.

    ADD 1 TO hinten.
    CONCATENATE vorne hinten INTO keyz1_safe.

* Prüfen, ob der neue Zahlstapel in der Datenbank vorliegt.
    DO.
      CLEAR ls_dfkkzk.
      SELECT SINGLE * FROM dfkkzk INTO ls_dfkkzk
        WHERE keyz1 = keyz1_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO keyz1_safe.
      ENDIF.
    ENDDO.

* Prüfen, ob der neue Zahlstapel in der Datei vorliegt.
    DO.
      READ TABLE lt_bfkkzk INTO ls_bfkkzk
        WITH KEY keyz1 = keyz1_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO keyz1_safe.
      ENDIF.
    ENDDO.

    MOVE keyz1_safe TO pls_bfkkzk-keyz1.

* Abstimmschlüssel = neuer Zahlstapel
* Prüfen, ob der Abstimmschlüssel in der Datenbank vorliegt.
    MOVE keyz1_safe TO fikey_safe.
    DO.
      SELECT SINGLE * FROM dfkksumc INTO ls_dfkksumc
        WHERE fikey = fikey_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO fikey_safe.
      ENDIF.
    ENDDO.

* Ist der Abstimmschlüssel in der Tabelle
    DO.
      READ TABLE lt_bfkkzk INTO ls_bfkkzk
        WITH KEY fikey = fikey_safe.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        ADD 1 TO hinten.
        CONCATENATE vorne hinten INTO fikey_safe.
      ENDIF.
    ENDDO.

    MOVE fikey_safe TO pls_bfkkzk-fikey.
** <-- Nuss Anpassung 26.10.2017

  ENDIF.



* pls_bfkkzk-keyz1.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_BILINE  text
*      -->P_PH_NEW  text
*----------------------------------------------------------------------*
FORM create_file  TABLES   pt_biline
                  USING    pph_new TYPE filename-fileextern.

  DATA: ls_biline TYPE bilinetext.

  OPEN DATASET pph_new FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  LOOP AT pt_biline INTO ls_biline.
    TRANSFER ls_biline TO pph_new.
  ENDLOOP.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_file .

  DATA: ls_header TYPE file_structure.
  DATA: lt_file_help   TYPE t_tbiline_data,
        ls_file_help   TYPE file_structure,
        h_tabix        LIKE sy-tabix,
        lv_cnt         TYPE i,
        ls_bfkkzk      TYPE bfkkzk,
        ls_bfkkzp      TYPE bfkkzp,
        lv_betrz       TYPE betrz_kk,
        lv_betrz_h     TYPE betrz_kk,    "Nuss 02.02.2018
        lv_betrzhelp   TYPE betrz_kk,
        lv_betrzhelp_h TYPE betrz_kk,    "Nuss 02.02.2018
        lv_vorg        TYPE stype_z_kk,    "Nuss 12.10.2017
        lv_del         TYPE flag.          "Nuss 12.10.2017

  LOOP AT gt_file INTO gs_file.

    CLEAR: ls_header, ls_bfkkzk.
    IF gs_file-stype = '1'.
      MOVE gs_file TO ls_header.
      lv_vorg = gs_file-stype.         "Nuss 12.10.2017
      CLEAR lv_del.                    "Nuss 12.10.2017
      MOVE ls_header-biline TO ls_bfkkzk.
      CLEAR: lv_cnt, lv_betrz.
      CLEAR: lv_betrz_h.               "Nuss 07.02.2017
      h_tabix = sy-tabix.
      LOOP AT gt_file INTO ls_file_help FROM ( h_tabix + 1 ).
***     --> Nuss 12.10.2017
***     Prüfen bei Filetype 1, ob Vorgänger auch ein Kopf war
***     Wenn ja, den Vorgänger löschen
        IF ls_file_help-stype = '1'.
          IF lv_vorg = '1'.
            DELETE gt_file INDEX h_tabix.
            lv_del = 'X'.
          ENDIF.
          EXIT.
        ENDIF.
***   <-- Nuss 12.10.2017

        IF ls_file_help-stype = '2'.
          lv_vorg = ls_file_help-stype.         "Nuss 12.10.2017
          ADD 1 TO lv_cnt.
          MOVE ls_file_help-biline TO ls_bfkkzp.
***       Format des Betrags enthält Kommas
          IF ls_bfkkzp-betrz CA ','.
            CALL FUNCTION 'MOVE_CHAR_TO_NUM'
              EXPORTING
                chr             = ls_bfkkzp-betrz
              IMPORTING
                num             = lv_betrzhelp
              EXCEPTIONS
                convt_no_number = 1
                convt_overflow  = 2
                OTHERS          = 3.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.

**          --> Nuss 02.02.2018
            IF lv_betrzhelp GE 0.
              ADD lv_betrzhelp TO lv_betrz.
            ELSE.
              ADD lv_betrzhelp TO lv_betrz_h.
            ENDIF.
*             ADD lv_betrzhelp TO lv_betrz.
**         <-- Nuss 02.02.2018
            MOVE lv_betrzhelp TO ls_bfkkzp-betrz.  "Nuss 04.12.2017


          ELSE.
***         Format enthält keine Kommas
**          --> Nuss 02.02.2018
            IF ls_bfkkzp-betrz GE 0.
              ADD ls_bfkkzp-betrz TO lv_betrz.
            ELSE.
              ADD ls_bfkkzp-betrz TO lv_betrz_h.
            ENDIF.
*            ADD ls_bfkkzp-betrz TO lv_betrz.
**         <-- Nuss 02.02.2018
          ENDIF.

          MOVE ls_bfkkzp TO ls_file_help-biline.
          MODIFY gt_file FROM ls_file_help.

        ENDIF.
**      --> Nuss 12.10.2017
        IF ls_file_help-stype = '3' OR
           ls_file_help-stype = '4'.
          lv_vorg = ls_file_help-stype.
        ENDIF.
**      <-- Nuss 12.10.2017

      ENDLOOP.
**    Anzahl der Positionen, Sollsumme und Habensumme der Positionen
**    in den Kopf eintragen.
      CHECK lv_del IS INITIAL.            "Nicht nach löschen eines Vorgängers  Nuss 12.10.2017
      MOVE lv_cnt TO ls_bfkkzk-ksump.

**     --> Nuss 02.02.2018
*      IF lv_betrz GE 0.
*        MOVE lv_betrz TO ls_bfkkzk-ktsus.
*      ELSE.
*        MOVE lv_betrz TO ls_bfkkzk-ktsuh.
*      ENDIF.
      MOVE lv_betrz   TO ls_bfkkzk-ktsus.
**    --> Nuss 07.02.2018
**    Haben Beträge mit -1 multiplizieren
      IF lv_betrz_h LT 0.
        MULTIPLY lv_betrz_h BY -1.
      ENDIF.
**    <-- Nuss 07.02.2018
      MOVE lv_betrz_h TO ls_bfkkzk-ktsuh.
**    <-- Nuss 02.02.2018


** -->   Format der Ziffern KTSUS oder KZSUH enthält Kommas
      IF ls_bfkkzk-ktsus CA ','.
        CALL FUNCTION 'MOVE_CHAR_TO_NUM'
          EXPORTING
            chr             = ls_bfkkzk-ktsus
          IMPORTING
            num             = lv_betrzhelp
          EXCEPTIONS
            convt_no_number = 1
            convt_overflow  = 2
            OTHERS          = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        MOVE lv_betrzhelp TO ls_bfkkzk-ktsus.
      ENDIF.
      IF ls_bfkkzk-ktsuh CA ','.
        CALL FUNCTION 'MOVE_CHAR_TO_NUM'
          EXPORTING
            chr             = ls_bfkkzk-ktsuh
          IMPORTING
            num             = lv_betrzhelp
          EXCEPTIONS
            convt_no_number = 1
            convt_overflow  = 2
            OTHERS          = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        MOVE lv_betrzhelp TO ls_bfkkzk-ktsuh.
      ENDIF.
** <-- Format der Ziffern enthält Kommas

** --> Nuss 02.02.2018
** Haben-Beträge mit -1 Multiplizieren, wenn sie negativ sind
      IF ls_bfkkzk-ktsuh LT 0.
        MULTIPLY ls_bfkkzk-ktsuh BY -1.
      ENDIF.
** <-- Nuss 02.02.2018

      MOVE ls_bfkkzk TO ls_header-biline.
      CLEAR ls_bfkkzk.                             "Nuss 07.02.2018
      MODIFY gt_file FROM ls_header.

    ENDIF.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  READ_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_customizing .

  IF gv_cust_ok IS INITIAL.
    SELECT * FROM /adesso/zs_split INTO TABLE gt_cust.
    IF sy-subrc = 0.
      gv_cust_ok = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  SPLIT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM split_file.


  DATA: ls_bfkkzk TYPE bfkkzk,
        ls_bfkkzp TYPE bfkkzp.

  DATA: h_tabix TYPE sy-tabix.
  DATA: ls_file_h TYPE file_structure.

  DATA: lv_counter(6) TYPE n,
        lv_betrz      TYPE betrz_kk.

  DATA: lv_add   TYPE char1,
        lv_keyz1 TYPE keyz1_kk,
        lv_del   TYPE char1,
        lv_bukrs TYPE bukrs.    "Nuss 04.12.2017

  DATA: ls_position TYPE file_structure.

  LOOP AT gt_cust INTO gs_cust.

    CLEAR gt_file_new.

    LOOP AT gt_file INTO gs_file.

      h_tabix = sy-tabix.

      IF gs_file-stype = '0'.
        CONTINUE.
      ENDIF.

      IF gs_file-stype = '1'.
        MOVE gs_file TO gs_header.
        MOVE gs_header-biline TO ls_bfkkzk.



**      --> Nuss 04.12.2017 Prüfen Buchungskreis Kopf
        IF ls_bfkkzk-bukrs NE gs_cust-bukrs.
          CONTINUE.
        ENDIF.
**      <-- Nuss 04.12.2017

**    --> Nuss 12.12.2017 Prüfen Bankverrechnungskonto Kopf
        IF ls_bfkkzk-bvrko NE gs_cust-bvrko_org.
          CONTINUE.
        ENDIF.
**    <-- Nuss 12.12.2017

        IF ls_bfkkzk-keyz1 NE lv_keyz1.
          CLEAR lv_add.
        ENDIF.
        lv_keyz1 = ls_bfkkzk-keyz1.
      ENDIF.

      IF gs_file-stype = '2'.
        MOVE gs_file-biline TO ls_bfkkzp.
        IF ls_bfkkzp-selt1 = gs_cust-selt1
        AND ls_bfkkzp-bukrs = gs_cust-bukrs         "Nuss 04.12.2017
          AND ls_bfkkzp-bvrko = gs_cust-bvrko_org.   "Nuss 04.12.2017

          IF lv_add IS INITIAL.
            APPEND gs_header TO gt_file_new.
            lv_add = 'X'.
          ENDIF.
          MOVE gs_file TO gs_file_new.
          MOVE gs_file_new-biline TO ls_bfkkzk.
*      Hier die Datei New bearbeiten
          APPEND gs_file_new TO gt_file_new.
          DELETE gt_file  INDEX h_tabix.
          lv_del = 'X'.
        ELSE.
          CLEAR lv_del.
        ENDIF.
      ENDIF.

      IF gs_file-stype = '3'.
        IF lv_del = 'X'.
          DELETE gt_file INDEX h_tabix.
          APPEND gs_file TO gt_file_new.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF gs_file-stype = '4'.
        IF lv_del = 'X'.
          DELETE gt_file INDEX h_tabix.
          APPEND gs_file TO gt_file_new.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

    ENDLOOP.

    LOOP AT gt_file_new INTO gs_file_new.
*  Neue Köpfe anpassen.
      IF gs_file_new-stype = '1'.
        MOVE gs_file_new TO gs_header.
        MOVE gs_header-biline TO ls_bfkkzk.

        MOVE ls_bfkkzk-keyz1 TO gs_out-zs_old.      "Nuss 16.01.2018

*       Neuer Zahlstapel und Abstimmschlüssel
        PERFORM get_new_zs_and_as CHANGING ls_bfkkzk.

        MOVE ls_bfkkzk-keyz1 TO gs_out-zs_new.      "Nuss 16.01.2018
*      Buchungskreis
        IF gs_cust-bukrs_neu IS NOT INITIAL.
          MOVE gs_cust-bukrs_neu TO ls_bfkkzk-bukrs.
        ENDIF.
*      Belegart
        IF gs_cust-blart IS NOT INITIAL.
          MOVE gs_cust-blart TO ls_bfkkzk-blart.
        ENDIF.
*       Bankverrechnungskonto
        IF gs_cust-bvrko IS NOT INITIAL.
          MOVE gs_cust-bvrko TO ls_bfkkzk-bvrko.
        ENDIF.
*      Feld XZAUS
        MOVE gs_cust-xzaus TO ls_bfkkzk-xzaus.

        MOVE ls_bfkkzk TO gs_header-biline.
        APPEND gs_header TO gt_file.
      ELSEIF gs_file_new-stype = '2'.
        gs_out-posnew = 1.                    "Nuss 16.01.2018
        MOVE gs_file_new TO ls_position.
        MOVE ls_position-biline TO ls_bfkkzp.
*       Neuer Selektionstyp
        IF gs_cust-selt1_neu IS NOT INITIAL.
          MOVE gs_cust-selt1_neu TO ls_bfkkzp-selt1.
        ENDIF.
*      Buchungskreis
        IF gs_cust-bukrs_neu IS NOT INITIAL.
          MOVE gs_cust-bukrs_neu TO ls_bfkkzp-bukrs.
        ENDIF.
*      Belegart
        IF gs_cust-blart IS NOT INITIAL.
          MOVE gs_cust-blart TO ls_bfkkzp-blart.
        ENDIF.
*       Bankverrechnungskonto
        IF gs_cust-bvrko IS NOT INITIAL.
          MOVE gs_cust-bvrko TO ls_bfkkzp-bvrko.
        ENDIF.
        MOVE ls_bfkkzp TO ls_position-biline.
        APPEND ls_position TO gt_file.
        COLLECT gs_out INTO gt_out.       "Nuss 16.01.2018
      ELSE.
        APPEND gs_file_new TO gt_file.
      ENDIF.



    ENDLOOP.

  ENDLOOP.

ENDFORM.


* --> Nuss 16.01.2018
*&---------------------------------------------------------------------*
*&      Form  AUSGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ausgabe .

  IF gt_out IS NOT INITIAL.
    IF p_stap IS INITIAL.
      FORMAT COLOR COL_GROUP.
      WRITE: /5 'Verarbeitung ohne Zahlungsstapelübernaheme.', AT sy-linsz space.
    ELSE.
      FORMAT COLOR COL_POSITIVE.
      WRITE: /5 'Verarbeitung mit Zahlungsstapelübernahme', AT sy-linsz space.
    ENDIF.
    FORMAT COLOR COL_BACKGROUND.
    SKIP.
    WRITE: /5 'Neue Übernahmedatei', ph_new, 'erstellt.'.
    SKIP.
    LOOP AT gt_out INTO gs_out.
      WRITE: /5 'Aus Zahlstapel', gs_out-zs_old, 'wurden', gs_out-posnew, 'Positionen in Zahlstapel', gs_out-zs_new, 'übertragen'.
    ENDLOOP.
  ELSE.
    WRITE: /5 'Es wurden keine Zahlstapel geplittet'.
  ENDIF.


ENDFORM.
* <-- Nuss 16.01.2018
