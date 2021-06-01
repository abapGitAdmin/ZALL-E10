class ZCL_AGC_BADI_PROC_ADDDATA definition
  public
  inheriting from /IDXGC/CL_BADI_PDOC_ADDDATA
  create public .

public section.

  methods IF_ISU_IDE_SWTDOC_ADDDATA~UPDATE_DB_ADDDATA
    redefinition .
protected section.

  methods UPDATE_SWTDOC_FROM_PDOC_HDR
    importing
      !X_NEW_SWTDOC type KENNZX
      !X_SWTDOC type EIDESWTDOC
      !XT_SWTMSG type TEIDESWTMSGDATA
      !X_SWTDOC_ADDHDDATA type EIDESWTDOCADDDATA optional
      !XT_SWTMSG_ADDDATA type TEIDESWTMSGADDDATA optional
    exceptions
      UPDATE_ERROR .
  methods UPDATE_MSGDATA_FROM_PRSTP
    importing
      !X_NEW_SWTDOC type KENNZX
      !X_SWTDOC type EIDESWTDOC
      !XT_SWTMSG type TEIDESWTMSGDATA
      !X_SWTDOC_ADDHDDATA type EIDESWTDOCADDDATA optional
      !XT_SWTMSG_ADDDATA type TEIDESWTMSGADDDATA optional
    exceptions
      UPDATE_ERROR .
private section.
ENDCLASS.



CLASS ZCL_AGC_BADI_PROC_ADDDATA IMPLEMENTATION.


  METHOD if_isu_ide_swtdoc_adddata~update_db_adddata.
*
*    DATA: ls_header    TYPE        x030l,
*          lr_typedescr TYPE REF TO cl_abap_typedescr.
*
*    FIELD-SYMBOLS: <fs_swtmsg_adddata> TYPE eideswtmsgadddata.
*
*    IF x_swtdoc_addhddata IS SUPPLIED AND xt_swtmsg_adddata IS SUPPLIED.
*      CALL METHOD super->if_isu_ide_swtdoc_adddata~update_db_adddata
*        EXPORTING
*          x_new_swtdoc       = x_new_swtdoc
*          x_swtdoc           = x_swtdoc
*          xt_swtmsg          = xt_swtmsg
*          x_swtdoc_addhddata = x_swtdoc_addhddata
*          xt_swtmsg_adddata  = xt_swtmsg_adddata
*        EXCEPTIONS
*          update_error       = 1
*          OTHERS             = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING update_error.
*      ENDIF.
*    ELSEIF x_swtdoc_addhddata IS SUPPLIED AND xt_swtmsg_adddata IS NOT SUPPLIED.
*      CALL METHOD super->if_isu_ide_swtdoc_adddata~update_db_adddata
*        EXPORTING
*          x_new_swtdoc       = x_new_swtdoc
*          x_swtdoc           = x_swtdoc
*          xt_swtmsg          = xt_swtmsg
*          x_swtdoc_addhddata = x_swtdoc_addhddata
*        EXCEPTIONS
*          update_error       = 1
*          OTHERS             = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING update_error.
*      ENDIF.
*    ELSEIF x_swtdoc_addhddata IS NOT SUPPLIED AND xt_swtmsg_adddata IS SUPPLIED.
*      CALL METHOD super->if_isu_ide_swtdoc_adddata~update_db_adddata
*        EXPORTING
*          x_new_swtdoc      = x_new_swtdoc
*          x_swtdoc          = x_swtdoc
*          xt_swtmsg         = xt_swtmsg
*          xt_swtmsg_adddata = xt_swtmsg_adddata
*        EXCEPTIONS
*          update_error      = 1
*          OTHERS            = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING update_error.
*      ENDIF.
*    ENDIF.
*
*    IF x_swtdoc-switchtype = zif_agc_datex_co=>gc_proc_type_21.
*      RETURN.
*    ENDIF.
*
*    IF x_swtdoc_addhddata IS SUPPLIED.
*
*      CALL METHOD cl_abap_typedescr=>describe_by_data_ref
*        EXPORTING
*          p_data_ref           = x_swtdoc_addhddata-adddata
*        RECEIVING
*          p_descr_ref          = lr_typedescr
*        EXCEPTIONS
*          reference_is_initial = 1
*          OTHERS               = 2.
*      IF sy-subrc <> 0.
*        RETURN.
*      ENDIF.
*
*    ELSEIF xt_swtmsg_adddata IS SUPPLIED.
*      LOOP AT xt_swtmsg_adddata ASSIGNING <fs_swtmsg_adddata>.
*      ENDLOOP.
*      CHECK <fs_swtmsg_adddata> IS ASSIGNED.
*
*      CALL METHOD cl_abap_typedescr=>describe_by_data_ref
*        EXPORTING
*          p_data_ref           = <fs_swtmsg_adddata>-adddata
*        RECEIVING
*          p_descr_ref          = lr_typedescr
*        EXCEPTIONS
*          reference_is_initial = 1
*          OTHERS               = 2.
*      IF sy-subrc <> 0.
*        RETURN.
*      ENDIF.
*
*    ENDIF.
*
*    IF lr_typedescr->is_ddic_type( ) = abap_false
*    AND lr_typedescr->type_kind <> cl_abap_typedescr=>typekind_struct1
*    AND lr_typedescr->type_kind <> cl_abap_typedescr=>typekind_struct2
*    AND lr_typedescr->type_kind <> cl_abap_typedescr=>kind_struct
*    AND lr_typedescr->type_kind <> cl_abap_typedescr=>typekind_table
*    AND lr_typedescr->type_kind <> cl_abap_typedescr=>kind_table.
*      RETURN.
*    ENDIF.
*
*    ls_header = lr_typedescr->get_ddic_header( ).
*
*    IF ls_header-tabname(7) = /idxgc/if_constants=>gc_idxgc_namespace.
*
** Mapping der PDoc Kopfdaten auf die EIDESWTDOC
*      IF x_swtdoc_addhddata IS SUPPLIED.
*        CALL METHOD me->update_swtdoc_from_pdoc_hdr
*          EXPORTING
*            x_new_swtdoc       = x_new_swtdoc
*            x_swtdoc           = x_swtdoc
*            xt_swtmsg          = xt_swtmsg
*            x_swtdoc_addhddata = x_swtdoc_addhddata
*            xt_swtmsg_adddata  = xt_swtmsg_adddata
*          EXCEPTIONS
*            update_error       = 1
*            OTHERS             = 2.
*      ENDIF.
*
*      IF xt_swtmsg_adddata IS SUPPLIED.
** Mapping der Schrittdaten auf die EIDESWTMSGDATA inkl. ZLW_EXTMSGDATA
*        CALL METHOD me->update_msgdata_from_prstp
*          EXPORTING
*            x_new_swtdoc       = x_new_swtdoc
*            x_swtdoc           = x_swtdoc
*            xt_swtmsg          = xt_swtmsg
*            x_swtdoc_addhddata = x_swtdoc_addhddata
*            xt_swtmsg_adddata  = xt_swtmsg_adddata
*          EXCEPTIONS
*            update_error       = 1
*            OTHERS             = 2.
*      ENDIF.
*    ENDIF.
*
  ENDMETHOD.


  METHOD update_msgdata_from_prstp.
