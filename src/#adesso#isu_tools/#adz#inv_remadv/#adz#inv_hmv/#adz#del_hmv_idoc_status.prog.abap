*&---------------------------------------------------------------------*
*& Report  /ADZ/DEL_HMV_IDOC_STATUS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adz/del_hmv_idoc_status.

TABLES: /adz/hmv_memi, /adz/hmv_dfkk.

DATA: lt_memi LIKE TABLE OF /adz/hmv_memi,
      lt_dfkk LIKE TABLE OF /adz/hmv_dfkk.

SELECT-OPTIONS: so_docid FOR /adz/hmv_memi-doc_id,
                so_opbel  FOR /adz/hmv_dfkk-opbel.

PARAMETERS: p_memi AS CHECKBOX,
            p_dfkk AS CHECKBOX.

IF p_memi IS NOT INITIAL.
  SELECT * FROM /adz/hmv_memi  INTO TABLE lt_memi
    WHERE doc_id IN so_docid.
  IF sy-subrc = 0.
    DELETE /adz/hmv_memi FROM TABLE lt_memi.
    WRITE: / 'Löschen /ADZ/HMV_MEMI durchgeführt!' COLOR 2.
    WRITE: / sy-dbcnt, 'Datensaetze geloescht' COLOR 2.
  ENDIF.

ENDIF.

IF p_dfkk IS NOT INITIAL.
  SELECT * FROM /adz/hmv_dfkk INTO TABLE lt_dfkk
    WHERE opbel IN so_opbel.
  IF sy-subrc = 0.
    DELETE /adz/hmv_dfkk FROM TABLE lt_dfkk.
    WRITE: / 'Löschen /ADZ/HMV_DFKK durchgeführt!' COLOR 2.
    WRITE: / sy-dbcnt, 'Datensaetze geloescht' COLOR 2.
  ENDIF.

ENDIF.
