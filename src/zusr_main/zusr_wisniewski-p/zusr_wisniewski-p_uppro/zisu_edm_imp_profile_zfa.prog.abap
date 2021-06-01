*&---------------------------------------------------------------------*
*& Report ZISU_EDM_IMP_PROFILE_ZFA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zisu_edm_imp_profile_zfa LINE-SIZE 132 MESSAGE-ID zisu_edm.

*&---------------------------------------------------------------------*
*& report reedmprofileimp                                              *
*& call BAPI and upload via POD                                        *
*&---------------------------------------------------------------------*
************************************************************************
*                P r o g r a m m ä n d e r u n g e n                   *
************************************************************************
*  Datum     Name           Kz.   Hinweis                              *
*  --------  ------------   ---   -----------------------------------  *
*  16.04.2018 kalali.f      kalali Kopie aus P1N                                   *
*  OBIS-Code aus dem Datenstrom in OBIS- Marktkommunikation umwandeln  *
*  Über die Tabelle ZEEDM_OBIS_CHANG                                   *
*  Pflege-View ZEEDM_OBIS_CHANG                                        *
************************************************************************
*REPORT ZAIS_REEDMPROFILEIMP LINE-SIZE 132 MESSAGE-ID ZAIS_EDM.

TABLES: eedmstatus_ext.


DATA: proval_bapi  LIKE bapiisuproval OCCURS 0,
      wbapi        LIKE bapiisuproval,
      proval_file  LIKE edmisuproval_file_01 OCCURS 0,
      wproval_file LIKE edmisuproval_file_01,
      return       LIKE bapiret2 OCCURS 0,
      wreturn      TYPE bapiret2,
      uploadinfo   LIKE bapiisuprovalupdata,
*      filename     LIKE rlgrap-filename,
      filename_str TYPE string,
      wa_message   TYPE string.
* 20.03.2009 EVkalali
*     -------------------------------------------------------------
DATA: "it_obis    TYPE STANDARD TABLE OF zisu_obis_ch_zfa, " ZEEDM_OBIS_CHANG,
      "wa_obis    TYPE zisu_obis_ch_zfa, "ZEEDM_OBIS_CHANG,
      flag_cheng TYPE c.
FIELD-SYMBOLS <wbapi> TYPE bapiisuproval.
*     -------------------------------------------------------------


DATA: benutzerzeitzone LIKE usr02-tzone.
DATA: user       TYPE sy-uname.
DATA: u_name(14) TYPE c.
DATA: id TYPE sy-sysid.
DATA: file(30) TYPE c.

DATA: f1 TYPE bapiisuproval-value.
DATA: f2 TYPE bapiisuproval-value.
DATA: flen TYPE i.
* lesen der externen Status
TYPES: t_eedmstatus_ext TYPE eedmstatus_ext.
DATA: wa_eedmstatus_ext TYPE t_eedmstatus_ext.
DATA:  i_eedmstatus_ext TYPE TABLE OF t_eedmstatus_ext.


FIELD-SYMBOLS: <wfile> TYPE edmisuproval_file_01.

PARAMETERS: bapiform LIKE regen-kennzx DEFAULT ' '.
"PARAMETERS filetype    TYPE zisu_edm_file_type DEFAULT 'ASC'.
PARAMETERS extref      TYPE e_extreference NO-DISPLAY.
PARAMETERS srcsyst     TYPE e_srcsystem NO-DISPLAY.
PARAMETERS: p_s        RADIOBUTTON GROUP rad DEFAULT 'X'.
PARAMETERS filename    TYPE rlgrap-filename.
PARAMETERS  p_u        RADIOBUTTON GROUP rad.
PARAMETERS ufile       TYPE rlgrap-filename
                        DEFAULT'/rkudat/rkustd/'.

PARAMETERS: p_duplic AS CHECKBOX.
PARAMETERS: p_v RADIOBUTTON GROUP rad1 DEFAULT 'X',
            p_l RADIOBUTTON GROUP rad1.
