FUNCTION /ADESSO/MTE_ENT_INVOICE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_BELEG) TYPE  CHAR18
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_HEAD) TYPE  I
*"     REFERENCE(ANZ_DOC) TYPE  I
*"     REFERENCE(ANZ_DOC_DB) TYPE  I
*"     REFERENCE(ANZ_LINEB) TYPE  I
*"     REFERENCE(ANZ_APPEND) TYPE  I
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
  DATA: p_beginn        LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: wa_euitrans TYPE euitrans.
  DATA: wa_extid    TYPE tinv_inv_extid.
  DATA: wa_tinv_inv_bank TYPE tinv_inv_bank.
  DATA: y_eadrdat  TYPE eadrdat.

  DATA: quant2 TYPE string.
  DATA: discount TYPE string.

  object     = 'INVOICE'.
  ent_file   = pfad_dat_ent.
  oldkey_inv = x_beleg.

** Ermitteln des Umschlüsselungs-Fubas
*  CLEAR ums_fuba.
*  SELECT SINGLE zfuba INTO ums_fuba
*         FROM /evuit/mt_ums_fu
*              WHERE object = object
*                AND firma  = firma
*                AND zricht = 'ENT'.


* Initialisierung
  PERFORM init_inv.
  CLEAR: iinv_out, winv_out, meldung, anz_obj.
  REFRESH: iinv_out, meldung.

* Die Tabelle TINV_INV_HEAD zur Belegnummer lesen und Daten übertragen
  SELECT SINGLE * FROM tinv_inv_head WHERE int_inv_no = oldkey_inv.
  MOVE-CORRESPONDING tinv_inv_head TO iinv_head.

* Tabelle TINV_INV_DOC lesen
  SELECT SINGLE * FROM tinv_inv_doc
      WHERE int_inv_no = tinv_inv_head-int_inv_no.

* Das Original der Tabelle wird im Zielsystem benötigt
* (für mögliche Statusanpassungen)
  MOVE-CORRESPONDING tinv_inv_doc TO iinv_docdb.
  APPEND iinv_docdb.
  CLEAR iinv_docdb.

  MOVE-CORRESPONDING tinv_inv_doc TO iinv_doc.
  MOVE tinv_inv_doc-int_inv_doc_no TO iinv_doc-inv_bulk_ref.

  iinv_head-invoice_date = tinv_inv_doc-invoice_date.

  CASE tinv_inv_doc-inv_doc_status.
    WHEN '01'.
      iinv_head-invoice_type = '100'.
    WHEN '02'.
      iinv_head-invoice_type = '100'.
    WHEN '04'.
      iinv_head-invoice_type = '100'.
    WHEN '05'.
      iinv_head-invoice_type = '100'.
    WHEN '06'.
      iinv_head-invoice_type = '100'.
    WHEN '07'.
      iinv_head-invoice_type = '100'.
    WHEN '08'.
      iinv_head-invoice_type = '101'.
    WHEN '09'.
      iinv_head-invoice_type = '100'.
    WHEN '12'.
      iinv_head-invoice_type = '101'.
    WHEN '13'.
      iinv_head-invoice_type = '101'.
    WHEN '16'.
      iinv_head-invoice_type = '101'.

  ENDCASE.

  CASE tinv_inv_doc-inv_doc_status.
    WHEN '04'.
      iinv_head-invoice_status = '02'.
    WHEN '05'.
      iinv_head-invoice_status = '02'.
    WHEN '08'.
      iinv_head-invoice_status = '04'.
    WHEN '09'.
      iinv_head-invoice_status = '02'.
    WHEN '13'.
      iinv_head-invoice_status = '02'.
    WHEN '16'.
      iinv_head-invoice_status = '02'.
    WHEN '12'.
      iinv_head-invoice_status = '04'.
  ENDCASE.

  APPEND iinv_head.
  CLEAR iinv_head.

* Füllen der Felder für IINV_DOC

