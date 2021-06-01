*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_MIG_UPDATE_BIRTHDT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_MIG_UPDATE_BIRTHDT MESSAGE-ID em
                                       LINE-SIZE 200.





CONSTANTS: co_marked(1)    TYPE c    VALUE 'X',
           co_notmarked(1) TYPE c    VALUE space.

TABLES: temfd, temob, temdb, temdbt.
TABLES: dd02t.

TYPES: BEGIN OF ty_import_uc,
        oldkey TYPE emg_oldkey,
        dttyp  TYPE emg_dttyp,
        data   TYPE xstring,
       END OF ty_import_uc.
DATA:  l_iimp TYPE TABLE OF temimport,
              wl_iimp TYPE temimport,
        w_iimp TYPE ty_import_uc.

DATA: rc LIKE sy-subrc,
      hc LIKE sy-subrc,
      knz_unicode TYPE c,
      zcp        LIKE tcp00-cpcodepage,
      r_lennr(2) TYPE x,
      ss_tabix   LIKE sy-tabix,
      sv_tabix   LIKE sy-tabix,
      h_len      TYPE i,
      lv_unicode TYPE abap_encod,
      h_seite(1) TYPE c.


DATA: imp TYPE ty_import_uc.
DATA: iimp TYPE ty_import_uc OCCURS 0 WITH HEADER LINE.

DATA: cl_view_nodata TYPE REF TO cl_abap_view_offlen.
DATA: himp_header TYPE tem_import_header.
DATA: cl_conv_in  TYPE REF TO cl_abap_conv_in_ce.
DATA: cl_conv_out TYPE REF TO cl_abap_conv_out_ce.

DATA: h_info LIKE teminfo.
DATA: cl_view_info TYPE REF TO cl_abap_view_offlen.

TYPES: BEGIN OF ty_strucinfo.
        INCLUDE STRUCTURE temdb_info.
TYPES: END   OF ty_strucinfo.
DATA: lt_strucinfo TYPE ty_strucinfo OCCURS 0,
      wa_strucinfo TYPE ty_strucinfo.


DATA: htemdb LIKE temdb OCCURS 10 WITH HEADER LINE,
      jtemdb LIKE temdb OCCURS 10 WITH HEADER LINE,
      must_temdb LIKE temdb OCCURS 10 WITH HEADER LINE.

TYPES: BEGIN OF ty_ref_z_structure,
         dttyp TYPE emg_dttyp,
         ref TYPE REF TO data,
         view TYPE REF TO cl_abap_view_offlen,
       END OF ty_ref_z_structure.
DATA: lt_z_structure TYPE ty_ref_z_structure OCCURS 0,
      wa_z_structure TYPE ty_ref_z_structure.

DATA: BEGIN OF itemdb OCCURS 10,
        dttyp LIKE temdb-dttyp,
        multi LIKE temdb-multi,
      END OF itemdb.
DATA: BEGIN OF itemdbt OCCURS 10,
        dttyp LIKE temdb-dttyp,
        strbez LIKE temdbt-strbez,
      END OF itemdbt.


*data: ipar_but000 TYPE /evuit/mt_bus000_di.
DATA: BEGIN OF par_but000,
         bu_sort1    TYPE bu_sort1,
         bu_sort2   TYPE bu_sort2,
         title      TYPE ad_title,
         name_org1  TYPE bu_nameor1,
         name_org2  TYPE bu_nameor2,
         name_org3  TYPE bu_nameor3,
         name_org4  TYPE bu_nameor4,
         legal_enty TYPE bu_legenty,
         name_last  TYPE bu_namep_l,
         name_first TYPE bu_namep_f,
         name_last2 TYPE bu_birthnm,
         title_aca1 TYPE ad_title1,
         title_aca2 TYPE ad_title2,
         title_royl TYPE ad_titles,
         prefix1    TYPE ad_prefix,
         prefix2    TYPE ad_prefix2,
         name1_text TYPE  bu_name1tx,
         xsexm      TYPE bu_xsexm,
         xsexf      TYPE bu_xsexf,
         birthdt    TYPE bu_birthdt,
         birthpl    TYPE bu_birthpl,
         partgrptyp TYPE bu_grptyp,
         name_grp1  TYPE bu_namegr1,
         name_grp2  TYPE bu_namegr2,
         name_lst2  TYPE bu_namepl2,
         namemiddle TYPE bu_namemid,
         xsexu      TYPE bu_xsexu,
         bu_langu   TYPE bu_langu,
         langu_corr TYPE bu_langu_corr,
        END OF par_but000.