PARAMETERS: panzst     AS CHECKBOX DEFAULT ' '.
PARAMETERS: vstell     TYPE n DEFAULT '6'.
SELECT-OPTIONS: stati  FOR eedmstatus_ext-ext_status.
*********************************

INITIALIZATION.
  user = sy-uname.

* Selektionsvariante automatisch laden
* Selectionsvariante U_Benutzername -----------------------------------*
  CONCATENATE 'U_' sy-uname INTO u_name.

  CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
    EXPORTING
      report               = sy-cprog
      variant              = u_name
    EXCEPTIONS
      variant_not_existent = 1
      variant_obsolete     = 2
      OTHERS               = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* 20.03.2009 EVkalali
*     -------------------------------------------------------------
*  SELECT * FROM ZEEDM_OBIS_CHANG INTO TABLE IT_OBIS.
*  SELECT * FROM zisu_obis_ch_zfa INTO TABLE it_obis.
*  IF it_obis IS INITIAL.
*    CLEAR flag_cheng.
*  ELSE.
*    SORT it_obis.
*    flag_cheng = 'X'.
*  ENDIF.

*-------------- F4 Hilfe File -----------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR filename.

  IF NOT p_s IS INITIAL.

    CALL FUNCTION 'WS_FILENAME_GET'
      EXPORTING
*       DEF_FILENAME     = ' '
*       DEF_PATH         = ' '
        mask             = ',*.*,*.*.'
        mode             = 'O'
        title            = TEXT-004
      IMPORTING
        filename         = filename
*       RC               =
      EXCEPTIONS
        inv_winsys       = 1
        no_batch         = 2
        selection_cancel = 3
        selection_error  = 4
        OTHERS           = 5.
*  IF sy-subrc NE 0.
*    CHECK sy-subrc NE 4.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*  ENDIF.
  ENDIF.

START-OF-SELECTION.


* Upload mit sequentieller Datei
  IF NOT p_s IS INITIAL.

    IF NOT filename IS INITIAL.
      filename_str = filename.

* call GUI upload
      IF NOT bapiform IS INITIAL.

        CALL FUNCTION 'GUI_UPLOAD'
          EXPORTING
            filename = filename_str
            filetype = ' '"filetype
          TABLES
            data_tab = proval_bapi.
      ELSE.

        CALL FUNCTION 'GUI_UPLOAD'
          EXPORTING
            filename = filename_str
            filetype = ' '"filetype
          TABLES
            data_tab = proval_file.

        LOOP AT proval_file ASSIGNING <wfile>.
          MOVE-CORRESPONDING <wfile> TO wbapi.
          APPEND wbapi TO proval_bapi.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ELSE.
* Uniximport
    PERFORM get_data_from_unix.

  ENDIF.

* 20.03.2009 EVkalali
*     -------------------------------------------------------------
*  IF flag_cheng = 'X'.
*    LOOP AT proval_bapi ASSIGNING <wbapi>.
*      CLEAR: wa_obis.
**     OBIS-Umschlüsselung
*      READ TABLE it_obis
*           WITH KEY referencenumber = <wbapi>-referencenumber
*           INTO wa_obis BINARY SEARCH.
*      IF sy-subrc = 0.
**       Wert Tauschen
*        <wbapi>-referencenumber = wa_obis-kennziff.
*      ELSE.
*        CLEAR: wa_obis.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*     -------------------------------------------------------------
* 20.03.2009 EVkalali

  LOOP AT proval_bapi ASSIGNING <wbapi>.
    IF <wbapi>-fromoffset+2 = space.
      <wbapi>-fromoffset+2(1) = <wbapi>-fromoffset+1(1).
      <wbapi>-fromoffset+1(1) = '0'.
    ENDIF.

    IF <wbapi>-tooffset+2 = space.
      <wbapi>-tooffset+2(1) = <wbapi>-tooffset+1(1).
      <wbapi>-tooffset+1(1) = '0'.
    ENDIF.
  ENDLOOP.


