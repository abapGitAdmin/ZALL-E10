FUNCTION /ADESSO/ISU_EVENT_5065_SWK .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_DFKKCOLL STRUCTURE  DFKKCOLL
*"      T_ALL_COLL STRUCTURE  DFKKCOLL
*"      T_RECALL_COLL STRUCTURE  DFKKCOLL
*"      T_REASSIGN_COLL STRUCTURE  DFKKCOLL
*"  CHANGING
*"     VALUE(DO_RECALL) LIKE  BOOLE-BOOLE
*"  EXCEPTIONS
*"      ERROR_FOUND
*"--------------------------------------------------------------------
* T_DFKKCOLL :      Items to be submitted
* T_ALL_COLL :      All previously submitted items
* T_RECALL_COLL :   Items to be recalled from the Collection agency
* T_REASSIGN_COLL:  Items to be reassign to another Collection Agency
* DO_RECALL (flag): Must be set if items have to be recalled
************************************************************************

*-------------------------- EXAMPLE -----------------------------------*
* If the receivables are at the agency for more than 60 days           *
*----------------------------------------------------------------------*
  DATA: rec_index LIKE sy-index.

    INCLUDE: <cntn01>.
* Folgeaktivität nach Abgabe an Inkasso: CIC-Kontakt anlegen

  DATA: h_gpart LIKE T_DFKKCOLL-GPART,
        h2_gpart LIKE T_DFKKCOLL-GPART,
        h_opbel LIKE T_DFKKCOLL-OPBEL,
        h_vkont LIKE T_DFKKCOLL-VKONT,
        string_objkey TYPE c length 100,
        string_belnr TYPE c length 100.

  DATA: isupartner    TYPE swc_object,
        bcontact      TYPE swc_object.

  TYPES: BEGIN OF ty_obj_zeile,
    objrole(12) TYPE c,
    objtype(10) TYPE c,
    objkey(70) TYPE c,
    END OF ty_obj_zeile.

  DATA: gwa_obj TYPE ty_obj_zeile,
        it_obj TYPE TABLE OF ty_obj_zeile.

*  DATA: limit_date LIKE sy-datum.
*  limit_date = sy-datum - 60.
*
** Reassign selected items to a new collection agency (this is only
** called in case of manual recall)
*  LOOP AT t_recall_coll WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_recall_coll TO t_reassign_coll.
*    MOVE 'COL-AG1' TO t_reassign_coll-inkgp.         "Collection Agency
*    APPEND t_reassign_coll.
*  ENDLOOP.
*
** Recall items from a collection agency
*  LOOP AT t_all_coll. "WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_all_coll TO t_recall_coll.
*    APPEND t_recall_coll.
*  ENDLOOP.
*
** Reassign items to a new collection agency
*  LOOP AT t_all_coll WHERE agdat LT limit_date.
*    MOVE-CORRESPONDING t_all_coll TO t_reassign_coll.
*    MOVE 'COL-AG1' TO t_reassign_coll-inkgp.         "Collection Agency
*    APPEND t_reassign_coll.
*  ENDLOOP.
**
  DESCRIBE TABLE t_recall_coll   LINES rec_index.
  IF NOT rec_index IS INITIAL.
    do_recall = 'X'.
  ENDIF.
**---------------------------------------------------------------------*

  FIELD-SYMBOLS: <fs_dfkkcol> TYPE DFKKCOLL.

  SORT T_RECALL_COLL BY VKONT.

  LOOP AT  T_RECALL_COLL ASSIGNING <fs_dfkkcol>.

    h2_gpart = <fs_dfkkcol>-gpart.

    IF h_vkont NE <fs_dfkkcol>-vkont.

      clear string_objkey.
      clear string_belnr.

      h_vkont = <fs_dfkkcol>-vkont.
      h_gpart = <fs_dfkkcol>-gpart.
      h_opbel = <fs_dfkkcol>-opbel.

      CONCATENATE h_vkont h_gpart INTO string_objkey.
*      CONCATENATE 'Belegnummer:' ' ' h_opbel INTO string_belnr.

      gwa_obj-objrole = 'X00040002001'.
      gwa_obj-objtype = 'ISUACCOUNT'.
      gwa_obj-objkey = string_objkey.
      APPEND gwa_obj to it_obj.

*------
      swc_container bcont_cont.


      swc_create_object bcontact   'BCONTACT'   ''.
      swc_create_object isupartner 'ISUPARTNER' h_gpart. "Hier die Kundennummer eintragen

      swc_create_container bcont_cont.


      swc_set_element bcont_cont 'BusinessPartner' isupartner.
      swc_set_element bcont_cont 'contactclass'  '0200'.   "Im Customizing definieren
      swc_set_element bcont_cont 'contactactivity'  '0010'."Im Customizing definieren
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



ENDFUNCTION.
