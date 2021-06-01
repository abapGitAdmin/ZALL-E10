FUNCTION /ADESSO/FKK_SAMPLE_5067_SWK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_BFKKZK) LIKE  BFKKZK STRUCTURE  BFKKZK
*"     REFERENCE(I_FKKCOLLP) TYPE  FKKCOLLP OPTIONAL
*"  TABLES
*"      CT_BFKKZS STRUCTURE  BFKKZS OPTIONAL
*"      CT_BFKKZV STRUCTURE  BFKKZV OPTIONAL
*"  CHANGING
*"     REFERENCE(C_BFKKZP) LIKE  BFKKZP STRUCTURE  BFKKZP
*"--------------------------------------------------------------------
  INCLUDE: <cntn01>.

  DATA:       ls_bapidfkkko         TYPE bapidfkkko,
              lt_bapidfkkop         TYPE STANDARD TABLE OF bapidfkkop,
              lt_bapidfkkop_z       TYPE STANDARD TABLE OF bapidfkkop,
              ls_bapidfkkop_temp    TYPE bapidfkkop,
              ls_bapidfkkop_temp_z  TYPE bapidfkkop,
              lt_bapidfkkopk        TYPE STANDARD TABLE OF bapidfkkopk,
              lt_bapidfkkopk_z      TYPE STANDARD TABLE OF bapidfkkopk,
              ls_bapidfkkopk_temp   TYPE bapidfkkopk,
              ls_bapidfkkopk_temp_z TYPE bapidfkkopk,
              f_fikey               LIKE fkkko-fikey,
              lv_doc_no             TYPE bapidfkkko-doc_no,
              lv_testrun            TYPE bapictracaux-testrun,
              ls_bapiret2           TYPE bapiret2,
              lv_vkont              TYPE fkkvkp,
              string_objkey         TYPE c LENGTH 100,
              string_belnr          TYPE c LENGTH 100,
              lv_txtvw              TYPE bfkkzp-txtvw.

  DATA:         isupartner TYPE swc_object,
                bcontact   TYPE swc_object.

  TYPES: BEGIN OF ty_obj_zeile,
           objrole(12) TYPE c,
           objtype(10) TYPE c,
           objkey(70)  TYPE c,
         END OF ty_obj_zeile.

  DATA: gwa_obj TYPE ty_obj_zeile,
        it_obj  TYPE TABLE OF ty_obj_zeile.

  FIELD-SYMBOLS: <ptr>.

  CONSTANTS:  lc_appl_area      LIKE bapidfkkko-appl_area VALUE 'R',
              lc_doc_type       LIKE bapidfkkko-doc_type VALUE 'SK', "Kosten
              lc_main_trans     TYPE bapidfkkop-main_trans VALUE 'MWST',
              lc_main_trans_z   TYPE bapidfkkop-main_trans VALUE 'MAZI',
              lc_sub_trans      LIKE bapidfkkop-sub_trans VALUE 'GUTH',
              lc_sub_trans_z    LIKE bapidfkkop-sub_trans VALUE 'ZFOR',
              lc_doc_source_key LIKE bapidfkkko-doc_source_key VALUE '01', "Manuelle Buchuung
              lc_currency       LIKE bapidfkkko-currency VALUE 'EUR',
              lc_currency_iso   LIKE bapidfkkko-currency_iso VALUE 'EUR',
              lc_comp_code      LIKE bapidfkkop-comp_code VALUE '0010'. "Mark-E

*>>>>>>>>>> BUCHUNG NUR SIMULIEREN, WENN DATEI NUR GETESTET WIRD (Selektionsparameter)
  ASSIGN ('(RFKKCOPM)P_TEST') TO <ptr>. "Clean Assign
  lv_testrun = <ptr>.
*<<<<<<<<<< BUCHUNG NUR SIMULIEREN, WENN DATEI NUR GETESTET WIRD

  IF i_fkkcollp-zz_flag1 = '01'.  " Nur bei Vollzahlung



    SELECT SINGLE * FROM fkkvkp INTO lv_vkont WHERE vkont = i_fkkcollp-vkont. "Vertragskonto zur Position lesen (Für KOFI)

    ls_bapidfkkko-doc_type = lc_doc_type. " Belegart festlegen

