FUNCTION /ADESSO/MTU_SAMPL_ENT_INST_MGM.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INM_DI_INT STRUCTURE  /ADESSO/MT_EMG_WOL OPTIONAL
*"      INM_DI_ZW STRUCTURE  /ADESSO/MT_REG30_ZW_C OPTIONAL
*"      INM_DI_GER STRUCTURE  /ADESSO/MT_REG30_GERA OPTIONAL
*"      INM_DI_CNT STRUCTURE  /ADESSO/MT_EMG_INSTALL_CONTAINE OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_INM) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* SAMPLE-Baustein zur Umschlüsselung des Geräteeinbau /-ausbau /-wechsel
* (Entladung)
  TABLES: eanlh, eanl.
  DATA: h_tariftyp LIKE eanlh-tariftyp.

* um den Fehler 'Gasverfahren nicht gültig'
* auszuschalten, auch wieder in Tabelle
* /ADESSO/MT_UMSFU genommen,
* Fehler kommen zustande, weil in den
* alten Zeitscheiben 'falsche' oder keine Gasverfahren gepflegt sind.
* jetzt zur Fehlerkorrektur: Abgleich auf die jetzt gültige Zeitscheibe, Test auf
* Tarifkunden und dann immer gleichem Gasverfahren!

  READ TABLE inm_di_int INDEX 1.
* nur beim Gasverfahren
  SELECT SINGLE * FROM eanl
             WHERE anlage = inm_di_int-anlage AND
                   sparte = '02'.
  IF sy-subrc = 0.
    LOOP AT inm_di_zw.
      SELECT SINGLE * FROM eanlh
             WHERE anlage   = inm_di_int-anlage AND
                   bis      = '99991231'.
      IF sy-subrc = 0.
        IF eanlh-aklasse = 'TK' .
          MOVE: 'GVTKFEST' TO inm_di_zw-thgver,
                'FT01'     TO inm_di_zw-festtemp.
          MODIFY inm_di_zw.
        ENDIF.
      else.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Abrechnungssteuerung für den Tariftyp GNNEXPNV aufbauen
  READ TABLE inm_di_int INDEX 1.
  SELECT SINGLE tariftyp INTO h_tariftyp
         FROM eanlh
         WHERE anlage = inm_di_int-anlage
           AND ab  LE inm_di_int-eadat
           AND bis GE inm_di_int-eadat.

  CHECK h_tariftyp = 'GNNEXPNV'.
  LOOP AT inm_di_zw.

    inm_di_zw-zwnabr = 'X'.
    CLEAR inm_di_zw-tarifart.
    MODIFY inm_di_zw.

  ENDLOOP.

ENDFUNCTION.