* Externer Zählpukt
  CLEAR wa_extid.
  SELECT * FROM tinv_inv_extid INTO wa_extid
     WHERE int_inv_doc_no = tinv_inv_doc-int_inv_doc_no.
    EXIT.
  ENDSELECT.
  iinv_doc-ext_ident_type = wa_extid-ext_ident_type.
  iinv_doc-ext_ident = wa_extid-ext_ident.
* Geschäftspartnerdaten
  iinv_doc-mc_name1 = wa_extid-mc_name1.
  iinv_doc-mc_name2 = wa_extid-mc_name2.
  iinv_doc-mc_street = wa_extid-mc_street.
  CONCATENATE wa_extid-mc_house_num1
              wa_extid-mc_house_num2
              INTO iinv_doc-mc_house_num1
              SEPARATED BY space.
  iinv_doc-mc_city1 = wa_extid-mc_city1.
  iinv_doc-mc_postcode = wa_extid-mc_postcode.

**  Wenn in der Tabelle TINV_INV_EXTID der ext. ZP nicht gefüllt ist
**  diesen über die interne ZP-Bezeichnung aus der TINV_INV_DOC über
**  die EUITRANS ermitteln
  IF wa_extid-ext_ident IS INITIAL.
    iinv_doc-ext_ident_type = '01'.
    CLEAR wa_euitrans.
    SELECT * FROM euitrans INTO wa_euitrans
      WHERE int_ui = tinv_inv_doc-int_ident.
      EXIT.
    ENDSELECT.
    iinv_doc-ext_ident = wa_euitrans-ext_ui.
  ENDIF.

* Bankdaten
* Sender
  CLEAR wa_tinv_inv_bank.
  IF tinv_inv_doc-int_inv_bkid IS NOT INITIAL.
    SELECT SINGLE * FROM tinv_inv_bank
       INTO wa_tinv_inv_bank
      WHERE int_inv_bkid = tinv_inv_doc-int_inv_bkid.

    IF sy-subrc = 0.
      iinv_doc-banks = wa_tinv_inv_bank-banks.
      iinv_doc-bankl = wa_tinv_inv_bank-bankl.
      iinv_doc-bankn = wa_tinv_inv_bank-bankn.
      iinv_doc-koinh = wa_tinv_inv_bank-koinh.
    ENDIF.
  ENDIF.

* Empfänger
  CLEAR wa_tinv_inv_bank.
  IF tinv_inv_doc-int_inv_bkid_r IS NOT INITIAL.
    SELECT SINGLE * FROM tinv_inv_bank
        INTO wa_tinv_inv_bank
          WHERE int_inv_bkid = tinv_inv_doc-int_inv_bkid_r.

    IF sy-subrc = 0.
      iinv_doc-banks_recv = wa_tinv_inv_bank-banks.
      iinv_doc-bankl_recv = wa_tinv_inv_bank-bankl.
      iinv_doc-bankn_recv = wa_tinv_inv_bank-bankn.
      iinv_doc-koinh_recv = wa_tinv_inv_bank-koinh.
    ENDIF.
  ENDIF.


