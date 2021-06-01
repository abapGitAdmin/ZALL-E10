FUNCTION /adesso/edivar_before_output.
******************************************************************
* Kurzbeschreibung der Funktion:
* Steuereung die Anzeige/Speichern der EDI Variante im Vertragskonto
* nach der Anpassung/Eingabe im Vertragskonto
*
* Änderungshistorie:
* Datum       Benutzer  Grund
* ----------------------------------------------------------------

  CALL FUNCTION 'VKK_FICA_FKKVK_GET'
    IMPORTING
      e_fkkvk = gs_fkkvk_neu.

  CALL FUNCTION 'VKK_FICA_FKKVKP_GET'
    TABLES
      t_fkkvkp = gt_fkkvkp.

  CLEAR: gs_fkkvkp_neu, ci_fkkvkp.

  READ TABLE gt_fkkvkp INTO gs_fkkvkp_neu INDEX 1.
  IF sy-subrc = 0.
    ci_fkkvkp-zzedivar = gs_fkkvkp_neu-zzedivar.
  ENDIF.

ENDFUNCTION.
