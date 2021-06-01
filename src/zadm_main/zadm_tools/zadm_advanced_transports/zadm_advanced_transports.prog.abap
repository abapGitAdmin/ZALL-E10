*&---------------------------------------------------------------------*
*& Report  ZADM_ADVANCED_TRANSPORTS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zadm_advanced_transports.
*=======================================================================
* Selektionsbild
*=======================================================================
SELECTION-SCREEN BEGIN OF BLOCK direction
  WITH FRAME TITLE text-dir.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_export RADIOBUTTON GROUP dirc
           TYPE boolean DEFAULT 'X'.
SELECTION-SCREEN COMMENT 4(30) text-exp
           FOR FIELD p_export.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_import RADIOBUTTON GROUP dirc
           TYPE boolean.
SELECTION-SCREEN COMMENT 4(30) text-imp
           FOR FIELD p_import.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END   OF BLOCK direction.

SELECTION-SCREEN BEGIN OF BLOCK parameters
  WITH FRAME TITLE text-par.
PARAMETERS:
  p_trkorr TYPE e070-trkorr,
  p_path   TYPE string DEFAULT 'C:\'.
SELECTION-SCREEN END   OF BLOCK parameters.

SELECTION-SCREEN BEGIN OF BLOCK files
  WITH FRAME TITLE text-fil.
PARAMETERS:
  p_xdtfil AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF BLOCK destsyst.
PARAMETERS p_xbuffe AS CHECKBOX.
PARAMETERS p_dstsys TYPE char3.
SELECTION-SCREEN END OF BLOCK destsyst.
SELECTION-SCREEN END   OF BLOCK files.

*=======================================================================
* Globale Daten
*=======================================================================
DATA:
  gc_system(3)     TYPE c,
  gc_number(6)     TYPE c,
  gc_dirname(75)   TYPE c,
  gc_cofile(75)    TYPE c,
  gc_datafile1(75) TYPE c,
  gc_datafile2(75) TYPE c,
  gc_separator(1)  TYPE c,
  gc_applname(132) TYPE c,
  gc_presname(132) TYPE c.

*=======================================================================
AT SELECTION-SCREEN ON BLOCK destsyst.
*=======================================================================
  IF p_xbuffe = 'X' AND p_dstsys IS INITIAL.
    MESSAGE e055(00).
  ENDIF.

*=======================================================================
END-OF-SELECTION.
*=======================================================================

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  DATA: lt_data_tab TYPE TABLE OF char255.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Ordner auswählen'
      initial_folder       = 'C:\'
    CHANGING
      selected_folder      = p_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

END-OF-SELECTION.

* Name des Transportverzeichnis auf Applikationsserver holen
  CALL 'C_SAPGPARAM'
    ID 'NAME'  FIELD 'DIR_TRANS'
    ID 'VALUE' FIELD gc_dirname.

* Namen der Dateien erzeugen
  gc_system = p_trkorr+0(3).
  gc_number = p_trkorr+4.
  CONCATENATE 'K' gc_number '.' gc_system INTO gc_cofile.
  CONCATENATE 'R' gc_number '.' gc_system INTO gc_datafile1.
  CONCATENATE 'D' gc_number '.' gc_system INTO gc_datafile2.

* Trennzeichen ermitteln
  CASE sy-opsys.
    WHEN 'VMS'.
      "nothing
    WHEN 'Windows NT'.
      gc_separator = '\'.
    WHEN OTHERS.   "UNIX
      gc_separator = '/'.
  ENDCASE.

* Separator anfügen, falls nötig
  PERFORM add_separator
    USING    '\'
    CHANGING p_path.

* BUFFER-Datei kopieren (falls gewünscht)
  IF p_xbuffe = 'X'.
    CONCATENATE gc_dirname gc_separator 'buffer' gc_separator p_dstsys
      INTO gc_applname.
    CONCATENATE p_path p_dstsys
      INTO gc_presname.
    PERFORM copy_file
      USING gc_applname gc_presname p_export 'X'.
  ENDIF.

* COFILE und Datenfiles kopieren (falls gewünscht)
  IF p_xdtfil = 'X'.
*   COFILE kopieren
    CONCATENATE gc_dirname gc_separator 'cofiles' gc_separator gc_cofile
      INTO gc_applname.
    CONCATENATE p_path gc_cofile
      INTO gc_presname.
    PERFORM copy_file
      USING gc_applname gc_presname p_export 'X'.

*   Datenfile 1 kopieren
    CONCATENATE gc_dirname gc_separator 'data' gc_separator gc_datafile1
      INTO gc_applname.
    CONCATENATE p_path gc_datafile1
      INTO gc_presname.
    PERFORM copy_file
      USING gc_applname gc_presname p_export 'X'.

