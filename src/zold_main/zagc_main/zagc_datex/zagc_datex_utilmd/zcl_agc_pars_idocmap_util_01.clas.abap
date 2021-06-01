class ZCL_AGC_PARS_IDOCMAP_UTIL_01 definition
  public
  inheriting from /IDXGC/CL_PARS_IDOCMAP_UTIL_01
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_IDOC_DATA type EDEX_IDOCDATA optional
      !IV_KEY_DATE type /IDXGC/DE_PARSER_DATEFROM optional
    raising
      /IDXGC/CX_IDE_ERROR .
protected section.

  methods DET_DATEX_BASICPROC_E01
    redefinition .
  methods DET_DATEX_BASICPROC_E02
    redefinition .
  methods DET_DATEX_BASICPROC_E03
    redefinition .
  methods DET_DATEX_BASICPROC_E35
    redefinition .
  methods DET_DATEX_BASICPROC_E44
    redefinition .
  methods DET_DATEX_BASICPROC_Z14
    redefinition .
  methods GET_PROCESS_PARAMETERS
    redefinition .
  methods PROCESS_INBOUND_PROCESS
    redefinition .
  methods DET_INBOUND_BASICPROC
    redefinition .
private section.

  methods Z_DET_DATEX_BASICPROC_Z22 .
ENDCLASS.



CLASS ZCL_AGC_PARS_IDOCMAP_UTIL_01 IMPLEMENTATION.


  METHOD CONSTRUCTOR.
**************************************************************************************************
* THIMEL.R 20150229 Einführung CL
*   Standard COMEV festlegen
**************************************************************************************************
    CALL METHOD super->constructor
      EXPORTING
        is_idoc_data = is_idoc_data
        iv_key_date  = iv_key_date.

* Set attribute in inbound process
    IF is_idoc_data-control-direct = /idxgc/cl_parser_idoc=>co_idoc_direction_inbound.
      me->mv_de_old_fm          = zif_agc_datex_utilmd_co=>gc_de_fm_utilmd_1.
    ENDIF.
  ENDMETHOD.


  METHOD det_datex_basicproc_e01.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
***
*** Usage: for message category E01
**a)check new or old process for message category E01 by using transaction
**  reason and distinguish between request and response
**b)If new process check if the message refers to process created with old
**  switch dcument (then do not set new basic process)
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Apr. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

    DATA:
      lt_range_transr_e01 TYPE        isu_ranges_tab,
      ls_range            TYPE        isu_ranges,
      lt_segm             TYPE        edidd_tt,
      ls_segm_sts         TYPE        /idxgc/e1_sts_01,
      ls_segm_sts_7       TYPE        /idxgc/e1_sts_01,
      ls_segm_imd         TYPE        /idxgc/e1_imd_01,
      lv_response         TYPE        boolean,
      lv_swtdoc_exist     TYPE        boolean,
      lv_eideswtnum       TYPE        eideswtnum,
      lx_previous         TYPE REF TO /idxgc/cx_general.

    FIELD-SYMBOLS <fs_edidd> TYPE edidd.

    ls_range-sign = 'I'.
    ls_range-option = 'EQ'.

* range for relevant transaction reasons
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e01.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e02.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e03.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e04.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e06.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_zc6.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_zc7.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z36.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z37.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z38.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z39.
    APPEND ls_range TO lt_range_transr_e01.
    ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_zd2.
    APPEND ls_range TO lt_range_transr_e01.
*>>> THIMEL.R 20150329 Transaktionsgrund für Sperrprozesse
    ls_range-low = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z28.
    APPEND ls_range TO lt_range_transr_e01.
*<<< THIMEL.R 20150329

* Get STS segments from IDOC data
    lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_sts_01 ).
    LOOP AT lt_segm ASSIGNING <fs_edidd>.
      ls_segm_sts = <fs_edidd>-sdata.
*   get transaction reason
      IF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_7.
        ls_segm_sts_7 = <fs_edidd>-sdata.
*   if STS+E01 exists it is a response message
      ELSEIF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_e01.
        lv_response = abap_true.
      ENDIF.
    ENDLOOP.

* Get IMD segments from IDOC data; if other than Z14 exists the message is not relevant
    lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_imd_01 ).
    LOOP AT lt_segm ASSIGNING <fs_edidd>.
      ls_segm_imd = <fs_edidd>-sdata.
      IF ls_segm_imd-item_characteristic_code <> /idxgc/if_constants_ide=>gc_imd_servcode_z14.
        RETURN.
      ENDIF.
    ENDLOOP.

