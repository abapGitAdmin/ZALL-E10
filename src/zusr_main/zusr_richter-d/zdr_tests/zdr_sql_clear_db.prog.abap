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
REPORT zdr_sql_clear_db.

PARAMETERS: p_tab  TYPE dd02l-tabname.

IF p_tab IS INITIAL.
  MESSAGE 'Bitte gib eine Datenbanktabelle an!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.
SELECT SINGLE * FROM dd02l WHERE tabname = @p_tab INTO @DATA(ls_dd021).
IF sy-subrc <> 0.
  MESSAGE 'Bitte wähle eine gültige Datenbanktabelle aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

TRY.
    DELETE FROM (p_tab).
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

* SE16N aufrufen, um Inhalt der der Datenbanktabelle anzuzeigen
SET PARAMETER ID 'DTB' FIELD p_tab.
CALL TRANSACTION 'SE16N'.
