FUNCTION /adesso/edivar_after_entry.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
******************************************************************
* Kurzbeschreibung der Funktion:
* Steuereung die Anzeige/Speichern der EDI Variante im Vertragskonto
* nach der Anpassung/Eingabe im Vertragskonto
*
* Änderungshistorie:
* Datum       Benutzer  Grund
* ----------------------------------------------------------------

  CALL FUNCTION 'BUS_PARAMETERS_ISSTA_GET'
    IMPORTING
      e_aktyp = gv_aktyp.

  CHECK gv_aktyp NE gc_03.

  CALL FUNCTION 'VKK_FICA_FKKVKP_GET'
    TABLES
      t_fkkvkp = gt_fkkvkp.

  IF NOT gt_fkkvkp[] IS INITIAL.
    CLEAR: gs_fkkvkp_neu.
    LOOP AT gt_fkkvkp INTO gs_fkkvkp_neu.
      gs_fkkvkp_neu-zzedivar = ci_fkkvkp-zzedivar.
      MODIFY gt_fkkvkp FROM gs_fkkvkp_neu INDEX 1.
    ENDLOOP.

  ENDIF.

  CALL FUNCTION 'VKK_FICA_FKKVKP_COLLECT'
    EXPORTING
      i_subname = 'CI_FKKVKP'
    TABLES
      pt_fkkvkp = gt_fkkvkp.

ENDFUNCTION.
