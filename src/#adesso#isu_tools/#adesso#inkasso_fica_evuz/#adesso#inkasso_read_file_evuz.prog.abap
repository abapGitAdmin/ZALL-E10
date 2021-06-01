*&---------------------------------------------------------------------*
*& Report  Report /ADESSO/INKASSO_READ_FILE_EVUZ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_read_file_evuz NO STANDARD PAGE HEADING.

*{ INS ILASS ECHOUAIBI 22082019 EVUZ-Projekt----------------------------
TYPES: BEGIN OF ty_fkkcolfile_evuz,
         zzmglnr        TYPE  char10,
         gpart          TYPE  vkont_kk,
         vkont          TYPE  vkont_kk,
         zzanrede       TYPE  ad_titletx,
         zzname_gp2     TYPE  bu_nameor2, "Nachname
         zzname_gp1     TYPE  bu_nameor1, "Vorname
         zzname_gp3     TYPE  bu_nameor3,
         zzname_gp4     TYPE  char90,
         zzbirthdt      TYPE  bu_birthdt,
         zzpost_code1gp TYPE  ad_pstcd1,
         zzcity1gp      TYPE  ad_city1,
         zzstreetgp     TYPE  ad_street,
         zzhouse_num1gp TYPE  ad_hsnm1,
         zzstreethnr    TYPE  char70,
         zztel1         TYPE  ad_tlnmbr1,
         zzmobil        TYPE  ad_tlnmbr1,
         zzfax1         TYPE  ad_fxnmbr1,
         zzsmtp         TYPE  ad_smtpadr,
         zzbanka        TYPE  banka,
         zzswift        TYPE  swift,
         zziban         TYPE  bu_iban,
         zzzinss        TYPE  char10,
         zzzinsa        TYPE  char10,
         zzzinsdatum    TYPE  faedn_kk,
         zzbetrw        TYPE  betrw_kk,
         zzbldat        TYPE  bldat,
         zzausdt        TYPE  ausdt_kk,
         zzfaellig      TYPE  faedn_kk,
         zzvalut        TYPE  valut,
         zzabrzu        TYPE  abrzu_kk,
         zzabrzo        TYPE  abrzo_kk,
         zzfordg        TYPE  char20,
         zzrechnung     TYPE  xblnr_kk,
         zzspesen       TYPE  char10,
         zzzahl         TYPE  char10,
         zzgutsch       TYPE  char10,
         zzvertrag      TYPE  vertrag,
         zzbezfo2       TYPE  char10,
         zzbeztf1       TYPE  char20,
         zzadrvs        TYPE  char100,
         zzland         TYPE  land1,
         zzauart        TYPE  char10,
         zzermko        TYPE  char10,
         zzbankko       TYPE  char10,
         zzvalutnb      TYPE  valut,
         zzzahlnb       TYPE  char10,
         zzaktnr        TYPE  char10,
         zziban2        TYPE  bu_iban,
         zzbic2         TYPE  swift,
         zzvt_beginn    TYPE  e_vbeginn,
       END OF ty_fkkcolfile_evuz.

DATA: gt_fkkcolfile_evuz TYPE STANDARD TABLE OF ty_fkkcolfile_evuz.
DATA: gs_fkkcolfile_evuz LIKE LINE OF gt_fkkcolfile_evuz.
DATA: gr_salv           TYPE REF TO cl_salv_table.
DATA: gr_columns        TYPE REF TO cl_salv_columns_table. " handelt es sich um das Hauptobjekt zur Verwaltung von ALV-Spalten
DATA: gr_column         TYPE REF TO cl_salv_column_table.
DATA: gr_err_salv       TYPE REF TO cx_salv_msg.
DATA: gv_string         TYPE string.
DATA: gr_functions      TYPE REF TO cl_salv_functions_list. " zum aktievieren aller Standardfunktionen wird Methode Set_ALL().
DATA: gr_selections     TYPE REF TO cl_salv_selections.
DATA: gs_cust           TYPE /adesso/i_cuevuz.
DATA: gt_cust           TYPE STANDARD TABLE OF /adesso/i_cuevuz.

*} END ILASS ECHOUAIBI 22082019 EVUZ-Projekt----------------------------


DATA: p_string(6000) TYPE c.

DATA: wa_colfile TYPE fkkcolfile.
DATA: BEGIN OF wa_colfile_sort,
        sort_gp TYPE gpart_kk,
        sort_vk TYPE vkont_kk.
        INCLUDE STRUCTURE fkkcolfile.
      DATA: END OF wa_colfile_sort.

