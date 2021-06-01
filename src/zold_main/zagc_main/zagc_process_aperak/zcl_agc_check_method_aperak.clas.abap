class ZCL_AGC_CHECK_METHOD_APERAK definition
  public
  create public .

public section.

  interfaces /IDXGC/IF_CHECK_METHOD_APERAK .

  aliases CHECK_DISTRIBUTOR_ASSIGNMENT
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_DISTRIBUTOR_ASSIGNMENT .
  aliases CHECK_INTERNAL_REF
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_INTERNAL_REF .
  aliases CHECK_OBIS_KNOWN
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_OBIS_KNOWN .
  aliases CHECK_POD_EXIST
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_POD_EXIST .
  aliases CHECK_POD_PROVIDED_BY_TR
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_POD_PROVIDED_BY_TR .
  aliases CHECK_PRE_DECIMALS_MR
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_PRE_DECIMALS_MR .
  aliases CHECK_RECEIVED_APERAK
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_RECEIVED_APERAK .
  aliases CHECK_RECEIVER_AUTHORIZATION
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_RECEIVER_AUTHORIZATION .
  aliases CHECK_REFERENCE_EXIST
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_REFERENCE_EXIST .
  aliases CHECK_SENDER_AUTHORIZATION
    for /IDXGC/IF_CHECK_METHOD_APERAK~CHECK_SENDER_AUTHORIZATION .
  aliases IDENTIFY_POD_NODIALOG
    for /IDXGC/IF_CHECK_METHOD_APERAK~IDENTIFY_POD_NODIALOG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_CHECK_METHOD_APERAK IMPLEMENTATION.


  METHOD /idxgc/if_check_method_aperak~identify_pod_nodialog.
    "Kopie aus dem Standard (Klasse: /IDXGC/CL_CHECK_METHOD_APERAK)
    "Anpassung des Deregulierungsprozesses für Gerätereplikation

    FIELD-SYMBOLS: <fs_ref_process_data_extern> TYPE REF TO /idxgc/if_process_data_extern,
                   <fs_ref_process_log>         TYPE REF TO /idxgc/if_process_log.

    DATA:
      ls_check_result        TYPE        /idxgc/de_check_result,
      ls_proc_step_data_all  TYPE        /idxgc/s_proc_step_data_all,
      lr_process_data_step   TYPE REF TO /idxgc/if_process_data_step,
      lr_badi_business_check TYPE REF TO /idxgc/badi_business_check.

    DATA:
      ls_searchdata      TYPE /isidex/eident_searchdata,
      lv_dialogident     TYPE /isidex/e_dialogident,
      ls_address_details TYPE /idxgc/s_address_details,
      lv_mtext           TYPE string,
      lv_procvarid       TYPE /isidex/e_procvarid,
      lv_msgcategory     TYPE /isidex/e_msgcategory,
      lt_identmatrix     TYPE /isidex/teidentmatrix,
      lt_identresult     TYPE /isidex/teidentmatrix,
      ls_identresult     TYPE /isidex/eidentmatrix,
      ls_name_address    TYPE /idxgc/s_nameaddr_details,
      ls_meter_dev       TYPE /idxgc/s_meterdev_details,
      lv_identstatus     TYPE /isidex/e_identstatus,
      lv_deregproc       TYPE e_deregproc,
      lv_clear_buffer    TYPE kennzx.

    DATA:
      lx_previous TYPE REF TO /idxgc/cx_general.

    ASSIGN cr_data->*     TO  <fs_ref_process_data_extern> .
    ASSIGN cr_data_log->* TO  <fs_ref_process_log>.

    lr_process_data_step ?= <fs_ref_process_data_extern>.

    TRY.
*    Get process step data by key.
        CALL METHOD lr_process_data_step->get_process_step_data
          EXPORTING
            is_process_step_key  = is_process_step_key
          RECEIVING
            rs_process_step_data = ls_proc_step_data_all.
      CATCH /idxgc/cx_process_error INTO lx_previous.
        <fs_ref_process_log>->add_message_to_process_log( ).
        CALL METHOD /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    CHECK NOT ls_proc_step_data_all IS INITIAL.