* check transaction reason
    IF NOT ls_segm_sts_7-status_reason_descr_code_1 IN lt_range_transr_e01.
      RETURN.
    ENDIF.

* data exchange basic process I_UTILREQ (Initial process)
    IF lv_response <> abap_true.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
      IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e06 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc6 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc7 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z36 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z37 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z38 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z39.
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impreqbsup.
      ELSE.
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impreqswt.
      ENDIF.
*        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilreq.
*<<< THIMEL.R 20150113

*   in case of reversal check for ongoing old process (process started with switch document not PDoc)
      IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.

*    reversal messages refers to original message that was imported at switchdocument
*    check for ongoing switch document to which the message belongs
        TRY.
            CALL METHOD me->check_swt_on_going
              IMPORTING
                ev_eideswtnum   = lv_eideswtnum
                ev_swtdoc_exist = lv_swtdoc_exist.
          CATCH /idxgc/cx_ide_error INTO lx_previous.
            MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.

        IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*       ongoing switch document was found: the message shall not be processed with the new basic process
          CLEAR: me->mv_dexbasicproc.
        ENDIF.

      ENDIF.

* Data exchange basic process: I_UTILRES (response to request message)
    ELSE.
*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
      IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e06 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc6 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc7 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z36 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z37 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z38 OR
         ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z39.
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresbsup.
      ELSE.
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresswt.
      ENDIF.
*        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres.
*<<< THIMEL.R 20150113


*   check for ongoing switch document to which the message belongs
      TRY.
          CALL METHOD me->check_swt_on_going
            IMPORTING
              ev_eideswtnum   = lv_eideswtnum
              ev_swtdoc_exist = lv_swtdoc_exist.
        CATCH /idxgc/cx_ide_error INTO lx_previous.
          MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.

      IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*     ongoing switch document was found: the message shall not be processed with the new basic process
        CLEAR: me->mv_dexbasicproc.
      ENDIF.

    ENDIF.

  ENDMETHOD.


METHOD DET_DATEX_BASICPROC_E02.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
***
*** Usage: for message catefory E035
**a)check new or old process for message category E01 by using transaction
**  reason and distinguish between request and response
**b)If new process check if the message refers to process created with old
**  switch dcument (then do not set new basic process)
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Apr. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

  DATA:
* Range table for STS reason code with category 7:Document code E02,request
    lt_range_transr_e02 TYPE        isu_ranges_tab,
    ls_range            TYPE        isu_ranges,
    lt_segm             TYPE        edidd_tt,
    ls_segm_sts         TYPE        /idxgc/e1_sts_01,
    ls_segm_sts_7       TYPE        /idxgc/e1_sts_01,
    ls_segm_nad         TYPE        /idxgc/e1_nad_03,
    ls_segm_imd         TYPE        /idxgc/e1_imd_01,
    lv_response         TYPE        boolean,
    ls_sp_sender        TYPE        /idxgc/s_agent_attr,
    ls_sp_receiver      TYPE        /idxgc/s_agent_attr,    "#EC NEEDED
    lv_ext_id           TYPE        dunsnr,
    lv_swtdoc_exist     TYPE        boolean,
    lv_eideswtnum       TYPE        eideswtnum,
    lx_previous         TYPE REF TO /idxgc/cx_general.

  FIELD-SYMBOLS: <fs_edidd> TYPE edidd.

  ls_range-sign = 'I'.
  ls_range-option = 'EQ'.
* range for relevant transaction reasons
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e01.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e03.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e04.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z33.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_z41.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_zd2.
  APPEND ls_range TO lt_range_transr_e02.
  ls_range-low = /idxgc/if_constants_ide=>gc_trans_reason_code_zc9.
  APPEND ls_range TO lt_range_transr_e02.
*>>> THIMEL.R 20150329 Transaktionsgrund für Sperrprozesse
  ls_range-low = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z27.
  APPEND ls_range TO lt_range_transr_e02.
*<<< THIMEL.R 20150329

* Get STS segments from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_sts_01 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_sts = <fs_edidd>-sdata.
*   get transaction reason
    IF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_7.
      ls_segm_sts_7 = <fs_edidd>-sdata.
