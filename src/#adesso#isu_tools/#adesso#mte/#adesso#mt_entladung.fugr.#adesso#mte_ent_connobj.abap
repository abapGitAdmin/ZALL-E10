FUNCTION /ADESSO/MTE_ENT_CONNOBJ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HAUS) LIKE  EHAUISU-HAUS
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_EHAUD) TYPE  I
*"     REFERENCE(ANZ_ADDR_DATA) TYPE  I
*"     REFERENCE(ANZ_ADDR_COMM_DATA) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      GEN_ERROR
*"      ERROR
*"----------------------------------------------------------------------

DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  data: o_key           TYPE  EMG_OLDKEY.

  object     = 'CONNOBJ'.
  ent_file   = pfad_dat_ent.
  oldkey_con = x_haus.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_con.
  CLEAR: icon_out, wcon_out, meldung, ANZ_OBJ.
  REFRESH: icon_out, meldung.
*<

*> Datenermittlung ---------
  SELECT SINGLE * FROM ehauisu WHERE haus EQ oldkey_con.
  IF sy-subrc NE 0.
    meldung-meldung = 'Anschlußobjekt nicht in EHAUISU gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*icon_co_eha
  SELECT SINGLE * FROM  iflot  WHERE tplnr  = ehauisu-haus.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iflot TO icon_co_eha.
  ENDIF.
  SELECT SINGLE * FROM  iflotx WHERE tplnr  = ehauisu-haus.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iflotx TO icon_co_eha.
  ENDIF.
  SELECT SINGLE * FROM  iloa   WHERE tplnr  = ehauisu-haus.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING iloa  TO icon_co_eha.
  ENDIF.

  MOVE-CORRESPONDING ehauisu  TO icon_co_eha.

  APPEND icon_co_eha.
  CLEAR  icon_co_eha.


*icon_co_adr
  SELECT SINGLE * FROM  adrc  WHERE addrnumber  = iloa-adrnr.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adrc TO icon_co_adr.
  ELSE.
    meldung-meldung = 'keine Adressdaten gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.
  APPEND icon_co_adr.
  CLEAR  icon_co_adr.


*icon_co_com
  SELECT SINGLE * FROM adr2 WHERE addrnumber = iloa-adrnr.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adr2 TO icon_co_com.
  ENDIF.
  SELECT SINGLE * FROM adr3 WHERE addrnumber = iloa-adrnr.
  IF sy-subrc EQ 0.
    MOVE-CORRESPONDING adr3 TO icon_co_com.
  ENDIF.
  IF NOT icon_co_com IS INITIAL.
    APPEND icon_co_com.
    CLEAR icon_co_com.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_con.
  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
       EXPORTING
            i_firma  = firma
            i_object = object
            i_oldkey = o_key
       EXCEPTIONS
            error    = 1
            OTHERS   = 2.
  IF sy-subrc <> 0.
    meldung-meldung =
        'Fehler bei wegschreiben in Entlade-KSV'.
    APPEND meldung.
    RAISE error.
  ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV



    ADD 1 TO anz_obj.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_CONNOBJ'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              icon_co_eha = icon_co_eha
              icon_co_adr = icon_co_adr
              icon_co_com = icon_co_com
         CHANGING
              oldkey_con  = oldkey_con.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_icon_out USING oldkey_con
                              firma
                              object
                              anz_ehaud
                              anz_addr_data
                              anz_addr_comm_data.



  LOOP AT icon_out INTO wcon_out.
    TRANSFER wcon_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