DATA: BEGIN OF wa_data,
       partner TYPE bu_partner.
        INCLUDE STRUCTURE par_but000.
DATA:    END OF wa_data.
DATA: it_data LIKE STANDARD TABLE OF wa_data.


* Zähler
DATA: z_partner TYPE i,
      z_not_mig TYPE i,
      z_mig     TYPE i,
      z_no_part  TYPE i,
      z_firma   TYPE i,
      z_person  TYPE i,
      z_no_birthdt TYPE i,
      z_commit  TYPE i,
      z_update  TYPE i,
      z_irrelevant TYPE i,
      z_upderr  TYPE i.

* SAP-Strukturen
DATA: wa_but000_old  TYPE but000,
      wa_but000_new  TYPE but000.

DATA: wa_temksv TYPE temksv.


* Ausgabetabelle
DATA: BEGIN OF wa_ausgabe,
        partner_alt  LIKE but000-partner,
        partner      LIKE but000-partner,
        name_first   LIKE but000-name_first,
        name_last    LIKE but000-name_last,
        birthdt_quelle LIKE but000-birthdt,
        birthdt_old  LIKE but000-birthdt,
        birthdt_new  LIKE but000-birthdt,
        komment      TYPE char50,
      END OF wa_ausgabe.
DATA: it_ausgabe LIKE STANDARD TABLE OF wa_ausgabe.

DATA: counter(2)   TYPE n.

*****************************************************************************
* Selektionsbildschirm
*****************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
PARAMETERS: firma  LIKE temfd-firma DEFAULT 'WBD',
            object LIKE temfd-object DEFAULT 'PARTNER',
            file LIKE temfd-file DEFAULT 'PARTNER01.IMP',
*            filepath(64) DEFAULT '\\srv8705\migWBD1\Beladung\' LOWER CASE,
            filepath(64) DEFAULT '\\srv8705\WBD_MIG_BELADUNG\' LOWER CASE,
            qcp LIKE tcp00-cpcodepage DEFAULT '4103'.
SELECTION-SCREEN SKIP.
PARAMETERS: p_echt AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK bl1.

*******************************************************************************
* TOP-OF-PAGE
******************************************************************************
TOP-OF-PAGE.
  PERFORM seitenkopf.


********************************************************************************
* START-OF-SELECTION
********************************************************************************
START-OF-SELECTION.

* Codepage checken
  PERFORM check_cp USING qcp rc.
  IF rc NE 0.
    MESSAGE e000 WITH 'Codepage nicht vorhanden!'(003).
    EXIT.
  ENDIF.

* prepare codepage translation
  CALL FUNCTION 'ISU_M_UNICODE_CHECK'
    EXPORTING
      x_codepage     = qcp
    IMPORTING
      y_is_uc_system = knz_unicode.
  IF knz_unicode EQ co_marked.
    cl_view_nodata = cl_abap_view_offlen=>create_unicode16_view(
himp_header ).
    cl_view_info = cl_abap_view_offlen=>create_unicode16_view( h_info ).
  ELSE.
    cl_view_nodata = cl_abap_view_offlen=>create_legacy_view(
himp_header ).
    cl_view_info = cl_abap_view_offlen=>create_legacy_view( h_info ).
  ENDIF.
  lv_unicode = qcp.
  cl_conv_in  = cl_abap_conv_in_ce=>create(
                  encoding = lv_unicode input = iimp-data
                  ignore_cerr = abap_true replacement = '#' ).
  cl_conv_out = cl_abap_conv_out_ce=>create( encoding = lv_unicode ).

* check existence of migration object
  SELECT SINGLE * FROM temob WHERE firma  EQ firma
                               AND object EQ object.
  IF sy-subrc NE 0.
    MESSAGE e004 WITH 'Migrationsobjekt'(012) object.
    EXIT.
  ENDIF.