* Check if the pod has identified manually .
    READ TABLE ls_proc_step_data_all-check WITH KEY check_result = /idxgc/if_constants_add=>gc_cr_pod_identified_manually
           TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      ls_check_result = /idxgc/if_constants_add=>gc_cr_pod_identified_manually.
      APPEND  ls_check_result TO et_check_result.

      MESSAGE s152(/idxgc/utility_add) WITH ls_proc_step_data_all-ext_ui
                                       INTO lv_mtext.
      <fs_ref_process_log>->add_message_to_process_log(
                           EXPORTING is_business_log = /idxgc/if_constants=>gc_true ).

      RETURN.
    ENDIF.


*-----------------------------------------------*
*Prepare the parameters for identify PoD
    ls_searchdata-keydate = ls_proc_step_data_all-proc_date.

    lv_dialogident = /isidex/cl_isu_ident_controler=>co_nodialog.

**Set Message Category by BMID now is hard code.
    lv_msgcategory = /isidex/cl_isu_ident_controler=>co_msg_req.

    IF ls_proc_step_data_all-proc_id = zif_agc_devrepl_constants=>ac_proc_id_8012 OR
       ls_proc_step_data_all-proc_id = zif_agc_devrepl_constants=>ac_proc_id_8011 OR
       ls_proc_step_data_all-proc_id = zif_agc_devrepl_constants=>ac_proc_id_8013 OR
       ls_proc_step_data_all-proc_id = zif_agc_devrepl_constants=>ac_proc_id_8014.
      lv_deregproc = 'BACKUPSPL'.
    ELSE.
      lv_deregproc = cl_isu_ide_deregprocess=>co_deregproc_gridusage.
    ENDIF.
**Get customer info
    READ TABLE ls_proc_step_data_all-name_address INTO ls_name_address WITH KEY
                party_func_qual = /idxgc/if_pd_wf_constants=>gc_party_qual_ud.

    IF sy-subrc = 0.
      IF ls_name_address-name_format_code EQ /idxgc/if_constants_ide=>gc_name_format_code_person.
        ls_searchdata-name1       = ls_name_address-fam_comp_name1.
        ls_searchdata-name2       = ls_name_address-first_name1.
      ELSEIF ls_name_address-name_format_code EQ /idxgc/if_constants_ide=>gc_name_format_code_company.
        ls_searchdata-name1       = ls_name_address-fam_comp_name1.
        ls_searchdata-name2       = ls_name_address-fam_comp_name2.
      ENDIF.
    ENDIF.

**Get address
    READ TABLE ls_proc_step_data_all-name_address INTO ls_name_address WITH KEY
                party_func_qual = /idxgc/if_constants_add=>gc_party_qual_dp.

    IF sy-subrc = 0.
      ls_searchdata-housenr     = ls_name_address-houseid.
      ls_searchdata-housenrext  = ls_name_address-houseid_add.
      ls_searchdata-street      = ls_name_address-streetname.
      ls_searchdata-postcode    = ls_name_address-postalcode.
      ls_searchdata-city        = ls_name_address-cityname.
    ENDIF.
    READ TABLE ls_proc_step_data_all-meter_dev INTO ls_meter_dev INDEX 1.
    IF sy-subrc EQ 0.
      ls_searchdata-meternr = ls_meter_dev-meternumber.
      TRANSLATE ls_searchdata-meternr TO UPPER CASE.     "#EC TRANSLANG
    ENDIF.

    ls_searchdata-ext_ui      = ls_proc_step_data_all-ext_ui.
    ls_searchdata-spartyp     = ls_proc_step_data_all-spartyp.
    ls_searchdata-serviceid   = ls_proc_step_data_all-assoc_servprov.

