*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  /ADZ/HMV_DUNNING
*&
*&---------------------------------------------------------------------*
REPORT  /adz/hmv_dunning_old.
INCLUDE /adz/hmv_dunningtop.
INCLUDE /adz/hmv_constants.
*-----------------------------------------------------------------------
* initialization
*-----------------------------------------------------------------------
TOP-OF-PAGE.

* Leon Kasdorf 2020

INITIALIZATION.

  PERFORM assign_constants.
  PERFORM fill_selection_param.
*-----------------------------------------------------------------------
* Selections
*-----------------------------------------------------------------------
* Verarbeitungsmodus
  SELECTION-SCREEN BEGIN OF BLOCK mod WITH FRAME TITLE TEXT-b05.
  PARAMETERS: pa_showh RADIOBUTTON GROUP out.
  PARAMETERS: pa_updhi RADIOBUTTON GROUP out.
  PARAMETERS: pa_liste RADIOBUTTON GROUP out DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK mod.
* Vertragskonto
  SELECTION-SCREEN BEGIN OF BLOCK vkont WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: so_vkont FOR fkkvkp-vkont.  "Aggregiertes VK
  SELECT-OPTIONS: so_bcbln FOR dfkkthi-bcbln. "Belegnummer der Buchung
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS: so_ekont FOR dfkkop-vkont.  "Vertragskontonummer
  SELECT-OPTIONS: so_bukrs FOR dfkkop-bukrs.
  SELECT-OPTIONS: so_augst FOR dfkkop-augst DEFAULT ' ' OPTION EQ SIGN I.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS: so_mansp FOR fkkvkp-mansp.
  SELECT-OPTIONS: so_mahns FOR fkkmako-mahns.
  SELECTION-SCREEN SKIP.
  PARAMETERS: p_akonto AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_dunn   AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK vkont.
* Mahnen
  SELECTION-SCREEN BEGIN OF BLOCK mahn WITH FRAME TITLE TEXT-b02.
  SELECT-OPTIONS: so_mahnv FOR fkkvkp-mahnv.
  SELECT-OPTIONS: so_faedn FOR dfkkop-faedn NO-EXTENSION OBLIGATORY.
  SELECTION-SCREEN SKIP.
  PARAMETERS:     pa_lockr LIKE fkkvkp-mansp OBLIGATORY DEFAULT c_lockr.
  PARAMETERS:     pa_fdate LIKE sy-datum.
  PARAMETERS:     pa_tdate LIKE sy-datum.
  SELECTION-SCREEN END OF BLOCK mahn.
* Ausgabe
  SELECTION-SCREEN BEGIN OF BLOCK var WITH FRAME TITLE TEXT-b04.
  PARAMETERS: pa_updte AS CHECKBOX.
  SELECTION-SCREEN SKIP.
  PARAMETERS: p_vari LIKE disvariant-variant.
  SELECTION-SCREEN END OF BLOCK var.

  PERFORM init_alv.

  pa_fdate = sy-datum.
  pa_tdate = sy-datum + 2.

  CLEAR: so_vkont, so_mahnv.

*-----------------------------------------------------------------------
* At selection-screen
*-----------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN.

  PERFORM pai_of_selection_screen.

  SELECT * FROM te002a
           INTO t_te002a
           WHERE fktsa = 'X'.

    LOOP AT t_te002a.
      r_vktyp-option = 'EQ'.
      r_vktyp-sign   = 'I'.
      r_vktyp-low    = t_te002a-vktyp.
      APPEND r_vktyp.
    ENDLOOP.

    SELECT COUNT(*) FROM fkkvk
        WHERE vkont IN so_vkont
          AND vktyp IN r_vktyp.
  ENDSELECT.

  IF pa_fdate < sy-datum.
    MESSAGE TEXT-e03 TYPE 'E'.
  ENDIF.

* --> Nuss 12.02.2018
* Bis-Datum darf nicht größer Ab-Datum sein
  IF pa_tdate < pa_fdate.
    MESSAGE TEXT-e05 TYPE 'E'.
  ENDIF.
* <-- Nuss 12.02.2018

  IF sy-ucomm NE 'ONLI' AND
    pa_updte = 'X'.
    MESSAGE TEXT-w01 TYPE 'W'.
  ENDIF.

  x_tage = ( pa_tdate - pa_fdate ).
  IF x_tage GT 14.
    SET CURSOR FIELD 'PA_TDATE'.
    MESSAGE TEXT-e02 TYPE 'E'.
  ENDIF.

*-----------------------------------------------------------------------
* START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  GET TIME.
  x_uzeit = sy-uzeit.

  IF sy-batch = 'X'.
    x_maxts = c_maxtb.
  ELSE.
    x_maxts = c_maxtd.
  ENDIF.

  IF pa_showh = 'X'.
    PERFORM show_history.
    STOP.
  ENDIF.

  sel_augst[] = so_augst[].
  so_mansp[]  = so_mansp[].
  so_mahns[]  = so_mahns[].

  SELECT k~vkont k~vktyp k~vkbez
         p~gpart p~stdbk p~mahnv
         INTO CORRESPONDING FIELDS OF TABLE t_fkkvkp
         FROM fkkvk AS k INNER JOIN fkkvkp AS p
           ON k~vkont = p~vkont
        WHERE k~vkont IN so_vkont
          AND p~stdbk IN so_bukrs
          AND p~mahnv IN so_mahnv.

  IF so_faedn-high IS INITIAL.
    x_thidt_from = so_faedn-low.
    x_thidt_to   = so_faedn-low.
  ELSE.
    x_thidt_to   = so_faedn-high.
    x_thidt_from = so_faedn-low.
  ENDIF.

  PERFORM basis_select
    USING
      t_fkkvkp[]
      x_thidt_to
      x_thidt_from
      so_bcbln[]
    CHANGING
      gt_dfkkop_buffer.


  LOOP AT t_fkkvkp.
    PERFORM get_locks_vk.
    PERFORM serv_prov.
    MODIFY t_fkkvkp.

* WA_OUT füllen
    CLEAR wa_out.
    wa_out-buchvert          = t_fkkvkp-buchvert.
    wa_out-aggvk             = t_fkkvkp-vkont.
    wa_out-vkbez             = t_fkkvkp-vkbez.
    wa_out-recid             = t_fkkvkp-recid.
    wa_out-senid             = t_fkkvkp-senid.
    wa_out-vktyp             = t_fkkvkp-vktyp.
    wa_out-mahnv             = t_fkkvkp-mahnv.
    wa_out-agmsp             = t_fkkvkp-mansp.
    wa_out-v_group           = t_fkkvkp-v_group.
    wa_out-dexidocsent     = t_fkkvkp-dexidocsent.
    wa_out-dexidocsentctrl = t_fkkvkp-dexidocsentctrl.
    wa_out-dexidocsendcat  = t_fkkvkp-dexidocsendcat.
    wa_out-dexproc         = t_fkkvkp-dexproc.

    PERFORM pre_select.
    WAIT UNTIL t_tasks IS INITIAL.
    PERFORM create_tasks.

* HMV_Select für DFKKTHI
    LOOP AT t_tasks ASSIGNING <t_tasks>.
      CASE <t_tasks>-name(1).
        WHEN c_doc_kzd.
          wa_tout-kennz = c_doc_kzd.
          REFRESH t_selct.
          APPEND LINES OF t_tbcbl FROM <t_tasks>-low
                                    TO <t_tasks>-high
                                    TO  t_selct.
          CHECK t_selct[] IS NOT INITIAL.
          ADD 1 TO x_runts.
          CALL FUNCTION '/ADZ/HMV_SELECT'
            STARTING NEW TASK <t_tasks>-name
            DESTINATION IN GROUP DEFAULT
            PERFORMING ende_task ON END OF TASK
            EXPORTING
              is_out                = wa_tout
              if_akonto             = p_akonto
              if_updte              = pa_updte
              if_adunn              = p_dunn
              if_lockr              = pa_lockr
              if_fdate              = pa_fdate
              if_tdate              = pa_tdate
            TABLES
              it_selct              = t_selct
              et_out                = ft_out
              it_so_augst           = sel_augst
              it_so_mansp           = so_mansp
              it_so_mahns           = so_mahns
            EXCEPTIONS
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.
          IF sy-subrc NE 0.
            MESSAGE TEXT-e04 TYPE 'I'.
            STOP.
          ENDIF.
          WAIT UNTIL x_runts < x_maxts.

* HMV_Select für MEMIDOC
        WHEN /idxmm/if_constants=>gc_createdfrom_m.
          wa_tout-kennz = /idxmm/if_constants=>gc_createdfrom_m.
          APPEND wa_out TO ft_out.
          REFRESH t_selct_memi.
          APPEND LINES OF  t_memidoc2
                     FROM <t_tasks>-low
                       TO <t_tasks>-high
                       TO  t_selct_memi.
          CHECK t_selct_memi[] IS NOT INITIAL.
          ADD 1 TO x_runts.
          CALL FUNCTION '/ADZ/HMV_SELECT_MEMIDOC'
            STARTING NEW TASK <t_tasks>-name
            DESTINATION IN GROUP DEFAULT
            PERFORMING ende_task_memi ON END OF TASK
            EXPORTING
              is_out                = wa_tout
              if_akonto             = p_akonto
              if_updte              = pa_updte
              if_adunn              = p_dunn
              if_lockr              = pa_lockr
              if_fdate              = pa_fdate
              if_tdate              = pa_tdate
            TABLES
              it_selct_memi         = t_selct_memi[]
              et_out                = ft_out
              it_so_augst           = sel_augst
              it_so_mansp           = so_mansp
              it_so_mahns           = so_mahns
            EXCEPTIONS
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.
          IF sy-subrc NE 0.
            MESSAGE TEXT-e04 TYPE 'I'.
            STOP.
          ENDIF.
          WAIT UNTIL x_runts < x_maxts.

