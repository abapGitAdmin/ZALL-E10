CLASS /adesso/cl_hmv_idoc_stat_class DEFINITION  PUBLIC  FINAL.

  PUBLIC SECTION.

    TYPES:
      tt_datum_type TYPE /adesso/hmv_t_sel_tab_datum,
      tt_serv_type  TYPE /adesso/hmv_t_sel_tab_serv,
      tt_intui_type TYPE /adesso/hmv_t_sel_tab_intui,
      tt_serve_type TYPE /adesso/hmv_t_sel_tab_serve.

    TYPES:  tt_taski_type TYPE RANGE OF edextaskidoc-dextaskid.

* Neue Ausgabetabelle/Struktur für Komponenten aus DFKKTHI & MEMI-DOC.
    TYPES tt_dfkkthi_memi_out TYPE STANDARD TABLE OF /adesso/hmv_s_memi_out.
    TYPES dfkkthi_memi_out    TYPE /adesso/hmv_s_memi_out.
    METHODS:
      constructor IMPORTING
                    VALUE(is_const)     TYPE /adesso/hmv_s_idoc_const
                    VALUE(is_selparams) TYPE /adesso/hmv_s_idoc_sel_params,

      main EXPORTING et_alv_grid_data TYPE /adesso/hmv_t_memi_out
                     es_stats         TYPE /adesso/hmv_idoc,

      set_output_data IMPORTING it_alv_grid_data TYPE /adesso/hmv_t_memi_out,
      add_statistics
        IMPORTING is_sta1 TYPE /adesso/hmv_idoc
        CHANGING  cs_sta2 TYPE /adesso/hmv_idoc,
      write_stats
        CHANGING cs_stats TYPE /adesso/hmv_idoc,
      show_data IMPORTING
                  it_alv_grid_data TYPE /adesso/hmv_t_memi_out
                  is_stats         TYPE /adesso/hmv_idoc.
  PRIVATE SECTION.
    DATA  ms_const  TYPE /adesso/hmv_s_idoc_const.
    DATA  ms_rng_so_datum TYPE /adesso/hmv_s_sel_tab_datum.

*   Selektionsvariablen
    DATA:
      my_so_bukrs     TYPE RANGE OF bukrs,
      my_so_datum     TYPE RANGE OF e_dexaedat,
      my_so_serv      TYPE RANGE OF e_dexservprovself,
      my_update_flag  TYPE          char1,
      my_updmmm_flag  TYPE          char1,
      my_updmsb_flag  TYPE          char1,                   "Nuss 09.2018
      my_statlst_flag TYPE          char1 VALUE space,
      my_so_taski     TYPE RANGE OF e_dextaskid,
      my_so_intui     TYPE RANGE OF int_ui,
      my_so_serve     TYPE RANGE OF e_dexservprov,
      mv_rng_so_datum TYPE /adesso/cl_hmv_customizing=>ty_ab_bis.

*  DFKKTHI-Type
    TYPES:
      BEGIN OF type_dfkkthi,
        opbel           TYPE opbel_kk,
        opupw           TYPE opupw_kk,
        opupk           TYPE opupk_kk,
        opupz           TYPE opupz_kk,
        thinr           TYPE thinr_kk,
        bukrs           TYPE bukrs,
        thist           TYPE thist_kk,
        storn           TYPE storn_kk,
        stidc           TYPE stidc_kk,
        thidt           TYPE thidt_kk,
        thprd           TYPE thprd_kk,
        bcbln           TYPE bcbln_kk,
        senid           TYPE e_dexservprovself,
        recid           TYPE e_dexservprov,
        waers           TYPE blwae_kk,
        betrw           TYPE betrw_kk,
        crsrf           TYPE int_crossrefno,
        intui           TYPE int_ui,
        idocin          TYPE /adesso/hmv_idocin,
        statin          TYPE /adesso/hmv_statin,
        idocct          TYPE /adesso/hmv_idocct,
        statct          TYPE /adesso/hmv_statct,
        dexproc         TYPE e_dexproc,
        dexidocsent     TYPE e_dexidocsent,
        dexidocsend     TYPE e_dexidocsend,
        dexservprovself TYPE e_dexservprovself,
        dexidocsendcat  TYPE e_dexidocsendcat,
      END OF type_dfkkthi.

    DATA:
      it_dfkkthi TYPE TABLE OF type_dfkkthi,
      s_dfkkthi  TYPE          type_dfkkthi.


*MEMIDOC-Type (/IDXMM/S_MEMI_DATA)
    TYPES:
      BEGIN OF type_memidoc,
        doc_id              TYPE /idxmm/de_doc_id,
        doc_status          TYPE /idxmm/de_doc_status,
        creation_process    TYPE /idxmm/de_creation_process,   "Erstellungsprozess
        int_pod             TYPE int_ui,                       "Interner Zählpunkt
        dist_sp             TYPE eideserprov_dist,             "SP VNB
        suppl_sp            TYPE service_prov,                 "SP
        company_code        TYPE bukrs,
        reversal            TYPE /idxmm/de_reversal,            "Stornierung('X') oder nicht('')?
        reverse_charge_type TYPE /idxmm/de_reverse_charge_type, "Art des Reverse-Charge-Verfahrens (01 - 03)
        reversal_doc_id     TYPE /idxmm/de_reversal_doc_id,     "Stornobeleg-ID
        reversal_status     TYPE /idxmm/de_reversal_status,     "Stornostatus
        due_date            TYPE /idxmm/de_due_date,            "Fälligkeitsdatum
        aedat               TYPE aedat,                         "Datum der letzten Änderung
        inv_send_date       TYPE /idxmm/de_inv_send_date,
        gross_amount        TYPE /idxmm/de_gross_amount,
        currency            TYPE /idxmm/de_currency,
        crossrefno          TYPE crossrefno,                   "IDE: Crossreferenznummer
        invoic_idoc         TYPE /idxmm/de_invoic_idoc,         "IDoc-Nummer für INVOIC-Nachricht
        ci_invoic_doc_no    TYPE invdocno_kk,                  "Nummer des Fakturierungsbelegs (Faktur.beleg)
        ci_fica_doc_no      TYPE opbel_kk,                     "Nummer eines Belegs des Vertragskontokorrents (Belegnr)
        remadv_idoc         TYPE /idxmm/de_remadv_idoc,         "IDoc-Nummer für REMADV-Nachricht
        settle_measure_unit TYPE /idxmm/de_settle_measure_unit,
        inv_doc_no          TYPE inv_int_inv_doc_no,           "Interne Nummer des Rechnungsbelegs/Avisbelegs
        pdoc_ref            TYPE /idxgc/de_proc_ref,            "Dynamische Prozessreferenz
        pdoc_ref_mass       TYPE /idxgc/de_proc_ref,
        suppl_bupa          TYPE bu_partner,
        suppl_contr_acct    TYPE vkont_kk,
        stidc               TYPE stidc_kk,                     "XFELD Storno
        idocin              TYPE /adesso/hmv_idocin,
        statin              TYPE /adesso/hmv_statin,
        idocct              TYPE /adesso/hmv_idocct,
        statct              TYPE /adesso/hmv_statct,
        dexproc             TYPE e_dexproc,
        dexidocsent         TYPE e_dexidocsent,
        dexidocsend         TYPE e_dexidocsend,
        dexservprovself     TYPE e_dexservprovself,
        dexidocsendcat      TYPE e_dexidocsendcat,
      END OF type_memidoc.

    DATA:
      it_memidoc TYPE TABLE OF type_memidoc,
      s_memidoc  TYPE          type_memidoc.

* --> Nuss 09.2018
    TYPES:
      BEGIN OF type_msbdoc,
        invdocno            TYPE invdocno_kk,
        /mosb/ld_malo_i     TYPE /mosb/de_int_ui_malo,
        /mosb/ld_malo_e     TYPE /mosb/de_ext_ui_malo,
        /mosb/mo_sp         TYPE /mosb/de_mo_sp,
        /mosb/lead_sup      TYPE /mosb/de_leading_sup,
        bukrs               TYPE bukrs,
        faedn               TYPE faedn_kk,
        crdate              TYPE invdoc_crdat_kk,
        total_curr          TYPE blwae_kk,
        total_amt           TYPE betrw_kk,
        /mosb/inv_doc_ident TYPE /idxgc/de_document_ident,
        opbel               TYPE opbel_kk,

        idocin              TYPE /adesso/hmv_idocin,
        statin              TYPE /adesso/hmv_statin,
        idocct              TYPE /adesso/hmv_idocct,
        statct              TYPE /adesso/hmv_statct,
        dexproc             TYPE e_dexproc,
        dexidocsent         TYPE e_dexidocsent,
        dexidocsend         TYPE e_dexidocsend,
        dexservprovself     TYPE e_dexservprovself,
        dexidocsendcat      TYPE e_dexidocsendcat,

      END OF type_msbdoc.

    DATA:
      mt_msbdoc TYPE TABLE OF type_msbdoc,
      s_msbdoc  TYPE          type_msbdoc.