*   if STS+E01 exists it is a response message
    ELSEIF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_e01.
      lv_response = abap_true.
    ENDIF.
  ENDLOOP.

* Get IMD segments from IDOC data; if other than Z14 found the message is not relevant for new process
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_imd_01 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_imd = <fs_edidd>-sdata.
    IF ls_segm_imd-item_characteristic_code <> /idxgc/if_constants_ide=>gc_imd_servcode_z14.
      RETURN.
    ENDIF.
  ENDLOOP.

* Get NAD Segments from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_nad_03 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_nad = <fs_edidd>-sdata.
    IF ls_segm_nad-party_function_code_qualifier = /idxgc/if_constants_ide=>gc_nad_qual_mr.
      lv_ext_id = ls_segm_nad-party_identifier.
      CALL METHOD /idxgc/cl_utility_isu_add=>get_sp_attr_by_ext_id
        EXPORTING
          iv_ext_id        = lv_ext_id
          iv_extcodelistid = ls_segm_nad-code_list_resp_agency_code_1
        IMPORTING
          es_sp_attr       = ls_sp_receiver.

    ELSEIF ls_segm_nad-party_function_code_qualifier = /idxgc/if_constants_ide=>gc_nad_qual_ms.
      lv_ext_id = ls_segm_nad-party_identifier.
      CALL METHOD /idxgc/cl_utility_isu_add=>get_sp_attr_by_ext_id
        EXPORTING
          iv_ext_id        = lv_ext_id
          iv_extcodelistid = ls_segm_nad-code_list_resp_agency_code_1
        IMPORTING
          es_sp_attr       = ls_sp_sender.
    ENDIF.
    CLEAR ls_segm_nad.
  ENDLOOP.

* check transaction reason
  IF NOT ls_segm_sts_7-status_reason_descr_code_1 IN lt_range_transr_e02.
    RETURN.
  ENDIF.

* data exchange basic process I_UTILREQ (Initial process)
  IF lv_response <> abap_true.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impreqswt.
**   check for special process that is not supported: Move-out/Shut down from DSO to supplier
*    IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z33
*      AND ls_sp_sender-agent_cat     = /idxgc/if_constants_ide=>gc_service_cat_dis.
*      RETURN.
*    ENDIF.
*
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilreq.
*<<< THIMEL.R 20150113

*   in case of reversal check for ongoing old process (process started with switch document not PDoc)
    IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.

*     reversal messages refers to original message that was imported at switchdocument
*     check for ongoing switch document to which the message belongs
      TRY.
          CALL METHOD me->check_swt_on_going
            IMPORTING
              ev_eideswtnum   = lv_eideswtnum
              ev_swtdoc_exist = lv_swtdoc_exist.
        CATCH /idxgc/cx_ide_error INTO lx_previous.
          MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.

      IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*       ongoing switch document was found: the message shall not be processed with the new basic process
        CLEAR: me->mv_dexbasicproc.
      ENDIF.

    ENDIF.

* Data exchange basic process:I_UTILRES (response to request messages )
  ELSE.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresswt.
**   Check for special process that is not supported: Move-out/Shut down from DSO to supplier
*    IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z33
*      AND ls_sp_sender-agent_cat     = /idxgc/if_constants_ide=>gc_service_cat_sup.
*      RETURN.
*    ENDIF.
*
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres.
*<<< THIMEL.R 20150113

*  check for ongoing old process (process started with switch document not PDoc)
*  response messages refers to original message that was exported from switchdocument
    TRY.
        CALL METHOD me->check_swt_on_going
          IMPORTING
            ev_eideswtnum   = lv_eideswtnum
            ev_swtdoc_exist = lv_swtdoc_exist.
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*     ongoing switch document was found: the message shall not be processed with the new basic process
      CLEAR: me->mv_dexbasicproc.
    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD DET_DATEX_BASICPROC_E03.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
***
*** Usage:
**a)check new or old process for message category E01
**b)If new process and the message ref to swithc dcument, mv_dexbasicproc
**  is initial.
**c)For response message, get the process step data of the original step
**d)Fill the original step reference in ATTRIBUTE
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Apr. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

  DATA:  lv_old_proc        TYPE        boolean,
         lt_segm            TYPE        edidd_tt,
         ls_segm_seq        TYPE        /idxgc/e1_seq_01,
         ls_segm_sts        TYPE        /idxgc/e1_sts_01,
         lv_is_swtdoc_exist TYPE        flag,
         lv_response        TYPE        flag,
         lx_previous        TYPE REF TO /idxgc/cx_general.

  FIELD-SYMBOLS <fs_edidd> TYPE edidd.