* get all information for the auto structures
  PERFORM get_struc_info.
  PERFORM create_customer_structure.

  SELECT * FROM temdb INTO TABLE jtemdb
                      WHERE firma  EQ firma
                        AND object EQ object
                        AND afeld  EQ space
                        AND gen    NE space.

  SELECT * FROM temdb WHERE firma  EQ firma
                        AND object EQ object
                        AND dttyp  NE space
                        AND afeld  EQ space
                        AND gen    NE space.

    MOVE-CORRESPONDING temdb TO itemdb.
    APPEND itemdb.

*   get structure description
    itemdbt-dttyp = itemdb-dttyp.
    SELECT SINGLE * FROM temdbt WHERE spras   EQ sy-langu
                                  AND firma   EQ firma
                                  AND object  EQ object
                                  AND n_level EQ temdb-n_level
                                  AND n_node  EQ temdb-n_node.
    IF sy-subrc NE 0 OR
       temdbt-strbez IS INITIAL.
      SELECT SINGLE * FROM dd02t WHERE tabname    = temdb-inpstruct
                                  AND ddlanguage = sy-langu
                                  AND as4local   = 'A'
                                  AND as4vers    = '0000'.
      IF sy-subrc EQ 0.
        itemdbt-strbez = dd02t-ddtext.
      ENDIF.
    ELSE.
      itemdbt-strbez = temdbt-strbez.
    ENDIF.
    APPEND itemdbt.

  ENDSELECT.



* get record types in the right order
  SORT jtemdb BY a_level a_node n_level n_node.

  PERFORM sort_temdb USING 0
                           0
                           rc.

  CLEAR: l_iimp, it_data.


  PERFORM get_data.


* Daten in ein lesbares Format konvertieren
  PERFORM convert_data.

  LOOP AT l_iimp INTO wl_iimp.

    IF wl_iimp-dttyp = 'BUT000'.
      MOVE wl_iimp-data TO par_but000.
      MOVE-CORRESPONDING par_but000 TO wa_data.
      MOVE wl_iimp-oldkey TO wa_data-partner.
      APPEND wa_data TO it_data.
      CLEAR: par_but000, wa_data.
    ENDIF.

  ENDLOOP.



*  Partner abarbeiten
  LOOP AT it_data INTO wa_data.
    ADD 1 TO z_partner.
*  Prüfen, ob der Partner migriert wurde

    SELECT SINGLE * FROM temksv INTO wa_temksv
      WHERE firma  = firma
        AND object = object
        AND oldkey = wa_data-partner.

*   Wenn nein, dann nächster Schleifendurchlauf
    IF sy-subrc NE 0.
      ADD 1 TO z_not_mig.
      CONTINUE.
    ELSE.
      ADD 1 TO z_mig.
**  BUT000 lesen
      CLEAR wa_but000_old.
      SELECT SINGLE * FROM but000 INTO wa_but000_old
        WHERE partner = wa_temksv-newkey.
**    Partner nicht in BUT000 (dürfte nicht vorkommen)
      IF sy-subrc NE 0.
        ADD 1 TO z_no_part.
        CONTINUE.
      ENDIF.

**    Partner ist eine Firma oder eine Gruppe
      IF ( wa_but000_old-type = '2' OR
           wa_but000_old-type = '3' ).
        ADD 1 TO z_firma.
        CONTINUE.
      ENDIF.
      ADD 1 TO z_person.
      CLEAR wa_but000_new.
      MOVE wa_but000_old TO wa_but000_new.
      MOVE wa_temksv-oldkey TO wa_ausgabe-partner_alt.
      MOVE wa_but000_new-partner TO wa_ausgabe-partner.
      MOVE wa_but000_new-name_first TO wa_ausgabe-name_first.
      MOVE wa_but000_new-name_last TO wa_ausgabe-name_last.
      MOVE wa_data-birthdt TO wa_ausgabe-birthdt_quelle.
