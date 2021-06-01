*&---------------------------------------------------------------------*
*& Report  /ADESSO/INKASSO_READ_FILE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/inkasso_read_file_swk.

DATA: p_string(6000) TYPE c.

DATA: wa_header TYPE fkkcolfile_header.
DATA: it_header  TYPE STANDARD TABLE OF fkkcolfile_header.
DATA: wa_header_info TYPE fkkcollh_i.
DATA: it_header_info TYPE STANDARD TABLE OF fkkcollh_i.
DATA: wa_colfile TYPE fkkcolfile.
DATA: it_colfile TYPE STANDARD TABLE OF fkkcolfile.
DATA: wa_colfile_info TYPE fkkcollp_ip.
DATA: it_colfile_info TYPE STANDARD TABLE OF fkkcollp_ip.
DATA: wa_trailer TYPE fkkcolfile_trailer.
DATA: it_trailer TYPE STANDARD TABLE OF fkkcolfile_trailer.
DATA: wa_trailer_info TYPE fkkcollt_i.
DATA: it_trailer_info TYPE STANDARD TABLE OF fkkcollt_i.

DATA: h_lines TYPE i.

DATA: lv_file_bom      TYPE sychar01,
      lv_file_encoding TYPE sychar01.

CONSTANTS: gc_lgname LIKE filename-fileintern
             VALUE 'FICA_DATA_TRANSFER_DIR',
           gc_phname LIKE filename-fileextern VALUE ''.

* Selektionsbidschirm
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
PARAMETERS: p_rb1 RADIOBUTTON GROUP butt DEFAULT 'X'.
PARAMETERS: p_rb2 RADIOBUTTON GROUP butt.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME.
PARAMETERS: ph_name LIKE filename-fileextern DEFAULT gc_phname.
*PARAMETERS: p_pfad OBLIGATORY LIKE rlgrap-filename DEFAULT 'C:\usr\sap\E10\DVEBMGS01\work\'.
*PARAMETERS: p_file OBLIGATORY LIKE rlgrap-filename. "DEFAULT '0000000072_1'.
SELECTION-SCREEN END OF BLOCK bl2.

******************************************************************************************
* AT SELECTIO-SCREEN
******************************************************************************************
AT SELECTION-SCREEN.

  CALL FUNCTION 'FILE_VALIDATE_NAME'
    EXPORTING
      logical_filename  = gc_lgname
    CHANGING
      physical_filename = ph_name
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc <> 0.
    MESSAGE e800(29) WITH ph_name.
  ENDIF.

*******************************************************************************************
* START-OF-SELECTION
*******************************************************************************************
START-OF-SELECTION.
  perform read_file.




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

  IF p_rb1 = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLFILE_HEADER'
        i_grid_title     = 'Kopfdaten Abgabedatei'
      TABLES
        t_outtab         = it_header
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLFILE'
        i_grid_title     = 'Positionen Abgabedatei'
      TABLES
        t_outtab         = it_colfile
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLFILE_TRAILER'
        i_grid_title     = 'Fußdaten Abgabedatei'
      TABLES
        t_outtab         = it_trailer
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSEIF p_rb2 = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLLH_I'
        i_grid_title     = 'Kopfdaten Infodatei'
      TABLES
        t_outtab         = it_header_info
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLLP_IP'
        i_grid_title     = 'Positionen Infodatei'
      TABLES
        t_outtab         = it_colfile_info
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_structure_name = 'FKKCOLLT_I'
        i_grid_title     = 'Fußdaten Infodatei'
      TABLES
        t_outtab         = it_trailer_info
      EXCEPTIONS
        program_error    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDIF.


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
      physical_filename = ph_name
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc <> 0.
    MESSAGE e800(29) WITH ph_name.
  ENDIF.


*   Check if file is UTF-8
  TRY.
      CALL METHOD cl_abap_file_utilities=>check_utf8
        EXPORTING
          file_name = ph_name
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
    OPEN DATASET ph_name FOR INPUT IN TEXT MODE
         ENCODING UTF-8 SKIPPING BYTE-ORDER MARK
         WITH SMART LINEFEED.
  ELSE.
    OPEN DATASET ph_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF syst-subrc GT 0.
    MESSAGE e800(29) WITH ph_name.
  ENDIF.

* Einlesen, um zu wissen, wieviel Zeilen der Datensatz hat.
  DO.
    READ DATASET ph_name INTO p_string.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    ADD 1 TO h_lines.
  ENDDO.

  CLOSE DATASET ph_name.


* Nochmals Öffnen, um die Datei zu verarbeiten
  IF lv_file_bom      EQ cl_abap_file_utilities=>bom_utf8 AND
     lv_file_encoding EQ cl_abap_file_utilities=>encoding_utf8.
*   Read as UTF-8 character representation and skip BOM
    OPEN DATASET ph_name FOR INPUT IN TEXT MODE
         ENCODING UTF-8 SKIPPING BYTE-ORDER MARK
         WITH SMART LINEFEED.
  ELSE.
    OPEN DATASET ph_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  ENDIF.
  IF syst-subrc GT 0.
    MESSAGE e800(29) WITH ph_name.
  ENDIF.

* Verarbeitung der Datei
  DO.
    READ DATASET ph_name INTO p_string.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
*   Erste Zeile ist der HEADER
    IF sy-index = 1.
      IF p_rb1 = 'X'.
        MOVE p_string TO wa_header.
        APPEND wa_header TO it_header.
      ELSEIF p_rb2 = 'X'.
        MOVE p_string TO wa_header_info.
        APPEND wa_header_info TO it_header_info.
      ENDIF.
    ELSEIF sy-index = h_lines.
      IF p_rb1 = 'X'.
        MOVE p_string TO wa_trailer.
        APPEND wa_trailer TO it_trailer.
      ELSEIF p_rb2 = 'X'.
        MOVE p_string TO wa_trailer_info.
        APPEND wa_trailer_info TO it_trailer_info.
      ENDIF.
    ELSE.
      IF p_rb1 = 'X'.
        MOVE p_string TO wa_colfile.
        APPEND wa_colfile TO it_colfile.
      ELSEIF p_rb2 = 'X'.
        MOVE p_string TO wa_colfile_info.
        APPEND wa_colfile_info TO it_colfile_info.
      ENDIF.
    ENDIF.
  ENDDO.


ENDFORM.