* -->  Nuss 09.2018
        WHEN c_doc_kzmsb.
          wa_tout-kennz = c_doc_kzmsb.
          REFRESH t_selct_msb.
          APPEND LINES OF t_msbdoc2 FROM <t_tasks>-low
                                    TO <t_tasks>-high
                                    TO  t_selct_msb.
          CHECK t_selct_msb[] IS NOT INITIAL.
          ADD 1 TO x_runts.

          CALL FUNCTION '/ADZ/HMV_SELECT_MSBDOC'
            STARTING NEW TASK <t_tasks>-name
            DESTINATION IN GROUP DEFAULT
            PERFORMING ende_task_msb ON END OF TASK
            EXPORTING
              is_out                = wa_tout
              if_akonto             = p_akonto
              if_updte              = pa_updte
              if_adunn              = p_dunn
              if_lockr              = pa_lockr
              if_fdate              = pa_fdate
              if_tdate              = pa_tdate
            TABLES
              it_selct_msb          = t_selct_msb[]
              et_out                = ft_out
              it_so_augst           = sel_augst
              it_so_mansp           = so_mansp
              it_so_mahns           = so_mahns
            EXCEPTIONS
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.
          IF sy-subrc NE 0.
            MESSAGE TEXT-e04 TYPE 'I'.
            STOP.
          ENDIF.
          WAIT UNTIL x_runts < x_maxts.

* <-- Nuss 09.2018
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  WAIT UNTIL t_tasks IS INITIAL.

*-----------------------------------------------------------------------
* END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  PERFORM update_t_out TABLES t_out.

  SORT t_out.
  DELETE ADJACENT DUPLICATES FROM t_out COMPARING ALL FIELDS.
  PERFORM output_alv.
*&---------------------------------------------------------------------*
*&      Form  SERV_PROV
*&---------------------------------------------------------------------*
FORM serv_prov .

* --- determine receiving service provider
  CALL FUNCTION 'ISU_DEREG_GET_AGREEMENT_VKONT'
    EXPORTING
      x_keydate           = sy-datum
      x_vkont             = t_fkkvkp-vkont
    IMPORTING
      y_initiator         = x_initiator
      y_partner           = x_partner
      y_param_wa          = s_param_inv_outbound
    EXCEPTIONS
      agreement_not_found = 1
      bupart_not_found    = 2
      not_unique          = 3
      internal_error      = 4
      OTHERS              = 5.

  IF sy-subrc = 0.
    t_fkkvkp-recid = x_initiator.
    t_fkkvkp-senid = x_partner.
  ENDIF.
  READ TABLE s_param_inv_outbound-account_param ASSIGNING <outbound_acc>
    WITH KEY vkont_aggbill = t_fkkvkp-vkont.

  IF sy-subrc = 0.
    t_fkkvkp-v_group = <outbound_acc>-v_group.
  ENDIF.
  READ TABLE s_param_inv_outbound-avis_param ASSIGNING <outbound_avis>
    WITH KEY vkont_aggbill = t_fkkvkp-vkont.

  IF sy-subrc = 0.
    IF <outbound_avis>-saveacc = 'X'.
      t_fkkvkp-buchvert = icon_agent_orphan.
    ENDIF.
  ENDIF.
ENDFORM.                    " SERV_PROV
*&---------------------------------------------------------------------*
*&      Form  GET_LOCKS_VK
*&---------------------------------------------------------------------*
FORM get_locks_vk .

* Check dunning block in contract account
  CLEAR: t_fkkvkp-mansp, s_dfkkop.
  s_dfkkop-gpart = t_fkkvkp-gpart.
  s_dfkkop-vkont = t_fkkvkp-vkont.

  CALL FUNCTION 'FKK_S_LOCK_GET'
    EXPORTING
      i_keystructure           = s_dfkkop
      i_lotyp                  = c_lotyp_gp_vk
      i_proid                  = c_proid_dunn
      i_lockdate               = sy-datum
      i_x_mass_access          = space
      i_x_dependant_locktypes  = space
    IMPORTING
      e_x_lock_exist           = x_lock_exist
      e_x_dependant_lock_exist = x_lock_depex
    TABLES
      et_locks                 = t_dfkklock.
  READ TABLE t_dfkklock INDEX 1.
  IF sy-subrc = 0.
    t_fkkvkp-mansp  = t_dfkklock-lockr.
    t_fkkvkp-locked = icon_locked.
  ENDIF.
ENDFORM.                    " GET_LOCKS_VK
*&---------------------------------------------------------------------*
*&      Form  INIT_ALV
*&---------------------------------------------------------------------*
FORM init_alv .

  g_repid       = sy-repid.
  g_save        = 'A'.
  g_tabname_all = 'IT_OUT'.

* define sort
  PERFORM tabelle_sortieren USING g_sort[].

* define layout
  CLEAR gs_layout.
  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-no_vline          = ' '.

* Variante initialisieren
  PERFORM variant_init.

* Get default variant
  gx_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.
  PERFORM set_events.
ENDFORM.                    " INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_structure_name       = '/ADZ/HMV_S_OUT_DUNNING'
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      OTHERS                 = 0.

**  Felder anpassen
  LOOP AT lt_fieldcat INTO ls_fieldcat.

    CASE ls_fieldcat-fieldname.

      WHEN 'SEL'.
        ls_fieldcat-edit         = 'X'.
        ls_fieldcat-input        = 'X'.
        ls_fieldcat-checkbox     = 'X'.
        ls_fieldcat-key          = 'X'.
        ls_fieldcat-seltext_s    = 'Mahnsp'.
        ls_fieldcat-seltext_m    = 'Mahnsperre'.
        ls_fieldcat-seltext_l    = 'Mahnsperre'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'LOCKED'.
        ls_fieldcat-seltext_s    = 'Sp'.
        ls_fieldcat-seltext_m    = 'Sperre'.
        ls_fieldcat-seltext_l    = 'Sperre'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-key          = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'TO_LOCK'.
        ls_fieldcat-seltext_s    = 'VS'.
        ls_fieldcat-seltext_m    = 'V.Sperre'.
        ls_fieldcat-seltext_l    = 'Vorschlag Sperre'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-key          = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.


      WHEN 'KENNZ'.
        ls_fieldcat-key          = 'X'.
        ls_fieldcat-seltext_s    = 'Kz.'.
        ls_fieldcat-seltext_m    = 'Hrkft Kennz.'.
        ls_fieldcat-seltext_l    = 'Herkunft Kennzeichen'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'SENT'.
        ls_fieldcat-no_out = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'BUCHVERT'.
        ls_fieldcat-seltext_s    = 'VSt.'.
        ls_fieldcat-seltext_m    = 'Buchg VSt.'.
        ls_fieldcat-seltext_l    = 'Buchg VSt.'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-key          = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'AGGVK'.
        ls_fieldcat-seltext_s    = 'Aggr VK'.
        ls_fieldcat-seltext_m    = 'Aggr VK'.
        ls_fieldcat-seltext_l    = 'Aggr VK'.
        ls_fieldcat-hotspot      = 'X'.                      "Nuss 29.03.2012
        ls_fieldcat-key          = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'VKBEZ'.
        ls_fieldcat-key = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'RECID'.
        ls_fieldcat-key     = 'X'.
        ls_fieldcat-hotspot = 'X'.                           "Nuss 29.03.2012
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'SENID'.
        ls_fieldcat-key     = 'X'.
        ls_fieldcat-hotspot = 'X'.                           "Nuss 29.03.2012
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'VKTYP'.
        ls_fieldcat-key = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'MAHNV'.
        ls_fieldcat-key = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'AGMSP'.
        ls_fieldcat-no_out = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'STATUS'.
        ls_fieldcat-seltext_s    = 'Stat'.
        ls_fieldcat-seltext_m    = 'Status'.
        ls_fieldcat-seltext_l    = 'Status'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'AKONTO'.
        ls_fieldcat-seltext_s    = 'AKto'.
        ls_fieldcat-seltext_m    = 'AKonto'.
        ls_fieldcat-seltext_l    = 'AKonto'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM  ls_fieldcat.

      WHEN 'BCBLN'.
        ls_fieldcat-seltext_s    = 'AggrBel'.
        ls_fieldcat-seltext_m    = 'Aggre.Beleg'.
        ls_fieldcat-seltext_l    = 'Aggre.Beleg'.
        ls_fieldcat-hotspot      = 'X'.                        "Nuss 29.03.2012
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