**    Wenn kein Geburtsdtum aus der Quelle geliefert wird, dann nächste
      IF wa_data-birthdt IS INITIAL.
        MOVE 'Kein Geburtdatum in Quelle gepflegt' TO wa_ausgabe-komment.
        ADD 1 TO z_no_birthdt.
        APPEND wa_ausgabe TO it_ausgabe.
        CLEAR wa_ausgabe.
        CONTINUE.
      ENDIF.
      MOVE wa_but000_old-birthdt TO wa_ausgabe-birthdt_old.
      MOVE wa_data-birthdt TO wa_ausgabe-birthdt_new.
      MOVE wa_data-birthdt TO wa_but000_new-birthdt.
      IF wa_but000_old-birthdt = wa_but000_new-birthdt.
        wa_ausgabe-komment = 'Geb.Datum alt und Geb.Datum neu sind identisch'.
        ADD 1 TO z_irrelevant.
     ENDIF.
      APPEND wa_ausgabe TO it_ausgabe.
      CLEAR wa_ausgabe.

*      Wenn die Geburtsdatümer gleich sind, dann kein Update.
      IF wa_but000_old-birthdt = wa_but000_new-birthdt.
        CONTINUE.
      ENDIF.
    ENDIF.

* Update der BUT000 wenn gewünscht
    IF p_echt IS NOT INITIAL.
      UPDATE but000 FROM wa_but000_new.
      IF sy-subrc = 0.
        ADD 1 TO z_update.
        ADD 1 TO z_commit.
        IF z_commit = 500.
          CLEAR z_commit.
          COMMIT WORK.
        ENDIF.
      ELSE.
        ADD 1 TO z_upderr.
      ENDIF.
    ENDIF.
  ENDLOOP.


*  Im Echtlauf noch einen Commit hinterheschicken
  IF p_echt IS NOT INITIAL.
    COMMIT WORK.
  ENDIF.



***********************************************************************
* END-OF-SELECTION
**********************************************************************
END-OF-SELECTION.
  PERFORM protokoll.
  PERFORM ausgabe_liste.

*&---------------------------------------------------------------------*
*&      Form  CHECK_CP
*&---------------------------------------------------------------------*
FORM check_cp USING p_qcp
                    rc.

* local data defintions
  TABLES: tcp00.

* do some initializations
  rc = 0.
  SELECT SINGLE * FROM tcp00 WHERE cpcodepage = p_qcp.
  IF sy-subrc NE 0.
    rc = 1.
    EXIT.
  ENDIF.

ENDFORM.                                                    " CHECK_CP

*&---------------------------------------------------------------------*
*&      Form  GET_STRUC_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_struc_info.

  CALL FUNCTION 'ISU_M_CSTRUC_GET'
    EXPORTING
      x_firma     = firma
      x_object    = object
*     x_INPSTRUCT =
    TABLES
      xy_info     = lt_strucinfo
      xy_temdb    = must_temdb
    EXCEPTIONS
      not_found   = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SORT lt_strucinfo BY dttyp.

ENDFORM.                                       " GET_STRUC_INFO

*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOMER_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_customer_structure.

  DATA: lt_code TYPE rswsourcet,
        lt_struc_code TYPE rswsourcet.
  DATA: lv_line TYPE string.
  DATA: lv_pool LIKE sy-repid.
  DATA: lv_form_name(60) TYPE c.
  FIELD-SYMBOLS: <wa> TYPE any.

* start with program header
  APPEND 'program customer_data message-id em.' TO lt_code.

* add subroutines to create customer data objects
  LOOP AT lt_strucinfo INTO wa_strucinfo
                       WHERE dttyp NE '&ENDE '
                         AND dttyp NE '&INFO '
                         AND empty NE 'X'.

    CALL FUNCTION 'ISU_M_CUSTOMER_STRUCTURE'
      EXPORTING
        x_firma         = firma
        x_object        = object
        x_inpstruct     = wa_strucinfo-inpstruct
      TABLES
        y_source        = lt_struc_code[]
      EXCEPTIONS
        field_not_found = 1.
    IF sy-subrc EQ 0.
      CONCATENATE 'form Z_'                                 "#EC NOTEXT
                  wa_strucinfo-inpstruct
                  ' using p_ref type ref to data.'          "#EC NOTEXT
                  INTO lv_line.
      APPEND lv_line TO lt_code.
      APPEND LINES OF lt_struc_code TO lt_code.
      CONCATENATE 'create data p_ref like z_' wa_strucinfo-inpstruct
                  '.' INTO lv_line.
      APPEND lv_line TO lt_code.
      APPEND 'endform.' TO lt_code.
    ENDIF.

  ENDLOOP.