* <-- Nuss 09.2018

* Struktur IDoc-Versandstatus-Ermittlung
    TYPES:
      BEGIN OF ty_edexdefserprov,
        dexservprov     TYPE e_dexservprov,
        dexproc         TYPE e_dexproc,
        dexservprovself TYPE e_dexservprovself,
        dexidocsent     TYPE e_dexidocsent,
        dexidocsend     TYPE e_dexidocsend,
        dexidocsendcat  TYPE e_dexidocsendcat,
      END OF ty_edexdefserprov.

    DATA: mt_edexdefserprov  TYPE TABLE OF ty_edexdefserprov,
          ls_edexdefservprov TYPE ty_edexdefserprov.

    DATA:
      l_date TYPE edextask-dexaedat,
      l_from TYPE edextask-dexaedat,
      l_to   TYPE edextask-dexaedat.

    TYPES:
      BEGIN OF ty_edidc,
        docnum      TYPE edi_docnum,
        idoc_status TYPE edi_status,
      END OF ty_edidc.

    DATA:
      mt_output TYPE  tt_dfkkthi_memi_out,
      s_output  TYPE  LINE OF tt_dfkkthi_memi_out.

*  Statistik im Header

*   EDI-Segmentname
    DATA:
      t_edi_segnam TYPE /adesso/hmv_rt_segn,
      s_edi_segnam TYPE /adesso/hmv_rs_segn.

*   Datenaustauschprozesse
    DATA:
      t_dexproc TYPE /adesso/hmv_rt_xpro,
      s_dexproc TYPE /adesso/hmv_rs_xpro.

*     Ecrossrefno
    TYPES:
      BEGIN OF type_ecrossrefno,
        int_crossrefno TYPE int_crossrefno,
        stidc          TYPE stidc_kk,   "Herkunft Storno
        docnum         TYPE edi_docnum,
        int_ui         TYPE int_ui,
        keydate        TYPE endabrpe,
        crossrefno(35) TYPE c, "har35, e1vdewbgm_1-documentnumber,
        abrdats        TYPE abrdats,
        cancel         TYPE kennzx,
        created_from   TYPE created_from, "M -> Mehr-/Mindermengenrechnung
        vertrag        TYPE vertrag,
        erdat          TYPE erdat,
        ernam          TYPE ernam,
        aedat          TYPE aedat,
        aenam          TYPE aenam,
        belnr          TYPE e_belnr,
        crn_rev        TYPE crossrefno,
      END OF type_ecrossrefno.

    DATA:
      mt_crsrf  TYPE TABLE OF type_ecrossrefno,
      mt_crsrf2 TYPE TABLE OF type_ecrossrefno,
      s_crsrf   TYPE          type_ecrossrefno.

*   IDocs
    TYPES:
      BEGIN OF type_idocs,
        docnum          TYPE edi_docnum,
        int_ui          TYPE int_ui,
        credat          TYPE edi_ccrdat,
        cretim          TYPE edi_ccrtim,
        dextaskid       TYPE e_dextaskid,
        dexduedate      TYPE e_dexduedate,
        dexrefdateto    TYPE e_dexrefdateto,
        dexaedat        TYPE e_dexaedat,
        dexproc         TYPE e_dexproc,
        dexstatus       TYPE e_dexstatus,
        dexservprov     TYPE e_dexservprov,       "dfkkthi-recid,
        dexservprovself TYPE e_dexservprovself,   "dfkkthi-senid,
        sent            TYPE e_dexidocsent,
        status          TYPE edi_status,          "edids-status,
      END OF type_idocs.

    DATA:
      mt_idocs TYPE TABLE OF type_idocs,
      s_idocs  TYPE          type_idocs.

    DATA:
      t_hmv_sart TYPE TABLE OF /adesso/hmv_sart,
      s_hmv_sart TYPE          /adesso/hmv_sart,
      r_status   TYPE          /adesso/hmv_rt_sart,
      s_status   TYPE          /adesso/hmv_rs_sart.

* IDoc Statussatz
    DATA:
      BEGIN OF s_edids,
        docnum TYPE edi_docnum,  "edids-docnum,
        status TYPE edi_status,  "edids-status,
      END OF s_edids.

    DATA: it_edids LIKE TABLE OF s_edids.

* EUITRANS (Transformation interne/externe Zählpunktnummer)
    DATA:
      mt_euitrans TYPE TABLE OF euitrans,
      s_euitrans  TYPE          euitrans.

* EDID4 (IDoc-Datensätze ab 4.0)
    DATA:
      mt_edid4 TYPE TABLE OF edid4,
      s_edid4  TYPE          edid4.

    TYPES:
      BEGIN OF type_edid4_s,
        docnum     TYPE edi_docnum,
        crossrefno TYPE crossrefno,
      END OF type_edid4_s.

    DATA:
      mt_edid4_s    TYPE TABLE OF type_edid4_s,
      mt_edid4_c    TYPE SORTED TABLE OF type_edid4_s WITH NON-UNIQUE KEY docnum crossrefno,
      s_edid4_s     TYPE type_edid4_s,
      s_e1vdewbgm_1 TYPE e1vdewbgm_1,
      s_bgm_general TYPE REF TO data.

*    DATA:
*      lv_dyn TYPE REF TO data.

    DATA:
      mt_fieldcat   TYPE slis_t_fieldcat_alv,
      s_fieldcat    TYPE slis_fieldcat_alv,
      s_layout      TYPE slis_layout_alv,
      mt_event      TYPE slis_t_event,
      s_listheader  TYPE slis_listheader,
      mt_listheader TYPE slis_t_listheader,
      s_event       TYPE slis_alv_event.

    DATA:
      x_updok          TYPE i,
      x_upder          TYPE i,

* <<<ET_20160229
* Update-Zähler MEMIDOC
      c_lines_memi(10) TYPE c,
      x_lines_memi     TYPE i,
      x_upd_memi_ok    TYPE i,
      x_upd_memi_er    TYPE i,
      xsart            TYPE /adesso/hmv_sart.
* >>>ET_20160229


* Update Zähler MSB-Doc
* -->Nuss 09.2018
    DATA: c_lines_msb(10) TYPE c,
          x_lines_msb     TYPE i,
          x_upd_msb_ok    TYPE i,
          x_upd_msb_er    TYPE i.
* -- Nuss 09.2018


    DATA: lt_constant TYPE TABLE OF /adesso/hmv_cons,
          ls_constant TYPE          /adesso/hmv_cons.


    METHODS:
      build_header RETURNING VALUE(r_header)    TYPE slis_t_listheader,
      get_dexproc,
*      get_edexdefservprov,
      get_idocs,
      get_euitrans,
      get_edid4,
      get_crsrf,
      get_dfkkthi,
      get_memidoc,
      get_msbdoc,                      "Nuss 09.2018
      fill_internal_table,
      get_statistics CHANGING cs_stats TYPE /adesso/hmv_idoc,
      update_stats_with_selvar   CHANGING cs_sta TYPE /adesso/hmv_idoc,
      output_alv     IMPORTING     is_stats         TYPE /adesso/hmv_idoc OPTIONAL ,
      build_fieldcat RETURNING VALUE(r_fieldcat) TYPE slis_t_fieldcat_alv,
      build_layout   RETURNING VALUE(r_layout)   TYPE slis_layout_alv,
      set_events     RETURNING VALUE(r_event)    TYPE slis_t_event,
      update_dfkkthi,
      update_memidoc,
      update_msbdoc.
ENDCLASS.



CLASS /adesso/cl_hmv_idoc_stat_class IMPLEMENTATION.

  METHOD set_output_data.
    mt_output = it_alv_grid_data.
  ENDMETHOD.

  METHOD build_fieldcat.
    DATA pos TYPE i VALUE 0.

    IF my_statlst_flag = space.
