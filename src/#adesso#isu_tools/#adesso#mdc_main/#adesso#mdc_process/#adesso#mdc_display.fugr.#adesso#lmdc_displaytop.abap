FUNCTION-POOL /adesso/mdc_display.

TYPES: BEGIN OF ts_header,
         proc_id        TYPE /idxgc/de_proc_id,
         proc_descr     TYPE /idxgc/de_proc_descr,
         proc_ref       TYPE /idxgc/de_proc_ref,
         proc_type      TYPE /idxgc/de_proc_type,
         proc_date      TYPE /idxgc/de_proc_date,
         ext_ui         TYPE ext_ui,
         bu_partner     TYPE bu_partner,
         assoc_servprov TYPE e_dexservprov,
         own_servprov   TYPE e_dexservprovself,
         amid           TYPE /idxgc/de_amid,
         amid_descr     TYPE text60,
         respstatus     TYPE /idxgc/de_respstatus,
       END OF ts_header.

TYPES: BEGIN OF ts_seltab,
         fieldname       TYPE fieldname,
         src_field_value TYPE /idxgc/de_mtd_src_field_value,
         cmp_field_value TYPE /idxgc/de_mtd_comp_field_value,
         auto_change     TYPE ddtext,
         edifact_name    TYPE /idxgc/de_add_info,
         badi_name       TYPE badi_name,
         rowcolor(4)     TYPE c,                  " für Zeilenfarbe
         cellcolor       TYPE lvc_t_scol,         " Farbe für einzelne Zellen
       END OF ts_seltab.

CONSTANTS: gc_tabname            TYPE slis_tabname VALUE 'TS_SELTAB',
           gc_text_mark_one_line TYPE string VALUE 'Bitte mind. eine Zeile markieren'.

DATA: gr_grid                   TYPE REF TO cl_gui_alv_grid,
      gr_custom_container       TYPE REF TO cl_gui_custom_container,
      gt_fieldcat               TYPE TABLE OF lvc_s_fcat,
      gs_layout                 TYPE lvc_s_layo,

      gv_but5(30)               TYPE c,
      gv_but6(30)               TYPE c,
      gv_but7(30)               TYPE c,
      "gv_buttontext(30)         TYPE c,

      gt_seltab                 TYPE STANDARD TABLE OF ts_seltab,
      gs_header                 TYPE ts_header,
      gv_ok_code                TYPE sy-ucomm,

      gr_ctx                    TYPE REF TO /idxgc/cl_pd_doc_context,
      gs_proc_step_key          TYPE /idxgc/s_proc_step_key,
      gs_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
      gs_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,
      gr_badi_mdc_pro_show_disp TYPE REF TO /adesso/badi_mdc_pro_show_disp.