* the abap is complete - generate the code
  GENERATE SUBROUTINE POOL lt_code NAME lv_pool.
  LOOP AT lt_strucinfo INTO wa_strucinfo
                       WHERE dttyp NE '&ENDE '
                         AND dttyp NE '&INFO '
                         AND empty NE 'X'.
    CONCATENATE 'Z_' wa_strucinfo-inpstruct INTO lv_form_name.
    PERFORM (lv_form_name) IN PROGRAM (lv_pool) USING wa_z_structure-ref
    .
    ASSIGN wa_z_structure-ref->* TO <wa>.
    IF knz_unicode EQ co_marked.
      wa_z_structure-view = cl_abap_view_offlen=>create_unicode16_view(
      <wa> ).
    ELSE.
      wa_z_structure-view = cl_abap_view_offlen=>create_legacy_view(
      <wa> ).
    ENDIF.
    wa_z_structure-dttyp = wa_strucinfo-dttyp.
    APPEND wa_z_structure TO lt_z_structure.
  ENDLOOP.

ENDFORM.                                    " CREATE_CUSTOMER_STRUCTURE

*&---------------------------------------------------------------------*
*&      Form  SORT_TEMDB
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM sort_temdb USING p_level
                      p_node
                      p_rc.

  LOOP AT jtemdb WHERE a_level = p_level
                   AND a_node  = p_node.
    APPEND jtemdb TO htemdb.
    PERFORM sort_temdb USING jtemdb-n_level
                             jtemdb-n_node
                             rc.
  ENDLOOP.

ENDFORM.                               " SORT_TEMDB

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.

* local data definition
  DATA: h_int TYPE i.

* open import file
  PERFORM open_file USING file
                          filepath
                          'I'
                          rc.
  IF rc NE 0.
    hc = rc.
    CLEAR iimp.
    REFRESH iimp.
    MESSAGE e022 WITH file.
    EXIT.
  ENDIF.


* read all records from the file
  h_int = 0.
  REFRESH iimp.
  DO.

*   read next record from file
    PERFORM read_ds USING file
                          filepath
                          r_lennr
                          imp
                          qcp
                          zcp
                          rc.
    IF rc NE 0.
      EXIT.
    ENDIF.

*   different methods to interpret data portion
    IF imp-dttyp EQ '&INFO'.
*     * fill infostructure
      CALL METHOD cl_conv_in->read(
        EXPORTING
          view = cl_view_info
        IMPORTING
          data = h_info ).
    ELSE.
      CLEAR imp-data.
      CALL METHOD cl_conv_in->read( IMPORTING data = imp-data ).
      APPEND imp TO iimp.
      IF imp-dttyp EQ '&ENDE'.
        h_int = h_int + 1.
      ENDIF.
    ENDIF.
  ENDDO.

* close import file
  PERFORM close_file USING file
                           filepath.

ENDFORM.                                                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  CLOSE_FILE
*&---------------------------------------------------------------------*
FORM close_file USING    p_file
                         p_filepath.

* local variables
  DATA: h_filepath(70).

* close file

  CONCATENATE p_filepath p_file INTO h_filepath.

  CALL FUNCTION 'ISU_M_DATASET_BINARY_CLOSE'
    EXPORTING
      x_dataset = h_filepath.

ENDFORM.                               " CLOSE_FILE

*&---------------------------------------------------------------------*
*&      Form  OPEN_FILE
*&---------------------------------------------------------------------*
FORM open_file USING    p_file
                        p_filepath
                        p_ioa
                        rc.
* local variables
  DATA: h_filepath(70).

* open file in given mode
  rc = 0.