*** Geschäftspartnerdaten
***  IF tinv_inv_doc-int_partner IS NOT INITIAL.
***    CLEAR y_eadrdat.
***    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
***      EXPORTING
***        x_address_type             = 'B'
***        x_partner                  = tinv_inv_doc-int_partner
***      IMPORTING
***        y_eadrdat                  = y_eadrdat
***      EXCEPTIONS
***        not_found                  = 1
***        parameter_error            = 2
***        object_not_given           = 3
***        address_inconsistency      = 4
***        installation_inconsistency = 5
***        OTHERS                     = 6.
***    IF sy-subrc <> 0.
**** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
****         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
***    ENDIF.
***
***    iinv_doc-mc_name1 = y_eadrdat-name1.
***    iinv_doc-mc_name2 = y_eadrdat-name2.
***    iinv_doc-mc_street = y_eadrdat-street.
****    iinv_doc-mc_house_num1 = y_eadrdat-house_num1.
***    CONCATENATE y_eadrdat-house_num1
***                y_eadrdat-house_num2
***                INTO iinv_doc-mc_house_num1
***                SEPARATED BY space.
***    iinv_doc-mc_city1 = y_eadrdat-city1.
***    iinv_doc-mc_postcode = y_eadrdat-post_code1.
***  ENDIF.


  APPEND iinv_doc.
  CLEAR iinv_doc.


  IF tinv_inv_doc-/idexge/contname IS NOT INITIAL OR
     tinv_inv_doc-/idexge/phone IS NOT INITIAL OR
     tinv_inv_doc-/idexge/mobphone IS NOT INITIAL OR
     tinv_inv_doc-/idexge/othphone IS NOT INITIAL OR
     tinv_inv_doc-/idexge/e_mail IS NOT INITIAL OR
     tinv_inv_doc-/idexge/fax IS NOT INITIAL OR
    tinv_inv_doc-/idexge/neg_pan IS NOT INITIAL.

    iinv_append-structure = cl_inv_inv_remadv_doc=>co_bapi_te_doc.
    iinv_append-valuepart1+0 = '000000000000000000'.
    iinv_append-valuepart1+18 = tinv_inv_doc-/idexge/contname.
    iinv_append-valuepart1+53 = tinv_inv_doc-/idexge/phone.
    iinv_append-valuepart1+93 = tinv_inv_doc-/idexge/mobphone.
    iinv_append-valuepart1+133 = tinv_inv_doc-/idexge/othphone.
    iinv_append-valuepart1+173 = tinv_inv_doc-/idexge/e_mail.
    iinv_append-valuepart2+174 = tinv_inv_doc-/idexge/fax.
    iinv_append-valuepart2+214 = tinv_inv_doc-/idexge/neg_pan.

    APPEND iinv_append.
    CLEAR iinv_append.

  ENDIF.

**  LINE_B
  SELECT * FROM tinv_inv_line_b
     WHERE int_inv_doc_no  = tinv_inv_doc-int_inv_doc_no.

    MOVE-CORRESPONDING tinv_inv_line_b TO iinv_lineb.

    APPEND iinv_lineb.
    CLEAR  iinv_lineb.

**  APPEND-für LINEB
    CLEAR: quant2, discount.
    iinv_append-structure = cl_inv_inv_remadv_doc=>co_bapi_te_line_b.
    iinv_append-valuepart1+0 = '000000000000000000000000'.
    iinv_append-valuepart1+24 = tinv_inv_line_b-/idexge/line_id.
    MOVE tinv_inv_line_b-/idexge/quant2 TO quant2.
    MOVE tinv_inv_line_b-/idexge/discount TO discount.
    iinv_append-valuepart1+32 = quant2.
    iinv_append-valuepart1+47 = tinv_inv_line_b-/idexge/invunit2.
    iinv_append-valuepart1+50 = discount.
    iinv_append-valuepart1+63 = tinv_inv_line_b-/idexge/currency.
*    iinv_append-valuepart1+40 = tinv_inv_line_b-/idexge/invunit2.
*    iinv_append-valuepart1+43 = discount.
*    iinv_append-valuepart1+50 = tinv_inv_line_b-/idexge/currency.
    APPEND iinv_append.
    CLEAR iinv_append.

  ENDSELECT.


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_inv.
  CALL FUNCTION '/EVUIT/MTE_OBJKEY_INSERT_ONE'
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

** Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
**  IF NOT ums_fuba IS INITIAL.
**         CALL FUNCTION '/EVUIT/MTU_SAMPLE_ENT_MOVE_OUT'
**    CALL FUNCTION ums_fuba
**      EXPORTING
**        firma      = firma
**      TABLES
**        meldung    = meldung
**        auszbeleg  = imoo_auszbeleg
**      CHANGING
**        oldkey_moh = oldkey_moh.
**  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_inv_out USING oldkey_inv
                             firma
                             object
                             anz_head
                             anz_doc
                             anz_doc_db
                             anz_lineb
                             anz_append.


  LOOP AT iinv_out INTO winv_out.
    TRANSFER winv_out TO ent_file.
  ENDLOOP.






ENDFUNCTION.