*>>> UH 22012013
      WHEN 'BCAUG'.
        ls_fieldcat-seltext_s    = 'AggrAgl'.
        ls_fieldcat-seltext_m    = 'AggrAglSt'.
        ls_fieldcat-seltext_l    = 'AggrAglSt'.
        ls_fieldcat-no_out       = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.
*<<< UH 22012013

*<<< ET_20160303
      WHEN 'AUGST'.
        ls_fieldcat-no_out = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.
* >>> ET_20160303

      WHEN 'VKONT'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'VTREF'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'OPBEL'.
        ls_fieldcat-hotspot = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'GPART'.
        ls_fieldcat-no_out = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'OWNRF'.
        ls_fieldcat-seltext_s    = 'CrsrfNo'.
        ls_fieldcat-seltext_m    = 'CrossrefNo'.
        ls_fieldcat-seltext_l    = 'CrossreferenceNo'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

*>>> UH 30012013
      WHEN 'MDRKD'.
        ls_fieldcat-seltext_s    = 'Druck 1.'.
        ls_fieldcat-seltext_m    = 'Druck 1.Mahn'.
        ls_fieldcat-seltext_l    = 'Druck 1.Mahn'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.
*<<< UH 30012013

      WHEN 'BETRH'.
        ls_fieldcat-do_sum = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

*>>> UH 11102012
      WHEN 'PAYNO'.
        ls_fieldcat-seltext_s    = 'Zahl'.
        ls_fieldcat-seltext_m    = 'Zahl.Avis'.
        ls_fieldcat-seltext_l    = 'Zahlungsavis'.
        ls_fieldcat-hotspot      = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'PAYST'.
        ls_fieldcat-seltext_s    = 'Zahl.St.'.
        ls_fieldcat-seltext_m    = 'Zahl.Status'.
        ls_fieldcat-seltext_l    = 'Zahlung Status'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'PAYST_ICON'.
        ls_fieldcat-seltext_s    = 'Z.St.'.
        ls_fieldcat-seltext_m    = 'Z.Stat'.
        ls_fieldcat-seltext_l    = 'Z.Stat'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.
*<<< UH 11102012

      WHEN 'DOCNO'.
        ls_fieldcat-seltext_s    = 'neg.REMADV'.
        ls_fieldcat-seltext_m    = 'neg.REMADV'.
        ls_fieldcat-seltext_l    = 'neg.REMADV'.
        ls_fieldcat-hotspot      = 'X'.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'STATREM'.
        ls_fieldcat-seltext_s    = 'St.R'.
        ls_fieldcat-seltext_m    = 'St.Rem'.
        ls_fieldcat-seltext_l    = 'St.Rem'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'IDOCIN'.
        ls_fieldcat-seltext_s    = 'INVOIC'.
        ls_fieldcat-seltext_m    = 'INVOIC'.
        ls_fieldcat-seltext_l    = 'INVOIC'.
        ls_fieldcat-hotspot      = 'X'.                "Nuss 30.03.2012
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'STATIN'.
        ls_fieldcat-seltext_s    = 'St.I'.
        ls_fieldcat-seltext_m    = 'St.Inv'.
        ls_fieldcat-seltext_l    = 'St.Inv'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'IDOCCT'.
        ls_fieldcat-seltext_s    = 'CONTRL'.
        ls_fieldcat-seltext_m    = 'CONTRL'.
        ls_fieldcat-seltext_l    = 'CONTRL'.
        ls_fieldcat-hotspot      = 'X'.                 "Nuss 30.03.2012
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.

      WHEN 'STATCT'.
        ls_fieldcat-seltext_s    = 'St.C'.
        ls_fieldcat-seltext_m    = 'St.Ctrl'.
        ls_fieldcat-seltext_l    = 'St.Ctrl'.
        ls_fieldcat-icon         = 'X'.
        ls_fieldcat-outputlen    = 10.
        MODIFY lt_fieldcat INDEX sy-tabix FROM ls_fieldcat.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " FIELDCAT_INIT
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_ALV
*&---------------------------------------------------------------------*
FORM output_alv .

* Feldkatalog aufbauen
  PERFORM fieldcat_init USING gt_fieldcat_all[].
  CASE 'X'.
    WHEN pa_showh.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = g_repid
          i_callback_pf_status_set = g_status
          i_callback_user_command  = g_user_command
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat_all[]
          it_sort                  = g_sort[]
          i_save                   = g_save
          it_events                = gt_events
        TABLES
          t_outtab                 = t_out
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN pa_liste.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program       = g_repid
          i_callback_pf_status_set = g_status
          i_callback_user_command  = g_user_command
          is_layout                = gs_layout
          it_fieldcat              = gt_fieldcat_all[]
          it_sort                  = g_sort[]
          i_save                   = g_save
          it_events                = gt_events
        TABLES
          t_outtab                 = t_out
        EXCEPTIONS
          program_error            = 1
          OTHERS                   = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN pa_updhi.
      PERFORM save_extract.
  ENDCASE.
ENDFORM.                    " OUTPUT_ALV
*&---------------------------------------------------------------------*
*&      Form  TABELLE_SORTIEREN
*&---------------------------------------------------------------------*
FORM tabelle_sortieren  USING lt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-spos = 1.
  ls_sort-fieldname = 'AGGVK'.
  ls_sort-up = 'X'.
  ls_sort-subtot = 'X'.
  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.

  CLEAR ls_sort.
  ls_sort-spos = 2.
  ls_sort-fieldname = 'BCBLN'.
  ls_sort-up = 'X'.
  ls_sort-subtot = 'X'.
*  ls_sort-comp   = 'X'.
  APPEND ls_sort TO lt_sort.
ENDFORM.                    " TABELLE_SORTIEREN
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
FORM variant_init.
  CLEAR g_variant.
  g_variant-report = g_repid.
ENDFORM.                    " VARIANT_INIT
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM f4_for_variant .

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.                    " F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM pai_of_selection_screen .

  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant  = gx_variant.
  ELSE.
    PERFORM variant_init.
  ENDIF.
ENDFORM.                    " PAI_OF_SELECTION_SCREEN
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

  READ TABLE t_out INTO wa_out INDEX rs_selfield-tabindex.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  CALL METHOD rev_alv->check_changed_data.

  rs_selfield-refresh    = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  REFRESH gt_filtered.
  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
    IMPORTING
      et_filtered_entries = gt_filtered
    EXCEPTIONS
      no_infos            = 1
      program_error       = 2
      OTHERS              = 3.
*<<< UH 30012013

  IF r_ucomm      = 'LOCK'.
    PERFORM mahnsperre_setzen.
    rs_selfield-refresh = 'X'.

  ELSEIF r_ucomm  = 'UNLOCK'.
    PERFORM mahnsperre_loeschen.
    rs_selfield-refresh = 'X'.

*>>> UH 11102012
  ELSEIF r_ucomm  = 'DATEX'.
    SUBMIT ree_datex_monitoring WITH se_extui-low = wa_out-ext_ui
       VIA SELECTION-SCREEN AND RETURN.

  ELSEIF r_ucomm  = 'BALANCE'.
    SET PARAMETER ID 'KTO' FIELD wa_out-vkont.
    CALL TRANSACTION 'FPL9'.
*<<< UH 11102012

*>>> UH 30012013
  ELSEIF r_ucomm  = 'SELECT_ALL'.
    PERFORM select_all.

  ELSEIF r_ucomm  = 'DESELECT'.
    PERFORM deselect_all.

  ELSEIF r_ucomm  = 'SEL_BLOCK'.
    PERFORM select_block USING rs_selfield-tabindex.

  ELSEIF r_ucomm  = 'DUNN_HIST'.
    PERFORM dunn_hist USING rs_selfield-tabindex.

  ELSEIF r_ucomm  = 'DUNN_BLK'.
    PERFORM dunn_blck USING rs_selfield-tabindex.

  ELSEIF r_ucomm  = 'INTE_HIST'.
    CALL FUNCTION 'FKK_INTEREST_HISTORY_BROWSE'
      EXPORTING
        i_opbel            = wa_out-opbel
        i_opupk            = wa_out-opupk
      EXCEPTIONS
        appendix_not_found = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE TEXT-s01 TYPE 'S'.
    ENDIF.

  ELSEIF r_ucomm   = 'BALAGGR'.
    SET PARAMETER ID 'KTO' FIELD wa_out-aggvk.
    CALL TRANSACTION 'FPL9'.

*<<< UH 30012013
  ELSE.
    CHECK rs_selfield-value IS NOT INITIAL.
    CASE rs_selfield-fieldname.
*  Vertrag anzeigen
      WHEN 'VTREF'.
        SET PARAMETER ID 'VTG' FIELD rs_selfield-value.
        CALL TRANSACTION 'ES22' AND SKIP FIRST SCREEN.

* Vertragskonto anzeigen
      WHEN  'VKONT'.
        SET PARAMETER ID 'KTO' FIELD rs_selfield-value.
        CALL TRANSACTION 'CAA3' AND SKIP FIRST SCREEN.

* Aggregiertes Vertragskonto
      WHEN 'AGGVK'.
        SET PARAMETER ID 'KTO' FIELD rs_selfield-value.
        CALL TRANSACTION 'CAA3' AND SKIP FIRST SCREEN.
*  Sender
      WHEN 'SENID'.
        SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
        CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