*   Datenfile 2 kopieren
    CONCATENATE gc_dirname gc_separator 'data' gc_separator gc_datafile2
      INTO gc_applname.
    CONCATENATE p_path gc_datafile2
      INTO gc_presname.
    PERFORM copy_file
      USING gc_applname gc_presname p_export ' '.
  ENDIF.

*=======================================================================
* FORM COPY_FILE
*=======================================================================
* Datei kopieren
*=======================================================================
FORM copy_file
  USING pc_applname TYPE c
        pc_presname TYPE c
        pb_a_to_p   TYPE boolean
        pb_showmesg TYPE boolean.

  CONSTANTS:
  ci_bufsize    TYPE i VALUE 1024.

  TYPES:
  tx_data(1024) TYPE x.

  DATA:
    lx_data     TYPE tx_data,
    lt_data     TYPE STANDARD TABLE OF tx_data WITH DEFAULT KEY,
    li_sizeone  TYPE i,
    li_sizeall  TYPE i,
    ls_presname TYPE string,
    lc_message  TYPE char100.

* Dateiname für FBs GUI_UP/DOWNLOAD muss vom Typ String sein
  ls_presname = pc_presname.

* Kopieren der Datei
  CASE pb_a_to_p.
*   ---- Richtung Applikationsserver -> Präsentationsserver ----------
    WHEN 'X'.
*     Datei vom Applikationsserver lesen
      OPEN DATASET pc_applname
        FOR INPUT IN BINARY MODE
        MESSAGE lc_message.
      IF sy-subrc = 0.
        DO.
          READ DATASET pc_applname INTO lx_data
            LENGTH li_sizeone.
          IF li_sizeone <> 0.
            INSERT lx_data INTO TABLE lt_data.
            li_sizeall = li_sizeall + li_sizeone.
          ENDIF.
          IF li_sizeone < ci_bufsize.
            EXIT.
          ENDIF.
        ENDDO.
        CLOSE DATASET pc_applname.
      ELSE.
        IF pb_showmesg = 'X'.
          WRITE: / lc_message.
        ENDIF.
        EXIT.
      ENDIF.
*     Datei auf Präsentationsserver schreiben
      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename     = ls_presname
          bin_filesize = li_sizeall
          filetype     = 'BIN'
        TABLES
          data_tab     = lt_data
        EXCEPTIONS
          OTHERS       = 1.
      IF sy-subrc <> 0.
        IF pb_showmesg = 'X'.
          WRITE: / pc_presname, ': FEHLER!'.
        ENDIF.
        EXIT.
      ENDIF.
*   ---- Richtung Präsentationsserver -> Applikationsserver ----------
    WHEN ' '.
*     Datei vom Präsentationsserver lesen
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename   = ls_presname
          filetype   = 'BIN'
        IMPORTING
          filelength = li_sizeall
        TABLES
          data_tab   = lt_data
        EXCEPTIONS
          OTHERS     = 1.
      IF sy-subrc <> 0.
        IF pb_showmesg = 'X'.
          WRITE: / ls_presname, ': FEHLER!'.
        ENDIF.
        EXIT.
      ENDIF.
*     Datei auf Applikationssserver schreiben
      OPEN DATASET pc_applname
        FOR OUTPUT IN BINARY MODE
        MESSAGE lc_message.
      IF sy-subrc = 0.
        LOOP AT lt_data INTO lx_data.
          IF li_sizeall > ci_bufsize.
            li_sizeone = ci_bufsize.
          ELSE.
            li_sizeone = li_sizeall.
          ENDIF.
          TRANSFER lx_data TO pc_applname
            LENGTH li_sizeone.
          li_sizeall = li_sizeall - li_sizeone.
        ENDLOOP.
      ELSE.
        IF pb_showmesg = 'X'.
          WRITE: / lc_message.
        ENDIF.
        EXIT.
      ENDIF.
*   -------------------------------------------------------------------
  ENDCASE.
ENDFORM.

*=======================================================================
* FORM ADD_SEPARATOR
*=======================================================================
* Trennzeichen anfügen
*=======================================================================
FORM add_separator
  USING    pc_sepa TYPE c
  CHANGING pc_path TYPE string.

  DATA:
  li_len TYPE i.

  li_len = strlen( pc_path ) - 1.
  IF li_len >= 0.
    IF pc_path+li_len(1) <> pc_sepa.
      CONCATENATE pc_path pc_sepa
        INTO pc_path.
    ENDIF.
  ENDIF.
ENDFORM.
