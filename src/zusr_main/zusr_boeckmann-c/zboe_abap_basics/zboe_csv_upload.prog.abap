************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 22.05.2019
*
* Beschreibung: CSV-Upload von lokalem Rechner
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_csv_upload.

TYPES: BEGIN OF lty_person,
         name    TYPE string,
         vorname TYPE string,
         alter   TYPE i,
         beruf   TYPE string,
       END OF lty_person.

TYPES: BEGIN OF lty_komponenten,
         name TYPE string,
       END OF lty_komponenten.

DATA: lt_person             TYPE TABLE OF lty_person,
      ls_person             TYPE lty_person,
      lt_komponenten_person TYPE TABLE OF lty_komponenten,
      lt_csv_data           TYPE truxs_t_text_data,
      ls_csv_data           TYPE LINE OF truxs_t_text_data,
      ls_komponenten        TYPE lty_komponenten,
      lo_struktur           TYPE REF TO cl_abap_structdescr,
      ls_components         TYPE abap_compdescr,
      lt_komponenten_csv    TYPE TABLE OF lty_komponenten,
      lv_rest               TYPE string,
      lv_wert               TYPE string.

DATA lv_path TYPE string VALUE 'C:\Users\boeckmann\Downloads\Personen.csv'.

FIELD-SYMBOLS <wert> TYPE any.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename = lv_path
*   FILETYPE = 'ASC'
*   HAS_FIELD_SEPARATOR           = ' '
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE = ' '
*   CODEPAGE = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER   =
  TABLES
    data_tab = lt_csv_data
* CHANGING
*   ISSCANPERFORMED               = ' '
* EXCEPTIONS
*   FILE_OPEN_ERROR               = 1
*   FILE_READ_ERROR               = 2
*   NO_BATCH = 3
*   GUI_REFUSE_FILETRANSFER       = 4
*   INVALID_TYPE                  = 5
*   NO_AUTHORITY                  = 6
*   UNKNOWN_ERROR                 = 7
*   BAD_DATA_FORMAT               = 8
*   HEADER_NOT_ALLOWED            = 9
*   SEPARATOR_NOT_ALLOWED         = 10
*   HEADER_TOO_LONG               = 11
*   UNKNOWN_DP_ERROR              = 12
*   ACCESS_DENIED                 = 13
*   DP_OUT_OF_MEMORY              = 14
*   DISK_FULL                     = 15
*   DP_TIMEOUT                    = 16
*   OTHERS   = 17
  .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

lo_struktur ?= cl_abap_typedescr=>describe_by_name( 'LTY_PERSON' ).

LOOP AT lo_struktur->components INTO ls_components.
  ls_komponenten-name = ls_components-name.
  APPEND ls_komponenten TO lt_komponenten_person.
ENDLOOP.

READ TABLE lt_csv_data INTO ls_csv_data INDEX 1. "Erste Zeile mit Komponenten lesen
lv_rest = ls_csv_data.
DO.
  SPLIT lv_rest AT ';' INTO lv_wert lv_rest.
  CONDENSE lv_wert. "Leerzeichen von Text abschneiden
  IF lv_rest IS INITIAL AND lv_wert IS INITIAL.
    EXIT.
  ENDIF.
  ls_komponenten-name = lv_wert. "Wert als Komponenten Namen speichern und der Komponenten Tabelle hinzufügen
  APPEND ls_komponenten TO lt_komponenten_csv.
ENDDO.

**********************************************************************
* Überprüfen, ob die Komponente der internen Tabelle auch in der CSV Datei vorhanden ist
**********************************************************************
LOOP AT lt_komponenten_person INTO ls_komponenten.
  READ TABLE lt_komponenten_csv WITH TABLE KEY name = ls_komponenten-name TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE e004(zboe_messages) WITH ls_komponenten-name.
  ENDIF.
ENDLOOP.

**********************************************************************
* Daten aus der CSV Datein in die entsprechenden Spalten der Internen Tabelle schreiben
**********************************************************************
LOOP AT lt_csv_data INTO ls_csv_data FROM 2. "Kopfdaten / Komponenten übersprigen deshalb Zeile 2
  lv_rest = ls_csv_data.
  DO.
    SPLIT lv_rest AT ';' INTO lv_wert lv_rest.
    CONDENSE lv_wert. " Leerzeichen entfernen
    IF lv_rest IS INITIAL AND lv_wert IS INITIAL.
      EXIT.
    ENDIF.
    READ TABLE lt_komponenten_csv INDEX sy-index INTO ls_komponenten. "Komponente zum Wert auslesen
    ASSIGN COMPONENT ls_komponenten-name OF STRUCTURE ls_person TO <wert>.
    IF <wert> IS ASSIGNED.
      <wert> = lv_wert.
    ENDIF.
    UNASSIGN <wert>.
  ENDDO.

  APPEND ls_person TO lt_person.
ENDLOOP.
