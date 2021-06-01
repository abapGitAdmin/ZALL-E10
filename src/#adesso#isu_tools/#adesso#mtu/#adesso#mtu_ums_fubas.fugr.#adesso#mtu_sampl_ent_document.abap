FUNCTION /ADESSO/MTU_SAMPL_ENT_DOCUMENT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDOC_KO STRUCTURE  /ADESSO/MT_FKKKO OPTIONAL
*"      IDOC_OP STRUCTURE  /ADESSO/MT_FKKOP OPTIONAL
*"      IDOC_OPK STRUCTURE  /ADESSO/MT_FKKOPK OPTIONAL
*"      IDOC_OPL STRUCTURE  /ADESSO/MT_FKKOPL OPTIONAL
*"      IDOC_ADDINF STRUCTURE  /ADESSO/MT_EMIG_DOC_ADDINFO OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DOC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung der offenen Posten (Entladung)

  DATA: w_partner_u LIKE /adesso/mte_gpzs-partner_u,
        w_partner_o LIKE /adesso/mte_gpzs-partner_o.

  LOOP AT idoc_op.


**  Geschäftspartnerzusammenführung
    SELECT SINGLE partner_u partner_o
           FROM /adesso/mte_gpzs
           INTO (w_partner_u, w_partner_o)
           WHERE firma = firma
            AND partner_u = idoc_op-gpart.
** Schlüssel des Geschäftspartners ersetzen
    IF sy-subrc = 0.
      idoc_op-gpart = w_partner_o.
    ENDIF.

** Hauptbuchkonten
    IF   ( idoc_op-hvorg = '0010' and idoc_op-tvorg = '0010' ) OR
         ( idoc_op-hvorg = '0060' AND idoc_op-tvorg = '0010'   AND
           idoc_op-spart = space )                             OR
         ( idoc_op-hvorg = '0060' AND idoc_op-tvorg = '0020'   AND
           idoc_op-spart = space )                             OR
         ( idoc_op-hvorg = '0070' AND idoc_op-tvorg = '0020'   AND
           idoc_op-spart = space )                             OR
         ( idoc_op-hvorg = '0700' AND idoc_op-tvorg = '0010'   AND
           idoc_op-spart = '02' )                              OR
         ( idoc_op-hvorg = '0700' AND idoc_op-tvorg = '0010'   AND
           idoc_op-spart = '03' )                              OR
         ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020'   AND
           idoc_op-spart = space )                             OR
         ( idoc_op-hvorg = '9070' AND idoc_op-tvorg = '0020'   AND
           idoc_op-spart = space ).

      idoc_op-hkont = '20324710'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02' )                             OR
             ( idoc_op-hvorg = '9040' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = space )                             OR
             ( idoc_op-hvorg = '9040' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = space ).

      idoc_op-hkont = '20324160'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '02'   AND idoc_op-kofiz = '05' ).

      idoc_op-hkont = '21934160'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '04' )                             OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '04' )                             OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '04' )                             OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '04' )                             OR
             ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '04' )                             OR
             ( idoc_op-hvorg = '9060' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = space ).

      idoc_op-hkont = '20324560'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz ne '05' ) OR
             ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03' ).

      idoc_op-hkont = '20324260'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz = '05' )  OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '03'   AND idoc_op-kofiz = '05' ).

      idoc_op-hkont = '21934260'.

    ELSEIF   ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '08' )                             OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '08' )                             OR
             ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = '08' )                             OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '08' )                             OR
             ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = '08' )                             OR
             ( idoc_op-hvorg = '9050' AND idoc_op-tvorg = '0010'  AND
               idoc_op-spart = space )                            OR
             ( idoc_op-hvorg = '9050' AND idoc_op-tvorg = '0020'  AND
               idoc_op-spart = space ).

      idoc_op-hkont = '20324960'.

    else.
      CONCATENATE 'Fehler bei Kontenermittlung für VK'
                  idoc_op-vkont
                  'GP' idoc_op-gpart
                  'BelNr' idoc_op-opbel
                  INTO meldung
                  SEPARATED BY space.
      APPEND meldung.
      CONCATENATE 'Kontenmerkmale: HVorgang'
                  idoc_op-hvorg
                  'TVorgang' idoc_op-tvorg
                  'Sparte'   idoc_op-spart
                  'Kofiz'    idoc_op-kofiz
                  INTO meldung
                  SEPARATED BY space.
      APPEND meldung.
      RAISE wrong_data.

    ENDIF.


** Teilvorgang
    IF ( ( idoc_op-hvorg = '0060' AND idoc_op-tvorg = '0010' ) OR
         ( idoc_op-hvorg = '0250' AND idoc_op-tvorg = '0010' ) OR
         ( idoc_op-hvorg = '0700' AND idoc_op-tvorg = '0010' ) OR
         ( idoc_op-hvorg = '9040' AND idoc_op-tvorg = '0010' ) OR
         ( idoc_op-hvorg = '9050' AND idoc_op-tvorg = '0010' ) ).

      idoc_op-tvorg = '0010'.

    ELSEIF ( ( idoc_op-hvorg = '0010' AND idoc_op-tvorg = '0010' ) OR
             ( idoc_op-hvorg = '0060' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '0100' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '0200' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '0300' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '8020' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '9040' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '9050' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '9060' AND idoc_op-tvorg = '0020' ) OR
             ( idoc_op-hvorg = '9070' AND idoc_op-tvorg = '0020' ) ).

      idoc_op-tvorg = '0020'.

    ELSEIF ( idoc_op-hvorg = '0070' AND idoc_op-tvorg = '0020' ).

      idoc_op-tvorg = '0040'.

    ENDIF.

** Hauptvorgang
    CASE idoc_op-hvorg.

      WHEN '0060' OR '0100' OR '0200' OR '0250' OR
           '0300' OR '0700' OR '8020' OR '9040' OR
           '9050' OR '9060'.
        idoc_op-hvorg = '4000'.

      WHEN '0010' OR '0070'.
        idoc_op-hvorg = '4010'.

      WHEN '9070'.
        idoc_op-hvorg = '4020'.
    ENDCASE.

    MODIFY idoc_op INDEX sy-tabix.
  ENDLOOP.

ENDFUNCTION.