DATA: it_colfile LIKE TABLE OF wa_colfile_sort.

DATA: h_lines TYPE i.

DATA: lv_file_bom      TYPE sychar01,
      lv_file_encoding TYPE sychar01.

CONSTANTS: gc_lgname LIKE filename-fileintern
             VALUE 'FICA_DATA_TRANSFER_DIR',
           gc_phname LIKE filename-fileextern VALUE ''.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-100.
SKIP 2.
PARAMETERS: p_name LIKE filename-fileextern DEFAULT gc_phname.

SELECTION-SCREEN END OF BLOCK bl2.

******************************************************************************************
* AT SELECTIO-SCREEN
******************************************************************************************
INITIALIZATION.

  SELECT SINGLE * FROM /adesso/i_cuevuz
         INTO gs_cust
         WHERE inkasso_option   = 'DATEI'
         AND   inkasso_category = 'FILENAME'.

  p_name = gs_cust-inkasso_value.


AT SELECTION-SCREEN.

  CALL FUNCTION 'FILE_VALIDATE_NAME'
    EXPORTING
      logical_filename  = gc_lgname
    CHANGING
      physical_filename = p_name
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc <> 0.
    MESSAGE e800(29) WITH p_name.
  ENDIF.

*******************************************************************************************
* START-OF-SELECTION
*******************************************************************************************
START-OF-SELECTION.

  PERFORM read_file.

  PERFORM create_evuz_file.

************************************************************************************
* END-OF-SELECTION
************************************************************************************
END-OF-SELECTION.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  TRY.

      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*         r_container  =                           " Abstracter Container fuer GUI Controls
*         container_name =
        IMPORTING
          r_salv_table = gr_salv                " Basisklasse einfache ALV Tabellen
        CHANGING
          t_table      = gt_fkkcolfile_evuz.
    CATCH cx_salv_msg INTO gr_err_salv.

      gv_string = gr_err_salv->get_text( ).

      MESSAGE gv_string TYPE 'E'.

  ENDTRY.

* Spaltenbreite optimieren
  gr_columns = gr_salv->get_columns( ).
  gr_columns->set_optimize( abap_true ). " nur ein 'X'

