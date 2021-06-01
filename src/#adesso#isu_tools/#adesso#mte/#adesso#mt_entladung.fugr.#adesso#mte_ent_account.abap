FUNCTION /ADESSO/MTE_ENT_ACCOUNT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VKONT) TYPE  FKKVK-VKONT
*"     REFERENCE(X_OBJECT) TYPE  EMG_OBJECT
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_VK_INIT) TYPE  I
*"     REFERENCE(ANZ_VK) TYPE  I
*"     REFERENCE(ANZ_VKP) TYPE  I
*"     REFERENCE(ANZ_VKLOCK) TYPE  I
*"     REFERENCE(ANZ_VKCORR) TYPE  I
*"     REFERENCE(ANZ_VKTAXEX) TYPE  I
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

  object   = x_object.
  ent_file = pfad_dat_ent.
  oldkey_acc = x_vkont.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = oldkey_acc
    IMPORTING
      output = oldkey_acc.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  PERFORM init_acc.
  CLEAR: iacc_out, wacc_out, meldung, anz_obj.
  REFRESH: iacc_out, meldung.
*<


*> Datenermittlung ---------

  SELECT * FROM fkkvkp WHERE vkont = oldkey_acc.

    MOVE-CORRESPONDING fkkvkp TO iacc_vkp.
    MOVE fkkvkp-gpart TO iacc_vkp-partner.
*   für die Migration der Fixen Adressen müssen die Nummer als
*   extern deklariert werden
    move fkkvkp-adrnb to iacc_vkp-adrnb_ext.
    move fkkvkp-adrre to iacc_vkp-adrre_ext.
    move fkkvkp-adrra to iacc_vkp-adrra_ext.
    move fkkvkp-adrrh to iacc_vkp-adrrh_ext.
    move fkkvkp-adrma to iacc_vkp-adrma_ext.

**  Wenn für den Eingangszahlweg keine Bankverbindung hinterlegt ist,
**  den Eingangszahlweg löschen
    IF iacc_vkp-ebvty IS INITIAL.
      CLEAR iacc_vkp-ezawe.
    ENDIF.

*iacc_INIT
    SELECT SINGLE * FROM fkkvk WHERE vkont = fkkvkp-vkont.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING fkkvk TO iacc_init.
      MOVE fkkvkp-gpart TO iacc_init-gpart.
      MOVE fkkvkp-gpart TO iacc_init-gpart_hdr_ext.
      MOVE fkkvkp-vkont TO iacc_init-vkona.
      APPEND iacc_init.
      CLEAR  iacc_init.
    ELSE.
      meldung-meldung =
         'Vertragskonto nicht in FKKVK gefunden'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.

*iacc_VK
    IF NOT fkkvkp-vkbez IS INITIAL.
      MOVE fkkvkp-vkbez TO iacc_vk-vkbez.
*     Fehlende VK-Struktur führt zum Abbruch bei EMIGALL
    else.
      move '.' to iacc_vk-vkbez.
    endif.
    APPEND iacc_vk.
    CLEAR  iacc_vk.


* i acc_VKLOCK
    SELECT * FROM dfkklocks WHERE vkont EQ fkkvkp-vkont
                              AND lotyp EQ '06'
*-----historische Sperren wieder ausklammern ----->>>>
                              AND tdate GE sy-datum.
*--------------------------------------------------<<<<

      MOVE dfkklocks-lotyp          TO iacc_vklock-lotyp_key.
      MOVE dfkklocks-proid          TO iacc_vklock-proid_key.
      MOVE dfkklocks-lockr          TO iacc_vklock-lockr_key.
      MOVE dfkklocks-fdate          TO iacc_vklock-fdate_key.
      MOVE dfkklocks-tdate          TO iacc_vklock-tdate_key.
      MOVE dfkklocks-cond_loobj     TO iacc_vklock-cond_loobj_dat.
      MOVE dfkklocks-gpart          TO iacc_vklock-lockpartner.
      MOVE dfkklocks-actkey         TO iacc_vklock-activity_dat.

      APPEND iacc_vklock.
      CLEAR iacc_vklock.

    ENDSELECT.


*   iacc_VKCORR
    SELECT * FROM fkkvk_corr  WHERE vkont EQ fkkvkp-vkont.

      MOVE-CORRESPONDING fkkvk_corr TO iacc_vkcorr.
      MOVE fkkvk_corr-gpart TO iacc_vkcorr-account_bp.
      APPEND iacc_vkcorr.
      CLEAR iacc_vkcorr.

    ENDSELECT.


*   iacc_VKTXEX
    SELECT * FROM dfkktaxex WHERE vkont EQ fkkvkp-vkont.

      MOVE-CORRESPONDING dfkktaxex TO iacc_vktxex.
      APPEND iacc_vktxex.
      CLEAR iacc_vktxex.

    ENDSELECT.

  ENDSELECT.

* iacc_VKP
  IF sy-subrc EQ 0.
    APPEND iacc_vkp.
    CLEAR  iacc_vkp.
  ELSE.
    meldung-meldung =
        'Vertragskonto nicht in FKKVKP gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_acc.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_ACCOUNT'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma       = firma
      TABLES
        meldung     = meldung
        iacc_init   = iacc_init
        iacc_vk     = iacc_vk
        iacc_vkp    = iacc_vkp
        iacc_vklock = iacc_vklock
        iacc_vkcorr = iacc_vkcorr
        iacc_vktxex = iacc_vktxex
      CHANGING
        oldkey_acc  = oldkey_acc.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_iacc_out USING oldkey_acc
                              firma
                              object
                              anz_vk_init
                              anz_vk
                              anz_vkp
                              anz_vklock
                              anz_vkcorr
                              anz_vktaxex.


  LOOP AT iacc_out INTO wacc_out.
    TRANSFER wacc_out TO ent_file.
  ENDLOOP.




ENDFUNCTION.