*  Empfänger
      WHEN 'RECID'.
        SET PARAMETER ID 'EESERVPROVID' FIELD rs_selfield-value.
        CALL TRANSACTION 'EEDMIDESERVPROV03' AND SKIP FIRST SCREEN.

* Aggr. Beleg
      WHEN 'BCBLN'.
        SET PARAMETER ID '80B' FIELD rs_selfield-value.
        CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.

*  Belegnummer
      WHEN 'OPBEL'.
* <<< ET_20160304 - Link MEMIDOC Beleg
        IF wa_out-kennz EQ c_doc_kzm.

          DATA lv_pdocnr TYPE eideswtnum .
          DATA lv_doc_id(12) TYPE n.
          lv_doc_id = rs_selfield-value.
          SELECT SINGLE pdoc_ref FROM /idxmm/memidoc INTO lv_pdocnr WHERE doc_id = lv_doc_id.

          IF sy-subrc = 0.
            CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
              EXPORTING
                x_switchnum    = lv_pdocnr
              EXCEPTIONS
                general_fault  = 1
                not_found      = 2
                not_authorized = 3
                OTHERS         = 4.
            IF sy-subrc NE 0.
              MESSAGE TEXT-t01 TYPE 'E'.
            ENDIF.
          ENDIF.
        ELSEIF wa_out-kennz EQ c_doc_kzd.
          SET PARAMETER ID '80B' FIELD rs_selfield-value.
          CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
**       --> Nuss 09.2018
        ELSEIF wa_out-kennz EQ c_doc_kzmsb.
          DATA lv_invdocno_kk TYPE invdocno_kk.
          lv_invdocno_kk = rs_selfield-value.
          CALL FUNCTION 'FKK_INV_INVDOC_DISP'
            EXPORTING
              x_invdocno = lv_invdocno_kk.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
**      <-- Nuss 09.2018
        ENDIF.

* >>> ET_20160304
*  positive REMADV
      WHEN 'PAYNO'.
        SUBMIT rinv_monitoring WITH se_docnr-low = wa_out-payno AND RETURN.

*  negative REMADV
      WHEN 'DOCNO'.
        SUBMIT rinv_monitoring WITH se_docnr-low = wa_out-docno AND RETURN.

*  INVOIC-IDOC
      WHEN 'IDOCIN'.
        SUBMIT idoc_tree_control WITH docnum = wa_out-idocin AND RETURN.

*  CONTROL-IDOC (Aggr. IDOC)
      WHEN 'IDOCCT'.
        SUBMIT idoc_tree_control WITH docnum = wa_out-idocct AND RETURN.
    ENDCASE.
  ENDIF.
ENDFORM.                    "user_command.
*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
FORM status_standard  USING extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_STATUS' EXCLUDING extab.
*  if pa_updte = 'X'.
*    set pf-status 'STANDARD_DIRECTUPD' excluding extab.
*  else.
*    if pa_showh = 'X'.
*      set pf-status 'STANDARD_DIRECTUPD' excluding extab.
*    else.
*      set pf-status 'STANDARD_STATUS' excluding extab.
*    endif.
*  endif.
ENDFORM.                    "status_standard
*&---------------------------------------------------------------------*
*&      Form  MAHNSPERRE_SETZEN
*&---------------------------------------------------------------------*
FORM mahnsperre_setzen.

  DATA:    l_answer TYPE char1.
  CLEAR:   w_sval.
  REFRESH: t_sval.

*>>> UH 30012013
  w_sval-tabname   = 'FKKMAZE'.
  w_sval-fieldname = 'MANSP'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'Sperrgrund'.
  w_sval-value     = pa_lockr.
  APPEND w_sval TO t_sval.
*<<< UH 30012013

  w_sval-tabname   = 'DFKKLOCKS'.
  w_sval-fieldname = 'FDATE'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'von Datum'.
  w_sval-value     = pa_fdate.
  APPEND w_sval TO t_sval.

  w_sval-tabname   = 'DFKKLOCKS'.
  w_sval-fieldname = 'TDATE'.
  w_sval-field_obl = 'X'.
  w_sval-fieldtext = 'bis Datum'.
  w_sval-value     = pa_tdate.
  APPEND w_sval TO t_sval.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      popup_title  = 'Mahnsperre'
      start_column = '5'
      start_row    = '5'
    TABLES
      fields       = t_sval.

  LOOP AT t_sval INTO w_sval.
    CASE w_sval-fieldname.
      WHEN 'MANSP'.
        pa_lockr = w_sval-value.
      WHEN 'FDATE'.
        pa_fdate = w_sval-value.
      WHEN 'TDATE'.
        pa_tdate = w_sval-value.
    ENDCASE.
  ENDLOOP.

* --> Nuss 12.02.2018
* Abdatum darf nicht kleiner als Tagesdatum sein
  IF pa_fdate < sy-datum.
    MESSAGE TEXT-e03 TYPE 'E'.
  ENDIF.

* Bis-Datum darf nicht größer Ab-Datum sein
  IF pa_tdate < pa_fdate.
    MESSAGE TEXT-e05 TYPE 'E'.
  ENDIF.
* <-- Nuss 12.02.2018

*** --> Nuss 01.02.2018 wieder auskommentiert
*** ---> Nuss 26.01.2018
*** Memis keine Mahnsperre
*** Wenn Memis ausgewählt sind mit Fehlermeldung raus
*  LOOP AT t_out ASSIGNING <t_out> WHERE sel IS NOT INITIAL
*      AND kennz = c_doc_kzm.
*    MESSAGE e000(e4) WITH 'Mahnsperren für Memi-Belege'
*                          'aktuell nicht möglich.'
*                          'Klärung mit SAP läuft'.
*
*    EXIT.
*  ENDLOOP.
*** <-- Nuss 26.01.2018


* Sicherheitsabfrage
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = TEXT-100
      textline2     = TEXT-101
      titel         = TEXT-t01
    IMPORTING
      answer        = l_answer.

  IF NOT l_answer CA 'jJyY'.
    EXIT.
  ENDIF.



  LOOP AT t_out ASSIGNING <t_out> WHERE sel IS NOT INITIAL.
    READ TABLE gt_filtered
      WITH KEY table_line = sy-tabix
      TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.
*    CHECK <t_out>-status = icon_breakpoint.
    CHECK <t_out>-augst  = ' '.

    IF <t_out>-kennz EQ c_doc_kzd.
      CLEAR:   t_fkkopchl.
      REFRESH: t_fkkopchl.

*   Sperren zu Belegpositionen
      t_fkkopchl-lockaktyp = c_lockaktyp.
      t_fkkopchl-opupk     = <t_out>-opupk.
      t_fkkopchl-opupw     = <t_out>-opupw.
      t_fkkopchl-opupz     = <t_out>-opupz.
      t_fkkopchl-proid     = c_proid.
      t_fkkopchl-lockr     = pa_lockr.
      t_fkkopchl-fdate     = pa_fdate.
      t_fkkopchl-tdate     = pa_tdate.
      t_fkkopchl-lotyp     = c_lotyp.
      t_fkkopchl-gpart     = <t_out>-gpart.
      t_fkkopchl-vkont     = <t_out>-vkont.
      APPEND t_fkkopchl.

      CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
        EXPORTING
          i_opbel           = <t_out>-opbel
        TABLES
          t_fkkopchl        = t_fkkopchl
        EXCEPTIONS
          err_document_read = 1
          err_create_line   = 2
          err_lock_reason   = 3
          err_lock_date     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        <t_out>-to_lock = icon_breakpoint.
      ELSE.
        <t_out>-mansp = pa_lockr.
        <t_out>-fdate = pa_fdate.
        <t_out>-tdate = pa_tdate.
        <t_out>-status = icon_locked.
      ENDIF.
*>>> UH 08042013
** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
*<<< UH 08042013
    ELSEIF <t_out>-kennz EQ c_doc_kzm.
      DATA lv_done TYPE abap_bool.
*      DATA: ls_mloc TYPE /ADZ/hmv_mloc.
*      DATA ls_memidoc_u TYPE /idxmm/memidoc.
*      DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
*      DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.
*
**      IF c_idxmm_sp03_dunn IS INITIAL.                              "Nuss 02.02.2018
*
**    Es ist schon eine Mahnsperre vorhanden
*      IF <t_out>-fdate IS NOT INITIAL AND
*         <t_out>-tdate IS NOT INITIAL.
*        IF pa_tdate ge <t_out>-fdate.
*           MESSAGE TEXT-e06 TYPE 'E'.
*        ENDIF.
*      ENDIF.
*
*      ls_mloc-doc_id    = <t_out>-opbel.
*      ls_mloc-lockr     = pa_lockr.
*      ls_mloc-fdate     = pa_fdate.
*      ls_mloc-tdate     = pa_tdate.
*      ls_mloc-crnam     = sy-uname.
*      ls_mloc-azeit     = sy-timlo.
*      ls_mloc-adatum    = sy-datum.
*      ls_mloc-lvorm     = ''.
**        INSERT INTO /ADZ/hmv_mloc VALUES ls_mloc.      "Nuss 02.02.2018
*      MODIFY /ADZ/hmv_mloc FROM ls_mloc.              "Nuss 02.02.2018
*
*      IF sy-subrc = 0.
*        <t_out>-mansp  = pa_lockr.
*        <t_out>-fdate  = pa_fdate.
*        <t_out>-tdate  = pa_tdate.
*        <t_out>-status = icon_locked.
*      ENDIF.