* change the name of the column in ALV.
  gr_column ?= gr_columns->get_column( 'ZZMGLNR' ).
  gr_column->set_long_text( 'Mitgliedsnr' ).
  gr_column->set_medium_text( 'Mitgliedsnr' ).
  gr_column->set_short_text( 'Mitgl.Nr' ).

  gr_column ?= gr_columns->get_column( 'GPART' ).
  gr_column->set_long_text( 'Kundennummer' ).
  gr_column->set_medium_text( 'Kundennummer' ).
  gr_column->set_short_text( 'Kundennr' ).

  gr_column ?= gr_columns->get_column( 'VKONT' ).
  gr_column->set_long_text( 'Geschaeftszeichen' ).
  gr_column->set_medium_text( 'Geschaeftsz.' ).
  gr_column->set_short_text( 'Gesch.Zei.' ).

  gr_column ?= gr_columns->get_column( 'ZZNAME_GP4' ).
  gr_column->set_long_text( 'Name Organisation' ).
  gr_column->set_medium_text( 'Organisation' ).
  gr_column->set_short_text( 'Organ.' ).

  gr_column ?= gr_columns->get_column( 'ZZSTREETHNR' ).
  gr_column->set_long_text( 'StraßeHNR' ).
  gr_column->set_medium_text( 'StraßeHNR' ).
  gr_column->set_short_text( 'StraßeHNR' ).

  gr_column ?= gr_columns->get_column( 'ZZMOBIL' ).
  gr_column->set_long_text( 'Mobil' ).
  gr_column->set_medium_text( 'Mobil' ).
  gr_column->set_short_text( 'Mobil' ).

  gr_column ?= gr_columns->get_column( 'ZZBANKA' ).
  gr_column->set_long_text( 'Bank' ).
  gr_column->set_medium_text( 'Bank' ).
  gr_column->set_short_text( 'Bank' ).

  gr_column ?= gr_columns->get_column( 'ZZZINSDATUM' ).
  gr_column->set_long_text( 'Zins ab Datum' ).
  gr_column->set_medium_text( 'Zins ab Datum' ).
  gr_column->set_short_text( 'ZinsabDat.' ).

  gr_column ?= gr_columns->get_column( 'ZZBLDAT' ).
  gr_column->set_long_text( 'Rechnungsdatum' ).
  gr_column->set_medium_text( 'Rechnungsdatum' ).
  gr_column->set_short_text( 'Rechn.Dat.' ).

  gr_column ?= gr_columns->get_column( 'ZZZINSS' ).
  gr_column->set_long_text( 'Zinssatz' ).
  gr_column->set_medium_text( 'Zinssatz' ).
  gr_column->set_short_text( 'Zinssatz' ).

  gr_column ?= gr_columns->get_column( 'ZZZINSA' ).
  gr_column->set_long_text( 'Zinsart' ).
  gr_column->set_medium_text( 'Zinsart' ).
  gr_column->set_short_text( 'Zinsart' ).

  gr_column ?= gr_columns->get_column( 'ZZAUSDT' ).
  gr_column->set_long_text( 'Mahndatum' ).
  gr_column->set_medium_text( 'Mahndatum' ).
  gr_column->set_short_text( 'Mahndatum' ).

  gr_column ?= gr_columns->get_column( 'ZZFORDG' ).
  gr_column->set_long_text( 'Forderungsgrund' ).
  gr_column->set_medium_text( 'Ford.Grund' ).
  gr_column->set_short_text( 'Ford.Grund' ).

  gr_column ?= gr_columns->get_column( 'ZZRECHNUNG' ).
  gr_column->set_long_text( 'Rechnung' ).
  gr_column->set_medium_text( 'Rechnung' ).
  gr_column->set_short_text( 'Rechnung' ).

  gr_column ?= gr_columns->get_column( 'ZZSPESEN' ).
  gr_column->set_long_text( 'Spesen' ).
  gr_column->set_medium_text( 'Spesen' ).
  gr_column->set_short_text( 'Spesen' ).

  gr_column ?= gr_columns->get_column( 'ZZZAHL' ).
  gr_column->set_long_text( 'Zahlung' ).
  gr_column->set_medium_text( 'Zahlung' ).
  gr_column->set_short_text( 'Zahlung' ).

  gr_column ?= gr_columns->get_column( 'ZZGUTSCH' ).
  gr_column->set_long_text( 'Gutschrift' ).
  gr_column->set_medium_text( 'Gutschrift' ).
  gr_column->set_short_text( 'Gutschrift' ).

  gr_column ?= gr_columns->get_column( 'ZZBEZFO2' ).
  gr_column->set_long_text( 'Bez.Ford.' ).
  gr_column->set_medium_text( 'Bez.Ford.' ).
  gr_column->set_short_text( 'Bez.Ford.' ).

  gr_column ?= gr_columns->get_column( 'ZZBEZTF1' ).
  gr_column->set_long_text( 'Bez.TeilFord.' ).
  gr_column->set_medium_text( 'Bez.TeilFord.' ).
  gr_column->set_short_text( 'TeilFord.' ).

  gr_column ?= gr_columns->get_column( 'ZZADRVS' ).
  gr_column->set_long_text( 'Adresse VS' ).
  gr_column->set_medium_text( 'Adresse VS' ).
  gr_column->set_short_text( 'Adresse VS' ).

  gr_column ?= gr_columns->get_column( 'ZZAUART' ).
  gr_column->set_long_text( 'Auftragsart' ).
  gr_column->set_medium_text( 'Auftragsart' ).
  gr_column->set_short_text( 'Auft.art' ).

  gr_column ?= gr_columns->get_column( 'ZZERMKO' ).
  gr_column->set_long_text( 'Ermittlungkosten' ).
  gr_column->set_medium_text( 'Erm.kosten' ).
  gr_column->set_short_text( 'Erm.kosten' ).

  gr_column ?= gr_columns->get_column( 'ZZBANKKO' ).
  gr_column->set_long_text( 'Bankkosten' ).
  gr_column->set_medium_text( 'Bankkosten' ).
  gr_column->set_short_text( 'Bankkosten' ).

  gr_column ?= gr_columns->get_column( 'ZZZAHLNB' ).
  gr_column->set_long_text( 'Zahlung NB' ).
  gr_column->set_medium_text( 'Zahlung NB' ).
  gr_column->set_short_text( 'Zahlung NB' ).

  gr_column ?= gr_columns->get_column( 'ZZAKTNR' ).
  gr_column->set_long_text( 'Aktennr' ).
  gr_column->set_medium_text( 'Aktennr' ).
  gr_column->set_short_text( 'Aktennr' ).

  gr_column ?= gr_columns->get_column( 'ZZVT_BEGINN' ).
  gr_column->set_long_text( 'Vertragsbeginn' ).
  gr_column->set_medium_text( 'Vertragsbeginn' ).
  gr_column->set_short_text( 'VtrgBeginn' ).