* Status
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STATUS'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-key         = 'X'.
      s_fieldcat-seltext_s   = 'St'.
      s_fieldcat-seltext_m   = 'Stat'.
      s_fieldcat-seltext_l   = 'Status'.
      s_fieldcat-icon        = 'X'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Kennzeichen zur Herkunft: D oder M
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'KENNZ'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-key         = 'X'.
      s_fieldcat-seltext_s   = 'Kz.'.
      s_fieldcat-seltext_m   = 'Kz.Herkunft'.
      s_fieldcat-seltext_l   = 'Kennzeichen Herkunft'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Belegnummer
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'OPBEL'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-key         = 'X'.
      s_fieldcat-seltext_s   = 'Belnr.'.
      s_fieldcat-seltext_m   = 'Belegnr.'.
      s_fieldcat-seltext_l   = 'Belegnummer'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Buchungskreis
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'BUKRS'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'BUKRS'.
      s_fieldcat-seltext_m   = 'Buchungskr.'.
      s_fieldcat-seltext_l   = 'Buchungskreis'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Status des Eintrags
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'THIST'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_m   = 'Status'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Beleg wurde storniert
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STORN'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_m   = 'Storno'.
      s_fieldcat-seltext_l   = 'Beleg storniert'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Herkunft des Eintrags ist Storno
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STIDC'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Hrkft.St.'.
      s_fieldcat-seltext_m   = 'Herkunft.St.'.
      s_fieldcat-seltext_l   = 'Herkunft Storno'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Fälligkeitsdatum der Übertragung an einen Dritten
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'THIDT'.     "FAEDN_KK
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'F.Dat.'.
      s_fieldcat-seltext_m   = 'Fäll.Dat.'.
      s_fieldcat-seltext_l   = 'Fälligkeitsdatum'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Ist-Datum der Übertragung an einen Dritten
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'THPRD'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Ist-Dat.'.
      s_fieldcat-seltext_m   = 'Ist Datum'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Belegnummer der Buchung auf das Serviceanbieter-Konto
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'BCBLN'.       "CI_FICA_DOC_NO
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'BelNr. SP'.
      s_fieldcat-seltext_m   = 'BelNr. Servprov.'.
      s_fieldcat-seltext_m   = 'Belegnummer Servprov.'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Interne bezeichnung des rechnungs-/avissenders
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'SENID'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_m   = 'Avissender'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Interne Bezeichnung des Rechnung-/Avisempfängers
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'RECID'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'A-Empf.'.
      s_fieldcat-seltext_m   = 'Avisempf.'.
      s_fieldcat-seltext_l   = 'Avisempfänger.'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Transaktionswährung
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'WAERS'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_m   = 'Waers'.
      s_fieldcat-seltext_l   = 'Währung'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Betrag in Transaktionswährung mit Vorzeichen
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'BETRW'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-currency    = 'EUR'.
      s_fieldcat-seltext_m   = 'Betrag'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IDE: Interne Cross Referenznummer
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'CRSRF'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'CRSRF'.
      s_fieldcat-seltext_m   = 'Crossref'.
      s_fieldcat-seltext_l   = 'Crossrefno'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Interner Schlüssel des Zählpunkts
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'INTUI'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Int.ZP'.
      s_fieldcat-seltext_m   = 'Interner ZP'.
      s_fieldcat-seltext_l   = 'Interner Zählpunkt'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IDE: Crossreferenznummer
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'OWNRF'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'IDE:Crsrf'.
      s_fieldcat-seltext_m   = 'IDE:Crossref'.
      s_fieldcat-seltext_l   = 'IDE:Crossrefno'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat."
*  Datum der letzten Änderung
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DEXAEDAT'.
      s_fieldcat-seltext_s   = 'Änd.'.
      s_fieldcat-seltext_m   = 'Geändert am'.
      s_fieldcat-seltext_l   = 'Zuletzt geändert am'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-ref_tabname = 'EDEXTASK'.
      s_fieldcat-no_out      = 'X'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* INVOIC
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'IDOCIN'.
      s_fieldcat-seltext_s   = 'Nr.INV'.
      s_fieldcat-seltext_m   = 'Nr.Invoic'.
      s_fieldcat-seltext_l   = 'Nr. Invoic'.
      s_fieldcat-emphasize   = 'C30'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Status INVOIC
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STATIN_LED'.
      s_fieldcat-seltext_s   = 'INV'.
      s_fieldcat-seltext_m   = 'St.INV'.
      s_fieldcat-seltext_l   = 'Status Invoice'.
      s_fieldcat-emphasize   = 'C30'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* CONTROL
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'IDOCCT'.
      s_fieldcat-seltext_s   = 'Nr.CT'.
      s_fieldcat-seltext_m   = 'Nr.Control'.
      s_fieldcat-seltext_l   = 'Nr. Control'.
      s_fieldcat-emphasize   = 'C30'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Status CONTROL
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STATCT_LED'.
      s_fieldcat-seltext_s   = 'CT'.
      s_fieldcat-seltext_m   = 'Stat.CTRL'.
      s_fieldcat-seltext_l   = 'St.Control'.
      s_fieldcat-emphasize   = 'C30'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* Externer Zählpunkt
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'EXT_UI'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'ext.ZP'.
      s_fieldcat-seltext_m   = 'ext.ZP-Bez'.
      s_fieldcat-seltext_l   = 'ext.Zählpunktbezeichnung'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IDoc-Stautus aus Tabelle EDIDC
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DOC_STATUS'.          "10 bis 86
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Rück.St.'.
      s_fieldcat-seltext_m   = 'Statusrückm.'.
      s_fieldcat-seltext_l   = 'Statusrückmeldung'.
      s_fieldcat-ref_tabname = '/IDXMM/MEMIDOC'.
      s_fieldcat-ref_fieldname = 'DOC_STATUS'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* EDIDS Status invoice
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STATUS_I'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Stat i'.
      s_fieldcat-seltext_m   = 'Status i'.
      s_fieldcat-seltext_l   = 'Status i'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* EDIDS Status ctrl
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'STATUS_C'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'Stat c'.
      s_fieldcat-seltext_m   = 'Status c'.
      s_fieldcat-seltext_l   = 'Status c'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.

* IT_OUTPUT DEXIDOCSENT
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DEXIDOCSENT'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'SINV'.
      s_fieldcat-seltext_m   = 'SENTINV'.
      s_fieldcat-seltext_l   = 'SENTINVOICE'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IT_OUTPUT DEXIDOCSENTCTRL
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DEXIDOCSENTCTRL'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'SCTRL'.
      s_fieldcat-seltext_m   = 'SENTCTRL'.
      s_fieldcat-seltext_l   = 'SENTCONTROL'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IT_OUTPUT DEXIDOCSENDCAT
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DEXIDOCSENDCAT'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'CAT'.
      s_fieldcat-seltext_m   = 'SENDCAT'.
      s_fieldcat-seltext_l   = 'DEXIDOCSENDCAT'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
* IT_OUTPUT DEXPROC
      CLEAR s_fieldcat.
      s_fieldcat-fieldname   = 'DEXPROC'.
      s_fieldcat-tabname     = 'IT_OUTPUT'.
      s_fieldcat-seltext_s   = 'XPROC'.
      s_fieldcat-seltext_m   = 'DEXPROC'.
      s_fieldcat-seltext_l   = 'DEXPROC'.
      s_fieldcat-ref_tabname = 'DFKKTHI'.
      s_fieldcat-col_pos     = pos = pos + 1.
      APPEND s_fieldcat TO r_fieldcat.
    ELSE.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_program_name         = ms_const-repid
          i_client_never_display = 'X'
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = r_fieldcat
        EXCEPTIONS
          OTHERS                 = 0.
    ENDIF.
  ENDMETHOD.                    "build_fieldcat


  METHOD build_header.
    DATA  c_lines(10)      TYPE c.
    DATA  x_lines          TYPE i.


    REFRESH: r_header.
* <<< ET_20160229
* Gesamtstatistik
    DESCRIBE TABLE it_dfkkthi LINES x_lines.
    ADD x_lines TO c_lines.
    DESCRIBE TABLE it_memidoc LINES x_lines.
    ADD x_lines TO c_lines.
* --> Nuss 09.2018
    DESCRIBE TABLE mt_msbdoc LINES x_lines.
    ADD x_lines TO c_lines.
* <-- Nuss 09.2018

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = c_lines.
    s_listheader-info = TEXT-003.
    APPEND s_listheader TO r_header.

* DFKKTHI Statistik
    CLEAR: c_lines, x_lines.
    DESCRIBE TABLE it_dfkkthi LINES x_lines.
    WRITE x_lines TO c_lines.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = c_lines.
    s_listheader-info = TEXT-004.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_updok.
    s_listheader-info = TEXT-005.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_upder.
    s_listheader-info = TEXT-006.
    APPEND s_listheader TO r_header.

* MEMIDOC Statistik
    CLEAR: c_lines, x_lines.
    DESCRIBE TABLE it_memidoc LINES x_lines.
    WRITE x_lines TO c_lines.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = c_lines.
    s_listheader-info = TEXT-011.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_upd_memi_ok.
    s_listheader-info = TEXT-012.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_upd_memi_er.
    s_listheader-info = TEXT-013.
    APPEND s_listheader TO r_header.