*Call BAdi to modify search data.
    GET BADI lr_badi_business_check.
    IF lr_badi_business_check IS NOT INITIAL.
      TRY .
          CALL BADI lr_badi_business_check->modify_pod_ident_searchdata
            EXPORTING
              is_proc_step_data_all = ls_proc_step_data_all
            CHANGING
              cs_searchdata         = ls_searchdata
              cv_clear_buffer       = lv_clear_buffer
              cv_deregproc          = lv_deregproc
              cv_msgcategory        = lv_msgcategory
              cv_procvarid          = lv_procvarid
              cr_data               = cr_data
              cr_data_log           = cr_data_log.
        CATCH /idxgc/cx_utility_error INTO lx_previous .
          <fs_ref_process_log>->add_message_to_process_log( ).
          CALL METHOD /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.
    ENDIF.

*-----------------------------------------------*
*Start Point of Delivery Identification
    CALL METHOD /isidex/cl_isu_ident_controler=>identify_pod
      EXPORTING
        x_deregproc      = lv_deregproc
        x_dialogident    = lv_dialogident
        x_clear_buffer   = lv_clear_buffer
        x_msgcategory    = lv_msgcategory
        x_searchdata     = ls_searchdata
      IMPORTING
        yt_identmatrix   = lt_identmatrix
        yt_identresult   = lt_identresult
        y_identstatus    = lv_identstatus
      CHANGING
        xy_procvarid     = lv_procvarid
      EXCEPTIONS
        not_found        = 1
        error_occurred   = 2
        wrong_input_data = 3
        OTHERS           = 4.

    IF lv_identstatus = /isidex/cl_isu_ident_controler=>co_identified.
      READ TABLE lt_identresult INTO ls_identresult INDEX 1.
**Table has only 1 row now!
      IF sy-subrc = 0.
        ls_proc_step_data_all-int_ui      = ls_identresult-int_ui.
        ls_proc_step_data_all-ext_ui      = ls_identresult-ext_ui.
        ls_check_result = /idxgc/if_constants_add=>gc_cr_pod_identified.
        APPEND  ls_check_result TO et_check_result.

* The status of the point of delivery identification is 'Identified'
        MESSAGE s000(/idxgc/utility_add) WITH ls_identresult-ext_ui
                                         INTO lv_mtext.
        <fs_ref_process_log>->add_message_to_process_log(
                             EXPORTING is_business_log = /idxgc/if_constants=>gc_true ).

* update the EXT_UI to process step data.
        CALL METHOD lr_process_data_step->update_process_step_data
          EXPORTING
            is_process_step_data = ls_proc_step_data_all.
      ELSE.
**No results for point of delivery identification
        ls_check_result = /idxgc/if_constants_add=>gc_cr_pod_not_identified.
        APPEND  ls_check_result TO et_check_result.
* save message log.
        MESSAGE e073(/isidex/edereg) INTO lv_mtext.
        <fs_ref_process_log>->add_message_to_process_log(
                       EXPORTING is_business_log = /idxgc/if_constants=>gc_true ).
      ENDIF.

    ELSEIF lv_identstatus = /isidex/cl_isu_ident_controler=>co_dupplicate_ident.
*   case of dupplicate indentified.
      ls_check_result = /idxgc/if_constants_add=>gc_cr_pod_not_unique.
      APPEND  ls_check_result TO et_check_result.
**The status of the PoD identification is 'Not Uniquely Identified'
      MESSAGE e074(/isidex/edereg) INTO lv_mtext.
      <fs_ref_process_log>->add_message_to_process_log(
                       EXPORTING is_business_log = /idxgc/if_constants=>gc_true ).

    ELSE.
*In other cases, Pod is not indentified.
      ls_check_result = /idxgc/if_constants_add=>gc_cr_pod_not_identified.
      APPEND  ls_check_result TO et_check_result.
**The status of the point of delivery identification is 'Not Identified'
      MESSAGE e073(/isidex/edereg) INTO lv_mtext.
      <fs_ref_process_log>->add_message_to_process_log(
                       EXPORTING is_business_log = /idxgc/if_constants=>gc_true ).

    ENDIF.




  ENDMETHOD.
ENDCLASS.