* Prüfung auf zugelassene Anzahl der Stellen für
* die Profilwerte:
  IF NOT panzst IS INITIAL.
* einmalig die gültigen status lesen

    CLEAR: i_eedmstatus_ext, wa_eedmstatus_ext.

    SELECT * FROM eedmstatus_ext INTO TABLE i_eedmstatus_ext
     WHERE ext_status IN stati.

    SORT i_eedmstatus_ext.

    LOOP AT proval_bapi INTO wbapi.
      CLEAR: f1, f2.
      SPLIT wbapi-value AT '.' INTO f1 f2.

      IF NOT f1+vstell(1) IS INITIAL.

        READ TABLE i_eedmstatus_ext INTO wa_eedmstatus_ext
                        WITH KEY ext_status = wbapi-status
                                         BINARY SEARCH.
        IF  sy-subrc > 0.

          WRITE:/'Profilwertgrösse von' &
                 ' max:', vstell,' Vorkommastellen überschritten: ',
                62 wbapi-pointofdelivery,
                99 wbapi-status,
               106 wbapi-value.
          WRITE:/'Der Satz wird nicht verarbeitet!'.
          DELETE proval_bapi INDEX sy-tabix.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.
*    LOOP AT proval_file ASSIGNING <wfile>.
*      MOVE-CORRESPONDING <wfile> TO wbapi.
*      APPEND wbapi TO proval_bapi.
*    ENDLOOP.
*  ENDIF.

* take over uploadinfo
  uploadinfo-extreference = extref.
  uploadinfo-srcsystem = srcsyst.
* RZKALALI
* Doppelte Profileinträge führen Verbuchungsabbruch
* Diese werden Sortiert und der höchste Status gelöscht
  IF p_duplic = 'X'.
    SORT proval_bapi BY pointofdelivery referencenumber
                        datefrom timefrom fromoffset
                        dateto timeto tooffset
                        status.

    DELETE ADJACENT DUPLICATES FROM proval_bapi COMPARING pointofdelivery referencenumber
                                                          datefrom timefrom fromoffset
                                                          dateto timeto tooffset.
  ENDIF.

* Ausgabemodus Verbuchung:
  IF NOT p_v IS INITIAL.

* call BAPI
    CALL FUNCTION 'BAPI_ISUPROFILE_UPLOAD'
      EXPORTING
        uploadinfo    = uploadinfo
      TABLES
        profilevalues = proval_bapi
        return        = return.

* write messages
    LOOP AT return INTO wreturn.
      CONCATENATE wreturn-type wreturn-id
      wreturn-number wreturn-message
      wreturn-system INTO wa_message SEPARATED BY space.
      WRITE:/ wa_message.
    ENDLOOP.

  ENDIF.

* Ausgabemodus Liste:
  IF NOT p_l IS INITIAL.

    PERFORM alv_liste.

  ENDIF.

  COMMIT WORK.

*ENDIF.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_FROM_UNIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_from_unix .
*Datei oeffnen:
* OPEN DATASET ufile FOR INPUT IN TEXT MODE ENCODING DEFAULT."RZKALALI UNICODE
  OPEN DATASET ufile FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.
  IF sy-subrc > 0.
    MESSAGE ID 'ZISU_EDM' TYPE 'E' NUMBER '006' WITH ufile.
  ENDIF.


  IF NOT bapiform IS INITIAL.

    DO.
      READ DATASET ufile INTO wbapi.
      IF sy-subrc = 0.

        APPEND wbapi TO proval_bapi.

      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

  ELSE.

    DO.
      READ DATASET ufile INTO wproval_file.
      IF sy-subrc = 0.

        MOVE-CORRESPONDING wproval_file TO wbapi.
        APPEND wbapi TO proval_bapi.

      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

  ENDIF.

  CLOSE DATASET ufile.