* Selection-Mode aktivieren
* Instanz des selections-Objektes holen
  gr_selections = gr_salv->get_selections( ).
* Selektionsmodus setzen
  gr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

* Alle Standard-Funktionen auf Aktiv setzen
* Instanz für Funktionen holen
  gr_functions = gr_salv->get_functions( ).

* Alle Standardfunktionen aktivieren
  gr_functions->set_all( abap_true ).

* Die eigentliche Anzeige
  gr_salv->display( ).


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_file .

  CALL FUNCTION 'FILE_VALIDATE_NAME'
    EXPORTING
      logical_filename  = gc_lgname
    CHANGING
      physical_filename = p_name
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc <> 0.
    MESSAGE e800(29) WITH p_name.
  ENDIF.


*   Check if file is UTF-8
  TRY.
      CALL METHOD cl_abap_file_utilities=>check_utf8
        EXPORTING
          file_name = p_name
          max_kb    = 0
        IMPORTING
          bom       = lv_file_bom
          encoding  = lv_file_encoding.

    CATCH  cx_sy_file_open
           cx_sy_file_authority
           cx_sy_file_io.
      CLEAR: lv_file_bom, lv_file_encoding.
  ENDTRY.


  IF lv_file_bom      EQ cl_abap_file_utilities=>bom_utf8 AND
     lv_file_encoding EQ cl_abap_file_utilities=>encoding_utf8.
*   Read as UTF-8 character representation and skip BOM
    OPEN DATASET p_name FOR INPUT IN TEXT MODE
         ENCODING UTF-8 SKIPPING BYTE-ORDER MARK
         WITH SMART LINEFEED.
  ELSE.
    OPEN DATASET p_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF syst-subrc GT 0.
    MESSAGE e800(29) WITH p_name.
  ENDIF.

* Einlesen, um zu wissen, wieviel Zeilen der Datensatz hat.
  DO.
    READ DATASET p_name INTO p_string.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    ADD 1 TO h_lines.
  ENDDO.

  CLOSE DATASET p_name.


* Nochmals Öffnen, um die Datei zu verarbeiten
  IF lv_file_bom      EQ cl_abap_file_utilities=>bom_utf8 AND
     lv_file_encoding EQ cl_abap_file_utilities=>encoding_utf8.
*   Read as UTF-8 character representation and skip BOM
    OPEN DATASET p_name FOR INPUT IN TEXT MODE
         ENCODING UTF-8 SKIPPING BYTE-ORDER MARK
         WITH SMART LINEFEED.
  ELSE.
    OPEN DATASET p_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF syst-subrc GT 0.
    MESSAGE e800(29) WITH p_name.
  ENDIF.

* Verarbeitung der Datei
  DO.
    CLEAR: wa_colfile, wa_colfile_sort.
    READ DATASET p_name INTO p_string.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    IF sy-index <> 1 AND sy-index <> h_lines.
      MOVE p_string TO wa_colfile.
*     nur Haupftforderungen aus SR berücksichtigen
      IF wa_colfile-zzart = 'HF'.
        MOVE-CORRESPONDING wa_colfile TO wa_colfile_sort.
        wa_colfile_sort-sort_gp = wa_colfile-gpart.
        wa_colfile_sort-sort_vk = wa_colfile-vkont.
        APPEND wa_colfile_sort TO it_colfile.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_EVUZ_FILE
*&---------------------------------------------------------------------*
FORM create_evuz_file .

  DATA: lv_zzmglnr    TYPE ty_fkkcolfile_evuz-zzmglnr.
  DATA: lv_option     TYPE /adesso/ink_option_evuz.
  DATA: lv_vkont      TYPE vkont_kk.
  DATA: lv_stdbk      TYPE stdbk_kk.
  DATA: lv_betrw      TYPE betrw_kk.
  DATA: lv_zzzinsa    TYPE ty_fkkcolfile_evuz-zzzinsa.
  DATA: lv_zzfordg    TYPE ty_fkkcolfile_evuz-zzfordg.
  DATA: lv_zzbeztf1   TYPE ty_fkkcolfile_evuz-zzbeztf1.
  DATA: lv_zzname_gp4 TYPE ty_fkkcolfile_evuz-zzname_gp4.
  DATA: lv_zzadrvs(200).
  DATA: ls_but000     TYPE but000.

  SELECT * FROM /adesso/i_cuevuz INTO TABLE gt_cust.
  SORT gt_cust.

