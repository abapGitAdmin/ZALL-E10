FUNCTION-POOL /adesso/bpu_display.

TYPES: BEGIN OF ts_header_emma,
         casenr    TYPE emma_cnr,
         casetxt   TYPE emma_casetxt,
         ccat      TYPE emma_ccat,
         currproc  TYPE emma_cprocessor,
         prevproc  TYPE emma_cprevproc,
         due_date  TYPE emma_cduedate,
         due_time  TYPE emma_cduetime,
         orig_date TYPE emma_corigdate,
         orig_time TYPE emma_corigtime,
         prio      TYPE emma_cprio,
         status    TYPE emma_cstatus,
       END OF ts_header_emma,

       BEGIN OF ts_header_proc,
         proc_id         TYPE /idxgc/de_proc_id,
         proc_descr      TYPE /idxgc/de_proc_descr,
         proc_ref        TYPE /idxgc/de_proc_ref,
         proc_type       TYPE /idxgc/de_proc_type,
         proc_type_descr TYPE text60,
         proc_date       TYPE /idxgc/de_proc_date,
         proc_time       TYPE tims,
         status_time     TYPE /idxgc/de_status_timestamp,
         ext_ui          TYPE ext_ui,
         bu_partner      TYPE bu_partner,
         assoc_servprov  TYPE e_dexservprov,
         own_servprov    TYPE e_dexservprovself,
         amid            TYPE /idxgc/t_amid_details,
         amid_text       TYPE text60,
         respstatus      TYPE /idxgc/de_respstatus,
       END OF ts_header_proc.

DATA: gr_case_desc              TYPE REF TO cl_gui_textedit,
      gr_case_desc_container    TYPE REF TO cl_gui_custom_container,
      gr_obj_list               TYPE REF TO cl_gui_alv_grid,
      gr_obj_list_container     TYPE REF TO cl_gui_custom_container,
      gr_process_log            TYPE REF TO cl_gui_alv_grid,
      gr_process_log_container  TYPE REF TO cl_gui_custom_container,

      gs_case                   TYPE emma_case,
      gs_header_emma            TYPE ts_header_emma,
      gs_header_proc            TYPE ts_header_proc,
      gs_proc_step_key          TYPE /idxgc/s_proc_step_key,
      gs_proc_step_data         TYPE /idxgc/s_proc_step_data_all,
      gs_proc_step_data_src_add TYPE /idxgc/s_proc_step_data_all,

      gt_message                TYPE emma_ctxn_alvmsg_t,
      gt_object                 TYPE /adesso/bpu_t_emma_case_object,
      gt_tline                  TYPE tsftext,

      gv_listbox_prio           TYPE char20,
      gv_listbox_status         TYPE char20,
      gv_ok_code                TYPE sy-ucomm,
      gv_subreport              LIKE sy-repid,
      gv_subscreen_9000         TYPE syst_dynnr,
      gv_subscreen_9010         TYPE syst_dynnr,
      gv_subscreen_9020         TYPE syst_dynnr.

**********************************************************************
"Dynprofelder 9010
DATA: gv_respstatus       TYPE /idxgc/de_respstatus,
      gv_rbutton_z12      TYPE abap_bool,
      gv_rbutton_e14      TYPE abap_bool,
      gv_rbutton_e15      TYPE abap_bool,
      gv_button_ok        TYPE abap_bool,
      gv_button_01        TYPE char24,
      gv_button_02        TYPE char24,
      gv_button_03        TYPE char24,
      gv_button_04        TYPE char24,
      gv_free_text_value  TYPE /idxgc/de_free_text_value,
      gv_endnextposs_from TYPE /idxgc/de_endnextposs_from,
      gv_frist_z12        TYPE char5,
      gs_return           TYPE /adesso/bpu_s_ret_show_disp,
      gt_return           TYPE /adesso/bpu_t_ret_show_disp.

**********************************************************************
"Dynprofelder 9020
DATA: gv_rbutton_z01      TYPE abap_bool.
