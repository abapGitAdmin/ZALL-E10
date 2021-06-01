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
*&
************************************************************************
*******
REPORT zpw_018_datenmanipulator.

TABLES sscrfields.

* Selektionsbildgestaltung
PARAMETERS: pa_adrit TYPE n LENGTH 8 OBLIGATORY,
            pa_cusid TYPE zpw016address-customid OBLIGATORY VALUE CHECK,
            pa_ort   TYPE text40,
            pa_plz   TYPE char10,
            pa_stras TYPE text40.

* Die Drucktasten
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN PUSHBUTTON 2(10) select USER-COMMAND select.
SELECTION-SCREEN PUSHBUTTON 12(10) insert USER-COMMAND insert.
SELECTION-SCREEN PUSHBUTTON 22(10) update USER-COMMAND update.
SELECTION-SCREEN PUSHBUTTON 32(10) delete USER-COMMAND delete.
SELECTION-SCREEN PUSHBUTTON 42(10) modify USER-COMMAND modify.
SELECTION-SCREEN PUSHBUTTON 52(10) enqueue USER-COMMAND enqueue.
SELECTION-SCREEN PUSHBUTTON 62(10) dequeue USER-COMMAND dequeue.

* <wa>: Die Arbeitsstruktur
DATA: ls_address TYPE zpw016address.
* Texte der Drucktasten initialisieren
INITIALIZATION.

* Texte initialisieren mithilfe der Namen der PUSHBUTTONS
  select = 'SELECT'(b00).
  insert = 'INSERT'(b01).
  update = 'UPDATE'(b02).
  delete = 'DELETE'(b03).
  modify = 'MODIFY'(b04).
  enqueue = 'ENQUEUE'(b05).
  dequeue = 'DEQUEUE'(b06).

* Hier kommen die Reaktionen auf die Drucktasten rein
AT SELECTION-SCREEN.
* Zuerst mal die Parameterdaten in die Arbetisstruktur <wa> übernehmen
  ls_address-mandt = sy-mandt.
  ls_address-addressid = pa_adrit.
  ls_address-customid = pa_cusid.
  ls_address-ort = pa_ort.
  ls_address-plz = pa_plz.
  ls_address-strasse = pa_stras.

* Auswertung der Drucktasten
  CASE sscrfields.
    WHEN 'SELECT'. "Das USER-COMMAND vom PUSHBUTTON
      SELECT SINGLE * FROM zpw016address INTO @ls_address WHERE addressid = @pa_adrit AND customid = @pa_cusid.
      IF sy-subrc = 0.
        pa_adrit = ls_address-addressid.
        pa_cusid = ls_address-customid.
        pa_ort = ls_address-ort.
        pa_plz = ls_address-plz.
        pa_stras = ls_address-strasse.
      ELSE.
        CLEAR: pa_adrit, pa_cusid, pa_ort, pa_plz, pa_stras.
        MESSAGE 'Nix gefunden'(m00) TYPE 'E'.
      ENDIF.
    WHEN 'INSERT'.
*      Einfügen in die DB-Tabelle
      INSERT INTO zpw016address VALUES ls_address.
      IF sy-subrc = 0.
        MESSAGE 'Super! Der Eintrag wurde erzeugt'(m03) TYPE 'S'.
      ELSE.
        MESSAGE 'Schade! Das hat nicht funktioniert'(m04) TYPE 'E'.
      ENDIF.
    WHEN 'UPDATE'.
      UPDATE zpw016address FROM ls_address.
      IF sy-subrc = 0.
        MESSAGE 'Super! Der Eintrag wurde geändert'(m05) TYPE 'S'.
      ELSE.
        MESSAGE 'Schade! Das hat nicht funktioniert'(m06) TYPE 'E'.
      ENDIF.
    WHEN 'DELETE'.
      DATA ld_answer TYPE char10.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question = 'Wirklich löschen?'(p01)
        IMPORTING
          answer        = ld_answer.
      IF ld_answer = '1'.
        DELETE FROM zpw016address WHERE addressid = pa_adrit.
        IF sy-subrc = 0.
          CLEAR: pa_adrit, pa_cusid, pa_ort, pa_plz, pa_stras.
          MESSAGE 'Super! Der Eintrag wurde gelöscht' TYPE 'S'.
        ELSE.
          MESSAGE 'Schade! Das hat nicht funktioniert' TYPE 'E'.
        ENDIF.
      ENDIF.
    WHEN 'MODIFY'.
      MODIFY zpw016address FROM ls_address.
      IF sy-subrc = 0.
        MESSAGE 'Super! Der Eintrag wurde modifiziert' TYPE 'S'.
      ELSE.
        MESSAGE 'Schade! as hat nicht funktioniert' TYPE 'E'.
      ENDIF.
    WHEN 'ENQUEUE'.
    WHEN 'DEQUEUE'.
  ENDCASE.