ENDFORM.                    " GET_DATA_FROM_UNIX
*&---------------------------------------------------------------------*
*&      Form  ALV_LISTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_liste .

*Tabelle für Spaltenbezeichnungen ALV-Grid
  DATA: BEGIN OF nametab OCCURS 0,
          name(60)         TYPE c,
          tabelle_name(30) TYPE c,
          feld_name(30)    TYPE c,
          key_feld         TYPE c,
        END OF nametab.

  DATA: headline1(132) TYPE c.
  DATA: headline2(132) TYPE c.
  DATA: x_part1_headline2(66) TYPE c.
  DATA: x_part2_headline2(66) TYPE c.
  DATA: headline3(132) TYPE c.
  DATA: headline4(132) TYPE c.
  DATA: basic_list_title TYPE string.
  DATA: x_datum(10) TYPE c.

  DATA: x_netzbetr  TYPE eservprovt-sp_name.
  DATA: x_lieferant TYPE eservprovt-sp_name.

*Titel:
  CONCATENATE 'ZFA'
              '-'
              'Intervalldaten'
         INTO basic_list_title SEPARATED BY space.
*Headlines:
* headline1
* headline2
* headline3
* headline4

*Aufbereitung ALV-Grid
  nametab-name = 'Zählpunktbezeichnung    '. APPEND nametab.
  nametab-name = 'Obiskennzahl            '. APPEND nametab.
  nametab-name = 'Profilrollentyp         '. APPEND nametab.
  nametab-name = 'Profilrolle             '. APPEND nametab.
  nametab-name = 'Ab-Datum                '. APPEND nametab.
  nametab-name = 'Ab-Zeit                 '. APPEND nametab.
  nametab-name = 'Offset                  '. APPEND nametab.
  nametab-name = 'Bis-Datum               '. APPEND nametab.
  nametab-name = 'Bis-Zeit                '. APPEND nametab.
  nametab-name = 'Offset                  '. APPEND nametab.
  nametab-name = 'Profilwert              '. APPEND nametab.
  nametab-name = 'Status                  '. APPEND nametab.
  nametab-name = 'Maßeinheit              '. APPEND nametab.

  CALL FUNCTION 'DISPLAY_BASIC_LIST'
    EXPORTING
      basic_list_title    = basic_list_title
      file_name           = 'C:\TEMP\zfa_liste.xls'
*     head_line1          = headline1
*     head_line2          = headline2
*     head_line3          = headline3
*     head_line4          = headline4
*     FOOT_NOTE1          = ' '
*     FOOT_NOTE2          = ' '
*     FOOT_NOTE3          = ' '
*     LAY_OUT             = 0
*     DYN_PUSHBUTTON_TEXT1       =
*     DYN_PUSHBUTTON_TEXT2       =
*     DYN_PUSHBUTTON_TEXT3       =
*     DYN_PUSHBUTTON_TEXT4       =
*     DYN_PUSHBUTTON_TEXT5       =
*     DYN_PUSHBUTTON_TEXT6       =
*     DATA_STRUCTURE      = ' '
*     CURRENT_REPORT      =
*     LIST_LEVEL          = ' '
*     ADDITIONAL_OPTIONS  = ' '
*     WORD_DOCUMENT       =
*     APPLICATION         =
*     OLDVALUES           = ' '
*     NO_ALV_GRID         =
*     ALV_MARKER          =
*   IMPORTING
*     RETURN_CODE         =
    TABLES
      data_tab            = proval_bapi
      fieldname_tab       = nametab
*     SELECT_TAB          =
*     ERROR_TAB           =
*     RECEIVERS           =
    EXCEPTIONS
      download_problem    = 1
      no_data_tab_entries = 2
      table_mismatch      = 3
      print_problems      = 4
      OTHERS              = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " ALV_LISTE