* >>>ET_20160229


** --> Nuss 09.2018
    CLEAR: c_lines, x_lines.
    DESCRIBE TABLE mt_msbdoc LINES x_lines.
    WRITE x_lines TO c_lines.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = c_lines.
    s_listheader-info = TEXT-014.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_upd_msb_ok.
    s_listheader-info = TEXT-015.
    APPEND s_listheader TO r_header.

    CLEAR: s_listheader.
    s_listheader-typ  = ms_const-c_listheader_typ.
    s_listheader-key  = x_upd_msb_er.
    s_listheader-info = TEXT-016.
    APPEND s_listheader TO r_header.
* <-- Nuss 09.2018

  ENDMETHOD.                    "build_header


  METHOD build_layout.
* Layout
    r_layout-zebra             = 'X'.
    r_layout-colwidth_optimize = 'X'.
  ENDMETHOD.                    "build_layout


  METHOD constructor.
    CLEAR:
    my_so_datum,
    my_so_serv,
    my_so_intui,
    my_so_serve.

    MOVE-CORRESPONDING is_const TO ms_const.
    my_so_datum    = is_selparams-so_datum.
    my_so_serv     = is_selparams-so_serv.
    my_update_flag = is_selparams-p_upd_dfk.
    my_updmmm_flag = is_selparams-p_upd_memi.
    my_updmsb_flag = is_selparams-p_upd_msb.          "Nuss 09.2018
    my_so_intui    = is_selparams-so_intui.
    my_so_serve    = is_selparams-so_serve.

    LOOP AT is_selparams-so_datum INTO ms_rng_so_datum.
      EXIT. "take the first.
    ENDLOOP..

    CLEAR: my_so_taski.
    my_so_taski     = is_selparams-so_taskid.
    my_statlst_flag = is_selparams-p_statistics.
  ENDMETHOD.                    "constructor


  METHOD fill_internal_table.
    DATA:
      h_e1vdewbgm_1 TYPE e1vdewbgm_1,
      x_tabix       TYPE sy-tabix,
      x_sdata       TYPE edid4-sdata,
      wa_edids      TYPE edids,
      waa_edids     TYPE edids.

    FIELD-SYMBOLS:
      <s_dfkkthi>      TYPE type_dfkkthi,
      <s_memidoc>      TYPE type_memidoc,
      <s_msbdoc>       TYPE type_msbdoc,            "Nuss 09.2018
      <f_euitrans>     TYPE euitrans,
      <f_crsrf>        TYPE type_ecrossrefno,
      <f_idocs>        TYPE type_idocs,
      <f_edids>        LIKE s_edids,
      <fs_output>      TYPE LINE OF tt_dfkkthi_memi_out,
      <fs_defservprov> TYPE ty_edexdefserprov.

*    CREATE OBJECT gr_hmv_cust.

************************************************* Loop über MEMIDOC (interne Tabelle) *************************************************
    LOOP AT it_memidoc ASSIGNING <s_memidoc>.

      s_output-kennz = /idxmm/if_constants=>gc_createdfrom_m.

      MOVE <s_memidoc>-doc_id           TO s_output-opbel.
      MOVE <s_memidoc>-company_code     TO s_output-bukrs.
      MOVE <s_memidoc>-crossrefno       TO s_output-ownrf.
      MOVE <s_memidoc>-int_pod          TO s_output-intui.
      MOVE <s_memidoc>-dist_sp          TO s_output-senid.
      MOVE <s_memidoc>-suppl_sp         TO s_output-recid.
      MOVE <s_memidoc>-currency         TO s_output-waers.
      MOVE <s_memidoc>-gross_amount     TO s_output-betrw.
      MOVE <s_memidoc>-due_date         TO s_output-thidt.
      MOVE <s_memidoc>-invoic_idoc      TO s_output-idocin.
      MOVE <s_memidoc>-ci_fica_doc_no   TO s_output-bcbln.
      MOVE <s_memidoc>-inv_send_date    TO s_output-thprd.
      MOVE <s_memidoc>-doc_status       TO s_output-doc_status.
      MOVE <s_memidoc>-aedat            TO s_output-dexaedat.
      MOVE <s_memidoc>-suppl_bupa       TO s_output-suppl_bupa.
      MOVE <s_memidoc>-suppl_contr_acct TO s_output-suppl_contr_acct.

*   Zählpunktnummer
      READ TABLE mt_euitrans ASSIGNING <f_euitrans>
        WITH KEY int_ui = <s_memidoc>-int_pod
        BINARY SEARCH.
      IF sy-subrc = 0 AND <f_euitrans> IS ASSIGNED.
        MOVE <f_euitrans>-ext_ui TO s_output-ext_ui.
      ENDIF.

*   Crossrefno (MMM+++)
      LOOP AT mt_crsrf ASSIGNING <f_crsrf>
        WHERE crossrefno = <s_memidoc>-crossrefno.

*   IDoc
        READ TABLE mt_idocs ASSIGNING <f_idocs>
          WITH KEY docnum = <f_crsrf>-docnum
                   int_ui     = s_output-intui
*                   dexduedate = s_output-thprd
                   BINARY SEARCH.


* <<< ET_20160309
* IDoc-Status fortschreiben
        IF sy-subrc = 0 AND <f_idocs> IS ASSIGNED.
*          s_output-status_i = <f_idocs>-status.
*          s_output-status_c = <f_idocs>-status.
*        ENDIF.
* >>> ET_20160309
          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <f_idocs>-dexduedate
              AND a~dateto   > <f_idocs>-dexduedate
              AND a~dexservprovself = <f_idocs>-dexservprovself
              AND a~dexservprov = <f_idocs>-dexservprov
              AND a~dexproc = <f_idocs>-dexproc.

*    Servprov
*          READ TABLE it_edexdefserprov ASSIGNING <fs_defservprov>
*            WITH KEY dexservprov     = <f_idocs>-dexservprov
*                     dexproc         = <f_idocs>-dexproc
*                     dexservprovself = <f_idocs>-dexservprovself
*                     BINARY SEARCH.

*     Status IDoc
          CLEAR: xsart, s_hmv_sart.
          LOOP AT t_hmv_sart INTO s_hmv_sart
            WHERE dexproc         = <f_idocs>-dexproc
              AND serviceanbieter = <f_idocs>-dexservprovself
              AND dexidocsent     = <f_idocs>-sent
              AND dexidocsendcat  = ls_edexdefservprov-dexidocsendcat
              AND datbi GE <f_idocs>-credat
              AND datab LE <f_idocs>-credat.
            s_output-dexproc         = s_hmv_sart-dexproc.
*            s_output-dexidocsent     = s_hmv_sart-dexidocsent.
*            s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
            s_output-dexidocsendcat  = s_hmv_sart-dexidocsendcat.
            xsart = s_hmv_sart.
          ENDLOOP.

          READ TABLE it_edids ASSIGNING <f_edids>
            WITH KEY docnum = <f_idocs>-docnum
                     status = xsart-status
                     BINARY SEARCH.

          IF sy-subrc = 0 AND <f_edids> IS ASSIGNED.
            IF xsart-inv = 'X'.
              s_output-idocin     = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led = icon_led_green.
              s_output-status_i   = <f_edids>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct     = <f_idocs>-docnum.
              s_output-dexidocsentctrl    = s_hmv_sart-dexidocsent.
              s_output-statct_led = icon_led_green.
              s_output-status_c   = <f_edids>-status.
            ENDIF.
          ELSE.
            IF xsart-inv = 'X'.
              s_output-idocin     = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led = icon_led_red.
              s_output-status_i   = <f_idocs>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct     = <f_idocs>-docnum.
              s_output-dexidocsentctrl     = s_hmv_sart-dexidocsent.
              s_output-statct_led = icon_led_red.
              s_output-status_c   = <f_idocs>-status.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <f_crsrf>-created_from EQ ms_const-c_invoice_status_03 OR
           <f_crsrf>-created_from EQ ms_const-c_invoice_status_04.
          s_output-stidc = 'X'.
        ENDIF.
      ENDLOOP.
      APPEND s_output TO mt_output.
    ENDLOOP.        "Loop MEMIDOC
************************************************************************** Loop über interne Tabelle DFKKTHI **************************************************************************

    LOOP AT it_dfkkthi ASSIGNING <s_dfkkthi>.
      CLEAR: s_output.

      s_output-kennz = ms_const-c_doc_kzd.

      MOVE-CORRESPONDING <s_dfkkthi> TO s_output.

