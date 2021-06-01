FUNCTION /ADESSO/MTU_SAMPL_BEL_BCONTACT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBCT_BCONTD STRUCTURE  BCONTD OPTIONAL
*"      IBCT_PBCOBJ STRUCTURE  BPC_OBJ OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BCT) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* SAMPLE-Baustein zur Umschlüsselung Kundenkontakte

* Handling der Umschlüsselungen hinzugefügt.
* Umschlüsselungshandling
  IF filled_kt IS INITIAL.
    SELECT * FROM /adesso/mtu_ktkt INTO TABLE iums_kt.
    filled_kt = 'X'.
  ENDIF.

  LOOP AT ibct_bcontd.
    READ TABLE iums_kt WITH KEY cclass_alt = ibct_bcontd-cclass
                                aktiv_alt  = ibct_bcontd-activity.
    IF sy-subrc = 0.
      ibct_bcontd-cclass = iums_kt-cclass_neu.
      ibct_bcontd-activity = iums_kt-aktiv_neu.
      MODIFY ibct_bcontd.
    ELSE.
      CONCATENATE 'Keine Umschlüsselung für Kontaktklasse Aktivität'
                  ibct_bcontd-cclass ibct_bcontd-activity
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDLOOP.








ENDFUNCTION.