** Änderung Aufbau Dateiname
  CONCATENATE p_filepath p_file INTO h_filepath.

  CALL FUNCTION 'ISU_M_DATASET_BINARY_OPEN'
    EXPORTING
      x_dataset       = h_filepath
      x_mode          = p_ioa
    EXCEPTIONS
      file_open_error = 1.
  IF sy-subrc NE 0.
    rc = 1.
    EXIT.
  ENDIF.

ENDFORM.                                                    " OPEN_FILE

*&---------------------------------------------------------------------*
*&      Form  READ_DS
*&---------------------------------------------------------------------*
FORM read_ds USING p_file
                   p_filepath
                   p_lennr
                   p_line
                   p_qcp
                   p_zcp
                   rc.

* local variables
  DATA: h_filepath(70),
        h_record TYPE xstring.


* get record
  CONCATENATE p_filepath p_file INTO h_filepath.

  CALL FUNCTION 'ISU_M_DATASET_BINARY_READ'
    EXPORTING
      x_dataset        = h_filepath
    IMPORTING
      y_record         = h_record
    EXCEPTIONS
      file_eof_reached = 1.
  IF sy-subrc EQ 0.
    CALL METHOD cl_conv_in->reset( input = h_record ).
    CALL METHOD cl_conv_in->read(
      EXPORTING
        view = cl_view_nodata
      IMPORTING
        data = himp_header ).
    imp-oldkey = himp_header-oldkey.
    imp-dttyp  = himp_header-dttyp.
    rc = 0.
  ELSE.
    rc = 1.
  ENDIF.

ENDFORM.                                                    " READ_DS


*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATA
*&---------------------------------------------------------------------*
FORM convert_data.

  DATA: lv_string_out(3000) TYPE c.

  FIELD-SYMBOLS: <cust>.
  DATA: descr_ref TYPE REF TO cl_abap_typedescr.
  DATA: lv_col TYPE i.

* new data
  DATA:  l_tabix LIKE sy-tabix.



  ss_tabix = 1.
  LOOP AT iimp INTO w_iimp.
    sv_tabix = sy-tabix.
    READ TABLE lt_strucinfo INTO wa_strucinfo WITH KEY dttyp = w_iimp-dttyp.
    IF sy-subrc NE 0. CONTINUE. ENDIF.
    MOVE-CORRESPONDING w_iimp TO wl_iimp.
    r_lennr = wa_strucinfo-leng + 2.
    wl_iimp-leng = r_lennr.
    h_len = xstrlen( w_iimp-data ).
    IF h_len NE 0.
      l_tabix = sy-tabix.
*       do some initialization
      CLEAR lv_string_out.
      lv_col = 0.

*     fill customer structure
      READ TABLE lt_z_structure INTO wa_z_structure
                              WITH KEY dttyp = wl_iimp-dttyp.
      ASSIGN wa_z_structure-ref->* TO <cust>.
      CLEAR <cust>.
      CALL METHOD cl_conv_in->reset( input = w_iimp-data ).
      CALL METHOD cl_conv_in->read(
        EXPORTING
          view = wa_z_structure-view
        IMPORTING
          data = <cust> ).
      PERFORM convert_cust_to_string USING <cust>
                                 CHANGING lv_string_out.
      wl_iimp-data = lv_string_out.
    ENDIF.

*   write string to list
    APPEND wl_iimp TO l_iimp.

  ENDLOOP.



ENDFORM.                                                    " CONVERT_DATA

*&---------------------------------------------------------------------*
*&      Form  CONVERT_CUST_TO_STRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM convert_cust_to_string USING cust TYPE any
                            CHANGING xv_string_out .

  DATA: lv_col TYPE i.
  DATA: lv_string_out(3000) TYPE c,
        lv_tmp_string TYPE string.

  FIELD-SYMBOLS: <fs> TYPE any.
  DATA: BEGIN OF lt_field_info OCCURS 0,
          inpstruct LIKE temre-inpstruct,
          count TYPE i,
          kind TYPE abap_typekind,
          length TYPE i,
        END OF lt_field_info.
  DATA: descr_ref TYPE REF TO cl_abap_typedescr.

*         loop at customer structure
  DO.

*           get new field
    ASSIGN COMPONENT sy-index OF STRUCTURE cust TO <fs>.
    IF sy-subrc NE 0. EXIT. ENDIF.