*
*    DATA: ls_pdoc_data        TYPE /idxgc/s_pdoc_data,
*          ls_prstp_data_all   TYPE /idxgc/s_msg_data_all,
*          lt_eideswtmsgdata   TYPE teideswtmsgdata,
*          lt_eideswtmsgdataco TYPE teideswtmsgdataco,
*          lt_extmsgdata       TYPE zide_extmsgdata_t.
*
*    FIELD-SYMBOLS: <fs_pdoc_hdr>       TYPE /idxgc/s_pdoc_hdr_add,
*                   <fs_pdoc_msg>       TYPE /idxgc/s_msg_data_add_all,
*                   <fs_swtmsg_adddata> TYPE eideswtmsgadddata.
*
*    "Kopfdaten
*    IF x_swtdoc_addhddata IS SUPPLIED.
*      ls_pdoc_data-hdr = x_swtdoc.
*      ASSIGN x_swtdoc_addhddata-adddata->* TO <fs_pdoc_hdr>.
*      IF <fs_pdoc_hdr> IS ASSIGNED.
*        ls_pdoc_data-hdr_add = <fs_pdoc_hdr>.
*      ENDIF.
*    ENDIF.
*
*    "Schrittdaten
*    IF xt_swtmsg_adddata IS SUPPLIED.
*      LOOP AT xt_swtmsg_adddata ASSIGNING <fs_swtmsg_adddata> WHERE data_saved EQ /idxgc/if_constants=>gc_false.
*
*        READ TABLE xt_swtmsg INTO ls_prstp_data_all-msg_isu_data WITH KEY switchnum = <fs_swtmsg_adddata>-switchnum msgdatanum = <fs_swtmsg_adddata>-msgdatanum.
*
*        ASSIGN <fs_swtmsg_adddata>-adddata->* TO <fs_pdoc_msg>.
*        IF <fs_pdoc_msg> IS ASSIGNED.
*          ls_prstp_data_all-msg_add_data_all = <fs_pdoc_msg>.
*        ENDIF.
*        APPEND ls_prstp_data_all TO ls_pdoc_data-msg_data.
*      ENDLOOP.
*    ENDIF.
*
*    CALL METHOD zcl_agc_datex_utility=>map_pdoc_to_isu_data
*      EXPORTING
*        is_pdoc_data    = ls_pdoc_data
*      IMPORTING
*        et_msg_hdr      = lt_eideswtmsgdata
*        et_msg_comments = lt_eideswtmsgdataco
*        et_msg_ext      = lt_extmsgdata.
*
*    IF lt_eideswtmsgdata IS NOT INITIAL.
*      MODIFY eideswtmsgdata FROM TABLE lt_eideswtmsgdata.
*    ENDIF.
*
*    IF lt_eideswtmsgdataco IS NOT INITIAL.
*      MODIFY eideswtmsgdataco FROM TABLE lt_eideswtmsgdataco.
*    ENDIF.
*
*    IF lt_extmsgdata IS NOT INITIAL.
*      MODIFY zlw_extmsgdata FROM TABLE lt_extmsgdata.
*    ENDIF.
*
  ENDMETHOD.


  METHOD update_swtdoc_from_pdoc_hdr.