**     --> Nuss 02.02.2018 auskommentiert
*      ELSE.
*

      CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
        EXPORTING
          iv_belnr     = <t_out>-opbel
*         IX_GET_LOCKHIST       =
          ix_set_lock  = 'X'
*         IX_DEL_LOCK  =
          iv_no_popup  = 'X'
        IMPORTING
          ev_done      = lv_done
        CHANGING
          iv_date_from = pa_fdate
          iv_date_to   = pa_tdate
          iv_lockr     = pa_lockr.
      IF lv_done = 'X'.
*      IF sy-subrc = 0.
        <t_out>-mansp  = pa_lockr.
        <t_out>-fdate  = pa_fdate.
        <t_out>-tdate  = pa_tdate.
        <t_out>-status = icon_locked.
*      ENDIF.
      ENDIF.

*
*
*        CREATE OBJECT lr_memidoc.
*        SELECT SINGLE * FROM /idxmm/memidoc INTO ls_memidoc_u WHERE doc_id = <t_out>-opbel.
*
*
*        ls_memidoc_u-doc_status = c_memidoc_dnlcrsn.
*        APPEND ls_memidoc_u TO lt_memidoc_u.
**      TRY.
*        CALL METHOD /idxmm/cl_memi_document_db=>update
*          EXPORTING
**           iv_simulate   =
*            it_doc_update = lt_memidoc_u.
**         CATCH /idxmm/cx_bo_error .
**        ENDTRY.
*
*        IF sy-subrc = 0.
*
*          <t_out>-doc_status = c_memidoc_dnlcrsn.
*
*        ENDIF.
*
*      ENDIF.

** --> Nuss 09.2018
    ELSEIF <t_out>-kennz EQ c_doc_kzmsb.
      CLEAR:   t_fkkopchl.
      REFRESH: t_fkkopchl.

*   Sperren zu Belegpositionen
      t_fkkopchl-lockaktyp = c_lockaktyp.
      t_fkkopchl-opupk     = '0001'.
      t_fkkopchl-opupw     = '000'.
      t_fkkopchl-opupz     = '0000'.
      t_fkkopchl-proid     = c_proid.
      t_fkkopchl-lockr     = pa_lockr.
      t_fkkopchl-fdate     = pa_fdate.
      t_fkkopchl-tdate     = pa_tdate.
      t_fkkopchl-lotyp     = c_lotyp.
      t_fkkopchl-gpart     = <t_out>-gpart.
      t_fkkopchl-vkont     = <t_out>-vkont.
      APPEND t_fkkopchl.

      CALL FUNCTION 'FKK_DOCUMENT_CHANGE_LOCKS'
        EXPORTING
          i_opbel           = <t_out>-bcbln
        TABLES
          t_fkkopchl        = t_fkkopchl
        EXCEPTIONS
          err_document_read = 1
          err_create_line   = 2
          err_lock_reason   = 3
          err_lock_date     = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        <t_out>-to_lock = icon_breakpoint.
      ELSE.
        <t_out>-mansp = pa_lockr.
        <t_out>-fdate = pa_fdate.
        <t_out>-tdate = pa_tdate.
        <t_out>-status = icon_locked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
** <-- Nuss 09.2018

    ENDIF.
  ENDLOOP.
ENDFORM.                    " MAHNSPERRE_SETZEN
*&---------------------------------------------------------------------*
*&      Form  save_extract
*&---------------------------------------------------------------------*
FORM save_extract.

  DATA: h_extract TYPE disextract.

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  CLEAR: h_extract.
* Programmname
  h_extract-report = sy-repid.
* Extrakt Text
  h_extract-text = TEXT-001.
  DESCRIBE TABLE t_out LINES x_tabix.
  WRITE x_tabix TO h_extract-text+8 LEFT-JUSTIFIED.

  h_extract-text+25 = TEXT-007.
  WRITE x_uzeit TO h_extract-text+31 USING EDIT MASK '__:__:__'.

* Extrakt Name
  h_extract-exname   = sy-datum.
  h_extract-exname+8 = sy-uzeit.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
    EXPORTING
      is_extract         = h_extract
      i_get_selinfos     = 'X'
    TABLES
      it_exp01           = t_out
    EXCEPTIONS
      wrong_relid        = 1
      no_report          = 2
      no_exname          = 3
      no_extract_created = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SAVE_EXTRACT
*&---------------------------------------------------------------------*
*&      Form  SHOW_HISTORY
*&---------------------------------------------------------------------*
FORM show_history .

* Extraktname bilden ----------------------------------------
* Schlüssel zum Extract bilden
  h_extract-report = sy-repid.

* F4 Hilfe für Extraktselektion
  CALL FUNCTION 'REUSE_ALV_EXTRACT_AT_F4_P_EX2'
    CHANGING
      c_p_ex2     = h_ex
      c_p_ext2    = h_ex
      cs_extract2 = h_extract.

* Extract Laden
  CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
    EXPORTING
      is_extract         = h_extract
*>>> UH 11102012
    IMPORTING
      es_admin           = h_extadmin
*<<< UH 11102012
    TABLES
      et_exp01           = t_out
    EXCEPTIONS
      not_found          = 1
      wrong_relid        = 2
      no_report          = 3
      no_exname          = 4
      no_import_possible = 5
      OTHERS             = 6.

  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " SHOW_HISTORY
*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
FORM set_events .

  DATA: ls_events TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = gt_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.

  READ TABLE gt_events WITH KEY name = slis_ev_top_of_page INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY gt_events FROM ls_events INDEX sy-tabix.
  ENDIF.
ENDFORM.                    " SET_EVENTS
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
FORM top_of_page .                                          "#EC *

  CLEAR:   gs_listheader.
  REFRESH: gt_listheader.

*>>> UH 11102012
  IF pa_showh = 'X'.
    gs_listheader-typ  = c_listheader_typ.
    gs_listheader-key  = TEXT-002.
    gs_listheader-info = h_extadmin-erfname.
    WRITE h_extadmin-erfdat  TO gs_listheader-info+20.
    WRITE h_extadmin-erftime TO gs_listheader-info+35 USING EDIT MASK '__:__:__'.
    APPEND gs_listheader     TO gt_listheader.
  ENDIF.
*<<< UH 11102012

  DESCRIBE TABLE t_out LINES x_tabix.
  gs_listheader-typ = c_listheader_typ.
  gs_listheader-key = TEXT-001.
  WRITE x_tabix        TO gs_listheader-info LEFT-JUSTIFIED.
  APPEND gs_listheader TO gt_listheader.

  gs_listheader-typ  = c_listheader_typ.
  gs_listheader-key  = TEXT-008.
  WRITE x_uzeit  TO gs_listheader-info USING EDIT MASK '__:__:__'.
  WRITE sy-uzeit TO gs_listheader-info+15 USING EDIT MASK '__:__:__'.
  APPEND gs_listheader TO gt_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.
ENDFORM.                    " handle_event_top_of_page
*----------------------------------------------------------------------*
*&      Form  BASIS_SELECT
*&---------------------------------------------------------------------*
FORM basis_select USING it_fkkvkp     TYPE tty_fkkvkp
                        iv_thidt_to   TYPE thidt_kk
                        iv_thidt_from TYPE thidt_kk
                        it_rng_bclbn  TYPE tty_rng_bcln
                  CHANGING ct_dfkkop_buffer TYPE tty_dfkkop_buffer.

  DATA lt_rng_vkont TYPE RANGE OF tsy_fkkvkp-vkont.
  DATA ls_rng_vkont LIKE LINE OF lt_rng_vkont.
  DATA lt_rng_stdbk TYPE RANGE OF tsy_fkkvkp-stdbk.
  DATA ls_rng_stdbk LIKE LINE OF lt_rng_stdbk.

  ls_rng_vkont-option = 'EQ'.
  ls_rng_vkont-sign   =  'I'.
  ls_rng_stdbk-option = 'EQ'.
  ls_rng_stdbk-sign   =  'I'.
  LOOP AT it_fkkvkp ASSIGNING FIELD-SYMBOL(<ls_fkkvkp>).
    ls_rng_vkont-low = <ls_fkkvkp>-vkont.
    INSERT ls_rng_vkont INTO lt_rng_vkont.
    ls_rng_stdbk-low = <ls_fkkvkp>-stdbk.
    INSERT ls_rng_stdbk INTO lt_rng_stdbk.
  ENDLOOP.
  SELECT opbel opupk vkont bukrs
         INTO TABLE ct_dfkkop_buffer
         FROM dfkkop
         WHERE augst IN (' ','9')
           AND vkont IN lt_rng_vkont
           AND bukrs IN lt_rng_stdbk
           AND faedn <= iv_thidt_to
           AND faedn >= iv_thidt_from
           AND opbel IN it_rng_bclbn.
ENDFORM.
*----------------------------------------------------------------------*
*&      Form  PRE_SELECT
*&---------------------------------------------------------------------*
FORM pre_select .

  REFRESH t_opbel.
  REFRESH t_bcbln.
  REFRESH t_memidoc.
  REFRESH t_msbdoc.    "Nuss 09.2018