*>>> THIMEL.R 20150211 Immer neuer Prozess
*  lv_old_proc = abap_true.
*
** Get SEQ segments from IDOC data
*  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_seq_01 ).
*  LOOP AT lt_segm ASSIGNING <fs_edidd>.
*    ls_segm_seq = <fs_edidd>-sdata.
*    IF ls_segm_seq-action_code = /idxgc/if_constants_ide=>gc_seq_action_code_z03. "Meter device
*      lv_old_proc = abap_false.
*      EXIT.
*    ELSEIF ls_segm_seq-action_code = /idxgc/if_constants_ide=>gc_seq_action_code_z04. "Transformer
*      lv_old_proc = abap_false.
*      EXIT.
*    ELSEIF ls_segm_seq-action_code = /idxgc/if_constants_ide=>gc_seq_action_code_z05. "Communication device
*      lv_old_proc = abap_false.
*      EXIT.
*    ELSEIF ls_segm_seq-action_code = /idxgc/if_constants_ide=>gc_seq_action_code_z06. "Control device
*      lv_old_proc = abap_false.
*      EXIT.
*    ELSEIF ls_segm_seq-action_code = /idxgc/if_constants_ide=>gc_seq_action_code_z09. "Corrector device
*      lv_old_proc = abap_false.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*
** Although it belongs new process so far, we still need to check whether an ongoing switch doc exists
** if an active switch document already exist, we shall dispatch the message to it
*  IF lv_old_proc = abap_false.
*<<< THIMEL.R 20150211
    TRY.
        CALL METHOD me->check_swt_on_going
          IMPORTING
            ev_swtdoc_exist = lv_is_swtdoc_exist.
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF lv_is_swtdoc_exist = abap_true.
      CLEAR: me->mv_dexbasicproc.
    ELSE.

*     Get STS segments from IDOC data
      lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_sts_01 ).
      LOOP AT lt_segm ASSIGNING <fs_edidd>.
        ls_segm_sts = <fs_edidd>-sdata.
        IF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_e01.
          lv_response = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_response = abap_false.
*       Data exchange basic process I_UTILREQ (Initial process)

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_req_change.
*        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilreq.
*<<< THIMEL.R 20150113

      ELSE.
*       Data exchange basic process:I_UTILRES (response to request message)

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
        me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresmdch.
*        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres.
*<<< THIMEL.R 20150113

      ENDIF.
    ENDIF.

*  ENDIF. "THIMEL.R 20150211 Immer neuer Prozess

ENDMETHOD.


METHOD DET_DATEX_BASICPROC_E35.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
***
*** Usage: for message category E35
**a)check new or old process for message category E01 by using transaction
**  reason and distinguish between request and response
**b)If new process check if the message refers to process created with old
**  switch dcument (then do not set new basic process)
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Apr. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

  DATA: lt_segm         TYPE        edidd_tt,
        ls_segm_sts     TYPE        /idxgc/e1_sts_01,
        ls_segm_sts_7   TYPE        /idxgc/e1_sts_01,
        ls_segm_imd     TYPE        /idxgc/e1_imd_01,
        lv_response     TYPE        boolean,
        lv_swtdoc_exist TYPE        boolean,
        lv_eideswtnum   TYPE        eideswtnum,
        lx_previous     TYPE REF TO /idxgc/cx_general.

  FIELD-SYMBOLS: <fs_edidd> TYPE edidd.

* Get STS segments from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_sts_01 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_sts = <fs_edidd>-sdata.
*   get transaction reason
    IF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_7.
      ls_segm_sts_7 = <fs_edidd>-sdata.
*   if STS+E01 exists it is a response message
    ELSEIF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_e01.
      lv_response = abap_true.
    ENDIF.
    CLEAR ls_segm_sts.
  ENDLOOP.

* Get IMD segments from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_imd_01 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_imd = <fs_edidd>-sdata.
    IF ls_segm_imd-item_characteristic_code <> /idxgc/if_constants_ide=>gc_imd_servcode_z14.
      RETURN.
    ENDIF.
  ENDLOOP.

* check transaction reason
  IF NOT ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e03 AND
     NOT ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.
    RETURN.
  ENDIF.

