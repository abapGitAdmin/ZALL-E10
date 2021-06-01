FUNCTION /ADESSO/WO_MON_DB_MODE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_MODE) TYPE  CHAR1
*"  TABLES
*"      T_WO_MON STRUCTURE  /ADESSO/WO_MON
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*   Um Laufzeitfehler zu vermeiden wird mit "ACCEPTING DUPLICATE KEYS"
*   gearbeitet
*"----------------------------------------------------------------------

  CASE i_mode.

    WHEN const_mode_insert.
*   Um Laufzeitfehler zu vermeiden wird mit "ACCEPTING DUPLICATE KEYS"
*   gearbeitet
      INSERT /ADESSO/WO_MON FROM TABLE T_WO_MON ACCEPTING DUPLICATE KEYS.
      IF sy-subrc NE 0.
        MESSAGE e001(/ADESSO/WO_MON) WITH '/ADESSO/WO_MON' RAISING error.
      ENDIF.

    WHEN const_mode_delete.
      DELETE /ADESSO/WO_MON FROM TABLE T_WO_MON.
      IF sy-subrc NE 0.
        MESSAGE e002(/ADESSO/WO_MON) WITH '/ADESSO/WO_MON' RAISING error.
      ENDIF.

    WHEN const_mode_update.
      UPDATE /ADESSO/WO_MON FROM TABLE T_WO_MON.
      IF sy-subrc NE 0.
        MESSAGE e003(/ADESSO/WO_MON) WITH '/ADESSO/WO_MON' RAISING error.
      ENDIF.

    WHEN const_mode_modify.
      MODIFY /ADESSO/WO_MON FROM TABLE T_WO_MON.
      IF sy-subrc NE 0.
        MESSAGE e004(/ADESSO/WO_MON) WITH '/ADESSO/WO_MON' RAISING error.
      ENDIF.
  ENDCASE.

ENDFUNCTION.