*           get field info
    READ TABLE lt_field_info WITH KEY inpstruct = wa_strucinfo-inpstruct
    count = sy-index.
    IF sy-subrc NE 0.
      descr_ref = cl_abap_typedescr=>describe_by_data( <fs> ).
      lt_field_info-inpstruct = wa_strucinfo-inpstruct.
      lt_field_info-count = sy-index.
      lt_field_info-kind = descr_ref->type_kind.
      lt_field_info-length = descr_ref->length.
*     Feldlänge wird hir durch 2 dividiert, damit den Struktur nachher zusammenpassen
      DIVIDE lt_field_info-length BY 2.

      APPEND lt_field_info.
    ENDIF.

*           move field entry to output string
    MOVE <fs> TO lv_tmp_string.
    CASE lt_field_info-kind.
      WHEN 'P'.
        DO lt_field_info-length TIMES.
          MOVE '#' TO lv_string_out+lv_col(1).
          lv_col = lv_col + 1.
        ENDDO.
        lv_col = lv_col - lt_field_info-length.
      WHEN OTHERS.
        MOVE lv_tmp_string TO lv_string_out+lv_col(lt_field_info-length)
        .
    ENDCASE.

*           calculate new position
    lv_col = lv_col + lt_field_info-length.
    IF lv_col GT 3000. EXIT. ENDIF.
  ENDDO.

  xv_string_out = lv_string_out.

ENDFORM.                    " CONVERT_CUST_TO_STRING
*&---------------------------------------------------------------------*
*&      Form  PROTOKOLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM protokoll .

  DATA: datei(100) TYPE c.

  CLEAR h_seite.
  NEW-PAGE.

  SKIP 4.
  WRITE: /25 'P R O T O K O L L'.
  WRITE: /25 '================='.
  SKIP.

  CONCATENATE filepath file INTO filepath.
  write: /5 'Dateiname:', filepath.
  skip 2.

  WRITE: /5 'Anzahl der Partner', 50 z_partner,
         /5 'nicht migriert',       50 z_not_mig,
         /5 'migriert',             50 z_mig,
         /5 'Partner nicht gefunden', 50 z_no_part,
         /5  'Partner ist Firma oder Gruppe', 50 z_firma,
         /5  'Partner ist eine Person', 50 z_person,
         /5  'Geburtsdatum ist in Quelle nicht gepflegt', 50 z_no_birthdt,
         /5 'identische Geburtsdaten', 50 z_irrelevant,
         /5 'Updates der BUT000',  50 z_update,
         /5 'Fehler beim Update', 50 z_upderr.

ENDFORM.                    " PROTOKOLL

*&---------------------------------------------------------------------*
*&      Form  AUSGABE_LISTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ausgabe_liste .

  h_seite = 'L'.
  NEW-PAGE.
  LOOP AT it_ausgabe INTO wa_ausgabe.
    WRITE: /5 wa_ausgabe-partner_alt,
           20 wa_ausgabe-partner,
           35 wa_ausgabe-name_first,
           77 wa_ausgabe-name_last,
          120 wa_ausgabe-birthdt_quelle,
          135 wa_ausgabe-birthdt_old,
          150 wa_ausgabe-birthdt_new,
          165 wa_ausgabe-komment.
  ENDLOOP.

ENDFORM.                    " AUSGABE_LISTE

*&---------------------------------------------------------------------*
*&      Form  SEITENKOPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM seitenkopf .
  IF h_seite = 'L'.
    IF p_echt IS INITIAL.
      FORMAT COLOR COL_TOTAL INTENSIFIED OFF.
      WRITE: /5 'S I M U L A T I O N', AT sy-linsz space.
    ELSE.
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE: /5 'E C H T L A U F', AT sy-linsz space.
    ENDIF.
    FORMAT COLOR COL_BACKGROUND.
    WRITE: /5 'GP (Quelle)',
           20 'GP (Ziel)',
           35 'Vorname',
           77 'Nachname',
          120 'GebDat(Quelle)',
          135 'GebDat(alt)',
          150 'GebDat(neu)',
          165 'Kommentar'.
    ULINE.
  ENDIF.

ENDFORM.                    " SEITENKOPF
