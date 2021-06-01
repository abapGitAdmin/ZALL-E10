FUNCTION /ADESSO/FKK_SAMPLE_5057_SWK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_DFKKCOL STRUCTURE  DFKKCOLL
*"      T_FKKOP STRUCTURE  FKKOP
*"--------------------------------------------------------------------
  INCLUDE: <cntn01>.
* Folgeaktivität nach Abgabe an Inkasso: CIC-Kontakt anlegen




  DATA: h_gpart LIKE t_dfkkcol-gpart,
        h2_gpart LIKE t_dfkkcol-gpart,
        h_vkont LIKE t_fkkop-vkont,
        h_opbel LIKE t_dfkkcol-opbel,
        hwo_vkont LIKE t_dfkkcol-vkont,
        string_objkey TYPE c LENGTH 100,
        string_belnr TYPE c LENGTH 100.
*        f_fikey LIKE fkkko-fikey.

  DATA: isupartner    TYPE swc_object,
        bcontact      TYPE swc_object.

  DATA: lw_fkkcl TYPE fkkcl,
        lt_fkkcl TYPE TABLE OF fkkcl,
        lw_fkkko   TYPE fkkko,
        lw_tfk001b TYPE tfk001b,
        lw_rfka1 TYPE rfka1,
        lt_fkkcl_split TYPE TABLE OF fkkop_split_by_key,
        lw_ibuktab TYPE ibuktab,
        lt_ibuktab TYPE TABLE OF ibuktab,
        lw_fkkop TYPE fkkop,
        lv_opbel TYPE fkkko-opbel,
        l_summe TYPE betrw_kk.


  TYPES: BEGIN OF ty_obj_zeile,
    objrole(12) TYPE c,
    objtype(10) TYPE c,
    objkey(70) TYPE c,
    END OF ty_obj_zeile.

  DATA: gwa_obj TYPE ty_obj_zeile,
        it_obj TYPE TABLE OF ty_obj_zeile.




  FIELD-SYMBOLS: <fs_dfkkcol> TYPE dfkkcoll.


  SORT t_dfkkcol BY vkont.

  LOOP AT  t_dfkkcol ASSIGNING <fs_dfkkcol>.

    h2_gpart = <fs_dfkkcol>-gpart.

    IF h_vkont NE <fs_dfkkcol>-vkont.

      CLEAR string_objkey.
      CLEAR string_belnr.
      CLEAR it_obj.

      h_vkont = <fs_dfkkcol>-vkont.
      h_gpart = <fs_dfkkcol>-gpart.
      h_opbel = <fs_dfkkcol>-opbel.

      CONCATENATE h_vkont h_gpart INTO string_objkey.
*      CONCATENATE 'Belegnummer:' ' ' h_opbel INTO string_belnr.

      gwa_obj-objrole = 'X00040002001'.
      gwa_obj-objtype = 'ISUACCOUNT'.
      gwa_obj-objkey = string_objkey.
      APPEND gwa_obj TO it_obj.

*------
      swc_container bcont_cont.


      swc_create_object bcontact   'BCONTACT'   ''.
      swc_create_object isupartner 'ISUPARTNER' h_gpart. "Hier die Kundennummer eintragen

      swc_create_container bcont_cont.


      swc_set_element bcont_cont 'BusinessPartner' isupartner.
      swc_set_element bcont_cont 'contactclass'  '0200'.   "Im Customizing definieren
      swc_set_element bcont_cont 'contactactivity'  '0005'."Im Customizing definieren
      swc_set_element bcont_cont 'contacttype' '002'.
      swc_set_element bcont_cont 'NoDialog'  'X'.
*      swc_set_element bcont_cont 'Note' string_belnr.
      swc_set_element bcont_cont 'contactdirection' '2'.

      swc_set_table bcont_cont 'contactobjectswithrole' it_obj.

      swc_call_method bcontact 'Create' bcont_cont.

