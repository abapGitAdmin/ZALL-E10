FUNCTION /adesso/fkk_sample_3020.                           "#EC *
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_RFKN1) LIKE  RFKN1 STRUCTURE  RFKN1
*"  EXPORTING
*"     VALUE(E_INKPS_ALLOW) TYPE  BOOLE-BOOLE
*"  TABLES
*"      T_FKKCL STRUCTURE  FKKCL
*"  EXCEPTIONS
*"      ERROR
*"--------------------------------------------------------------------

  DATA: h_agsta LIKE dfkkcoll-agsta.

* First Call Standard FuBa for IS-U
  CALL FUNCTION 'ISU_SAMPLE_3020'
    EXPORTING
      i_rfkn1 = i_rfkn1
    TABLES
      t_fkkcl = t_fkkcl
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT t_fkkcl.
    IF t_fkkcl-inkps IS NOT INITIAL.

      SELECT SINGLE agsta FROM dfkkcoll INTO h_agsta
                      WHERE opbel = t_fkkcl-opbel
                        AND inkps = t_fkkcl-inkps.
      IF sy-subrc EQ 0.
        IF h_agsta EQ '32'.  "Position "Erneute Bearbeitung"
          e_inkps_allow = 'X'.
        ELSE.
          DELETE t_fkkcl.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.


* If you want to return e_inkps_allow = 'X' in a customer module
* please see OSS note 740943 for hints and instructions.
* to check for the release status use the following
* coding as a template:

*  DATA: h_agsta LIKE dfkkcoll-agsta.
*  LOOP AT t_fkkcl.
*    IF t_fkkcl-inkps IS NOT INITIAL.
*
*      SELECT SINGLE agsta FROM dfkkcoll INTO h_agsta
*                      WHERE opbel = t_fkkcl-opbel
*                        AND inkps = t_fkkcl-inkps.
*      IF sy-subrc EQ 0.
*        IF h_agsta EQ '01' OR  "Position freigegeben
*           h_agsta EQ '05' OR  "Abgabe storniert
*           h_agsta EQ '09'.    "Abgabe zurückgerufen
*        ELSE.
*          DELETE t_fkkcl.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.

* First Call Standard FuBa for IS-U
  CALL FUNCTION 'ISU_SAMPLE_3020'
    EXPORTING
      i_rfkn1 = i_rfkn1
    TABLES
      t_fkkcl = t_fkkcl
    EXCEPTIONS
      error   = 1
      OTHERS  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFUNCTION.
