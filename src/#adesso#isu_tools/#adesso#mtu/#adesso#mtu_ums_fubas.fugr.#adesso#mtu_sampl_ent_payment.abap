FUNCTION /ADESSO/MTU_SAMPL_ENT_PAYMENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPAY_FKKKO STRUCTURE  /ADESSO/MT_EMIG_PAY_FKKKO OPTIONAL
*"      IPAY_FKKOPK STRUCTURE  /ADESSO/MT_FKKOPK OPTIONAL
*"      IPAY_SELTNS STRUCTURE  /ADESSO/MT_EMIG_PAY_SELTNS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PAY) LIKE  EABP-OPBEL
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der Zahlungen (Entladung)

  DATA: w_partner_u LIKE /adesso/mte_gpzs-partner_u,
        w_partner_o LIKE /adesso/mte_gpzs-partner_o.

  LOOP AT ipay_seltns.

**  Geschäftspartnerzusammenführung
    SELECT SINGLE partner_u partner_o
           FROM /adesso/mte_gpzs
           INTO (w_partner_u, w_partner_o)
           WHERE firma = firma
            AND partner_u = ipay_seltns-giart.

** Schlüssel des Geschäftspartners ersetzen
    IF sy-subrc = 0.
      ipay_seltns-giart = w_partner_o.
    ENDIF.

    MODIFY ipay_seltns INDEX sy-tabix.

  ENDLOOP.

ENDFUNCTION.