*     Externe Zählpunktbezeichnung
      READ TABLE mt_euitrans ASSIGNING <f_euitrans>
         WITH KEY int_ui = <s_dfkkthi>-intui
         BINARY SEARCH.
      IF sy-subrc = 0 AND <f_euitrans> IS ASSIGNED.
        s_output-ext_ui = <f_euitrans>-ext_ui.
      ENDIF.

*     Crossrefno (PRN-Nummer)
      LOOP AT mt_crsrf ASSIGNING <f_crsrf>
        WHERE int_crossrefno = <s_dfkkthi>-crsrf
          AND stidc          = <s_dfkkthi>-stidc.
        s_output-ownrf       = <f_crsrf>-crossrefno.
        s_output-ownrf_s     = <f_crsrf>-crn_rev.

*     IDOC
        READ TABLE mt_idocs ASSIGNING <f_idocs>
          WITH KEY docnum     = <f_crsrf>-docnum
                   int_ui     = s_output-intui
                   dexduedate = s_output-thprd
                   BINARY SEARCH.

        IF sy-subrc = 0 AND <f_idocs> IS ASSIGNED.

          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <f_idocs>-dexduedate
              AND a~dateto   > <f_idocs>-dexduedate
              AND a~dexservprovself = <f_idocs>-dexservprovself
              AND a~dexservprov = <f_idocs>-dexservprov
              AND a~dexproc = <f_idocs>-dexproc.

*       Servprov
*          READ TABLE it_edexdefserprov ASSIGNING <fs_defservprov>
*            WITH KEY dexservprov     = <f_idocs>-dexservprov
*                     dexproc         = <f_idocs>-dexproc
*                     dexservprovself = <f_idocs>-dexservprovself
*                     BINARY SEARCH.

*       Status IDoc
          CLEAR: xsart, s_hmv_sart.
          LOOP AT t_hmv_sart INTO s_hmv_sart
            WHERE dexproc         = <f_idocs>-dexproc
              AND serviceanbieter = <f_idocs>-dexservprovself
              AND dexidocsent     = <f_idocs>-sent
              AND dexidocsendcat  = ls_edexdefservprov-dexidocsendcat
              AND datbi GE <f_idocs>-credat
              AND datab LE <f_idocs>-credat.
            s_output-dexproc         = s_hmv_sart-dexproc.
*            s_output-dexidocsent     = s_hmv_sart-dexidocsent.
*            s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
            s_output-dexidocsendcat  = s_hmv_sart-dexidocsendcat.
            xsart = s_hmv_sart.
          ENDLOOP.

          READ TABLE it_edids ASSIGNING <f_edids>
            WITH KEY docnum = <f_idocs>-docnum
                     status = xsart-status
                     BINARY SEARCH.

          IF sy-subrc = 0 AND <f_edids> IS ASSIGNED.
            IF xsart-inv  = 'X'.
              s_output-idocin = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led    = icon_led_green.
              s_output-status_i  = <f_edids>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct = <f_idocs>-docnum.
              s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
              s_output-statct_led    = icon_led_green.
              s_output-status_c  = <f_edids>-status.
            ENDIF.
          ELSE.
            IF xsart-inv  = 'X'.
              s_output-idocin = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led = icon_led_red.
              s_output-status_i   = <f_idocs>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct = <f_idocs>-docnum.
              s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
              s_output-statct_led = icon_led_red.
              s_output-status_c   = <f_idocs>-status.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      APPEND s_output TO mt_output.
    ENDLOOP.

** --> Nuss 09.2018
*******************************Loop über interne Tabelle MSBDOC**********************
    LOOP AT mt_msbdoc ASSIGNING <s_msbdoc>.

      CLEAR: s_output.

      s_output-kennz = 'I'.

      MOVE <s_msbdoc>-invdocno TO s_output-opbel.
      MOVE <s_msbdoc>-bukrs TO s_output-bukrs.
      MOVE <s_msbdoc>-/mosb/inv_doc_ident TO s_output-ownrf.
      MOVE <s_msbdoc>-/mosb/ld_malo_i TO s_output-intui.
      MOVE <s_msbdoc>-/mosb/ld_malo_e TO s_output-ext_ui.
      MOVE <s_msbdoc>-/mosb/mo_sp TO s_output-senid.
      MOVE <s_msbdoc>-/mosb/lead_sup  TO s_output-recid.
      MOVE <s_msbdoc>-total_curr  TO s_output-waers.
      MOVE <s_msbdoc>-total_amt TO s_output-betrw.
      MOVE <s_msbdoc>-faedn TO s_output-thidt.
      MOVE <s_msbdoc>-crdate TO s_output-thprd.
      MOVE <s_msbdoc>-opbel TO s_output-bcbln.

*     Crossrefno (msb)
      LOOP AT mt_crsrf ASSIGNING <f_crsrf>
        WHERE crossrefno = <s_msbdoc>-/mosb/inv_doc_ident.
*     IDOC
        READ TABLE mt_idocs ASSIGNING <f_idocs>
          WITH KEY docnum     = <f_crsrf>-docnum
                   int_ui     = s_output-intui
*                   dexduedate = s_output-thprd
                   BINARY SEARCH.

        IF sy-subrc = 0 AND <f_idocs> IS ASSIGNED.

          CLEAR: ls_edexdefservprov.
          SELECT SINGLE a~dexproc a~dexidocsend a~dexservprovself
                 a~dexservprov b~dexidocsendcat
            FROM edexdefservprov AS a
         "Join mit Tabelle EDEXIDOCSEND
            JOIN edexidocsend AS b
              ON a~dexidocsend = b~dexidocsend
            INTO CORRESPONDING FIELDS OF ls_edexdefservprov
            WHERE a~datefrom < <f_idocs>-dexduedate
              AND a~dateto   > <f_idocs>-dexduedate
              AND a~dexservprovself = <f_idocs>-dexservprovself
              AND a~dexservprov = <f_idocs>-dexservprov
              AND a~dexproc = <f_idocs>-dexproc.

*       Status IDoc
          CLEAR: xsart, s_hmv_sart.
          LOOP AT t_hmv_sart INTO s_hmv_sart
            WHERE dexproc         = <f_idocs>-dexproc
              AND serviceanbieter = <f_idocs>-dexservprovself
              AND dexidocsent     = <f_idocs>-sent
              AND dexidocsendcat  = ls_edexdefservprov-dexidocsendcat
              AND datbi GE <f_idocs>-credat
              AND datab LE <f_idocs>-credat.
            s_output-dexproc         = s_hmv_sart-dexproc.
*            s_output-dexidocsent     = s_hmv_sart-dexidocsent.
*            s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
            s_output-dexidocsendcat  = s_hmv_sart-dexidocsendcat.
            xsart = s_hmv_sart.
          ENDLOOP.

          READ TABLE it_edids ASSIGNING <f_edids>
              WITH KEY docnum = <f_idocs>-docnum
                      status = xsart-status
             BINARY SEARCH.

          IF sy-subrc = 0 AND <f_edids> IS ASSIGNED.
            IF xsart-inv  = 'X'.
              s_output-idocin = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led    = icon_led_green.
              s_output-status_i  = <f_edids>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct = <f_idocs>-docnum.
              s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
              s_output-statct_led    = icon_led_green.
              s_output-status_c  = <f_edids>-status.
            ENDIF.
          ELSE.
            IF xsart-inv  = 'X'.
              s_output-idocin = <f_idocs>-docnum.
              s_output-dexidocsent     = s_hmv_sart-dexidocsent.
              s_output-statin_led = icon_led_red.
              s_output-status_i   = <f_idocs>-status.
            ENDIF.
            IF xsart-ctrl = 'X'.
              s_output-idocct = <f_idocs>-docnum.
              s_output-dexidocsentctrl = s_hmv_sart-dexidocsent.
              s_output-statct_led = icon_led_red.
              s_output-status_c   = <f_idocs>-status.
            ENDIF.
          ENDIF.

        ENDIF.
      ENDLOOP.
      APPEND s_output TO mt_output.
    ENDLOOP.
** <-- Nuss 09.2018
  ENDMETHOD.                  "fill_internal_table


  METHOD get_crsrf.