*>>>>>>>>>> DOCUMENT HEADER FÜLLEN

    ls_bapidfkkko-doc_type = lc_doc_type.
    ls_bapidfkkko-appl_area = lc_appl_area.
    ls_bapidfkkko-doc_source_key = lc_doc_source_key.
    ls_bapidfkkko-created_by = sy-uname.
    ls_bapidfkkko-entry_date = sy-datum.
    ls_bapidfkkko-entry_time = sy-uzeit.
    ls_bapidfkkko-doc_date = sy-datum.
    ls_bapidfkkko-post_date = sy-datum.
    ls_bapidfkkko-currency = lc_currency.
    ls_bapidfkkko-currency_iso = lc_currency_iso.


    IF i_fkkcollp-zz_mwst > 0.

      ls_bapidfkkop_temp-item = 0001.
      ls_bapidfkkop_temp-appl_area = lc_appl_area.
      ls_bapidfkkop_temp-main_trans = lc_main_trans.
      ls_bapidfkkop_temp-sub_trans = lc_sub_trans.
      ls_bapidfkkop_temp-buspartner = i_fkkcollp-gpart.
      ls_bapidfkkop_temp-cont_acct = i_fkkcollp-vkont.
      ls_bapidfkkop_temp-amount_loc_curr = i_fkkcollp-zz_mwst * -1.
      ls_bapidfkkop_temp-amount = i_fkkcollp-zz_mwst * -1.
      ls_bapidfkkop_temp-discount_base = i_fkkcollp-zz_mwst * -1.
      ls_bapidfkkop_temp-net_date = sy-datum.
      ls_bapidfkkop_temp-disc_due = sy-datum.
      ls_bapidfkkop_temp-comp_code = lc_comp_code.
      ls_bapidfkkop_temp-doc_date = sy-datum.
      ls_bapidfkkop_temp-post_date = sy-datum.
      ls_bapidfkkop_temp-currency = lc_currency.
      ls_bapidfkkop_temp-currency_iso = lc_currency_iso.
      ls_bapidfkkop_temp-ref_doc_no = i_fkkcollp-opbel.

      PERFORM get_sachkonto
         USING 'R000' "Hauptvorgangsrelevante Kontierungsdaten
               lv_vkont-kofiz_sd
               lc_main_trans
               ''
               lc_comp_code
               'EM'
         CHANGING ls_bapidfkkop_temp-g_l_acct. "Sachkonto der Hauptbuchhaltung

      APPEND ls_bapidfkkop_temp TO lt_bapidfkkop.
    ENDIF.

    IF i_fkkcollp-zz_mwst_zins > 0.

      ls_bapidfkkop_temp-item = ls_bapidfkkop_temp-item + 1.

      ls_bapidfkkop_temp-amount_loc_curr = i_fkkcollp-zz_mwst_zins * -1.
      ls_bapidfkkop_temp-amount = i_fkkcollp-zz_mwst_zins * -1.
      ls_bapidfkkop_temp-discount_base = i_fkkcollp-zz_mwst_zins * -1.



      APPEND ls_bapidfkkop_temp TO lt_bapidfkkop.
    ENDIF.

    IF i_fkkcollp-zz_zins > 0.

      ls_bapidfkkop_temp-item = ls_bapidfkkop_temp-item + 1.

      ls_bapidfkkop_temp-amount_loc_curr = i_fkkcollp-zz_zins.
      ls_bapidfkkop_temp-amount = i_fkkcollp-zz_zins.
      ls_bapidfkkop_temp-discount_base = i_fkkcollp-zz_zins.

      ls_bapidfkkop_temp-main_trans = lc_main_trans_z.
      ls_bapidfkkop_temp-sub_trans = lc_sub_trans_z.

      PERFORM get_sachkonto
      USING 'R000' "Hauptvorgangsrelevante Kontierungsdaten
            lv_vkont-kofiz_sd
            lc_main_trans_z
            ''
            lc_comp_code
            'EM'
      CHANGING ls_bapidfkkop_temp-g_l_acct. "Sachkonto der Hauptbuchhaltung

      APPEND ls_bapidfkkop_temp TO lt_bapidfkkop.
    ENDIF.

*<<<<<<<<<< POSITIONEN

*Gegenposition aufbauen

    IF i_fkkcollp-zz_mwst > 0.
      ls_bapidfkkopk_temp-item      = 0001.
      ls_bapidfkkopk_temp-comp_code = lc_comp_code.
* Sachkonto ermitteln (hauptvorgangsrelevant)
      PERFORM get_sachkonto
         USING 'R001' "Vorgangsrelevante Kontierungsdaten
               lv_vkont-kofiz_sd
               lc_main_trans
               lc_sub_trans
               lc_comp_code
               'EM'
         CHANGING ls_bapidfkkopk_temp-g_l_acct. "Sachkonto der Hauptbuchhaltung

      ls_bapidfkkopk_temp-amount_loc_curr = i_fkkcollp-zz_mwst.
      ls_bapidfkkopk_temp-amount          = i_fkkcollp-zz_mwst.
*    ls_genledgerpositions-value_date      = sy-datum.
*  ls_bapidfkkopk_temp-fikey           = ls_documentheader-fikey.
      APPEND ls_bapidfkkopk_temp TO lt_bapidfkkopk.
