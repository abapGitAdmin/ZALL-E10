FUNCTION /adesso/fkk_sample_1799_ink.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FKKCOCC) LIKE  FKKCOCC STRUCTURE  FKKCOCC
*"     VALUE(I_FKK_PROT) LIKE  FKKPROT STRUCTURE  FKKPROT
*"     VALUE(I_BASICS) TYPE  FKK_MAD_BASICS OPTIONAL
*"  TABLES
*"      T_FIMSG STRUCTURE  FIMSG
*"      T_FKKCOINFO STRUCTURE  FKKCOINFO
*"      T_PROT_GPART STRUCTURE  FKKR_GPART OPTIONAL
*"      T_PROT_VKONT STRUCTURE  FKKR_VKONT OPTIONAL
*"----------------------------------------------------------------------

***************************************************************
***
*** Starting with Version 4.5.1 the only relevant
*** parameter is i_basics. The other parameters
*** are just left for compatability reasons.
*** If called via SAPLFKKAKTIV2 those parameters come empty !
***
***
****************************************************************

* declarations
  DATA: h_aktyp TYPE aktyp_kk.
  DATA: ls_fkkcollp_ip LIKE fkkcollp_ip.
  DATA: ls_fkkcollp_ir LIKE fkkcollp_ir.

  DATA: t_fkkcollh_i_w  LIKE dfkkcollh_i_w  OCCURS 0 WITH HEADER LINE.

  FIELD-SYMBOLS: <dfkkcollp_ir> TYPE dfkkcollp_ir_w.

****************************************************************

* Set h_aktyp appropriate related to version.
  IF NOT ( i_basics-runkey-aktyp IS INITIAL ).
    h_aktyp = i_basics-runkey-aktyp.
  ELSE.
    h_aktyp = i_fkkcocc-aktyp.
  ENDIF.

***************************************************
***
*** Should already been processed
***
*** First:  central FI-CA work
*** Second: application specific work
***
***************************************************

***************************************************
***
*** Third: Now do additional application specific work
***
***************************************************
* Only special handling for aktyp 0097.
* Only special handling for macat sell (create separate sell file).

  CHECK h_aktyp = '0097'.
  CHECK i_basics-macat IS NOT INITIAL.

* ----------------------------------------------------------------------
* file based version (enterprise services not active)
* ----------------------------------------------------------------------
  CHECK gv_flg_coll_esoa_active IS INITIAL.

* Decimal notation
  PERFORM get_decimal_notation(saplfkci).

* Konstruieren des Runkeys
  CALL FUNCTION 'FKK_AKTIV2_RUN_KEY_CONSTRUCT'
    EXPORTING
      i_aktyp  = i_basics-runkey-aktyp
      i_laufd  = i_basics-runkey-laufd
      i_laufi  = i_basics-runkey-laufi
    IMPORTING
      e_runkey = h_runkey.

* Lesen Zusatzparameter
  IMPORT addons TO g_fkkcollinfo                            "#EC ENHOK
                FROM DATABASE rfdt(kk) ID h_runkey.

  IF NOT sy-subrc IS INITIAL.
* Nachricht: Zusatzparameter zu Lauf ... konnten nicht gelesen werden
    mac_appl_log_msg 'E' '>6' '376'
     i_basics-runkey-aktyp i_basics-runkey-laufd
     i_basics-runkey-laufi space
*    c_msgprio_info i_basics-appllog-probclass.
     c_msgprio_info '1'.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e376(>6). ENDIF.
    SET EXTENDED CHECK ON.
    EXIT.
  ENDIF.

* Lesen Events
    PERFORM read_events(saplfkci)
            TABLES t_tfkfbc_5051
                   t_tfkfbc_5052
                   t_tfkfbc_5053.

  REFRESH: gt_fkkcollp_ir.

  SELECT * INTO  TABLE gt_fkkcollp_ir
           FROM  dfkkcollp_ir_w
           WHERE laufd   = i_basics-runkey-laufd
           AND   laufi   = i_basics-runkey-laufi
           AND   satztyp = c_position
           AND   postyp  IN (c_pt_sell, c_pt_decl).

  SORT gt_fkkcollp_ir BY w_inkgp.

  LOOP AT gt_fkkcollp_ir ASSIGNING <dfkkcollp_ir>.

    AT NEW w_inkgp.
      CLEAR rc.
*     first update header table
      CLEAR t_fkkcollh_i_w.
      MOVE-CORRESPONDING <dfkkcollp_ir> TO t_fkkcollh_i_w.
      t_fkkcollh_i_w-satztyp = c_header.
      t_fkkcollh_i_w-inkgp   = <dfkkcollp_ir>-w_inkgp.
      t_fkkcollh_i_w-datum   = sy-datum.

      PERFORM update_dfkkcollh_i_w USING t_fkkcollh_i_w.

* Erzeugen Datei-Kopfsatz
      PERFORM create_file_header_ink
         USING g_fkkcollinfo
               t_fkkcollh_i_w
               i_basics
         CHANGING h_file_name
                  t_fkkcollh_i
                  t_fkkcollt_i
                  rc.
    ENDAT.

    CHECK rc = 0.

    AT END OF w_inkgp.
      CHECK rc = 0.
* Erzeugen Positionen für Verkauf / Ablehnung Verkauf
      PERFORM create_info_sell_decl
              USING g_fkkcollinfo
                    h_file_name
                    t_fkkcollh_i_w
                    t_fkkcollh_i
                    i_basics
             CHANGING t_fkkcollt_i.

* Erzeugen Datei-Endesatz
      PERFORM create_trailer_ink
              USING g_fkkcollinfo
                    h_file_name
                    t_fkkcollh_i
                    t_fkkcollt_i
                    i_basics.

* Abschliessen Informationsdatei
      PERFORM close_dataset(saplfkci)
              USING h_file_name
                    t_fkkcollt_i
                    i_basics.

    ENDAT.
  ENDLOOP.

  IF NOT sy-subrc IS INITIAL.
* Nachricht: 'Es liegen keine Informationen vor'.
    mac_appl_log_msg 'I' '>4' '806'
      space space space space
*     c_msgprio_info i_basics-appllog-probclass.
      c_msgprio_high '1'.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE i806(>4). ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

ENDFUNCTION.