* data exchange basic process I_UTILREQ (Initial process)
  IF lv_response <> abap_true.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impreqswt.
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilreq.
*<<< THIMEL.R 20150113

*   in case of reversal check for ongoing old process (process started with switch document not PDoc)
    IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.

*    reversal messages refers to original message that was imported at switchdocument
*    check for ongoing switch document to which the message belongs
      TRY.
          CALL METHOD me->check_swt_on_going
            IMPORTING
              ev_eideswtnum   = lv_eideswtnum
              ev_swtdoc_exist = lv_swtdoc_exist.
        CATCH /idxgc/cx_ide_error INTO lx_previous.
          MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.

      IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*       ongoing switch document was found: the message shall not be processed with the new basic process
        CLEAR: me->mv_dexbasicproc.
      ENDIF.
    ENDIF.

* Data exchange basic process:I_UTILRES (response to request or reversal messages )
  ELSE.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresswt.
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres.
*<<< THIMEL.R 20150113

*    check for ongoing old process (process started with switch document not PDoc)
*    response messages refers to original message that was exported from switchdocument
*    check for ongoing switch document to which the message belongs
    TRY.
        CALL METHOD me->check_swt_on_going
          IMPORTING
            ev_eideswtnum   = lv_eideswtnum
            ev_swtdoc_exist = lv_swtdoc_exist.
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*       ongoing switch document was found: the message shall not be processed with the new basic process
      CLEAR: me->mv_dexbasicproc.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD DET_DATEX_BASICPROC_E44.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
***
*** Usage:
**a)check new or old process for message category E44
**b)If new process and the message refers to switch dcument, mv_dexbasicproc
**  is empty.
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Apr. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

  DATA: lt_segm         TYPE        edidd_tt,
        ls_segm_sts     TYPE        /idxgc/e1_sts_01,
        ls_segm_sts_7   TYPE        /idxgc/e1_sts_01,
        lv_swtdoc_exist TYPE        boolean,
        lv_eideswtnum   TYPE        eideswtnum ,
        lx_previous     TYPE REF TO /idxgc/cx_general.

  FIELD-SYMBOLS:  <fs_edidd> TYPE edidd.

* Get STS segments from IDOC data
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_sts_01 ).
  LOOP AT lt_segm ASSIGNING <fs_edidd>.
    ls_segm_sts = <fs_edidd>-sdata.
    IF ls_segm_sts-status_category_code_1 = /idxgc/if_constants_ide=>gc_sts_qual_7.
      ls_segm_sts_7 = <fs_edidd>-sdata.
    ENDIF.
    CLEAR ls_segm_sts.
  ENDLOOP.

* Check for new process for data exchange basic process I_UTILINF
  IF ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc8 OR
     ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_zc9 OR
     ls_segm_sts_7-status_reason_descr_code_1 = /idxgc/if_constants_ide=>gc_trans_reason_code_z26.

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impreqswt.
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilinf.
*<<< THIMEL.R 20150113

*   check for ongoing switch document
    TRY.
        CALL METHOD me->check_swt_on_going
          IMPORTING
            ev_eideswtnum   = lv_eideswtnum
            ev_swtdoc_exist = lv_swtdoc_exist.
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*     ongoing switch document was found: the message shall not be processed with the new basic process
      CLEAR: me->mv_dexbasicproc.
    ENDIF.

  ELSE.
    RETURN.
  ENDIF.

ENDMETHOD.


METHOD DET_DATEX_BASICPROC_Z14.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
*** Usage:
**a)Determine new/old process, and set the data exchange basic process
**
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** May. 2014: Created
**
*** THIMEL.R 20150113 Initiale Anpassung für alte Basisprozesse
**----------------------------------------------------------------------*

  DATA: ls_segm_rff          TYPE /idxgc/e1_rff_09,
        ls_amid_z13          TYPE /idxgc/e1_rff_09,
        ls_segm              TYPE edidd,
        lt_segm              TYPE edidd_tt,
        lv_eideswtnum        TYPE eideswtnum,
        lv_swtdoc_exist      TYPE boolean,
        lx_previous          TYPE REF TO cx_root.