* Zinsart
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CREFO'
             inkasso_field    = 'ZZZINSA'.
  IF sy-subrc = 0.
    lv_zzzinsa = gs_cust-inkasso_value.
  ENDIF.

* Bezeichnung Forderungsgrund
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CREFO'
             inkasso_field    = 'ZZFORDG'.
  IF sy-subrc = 0.
    lv_zzfordg = gs_cust-inkasso_value.
  ENDIF.

* Bezeichnung Teilforderung
  CLEAR gs_cust.
  READ TABLE gt_cust INTO gs_cust
    WITH KEY inkasso_option   = 'CREFO'
             inkasso_field    = 'ZZBEZTF1'.
  IF sy-subrc = 0.
    lv_zzbeztf1 = gs_cust-inkasso_value.
  ENDIF.

  SORT it_colfile.
  LOOP AT it_colfile INTO wa_colfile_sort.

    AT NEW sort_vk.
      CLEAR gs_fkkcolfile_evuz.
      CLEAR lv_stdbk.
      CLEAR lv_option.
      CLEAR lv_vkont.
      CLEAR lv_zzmglnr.

      SELECT SINGLE stdbk FROM fkkvkp
             INTO lv_stdbk
             WHERE vkont = wa_colfile_sort-sort_vk
             AND   gpart = wa_colfile_sort-sort_gp.

      CONCATENATE 'ZZMGLNR_' lv_stdbk INTO lv_option.
      LOOP AT gt_cust INTO gs_cust
           WHERE inkasso_option = lv_option.
        lv_vkont = gs_cust-inkasso_field.

        CASE gs_cust-inkasso_category.
          WHEN 'LE'.
            IF wa_colfile_sort-sort_vk LE lv_vkont.
              lv_zzmglnr = gs_cust-inkasso_value.
            ENDIF.
          WHEN 'GE'.
            IF wa_colfile_sort-sort_vk GE lv_vkont.
              lv_zzmglnr = gs_cust-inkasso_value.
            ENDIF.
          WHEN OTHERS.
            lv_zzmglnr = '?????'.
        ENDCASE.

      ENDLOOP.
      gs_fkkcolfile_evuz-zzmglnr = lv_zzmglnr.
    ENDAT.

* Nur Posten aus der Schlußrechnung
    CHECK wa_colfile_sort-zzart = 'HF'.

* Felder einzeln füllen / 2x Vkont ist richtig
    gs_fkkcolfile_evuz-gpart    = wa_colfile_sort-vkont.
    gs_fkkcolfile_evuz-vkont    = wa_colfile_sort-vkont.
    gs_fkkcolfile_evuz-zzanrede = wa_colfile_sort-zzanrede.

* Name Organisation
    SELECT SINGLE * FROM but000 INTO ls_but000
      WHERE partner = wa_colfile_sort-gpart.

    IF ls_but000-type = '2'.
      CONCATENATE wa_colfile_sort-zzname_gp1
                  wa_colfile_sort-zzname_gp2
                  wa_colfile_sort-zzname_gp3
                  wa_colfile_sort-zzname_gp4
                  INTO lv_zzname_gp4.
      gs_fkkcolfile_evuz-zzname_gp4 = lv_zzname_gp4.
    ELSE.
      gs_fkkcolfile_evuz-zzname_gp1 = wa_colfile_sort-zzname_gp1.
      gs_fkkcolfile_evuz-zzname_gp2 = wa_colfile_sort-zzname_gp2.
      gs_fkkcolfile_evuz-zzname_gp3 = wa_colfile_sort-zzname_gp3.
      gs_fkkcolfile_evuz-zzname_gp4 = wa_colfile_sort-zzname_gp4.
    ENDIF.

    gs_fkkcolfile_evuz-zzbirthdt      = wa_colfile_sort-zzbirthdt.
    gs_fkkcolfile_evuz-zzpost_code1gp = wa_colfile_sort-zzpost_code1gp.
    gs_fkkcolfile_evuz-zzcity1gp      = wa_colfile_sort-zzcity1gp.
    gs_fkkcolfile_evuz-zzstreetgp     = wa_colfile_sort-zzstreetgp.
    concatenate wa_colfile_sort-zzhouse_num1gp
                wa_colfile_sort-zzhouse_num2gp
                into gs_fkkcolfile_evuz-zzhouse_num1gp
                SEPARATED BY space.
