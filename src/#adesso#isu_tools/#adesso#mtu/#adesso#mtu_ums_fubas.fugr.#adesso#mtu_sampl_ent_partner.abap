FUNCTION /adesso/mtu_sampl_ent_partner.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPAR_INIT STRUCTURE  /ADESSO/MT_EMG_EKUN_INIT OPTIONAL
*"      IPAR_EKUN STRUCTURE  /ADESSO/MT_EKUN_DI OPTIONAL
*"      IPAR_BUT000 STRUCTURE  /ADESSO/MT_BUS000_DI OPTIONAL
*"      IPAR_BUT001 STRUCTURE  /ADESSO/MT_BUS001_DI OPTIONAL
*"      IPAR_BUT0BK STRUCTURE  /ADESSO/MT_BUS0BK_DI OPTIONAL
*"      IPAR_BUT020 STRUCTURE  /ADESSO/MT_BUS020_DI OPTIONAL
*"      IPAR_BUT021 STRUCTURE  /ADESSO/MT_BUS021_DI OPTIONAL
*"      IPAR_BUT0CC STRUCTURE  /ADESSO/MT_BUS0CC_DI OPTIONAL
*"      IPAR_SHIPTO STRUCTURE  /ADESSO/MT_ESHIPTO_DI OPTIONAL
*"      IPAR_TAXNUM STRUCTURE  /ADESSO/MT_EMG_FKKBPTAX_DI OPTIONAL
*"      IPAR_ECCARD STRUCTURE  /ADESSO/MT_ECONCARD_DI OPTIONAL
*"      IPAR_ECCRDH STRUCTURE  /ADESSO/MT_ECONCARDH_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PAR) LIKE  BUT000-PARTNER
*"----------------------------------------------------------------------
  DATA: w_tariftyp LIKE eanlh-tariftyp.


* Geschäftspartnerart auf Grund von Tariftypen in der Anlage zuordnen
* Es wird immer der Tariftyp der ersten gefundenen Anlage genommen
  READ TABLE ipar_init INDEX 1.

  CLEAR w_tariftyp.
  SELECT SINGLE eanlh~tariftyp INTO w_tariftyp
                FROM fkkvkp JOIN ever ON ever~vkonto = fkkvkp~vkont
                            JOIN eanl ON eanl~anlage = ever~anlage
                            JOIN eanlh ON eanlh~anlage = ever~anlage
                WHERE fkkvkp~gpart = ipar_init-partner
                  AND ever~auszdat = '99991231'
                  AND eanl~service NE 'G6-N'     "kein Netztarif
                  AND eanlh~bis = '99991231'.

  CASE w_tariftyp.

    WHEN 'GSK-S1G01' OR 'GSK-S1G02' OR 'GSK-S1G65'
                     OR 'GSK-S1G72' OR 'GSK-S1G81'.
      ipar_init-bpkind = 'GROS'.                       "Großkunden
      MODIFY ipar_init INDEX 1.

    WHEN 'ATK-E1A90' OR 'ATK-G1A00'  OR 'ATK-G1A01' OR 'ATK-G1A75'
                     OR 'ATK-V1A00'  OR 'GTK-E1G90' OR 'GTK-G1BEST'
                     OR 'GTK-TRADER' OR 'WTK-E1W30' OR 'WTK-G1W00'
                     OR 'WTK-G1W75'  OR 'WTK-S1W01' OR 'WTK-S1W02'
                     OR 'WTK-S1W03'  OR 'WTK-V1W00'.
      ipar_init-bpkind = 'GEWE'.                       "Gewerbe
      MODIFY ipar_init INDEX 1.

    WHEN 'ATK-GEA01' OR 'ATK-GEA50' OR 'ATK-GEA51' OR 'ATK-NWA00'
                     OR 'ATK-T1A00' OR 'ATK-T1A01' OR 'ATK-T1A31'
                     OR 'ATK-T1A55' OR 'ETK-T1F00' OR 'GTK-T1BEST'
                     OR 'WTK-T1W00' OR 'WTK-T1W20' OR 'WTK-T1W45'.
      ipar_init-bpkind = 'PRIV'.                       "Privatkunden
      MODIFY ipar_init INDEX 1.

    WHEN OTHERS.
*     GP's ohne Tariftypen:
*     Regelung auf Grund der Abstimmung Fachbereich - TP
      IF ipar_init-bpkind IS INITIAL OR
         ipar_init-bpkind EQ '0001'.
        ipar_init-bpkind = 'PRIV'.
        MODIFY ipar_init INDEX 1.
*     elseif.
*       sonst Übernahme des gelieferten alten Wertes
      ENDIF.
*
*      concatenate 'Fehler bei Bestimmung der Geschäftspartnerart -'
*                  'Tariftyp:'  w_tariftyp
*                   into meldung-meldung
*                   separated by space.
*      append meldung.

  ENDCASE.


* Wegen mangelnder Datenqualität wurde eine Reihe von Ersatzwerten definiert,
* die bis zum Prod.Gang durch Datenpflege ersetzt werden sollen
*------------------------------------------------------------------------>>>
* Anredeschlüssel
  READ TABLE ipar_but000 INDEX 1.
  READ TABLE ipar_init INDEX 1.

  IF ipar_but000-title IS INITIAL.
    CASE ipar_init-bu_type.

      WHEN '1'.
        ipar_but000-title = '0006'.

      WHEN '2'.
        ipar_but000-title = '0098'.

      WHEN '3'.
        ipar_but000-title = '0098'.

    ENDCASE.
  ENDIF.
  MODIFY ipar_but000 INDEX 1.

* Vornamen
  READ TABLE ipar_but000 INDEX 1.
  IF ipar_but000-name_first IS INITIAL.
    ipar_but000-name_first = '.'.
    MODIFY ipar_but000 INDEX 1.
  ENDIF.

* Geschäftspartner-Gruppenart
  READ TABLE ipar_but000 INDEX 1.
  READ TABLE ipar_init INDEX 1.
  IF ipar_init-bu_type NE '1' AND           "Organisation oder Gruppe
     ipar_but000-partgrptyp IS INITIAL.
    ipar_but000-partgrptyp = '0001'.       "WEG
    MODIFY ipar_but000 INDEX 1.
  ENDIF.

*------------------------------------------------------------------------<<<


ENDFUNCTION.