* Referenznummer IDoc (Crossrefno)
    FIELD-SYMBOLS: <s_edid4_s> TYPE type_edid4_s.

    SORT mt_idocs BY int_ui.
    LOOP AT mt_edid4_s ASSIGNING <s_edid4_s>.
      "   !erst Rechnungen (wg Index)
      SELECT * FROM ecrossrefno INTO CORRESPONDING FIELDS OF s_crsrf
             WHERE crossrefno = <s_edid4_s>-crossrefno
                OR crn_rev    = <s_edid4_s>-docnum.
        READ TABLE mt_idocs TRANSPORTING NO FIELDS
             WITH KEY int_ui = s_crsrf-int_ui
             BINARY SEARCH.
        IF sy-subrc = 0.
          s_crsrf-docnum = <s_edid4_s>-docnum.
          APPEND s_crsrf TO mt_crsrf.
        ENDIF.
        CLEAR s_crsrf.
      ENDSELECT.
      "    dann Stornos (wg Index)
      SELECT * FROM ecrossrefno
            INTO CORRESPONDING FIELDS OF s_crsrf
            WHERE crn_rev = <s_edid4_s>-crossrefno.
        READ TABLE mt_idocs TRANSPORTING NO FIELDS
          WITH KEY int_ui = s_crsrf-int_ui
          BINARY SEARCH.
        IF sy-subrc = 0.
          s_crsrf-docnum = <s_edid4_s>-docnum.
          s_crsrf-stidc = 'X'.
          APPEND s_crsrf TO mt_crsrf.
        ENDIF.
        CLEAR s_crsrf.
      ENDSELECT.
    ENDLOOP.
    SORT mt_idocs BY docnum int_ui.
    SORT mt_crsrf BY int_crossrefno.

    DELETE ADJACENT DUPLICATES FROM mt_crsrf COMPARING ALL FIELDS.
    COMMIT WORK.
  ENDMETHOD.                    "get_crsrf


  METHOD get_dexproc.
* DA-Prozesse anhand der Basis-DA-Prozesse ermitteln

    DATA:
      rng_edexproc TYPE /adesso/hmv_rt_xpro,
      wa_edexproc  TYPE edexproc.

* DA-Prozesse abhängig von Basisprozess lesen ( INV_OUT, E_INVOIC )
    rng_edexproc = /adesso/cl_hmv_customizing=>get_dexproc_invout( is_so_datum = ms_rng_so_datum ).
    SELECT dexproc FROM edexproc
      INTO CORRESPONDING FIELDS OF wa_edexproc
      WHERE dexbasicproc IN rng_edexproc.
      s_dexproc-sign   = 'I'.
      s_dexproc-option = 'EQ'.
      s_dexproc-low    = wa_edexproc-dexproc.
      APPEND s_dexproc TO t_dexproc.
    ENDSELECT.
  ENDMETHOD.                    "get_dexproc


  METHOD get_dfkkthi.
* Tabelle DFKKTHI (nicht versendete buchungsrelevante Datensätze)
    DATA: ls_dfkkthi LIKE LINE OF it_dfkkthi.
    FIELD-SYMBOLS: <s_crsrf> TYPE type_ecrossrefno.

    CLEAR   it_dfkkthi.
    REFRESH it_dfkkthi.
    LOOP AT mt_crsrf ASSIGNING <s_crsrf> WHERE ( created_from NE /idxmm/if_constants=>gc_createdfrom_m    "Nuss 09.2018
                                            OR   created_from NE 'I' ).                                   "Nuss 09.2018
      SELECT * FROM dfkkthi APPENDING CORRESPONDING FIELDS OF TABLE it_dfkkthi
          WHERE crsrf = <s_crsrf>-int_crossrefno
            AND thist NOT IN (' ','7')      "nicht gesendet/nicht gebucht
            AND burel = 'X'.                "buchungsrelevant
    ENDLOOP.
    IF sy-subrc = 0.
      SORT it_dfkkthi.
      DELETE ADJACENT DUPLICATES FROM it_dfkkthi COMPARING ALL FIELDS.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.          "get_dfkkthi


  METHOD get_edid4.
* IDoc Segment

    DATA: rng_segn_tab TYPE /adesso/hmv_rt_segn,
          lv_docnum    TYPE edi_docnum,
          lv_credat    TYPE edi_ccrdat,
          ls_ediseg    TYPE /adesso/hmv_segn,
          lv_ediseg    TYPE /adesso/hmv_segn,
          lv_segnam    TYPE /adesso/hmv_segn-segnam,
          lv_docnoid   TYPE /adesso/hmv_segn-docnoid.


    DATA: BEGIN OF r_datum,
            sign   TYPE c LENGTH 1,
            option TYPE c LENGTH 2,
            low    TYPE edi_ccrdat,
            high   TYPE edi_ccrdat,
          END OF r_datum.


    FIELD-SYMBOLS: <s_idocs>   TYPE type_idocs.
    FIELD-SYMBOLS: <s_edid4>   TYPE edid4.
    FIELD-SYMBOLS: <s_bgm_general> TYPE data.
    FIELD-SYMBOLS: <s_crossrefno> TYPE data.



    CLEAR mt_edid4.
    LOOP AT mt_idocs ASSIGNING <s_idocs>.
      lv_docnum = <s_idocs>-docnum.
      lv_credat = <s_idocs>-credat.
      AT END OF docnum.
        READ TABLE mt_edid4_c TRANSPORTING NO FIELDS
           WITH KEY docnum = <s_idocs>-docnum
           BINARY SEARCH.
        IF sy-subrc NE 0.
          CLEAR r_datum.

          r_datum-sign   = 'I'.
          r_datum = 'BT'.
          r_datum-low    = lv_credat.
          r_datum-high    = lv_credat.

          ls_ediseg = /adesso/cl_hmv_customizing=>get_edi_segment( is_so_datum = r_datum ).

          REFRESH mt_edid4.
          SELECT * FROM edid4 INTO TABLE mt_edid4
            WHERE docnum = <s_idocs>-docnum
**              AND segnam IN rng_segn_tab.                 "/IDXGC/E1VDEWBGM_1, /IDXGC/E1_BGM_02
              AND segnam = ls_ediseg-segnam.
          LOOP AT mt_edid4 ASSIGNING <s_edid4>.

            s_edid4_s-docnum     = <s_edid4>-docnum.
            CREATE DATA s_bgm_general TYPE (ls_ediseg-segnam).
            ASSIGN s_bgm_general->* TO <s_bgm_general>.
            <s_bgm_general> = <s_edid4>-sdata.
            ASSIGN COMPONENT ls_ediseg-docnoid OF STRUCTURE <s_bgm_general> TO <s_crossrefno>.
            IF <s_crossrefno> IS ASSIGNED.
              s_edid4_s-crossrefno = <s_crossrefno>.
            ENDIF.
*            s_e1vdewbgm_1        = <s_edid4>-sdata.
*            lv_ediseg     = <s_edid4>-sdata.
*            s_edid4_s-crossrefno = s_e1vdewbgm_1-documentnumber.
*            s_edid4_s-crossrefno = <comp2>.
            INSERT s_edid4_s INTO TABLE mt_edid4_c.
          ENDLOOP.
        ENDIF.
      ENDAT.
    ENDLOOP.
    DELETE ADJACENT DUPLICATES FROM mt_edid4_c COMPARING ALL FIELDS.
    mt_edid4_s[] = mt_edid4_c[].
    SORT mt_edid4_s BY crossrefno.
    COMMIT WORK.
  ENDMETHOD.                                                "get_edid4


  METHOD get_euitrans.
* Zählpunktbezeichnung
    CLEAR mt_euitrans.
    CHECK NOT mt_idocs IS INITIAL.
    SELECT *
      FROM euitrans
        INTO TABLE mt_euitrans
             FOR ALL ENTRIES IN mt_idocs
             WHERE int_ui = mt_idocs-int_ui
             AND datefrom <= mt_idocs-dexduedate
             AND dateto   >= mt_idocs-dexduedate.
    SORT mt_euitrans BY int_ui.
    COMMIT WORK.
  ENDMETHOD.                    "get_euitrans


  METHOD get_idocs.
* Serviceanbieter
*  METHOD get_edexdefservprov.
*    SELECT a~dexproc a~dexidocsend a~dexservprovself
*           a~dexservprov b~dexidocsendcat       "ET_20160401: Ergänzung um Feld dexidocsendcat
*      FROM edexdefservprov AS a
*   "Join mit Tabelle EDEXIDOCSEND
*      JOIN edexidocsend AS b
*        ON a~dexidocsend = b~dexidocsend         "ET_20160401: Join über das Feld dexidocsend
*      INTO CORRESPONDING FIELDS OF TABLE it_edexdefserprov
*      WHERE a~datefrom < so_datum-high
*        AND a~dateto   > so_datum-low
*        AND a~dexservprovself IN my_so_serv
*        AND a~dexservprov IN my_so_serve
*        AND a~dexproc IN t_dexproc.
*    SORT it_edexdefserprov.
*  ENDMETHOD.                   "get_edexdefservprov