* Preselect for dfkkthi
  IF gt_dfkkop_buffer IS NOT INITIAL.
    DATA ls_opbel like line of t_opbel.
    " selektion aus dem Buffer
    loop at gt_dfkkop_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>)
    where  vkont  = t_fkkvkp-vkont
      and  bukrs  = t_fkkvkp-stdbk
      and  opbel IN so_bcbln.
      ls_opbel-opbel = <ls_buf>-opbel.
      ls_opbel-opupk = <ls_buf>-opupk.
      insert ls_opbel into table t_opbel.
    ENDLOOP.
  ELSE.
    " selektion von db
    SELECT opbel opupk
           INTO CORRESPONDING FIELDS OF TABLE t_opbel
           FROM dfkkop
           WHERE augst IN (' ','9')
             AND vkont  = t_fkkvkp-vkont
             AND faedn <= x_thidt_to
             AND faedn >= x_thidt_from
             AND bukrs  = t_fkkvkp-stdbk
             AND opbel IN so_bcbln.
  ENDIF.
  CHECK t_opbel[] IS NOT INITIAL.
  SELECT bcbln opbel opupw opupk
        INTO CORRESPONDING FIELDS OF TABLE t_bcbln
        FROM dfkkthi
        FOR ALL ENTRIES IN t_opbel
        WHERE bcbln = t_opbel-opbel
          AND vkont IN so_ekont
          AND thidt <= x_thidt_to
          AND thidt >= x_thidt_from
          AND bukrs IN so_bukrs.
  SORT t_bcbln BY bcbln opbel opupw opupk.

* <<< ET_20160229
* Preselect memidoc
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE t_memidoc
    FROM /idxmm/memidoc
    FOR ALL ENTRIES IN t_opbel
      WHERE ci_fica_doc_no = t_opbel-opbel
        AND opupk = t_opbel-opupk
        AND due_date <= x_thidt_to
        AND due_date >= x_thidt_from.
  SORT t_memidoc.
* >>> ET_20160229

* Preselect msbdoc
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_msbdoc
  FROM dfkkinvdoc_i AS i
    INNER JOIN dfkkinvdoc_h AS h
    ON i~invdocno = h~invdocno
  FOR ALL ENTRIES IN t_opbel
  WHERE i~opbel = t_opbel-opbel
  AND i~faedn <= x_thidt_to
  AND i~faedn >= x_thidt_from
  AND i~bukrs IN so_bukrs
  AND h~inv_process = 'MO'
  AND h~inv_type = 'MO'
  AND h~/mosb/inv_doc_ident NE ''.
  SORT t_msbdoc.
  DELETE ADJACENT DUPLICATES FROM t_msbdoc COMPARING ALL FIELDS.


ENDFORM.                    " PRE_SELECT
*&---------------------------------------------------------------------*
*&      Form  ENDE_TASK
*&---------------------------------------------------------------------*
* DFKKTHI
FORM ende_task USING taskname.
  RECEIVE RESULTS FROM FUNCTION '/ADZ/HMV_SELECT'
    TABLES
         et_out      = ft_out
    EXCEPTIONS
       communication_failure = 1
       system_failure        = 2.
  IF sy-subrc = 0.
    APPEND LINES OF ft_out TO t_out.
*   Lösche Tasks aus der Tasktabelle
    DELETE t_tasks WHERE name = taskname.
    SUBTRACT 1 FROM x_runts.
  ELSE.
    MESSAGE TEXT-e04 TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " ENDE_TASK
*&---------------------------------------------------------------------*
*&      Form  ENDE_TASK_MEMI
*&---------------------------------------------------------------------*
* MEMIDOC
FORM ende_task_memi USING taskname.
  RECEIVE RESULTS FROM FUNCTION '/ADZ/HMV_SELECT_MEMIDOC'
    TABLES
         et_out      = ft_out
    EXCEPTIONS
       communication_failure = 1
       system_failure        = 2.
  IF sy-subrc = 0.
    APPEND LINES OF ft_out TO t_out.
*   Lösche Tasks aus der Tasktabelle
    DELETE t_tasks WHERE name = taskname.
    SUBTRACT 1 FROM x_runts.
  ELSE.
    MESSAGE TEXT-e04 TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " ENDE_TASK
** --> Nuss 09.2018
*&---------------------------------------------------------------------*
*&      Form  ENDE_TASK_MSB
*&---------------------------------------------------------------------*
* MEMIDOC
FORM ende_task_msb USING taskname.
  RECEIVE RESULTS FROM FUNCTION '/ADZ/HMV_SELECT_MSBDOC'
  TABLES
  et_out      = ft_out
  EXCEPTIONS
  communication_failure = 1
  system_failure        = 2.
  IF sy-subrc = 0.
    APPEND LINES OF ft_out TO t_out.
*   Lösche Tasks aus der Tasktabelle
    DELETE t_tasks WHERE name = taskname.
    SUBTRACT 1 FROM x_runts.
  ELSE.
    MESSAGE TEXT-e04 TYPE 'I'.
    STOP.
  ENDIF.
ENDFORM.                    " ENDE_TASK

** <-- Nuss 09.2018
*&---------------------------------------------------------------------*
*&      Form  CREATE_TASKS
*&---------------------------------------------------------------------*
FORM create_tasks .

* Create Tasks for DFKKTHI
  CLEAR wa_tasks.
  wa_tout   = wa_out.
  t_tbcbl[] = t_bcbln.
  DESCRIBE TABLE t_tbcbl LINES x_tabix.
  IF x_tabix NE 0.
    IF x_tabix < 2000.
      x_prtio = x_tabix.
    ELSE.
      x_prtio    = x_tabix / x_maxts.
      IF x_prtio > c_prtio.
        x_prtio = c_prtio.
      ENDIF.
    ENDIF.
    DO.
      wa_tasks-count = wa_tasks-count + 1.
      wa_tasks-low   = wa_tasks-high  + 1.
      wa_tasks-high  = wa_tasks-low   + x_prtio.
      CONCATENATE c_doc_kzd wa_tout-aggvk wa_tasks-count
             INTO wa_tasks-name SEPARATED BY space.
      APPEND wa_tasks TO t_tasks.
      x_tabix = x_tabix - x_prtio.
      IF x_tabix <= 0.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.

* Create Tasks for MEMIDOC
  CLEAR wa_tasks.
  wa_tout      = wa_out.
  t_memidoc2[] = t_memidoc[].
  DESCRIBE TABLE t_memidoc2 LINES x_tabix.
  IF x_tabix NE 0.
    IF x_tabix < 2000.
      x_prtio = x_tabix.
    ELSE.
      x_prtio = x_tabix / x_maxts.
      IF x_prtio > c_prtio.
        x_prtio = c_prtio.
      ENDIF.
    ENDIF.
    DO.
      wa_tasks-count = wa_tasks-count + 1.
      wa_tasks-low   = wa_tasks-high  + 1.
      wa_tasks-high  = wa_tasks-low   + x_prtio.
      CONCATENATE c_doc_kzm wa_tout-aggvk wa_tasks-count
             INTO wa_tasks-name SEPARATED BY space.
      APPEND wa_tasks TO t_tasks.
      x_tabix = x_tabix - x_prtio.
      IF x_tabix <= 0.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.

** --> Nuss 09.2018
* Create tasks for MSBDOC
  CLEAR wa_tasks.
  wa_tout = wa_out.
  t_msbdoc2[] = t_msbdoc[].
  DESCRIBE TABLE t_msbdoc2 LINES x_tabix.
  IF x_tabix NE 0.
    IF x_tabix < 2000.
      x_prtio = x_tabix.
    ELSE.
      x_prtio = x_tabix / x_maxts.
      IF x_prtio > c_prtio.
        x_prtio = c_prtio.
      ENDIF.
    ENDIF.
    DO.
      wa_tasks-count = wa_tasks-count + 1.
      wa_tasks-low   = wa_tasks-high  + 1.
      wa_tasks-high  = wa_tasks-low   + x_prtio.
      CONCATENATE c_doc_kzmsb wa_tout-aggvk wa_tasks-count
      INTO wa_tasks-name SEPARATED BY space.
      APPEND wa_tasks TO t_tasks.
      x_tabix = x_tabix - x_prtio.
      IF x_tabix <= 0.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
* <-- Nuss 09.2018


ENDFORM.                    " CREATE_TASKS
*>>> UH 30012013
*&---------------------------------------------------------------------*
*&      Form SELECT_ALL
*&---------------------------------------------------------------------*
FORM select_all .
  LOOP AT t_out INTO wa_out.
    READ TABLE gt_filtered
      WITH KEY table_line = sy-tabix
      TRANSPORTING NO FIELDS.
    CHECK sy-subrc NE 0.
    wa_out-sel = 'X'.
    MODIFY t_out FROM wa_out.
  ENDLOOP.
ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
FORM deselect_all .
  LOOP AT t_out INTO wa_out.
    CLEAR wa_out-sel.
    MODIFY t_out FROM wa_out.
  ENDLOOP.
