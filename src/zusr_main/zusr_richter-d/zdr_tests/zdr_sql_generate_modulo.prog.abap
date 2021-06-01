************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&         $USER  $DATE
************************************************************************
*******
REPORT zdr_sql_generate_modulo.

TYPES: ty_part1 TYPE /ado/sql_911,
       ty_part2 TYPE /ado/sql_actors,
       ty_part3 TYPE /ado/sql_movies,
       ty_part4 TYPE /ado/sql_psid,
       ty_part5 TYPE /ado/sql_salerec,
       ty_part6 TYPE /ado/sql_star.

PARAMETERS: p_tab TYPE dd02l-tabname.

DATA: lr_istruc     TYPE REF TO data,
      lr_itab       TYPE REF TO data,
      lv_iterations TYPE i VALUE 1000000,
      lv_index      TYPE i.

FIELD-SYMBOLS: <ls_istruc> TYPE any,
               <lt_itab>   TYPE STANDARD TABLE.

DATA: ls_istruc_part1 TYPE ty_part1,
      lt_itab_part1   TYPE TABLE OF ty_part1,
      ls_istruc_part2 TYPE ty_part2,
      lt_itab_part2   TYPE TABLE OF ty_part2,
      ls_istruc_part3 TYPE ty_part3,
      lt_itab_part3   TYPE TABLE OF ty_part3,
      ls_istruc_part4 TYPE ty_part4,
      lt_itab_part4   TYPE TABLE OF ty_part4,
      ls_istruc_part5 TYPE ty_part5,
      lt_itab_part5   TYPE TABLE OF ty_part5,
      ls_istruc_part6 TYPE ty_part6,
      lt_itab_part6   TYPE TABLE OF ty_part6.

IF p_tab IS INITIAL.
  MESSAGE 'Bitte gib eine Datenbanktabelle an!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.
SELECT SINGLE * FROM dd02l WHERE tabname = @p_tab INTO @DATA(ls_dd021).
IF sy-subrc <> 0.
  MESSAGE 'Bitte wähle eine gültige Datenbanktabelle aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

* Struktur zur Laufzeit erzeugen
CREATE DATA lr_istruc TYPE (p_tab).
ASSIGN lr_istruc->* TO <ls_istruc>.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

* interne Tabelle zur Laufzeit erzeugen
CREATE DATA lr_itab TYPE TABLE OF (p_tab).
ASSIGN lr_itab->* TO <lt_itab>.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

SELECT * FROM /ado/sql_911 INTO CORRESPONDING FIELDS OF TABLE lt_itab_part1 ORDER BY PRIMARY KEY.
SELECT * FROM /ado/sql_actors INTO CORRESPONDING FIELDS OF TABLE lt_itab_part2 ORDER BY PRIMARY KEY.
SELECT * FROM /ado/sql_movies INTO CORRESPONDING FIELDS OF TABLE lt_itab_part3 ORDER BY PRIMARY KEY.
SELECT * FROM /ado/sql_psid INTO CORRESPONDING FIELDS OF TABLE lt_itab_part4 ORDER BY PRIMARY KEY.
SELECT * FROM /ado/sql_salerec INTO CORRESPONDING FIELDS OF TABLE lt_itab_part5 ORDER BY PRIMARY KEY.
SELECT * FROM /ado/sql_star INTO CORRESPONDING FIELDS OF TABLE lt_itab_part6 ORDER BY PRIMARY KEY.

DO lv_iterations TIMES.
  CLEAR <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part1 ) ) + 1.
  ls_istruc_part1 = lt_itab_part1[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part1 TO <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part2 ) ) + 1.
  ls_istruc_part2 = lt_itab_part2[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part2 TO <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part3 ) ) + 1.
  ls_istruc_part3 = lt_itab_part3[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part3 TO <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part4 ) ) + 1.
  ls_istruc_part4 = lt_itab_part4[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part4 TO <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part5 ) ) + 1.
  ls_istruc_part5 = lt_itab_part5[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part5 TO <ls_istruc>.

  lv_index = ( ( sy-index - 1 ) MOD lines( lt_itab_part6 ) ) + 1.
  ls_istruc_part6 = lt_itab_part6[ lv_index ].
  MOVE-CORRESPONDING ls_istruc_part6 TO <ls_istruc>.

  IF sy-index < 500000.
    APPEND <ls_istruc> TO <lt_itab>.
  ENDIF.
ENDDO.

TRY.
    DELETE FROM (p_tab).
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

TRY.
    INSERT (p_tab) FROM TABLE <lt_itab>.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Schreiben auf die Datenbank! (etvl. ehlerhaftes Format der CSV-Datei, Key nicht eindeutig)' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

* SE16N aufrufen, um Inhalt der der Datenbanktabelle anzuzeigen
SET PARAMETER ID 'DTB' FIELD p_tab.
CALL TRANSACTION 'SE16N'.