* IDoc Status
    DATA: rng_sart_tab TYPE /adesso/hmv_rt_sart,
          wa_rng_vart  TYPE edextask.

    FIELD-SYMBOLS: <fs_edids> TYPE ty_edidc.

    CLEAR mt_idocs.

    SELECT t~int_ui t~dextaskid t~dexduedate
           t~dexrefdateto t~dexstatus t~dexservprov
           t~dexservprovself t~dexaedat t~dexproc
           i~docnum i~sent
           c~status c~credat c~cretim
           INTO CORRESPONDING FIELDS OF TABLE mt_idocs
           FROM edextask AS t
           LEFT OUTER JOIN edextaskidoc
                AS i ON i~dextaskid = t~dextaskid
           INNER JOIN edidc
                AS c ON c~docnum = i~docnum
           WHERE t~dextaskid       IN my_so_taski
             AND t~dexproc         IN t_dexproc
             AND t~dexaedat        IN my_so_datum
             AND t~dexservprovself IN my_so_serv
             AND t~int_ui          IN my_so_intui
             AND t~dexservprov     IN my_so_serve.
    SORT mt_idocs.
    CHECK NOT mt_idocs IS INITIAL.

    CALL METHOD /adesso/cl_hmv_customizing=>get_idoc_status(
      EXPORTING
        is_so_datum = ms_rng_so_datum
      IMPORTING
        et_stat     = r_status
        et_sart     = t_hmv_sart ).

    SELECT * FROM edids
      INTO CORRESPONDING FIELDS OF TABLE it_edids
      FOR ALL ENTRIES IN mt_idocs
      WHERE docnum = mt_idocs-docnum
        AND status IN r_status.
    SORT it_edids BY docnum status.
    COMMIT WORK.
  ENDMETHOD.                    "get_idocs


  METHOD get_memidoc.
* Tabelle /IDXMM/MEMIDOC
* <<< ET 20160120

    FIELD-SYMBOLS: <s_crsrf> TYPE type_ecrossrefno,
                   <fs_memi> TYPE type_memidoc.
    CLEAR it_memidoc.
    REFRESH it_memidoc.
    LOOP AT mt_crsrf ASSIGNING <s_crsrf> WHERE created_from EQ /idxmm/if_constants=>gc_createdfrom_m.
      SELECT * FROM /idxmm/memidoc APPENDING CORRESPONDING FIELDS OF TABLE it_memidoc
        WHERE crossrefno = <s_crsrf>-crossrefno.
    ENDLOOP.
    IF sy-subrc = 0.
      SORT it_memidoc.
      DELETE ADJACENT DUPLICATES FROM it_memidoc COMPARING ALL FIELDS.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.         "get_memidoc


  METHOD get_msbdoc.

    FIELD-SYMBOLS: <s_crsrf> TYPE type_ecrossrefno,
                   <fs_msb>  TYPE type_msbdoc.

    CLEAR mt_msbdoc.
    REFRESH mt_msbdoc.
    LOOP AT mt_crsrf ASSIGNING <s_crsrf> WHERE created_from EQ 'I'.
      SELECT * FROM dfkkinvdoc_h APPENDING CORRESPONDING FIELDS OF TABLE mt_msbdoc
        WHERE /mosb/inv_doc_ident = <s_crsrf>-crossrefno.
      SELECT * FROM dfkkinvdoc_h INTO CORRESPONDING FIELDS OF s_msbdoc
          WHERE /mosb/inv_doc_ident = <s_crsrf>-crossrefno.
        SELECT SINGLE opbel FROM dfkkinvdoc_i
          INTO s_msbdoc-opbel WHERE invdocno = s_msbdoc-invdocno.
        APPEND s_msbdoc TO mt_msbdoc.
        CLEAR s_msbdoc.
      ENDSELECT.


    ENDLOOP.
    IF sy-subrc = 0.
      SORT mt_msbdoc.
      DELETE ADJACENT DUPLICATES FROM mt_msbdoc COMPARING ALL FIELDS.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.        "get msbdoc.


  METHOD main.
    GET TIME.
    get_dexproc( ).
*    get_edexdefservprov( ).
    get_idocs( ).
    get_euitrans( ).
    get_edid4( ).
    get_crsrf( ).
    get_dfkkthi( ).
    get_memidoc( ).
    get_msbdoc( ).                "Nuss 09.2018
    fill_internal_table( ).

    IF my_update_flag IS NOT INITIAL.
      update_dfkkthi( ).
    ENDIF.

    IF my_updmmm_flag IS NOT INITIAL.
      update_memidoc( ).
    ENDIF.

    IF my_updmsb_flag IS NOT INITIAL.
      update_msbdoc( ).
    ENDIF.

    APPEND LINES OF mt_output TO et_alv_grid_data.

    get_statistics( CHANGING cs_stats = es_stats ).

    COMMIT WORK.

  ENDMETHOD.                    "main


  METHOD output_alv.
    CALL METHOD build_fieldcat RECEIVING r_fieldcat = mt_fieldcat.
    s_layout   = build_layout( ).
    CALL METHOD set_events RECEIVING r_event = mt_event.

    IF my_statlst_flag = space.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program = ms_const-repid
          is_layout          = s_layout
          it_fieldcat        = mt_fieldcat
          it_events          = mt_event
        TABLES
          t_outtab           = mt_output
        EXCEPTIONS
          program_error      = 1
          OTHERS             = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ELSE.
      "mt_sta     TYPE TABLE OF /adesso/hmv_idoc,
      DATA lt_sta  TYPE TABLE OF /adesso/hmv_idoc.
      IF is_stats IS NOT INITIAL.
        APPEND is_stats TO lt_sta.
      ENDIF.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_structure_name   = '/ADESSO/HMV_IDOC'
          i_callback_program = ms_const-repid
          is_layout          = s_layout
          it_fieldcat        = mt_fieldcat
        TABLES
          t_outtab           = lt_sta.
    ENDIF.
  ENDMETHOD.

  METHOD get_statistics.
    CLEAR cs_stats. "Statistik IDOC-Status
    cs_stats-datum = sy-datum.
    cs_stats-stati = sy-uzeit.
    DESCRIBE TABLE mt_idocs LINES cs_stats-anzda.
    cs_stats-updok = x_updok.
    ADD x_upd_memi_ok TO cs_stats-updok.     "Nuss 09.2018
    ADD x_upd_msb_ok  TO cs_stats-updok.      "Nuss 09.2018
    cs_stats-upder = x_upder.
    ADD x_upd_memi_er TO cs_stats-upder.     "Nuss 09.2018
    ADD x_upd_msb_er TO cs_stats-upder.      "Nuss 09.2018
  ENDMETHOD.

  METHOD add_statistics.
    cs_sta2-anzda = cs_sta2-anzda + is_sta1-anzda.
    cs_sta2-updok = cs_sta2-updok + is_sta1-updok.
    cs_sta2-upder = cs_sta2-upder + is_sta1-upder.
  ENDMETHOD.

  METHOD update_stats_with_selvar.
    DATA:
      mt_valutab TYPE TABLE OF rsparams,
      s_valutab  TYPE          rsparams.

    IF ms_const-slset NE space.
      cs_sta-varia = ms_const-slset.
      CALL FUNCTION 'RS_VARIANT_CONTENTS'
        EXPORTING
          report  = ms_const-repid
          variant = ms_const-slset
        TABLES
          valutab = mt_valutab.

      IF sy-subrc = 0.
        DELETE mt_valutab WHERE selname NE 'SO_TASKI'.
        SORT mt_valutab BY low.
        DESCRIBE TABLE mt_valutab LINES DATA(lv_last_line).
        READ TABLE mt_valutab INTO s_valutab INDEX 1.
        cs_sta-low = s_valutab-low.
        READ TABLE mt_valutab INTO s_valutab INDEX lv_last_line.
        cs_sta-high = s_valutab-low.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD write_stats.
    GET TIME.
    cs_stats-endti = sy-uzeit.
    update_stats_with_selvar(  CHANGING cs_sta = cs_stats ).

    INSERT /adesso/hmv_idoc FROM cs_stats.
    COMMIT WORK.
  ENDMETHOD.

  METHOD set_events.
* FuBa für Eventhandling
    CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                    "#EC *
      EXPORTING
        i_list_type     = 4
      IMPORTING
        et_events       = r_event
      EXCEPTIONS
        list_type_wrong = 1
        OTHERS          = 2.
    READ TABLE r_event WITH KEY name = slis_ev_top_of_page INTO s_event.
    IF sy-subrc = 0.
      MOVE slis_ev_top_of_page TO s_event-form.
      MODIFY r_event FROM s_event INDEX sy-tabix.
    ENDIF.
  ENDMETHOD.                    " SET_EVENTS


  METHOD show_data.
    set_output_data( EXPORTING it_alv_grid_data =  it_alv_grid_data ).
    output_alv( is_stats = is_stats ).
  ENDMETHOD.


  METHOD update_dfkkthi.