*   gs_fkkcolfile_evuz-zzstreethnr    = leer lassen
    gs_fkkcolfile_evuz-zztel1         = wa_colfile_sort-zztel1.
    gs_fkkcolfile_evuz-zzmobil        = wa_colfile_sort-zzmobil.
    gs_fkkcolfile_evuz-zzfax1         = wa_colfile_sort-zzfax1.
    gs_fkkcolfile_evuz-zzsmtp         = wa_colfile_sort-zzsmtp.
    gs_fkkcolfile_evuz-zzbanka        = wa_colfile_sort-zzbanka.
    gs_fkkcolfile_evuz-zzswift        = wa_colfile_sort-zzswift.
    gs_fkkcolfile_evuz-zziban         = wa_colfile_sort-zziban.
*   gs_fkkcolfile_evuz-zzzinss        = leer lassen
    gs_fkkcolfile_evuz-zzzinsa        = lv_zzzinsa.
    gs_fkkcolfile_evuz-zzzinsdatum    = wa_colfile_sort-zzzinsdatum.

    TRANSLATE wa_colfile_sort-betrw USING '. '.
    TRANSLATE wa_colfile_sort-betrw USING ',.'.
    CONDENSE wa_colfile_sort-betrw NO-GAPS.
    lv_betrw = wa_colfile_sort-betrw.
    gs_fkkcolfile_evuz-zzbetrw        = gs_fkkcolfile_evuz-zzbetrw +
                                        lv_betrw.

    gs_fkkcolfile_evuz-zzbldat        = wa_colfile_sort-zzbldat.
    gs_fkkcolfile_evuz-zzausdt        = wa_colfile_sort-zzausdt.
*    gs_fkkcolfile_evuz-zzfaellig      = leer lassen
    gs_fkkcolfile_evuz-zzvalut        = wa_colfile_sort-zzfaellig.

    IF wa_colfile_sort-zzvertrag NE space.
      gs_fkkcolfile_evuz-zzabrzu        = wa_colfile_sort-zzabrzu.
      gs_fkkcolfile_evuz-zzabrzo        = wa_colfile_sort-zzabrzo.
    ENDIF.

    gs_fkkcolfile_evuz-zzfordg        = lv_zzfordg.
*   gs_fkkcolfile_evuz-zzrechnung     = leer lassen
*   gs_fkkcolfile_evuz-zzspesen       = leer lassen
*   gs_fkkcolfile_evuz-zzzahl         = leer lassen
*   gs_fkkcolfile_evuz-zzgutsch       = leer lassen
*   gs_fkkcolfile_evuz-zzvertrag      = leer lassen
*   gs_fkkcolfile_evuz-zzbezfo2       = leer lassen
    gs_fkkcolfile_evuz-zzbeztf1       = lv_zzbeztf1.

* Adresse Verbrauchstelle
    IF wa_colfile_sort-zzvertrag NE space.
      CONCATENATE wa_colfile_sort-ZZPOST_CODE1VS
                  wa_colfile_sort-zzcity1vs
                  wa_colfile_sort-zzcity2vs
                  wa_colfile_sort-zzstreetvs
                  wa_colfile_sort-zzhouse_num1vs
                  wa_colfile_sort-zzhouse_num2vs
                  INTO lv_zzadrvs
                  SEPARATED BY space.
      CONDENSE lv_zzadrvs.
      gs_fkkcolfile_evuz-zzadrvs = lv_zzadrvs.
    ENDIF.

*   gs_fkkcolfile_evuz-zzland         = leer lassen
*   gs_fkkcolfile_evuz-zzauart        = leer lassen
*   gs_fkkcolfile_evuz-zzermko        = leer lassen
*   gs_fkkcolfile_evuz-zzbankko       = leer lassen
*   gs_fkkcolfile_evuz-zzvalutnb      = leer lassen
*   gs_fkkcolfile_evuz-zzzahlnb       = leer lassen
*   gs_fkkcolfile_evuz-zzaktnr        = leer lassen
*   gs_fkkcolfile_evuz-zziban2        = leer lassen
*   gs_fkkcolfile_evuz-zzbic2         = leer lassen
    gs_fkkcolfile_evuz-zzvt_beginn    = wa_colfile_sort-zzabrzu.

    AT END OF sort_vk.
      APPEND gs_fkkcolfile_evuz TO gt_fkkcolfile_evuz.
    ENDAT.

  ENDLOOP.

ENDFORM.