* Get IDOC segment value of RFF_09+Z13 segment and RFF_09+AAV segment
  REFRESH: lt_segm.
  lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_rff_09 ).
  LOOP AT lt_segm INTO ls_segm.
    ls_segm_rff = ls_segm-sdata.
    IF ls_segm_rff-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_z13.
      ls_amid_z13 = ls_segm-sdata.
    ELSE.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  IF ( ls_amid_z13-reference_identifier = /idxgc/if_constants_ide=>gc_amid_11035 ) OR
     ( ls_amid_z13-reference_identifier = /idxgc/if_constants_ide=>gc_amid_11095 ) OR
     ( ls_amid_z13-reference_identifier = /idxgc/if_constants_ide=>gc_amid_11060 ) OR
     ( ls_amid_z13-reference_identifier = /idxgc/if_constants_ide=>gc_amid_11061 ).

*   Set basic process

*>>> THIMEL.R 20150113 Umstellung auf alte Basisprozesse (für Prozesse mit WB)
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_impresswt.
*    me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_utilres. "I_UTILRES
*<<< THIMEL.R 20150113

*   check for ongoing switch document
    TRY.
        CALL METHOD me->check_swt_on_going
          IMPORTING
            ev_eideswtnum   = lv_eideswtnum
            ev_swtdoc_exist = lv_swtdoc_exist.
      CATCH /idxgc/cx_ide_error INTO lx_previous.
        MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF lv_swtdoc_exist = abap_true OR lv_eideswtnum IS NOT INITIAL.
*     ongoing switch document was found: the message shall not be processed with the new basic process
      CLEAR: me->mv_dexbasicproc.
    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD det_inbound_basicproc.
    DATA: lt_segm     TYPE edidd_tt,
          ls_segm     TYPE edidd,
          ls_segm_bgm TYPE /idxgc/e1_bgm_01.

    CALL METHOD super->det_inbound_basicproc.

    IF me->mv_dexbasicproc IS INITIAL.

* Get BGM segment from IDOC data
      lt_segm = me->get_segment( iv_segnam = /idxgc/if_constants_ide=>gc_segm_bgm_02 ).
      READ TABLE lt_segm INTO ls_segm INDEX 1.
      IF sy-subrc = 0.
        ls_segm_bgm = ls_segm-sdata.
      ENDIF.

      CASE ls_segm_bgm-document_name_code.
        WHEN zif_agc_datex_utilmd_co=>gc_msg_category_z22.
** Netzbetreiberwechsel
          CALL METHOD me->z_det_datex_basicproc_z22.

        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD get_process_parameters.
***************************************************************************************************
* THIMEL.R 20150113 Einführung CL
*   Bei alten Basisprozessen ggf. noch weitere Parameter mitgeben
***************************************************************************************************
    DATA: ls_edexbasicprocpar TYPE edexbasicprocpar,
          ls_edexprocparval   TYPE edexprocparval.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_amid>           TYPE /idxgc/s_amid_details.

    CALL METHOD super->get_process_parameters
      CHANGING
        ch_task_data       = ch_task_data
        cht_parameter      = cht_parameter
        cht_interface_data = cht_interface_data.

    SELECT SINGLE * FROM edexbasicprocpar INTO ls_edexbasicprocpar
      WHERE dexbasicproc = me->mv_dexbasicproc AND
          ( dexprocpartype = 'EIDESWTMDCAT' OR dexprocpartype = 'E_DEXCOMEV_DATA_CHANGED_IMP' ).
    CASE ls_edexbasicprocpar-dexprocpartype.
      WHEN 'EIDESWTMDCAT'.
        READ TABLE me->mr_process_data->gs_process_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
        IF sy-subrc = 0.
          ls_edexprocparval-dexprocparno  = ls_edexbasicprocpar-dexprocparno.
          ls_edexprocparval-dexprocparval = <fs_proc_step_data>-docname_code.
          INSERT ls_edexprocparval INTO TABLE cht_parameter.
        ENDIF.
      WHEN 'E_DEXCOMEV_DATA_CHANGED_IMP'.
        READ TABLE me->mr_process_data->gs_process_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.
        IF sy-subrc = 0.
          READ TABLE <fs_proc_step_data>-amid ASSIGNING <fs_amid> INDEX 1.
          IF sy-subrc = 0.
            ls_edexprocparval-dexprocparno  = ls_edexbasicprocpar-dexprocparno.
            IF <fs_amid>-amid = zif_agc_datex_utilmd_co=>gc_amid_11030 OR
               <fs_amid>-amid = zif_agc_datex_utilmd_co=>gc_amid_11033 OR
               <fs_amid>-amid = zif_agc_datex_utilmd_co=>gc_amid_11103 OR
               <fs_amid>-amid = zif_agc_datex_utilmd_co=>gc_amid_11104.
              ls_edexprocparval-dexprocparval = 'ZQ_BILARE'.
            ELSE.
              ls_edexprocparval-dexprocparval = 'ZQ_NBILARE'.
            ENDIF.
            INSERT ls_edexprocparval INTO TABLE cht_parameter.
          ENDIF.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