*<< 1. Positionsdaten "Gutschrift auf dem Sammelbestellerkonto" aufbauen
    ENDIF.

    IF i_fkkcollp-zz_mwst_zins > 0.

      ls_bapidfkkopk_temp-item = ls_bapidfkkopk_temp-item + 1.

      ls_bapidfkkopk_temp-amount_loc_curr = i_fkkcollp-zz_mwst_zins.
      ls_bapidfkkopk_temp-amount          = i_fkkcollp-zz_mwst_zins.
      APPEND ls_bapidfkkopk_temp TO lt_bapidfkkopk.

    ENDIF.

    IF i_fkkcollp-zz_zins > 0.

      ls_bapidfkkopk_temp-item = ls_bapidfkkopk_temp-item + 1.

      ls_bapidfkkopk_temp-amount_loc_curr = i_fkkcollp-zz_zins * -1.
      ls_bapidfkkopk_temp-amount          = i_fkkcollp-zz_zins * -1.

      ls_bapidfkkopk_temp-tax_code        = 'A0'.

      PERFORM get_sachkonto
      USING 'R001' "Vorgangsrelevante Kontierungsdaten
            lv_vkont-kofiz_sd
            lc_main_trans_z
            lc_sub_trans_z
            lc_comp_code
            'EM'
      CHANGING ls_bapidfkkopk_temp-g_l_acct. "Sachkonto der Hauptbuchhaltung

      APPEND ls_bapidfkkopk_temp TO lt_bapidfkkopk.

    ENDIF.
*>>>>>>>>>> ABSTIMMSCHLÜSSEL
    IF ls_bapidfkkko-fikey IS INITIAL.
*      s_rfk00-blart = 'AB'.
      PERFORM get_fikey USING     ls_bapidfkkko-doc_type
                        CHANGING  ls_bapidfkkko-fikey.
    ENDIF.
*<<<<<<<<<< ABSTIMMSCHLÜSSEL


    IF  i_fkkcollp-zz_mwst > 0.
      CALL FUNCTION 'BAPI_CTRACDOCUMENT_CREATE'
        EXPORTING
          testrun            = lv_testrun
          documentheader     = ls_bapidfkkko
*         RECKEYINFO         =
*         COMPLETEDOCUMENT   =
*         NET_RECEIVABLES    =
        IMPORTING
          documentnumber     = lv_doc_no
          return             = ls_bapiret2
        TABLES
          partnerpositions   = lt_bapidfkkop
          genledgerpositions = lt_bapidfkkopk
*         REPETITIONPOSITIONS           =
*         POSITIONLOCKS      =
*         DATESFORDEFERREDREVENUE       =
*         EXTENSIONIN        =
*         ITEMRELATIONS      =
*         CARDDATA           =
*         GENLEDGERPOSITIONSEXT         =
*         WITHHOLDINGTAX     =
*         PORPAYMENT         =
*         DOWNPAYMTAXPOSITIONS          =
        .
      IF NOT ls_bapiret2 IS INITIAL. "->> FEHLER
        MESSAGE ID ls_bapiret2-id TYPE ls_bapiret2-type
                NUMBER ls_bapiret2-number
           WITH ls_bapiret2-message_v1 ls_bapiret2-message_v2
                ls_bapiret2-message_v3 ls_bapiret2-message_v4.
*    f_error = 'X'.
      ELSE. "->> Wenn kein Fehler -> CommitWork
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'
*      importing
*           return = lw_bapireturn.
*    message i003 with 'Gutschrift' lv_opbel 'wurde erfolgreich gebucht!'.
          .

        IF lv_testrun NE 'X'.
          CONCATENATE i_fkkcollp-vkont i_fkkcollp-gpart INTO string_objkey.
*      CONCATENATE 'Belegnummer:' ' ' h_opbel INTO string_belnr.

          gwa_obj-objrole = 'X00040002001'.
          gwa_obj-objtype = 'ISUACCOUNT'.
          gwa_obj-objkey = string_objkey.
          APPEND gwa_obj TO it_obj.

*------
          swc_container bcont_cont.


          swc_create_object bcontact   'BCONTACT'   ''.
          swc_create_object isupartner 'ISUPARTNER' i_fkkcollp-gpart. "Hier die Kundennummer eintragen

          swc_create_container bcont_cont.


          swc_set_element bcont_cont 'BusinessPartner' isupartner.
          swc_set_element bcont_cont 'contactclass'  '0100'.   "Im Customizing definieren
          swc_set_element bcont_cont 'contactactivity'  '0015'."Im Customizing definieren
          swc_set_element bcont_cont 'contacttype' '002'.
          swc_set_element bcont_cont 'NoDialog'  'X'.
*      swc_set_element bcont_cont 'Note' string_belnr.
          swc_set_element bcont_cont 'contactdirection' '2'.

          swc_set_table bcont_cont 'contactobjectswithrole' it_obj.

          swc_call_method bcontact 'Create' bcont_cont.
        ENDIF.

      ENDIF.

    ENDIF.


    lv_txtvw = i_fkkcollp-txtvw.
    CONCATENATE 'VOLLZAHLUNG: ' lv_txtvw INTO c_bfkkzp-txtvw.


  ENDIF.

  IF i_fkkcollp-zz_flag1 = '03'.  " Vergleich

    lv_txtvw = i_fkkcollp-txtvw.
    CONCATENATE 'VERGLEICH: ' lv_txtvw INTO c_bfkkzp-txtvw.

  ENDIF.


ENDFUNCTION.