* Update DFKKTHI

    FIELD-SYMBOLS: <s_out> TYPE LINE OF tt_dfkkthi_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_dfkkthi  TYPE /adesso/hmv_dfkk, "dfkkthi,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out> WHERE kennz EQ ms_const-c_doc_kzd.
*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

* UPDATE Tabelle DFKKTHI
      CLEAR wa_dfkkthi.
      wa_dfkkthi-opbel = <s_out>-opbel.
      wa_dfkkthi-opupw = <s_out>-opupw.
      wa_dfkkthi-opupk = <s_out>-opupk.
      wa_dfkkthi-opupz = <s_out>-opupz.
      wa_dfkkthi-thinr = <s_out>-thinr.

      SELECT SINGLE * FROM /adesso/hmv_dfkk INTO @DATA(ls_aktueller_satz) WHERE opbel = @<s_out>-opbel AND
                                                                                opupw = @<s_out>-opupw AND
                                                                                opupk = @<s_out>-opupk AND
                                                                                opupz = @<s_out>-opupz AND
                                                                                thinr = @<s_out>-thinr.

*      CASE p_to_update.
*        WHEN 'XX'.
* Update invoice und control status
      wa_dfkkthi-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_dfkkthi-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_dfkkthi-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_dfkkthi-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_dfkkthi-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_dfkkthi-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
      MODIFY /adesso/hmv_dfkk FROM wa_dfkkthi.
      IF sy-subrc = 0.
        ADD 1 TO x_updok.
        <s_out>-status = icon_led_green.
      ELSE.
        ADD 1 TO x_upder.
        <s_out>-status = icon_led_red.
      ENDIF.

* Update invoice status
*        WHEN 'X '.
*          wa_dfkkthi-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_dfkkthi-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_dfkkthi-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_dfkk FROM wa_dfkkthi.
*          IF sy-subrc = 0.
*            ADD 1 TO x_updok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upder.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_dfkkthi-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_dfkkthi-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_dfkkthi-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_dfkkthi-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_dfkkthi-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_dfkk FROM wa_dfkkthi.
*          IF sy-subrc = 0.
*            ADD 1 TO x_updok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upder.
*            <s_out>-status = icon_led_red.
*          ENDIF.
* Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      COMMIT WORK.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.
  ENDMETHOD.                "update_dfkkthi


  METHOD update_memidoc.
* Update /IDXMM/MEMIDOC
    FIELD-SYMBOLS: <s_out> TYPE dfkkthi_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_memidoc  TYPE /adesso/hmv_memi,
      wa_memitemp TYPE /adesso/hmv_memi,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out>
      WHERE kennz EQ /idxmm/if_constants=>gc_createdfrom_m.

*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

      CLEAR wa_memidoc.
      wa_memidoc-doc_id = <s_out>-opbel.

      SELECT SINGLE * FROM /adesso/hmv_memi INTO @DATA(ls_aktueller_satz) WHERE doc_id = @<s_out>-opbel.

* Update invoice- und control-status
*      CASE p_to_update.
*        WHEN 'XX'.
      wa_memidoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_memidoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_memidoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_memidoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_memidoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_memidoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).

      MODIFY /adesso/hmv_memi FROM wa_memidoc.
      IF sy-subrc = 0.
        ADD 1 TO x_upd_memi_ok.
        <s_out>-status = icon_led_green.
      ELSE.
        ADD 1 TO x_upd_memi_er.
        <s_out>-status = icon_led_red.
      ENDIF.

* Update invoice status
*        WHEN 'X '.
*          wa_memidoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_memidoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_memidoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_memi FROM wa_memidoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_memi_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_memi_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_memidoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_memidoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_memidoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_memidoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_memidoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_memi FROM wa_memidoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_memi_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_memi_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
** Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      COMMIT WORK.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.
  ENDMETHOD.              "update_memidoc


  METHOD update_msbdoc.

    FIELD-SYMBOLS: <s_out> TYPE dfkkthi_memi_out.

    DATA:
      wa_edidc    TYPE edidc,
      wa_msbdoc   TYPE /adesso/hmv_mosb,
      p_to_update TYPE char2.

* !!! jeweils den Tabellenbereich mit ASSIGNING angesprochen !!!!
* !!! und Prüfung bei read ob assigned
    LOOP AT mt_output ASSIGNING <s_out>
      WHERE kennz EQ 'I'.

*      CLEAR p_to_update.
*      IF ( <s_out>-idocin IS NOT INITIAL ) AND ( <s_out>-status_i IS NOT INITIAL ) AND ( <s_out>-dexidocsent IS NOT INITIAL ).
*        p_to_update+0(1) = 'X'.
*      ENDIF.
*      IF ( <s_out>-idocct IS NOT INITIAL ) AND ( <s_out>-status_c IS NOT INITIAL ) AND ( <s_out>-dexidocsentctrl IS NOT INITIAL ).
*        p_to_update+1(1) = 'X'.
*      ENDIF.

      CLEAR wa_msbdoc.
      wa_msbdoc-invdocno = <s_out>-opbel.

      SELECT SINGLE * FROM /adesso/hmv_mosb INTO @DATA(ls_aktueller_satz) WHERE invdocno = @<s_out>-opbel.

* Update invoice- und control-status
*      CASE p_to_update.
*        WHEN 'XX'.
      wa_msbdoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
      wa_msbdoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
      wa_msbdoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
      wa_msbdoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
      wa_msbdoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
      wa_msbdoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
      wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
      wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
      MODIFY /adesso/hmv_mosb FROM wa_msbdoc.
      IF sy-subrc = 0.
        ADD 1 TO x_upd_msb_ok.
        <s_out>-status = icon_led_green.
      ELSE.
        ADD 1 TO x_upd_msb_er.
        <s_out>-status = icon_led_red.
      ENDIF.

** Update invoice status
*        WHEN 'X '.
*          wa_msbdoc-idocin          = COND #( WHEN ls_aktueller_satz-idocin IS NOT INITIAL AND <s_out>-idocin IS INITIAL THEN ls_aktueller_satz-idocin ELSE <s_out>-idocin ).
*          wa_msbdoc-statin          = COND #( WHEN ls_aktueller_satz-statin IS NOT INITIAL AND <s_out>-status_i IS INITIAL THEN ls_aktueller_satz-statin ELSE <s_out>-status_i ).
*          wa_msbdoc-dexidocsent     = COND #( WHEN ls_aktueller_satz-dexidocsent IS NOT INITIAL AND <s_out>-dexidocsent IS INITIAL THEN ls_aktueller_satz-dexidocsent ELSE <s_out>-dexidocsent ).
*          wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_mosb FROM wa_msbdoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_msb_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_msb_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
*
** Update control status
*        WHEN ' X'.
*          wa_msbdoc-idocct          = COND #( WHEN ls_aktueller_satz-idocct IS NOT INITIAL AND <s_out>-idocct IS INITIAL THEN ls_aktueller_satz-idocct ELSE <s_out>-idocct ).
*          wa_msbdoc-statct          = COND #( WHEN ls_aktueller_satz-statct IS NOT INITIAL AND <s_out>-status_c IS INITIAL THEN ls_aktueller_satz-statct ELSE <s_out>-status_c ).
*          wa_msbdoc-dexidocsentctrl = COND #( WHEN ls_aktueller_satz-dexidocsentctrl IS NOT INITIAL AND <s_out>-dexidocsentctrl IS INITIAL THEN ls_aktueller_satz-dexidocsentctrl ELSE <s_out>-dexidocsentctrl ).
*          wa_msbdoc-dexidocsendcat  = COND #( WHEN ls_aktueller_satz-dexidocsendcat IS NOT INITIAL AND <s_out>-dexidocsendcat IS INITIAL THEN ls_aktueller_satz-dexidocsendcat ELSE <s_out>-dexidocsendcat ).
*          wa_msbdoc-dexproc         = COND #( WHEN ls_aktueller_satz-dexproc IS NOT INITIAL AND <s_out>-dexproc IS INITIAL THEN ls_aktueller_satz-dexproc ELSE <s_out>-dexproc ).
*          MODIFY /adesso/hmv_mosb FROM wa_msbdoc.
*          IF sy-subrc = 0.
*            ADD 1 TO x_upd_msb_ok.
*            <s_out>-status = icon_led_green.
*          ELSE.
*            ADD 1 TO x_upd_msb_er.
*            <s_out>-status = icon_led_red.
*          ENDIF.
** Kein Update
*        WHEN OTHERS.
*          <s_out>-status = icon_led_yellow.
*      ENDCASE.
      COMMIT WORK.
      MODIFY mt_output FROM <s_out>.
      CLEAR ls_aktueller_satz.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
