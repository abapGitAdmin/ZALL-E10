FUNCTION /ADESSO/MTU_SAMPL_ENT_BBP_MULT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBPM_EABP STRUCTURE  /ADESSO/MT_EABP OPTIONAL
*"      IBPM_EABPV STRUCTURE  /ADESSO/MT_EMIGR_EVER OPTIONAL
*"      IBPM_EABPS STRUCTURE  /ADESSO/MT_SFKKOP OPTIONAL
*"      IBPM_EJVL STRUCTURE  /ADESSO/MT_EJVL OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BPM) LIKE  EABP-OPBEL
*"----------------------------------------------------------------------

  DATA: w_partner_u LIKE /adesso/mte_gpzs-partner_u,
        w_partner_o LIKE /adesso/mte_gpzs-partner_o.

** Geschäftspartnerzusammenführung
  read table ibpm_eabp index 1.

  SELECT SINGLE partner_u partner_o
         FROM /adesso/mte_gpzs
         INTO (w_partner_u, w_partner_o)
         WHERE firma = firma
          AND partner_u = ibpm_eabp-gpart.

** Zusammenführung erforderlich
** Schlüssel des Geschäftspartners ersetzen
  IF sy-subrc = 0.
    ibpm_eabp-gpart = w_partner_o.
    MODIFY ibpm_eabp INDEX 1.
  ENDIF.


ENDFUNCTION.