ENDFORM.                    " DESELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  SELECT_BLOCK
*&---------------------------------------------------------------------*
FORM select_block USING tabindex TYPE slis_selfield-tabindex.

  DATA: l_answer TYPE char1.

  IF block_line IS INITIAL.
    block_line = tabindex.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'Y'
        textline1     = TEXT-102
        textline2     = TEXT-103
        titel         = TEXT-t02
      IMPORTING
        answer        = l_answer.

    IF NOT l_answer CA 'jJyY'.
      CLEAR block_line.
      EXIT.
    ENDIF.
  ELSE.
    IF block_line <= tabindex.
      block_beg   = block_line.
      block_end   = tabindex.
    ELSE.
      block_beg   = tabindex.
      block_end   = block_line.
    ENDIF.

    LOOP AT t_out INTO wa_out FROM block_beg TO block_end.
      READ TABLE gt_filtered
         WITH KEY table_line = sy-tabix
         TRANSPORTING NO FIELDS.
      CHECK sy-subrc NE 0.
      wa_out-sel = 'X'.
      MODIFY t_out FROM wa_out.
    ENDLOOP.
    CLEAR block_line.
  ENDIF.
ENDFORM.                    " SELECT_BLOCK
*&---------------------------------------------------------------------*
*&      Form  DUNN_BLCK
*&---------------------------------------------------------------------*
FORM dunn_blck USING tabindex TYPE slis_selfield-tabindex.

  DATA: lv_t_dfkklocks  TYPE STANDARD TABLE OF dfkklocks WITH DEFAULT KEY.
  DATA: lv_s_dfkklocks  TYPE dfkklocks.
  DATA: lv_t_dfkklocksh TYPE STANDARD TABLE OF dfkklocksh WITH DEFAULT KEY.
  DATA: lv_s_dfkklocksh TYPE dfkklocksh.
  DATA: ls_dfkkop_key   TYPE dfkkop_key_s.
  DATA  x_wtitle        TYPE lvc_title.
  DATA: lv_loobj1       TYPE dfkklocks-loobj1.
*  DATA: x_wtitle(50).

  REFRESH: lv_t_dfkklocks, lv_t_dfkklocksh.


* --- move keyfields into key structure -----------------------------
  ls_dfkkop_key-opbel = wa_out-opbel.
  ls_dfkkop_key-opupw = wa_out-opupw.
  ls_dfkkop_key-opupk = wa_out-opupk.
  ls_dfkkop_key-opupz = wa_out-opupz.

  IF wa_out-kennz EQ c_doc_kzd.
    DATA: gt_outtab  TYPE STANDARD TABLE OF dfkklocks,
          lv_columns TYPE i,
          lv_belnr   TYPE opbel_kk,
          lr_content TYPE REF TO cl_salv_form_element,
          gr_display TYPE REF TO cl_salv_display_settings,
          gr_table   TYPE REF TO cl_salv_table.


    MOVE ls_dfkkop_key TO lv_loobj1.
    CALL FUNCTION 'FKK_DB_LOCK_SELECT'
      EXPORTING
        i_loobj1          = lv_loobj1
        i_proid           = c_proid
        i_lotyp           = c_lotyp
        i_x_hist          = 'X'
        i_x_use_fieldlist = 'X'
      TABLES
        et_locks          = lv_t_dfkklocks
        et_locksh         = lv_t_dfkklocksh.

    LOOP AT lv_t_dfkklocksh INTO lv_s_dfkklocksh.
      MOVE-CORRESPONDING lv_s_dfkklocksh TO lv_s_dfkklocks.
      APPEND lv_s_dfkklocks TO lv_t_dfkklocks.
    ENDLOOP.

    IF sy-subrc = 0.
      lv_columns = lines( lv_t_dfkklocks ) + 5.
      TRY.
          cl_salv_table=>factory(
       EXPORTING
          list_display = 'X'
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = lv_t_dfkklocks
             ).
        CATCH cx_salv_msg .
      ENDTRY.

      gr_table->set_screen_popup(
        start_column = 1
        end_column   = 200
        start_line   = 1
        end_line     = lv_columns ).

      lv_belnr = ls_dfkkop_key-opbel.
      SHIFT lv_belnr LEFT DELETING LEADING '0'.
      CONCATENATE TEXT-t04 lv_belnr INTO x_wtitle SEPARATED BY space.

      gr_display = gr_table->get_display_settings( ).
      gr_display->set_list_header( x_wtitle ).

      DATA: lr_selections TYPE REF TO cl_salv_selections.

      lr_selections = gr_table->get_selections( ).
      lr_selections->set_selection_mode(
    if_salv_c_selection_mode=>none ).

      gr_table->display( ).
    ELSE.
      MESSAGE i023(/adz/hmv).
    ENDIF.

*    CONCATENATE text-t03 wa_out-opbel INTO x_wtitle SEPARATED BY space.
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        ddic_structure  = 'DFKKLOCKS'
*        retfield        = 'LOOBJ1'
*        window_title    = x_wtitle
*        value_org       = 'S'
*      TABLES
*        value_tab       = lv_t_dfkklocks
*      EXCEPTIONS
*        parameter_error = 1
*        no_values_found = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      MESSAGE text-s02 TYPE 'S'.
*    ENDIF.

  ELSEIF wa_out-kennz EQ c_doc_kzm.

*    CALL FUNCTION '/ADZ/HMV_MEMI_LOCKHIST'
*      EXPORTING
*        doc_id = wa_out-opbel.
    CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
      EXPORTING
        iv_belnr        = wa_out-opbel
        ix_get_lockhist = 'X'
*       IX_SET_LOCK     =
*       IX_DEL_LOCK     =
*       IV_NO_POPUP     =
* IMPORTING
*       EV_DONE         =
* CHANGING
*       IV_DATE_FROM    =
*       IV_DATE_TO      =
*       IV_LOCKR        =
      .

  ENDIF.
ENDFORM.                    " DUNN_BLCK
*&---------------------------------------------------------------------*
*&      Form  DUNN_HIST
*&---------------------------------------------------------------------*
FORM dunn_hist USING tabindex TYPE slis_selfield-tabindex.

  " READ TABLE t_out INTO wa_out INDEX tabindex.

  FIELD-SYMBOLS <l_out>  TYPE /adz/hmv_s_out_dunning.

  DATA:
    lv_t_fkkmaze TYPE STANDARD TABLE OF fkkmaze WITH DEFAULT KEY,
    wa_fkkmaze   TYPE                   fkkmaze,
    x_wtitle     TYPE lvc_title.

*  DATA lv_count TYPE i.
*  CLEAR lv_count.
*  LOOP AT t_out ASSIGNING <l_out>  WHERE sel IS NOT INITIAL.
*    lv_count = lv_count + 1.
*  ENDLOOP.
*  IF lv_count <> 1.
*    ASSIGN wa_out TO <l_out>.
*    IF sy-subrc <> 0.
*      MESSAGE e024(/ADZ/hmv).
*    ENDIF.
*  ENDIF.
  READ TABLE t_out ASSIGNING <l_out> INDEX tabindex.
  IF sy-subrc = 0.

    CLEAR lv_t_fkkmaze.

    DATA: gt_outtab  TYPE STANDARD TABLE OF fkkmaze,
          lv_columns TYPE i,
          lv_belnr   TYPE opbel_kk,
          lr_content TYPE REF TO cl_salv_form_element,
          gr_display TYPE REF TO cl_salv_display_settings,
          gr_table   TYPE REF TO cl_salv_table.

* Select dunnhist für Dfkkthi
    IF <l_out>-kennz = 'D'.
      SELECT * FROM fkkmaze
        INTO TABLE lv_t_fkkmaze
        WHERE opbel = <l_out>-opbel
          AND opupw = <l_out>-opupw
          AND opupk = <l_out>-opupk.
    ELSE.
      SELECT * FROM fkkmaze
        INTO TABLE lv_t_fkkmaze
        WHERE opbel = <l_out>-bcbln
          AND opupk = <l_out>-opupk.
    ENDIF.

    IF sy-subrc = 0.
      lv_columns = lines( lv_t_fkkmaze ) + 5.
      TRY.
          cl_salv_table=>factory(
       EXPORTING
          list_display = 'X'
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = lv_t_fkkmaze
             ).
        CATCH cx_salv_msg .
      ENDTRY.

      gr_table->set_screen_popup(
        start_column = 1
        end_column   = 200
        start_line   = 1
        end_line     = lv_columns ).

      lv_belnr = <l_out>-opbel.
      SHIFT lv_belnr LEFT DELETING LEADING '0'.
      CONCATENATE TEXT-t04 lv_belnr INTO x_wtitle SEPARATED BY space.

      gr_display = gr_table->get_display_settings( ).
      gr_display->set_list_header( x_wtitle ).

      DATA: lr_selections TYPE REF TO cl_salv_selections.

      lr_selections = gr_table->get_selections( ).
      lr_selections->set_selection_mode(
    if_salv_c_selection_mode=>none ).

      gr_table->display( ).

    ELSE.
      MESSAGE i019(/adz/hmv).
    ENDIF.
  ENDIF.

*    CONCATENATE text-t04 wa_out-opbel INTO x_wtitle SEPARATED BY space.
*
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        ddic_structure  = 'FKKMAZE'
*        retfield        = 'LAUFD'
*        window_title    = x_wtitle
*        value_org       = 'S'
*      TABLES
*        value_tab       = lv_t_fkkmaze
*      EXCEPTIONS
*        parameter_error = 1
*        no_values_found = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      MESSAGE text-s03 TYPE 'S'.
*    ENDIF.


