FUNCTION /adesso/mtu_sampl_ent_account.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IACC_INIT STRUCTURE  /ADESSO/MT_FKKVK_HDR_DI OPTIONAL
*"      IACC_VK STRUCTURE  /ADESSO/MT_FKKVK_S_DI OPTIONAL
*"      IACC_VKP STRUCTURE  /ADESSO/MT_FKKVKP_S_DI OPTIONAL
*"      IACC_VKLOCK STRUCTURE  /ADESSO/MT_FKKVKLOCK_S_DI OPTIONAL
*"      IACC_VKCORR STRUCTURE  /ADESSO/MT_FKKVK_CORR_S_DI OPTIONAL
*"      IACC_VKTXEX STRUCTURE  /ADESSO/MT_FKKVK_TAXEX_S_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_ACC) LIKE  FKKVK-VKONT
*"----------------------------------------------------------------------
TABLES: ever.

  DATA: w_partner_u LIKE /adesso/mte_gpzs-partner_u,
        w_partner_o LIKE /adesso/mte_gpzs-partner_u.



* Geschäftspartnerzusammenführung - zusammengeführte Partner ersetzten
*----------------------------------------------------------------------
* Teil-1 Hauptverbindung zu dem GPartner des VKontos
* der GP ist in allen drei Strukturen gleich
  READ TABLE iacc_init INDEX 1.
  READ TABLE iacc_vkp INDEX 1.

  SELECT SINGLE partner_u partner_o
         INTO (w_partner_u, w_partner_o)
         FROM /adesso/mte_gpzs
         WHERE firma = firma
           AND partner_u = iacc_init-gpart.
  IF sy-subrc = 0.
*   Zusammenführung angefordert
*   Schlüssel des GPartners ersetzen (an allen relevanten Stellen)
    iacc_init-gpart = w_partner_o.
    MODIFY iacc_init INDEX 1.

    iacc_vkp-partner = w_partner_o.
    MODIFY iacc_vkp INDEX 1.

    LOOP AT iacc_vklock.
      iacc_vklock-lockpartner = w_partner_o.
      MODIFY iacc_vklock.
    ENDLOOP.

  ENDIF.


* Geschäftspartnerzusammenführung - zusammengeführte Partner ersetzten
*----------------------------------------------------------------------
* Teil-2 Verbindung zu den abweichenden GPartnern
  IF iacc_vkp-abwma IS NOT INITIAL.
*   Abw. Mahnempfämger
    SELECT SINGLE partner_u partner_o
           INTO (w_partner_u, w_partner_o)
           FROM /adesso/mte_gpzs
           WHERE firma = firma
             AND partner_u = iacc_vkp-abwma.
    IF sy-subrc = 0.
      iacc_vkp-abwma = w_partner_o.
      MODIFY iacc_vkp INDEX 1.
    ENDIF.
  ENDIF.

  IF iacc_vkp-abwma IS NOT INITIAL.
*   Abw. Mahnempfämger
    SELECT SINGLE partner_u partner_o
           INTO (w_partner_u, w_partner_o)
           FROM /adesso/mte_gpzs
           WHERE firma = firma
             AND partner_u = iacc_vkp-abwma.
    IF sy-subrc = 0.
      iacc_vkp-abwma = w_partner_o.
      MODIFY iacc_vkp INDEX 1.
    ENDIF.
  ENDIF.

  IF iacc_vkp-abwrh IS NOT INITIAL.
*   Abw. Rechnungsempfämger
    SELECT SINGLE partner_u partner_o
           INTO (w_partner_u, w_partner_o)
           FROM /adesso/mte_gpzs
           WHERE firma = firma
             AND partner_u = iacc_vkp-abwrh.
    IF sy-subrc = 0.
      iacc_vkp-abwrh = w_partner_o.
      MODIFY iacc_vkp INDEX 1.
    ENDIF.
  ENDIF.

  IF iacc_vkp-abwra IS NOT INITIAL.
*   Abw. Zahlempfänger
    SELECT SINGLE partner_u partner_o
           INTO (w_partner_u, w_partner_o)
           FROM /adesso/mte_gpzs
           WHERE firma = firma
             AND partner_u = iacc_vkp-abwra.
    IF sy-subrc = 0.
      iacc_vkp-abwra = w_partner_o.
      MODIFY iacc_vkp INDEX 1.
    ENDIF.
  ENDIF.

  IF iacc_vkp-abwre IS NOT INITIAL.
*   Abw. Zahler
    SELECT SINGLE partner_u partner_o
           INTO (w_partner_u, w_partner_o)
           FROM /adesso/mte_gpzs
           WHERE firma = firma
             AND partner_u = iacc_vkp-abwre.
    IF sy-subrc = 0.
      iacc_vkp-abwre = w_partner_o.
      MODIFY iacc_vkp INDEX 1.
    ENDIF.
  ENDIF.

* Mahnverfahren
  READ TABLE iacc_vkp INDEX 1.

  IF iacc_vkp-mahnv NE 'MX'.  " 'MX' wird 1:1 übernommen
    READ TABLE iacc_init INDEX 1.
    IF iacc_init-vktyp = 'SR'.       "Sammler-Oberkonto
      iacc_vkp-mahnv = 'MX'.
    ELSE.
      SELECT SINGLE *
             FROM ever
             WHERE vkonto = oldkey_acc
               AND sparte = '08'       "Abwasser
               AND auszdat = '99991231'.
      IF sy-subrc = 0.
*       es gibt Abwasserverträge
        SELECT SINGLE *
             FROM ever
             WHERE vkonto = oldkey_acc
               AND sparte NE '08'       "Abwasser
               AND auszdat = '99991231'.
        IF sy-subrc = 0.
*         es gibt nicht nur Abwasserverträge
          iacc_vkp-mahnv = 'MI'.
        ELSE.
*         es gibt nur Abwasserverträge
          iacc_vkp-mahnv = 'MO'.
        ENDIF.
      ELSE.
*       es gibt keine Abwasserverträge
        iacc_vkp-mahnv = 'MI'.
      ENDIF.
    ENDIF.
  ENDIF.
  MODIFY iacc_vkp INDEX 1.

* Regionalstrukturgruppen für Ober-Sammler
  READ TABLE iacc_init INDEX 1.
  READ TABLE iacc_vkp INDEX 1.
  IF iacc_init-vktyp = 'SR'.       "Sammler-Oberkonto
    iacc_vkp-regiogr_ca_t = 'SAMML'.
    iacc_vkp-regiogr_ca_b = 'SAMML'.
  ENDIF.
  MODIFY iacc_vkp INDEX 1.


ENDFUNCTION.