*IF sy-subrc <> 0.
*  ...
*ENDIF.
*--------


    ENDIF.

  ENDLOOP.

** AUSBUCHEN: Abgegebene Posten unter 300 #.
*
**
**
**
*  lw_fkkko-mandt = sy-mandt.
**  lw_fkkko-fikey = 'TEST_NUSS01'. " ABSTIMMSCHLÜSSEL MUSS NOCH GENERIERT WERDEN (FUBA)
*  lw_fkkko-applk = 'R'.
*  lw_fkkko-blart = 'AU'.
*  lw_fkkko-herkf = '16'.
*  lw_fkkko-ernam = sy-uname.
*  lw_fkkko-cpudt = sy-datum.
*  lw_fkkko-cputm = sy-uzeit.
*  lw_fkkko-waers = 'EUR'.
*  lw_fkkko-bldat = sy-datum.
*  lw_fkkko-budat = sy-datum.
*  lw_fkkko-wwert = sy-datum.
**  lw_fkkko-abgrd = '01'.
*
*  IF lw_fkkko-fikey IS INITIAL.
**      s_rfk00-blart = 'AB'.
*    PERFORM get_fikey USING     lw_fkkko-blart
*                      CHANGING  lw_fkkko-fikey.
*  ENDIF.
*
*
** SELECT * FROM TFK001B INTO CORRESPONDING FIELDS OF TABLE lt_ibuktab.
*
**  lw_ibuktab-bukrs = '0010'.
**  APPEND lw_ibuktab TO lt_ibuktab.
*
**  APPEND lw_TFK001B TO lt_ibuktab.
*
*  SORT t_fkkop BY vkont.
*
*  DATA lw_fkkop_help TYPE fkkop.
*
*  LOOP AT t_fkkop INTO lw_fkkop.
*
*    lw_ibuktab-bukrs = lw_fkkop-bukrs.
*    APPEND lw_ibuktab TO lt_ibuktab.
*
*    DELETE ADJACENT DUPLICATES FROM lt_ibuktab.
*
*    IF lw_fkkop-vkont NE hwo_vkont.
*
*      LOOP AT t_fkkop INTO lw_fkkop_help
*        WHERE vkont = lw_fkkop-vkont.
*
*        lw_ibuktab-bukrs = lw_fkkop_help-bukrs.
*        APPEND lw_ibuktab TO lt_ibuktab.
*        SORT lt_ibuktab BY bukrs.
*        DELETE ADJACENT DUPLICATES FROM lt_ibuktab.
*
*
*        MOVE-CORRESPONDING lw_fkkop_help TO lw_fkkcl.
*        lw_fkkcl-augbw = lw_fkkop_help-betrw.
*        lw_fkkcl-augbh = lw_fkkop_help-betrw.
*        lw_fkkcl-augrd = '04'.
*        lw_fkkcl-xaktp = 'X'.
*        IF lw_fkkcl-stakz IS NOT INITIAL.
*          lw_fkkcl-xclon = 'X'.
*        ENDIF.
**        CLEAR lw_fkkcl-stakz.
*
*
*
*        APPEND lw_fkkcl TO lt_fkkcl.
*
*        DELETE lt_fkkcl WHERE augst = 9.    " Bereits ausgebuchte löschen!!!
*
*        l_summe = l_summe + lw_fkkop_help-betrw.
*
*      ENDLOOP.
*
*      IF lt_fkkcl IS NOT INITIAL.
*
*        IF l_summe < 20.
*
*          lw_fkkko-abgrd = '01'.  " Ausbuchungsgrund für < 20 #
*
**       Geschäftspartner sperren
*          READ TABLE ht_enqtab WITH KEY gpart = lw_fkkop_help-gpart.
*          IF sy-subrc NE 0.
*            ht_enqtab-gpart = lw_fkkop_help-gpart.
*            APPEND ht_enqtab.
*          ENDIF.
*
*          PERFORM dfkkop_enqueue.
*
*          CALL FUNCTION 'FKK_WRITEOFF'
*            EXPORTING
*              i_fkkko       = lw_fkkko
*              i_rfka1       = lw_rfka1
**             I_TRANSACTION = 'FP04'
*            IMPORTING
*              e_opbel       = lv_opbel
*            TABLES
*              t_fkkcl       = lt_fkkcl
*              t_fkkcl_split = lt_fkkcl_split
*              t_buktab      = lt_ibuktab.
*
**  * --- Dequeue all business partner ------------------------------------
*          CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
*
*        ELSEIF l_summe < 300.
*
*          lw_fkkko-abgrd = '03'.  " Ausbuchungsgrund für 20 - 300 #
*
**       Geschäftspartner sperren
*          READ TABLE ht_enqtab WITH KEY gpart = lw_fkkop_help-gpart.
*          IF sy-subrc NE 0.
*            ht_enqtab-gpart = lw_fkkop_help-gpart.
*            APPEND ht_enqtab.
*          ENDIF.
*
*          PERFORM dfkkop_enqueue.
*
*          CALL FUNCTION 'FKK_WRITEOFF'
*            EXPORTING
*              i_fkkko       = lw_fkkko
*              i_rfka1       = lw_rfka1
**             I_TRANSACTION = 'FP04'
*            IMPORTING
*              e_opbel       = lv_opbel
*            TABLES
*              t_fkkcl       = lt_fkkcl
*              t_fkkcl_split = lt_fkkcl_split
*              t_buktab      = lt_ibuktab.
*
**  * --- Dequeue all business partner ------------------------------------
*          CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.
*        ENDIF.
*
*        CLEAR lt_fkkcl.
*        CLEAR l_summe.
*
*
*
**      ENDLOOP.
*
*      ENDIF.
*    ENDIF.
*
*    hwo_vkont = lw_fkkop-vkont.
*
*  ENDLOOP.
*
ENDFUNCTION.
**
**&---------------------------------------------------------------------*
**&      Form  get_fikey
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**      -->S_RFK00-BLART  text
**      <--S_RFK00-FIKEY  text
**----------------------------------------------------------------------*
*FORM get_fikey USING    s_rfk00-blart
*               CHANGING s_rfk00-fikey.
*
*  DATA: f_fikey   TYPE fkkko-fikey,
*      f_fikey_d TYPE fkkko-fikey,
*      f_num(3)  TYPE n,
*      f_xclos   TYPE dfkksumc-xclos.
*
*  CLEAR  s_rfk00-fikey.
*
*  DO 999 TIMES.                         "bis zu 100 mögliche Abstimmschlüssel
*    f_fikey(2)   = s_rfk00-blart.
*    f_fikey+2(2) = sy-datum+2(2).
*    f_fikey+4(4) = sy-datum+4(4).
*    f_fikey+8(1) = '-'.
*    f_fikey+9(3) = f_num.
*
*    SELECT SINGLE fikey xclos
*      INTO (f_fikey_d, f_xclos)
*      FROM dfkksumc
*      WHERE fikey  = f_fikey.
*
*    IF sy-subrc <> 0.                   "Anlegen Abstimmschlüssel oder beenden der Schleife
*
** FIKEY für die folgenden Buchungen reservieren
*      CALL FUNCTION 'FKK_FIKEY_OPEN'
*        EXPORTING
*          i_fikey = f_fikey.
*      EXIT.
*    ENDIF.
*    IF f_xclos = 'X'.
*      ADD 1 TO f_num.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*
** FIKEY prüfen, ob er verwendet werden darf
*  CALL FUNCTION 'FKK_FIKEY_CHECK'
*    EXPORTING
*      i_fikey                = f_fikey
*      i_open_without_dialog  = 'X'
*      i_non_existing_allowed = 'X'.
*
*  s_rfk00-fikey = f_fikey.
* ENDFORM.                    " GET_FIKEY
* GET_FIKEY