*
*    DATA: ls_eideswtdoc     TYPE        eideswtdoc,
*          ls_pdoc_data      TYPE        /idxgc/s_pdoc_data,
*          ls_prstp_data_all TYPE        /idxgc/s_msg_data_all,
*          lr_typedescr      TYPE REF TO cl_abap_typedescr,
*          lr_structdescr    TYPE REF TO cl_abap_structdescr.
*
*    FIELD-SYMBOLS: <fs_pdoc_hdr>       TYPE /idxgc/s_pdoc_hdr_add,
*                   <fs_pdoc_msg>       TYPE /idxgc/s_msg_data_add_all,
*                   <fs_swtmsg_adddata> TYPE eideswtmsgadddata,
*                   <fs_components>     TYPE abap_compdescr,
*                   <fs_msg_field_old>  TYPE any,
*                   <fs_msg_field_new>  TYPE any.
*
*    "Kopfdaten
*    IF x_swtdoc_addhddata IS SUPPLIED.
*      ls_pdoc_data-hdr = x_swtdoc.
*      ASSIGN x_swtdoc_addhddata-adddata->* TO <fs_pdoc_hdr>.
*      IF <fs_pdoc_hdr> IS ASSIGNED.
*        ls_pdoc_data-hdr_add = <fs_pdoc_hdr>.
*      ENDIF.
*    ENDIF.
*
*    "Schrittdaten
*    IF xt_swtmsg_adddata IS SUPPLIED.
*      LOOP AT xt_swtmsg_adddata ASSIGNING <fs_swtmsg_adddata> WHERE data_saved EQ /idxgc/if_constants=>gc_false.
*
*        READ TABLE xt_swtmsg INTO ls_prstp_data_all-msg_isu_data WITH KEY switchnum = <fs_swtmsg_adddata>-switchnum msgdatanum = <fs_swtmsg_adddata>-msgdatanum.
*
*        ASSIGN <fs_swtmsg_adddata>-adddata->* TO <fs_pdoc_msg>.
*        IF <fs_pdoc_msg> IS ASSIGNED.
*          ls_prstp_data_all-msg_add_data_all = <fs_pdoc_msg>.
*        ENDIF.
*        APPEND ls_prstp_data_all TO ls_pdoc_data-msg_data.
*      ENDLOOP.
*    ENDIF.
*
*    CALL METHOD zcl_agc_datex_utility=>map_pdoc_to_isu_data
*      EXPORTING
*        is_pdoc_data = ls_pdoc_data
*      IMPORTING
*        es_pdoc_hdr  = ls_eideswtdoc.
*
**    IF x_new_swtdoc = abap_false.
**      CALL METHOD cl_abap_tabledescr=>describe_by_name
**        EXPORTING
**          p_name         = 'EIDESWTDOC'
**        RECEIVING
**          p_descr_ref    = lr_typedescr
**        EXCEPTIONS
**          type_not_found = 1
**          OTHERS         = 2.
**      IF sy-subrc <> 0.
**      ENDIF.
**
**      lr_structdescr ?= lr_typedescr.
**
**      LOOP AT lr_structdescr->components ASSIGNING <fs_components>.
**        ASSIGN COMPONENT <fs_components>-name OF STRUCTURE ls_eideswtdoc TO <fs_msg_field_old>.
**        ASSIGN COMPONENT <fs_components>-name OF STRUCTURE x_swtdoc TO <fs_msg_field_new>.
**
**        IF <fs_components>-name NE 'MOVEINDATE' AND
**           <fs_msg_field_new> IS NOT INITIAL AND
**           <fs_msg_field_new> NE <fs_msg_field_old>.
**
**          <fs_msg_field_old> = <fs_msg_field_new>.
**
**        ENDIF.
**      ENDLOOP.
**    ENDIF.
*
*    IF ls_eideswtdoc-switchnum IS NOT INITIAL.
*      UPDATE eideswtdoc FROM ls_eideswtdoc.
*    ENDIF.
*
  ENDMETHOD.
ENDCLASS.