METHOD PROCESS_INBOUND_PROCESS.
***----------------------------------------------------------------------*
***
*** Author: SAP Custom Development, 2014
**
*** Usage:
*** Logic for all inbound processes
***
***
*** Status: Completed
**----------------------------------------------------------------------*
*** Change History:
**
*** Mar. 2014: Created
**----------------------------------------------------------------------*
* THIMEL.R 20150210 Einführung CL
*   APERAK Prüfung eingebaut. Änderungen sind mit ...+++... markiert.
*-----------------------------------------------------------------------*

  DATA:
    ls_task_data      TYPE        edextask_data_intf,
    lt_interface_data TYPE        abap_parmbind_tab,
    lt_parameter      TYPE        idexprocparval,
    lt_task           TYPE        iedextask,
    lt_error          TYPE        tisu00_message,
    ls_idoc_status    TYPE        bdidocstat,
    ls_msg            TYPE        isu00_message,
    lx_previous       TYPE REF TO /idxgc/cx_general.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DATA: lr_aperak_handler TYPE REF TO zcl_aperak_handler_001,
        lv_err_code       TYPE        /idxgc/de_err_code,
        ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
        ls_error_ref      TYPE        /idxgc/s_error_ref_details,
        ls_pod            TYPE        /idxgc/s_pod_info_details,
        ls_diverse        TYPE        /idxgc/s_diverse_details.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  FIELD-SYMBOLS:
    <fs_proc_step> TYPE /idxgc/s_proc_step_data,
    <fs_task>      TYPE edextask.

  CLEAR me->mt_process_data.

* 1. Parse single IDoc data to the data container

  CALL METHOD me->process_inbound_mapping.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* APERAK Prüfung
  CREATE OBJECT lr_aperak_handler
    EXPORTING
      is_proc_data        = me->ms_process_data
    EXCEPTIONS
      no_service_provider = 1
      error_occurred      = 2
      OTHERS              = 3.
  IF sy-subrc = 1.
    MESSAGE e100(zagc_datex_general) INTO gv_mtext.
    CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
  elseif sy-subrc <> 0.
    MESSAGE e102(zagc_datex_general) INTO gv_mtext.
    CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
  ENDIF.

  lv_err_code = lr_aperak_handler->execute_checks_utilmd_pdoc_001( is_proc_data = me->ms_process_data ).

  IF lv_err_code IS NOT INITIAL.

    ls_proc_step_data = lr_aperak_handler->get_proc_step_data( ). "Hier aufrufen, da Fehler nach Versand gelöscht werden.

    CALL METHOD lr_aperak_handler->send_001
      EXCEPTIONS
        no_dexproc_found = 1
        error_occurred   = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      MESSAGE e101(zagc_datex_general) INTO gv_mtext.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ELSE.
      "APERAK-Versand im Status vermerken
      READ TABLE me->ms_process_data-steps INTO ls_proc_step_data INDEX 1.
      LOOP AT ls_proc_step_data-pod INTO ls_pod
        WHERE pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30 OR pod_type IS INITIAL.
        EXIT.
      ENDLOOP.
      READ TABLE ls_proc_step_data-diverse INTO ls_diverse INDEX 1.

      READ TABLE ls_proc_step_data-error_ref INTO ls_error_ref INDEX 1.

      CLEAR: ls_idoc_status.
      ls_idoc_status-msgid  = 'ZAGC_DATEX_GENERAL'.
      ls_idoc_status-msgno  = '110'.
      ls_idoc_status-msgty  = 'I'.
      ls_idoc_status-msgv1  = ls_error_ref-err_code.
      ls_idoc_status-msgv2  = ls_diverse-transaction_no.
      ls_idoc_status-msgv3  = ls_pod-ext_ui.
      ls_idoc_status-status = /idxgc/if_constants_ide=>gc_idoc_status_53.
      ls_idoc_status-docnum = me->ms_split_idoc-control-docnum.
      ls_idoc_status-uname  = sy-uname.
      ls_idoc_status-repid  = sy-repid.
      ls_idoc_status-routid = /idxgc/if_constants_ide=>gc_fm_comev_in.
      APPEND ls_idoc_status TO et_idoc_status.
      IF 1 = 2. MESSAGE i110(zagc_datex_general). ENDIF.
    ENDIF.

    "Bei Fehler Verarbeitung abbrechen.
    EXIT.
  ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* 2. Set original IDOC number and data exchange basic process
  READ TABLE me->mt_process_data INTO me->mr_process_data INDEX 1.
  IF sy-subrc <> 0.