ENDFORM.                    " DUNN_HIST
*&---------------------------------------------------------------------*
*&      Form MAHNSPERRE_LOESCHEN
*&---------------------------------------------------------------------*
FORM mahnsperre_loeschen .

  DATA: lt_opbel TYPE fkkopkey_t.
  DATA: ls_opbel TYPE fkkopkey.
  DATA: l_answer TYPE char1.
  DATA ls_memidoc_u TYPE /idxmm/memidoc.
  DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
  DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.

* Sicherheitsabfrage
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = TEXT-104
      textline2     = TEXT-105
      titel         = TEXT-t05
    IMPORTING
      answer        = l_answer.

  IF NOT l_answer CA 'jJyY'.
    EXIT.
  ENDIF.

  LOOP AT t_out ASSIGNING <t_out> WHERE sel IS NOT INITIAL.
    READ TABLE gt_filtered
      WITH KEY table_line = sy-tabix
      TRANSPORTING NO FIELDS.

    CHECK sy-subrc NE 0.
    CHECK <t_out>-augst  = ' '.

    IF <t_out>-kennz EQ c_doc_kzd.
      CHECK <t_out>-mansp IS NOT INITIAL.
      REFRESH lt_opbel.
      CLEAR ls_opbel.

      ls_opbel-opbel = <t_out>-opbel.
      ls_opbel-opupw = <t_out>-opupw.
      ls_opbel-opupk = <t_out>-opupk.
      ls_opbel-opupz = <t_out>-opupz.
      APPEND ls_opbel TO lt_opbel.

      CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
        EXPORTING
          iv_opbel    = <t_out>-opbel
          it_fkkopkey = lt_opbel
          iv_proid    = c_proid
          iv_lockr    = <t_out>-mansp
          iv_fdate    = <t_out>-fdate
          iv_tdate    = <t_out>-tdate
        EXCEPTIONS
          OTHERS      = 5.

      IF sy-subrc <> 0.
        <t_out>-status = icon_breakpoint.
      ELSE.
        CLEAR: <t_out>-mansp, <t_out>-fdate, <t_out>-tdate.
        <t_out>-status = icon_unlocked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
*<<< UH 08042013
    ELSEIF  <t_out>-kennz EQ c_doc_kzm.
      DATA lv_done_del TYPE abap_bool.

      CALL FUNCTION '/ADZ/MEMI_MAHNSPERRE'
        EXPORTING
          iv_belnr    = <t_out>-opbel
*         IX_GET_LOCKHIST       =
*         IX_SET_LOCK =
          ix_del_lock = 'X'
*         IV_NO_POPUP =
        IMPORTING
          ev_done     = lv_done_del
* CHANGING
*         IV_DATE_FROM          =
*         IV_DATE_TO  =
*         IV_LOCKR    =
        .


      IF lv_done_del = 'X'.
        <t_out>-mansp = ''.
        <t_out>-fdate = ''.
        <t_out>-tdate = ''.
        <t_out>-status = icon_unlocked.
      ENDIF.

**  --> Nuss 09.2018
    ELSEIF  <t_out>-kennz EQ c_doc_kzmsb.
      CHECK <t_out>-mansp IS NOT INITIAL.
      REFRESH lt_opbel.
      CLEAR ls_opbel.

      ls_opbel-opbel = <t_out>-bcbln.
      ls_opbel-opupw = '000'.
      ls_opbel-opupk = '0001'.
      ls_opbel-opupz = '0000'.
      APPEND ls_opbel TO lt_opbel.

      CALL FUNCTION 'FKK_S_LOCK_DELETE_FOR_DOCITEMS'
        EXPORTING
          iv_opbel    = <t_out>-bcbln
          it_fkkopkey = lt_opbel
          iv_proid    = c_proid
          iv_lockr    = <t_out>-mansp
          iv_fdate    = <t_out>-fdate
          iv_tdate    = <t_out>-tdate
        EXCEPTIONS
          OTHERS      = 5.

      IF sy-subrc <> 0.
        <t_out>-status = icon_breakpoint.
      ELSE.
        CLEAR: <t_out>-mansp, <t_out>-fdate, <t_out>-tdate.
        <t_out>-status = icon_unlocked.
      ENDIF.

** Sperren der OPBELS wieder aufheben
      CALL FUNCTION 'FKK_DEQ_OPBELS_AFTER_CHANGES'
        EXPORTING
          _scope          = '3'
          i_only_document = ' '.
**   <-- Nuss 09.2018

    ENDIF.
  ENDLOOP.
ENDFORM.                    " MAHNSPERRE_LOESCHEN
*&---------------------------------------------------------------------*
*&      Form  GET_CONSTANTS
*&---------------------------------------------------------------------*
FORM fill_selection_param.

*** >>> ET_20160308
* Customizing Tabelle Intervallgrenzen für Vertragskonten (/ADZ/hmv_ival)
  SELECT * FROM /adz/hmv_ival INTO TABLE t_hmv_ival.

* Aggregiertes VK
  LOOP AT t_hmv_ival INTO s_interval WHERE aktiv = 'X'.
*  READ TABLE t_hmv_ival INTO s_interval WITH KEY aktiv = 'X'.
    so_vkont-sign    = 'I'.
    so_vkont-option  = 'BT'.
    so_vkont-low     = s_interval-fromnumber.
    so_vkont-high    = s_interval-tonumber.
    APPEND so_vkont.
  ENDLOOP.

* Mahnsperrgrund
  pa_lockr         = c_lockr.

* Mahnsperren
  IF c_mansp = ' '.
    c_mansp = '*'.
  ENDIF.
  so_mansp         = c_mansp.

* Mahnverfahren
* --> Nuss 05.03.2018
  SELECT * FROM /adz/hmv_mver INTO TABLE t_hmv_mver.
  LOOP AT t_hmv_mver INTO s_hmv_mver WHERE aktiv = 'X'.
    so_mahnv-sign = 'I'.
    so_mahnv-option = 'EQ'.
    so_mahnv-low = s_hmv_mver-mahnv.
    APPEND so_mahnv.
    CLEAR s_hmv_mver.
  ENDLOOP.
*  so_mahnv-sign    = 'I'.
*  so_mahnv-option  = 'EQ'.
*  so_mahnv-low     = c_mahnv.
*  APPEND so_mahnv.
* <-- Nuss 05.03.2018

* Fälligkeitsdatum von bis...
  IF c_faedn_to IS INITIAL.
    c_faedn_to = 0.
  ENDIF.

  so_faedn-sign    = 'I'.
  so_faedn-option  = 'BT'.
  so_faedn-low     = c_faedn_from.
  so_faedn-high    = sy-datum - c_faedn_to.
  APPEND so_faedn.
*** <<< ET_20160308
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_T_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_t_out TABLES pt_out STRUCTURE /adz/hmv_s_out_dunning.

  DATA: ls_pod_rel       TYPE /idxgc/pod_rel,
        lt_pod_rel       TYPE STANDARD TABLE OF /idxgc/pod_rel,
        ls_euitrans      TYPE euitrans,
        ls_out           TYPE /adz/hmv_s_out_dunning,
        lv_tabix         TYPE sy-tabix,
        ls_euitrans_help TYPE euitrans.              "Nuss 25.01.2018


  LOOP AT pt_out INTO ls_out.

    lv_tabix = sy-tabix.

    IF ls_out-int_ui IS NOT INITIAL.
      SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
        WHERE int_ui2 = ls_out-int_ui.
      IF sy-subrc = 0.
        READ TABLE lt_pod_rel INTO ls_pod_rel INDEX 1.
        SELECT SINGLE * FROM euitrans INTO ls_euitrans
          WHERE int_ui = ls_pod_rel-int_ui1.

        MOVE ls_pod_rel-int_ui1 TO ls_out-int_ui_melo.
        MOVE ls_euitrans-ext_ui TO ls_out-ext_ui_melo.

        MODIFY  pt_out FROM ls_out INDEX lv_tabix.

      ENDIF.
    ELSE.
**    --> Nuss 25.01.2018
      IF ls_out-ext_ui IS NOT INITIAL.
        CLEAR ls_euitrans_help.
        SELECT SINGLE * FROM euitrans INTO ls_euitrans_help
          WHERE ext_ui = ls_out-ext_ui.
        CHECK sy-subrc = 0.
        MOVE ls_euitrans_help-int_ui TO ls_out-int_ui.
        SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
          WHERE int_ui2 = ls_out-int_ui.
        IF sy-subrc = 0.
          READ TABLE lt_pod_rel INTO ls_pod_rel INDEX 1.
          SELECT SINGLE * FROM euitrans INTO ls_euitrans
            WHERE int_ui = ls_pod_rel-int_ui1.

          MOVE ls_pod_rel-int_ui1 TO ls_out-int_ui_melo.
          MOVE ls_euitrans-ext_ui TO ls_out-ext_ui_melo.

          MODIFY  pt_out FROM ls_out INDEX lv_tabix.

        ENDIF.
      ENDIF.
**    <-- Nuss 25.01.2018
    ENDIF.

  ENDLOOP.

ENDFORM.
