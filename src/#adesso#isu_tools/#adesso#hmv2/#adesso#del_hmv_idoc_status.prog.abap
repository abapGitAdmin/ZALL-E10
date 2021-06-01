*&---------------------------------------------------------------------*
*& Report  /ADESSO/DEL_HMV_IDOC_STATUS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/DEL_HMV_IDOC_STATUS.

TABLES: /adesso/hmv_memi, /adesso/hmv_dfkk.

DATA: it_memi LIKE TABLE OF /adesso/hmv_memi,
      it_dfkk LIKE TABLE OF /adesso/hmv_dfkk.

SELECT-OPTIONS: so_docid FOR /adesso/hmv_memi-doc_id,
                so_opbel  FOR /adesso/hmv_dfkk-opbel.

PARAMETERS: p_memi AS CHECKBOX,
            p_dfkk AS CHECKBOX.


IF p_memi IS NOT INITIAL.

  SELECT * FROM /adesso/hmv_memi
    INTO CORRESPONDING FIELDS OF TABLE it_memi
    WHERE doc_id IN so_docid.
*  ENDSELECT.

  IF sy-subrc = 0.

      DELETE /adesso/hmv_memi FROM TABLE it_memi.

      WRITE: / 'Löschen /ADESSO/HMV_MEMI durchgeführt!' COLOR 2.

  ENDIF.

ENDIF.



IF p_dfkk IS NOT INITIAL.

  SELECT * FROM /adesso/hmv_dfkk
    INTO CORRESPONDING FIELDS OF TABLE it_dfkk
    WHERE opbel IN so_opbel.
* ENDSELECT.

  IF sy-subrc = 0.

      DELETE /adesso/hmv_dfkk FROM TABLE it_dfkk.

      WRITE: / 'Löschen /ADESSO/HMV_DFKK durchgeführt!' COLOR 2.

  ENDIF.

ENDIF.