*     No process data.
    MESSAGE e059(/idxgc/ide_add) INTO gv_mtext.
    CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.

  ELSE.
    READ TABLE me->mr_process_data->gs_process_data-steps ASSIGNING <fs_proc_step> INDEX 1.
    IF sy-subrc = 0.
      <fs_proc_step>-dexbasicproc = me->mv_dexbasicproc.
      <fs_proc_step>-idocnum      = me->ms_split_idoc-control-docnum.
      <fs_proc_step>-direct       = me->ms_split_idoc-control-direct.
      <fs_proc_step>-mescod       = me->mv_mescod.
      <fs_proc_step>-mestyp       = me->mv_mestyp.
      <fs_proc_step>-idoctp       = me->mv_idoctp.
      <fs_proc_step>-attribute    = me->mt_attribute.

    ELSE.
*       No process data.
      MESSAGE e059(/idxgc/ide_add) INTO gv_mtext.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ENDIF.
  ENDIF.

* 3. Prepare parameters for Start data exchange basic process
  CALL METHOD me->get_process_parameters
    CHANGING
      ch_task_data       = ls_task_data
      cht_parameter      = lt_parameter
      cht_interface_data = lt_interface_data.

* 5. Start data exchange process
* An error PDoc will be created if basic process can't be started, but the IDOC status should also be '53'
  CALL METHOD cl_isu_datex_controller=>start_ui_datex_basicprocess
    EXPORTING
      x_dexbasicproc     = me->mv_dexbasicproc
      xt_parameter       = lt_parameter
      x_task_data        = ls_task_data
      x_idoc_data        = me->ms_split_idoc
    IMPORTING
      yt_task            = lt_task
      yt_error           = lt_error
    CHANGING
      xyt_interface_data = lt_interface_data
    EXCEPTIONS
      error_occurred     = 1
      no_dexproc_found   = 2
      dexproc_not_unique = 3
      OTHERS             = 4.

  IF sy-subrc <> 0 OR lt_error IS NOT INITIAL.

* DEXSTATUS is set in GET_PROCESS_PARAMETERS with OK, so if data exchange process
* doesn't exit, clear the status
    LOOP AT lt_task ASSIGNING <fs_task>.
      IF <fs_task>-dexproc IS INITIAL.
        CLEAR: <fs_task>-dexstatus.
      ENDIF.
    ENDLOOP.

*   sometimes message will not be in lt_error, add this here
    IF sy-subrc <> 0.
      MOVE-CORRESPONDING sy TO ls_msg.
      APPEND ls_msg TO lt_error.
    ENDIF.

    mt_message = lt_error.
*   Create Error PDOC in the System
    CALL METHOD me->handle_unsolicited_msg
      EXPORTING
        it_interface_data = lt_interface_data
        it_task           = lt_task.

  ENDIF.

* set Single new porcess status
  IF mv_aggregated_idoc <> abap_true.
    ls_idoc_status-status = /idxgc/if_constants_ide=>gc_idoc_status_53.
    ls_idoc_status-docnum = me->ms_split_idoc-control-docnum.
    ls_idoc_status-uname  = sy-uname.
    ls_idoc_status-repid  = sy-repid.
    ls_idoc_status-routid = /idxgc/if_constants_ide=>gc_fm_comev_in.
    APPEND ls_idoc_status TO et_idoc_status.
  ENDIF.

ENDMETHOD.


  METHOD z_det_datex_basicproc_z22.
***************************************************************************************************
* Ermittlung Basisprozess für Netzbetreiberwechsel.
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150226 Einführung CL
***************************************************************************************************
    me->mv_dexbasicproc = zif_agc_datex_co=>gc_basicproc_req_change.
  ENDMETHOD.
ENDCLASS.
