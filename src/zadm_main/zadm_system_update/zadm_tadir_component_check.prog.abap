*&---------------------------------------------------------------------*
*& Report ZADM_TADIR_COMPONENT_CHECK
*&---------------------------------------------------------------------*
*&
* logfile written to
* DIR_TRANS/tmp/UPGTADIRCHECK.<sid>   in case of standalone execution
* DIR_PUT/tmp/UPGTADIRCHECK.<sid>     in case of execution during upgrade
*&---------------------------------------------------------------------*
REPORT zadm_tadir_component_check.

TYPE-POOLS: abap, smodi.

TABLES sscrfields.

TYPES: ty_trmess_tab TYPE TABLE OF trmess_int.

PARAMETERS: p_summod TYPE abap_bool DEFAULT space NO-DISPLAY.
PARAMETERS: p_check TYPE abap_bool RADIOBUTTON GROUP rad1 DEFAULT 'X' USER-COMMAND check,
            p_cmpta TYPE abap_bool RADIOBUTTON GROUP rad1.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE cmp.
PARAMETERS: p_cmpchk TYPE dlvunit MODIF ID cmp.
SELECTION-SCREEN END OF BLOCK block1.

PARAMETERS: p_fixloc TYPE abap_bool RADIOBUTTON GROUP rad1,
            p_fixnoc TYPE abap_bool RADIOBUTTON GROUP rad1.


SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE fix.
SELECT-OPTIONS: p_comps FOR ('DLVUNIT') MODIF ID fix.
PARAMETERS: p_trkorr TYPE e071-trkorr  MODIF ID fix.
SELECTION-SCREEN END OF BLOCK block2.

INITIALIZATION.
  PERFORM initialization.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_trkorr.
  PERFORM value_request_trkorr CHANGING p_trkorr.

AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output.

AT SELECTION-SCREEN.
  PERFORM at_selection_screen_output.

AT SELECTION-SCREEN ON p_trkorr.
  IF p_check = abap_true OR p_cmpta = abap_true.
  ELSEIF sscrfields-ucomm = 'ONLI' AND p_trkorr IS INITIAL OR p_trkorr = '*'.
    MESSAGE 'Please enter a transport request' TYPE 'E'.
  ELSEIF sscrfields-ucomm = 'ONLI'.
    SELECT SINGLE trkorr FROM e070 INTO sy-msgv2
     WHERE trkorr = p_trkorr AND
           ( trstatus = 'D' OR trstatus = 'L' ).
    IF sy-subrc <> 0.
      MESSAGE e013(tg) WITH 'Transport' p_trkorr 'is not usable or does not exist'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON p_cmpchk.
  IF p_cmpta = abap_true AND sscrfields-ucomm = 'ONLI' AND p_cmpchk IS INITIAL OR p_cmpchk CA '*'.
    MESSAGE 'Please enter one component to check in detail' TYPE 'E'.
  ENDIF.

AT SELECTION-SCREEN ON p_comps.
  IF p_check = abap_true OR p_cmpta = abap_true OR p_fixloc = abap_true.
  ELSEIF sscrfields-ucomm = 'ONLI' AND p_comps[] IS INITIAL.
    MESSAGE 'Please enter at least one component for cleanup' TYPE 'E'.
  ENDIF.

FORM initialization.
  CONSTANTS: co_language_en TYPE c LENGTH 1 VALUE 'E'.

  TYPES: tt_textpool TYPE STANDARD TABLE OF textpool.

  DATA: lt_textpool_en     TYPE tt_textpool.

  DATA: ls_textpool TYPE textpool.

  FIELD-SYMBOLS: <ls_textpool>        TYPE textpool,
                 <ls_textpool_update> TYPE textpool.

  fix = 'Select components for cleaning up inconsistencies: '.
  cmp = 'Select component for delivery check: '.

  CLEAR: ls_textpool.
  ls_textpool-id      = 'R'. " Report Short Text
  ls_textpool-key     = ''.
  ls_textpool-entry   = 'Component Consistency Check'.      "#EC NOTEXT
  ls_textpool-length  = 40.
  APPEND ls_textpool TO lt_textpool_en.


  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_CHECK'.
  ls_textpool-entry+8 = 'Check component consistency'.      "#EC NOTEXT
  ls_textpool-length  = 40.
  APPEND ls_textpool TO lt_textpool_en.
  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_CHKTA'.
  ls_textpool-entry+8 = 'Check delivery transports'.        "#EC NOTEXT
  ls_textpool-length  = 40.
  APPEND ls_textpool TO lt_textpool_en.

  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_CMPTA'.
  ls_textpool-entry+8 = 'Check delivery for components'.    "#EC NOTEXT
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.
  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_CMPCHK'.
  ls_textpool-entry+8 = 'Component to check'.               "#EC NOTEXT
  REPLACE 'XXX' WITH sy-sysid INTO ls_textpool-entry.
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.

  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_FIXLOC'.
  ls_textpool-entry+8 = 'Correct local and home objects'.   "#EC NOTEXT
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.
  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_FIXCMP'.
  ls_textpool-entry+8 = 'Correct registered components'.    "#EC NOTEXT
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.
  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_FIXNOC'.
  ls_textpool-entry+8 = 'Correct not registered comps'.     "#EC NOTEXT
  REPLACE 'XXX' WITH sy-sysid INTO ls_textpool-entry.
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.

  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_COMPS'.
  ls_textpool-entry+8 = 'Components to correct:'.           "#EC NOTEXT
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.
  CLEAR: ls_textpool.
  ls_textpool-id      = 'S'. " Selection Screen Parameter: Text Label
  ls_textpool-key     = 'P_TRKORR'.
  ls_textpool-entry+8 = 'Transport for recording:'.         "#EC NOTEXT
  ls_textpool-length  = strlen( ls_textpool-entry ).
  APPEND ls_textpool TO lt_textpool_en.

  INSERT TEXTPOOL sy-repid FROM lt_textpool_en LANGUAGE 'E'.
  IF sy-langu <> 'E'.
    INSERT TEXTPOOL sy-repid FROM lt_textpool_en LANGUAGE sy-langu.
  ENDIF.
ENDFORM.


FORM at_selection_screen_output.

  LOOP AT SCREEN INTO screen.                        "#EC CI_USE_WANTED
    IF screen-group1 EQ 'FIX'.
      IF p_check = abap_true OR p_cmpta = abap_true OR
        ( p_fixloc = abap_true AND screen-name <> 'P_TRKORR' ).
        screen-active    = '1'.
        screen-input     = '0'.
        screen-invisible = '0'.
      ELSE.
        screen-active    = '1'.
        screen-input     = '1'.
        screen-invisible = '0'.
      ENDIF.
      MODIFY screen FROM screen.                     "#EC CI_USE_WANTED
    ELSEIF screen-group1 = 'CMP'.
      IF p_cmpta = abap_true.
        screen-active    = '1'.
        screen-input     = '1'.
        screen-invisible = '0'.
      ELSE.
        screen-active    = '1'.
        screen-input     = '0'.
        screen-invisible = '0'.
      ENDIF.
      MODIFY screen FROM screen.                     "#EC CI_USE_WANTED
    ENDIF.
  ENDLOOP.
ENDFORM.
FORM value_request_trkorr CHANGING p_trkorr TYPE e071-trkorr.
  TYPES: BEGIN OF ty_trkorr,
           trkorr  TYPE trkorr,
           as4text TYPE as4text,
         END OF ty_trkorr.
  DATA: l_trkorrs TYPE STANDARD TABLE OF ty_trkorr,
        l_return  LIKE ddshretval OCCURS 0 WITH HEADER LINE.

  SELECT e070~trkorr as4text FROM e070 LEFT JOIN e07t ON e070~trkorr = e07t~trkorr AND langu = sy-langu
    INTO TABLE l_trkorrs
    WHERE as4user = sy-uname AND trstatus = 'D' AND
  ( trfunction = 'K' OR trfunction = 'T' ).
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'TRKORR'   "field of internal table
      value_org  = 'S'
    TABLES
      value_tab  = l_trkorrs
      return_tab = l_return.
  p_trkorr = l_return-fieldval.
  REFRESH l_trkorrs.
ENDFORM.

CLASS lcx_exception DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA: m_error_tab TYPE ty_trmess_tab READ-ONLY.
    METHODS: constructor
      IMPORTING p_error_tab TYPE ty_trmess_tab OPTIONAL.
ENDCLASS.
CLASS lcx_exception IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    m_error_tab[] = p_error_tab[].
  ENDMETHOD.
ENDCLASS.


CLASS cl_upg_logger_620 DEFINITION FINAL .

  PUBLIC SECTION.
    TYPE-POOLS abap .

    CONSTANTS c_logtype_trans TYPE tstrf01-acttype VALUE 'T'. "#EC NOTEXT
    CONSTANTS c_logtype_upg TYPE tstrf01-acttype VALUE 'P'. "#EC NOTEXT

    METHODS constructor
      IMPORTING
        !iv_filename  TYPE trfilename
        !iv_report    TYPE sy-repid OPTIONAL
        !iv_logtype   TYPE tstrf01-dirtype DEFAULT 'T'
        !iv_skip_init TYPE abap_bool OPTIONAL
        !iv_module    TYPE sy-repid OPTIONAL .
    METHODS write_log_line_s
      IMPORTING
        !iv_severity TYPE sprot-severity DEFAULT space
        !iv_ag       TYPE sprot-ag DEFAULT 'TG'
        !iv_msgnr    TYPE sprot-msgnr DEFAULT '010'
        !iv_var1     TYPE clike OPTIONAL
        !iv_var2     TYPE clike OPTIONAL
        !iv_var3     TYPE clike OPTIONAL
        !iv_var4     TYPE clike OPTIONAL .
    METHODS write_symsg_or_log_line_s
      IMPORTING
        !iv_severity TYPE sprot-severity DEFAULT space
        !iv_ag       TYPE sprot-ag DEFAULT 'TG'
        !iv_msgnr    TYPE sprot-msgnr DEFAULT '010'
        !iv_var1     TYPE clike OPTIONAL
        !iv_var2     TYPE clike OPTIONAL
        !iv_var3     TYPE clike OPTIONAL
        !iv_var4     TYPE clike OPTIONAL .
    METHODS flush_log .
    METHODS close_log .
    METHODS open_log .
    METHODS write_log_text
      IMPORTING
        !iv_severity TYPE sprot-severity DEFAULT space
        !iv_ag       TYPE sprot-ag DEFAULT 'TG'
        !iv_msgnr    TYPE sprot-msgnr DEFAULT '010'
        !iv_text     TYPE clike .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPE-POOLS abap .
    DATA m_skip_intro TYPE abap_bool .
    DATA m_log_type TYPE tstrf01-acttype .
    DATA m_protfile TYPE tstrf01-file .
    DATA m_startdate LIKE sy-datum .
    DATA m_starttime LIKE sy-uzeit .
    DATA:
      m_protocol_tab TYPE TABLE OF sprot_u .
    DATA m_report TYPE sy-repid .
    DATA m_module TYPE sy-repid.

    DATA: m_log_opened TYPE abap_bool.

    METHODS write_log_header .
    METHODS write_log_footer .
ENDCLASS.



CLASS cl_upg_logger_620 IMPLEMENTATION.


  METHOD close_log .
    IF m_log_opened = abap_false.
      CALL METHOD open_log.
    ENDIF.
    IF m_skip_intro = abap_false.
      CALL METHOD write_log_footer.
    ENDIF.
    CALL METHOD flush_log.
  ENDMETHOD.


  METHOD constructor .
    DATA: l_file TYPE trfilename.
    DATA lv_sid(3) TYPE c.
    DATA lv_filename TYPE trfilename.

    ASSERT iv_filename IS NOT INITIAL.

    m_report = iv_report.
    m_module = iv_module.
    m_skip_intro = iv_skip_init.

    SPLIT iv_filename AT '.' INTO lv_filename lv_sid.
    IF lv_sid = sy-sysid.
      l_file = iv_filename.
    ELSE.

      CONCATENATE iv_filename '.' sy-sysid INTO l_file.
    ENDIF.
    m_log_type = iv_logtype.

    CALL FUNCTION 'STRF_SETNAME'
      EXPORTING
        dirtype    = m_log_type
        filename   = l_file
        subdir     = 'tmp'
      IMPORTING
        file       = m_protfile
      EXCEPTIONS
        wrong_call = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      MESSAGE a150(tg) WITH sy-subrc.
    ENDIF.

  ENDMETHOD.


  METHOD flush_log .
    IF m_log_opened = abap_false.
      CALL METHOD open_log.
    ENDIF.

    CALL FUNCTION 'SUBST_WRITE_PROTOCOL'
      EXPORTING
        acttype      = m_log_type
        ifname       = m_protfile
      IMPORTING
        efname       = m_protfile
      TABLES
        p_tab        = m_protocol_tab
      EXCEPTIONS
        write_failed = 01
        OTHERS       = 02.

    IF sy-subrc <> 0.
      MESSAGE a154(tg) WITH sy-subrc.
    ENDIF.
    CLEAR m_protocol_tab[].
  ENDMETHOD.


  METHOD open_log .
    IF m_log_opened = abap_false.
      m_log_opened = abap_true.
      IF m_skip_intro = abap_false.
        CALL METHOD write_log_header.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD write_log_footer .
    DATA stopdate LIKE sy-datum.
    DATA stoptime LIKE sy-uzeit.
    DATA timestring TYPE sy-msgv1.
    DATA datestring TYPE sy-msgv1.

    GET TIME.

    stopdate = sy-datum.
    stoptime = sy-uzeit.


    WRITE m_startdate TO datestring USING EDIT MASK '__.__.____'.
    WRITE m_starttime TO timestring USING EDIT MASK '__:__:__'.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '039'.
    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '011'.

    IF m_report IS NOT INITIAL.
      sy-msgv1 = m_report.
      CALL METHOD write_log_line_s
        EXPORTING
          iv_severity = space
          iv_msgnr    = '037'
          iv_var1     = sy-msgv1.
    ELSEIF m_module IS NOT INITIAL.
      sy-msgv1 = m_module.
      CALL METHOD write_log_line_s
        EXPORTING
          iv_severity = space
          iv_msgnr    = '036'
          iv_var1     = sy-msgv1.
    ENDIF.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '040'
        iv_var1     = datestring
        iv_var2     = timestring.

    WRITE stopdate TO datestring(10) USING EDIT MASK '__.__.____'.
    WRITE stoptime TO timestring(8) USING EDIT MASK '__:__:__'.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '041'
        iv_var1     = datestring
        iv_var2     = timestring.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '011'.
    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '039'.
  ENDMETHOD.


  METHOD write_log_header .
    DATA timestring TYPE sy-msgv1.
    DATA datestring TYPE sy-msgv1.

    GET TIME.
    m_startdate = sy-datum.
    m_starttime = sy-uzeit.

    WRITE m_startdate TO datestring(10) USING EDIT MASK '__.__.____'.
    WRITE m_starttime TO timestring(8) USING EDIT MASK '__:__:__'.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '039'.
    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '011'.

    IF m_report IS NOT INITIAL.
      sy-msgv1 = m_report.
      CALL METHOD write_log_line_s
        EXPORTING
          iv_severity = space
          iv_msgnr    = '037'
          iv_var1     = sy-msgv1.
    ELSEIF m_module IS NOT INITIAL.
      sy-msgv1 = m_module.
      CALL METHOD write_log_line_s
        EXPORTING
          iv_severity = space
          iv_msgnr    = '036'
          iv_var1     = sy-msgv1.
    ENDIF.


    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '040'
        iv_var1     = datestring
        iv_var2     = timestring.

    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '011'.
    CALL METHOD write_log_line_s
      EXPORTING
        iv_severity = space
        iv_msgnr    = '039'.
  ENDMETHOD.


  METHOD write_log_line_s .
    DATA: l_var1  LIKE sy-msgv1,
          l_var2  LIKE sy-msgv2,
          l_var3  LIKE sy-msgv3,
          l_var4  LIKE sy-msgv4,
          l_level TYPE sprot-level.

    IF m_log_opened = abap_false.
      CALL METHOD open_log.
    ENDIF.

    l_var1 = iv_var1.
    l_var2 = iv_var2.
    l_var3 = iv_var3.
    l_var4 = iv_var4.
    CASE iv_severity.
      WHEN 'A'.
        l_level = 1.
      WHEN 'E'.
        l_level = 2.
      WHEN 'W'.
        l_level = 3.
      WHEN OTHERS.
        l_level = 4.
    ENDCASE.
    CALL FUNCTION 'SUBST_APPEND_PROTOCOL'
      EXPORTING
        l_level    = l_level
        l_severity = iv_severity
        l_msag     = iv_ag
        l_msgnr    = iv_msgnr
        l_v1       = l_var1
        l_v2       = l_var2
        l_v3       = l_var3
        l_v4       = l_var4
      TABLES
        p_tab      = m_protocol_tab.
  ENDMETHOD.


  METHOD write_log_text .
    DATA: l_text TYPE string,
          l_var1 TYPE sy-msgv1,
          l_var2 TYPE sy-msgv1,
          l_var3 TYPE sy-msgv1,
          l_var4 TYPE sy-msgv1.

    l_text = iv_text.

    WHILE l_text IS NOT INITIAL.
      CLEAR: l_var1, l_var2, l_var3, l_var4.
      l_var1 = l_text.
      SHIFT l_text BY 50 PLACES LEFT IN CHARACTER MODE.
      IF l_text IS NOT INITIAL.
        l_var2 = l_text.
        SHIFT l_text BY 50 PLACES LEFT IN CHARACTER MODE.
      ENDIF.
      IF l_text IS NOT INITIAL.
        l_var3 = l_text.
        SHIFT l_text BY 50 PLACES LEFT IN CHARACTER MODE.
      ENDIF.
      IF l_text IS NOT INITIAL.
        l_var4 = l_text.
        SHIFT l_text BY 50 PLACES LEFT IN CHARACTER MODE.
      ENDIF.
      CALL METHOD write_log_line_s
        EXPORTING
          iv_severity = iv_severity
          iv_ag       = iv_ag
          iv_msgnr    = iv_msgnr
          iv_var1     = l_var1
          iv_var2     = l_var2
          iv_var3     = l_var3
          iv_var4     = l_var4.
    ENDWHILE.

  ENDMETHOD.


  METHOD write_symsg_or_log_line_s .
    DATA: l_msgnr        TYPE sprot-msgnr.

    IF sy-msgid IS NOT INITIAL AND sy-msgno IS NOT INITIAL.
      l_msgnr = sy-msgno.
      write_log_line_s(
        EXPORTING
          iv_severity = iv_severity
          iv_ag       = sy-msgid
          iv_msgnr    = l_msgnr
          iv_var1     = sy-msgv1
          iv_var2     = sy-msgv2
          iv_var3     = sy-msgv3
          iv_var4     = sy-msgv4 ).
    ELSE.
      write_log_line_s(
        EXPORTING
          iv_severity = iv_severity
          iv_ag       = iv_ag
          iv_msgnr    = iv_msgnr
          iv_var1     = iv_var1
          iv_var2     = iv_var2
          iv_var3     = iv_var3
          iv_var4     = iv_var4 ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_tadir_checker DEFINITION CREATE PUBLIC.
  PUBLIC SECTION.

    CONSTANTS: c_logname                      TYPE tstrf01-filename VALUE 'UPGCOMPONENTCHECK',
               c_action_check                 TYPE c VALUE 'A',
               c_action_fixnocomp             TYPE c VALUE 'C',
               c_action_fixlocal              TYPE c VALUE 'D',
               c_action_detail_delivery_check TYPE c VALUE 'E'.

    TYPES: ty_e071_tab  TYPE STANDARD TABLE OF e071,
           ty_tadir_tab TYPE STANDARD TABLE OF tadir,
           ty_comps_tab TYPE RANGE OF dlvunit.

    CLASS-METHODS:

      is_upgrade_running
        RETURNING VALUE(p_target_rel) TYPE puttb-saprelease.

    METHODS:
      constructor
        IMPORTING p_logger      TYPE REF TO cl_upg_logger_620 OPTIONAL
                  p_is_sum_mode TYPE abap_bool
                  p_check       TYPE abap_bool DEFAULT 'X'
                  p_check_ta    TYPE abap_bool DEFAULT space
                  p_fixnocomp   TYPE abap_bool DEFAULT space
                  p_fixloc      TYPE abap_bool DEFAULT space
                  p_comps4fix   TYPE ty_comps_tab
                  p_trkorr      TYPE trkorr,
      is_customer_system
        RETURNING VALUE(p_is_customer_system) TYPE abap_bool,
      run,
      check,
      close_logger.

  PROTECTED SECTION.
    TYPES: BEGIN OF ty_tadir_reduced,
             pgmid     TYPE tadir-pgmid,
             object    TYPE tadir-object,
             obj_name  TYPE tadir-obj_name,
             devclass  TYPE tadir-devclass,
             component TYPE tadir-component,
           END OF ty_tadir_reduced,
           ty_tadir_reduced_tab TYPE STANDARD TABLE OF ty_tadir_reduced,
           BEGIN OF ty_devc_comp,
             devclass TYPE devclass,
             dlvunit  TYPE dlvunit,
           END OF ty_devc_comp,
           BEGIN OF ty_sobjs,
             object             TYPE tadir-obj_name,
             has_exchange_parts TYPE abap_bool,
           END OF ty_sobjs,
           BEGIN OF ty_r3tr_limu_exception,
             r3tr_object TYPE tadir-object,
             limu_object TYPE tadir-object,
           END OF ty_r3tr_limu_exception.

    DATA: m_logger                       TYPE REF TO cl_upg_logger_620,
          m_action                       TYPE c,
          m_is_sum_mode                  TYPE abap_bool,
          m_logtype                      TYPE tstrf01-acttype,
          m_sapvers                      TYPE puttb-saprelease,
          m_dump_file_dir                TYPE tstrf01-subdir,
          m_trkorr                       TYPE trkorr,
          m_comps4fix                    TYPE ty_comps_tab,
          m_comp4detail_delivery_check   TYPE dlvunit,
          m_wbotypes                     TYPE TABLE OF ko100,
          m_where_clause_local_home      TYPE string,
          m_where_clause_cvers_comps     TYPE string,
          m_sap_comps_to_ignore          TYPE TABLE OF dlvunit,
          m_objects_with_exchange        TYPE SORTED TABLE OF ty_sobjs
                                            WITH UNIQUE KEY object,
          m_delivery_check_r3tr_limu_map TYPE TABLE OF ty_r3tr_limu_exception,
          m_sum_exception_list           TYPE SORTED TABLE OF e071 WITH UNIQUE KEY pgmid object obj_name,
          "workaround for non-existent check function for SOTR
          st_has_sotr_func               TYPE c LENGTH 1 VALUE '-',
          m_logfile_msg                  TYPE c LENGTH 200.

    METHODS:
      check_indexes_on_sap_tables,
      check_comps_no_cvers,
      check_comps_no_avers,
      check_local_home_objs,
      check_non_existing_packages,
      check_srcsystem_for_comps,
      check_for_rescued_comps,
      collect_sum_exception_list,
      check_delivery_tr_for_comp
        IMPORTING p_comp            TYPE dlvunit
                  p_delivery_tr_tab TYPE trkorrs,
      check_deliveries_for_comps
        IMPORTING p_comp4detail TYPE dlvunit OPTIONAL,
      write_summary_per_package
        IMPORTING p_comp    TYPE dlvunit
                  p_obj_tab TYPE ty_tadir_reduced_tab,
      log_proj_comp_inconsistencies
        IMPORTING p_comp TYPE dlvunit,
      dump_objects_to_file
        IMPORTING p_file         TYPE tstrf01-filename
                  p_include_comp TYPE abap_bool DEFAULT abap_false
                  p_objects      TYPE ty_tadir_reduced_tab,
      append_to_trkorr
        IMPORTING p_tadir_tab TYPE ty_tadir_tab
        EXPORTING p_error_tab TYPE ty_trmess_tab
        RAISING   lcx_exception,
      check_valid_obj_type
        IMPORTING p_object          TYPE tadir-object
        RETURNING VALUE(p_is_valid) TYPE abap_bool,
      update_tadir_add_2_trkorr
        IMPORTING p_component  TYPE dlvunit
                  p_src_system TYPE sy-sysid
        CHANGING  p_tadir_tab  TYPE ty_tadir_tab
                  p_error_tab  TYPE ty_trmess_tab
        RAISING   lcx_exception,
      check_object_existence
        IMPORTING p_obj           TYPE ty_tadir_reduced
        RETURNING VALUE(p_exists) TYPE abap_bool,
      has_exchange_parts
        IMPORTING p_object                  TYPE e071-object
        RETURNING VALUE(has_exchange_parts) TYPE abap_bool,
      collect_delivery_tr
        IMPORTING p_component               TYPE dlvunit
        RETURNING VALUE(p_delivery_trkorrs) TYPE trkorrs,
      fix_comps_no_cvers
        RAISING lcx_exception,
      fix_local_home_objs
        RAISING lcx_exception,
      process_error_tab
        IMPORTING p_error_tab TYPE ty_trmess_tab,
      write_log_separation
        IMPORTING p_start  TYPE abap_bool DEFAULT abap_false
                  p_module TYPE clike OPTIONAL.

ENDCLASS.
CLASS lcl_tadir_checker IMPLEMENTATION.
  METHOD constructor.
    DATA: l_logname  TYPE tstrf01-filename,
          l_packages TYPE TABLE OF devclass,
          l_tmp      TYPE string.
    FIELD-SYMBOLS: <package>       TYPE devclass,
                   <r3tr_limu_map> TYPE ty_r3tr_limu_exception.

    m_logtype  = cl_upg_logger_620=>c_logtype_trans.

    m_sapvers = is_upgrade_running( ).
    IF m_sapvers IS NOT INITIAL.
      m_logtype = cl_upg_logger_620=>c_logtype_upg.
      m_is_sum_mode = p_is_sum_mode.
      m_dump_file_dir = 'var'.
    ELSE.
      m_sapvers = sy-saprl.
      m_dump_file_dir = 'tmp'.
    ENDIF.

    l_logname = c_logname.

    IF p_check = abap_true.
      m_action = c_action_check.
    ELSEIF p_cmpta = abap_true.
      m_action = c_action_detail_delivery_check.
      CONCATENATE l_logname '_' p_cmpchk INTO l_logname.
      REPLACE ALL OCCURRENCES OF '\' IN l_logname WITH '_'.
      REPLACE ALL OCCURRENCES OF '/' IN l_logname WITH '_'.
    ELSEIF p_fixnocomp = abap_true.
      m_action = c_action_fixnocomp.
      CONCATENATE l_logname '_FIXNOCOMP' INTO l_logname.
    ELSEIF p_fixloc = abap_true.
      m_action = c_action_fixlocal.
      CONCATENATE l_logname '_FIXLOCAL' INTO l_logname.
    ELSE. "should not happen
      m_action = c_action_check.
    ENDIF.
    CASE m_action.
      WHEN c_action_check. "no further input
      WHEN c_action_detail_delivery_check.
        m_comp4detail_delivery_check = p_cmpchk.
      WHEN OTHERS.
        m_trkorr = p_trkorr.
        m_comps4fix = p_comps4fix.
    ENDCASE.

    IF p_logger IS NOT INITIAL.
      m_logger = p_logger.
    ELSE.
      CREATE OBJECT m_logger
        EXPORTING
          iv_filename = l_logname
          iv_logtype  = m_logtype
          iv_module   = 'COMPONENT_CONSISTENCY_CHECK'.
    ENDIF.

    CONCATENATE
        "these objects are exported but not imported by rddit006 (loctest_objects)
        'pgmid = ''R3TR'' and '
        'object not in (''FORM'', ''PRIN'', ''TEXT'', ''STYL'', ''STOB'', ''NOTE'', ''CINS'' ) and '
        'devclass not like ''T%'' and devclass not like ''$%'' and'
        "ignore special objects for 730-731 upgrade, intentionally home
        'devclass <> ''SPAK_UPGRADE'' and'
        "ignore special objects for DMO BW objects, intentionally home
        'devclass <> ''RS_UPG_TOOL'' and'
        "ignore Veri delivery
        'devclass not like ''SVER%'' and'
        'devclass not like ''SVET%'' and'
        'devclass <> ''SVED'' and devclass <> ''SVEP'' and devclass <> ''SVES'' and'
        "ignore package BKDG0 from CA-GTF-TS itself
        'not ( object = ''DEVC'' and obj_name = ''BKDG0'' ) and '
        "ignore package Z001, looks like a SAP delivery issue
        'not ( object = ''DEVC'' and obj_name = ''Z001'' ) and '
        "ignore package CLBW, a SAP delivery issue, see CM 452430/2016
        'devclass <> ''CLBW'' '
    INTO m_where_clause_local_home SEPARATED BY space.
    "collect SUM internal test objects
    CALL FUNCTION 'PA_GET_DESCENDANT_PACKAGES'
      EXPORTING
        i_package_name        = 'SUPG_INTERNAL'
        i_shortcut            = 'X'
      IMPORTING
        e_descendant_packages = l_packages
      EXCEPTIONS
        package_not_existing  = 1
        OTHERS                = 2.
    IF sy-subrc > 1.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'W'
          iv_ag       = 'TG'
          iv_msgnr    = '013'
          iv_var1     = 'Error retrieving package hierarchy for'
          iv_var2     = 'SUPG_INTERNAL'
          iv_var3     = '... ignoring' ).
    ELSE.
      APPEND 'SUPG_INTERNAL' TO l_packages.
      LOOP AT l_packages ASSIGNING <package>.
        l_tmp = <package>.
        REPLACE ALL OCCURRENCES OF `'` IN l_tmp WITH `''`.
        CONCATENATE `'` l_tmp `'` INTO l_tmp.
        CONCATENATE 'and devclass <> ' l_tmp  INTO l_tmp.
        CONCATENATE m_where_clause_local_home l_tmp
        INTO m_where_clause_local_home SEPARATED BY space.
      ENDLOOP.
    ENDIF.

    CONCATENATE
        'pgmid = ''R3TR'' and '
        'object not in (''FORM'', ''PRIN'', ''TEXT'', ''STYL'', ''STOB'' ) '
    INTO m_where_clause_cvers_comps SEPARATED BY space.

    APPEND 'SAP_BASIS' TO m_sap_comps_to_ignore.
    APPEND 'SAP_ABA' TO m_sap_comps_to_ignore.
    APPEND 'SAP_BW' TO m_sap_comps_to_ignore.
    APPEND 'SAP_GWFND' TO m_sap_comps_to_ignore.
    APPEND 'SAP_UI' TO m_sap_comps_to_ignore.
    APPEND 'SAP_APPL' TO m_sap_comps_to_ignore.
    APPEND 'SAP_HR' TO m_sap_comps_to_ignore.
    SELECT DISTINCT subcomp FROM cvers_sub APPENDING TABLE m_sap_comps_to_ignore WHERE mastercomp = 'SAP_HR'.
    APPEND 'SAP_FIN' TO m_sap_comps_to_ignore.

    CONCATENATE l_logname'.' sy-sysid INTO m_logfile_msg.
    CONCATENATE 'Log file' m_logfile_msg INTO m_logfile_msg SEPARATED BY space.
    IF m_logtype = cl_upg_logger_620=>c_logtype_upg.
      CONCATENATE m_logfile_msg 'written to tmp in <DIR_PUT>' INTO m_logfile_msg SEPARATED BY space.
    ELSE.
      CONCATENATE m_logfile_msg 'written to tmp in <DIR_TRANS>'  INTO m_logfile_msg SEPARATED BY space.
    ENDIF.

    "exception list for delivery check, which LIMUs to check for R3TR object
    "requested from Martin Runte for DMIS
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'DOMA'.
    <r3tr_limu_map>-limu_object = 'DOMD'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'DTEL'.
    <r3tr_limu_map>-limu_object = 'DTED'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'MSAG'.
    <r3tr_limu_map>-limu_object = 'MSAD'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'PROG'.
    <r3tr_limu_map>-limu_object = 'REPS'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'TABL'.
    <r3tr_limu_map>-limu_object = 'TABD'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'SOTS'.
    <r3tr_limu_map>-limu_object = 'SOTU'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'VIEW'.
    <r3tr_limu_map>-limu_object = 'VIED'.
    APPEND INITIAL LINE TO m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
    <r3tr_limu_map>-r3tr_object = 'WDYN'.
    <r3tr_limu_map>-limu_object = 'WDYD'.
  ENDMETHOD.

  METHOD close_logger.
    IF m_logger IS NOT INITIAL.
      m_logger->close_log( ).
    ENDIF.
  ENDMETHOD.

  METHOD is_upgrade_running.
    DATA: ld_uvers TYPE uvers.
    CALL FUNCTION 'UPG_GET_ACTIVE_COMP_UPGRADE'
      EXPORTING
        iv_component = 'SAP_BASIS'
        iv_upgtype   = 'A'
        iv_buffered  = ' '
      IMPORTING
        ev_upginfo   = ld_uvers
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc <> 0.
      CLEAR p_target_rel.
    ELSE.
      p_target_rel = ld_uvers-newrelease.
    ENDIF.
  ENDMETHOD.

  METHOD is_customer_system.
    DATA: l_sys_type TYPE sy-sysid,
          l_msgno    TYPE sprot-msgnr.
    p_is_customer_system = abap_false.
    CALL FUNCTION 'TR_SYS_PARAMS'
      IMPORTING
        systemtype = l_sys_type   " System Type ('SAP' or 'CUSTOMER')
      EXCEPTIONS
        OTHERS     = 4.
    IF sy-subrc <> 0.
      IF sy-msgid IS NOT INITIAL AND sy-msgno IS NOT INITIAL.
        l_msgno = sy-msgno.
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'E'
            iv_ag       = sy-msgid
            iv_msgnr    = l_msgno
            iv_var1     = sy-msgv1
            iv_var2     = sy-msgv2
            iv_var3     = sy-msgv3
            iv_var4     = sy-msgv4 ).
      ENDIF.
      m_logger->write_log_text(
        EXPORTING
          iv_severity = 'E'
          iv_text     = 'system type can not be determined' ).
    ENDIF.
    IF l_sys_type = 'CUSTOMER'.
      p_is_customer_system = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD check_valid_obj_type.
    DATA: l_invalid_tlogo_tab TYPE TABLE OF objh-objectname,
          l_idx               TYPE i.
    FIELD-SYMBOLS: <tlogo> TYPE objh-objectname.

    IF m_wbotypes[] IS INITIAL.
      CALL FUNCTION 'TR_OBJECT_TABLE'
        TABLES
          wt_object_text = m_wbotypes.
      SORT m_wbotypes BY object.
      "remove all TLOGOs without checkid = L as only Tlogo with L
      "should have TADIR entries
      SELECT objectname FROM objh INTO TABLE l_invalid_tlogo_tab
      WHERE objecttype = 'L' AND checkid <> 'L'.
      LOOP AT l_invalid_tlogo_tab ASSIGNING <tlogo>.
        READ TABLE m_wbotypes TRANSPORTING NO FIELDS
          WITH KEY object = <tlogo> BINARY SEARCH.
        IF sy-subrc = 0.
          l_idx = sy-tabix.
          DELETE m_wbotypes INDEX l_idx.
        ENDIF.
      ENDLOOP.
    ENDIF.
    READ TABLE m_wbotypes TRANSPORTING NO FIELDS
      WITH KEY object = p_object BINARY SEARCH.
    IF sy-subrc = 0.
      p_is_valid = abap_true.
    ELSE.
      p_is_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD update_tadir_add_2_trkorr.
    DATA: l_valid_type TYPE abap_bool,
          l_idx        TYPE sy-tabix,
          l_error_tab  TYPE ty_trmess_tab.
    FIELD-SYMBOLS: <l_tadir> TYPE tadir,
                   <l_err>   TYPE LINE OF ty_trmess_tab.

    IF p_tadir_tab IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT p_tadir_tab ASSIGNING <l_tadir>.
      l_idx = sy-tabix.
      l_valid_type = check_valid_obj_type( p_object = <l_tadir>-object ).
      IF l_valid_type = abap_false.
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'W'
            iv_ag       = 'TG'
            iv_msgnr    = '013'
            iv_var1     = 'Unknown object (ignored): '
            iv_var2     = <l_tadir>-object
            iv_var3     = <l_tadir>-obj_name ).
        DELETE p_tadir_tab INDEX l_idx.
        CONTINUE.
      ELSEIF "programs generated for context objects are not transportable but without reliable genflag setting
        <l_tadir>-obj_name(8)      =    'CONTEXT_' AND
        <l_tadir>-obj_name+8(1)    CO   'ISX'      AND
        <l_tadir>-obj_name+9(1)    =    '_'   .
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag       = 'TG'
            iv_msgnr    = '012'
            iv_var1     = 'Excluding generated context program: '
            iv_var2     = <l_tadir>-obj_name ).
        DELETE p_tadir_tab INDEX l_idx.
        CONTINUE.
      ENDIF.
      <l_tadir>-srcsystem = p_src_system.
      IF <l_tadir>-object = 'DEVC' AND
        <l_tadir>-obj_name <> <l_tadir>-devclass. "avoid TO134 in append_to_trkorr
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'W'
            iv_ag       = 'TG'
            iv_msgnr    = '010'
            iv_var1     = 'A package cannot be assigned to another package'
            iv_var2     = <l_tadir>-obj_name
            iv_var3     = <l_tadir>-devclass
            iv_var4     = '==> changing package assignment' ).
        <l_tadir>-devclass = <l_tadir>-obj_name.
      ENDIF.
    ENDLOOP.
    append_to_trkorr( EXPORTING p_tadir_tab = p_tadir_tab
                      IMPORTING p_error_tab = l_error_tab ).
    LOOP AT l_error_tab ASSIGNING <l_err>.
      DELETE p_tadir_tab INDEX <l_err>-tabix.
    ENDLOOP.
    APPEND LINES OF l_error_tab TO p_error_tab.
    UPDATE tadir FROM TABLE p_tadir_tab.
    WRITE sy-dbcnt TO sy-msgv1 LEFT-JUSTIFIED.
    CONCATENATE sy-msgv1 'objects updated for' INTO sy-msgv1 SEPARATED BY space.
    CONCATENATE 'Component' p_component INTO sy-msgv2 SEPARATED BY space.
    m_logger->write_log_line_s(
      EXPORTING
        iv_ag       = 'TG'
        iv_msgnr    = '012'
        iv_var1     = sy-msgv1
        iv_var2     = sy-msgv2 ).
    "commit work.
    m_logger->flush_log( ).
    CALL FUNCTION 'DB_COMMIT'.
  ENDMETHOD.

  METHOD append_to_trkorr.
    DATA: l_e071_tab TYPE TABLE OF e071,
          l_wa       TYPE e071,
          l_cnt      TYPE i.
    FIELD-SYMBOLS: <l_tadir> TYPE tadir.

    CLEAR p_error_tab[].
    l_cnt = lines( p_tadir_tab ).
    SELECT MAX( as4pos ) FROM e071 INTO l_wa-as4pos WHERE trkorr = m_trkorr.
    l_cnt = l_wa-as4pos + l_cnt.
    IF l_cnt > 999999.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '013'
          iv_var1     = 'Too many entries in transport'
          iv_var2     = m_trkorr
          iv_var3      = 'can not add current batch of changes'   ).
      RAISE EXCEPTION TYPE lcx_exception.
    ENDIF.
    LOOP AT p_tadir_tab ASSIGNING <l_tadir>.
      l_wa-pgmid = 'LIMU'.
      l_wa-object = 'ADIR'.
      l_wa-obj_name = '$1$2$3'.
      REPLACE '$3' WITH  <l_tadir>-obj_name INTO  l_wa-obj_name.
      REPLACE '$2' WITH  <l_tadir>-object   INTO  l_wa-obj_name.
      REPLACE '$1' WITH  <l_tadir>-pgmid    INTO  l_wa-obj_name.
      APPEND l_wa TO l_e071_tab.
    ENDLOOP.
    IF l_e071_tab[] IS NOT INITIAL.
      CLEAR: sy-msgid, sy-msgno.
      CALL FUNCTION 'TRINT_APPEND_TO_COMM_ARRAYS'
        EXPORTING
          wi_error_table            = abap_false "'X' "RT, 17.01.2018
          wi_trkorr                 = m_trkorr
          iv_append_at_order        = 'X'
          iv_no_owner_check         = 'X'
          iv_dialog                 = ' '
        TABLES
          wt_e071                   = l_e071_tab
          wt_trmess_int             = p_error_tab
        EXCEPTIONS
          key_check_keysyntax_error = 1
          ob_check_obj_error        = 2
          tr_lockmod_failed         = 3
          tr_lock_enqueue_failed    = 4
          tr_wrong_order_type       = 5
          tr_order_update_error     = 6
          file_access_error         = 7
          ob_no_systemname          = 8
          OTHERS                    = 9.
      IF sy-subrc <> 0.
        m_logger->write_symsg_or_log_line_s(
          EXPORTING
            iv_severity = 'E'
            iv_ag       = 'TG'
            iv_msgnr    = '012'
            iv_var1     = 'Not all objects could be added to transport'
            iv_var2     = m_trkorr ).
        IF p_error_tab[] IS NOT INITIAL.
          SORT p_error_tab BY msgid msgty msgno msgv1 msgv2 msgv3 msgv4.
          DELETE ADJACENT DUPLICATES FROM p_error_tab[]
                 COMPARING msgid msgty msgno msgv1 msgv2 msgv3 msgv4.
        ENDIF.
        RAISE EXCEPTION TYPE lcx_exception
          EXPORTING
            p_error_tab = p_error_tab[].
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD run.
    DATA: l_err  TYPE REF TO lcx_exception,
          l_flag TYPE c.
    l_flag =  is_customer_system( ).
    IF l_flag = abap_false.
      m_logger->write_log_text(
        EXPORTING
          iv_text     = 'Not a customer system, nothing to do'  ).
    ELSE.
      TRY.
          CASE m_action.
            WHEN c_action_check.
              check( ).
            WHEN c_action_detail_delivery_check.
              check_deliveries_for_comps( p_comp4detail =  m_comp4detail_delivery_check ).
            WHEN c_action_fixlocal.
              fix_local_home_objs( ).
            WHEN c_action_fixnocomp.
              fix_comps_no_cvers( ).
          ENDCASE.
        CATCH lcx_exception INTO l_err.
          IF l_err->m_error_tab[] IS NOT INITIAL.
            process_error_tab( p_error_tab = l_err->m_error_tab[] ).
          ENDIF.
          m_logger->write_log_text(
            EXPORTING
              iv_severity = 'E'
              iv_text     = 'Error occurred during processing.' ).
      ENDTRY.
    ENDIF.
    close_logger( ).
    MESSAGE m_logfile_msg TYPE 'I'.
  ENDMETHOD.

  METHOD write_log_separation.
    IF p_start = abap_true.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '039' ).
      IF p_module IS NOT INITIAL.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' iv_var1 = p_module ).
      ENDIF.
    ELSE.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '039' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
    ENDIF.
  ENDMETHOD.

  METHOD check.

    write_log_separation( EXPORTING p_start = abap_true
                                    p_module = 'CHECK_MOD_INDEXES_ON_SAP_TABLES' ).
    check_indexes_on_sap_tables( ).

    write_log_separation( ).
    write_log_separation( EXPORTING p_start = abap_true
                                    p_module = 'CHECK_LOCAL_HOME_OBJS' ).
    check_local_home_objs( ).

*    write_log_separation( ).
*    write_log_separation( exporting p_start = abap_true
*                                    p_module = 'CHECK_NON_EXISTING_PACKAGES' ).
*    check_non_existing_packages( ).


    write_log_separation( ).
    write_log_separation( EXPORTING p_start  = abap_true
                                    p_module =  'CHECK_COMPS_NO_CVERS' ).
    check_comps_no_cvers( ).

    IF m_is_sum_mode EQ abap_true.
      write_log_separation( ).
      write_log_separation( EXPORTING p_start  = abap_true
                                      p_module =  'CHECK_COMPS_CVERS' ).
*     Check, if there are components with CVERS-COMP_TYPE <> 'C' and no AVERS entry.
*
      check_comps_no_avers( ).

      write_log_separation( ).
      write_log_separation( EXPORTING p_start = abap_true
                                      p_module = 'CHECK_DELIVERIES_FOR_COMPS' ).
      collect_sum_exception_list( ).
      check_for_rescued_comps( ).
    ENDIF.

  ENDMETHOD.

  METHOD check_indexes_on_sap_tables.
    "check for customer indexes on SAP tables that are reset according
    "to smodilog but still exist in DDIC
    "the reset is most probably an error, they will get lost during upgrade

    DATA: l_smodilog_tab TYPE TABLE OF smodilog,
          l_indx         TYPE e071-obj_name,
          l_indx_id      TYPE ddobjectid,  "to detect customer namespace
          l_tabname      TYPE ddobjname,
          l_gotstate     TYPE ddgotstate,
          l_cnt          TYPE i.
    FIELD-SYMBOLS: <l_smodi> TYPE smodilog.

    SELECT DISTINCT obj_type obj_name sub_type sub_name
                mod_user mod_date mod_time trkorr
       INTO CORRESPONDING FIELDS OF TABLE l_smodilog_tab
       FROM smodilog
       WHERE sub_type = 'INDX' AND
             operation <> 'NOTE' AND operation <> 'TRSL' AND operation <> 'IMP' AND
             inactive = 'R'
        ORDER BY obj_type obj_name sub_type sub_name.

    LOOP AT l_smodilog_tab ASSIGNING <l_smodi>.

      "indexname 10+3 in 3.0 and 30+3 later, but for short table names
      "still 10+3 used, in smodilog mostly long names are used!!
      l_cnt = strlen( <l_smodi>-obj_name ).
      l_indx = <l_smodi>-sub_name+l_cnt.
      CONDENSE l_indx. "this is the name of the index

      IF l_indx(1) <> 'Z' AND l_indx(1) <> 'Y'.
        CONTINUE. "for now only check customer name range
      ENDIF.
      " the following indexes look like customer indices but are from SAP
      IF ( <l_smodi>-obj_name = 'KNA1'  AND l_indx = 'Z' ) OR
         ( <l_smodi>-obj_name = 'KNB1'  AND l_indx = 'Z' ) OR
         ( <l_smodi>-obj_name = 'LFA1'  AND l_indx = 'Z' ) OR
         ( <l_smodi>-obj_name = 'MARC'  AND l_indx = 'Y' ) OR
         ( <l_smodi>-obj_name = 'SADRP' AND l_indx = 'Z' ) .
        CONTINUE.
      ENDIF.
      "check if index still exists in DDIC
      l_indx_id = l_indx.
      l_tabname = <l_smodi>-obj_name.
      CALL FUNCTION 'DDIF_INDX_GET'
        EXPORTING
          name     = l_tabname
          id       = l_indx_id
        IMPORTING
          gotstate = l_gotstate
        EXCEPTIONS
          OTHERS   = 0.
      IF l_gotstate IS NOT INITIAL.
        CONCATENATE 'Customer index' l_indx_id 'for table' INTO sy-msgv1 SEPARATED BY space.
        IF strlen( <l_smodi>-obj_name ) > 10. "only long index name possible
          l_indx = <l_smodi>-sub_name.
        ELSE. "tabname shorter than 10, check if smodilog contains long or short name,
          "need to check for both name conventions in TADIR
          l_indx = <l_smodi>-obj_name.
          IF strlen( <l_smodi>-sub_name ) > 30. "long index name
            l_indx+10 = l_indx_id.
          ELSE. "short index name in smodilog
            l_indx+30 = l_indx_id.
          ENDIF.
        ENDIF.
        SELECT COUNT(*) FROM tadir INTO l_cnt
          WHERE pgmid = 'R3TR' AND object = 'XINX' AND
                ( obj_name = <l_smodi>-sub_name OR obj_name = l_indx ).
        IF l_cnt > 0.
          m_logger->write_log_line_s(
            EXPORTING iv_ag = 'TG' iv_msgnr = '010'
              iv_var1     = sy-msgv1
              iv_var2     = l_tabname
              iv_var3     = 'is defined as extension index. '
              iv_var4     = 'Everything ok.' ).
        ELSE.
          m_logger->write_log_line_s(
            EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
              iv_var1     = sy-msgv1
              iv_var2     = l_tabname
              iv_var3     = 'is flagged as reset modification'
              iv_var4     = 'but still exists in DDIC' ).
          m_logger->write_log_line_s(
            EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
              iv_var1     = 'Index will be dropped during system update'
              iv_var2     = 'if modification is not re-activated'
              iv_var3     = 'or converted to extension index').
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_comps_no_avers.
*
*   Check for Add-On components with CVERS-COMP_TYPE <> 'C' that have no AVERS entry.
*   Add-On Components with CVERS-COMP_TYPE = 'C' are project components that are developed
*   in the customer's own systems. These project components have no(!!) AVERS entry.
*
    DATA: lt_cvers TYPE STANDARD TABLE OF cvers,
          lt_avers TYPE SORTED TABLE OF avers
                        WITH UNIQUE KEY addonid addonrl.

    DATA: lv_subrc          TYPE sysubrc,
          lv_message_logged TYPE abap_bool.

    FIELD-SYMBOLS: <ls_cvers> TYPE cvers.

    SELECT * FROM cvers INTO TABLE lt_cvers.

    SELECT * FROM avers INTO TABLE lt_avers.

    lv_message_logged = abap_false.

*
*   Log only info-messages, so that SUM does NOT stop in this phase.
*
    LOOP AT lt_cvers ASSIGNING <ls_cvers>.

      READ TABLE lt_avers TRANSPORTING NO FIELDS
           WITH TABLE KEY addonid = <ls_cvers>-component
                          addonrl = <ls_cvers>-release.
      lv_subrc = sy-subrc.

      " comp_type = 'C': Add-On is developed in customer's own systems.
      IF <ls_cvers>-comp_type EQ 'C' AND lv_subrc NE 0.

        sy-msgv1 = 'Component &1'.                          "#EC NOTEXT
        REPLACE '&1' IN sy-msgv1 WITH <ls_cvers>-component.
        sy-msgv2 = 'is a project component'.                "#EC NOTEXT
        sy-msgv3 = '(no entry about AddOn update info ==> ok).'. "#EC NOTEXT

        m_logger->write_log_line_s( EXPORTING iv_severity = '' iv_ag = 'TG' iv_msgnr = '013'
                                    iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 iv_var3 = sy-msgv3 ).
        lv_message_logged = abap_true.

      ELSEIF <ls_cvers>-comp_type NE 'C' AND lv_subrc NE 0. " Delivered Add-On component.

        sy-msgv1 = 'Component &1'.                          "#EC NOTEXT
        REPLACE '&1' IN sy-msgv1 WITH <ls_cvers>-component.
        sy-msgv2 = 'is not a project component,'.           "#EC NOTEXT
        sy-msgv3 = 'no entry about AddOn update info exists.'. "#EC NOTEXT

        m_logger->write_log_line_s( EXPORTING iv_severity = '' iv_ag = 'TG' iv_msgnr = '013'
                                    iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 iv_var3 = sy-msgv3 ).
        lv_message_logged = abap_true.
      ENDIF.

    ENDLOOP.

*   In case no messages have been logged, write a friendly 'Everything ok'.
    IF lv_message_logged EQ abap_false.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                            iv_var1  = 'Everything ok.' ).
    ENDIF.

  ENDMETHOD.

  METHOD check_comps_no_cvers.
    DATA: l_comps       TYPE TABLE OF tdevc-dlvunit,
          l_msgv1       TYPE sy-msgv1,
          l_cnt         TYPE i,
          l_cnt_g       TYPE i,
          l_cnt_pi      TYPE i,
          l_obj_tab     TYPE ty_tadir_reduced_tab,
          l_obj_tab_tmp TYPE ty_tadir_reduced_tab,
          l_obj_tab_wa  TYPE LINE OF ty_tadir_reduced_tab.
    FIELD-SYMBOLS: <l_comp> TYPE tdevc-dlvunit.

    SELECT DISTINCT dlvunit FROM tdevc INTO TABLE l_comps
      WHERE dlvunit <> 'LOCAL' AND
            dlvunit <> 'HOME'  AND
            dlvunit <> space   AND
            dlvunit NOT IN ( SELECT component FROM cvers ) AND
            "IW_BEP has been consolidated to SAP_GWFND but some packages are not yet changed in 740
            dlvunit <> 'IW_BEP' AND
            "wrong delivery with SAPK-75001INSAPGWFND
            dlvunit <> 'AOF_STRTPT' AND
            "upgrade SCM <= 7.02 to >= 7.13: SAPK750VTA imports SCM objects already with
            "target component SCMAPO assigned, see note 2500787 (IM 1780271599/2017)
            devclass <> '/SAPAPO/OM_UPGRADE' .
    IF l_comps[] IS NOT INITIAL.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'W'
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'ABAP packages found for software components'
          iv_var2     = 'without component registration'  ).
      LOOP AT l_comps ASSIGNING <l_comp>.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag       = 'TG'
            iv_msgnr    = '012'
            iv_var1     = 'Software Component without component registration'
            iv_var2     = <l_comp>  ).

        SELECT COUNT(*) FROM tadir INTO l_cnt
          WHERE srcsystem <> 'SAP' AND
                pgmid = 'R3TR' AND
                devclass IN ( SELECT devclass FROM tdevc WHERE dlvunit = <l_comp> ).
        WRITE l_cnt TO l_msgv1 LEFT-JUSTIFIED.
        CONCATENATE 'component' <l_comp> INTO sy-msgv3 SEPARATED BY space.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag    = 'TG'
            iv_msgnr = '013'
            iv_var1  = l_msgv1
            iv_var2  = 'objects with srcsystem <> SAP found for'
            iv_var3  = sy-msgv3 ).

        SELECT COUNT(*) FROM tadir INTO l_cnt
          WHERE srcsystem = 'SAP' AND
                pgmid = 'R3TR' AND
                devclass IN ( SELECT devclass FROM tdevc WHERE dlvunit = <l_comp> ).
        WRITE l_cnt TO l_msgv1 LEFT-JUSTIFIED.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag    = 'TG'
            iv_msgnr = '013'
            iv_var1  = l_msgv1
            iv_var2  = 'objects with srcsystem = SAP found for'
            iv_var3  = sy-msgv3
            iv_var4  = '(including generated objects)' ).

        SELECT COUNT(*) FROM tadir INTO l_cnt_g
          WHERE srcsystem = 'SAP' AND
                pgmid = 'R3TR' AND
                genflag = 'X' AND
                devclass IN ( SELECT devclass FROM tdevc WHERE dlvunit = <l_comp> ).
        WRITE l_cnt_g TO l_msgv1 LEFT-JUSTIFIED.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag    = 'TG'
            iv_msgnr = '013'
            iv_var1  = l_msgv1
            iv_var2  = 'generated objects with srcsystem = SAP found for'
            iv_var3  = sy-msgv3 ).
        l_cnt = l_cnt - l_cnt_g.
        "generates with srcsystem SAP will be rescued (SAPKCCG<xxx>)
        "but the others not due to the missing component registration
        IF <l_comp> = 'PI' AND l_cnt <= 50.
          "Package ASU1 is delivered as transport, also with SUM (RSASUVAR*)
          SELECT COUNT(*) FROM tadir INTO l_cnt_pi
            WHERE srcsystem = 'SAP' AND
                  pgmid = 'R3TR' AND
                  genflag <> 'X' AND
                  devclass = 'ASU1'.
          IF l_cnt = l_cnt_pi.
            WRITE l_cnt TO l_msgv1 LEFT-JUSTIFIED.
            CONCATENATE 'component' <l_comp> INTO sy-msgv3 SEPARATED BY space.
            m_logger->write_log_line_s(
              EXPORTING
                iv_ag    = 'TG'
                iv_msgnr = '010'
                iv_var1  = l_msgv1
                iv_var2  = 'objects with srcsystem = SAP found for'
                iv_var3  = sy-msgv3
                iv_var4  = 'in package ASU1, to be ignored' ).
            l_cnt = 0.
          ENDIF.
        ENDIF.
        IF l_cnt > 0.
          WRITE l_cnt TO l_msgv1 LEFT-JUSTIFIED.
          CONCATENATE 'component' <l_comp> INTO sy-msgv3 SEPARATED BY space.
          m_logger->write_log_line_s(
            EXPORTING
              iv_severity = 'E'
              iv_ag    = 'TG'
              iv_msgnr = '010'
              iv_var1  = l_msgv1
              iv_var2  = 'objects with srcsystem = SAP found for'
              iv_var3  = sy-msgv3
              iv_var4  = 'that will not be rescued by SUM upgrade' ).
          "collect objects for dumping to file
          SELECT pgmid object obj_name devclass FROM tadir
            INTO CORRESPONDING FIELDS OF TABLE l_obj_tab_tmp
            WHERE srcsystem = 'SAP' AND
                  pgmid = 'R3TR' AND
                  genflag <> 'X' AND
                  devclass IN ( SELECT devclass FROM tdevc WHERE dlvunit = <l_comp> ).
          l_obj_tab_wa-component = <l_comp>.
          MODIFY l_obj_tab_tmp FROM l_obj_tab_wa TRANSPORTING component WHERE component <> <l_comp>.
          APPEND LINES OF l_obj_tab_tmp TO l_obj_tab.
        ELSE.
          sy-msgv2 = <l_comp>.
          m_logger->write_log_line_s(
            EXPORTING
              iv_ag    = 'TG'
              iv_msgnr = '012'
              iv_var1  = 'Everything ok for component'
              iv_var2  = sy-msgv2 ).
        ENDIF.
        m_logger->flush_log( ).
      ENDLOOP.
      IF l_obj_tab[] IS NOT INITIAL.
        dump_objects_to_file( EXPORTING p_file = 'UNKNOWN_COMPONENT_OBJECT.LST'
                                        p_include_comp = abap_true
                                        p_objects = l_obj_tab ).
      ENDIF.

    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'All ABAP packages have valid software components'
          iv_var2     = 'associated. Everything ok.'  ).
    ENDIF.
  ENDMETHOD.

  METHOD fix_comps_no_cvers.
    DATA: l_comps     TYPE TABLE OF ty_devc_comp,
          l_error_tab TYPE ty_trmess_tab,
          l_tadir_tab TYPE TABLE OF tadir.
    FIELD-SYMBOLS: <l_comp>     TYPE ty_devc_comp,
                   <l_sel_comp> TYPE LINE OF ty_comps_tab.

    m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                          iv_var1 = 'FIX_COMPS_NO_CVERS' ).

    IF m_comps4fix[] IS INITIAL.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '011'
          iv_var1     = 'Component selection: empty --> nothing to do' ).
      RETURN.
    ENDIF.
    IF m_trkorr IS INITIAL.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '011'
          iv_var1     = 'No transport specified for change recording' ).
      RETURN.
    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'Collection objects into transport:'
          iv_var2     = m_trkorr ).
    ENDIF.

    LOOP AT m_comps4fix ASSIGNING <l_sel_comp>.
      CONCATENATE  <l_sel_comp>-sign  <l_sel_comp>-option INTO sy-msgv2 SEPARATED BY space.
      sy-msgv3 = <l_sel_comp>-low.
      sy-msgv4 = <l_sel_comp>-high.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '010'
          iv_var1     = 'Component selection:'
          iv_var2     = sy-msgv2
          iv_var3     = sy-msgv3
          iv_var4     = sy-msgv4 ).
    ENDLOOP.
    SELECT DISTINCT dlvunit devclass FROM tdevc INTO CORRESPONDING FIELDS OF TABLE l_comps
      WHERE dlvunit <> 'LOCAL' AND
            dlvunit <> 'HOME'  AND
            dlvunit <> space   AND
            dlvunit IN m_comps4fix AND
    dlvunit NOT IN ( SELECT component FROM cvers ).
    IF l_comps[] IS NOT INITIAL.
      SORT l_comps BY dlvunit devclass.
      LOOP AT l_comps ASSIGNING <l_comp>.
        sy-msgv1 = 'Updating objects '.
        CONCATENATE 'Component' <l_comp>-dlvunit INTO sy-msgv2 SEPARATED BY space.
        CONCATENATE 'Package' <l_comp>-devclass INTO sy-msgv3 SEPARATED BY space.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag       = 'TG'
            iv_msgnr    = '012'
            iv_var1     = sy-msgv1
            iv_var2     = sy-msgv2
            iv_var3     = sy-msgv3 ).
        SELECT * FROM tadir INTO TABLE l_tadir_tab
          WHERE devclass = <l_comp>-devclass AND
                srcsystem = 'SAP' AND
                pgmid = 'R3TR' AND
                obj_name IS NOT NULL AND
                obj_name <> space AND
                genflag <> 'X'.
        IF l_tadir_tab[] IS NOT INITIAL.
          update_tadir_add_2_trkorr( EXPORTING p_component = <l_comp>-dlvunit
                                               p_src_system = sy-sysid
                                     CHANGING  p_tadir_tab = l_tadir_tab
                                               p_error_tab = l_error_tab ).
        ELSE.
          CONCATENATE 'Component' <l_comp>-dlvunit INTO sy-msgv2 SEPARATED BY space.
          m_logger->write_log_line_s(
            EXPORTING
              iv_ag       = 'TG'
              iv_msgnr    = '012'
              iv_var1     = 'No objects requiring change for '
              iv_var2     = sy-msgv2  ).
        ENDIF.
      ENDLOOP.
      process_error_tab( p_error_tab = l_error_tab ).
    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'No ABAP packages found for '
          iv_var2     = 'selected software components.'  ).
    ENDIF.
  ENDMETHOD.


  METHOD fix_local_home_objs.
    DATA: l_error_tab TYPE ty_trmess_tab,
          l_tadir_tab TYPE TABLE OF tadir,
          l_err       TYPE REF TO lcx_exception,
          l_cursor    TYPE cursor.


    m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                          iv_var1 = 'FIX_LOCAL_HOME' ).
    IF m_trkorr IS INITIAL.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '011'
          iv_var1     = 'No transport specified for change recording' ).
      RETURN.
    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'Collection objects into transport:'
          iv_var2     = m_trkorr ).
    ENDIF.
    TRY.
        OPEN CURSOR WITH HOLD l_cursor FOR
        SELECT * FROM tadir
          WHERE (m_where_clause_local_home) AND
                srcsystem = 'SAP' AND genflag <> 'X' AND genflag <> 'T' AND
                devclass IN
               ( SELECT devclass FROM tdevc
                  WHERE dlvunit = 'HOME' OR
                        dlvunit = 'LOCAL' OR
                        dlvunit = space OR
                        dlvunit IS NULL ).
        DO.
          FETCH NEXT CURSOR l_cursor INTO TABLE l_tadir_tab PACKAGE SIZE 1000.
          IF sy-subrc <> 0. EXIT. ENDIF.
          update_tadir_add_2_trkorr(
            EXPORTING
              p_component   = 'home or local'
              p_src_system  = sy-sysid
            CHANGING
              p_tadir_tab   = l_tadir_tab
              p_error_tab   = l_error_tab  ).
          process_error_tab( p_error_tab = l_error_tab ).
        ENDDO.
        CLOSE CURSOR l_cursor.
      CATCH lcx_exception INTO l_err.
        IF l_error_tab[] IS INITIAL AND l_err->m_error_tab[] IS NOT INITIAL.
          l_error_tab[] = l_err->m_error_tab[].
        ENDIF.
        process_error_tab( p_error_tab = l_error_tab ).
        RAISE EXCEPTION l_err.
    ENDTRY.

  ENDMETHOD.

  METHOD check_local_home_objs.
    DATA: l_tdevc_tab TYPE TABLE OF tdevc,
          l_cnt       TYPE i,
          l_cnt_g     TYPE i,
          l_obj_tab   TYPE ty_tadir_reduced_tab.

    FIELD-SYMBOLS: <l_tdevc> TYPE tdevc.

    SELECT * FROM tdevc INTO TABLE l_tdevc_tab
      WHERE ( dlvunit = space OR dlvunit IS NULL ) .
    LOOP AT l_tdevc_tab ASSIGNING <l_tdevc>.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = 'TG'
          iv_msgnr    = '010'
          iv_var1     = 'ABAP package'
          iv_var2     = <l_tdevc>-devclass
          iv_var3     = 'has no software component assigned, namespace'
          iv_var4     = <l_tdevc>-namespace  ).

    ENDLOOP.

    SELECT COUNT(*) FROM tadir INTO l_cnt
      WHERE (m_where_clause_local_home) AND
            devclass IN
            ( SELECT devclass FROM tdevc
                WHERE dlvunit = 'HOME' OR
                      dlvunit = 'LOCAL' OR
                      dlvunit = space OR
                      dlvunit IS NULL ).
    WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
    m_logger->write_log_line_s(
      EXPORTING
        iv_ag    = 'TG'
        iv_msgnr = '013'
        iv_var1  = sy-msgv1
        iv_var2  = 'objects found for components'
        iv_var3  = 'LOCAL, HOME and space' ).

    SELECT COUNT(*) FROM tadir INTO l_cnt
      WHERE (m_where_clause_local_home) AND srcsystem = 'SAP' AND
            devclass IN
            ( SELECT devclass FROM tdevc
                WHERE dlvunit = 'HOME' OR
                      dlvunit = 'LOCAL' OR
                      dlvunit = space OR
                      dlvunit IS NULL ).
    IF l_cnt > 0 .
      WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '013'
          iv_var1  = sy-msgv1
          iv_var2  = 'objects with srcsystem = SAP found for '
          iv_var3  = 'components LOCAL, HOME and space (incl. generates)' ).
      SELECT COUNT(*) FROM tadir INTO l_cnt_g
        WHERE (m_where_clause_local_home) AND
              srcsystem = 'SAP' AND
              genflag IN ('X','T') AND
              devclass IN
              ( SELECT devclass FROM tdevc
                  WHERE dlvunit = 'HOME' OR
                        dlvunit = 'LOCAL' OR
                        dlvunit = space OR
                        dlvunit IS NULL ).
      WRITE l_cnt_g TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '013'
          iv_var1  = sy-msgv1
          iv_var2  = 'generated objects with srcsystem = SAP found for '
          iv_var3  = 'components LOCAL, HOME and space (incl generates)' ).

      l_cnt = l_cnt - l_cnt_g.
      "generates with srcsystem SAP will be rescued (SAPKCCG<xxx>)
      "but the others not due to the missing component registration
      IF l_cnt > 0.
        WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'E'
            iv_ag    = 'TG'
            iv_msgnr = '010'
            iv_var1  = sy-msgv1
            iv_var2  = 'objects with srcsystem = SAP found for '
            iv_var3  = 'components LOCAL, HOME and space '
            iv_var4  = 'which will not be rescued' ).
        SELECT pgmid object obj_name devclass FROM tadir INTO CORRESPONDING FIELDS OF TABLE l_obj_tab
          WHERE (m_where_clause_local_home) AND
                srcsystem = 'SAP' AND
                genflag <> 'X' AND genflag <> 'T' AND
                devclass IN
                ( SELECT devclass FROM tdevc
                    WHERE dlvunit = 'HOME' OR
                          dlvunit = 'LOCAL' OR
                          dlvunit = space OR
                          dlvunit IS NULL ).
        dump_objects_to_file( EXPORTING p_file = 'LOCAL_HOME_OBJECT.LST'
                                        p_objects = l_obj_tab ).
      ELSE. "everything fine
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag    = 'TG'
            iv_msgnr = '012'
            iv_var1  = 'Everything ok for '
            iv_var2  = 'components LOCAL, HOME and space' ).
      ENDIF.
    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '012'
          iv_var1  = 'No objects with srcsystem = SAP found for '
          iv_var2  = 'components LOCAL, HOME and space' ).
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '012'
          iv_var1  = 'Everything ok for '
          iv_var2  = 'components LOCAL, HOME and space' ).
    ENDIF.
    m_logger->flush_log( ).
  ENDMETHOD.

  METHOD check_non_existing_packages.
    DATA: l_cnt     TYPE i,
          l_cnt_g   TYPE i,
          l_obj_tab TYPE ty_tadir_reduced_tab.

    SELECT COUNT(*) FROM tadir INTO l_cnt
      WHERE NOT EXISTS
            ( SELECT * FROM tdevc WHERE devclass = tadir~devclass ).
    WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
    m_logger->write_log_line_s(
      EXPORTING
        iv_ag    = 'TG'
        iv_msgnr = '013'
        iv_var1  = sy-msgv1
        iv_var2  = 'objects found for non-existing packages' ).

    SELECT COUNT(*) FROM tadir INTO l_cnt
      WHERE srcsystem = 'SAP' AND
            NOT EXISTS
            ( SELECT * FROM tdevc WHERE devclass = tadir~devclass ).
    IF l_cnt > 0 .
      WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '013'
          iv_var1  = sy-msgv1
          iv_var2  = 'objects with srcsystem = SAP found for '
          iv_var3  = 'non-existing packages (incl. generates)' ).
      SELECT COUNT(*) FROM tadir INTO l_cnt_g
        WHERE srcsystem = 'SAP' AND
              genflag IN ('X','T') AND
              NOT EXISTS
              ( SELECT * FROM tdevc WHERE devclass = tadir~devclass ).
      WRITE l_cnt_g TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '013'
          iv_var1  = sy-msgv1
          iv_var2  = 'generated objects with srcsystem = SAP found for '
          iv_var3  = 'non-existing packages (incl. generates)' ).

      l_cnt = l_cnt - l_cnt_g.
      "generates with srcsystem SAP will be rescued (SAPKCCG<xxx>)
      "but the others may not,
      "due to the missing ABAP package it is not possible to determine if the object
      "belongs to a component that may be rescued
      IF l_cnt > 0.
        WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'E'
            iv_ag    = 'TG'
            iv_msgnr = '010'
            iv_var1  = sy-msgv1
            iv_var2  = 'objects with srcsystem = SAP found for '
            iv_var3  = 'non-existing packages '
            iv_var4  = 'which may not be rescued' ).
        SELECT pgmid object obj_name devclass FROM tadir INTO CORRESPONDING FIELDS OF TABLE l_obj_tab
          WHERE srcsystem = 'SAP' AND
                genflag <> 'X' AND genflag <> 'T' AND
                NOT EXISTS
                ( SELECT * FROM tdevc WHERE devclass = tadir~devclass ).
        dump_objects_to_file( EXPORTING p_file = 'NON_EXISTING_PACKAGE_OBJ.LST'
                                        p_objects = l_obj_tab ).
      ENDIF.
    ELSE.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag    = 'TG'
          iv_msgnr = '012'
          iv_var1  = 'No objects with srcsystem = SAP found for '
          iv_var2  = 'non-existing packages' ).
    ENDIF.
    m_logger->flush_log( ).
  ENDMETHOD.

  METHOD dump_objects_to_file.

    DATA: l_file_name TYPE tstrf01-filename,
          l_file      TYPE tstrf01-file,
          l_line      TYPE c LENGTH 250.
    FIELD-SYMBOLS: <obj> TYPE LINE OF ty_tadir_reduced_tab.

    l_file_name = p_file.
    CONCATENATE l_file_name '_' sy-sysid  INTO l_file_name.

    CALL FUNCTION 'STRF_SETNAME'
      EXPORTING
        dirtype  = m_logtype
        filename = l_file_name
        subdir   = m_dump_file_dir
      IMPORTING
        file     = l_file
      EXCEPTIONS
        OTHERS   = 2.

    IF sy-subrc <> 0.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '012'
          iv_var1     = 'Error creating dumpfile name'
          iv_var2     = l_file_name ).
      RETURN.
    ELSE.
      CLEAR l_line.
      CONCATENATE 'Object list dumped to file:' l_file INTO l_line SEPARATED BY space.
      m_logger->write_log_text( EXPORTING iv_severity = 'E' iv_text = l_line ).
    ENDIF.

    OPEN DATASET l_file IN TEXT MODE FOR OUTPUT ENCODING UTF-8.

    l_line = 'PGMID,OBJECT,OBJ_NAME,DEVCLASS' .
    IF p_include_comp = abap_true.
      CONCATENATE l_line ',COMPONENT' INTO l_line.
    ENDIF.
    CONCATENATE l_line '( creation time:' sy-datum sy-uzeit ')' INTO l_line SEPARATED BY space.
    TRANSFER l_line TO l_file.
    LOOP AT p_objects ASSIGNING <obj>.
      CLEAR l_line.
      l_line(4) = <obj>-pgmid.
      l_line+4(1) = ','.
      l_line+5(4) = <obj>-object.
      l_line+9(1) = ','.
      l_line+10(120) = <obj>-obj_name.
      l_line+130(1) = ','.
      l_line+131(30) = <obj>-devclass.
      IF p_include_comp = abap_true.
        l_line+162(1) = ','.
        l_line+163(30) = <obj>-component.
      ENDIF.
      TRANSFER l_line TO l_file.
    ENDLOOP.
    CLOSE DATASET l_file.
  ENDMETHOD.

  METHOD check_srcsystem_for_comps.
    TYPES: BEGIN OF ty_tadir_cnt,
             devclass TYPE tadir-devclass,
             dlvunit  TYPE tdevc-dlvunit,
             cnt      TYPE i,
           END OF ty_tadir_cnt.
    DATA: l_itab_sap     TYPE TABLE OF ty_tadir_cnt,
          l_itab_not_sap TYPE TABLE OF ty_tadir_cnt,
          l_itab_summary TYPE TABLE OF ty_tadir_cnt,
          l_comp_summary TYPE ty_tadir_cnt,
          l_dlvunit      TYPE tdevc-dlvunit.
    FIELD-SYMBOLS: <l_comp> TYPE dlvunit,
                   <l_wa>   TYPE ty_tadir_cnt,
                   <l_wa2>  TYPE ty_tadir_cnt.

    m_logger->write_log_text( EXPORTING iv_msgnr = '011'
                                        iv_text = 'Installed AddOns should have srcsystem = SAP' ).

    SELECT t~devclass d~dlvunit COUNT(*) AS cnt INTO TABLE l_itab_sap
      FROM tadir AS t
      INNER JOIN tdevc AS d
      ON t~devclass = d~devclass
      WHERE (m_where_clause_cvers_comps)  AND
            t~srcsystem = 'SAP' AND
            d~dlvunit IN ( SELECT component FROM cvers )
      GROUP BY  t~devclass d~dlvunit
    ORDER BY d~dlvunit t~devclass.

    SELECT t~devclass  d~dlvunit COUNT(*) AS cnt INTO TABLE l_itab_not_sap
      FROM tadir AS t
      INNER JOIN tdevc AS d
      ON t~devclass = d~devclass
      WHERE (m_where_clause_cvers_comps) AND
            t~srcsystem <> 'SAP' AND
            t~genflag <> 'X' AND
            d~dlvunit IN ( SELECT component FROM cvers )
      GROUP BY  t~devclass d~dlvunit
    ORDER BY d~dlvunit t~devclass.

    IF m_is_sum_mode = abap_true.
    ELSE.
      LOOP AT m_sap_comps_to_ignore ASSIGNING <l_comp>.
        DELETE l_itab_sap WHERE dlvunit = <l_comp>.
        DELETE l_itab_not_sap WHERE dlvunit = <l_comp>.
        sy-msgv2 = <l_comp>.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                              iv_var1 = 'Ignoring component'
                                              iv_var2 = sy-msgv2 ).
      ENDLOOP.
    ENDIF.

    LOOP AT l_itab_not_sap ASSIGNING <l_wa>.
      IF l_dlvunit <> <l_wa>-dlvunit.
        IF l_comp_summary IS NOT INITIAL.
          APPEND l_comp_summary TO l_itab_summary.
          CLEAR l_comp_summary.
        ENDIF.
        l_dlvunit = <l_wa>-dlvunit.
        l_comp_summary-dlvunit = <l_wa>-dlvunit.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
        m_logger->write_log_line_s(
          EXPORTING
            iv_severity = 'E'
            iv_ag       = 'TG'
            iv_msgnr    = '013'
            iv_var1     = 'Component found with srcsystem <> SAP'
            iv_var2     = <l_wa>-dlvunit ).
      ENDIF.
      l_comp_summary-cnt = l_comp_summary-cnt + <l_wa>-cnt.
      CONCATENATE 'objects in package' <l_wa>-devclass
        INTO sy-msgv2 SEPARATED BY space.
      WRITE <l_wa>-cnt TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '013'
          iv_var1     = sy-msgv1
          iv_var2     = sy-msgv2
          iv_var3     = 'with srcsystem <> SAP (excluding generates)' ).
      READ TABLE l_itab_sap ASSIGNING <l_wa2> WITH KEY dlvunit = <l_wa>-dlvunit devclass = <l_wa>-devclass.
      IF sy-subrc = 0.
        WRITE <l_wa2>-cnt TO sy-msgv1 LEFT-JUSTIFIED.
        m_logger->write_log_line_s(
          EXPORTING
            iv_ag       = 'TG'
            iv_msgnr    = '013'
            iv_var1     = sy-msgv1
            iv_var2     = sy-msgv2
            iv_var3     = 'with srcsystem = SAP (including generates)' ).
      ENDIF.
    ENDLOOP.
    m_logger->flush_log( ).
    IF l_itab_not_sap IS NOT INITIAL.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' iv_var1 = 'SUMMARY' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = 'Number of objects with srcsystem <> SAP'
                                            iv_var2 = 'per component' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
      l_comp_summary-cnt = 0.
      LOOP AT l_itab_summary ASSIGNING <l_wa>.
        l_comp_summary-cnt = l_comp_summary-cnt + <l_wa>-cnt.
        WRITE <l_wa>-cnt TO sy-msgv1 LEFT-JUSTIFIED.
        sy-msgv3 = <l_wa>-dlvunit.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                              iv_var1 = sy-msgv1
                                              iv_var2 = 'objects in component '
                                              iv_var3 = sy-msgv3 ).
      ENDLOOP.
      WRITE l_comp_summary-cnt TO sy-msgv2 LEFT-JUSTIFIED.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                            iv_var1 = 'TOTAL:'
                                            iv_var2 = sy-msgv2
                                            iv_var3 = 'objects with srcsystem <> SAP' ).

    ENDIF.
    m_logger->flush_log( ).
  ENDMETHOD.

  METHOD check_for_rescued_comps.
    "collect AddOns to be saved and check if all objects in the system
    "are part of rescue transports,
    "similar to collect_transports_for_addons in fugr sug7
    DATA: lt_compinfo       TYPE TABLE OF compinfo,
          l_comp            TYPE dlvunit,
          l_rc              TYPE sy-subrc,
          l_navers          TYPE navers,
          lt_e071           TYPE TABLE OF e071,
          l_delivery_tr_tab TYPE trkorrs.

    FIELD-SYMBOLS: <compinfo> TYPE compinfo,
                   <l_e071>   TYPE e071.
    m_logger->write_log_text( EXPORTING iv_msgnr = '011'
                                        iv_text = 'Check deliveries for AddOns to be rescued' ).

    CALL FUNCTION 'SPDA_GET_EXTENDED_UPG_INFO'
      EXPORTING
        get_all     = 'X'
      IMPORTING
        ev_rc       = l_rc
      TABLES
        et_compinfo = lt_compinfo.

    IF l_rc <> 0.
      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '011'
                                            iv_var1 = 'Upgrade Info not found' ).
      RETURN.
    ENDIF.

    SELECT * FROM navers BYPASSING BUFFER INTO l_navers
             WHERE relstamp = 'CURRENT'
               AND updstatus IN ('A', 'M') AND
                   ( updtype  = 'T' OR
                     updtype  = 'C' OR
                     updtype  = 'J' ).

      CLEAR: lt_e071[], l_delivery_tr_tab[].
      m_logger->write_log_line_s( EXPORTING iv_ag = 'UG' iv_msgnr = '100'
                                            iv_var1 = l_navers-addonid
                                            iv_var2 = l_navers-addonrl ).
      READ TABLE lt_compinfo ASSIGNING <compinfo> WITH KEY component = l_navers-addonid.
      IF sy-subrc <> 0.
        " warning: no compinfo -> Add-On will be saved!
        m_logger->write_log_line_s( EXPORTING iv_ag = 'UG' iv_msgnr = '138'
                                              iv_var1 = l_navers-addonid
                                              iv_var2 = l_navers-addonrl ).
      ELSEIF <compinfo>-exprelease IS NOT INITIAL.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '010'
                                              iv_var1 = 'Component '
                                              iv_var2 = l_navers-addonid
                                              iv_var3 = 'is part of export and will not be checked').
        CONTINUE.
      ENDIF.

*   Loop over transport orders defined in full master commandfile
      SELECT * FROM e071 INTO TABLE lt_e071
                         WHERE trkorr = l_navers-fulltask  AND
                               pgmid  = 'LIMU'          AND
                               object = 'COMM'.
      IF sy-subrc <> 0.
        m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'UG' iv_msgnr = '172'
                                              iv_var1 = l_navers-fulltask
                                              iv_var2 = l_navers-addonid ).
        CONTINUE.
      ENDIF.
      LOOP AT lt_e071 ASSIGNING <l_e071>.
* Collect the content of all LIMU COMMs
* write all command files into log
        m_logger->write_log_line_s( EXPORTING iv_ag = 'UG' iv_msgnr = '170'
                                              iv_var1 = l_navers-addonid
                                              iv_var2 = l_navers-addonrl
                                              iv_var3 = <l_e071>-obj_name ).
        APPEND <l_e071>-obj_name TO l_delivery_tr_tab.
      ENDLOOP.
      l_comp = l_navers-addonid.
      check_delivery_tr_for_comp( EXPORTING p_comp    = l_comp
                                            p_delivery_tr_tab = l_delivery_tr_tab ).
      " lt_e071
    ENDSELECT.              " addons

    m_logger->write_log_text( EXPORTING iv_msgnr = '011'
                                        iv_text = 'Check deliveries done' ).
    m_logger->flush_log( ).

  ENDMETHOD.

  METHOD check_object_existence.
    DATA: l_exists        TYPE abap_bool,
          l_e071_obj_name TYPE e071-obj_name,
          l_sotr_paket    TYPE devclass,
          l_tadir         TYPE tadir.

    IF st_has_sotr_func = '-'.
      "function check_exist_otr does not exist in all releases
      CALL FUNCTION 'CHECK_EXIST_LIMU_FUNC'
        EXPORTING
          name   = 'CHECK_EXIST_SOTR'
        IMPORTING
          exist  = l_exists    " Flag = X -> exists, space -> does not exist
        EXCEPTIONS
          OTHERS = 0.
      IF l_exists IS INITIAL.
        st_has_sotr_func = abap_false.
      ELSE.
        st_has_sotr_func = abap_true.
      ENDIF.
    ENDIF.

    p_exists = abap_false.

    IF st_has_sotr_func = abap_false.
      l_sotr_paket = p_obj-obj_name(30).
      SELECT SINGLE paket FROM sotr_head INTO l_sotr_paket
                      WHERE paket = l_sotr_paket.
      IF sy-subrc = 0.
        p_exists = abap_true.
      ENDIF.
    ELSE.
      l_e071_obj_name = p_obj-obj_name.
      l_tadir-pgmid   = p_obj-pgmid.
      l_tadir-object  = p_obj-object.
      l_tadir-obj_name = p_obj-obj_name.
      IF m_is_sum_mode = abap_true.
        CALL FUNCTION 'SUBST_CHECK_EXIST'
          EXPORTING
            iv_pgmid    = p_obj-pgmid
            iv_object   = p_obj-object
            iv_obj_name = l_e071_obj_name
            is_tadir    = l_tadir
          IMPORTING
            e_exist     = l_exists
          EXCEPTIONS
            OTHERS      = 2.
      ELSE. "SUBST_CHECK_EXIST is only delivered by SUM, use TR_CHECK_EXIST which is quite slow for TLOGOs
        CALL FUNCTION 'TR_CHECK_EXIST'
          EXPORTING
            iv_pgmid    = p_obj-pgmid
            iv_object   = p_obj-object
            iv_obj_name = l_e071_obj_name
            is_tadir    = l_tadir
          IMPORTING
            e_exist     = l_exists
          EXCEPTIONS
            OTHERS      = 1.
      ENDIF.
      IF sy-subrc <> 0 OR l_exists <> space.
        p_exists = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD has_exchange_parts.
    DATA: l_object TYPE objh-objectname,
          lt_objsl TYPE TABLE OF objsl,
          l_sobjs  TYPE ty_sobjs,
          l_puttb  TYPE puttb,
          l_objsl  TYPE objsl.
    FIELD-SYMBOLS: <sobjs> TYPE ty_sobjs,
                   <objsl> TYPE objsl.

    l_object = p_object.
    READ TABLE m_objects_with_exchange ASSIGNING <sobjs> WITH TABLE KEY object = l_object.
    IF sy-subrc = 0.
      has_exchange_parts = <sobjs>-has_exchange_parts.
    ELSE.

      REFRESH lt_objsl.
      CALL FUNCTION 'CTO_OBJECT_GET'
        EXPORTING
          iv_objectname      = l_object
          iv_objecttype      = 'L'
          iv_sel_objsl       = abap_true
        TABLES
          tt_objsl           = lt_objsl
        EXCEPTIONS
          object_not_defined = 1
          OTHERS             = 99.

      IF sy-subrc <> 0 AND l_object = 'SOTR'.
        "SOTR is hard coded but so far not in exchange part, but to be on the save
        "side evaluate the current tables used by R3trans
        "SOTR object come into existence without R3TR SOTR delivery by importing ENHOs for example,
        "therefore a lot of false positives may show without this "trick"
        APPEND l_objsl TO lt_objsl.
        l_objsl-tpgmid     = 'R3TR'.
        l_objsl-tobject    = 'TABU'.
        l_objsl-objectname = 'SOTR'.
        l_objsl-tobj_name = 'SOTR_HEAD'.
        APPEND l_objsl TO lt_objsl.
        l_objsl-tobj_name = 'SOTR_TEXT'.
        APPEND l_objsl TO lt_objsl.
        l_objsl-tobj_name = 'SOTR_LINK'.
        APPEND l_objsl TO lt_objsl.
        sy-subrc = 0.
      ENDIF.
      IF sy-subrc <> 0.
        m_logger->write_log_line_s( EXPORTING iv_severity = 'W' iv_msgnr = '012'
                                              iv_var1 = 'No TLOGO (assuming exchange parts):'
                                              iv_var2 = p_object ).
        l_sobjs-object = p_object.
        l_sobjs-has_exchange_parts = abap_true.
        INSERT l_sobjs INTO TABLE m_objects_with_exchange.
      ELSE.

        SORT lt_objsl.
        l_sobjs-object = p_object.
        LOOP AT lt_objsl ASSIGNING <objsl>
                         WHERE tpgmid  = 'R3TR' AND
                               tobject = 'TABU'.
* R3trans considers PUTTB-entries with WCONTENT IN ('D','P','Q')
* cv 061212 but only exchange is needed for checking here
          SELECT SINGLE * FROM puttb INTO l_puttb
                          WHERE saprelease = m_sapvers AND
                                tabname = <objsl>-tobj_name AND
                                wcontent = 'D'.
          IF sy-subrc = 0.
            l_sobjs-has_exchange_parts = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
        INSERT l_sobjs INTO TABLE m_objects_with_exchange.
        IF l_sobjs-has_exchange_parts = abap_false.
          m_logger->write_log_line_s( EXPORTING iv_severity = 'W' iv_ag = 'TG' iv_msgnr = '013'
                                        iv_var1 = 'ignoring objects of type'
                                        iv_var2 = p_object
                                        iv_var3 = '(no exchange parts)' ).
        ENDIF.
      ENDIF.
      has_exchange_parts = l_sobjs-has_exchange_parts.
    ENDIF.
  ENDMETHOD.

  METHOD check_delivery_tr_for_comp.
    TYPES: ty_sel_trkorr TYPE RANGE OF trkorr.
    CONSTANTS: obj_appd  TYPE smodilog-int_type  VALUE 'APPD',
               oper_trsl TYPE smodilog-operation VALUE 'TRSL',
               oper_imp  TYPE smodilog-operation VALUE 'IMP'.

    DATA: l_type                TYPE tadir-object,
          l_obj_no_tr_tab       TYPE TABLE OF ty_tadir_reduced,
          l_delivery_tr_sel_tab TYPE ty_sel_trkorr,
          l_sel_trkorr          TYPE LINE OF ty_sel_trkorr,
          l_cnt                 TYPE i,
          l_idx                 TYPE sy-tabix,
          l_valid               TYPE abap_bool,
          l_exists              TYPE abap_bool,
          l_smodi_tab           TYPE TABLE OF ty_tadir_reduced,
          l_e071                TYPE e071,
          l_is_delivered        TYPE abap_bool,
          l_file                TYPE tstrf01-filename,
          l_msgv3               TYPE sy-msgv3.

    FIELD-SYMBOLS: <l_wa>          TYPE ty_tadir_reduced,
                   <l_e071>        TYPE e071,
                   <r3tr_limu_map> TYPE ty_r3tr_limu_exception.

    IF p_delivery_tr_tab[] IS INITIAL.
      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = 'No transports listed for component'
                                            iv_var2 = p_comp ).
      RETURN.
    ENDIF.
    m_logger->write_log_line_s( EXPORTING iv_msgnr = '012'
                                          iv_var1 = 'Check deliveries for component '
                                          iv_var2 = p_comp  ).
    m_logger->flush_log( ).


    l_sel_trkorr-option = 'EQ'.
    l_sel_trkorr-sign = 'I'.
    LOOP AT p_delivery_tr_tab INTO l_sel_trkorr-low.
      APPEND l_sel_trkorr TO l_delivery_tr_sel_tab.
    ENDLOOP.
    SELECT t~pgmid t~object t~obj_name t~devclass
      FROM tadir AS t
      INNER JOIN tdevc AS d ON t~devclass = d~devclass
      INTO CORRESPONDING FIELDS OF TABLE l_obj_no_tr_tab
      WHERE t~pgmid = 'R3TR' AND
            t~object <> 'NOTE' AND t~object <> 'CINS' AND "exclude Snote artefacts
            t~object <> 'AVAS' AND "exclude AVAS objects
            t~object <> 'SPRX' AND "exclude SPRX (TADIR created by XPRA --> special logig in SUG7)
            t~genflag <> 'X' AND
            t~srcsystem = 'SAP' AND
            d~dlvunit = p_comp AND
           NOT EXISTS
      ( SELECT pgmid FROM e071
        WHERE trkorr IN l_delivery_tr_sel_tab AND
              pgmid = t~pgmid AND
              object = t~object AND
              obj_name = t~obj_name ).
    SORT l_obj_no_tr_tab BY devclass pgmid object obj_name.

    "sometimes R3TR PROG is only delivered by LIMU REPS for what ever reasons
    "same happens for some other objects, mostly seen in DMIS AddOn
    LOOP AT m_delivery_check_r3tr_limu_map ASSIGNING <r3tr_limu_map>.
      l_msgv3 = 'delivered as XXXX, will be rescued'.
      REPLACE 'XXXX' INTO l_msgv3 WITH <r3tr_limu_map>-limu_object.
      LOOP AT l_obj_no_tr_tab ASSIGNING <l_wa> WHERE object = <r3tr_limu_map>-r3tr_object.
        l_idx = sy-tabix.
        SELECT SINGLE object FROM e071 INTO l_type
          WHERE trkorr IN l_delivery_tr_sel_tab AND
                pgmid = 'LIMU' AND
                object = <r3tr_limu_map>-limu_object AND
                obj_name = <l_wa>-obj_name.
        IF sy-subrc = 0.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                                iv_var1 = <l_wa>-object
                                                iv_var2 = <l_wa>-obj_name
                                                iv_var3 = l_msgv3 ).
          DELETE l_obj_no_tr_tab INDEX l_idx.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    "filter out invalid object types
    LOOP AT l_obj_no_tr_tab ASSIGNING <l_wa>.
      l_valid = check_valid_obj_type( p_object =  <l_wa>-object ).
      IF l_valid = abap_false.
        sy-msgv1 = <l_wa>-object.
        m_logger->write_log_line_s( EXPORTING iv_severity = 'W' iv_ag = 'TG' iv_msgnr = '012'
                                              iv_var1 = sy-msgv1
                                              iv_var2 = ' invalid object type, will be ignored' ).
        l_type = <l_wa>-object.
        DELETE l_obj_no_tr_tab WHERE object = l_type.
      ENDIF.
    ENDLOOP.

    "check if objects are delivered by Note (-> smodilog, rescue logic will pick them up in modifications).
    IF l_obj_no_tr_tab[] IS NOT INITIAL.
      SELECT DISTINCT obj_type AS object obj_name
        INTO CORRESPONDING FIELDS OF TABLE l_smodi_tab
        FROM smodilog
        FOR ALL ENTRIES IN l_obj_no_tr_tab
        WHERE obj_type = l_obj_no_tr_tab-object AND
              obj_name = l_obj_no_tr_tab-obj_name AND
              ( operation <> oper_trsl OR prot_only = abap_false ) AND
              ( operation <> oper_imp  OR prot_only = abap_true ) AND
              ( int_type <> obj_appd OR prot_only = abap_true )
         "exclude reseted and deleted smodilog entries
          AND ( inactive <> smodi_c_inactive_reset AND
                inactive <> smodi_c_inactive_deleted ).
      SORT l_smodi_tab BY object obj_name.
      LOOP AT l_smodi_tab ASSIGNING <l_wa>.
        sy-msgv1 = <l_wa>-object.
        sy-msgv2 = <l_wa>-obj_name.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                              iv_var1 = sy-msgv1
                                              iv_var2 = sy-msgv2
                                              iv_var3 = 'not in delivery transport, found as modification' ).
        DELETE l_obj_no_tr_tab WHERE object = <l_wa>-object AND obj_name = <l_wa>-obj_name.
      ENDLOOP.
    ENDIF.

    LOOP AT l_obj_no_tr_tab ASSIGNING <l_wa>.
      l_idx = sy-tabix.
      IF has_exchange_parts( <l_wa>-object ) = abap_false.
        DELETE l_obj_no_tr_tab WHERE object = <l_wa>-object.
      ELSE. "check if we have dead wood in TADIR
        IF <l_wa>-object = 'DOCV' AND <l_wa>-obj_name(6) = 'INRELN'.
          "release notes, don't care they can be re-downloaded if needed
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                                iv_var1 = 'ignoring release note object'
                                                iv_var2 = <l_wa>-object
                                                iv_var3 = <l_wa>-obj_name ).
          DELETE l_obj_no_tr_tab INDEX l_idx.
          CONTINUE.
        ENDIF.
        l_exists = check_object_existence( p_obj = <l_wa> ).
        IF l_exists = abap_false.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                                iv_var1 = 'ignoring non-existent object'
                                                iv_var2 = <l_wa>-object
                                                iv_var3 = <l_wa>-obj_name ).
          DELETE l_obj_no_tr_tab INDEX l_idx.
          CONTINUE.
        ENDIF.
        IF m_is_sum_mode = abap_true.  "cannot check without upgrade running
          l_e071-pgmid = <l_wa>-pgmid.
          l_e071-object = <l_wa>-object.
          l_e071-obj_name = <l_wa>-obj_name.
          "check if object is in delivery (bound package)
          CALL FUNCTION 'SUBST_OBJECT_PACKAGES_DELIVERY'
            EXPORTING
              iv_e071         = l_e071
            IMPORTING
              ev_is_delivered = l_is_delivered.
          IF l_is_delivered = abap_true.
            m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '013'
                                                  iv_var1 = 'ignoring delivered object'
                                                  iv_var2 = <l_wa>-object
                                                  iv_var3 = <l_wa>-obj_name ).
            DELETE l_obj_no_tr_tab INDEX l_idx.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    l_cnt = lines( l_obj_no_tr_tab ).
    IF l_cnt > 0 AND m_is_sum_mode = abap_true.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                            iv_var1 = 'Processing exception list' ).
      LOOP AT m_sum_exception_list ASSIGNING <l_e071>.
        l_idx = strlen( <l_e071>-obj_name ) - 1.
        IF <l_e071>-obj_name+l_idx(1) = '*'.
          DELETE l_obj_no_tr_tab WHERE pgmid = <l_e071>-pgmid AND
                                       object = <l_e071>-object AND
                                       obj_name CP <l_e071>-obj_name.
        ELSE.
          DELETE l_obj_no_tr_tab WHERE pgmid = <l_e071>-pgmid AND
                                       object = <l_e071>-object AND
                                       obj_name = <l_e071>-obj_name.
        ENDIF.
        IF sy-subrc = 0.
          CONCATENATE <l_e071>-pgmid <l_e071>-object INTO sy-msgv2 SEPARATED BY space.
          sy-msgv3 = <l_e071>-obj_name.
          CLEAR sy-msgv4.
          IF l_idx > 49.
            sy-msgv4 = <l_e071>-obj_name+50.
          ENDIF.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '010'
                                                iv_var1 = 'Ignoring exception key'
                                                iv_var2 = sy-msgv2
                                                iv_var3 = sy-msgv3
                                                iv_var4 = sy-msgv4 ).

        ENDIF.
      ENDLOOP.
    ENDIF.

    l_cnt = lines( l_obj_no_tr_tab ).
    IF l_cnt > 0.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ). "separation only
      WRITE l_cnt TO sy-msgv1 LEFT-JUSTIFIED.
      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                            iv_var1 = sy-msgv1
                                            iv_var2 = 'objects found without delivery transport'
                                            iv_var3 = 'for Software Component'
                                            iv_var4 = p_comp ). "#EC NOTEXT

      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                            iv_var1 = '!!'
                                            iv_var2 = 'The list below contains the number of '
                                            iv_var3 = 'objects found without delivery transport'
                                            iv_var4 = 'per package and application component.' ). "#EC NOTEXT
      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                            iv_var1 = '!!'
                                            iv_var2 = 'Contact the respective application component'
                                            iv_var3 = 'owners for assistance.'
                                            iv_var4 = space ). "#EC NOTEXT
      IF m_is_sum_mode = abap_false.
        " point customer to SAP Note 2318321 and also advise to double check with application if the component
        " is optional and therefore a likely candidate for rescue.
        m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
                                              iv_var1 = '!!'
                                              iv_var2 = 'See also SAP note 2318321 fur further'
                                              iv_var3 = 'informations.' ). "#EC NOTEXT
        m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                              iv_var1 = '!!'
                                              iv_var2 = 'If you are not sure if an Add-On is optional,'
                                              iv_var3 = 'contact the respective application component'
                                              iv_var4 = 'owners for assistance.' ). "#EC NOTEXT
      ENDIF.

      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = ' ' iv_var2 = 'Objects without delivery transport:' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = ' ' iv_var2 = 'Summary per package:' ). "#EC NOTEXT
      write_summary_per_package( EXPORTING p_comp = p_comp
                                           p_obj_tab = l_obj_no_tr_tab ).
      l_file = p_comp.
      REPLACE ALL OCCURRENCES OF '\' IN l_file WITH '_'.
      REPLACE ALL OCCURRENCES OF '/' IN l_file WITH '_'.
      CONCATENATE l_file '_NO_TR_OBJECT.LST' INTO l_file.
      dump_objects_to_file( EXPORTING p_file         = l_file
                                      p_objects      = l_obj_no_tr_tab ).

    ELSE.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                            iv_var1 = 'All objects found in delivery transports' ). "#EC NOTEXT
      sy-msgv2 = p_comp.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = 'Everything ok for component'
                                            iv_var2 = sy-msgv2 ). "#EC NOTEXT
    ENDIF.
    m_logger->flush_log( ).
  ENDMETHOD.

  METHOD log_proj_comp_inconsistencies.

    DATA: lt_devclass    TYPE STANDARD TABLE OF devclass,
          lt_object_keys TYPE TABLE OF ty_tadir_reduced,
          lv_devclass    TYPE devclass,
          lv_file        TYPE tstrf01-filename,
          lv_counter     TYPE i.

    IF p_comp IS INITIAL.
      RETURN.
    ENDIF.

    m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ). "separation only

    sy-msgv4 = '&4 with orig. system <> ''SAP''.'.          "#EC NOTEXT
    REPLACE '&4' IN sy-msgv4 WITH p_comp.
    m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                          iv_var1 = '!!'
                                          iv_var2 = 'The list below contains the number of objects'
                                          iv_var3 = 'per package of project component'
                                          iv_var4 = sy-msgv4 ). "#EC NOTEXT

    m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
                                          iv_var1 = '!!'
                                          iv_var2 = 'See also SAP note 2318321 fur further'
                                          iv_var3 = 'informations.' ). "#EC NOTEXT

    m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                          iv_var1 = ' ' iv_var2 = 'Summary per package:' ). "#EC NOTEXT

    SELECT devclass FROM tdevc INTO TABLE lt_devclass
           WHERE dlvunit = p_comp.

    LOOP AT lt_devclass INTO lv_devclass.

      SELECT COUNT(*) FROM tadir INTO lv_counter
            WHERE devclass  = lv_devclass AND
                  srcsystem = 'SAP'.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      sy-msgv1 = '&1 objects'.                              "#EC NOTEXT
      sy-msgv2 = lv_counter. CONDENSE sy-msgv2.
      REPLACE '&1' IN sy-msgv1 WITH sy-msgv2.
      sy-msgv2 = 'with original system <> ''SAP'''.         "#EC NOTEXT
      sy-msgv3 = 'found in package &2'.                     "#EC NOTEXT
      REPLACE '&2' IN sy-msgv3 WITH lv_devclass.

      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
                                            iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 iv_var3 = sy-msgv3 ).

    ENDLOOP.

    lv_file = p_comp.
    REPLACE ALL OCCURRENCES OF '\' IN lv_file WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN lv_file WITH '_'.
    CONCATENATE lv_file '_NO_CUST_OBJECT.LST' INTO lv_file.

    SELECT tadir~pgmid tadir~object tadir~obj_name tadir~devclass

           FROM tadir
           INNER JOIN tdevc
             ON tdevc~devclass = tadir~devclass
           INTO CORRESPONDING FIELDS OF TABLE lt_object_keys
           WHERE tdevc~dlvunit   = p_comp AND
                 tadir~srcsystem = 'SAP'.

    dump_objects_to_file( EXPORTING p_file         = lv_file
                                    p_include_comp = abap_false
                                    p_objects      = lt_object_keys ).
    m_logger->flush_log( ).

  ENDMETHOD.

  METHOD write_summary_per_package.
    TYPES: BEGIN OF ty_summary,
             devc TYPE devclass,
             cnt  TYPE i,
           END OF ty_summary.
    DATA: l_summary_tab  TYPE TABLE OF ty_summary,
          l_last_package TYPE devclass.
    FIELD-SYMBOLS: <summary_line> TYPE ty_summary,
                   <l_wa>         TYPE ty_tadir_reduced.

    l_last_package = space.
    "table is sorted by devclass!! see caller
    LOOP AT p_obj_tab ASSIGNING <l_wa>.
      IF l_last_package <> <l_wa>-devclass.
        APPEND INITIAL LINE TO l_summary_tab ASSIGNING <summary_line>.
        <summary_line>-devc = <l_wa>-devclass.
        l_last_package = <l_wa>-devclass.
      ENDIF.
      <summary_line>-cnt = <summary_line>-cnt + 1.
    ENDLOOP.
    LOOP AT l_summary_tab ASSIGNING <summary_line>.
      WRITE <summary_line>-cnt TO sy-msgv1(8).
      CONCATENATE sy-msgv1(8) 'objects found without delivery transport' INTO sy-msgv1 SEPARATED BY space.
      CONCATENATE 'in package' <summary_line>-devc INTO sy-msgv2 SEPARATED BY space.
      CLEAR sy-msgv4.
      SELECT SINGLE d~ps_posid
        INTO sy-msgv4
        FROM df14l AS d
        INNER JOIN tdevc AS t ON t~component = d~fctr_id
        WHERE devclass = <summary_line>-devc.
      m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '010'
                                            iv_var1 = sy-msgv1
                                            iv_var2 = sy-msgv2
                                            iv_var3 = 'application component'
                                            iv_var4 = sy-msgv4 ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_deliveries_for_comps.

    DATA: l_comps           TYPE TABLE OF dlvunit,
          l_delivery_tr_tab TYPE trkorrs,
          l_cnt             TYPE i,
          l_comp_type       TYPE cvers-comp_type,
          l_release         TYPE cvers-release.

    FIELD-SYMBOLS: <l_comp> TYPE dlvunit.

    m_logger->write_log_text( EXPORTING iv_msgnr = '011'
                                        iv_text = 'Check deliveries for AddOns (SAP objects)' ).

    IF p_comp4detail IS NOT INITIAL.

      SELECT component FROM cvers INTO TABLE l_comps
        WHERE component = p_comp4detail .

    ELSE.

      SELECT component FROM cvers INTO TABLE l_comps.

    ENDIF.

    LOOP AT m_sap_comps_to_ignore ASSIGNING <l_comp>.
      READ TABLE l_comps TRANSPORTING NO FIELDS WITH TABLE KEY table_line = <l_comp>.
      IF sy-subrc = 0.
        l_cnt = sy-tabix.
        sy-msgv2 = <l_comp>.
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
        m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                              iv_var1 = 'Ignoring component'
                                              iv_var2 = sy-msgv2 ).
        DELETE l_comps WHERE table_line = <l_comp>.
      ENDIF.
    ENDLOOP.

    LOOP AT l_comps ASSIGNING <l_comp>.
      sy-msgv2 = <l_comp>.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011' ).
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = 'Checking component'
                                            iv_var2 = sy-msgv2 ). "#EC NOTEXT

      l_delivery_tr_tab = collect_delivery_tr( p_component = <l_comp> ).

      IF l_delivery_tr_tab[] IS INITIAL.
*       CVERS comp_type = 'C' means: Add-On is developed in the customer's own systems.
        SELECT SINGLE comp_type release FROM cvers INTO (l_comp_type, l_release)
               WHERE component = <l_comp>.
        IF l_comp_type NE 'C'.
          " check that AVERS entry exists. Log e-message if no avers-entry exists.
          SELECT SINGLE addonid FROM avers INTO sy-msgv1
                 WHERE addonid = <l_comp> AND
                       addonrl = l_release.
          IF sy-subrc NE 0.
            sy-msgv1 = 'Component &1'.                      "#EC NOTEXT
            REPLACE '&1' IN sy-msgv1 WITH <l_comp>.
            sy-msgv2 = 'is not a project component,'.       "#EC NOTEXT
            sy-msgv3 = 'but entry about AddOn update info is missing.'. "#EC NOTEXT
            m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
                                                  iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 iv_var3 = sy-msgv3 ). "#EC NOTEXT

          ENDIF.

          sy-msgv2 = <l_comp>.
          m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '012'
                                                iv_var1 = 'No delivery transports found for component'
                                                iv_var2 = sy-msgv2 ). "#EC NOTEXT

        ELSE. " elseif l_comp_type eq 'C'. ==> Add-On is developed in customer's own systems.

          l_cnt = 0.
          SELECT COUNT(*) FROM tadir
                 INNER JOIN tdevc
                   ON tdevc~devclass = tadir~devclass
                 INTO l_cnt
                 WHERE tdevc~dlvunit   = <l_comp> AND
                       tadir~srcsystem = 'SAP'.
          IF l_cnt > 0.

            sy-msgv1 = 'Component &1 is a project component,'. "#EC NOTEXT
            REPLACE '&1' IN sy-msgv1 WITH <l_comp>.
            sy-msgv2 = 'but has &2 objects'.                "#EC NOTEXT
            sy-msgv3 = l_cnt. CONDENSE sy-msgv3.
            REPLACE '&2' IN sy-msgv2 WITH sy-msgv3.
            sy-msgv3 = 'with original system = ''SAP''.'.   "#EC NOTEXT
            m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'TG' iv_msgnr = '013'
                                                  iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 iv_var3 = sy-msgv3 ).

            log_proj_comp_inconsistencies( EXPORTING p_comp = <l_comp> ).

          ELSE.

            sy-msgv1 = 'Component &1 is a project component.'. "#EC NOTEXT
            REPLACE '&1' IN sy-msgv1 WITH <l_comp>.
            sy-msgv2 = 'Everything ok.'.                    "#EC NOTEXT
            m_logger->write_log_line_s( EXPORTING iv_severity = '' iv_ag = 'TG' iv_msgnr = '012'
                                                  iv_var1 = sy-msgv1 iv_var2 = sy-msgv2 ).
          ENDIF.
        ENDIF. " if l_comp_type ne 'C'.

        CONTINUE.

      ENDIF. " if l_delivery_tr_tab[] is initial.

      check_delivery_tr_for_comp( EXPORTING p_comp    = <l_comp>
                                            p_delivery_tr_tab = l_delivery_tr_tab ).
    ENDLOOP.

  ENDMETHOD.

  METHOD collect_delivery_tr.
    DATA: l_avers TYPE avers,
          l_pat03 TYPE pat03.
    FIELD-SYMBOLS: <l_trkorr> TYPE trkorr.

    CLEAR p_delivery_trkorrs[].

    IF p_summod = abap_true.

      "when running within SUM, rddit021 has already been executed -> use the result
      "see form collect_transports_for_addons SAPLSUG7
      SELECT * FROM navers BYPASSING BUFFER INTO CORRESPONDING FIELDS OF l_avers
                 WHERE relstamp = 'CURRENT'
                   AND updstatus IN ('A', 'M') AND
** not save anything from supplemented add-ons HS 6.20
                       ( updtype  = 'T' OR
                         updtype  = 'C' OR
                         updtype  = 'J' ).
        SELECT obj_name AS trkorr FROM e071 APPENDING TABLE p_delivery_trkorrs
                   WHERE trkorr = l_avers-fulltask  AND
                         pgmid  = 'LIMU'          AND
                         object = 'COMM'.
        IF sy-subrc <> 0.
          m_logger->write_log_line_s( EXPORTING iv_severity = 'E' iv_ag = 'UG' iv_msgnr = '172'
                                                iv_var1 = l_avers-fulltask
                                                iv_var2 = l_avers-addonid ).
        ENDIF.
      ENDSELECT.

    ELSE.  "not in SUM
      "see rddit021, form calculate_fulltask

      SELECT * FROM avers BYPASSING BUFFER
        INTO l_avers
        WHERE addonid    = p_component AND
              updstatus = '+'
        ORDER BY enddate DESCENDING
                 endtime DESCENDING
                 addonrl DESCENDING.

** add all CSPs to the list of commandfiles here
        SELECT * FROM pat03 INTO l_pat03
          WHERE component  = l_avers-addonid AND
                comp_rel   = l_avers-addonrl AND
                patch_type = 'CSP' AND
                status     = 'I'.
          APPEND l_pat03-patch TO p_delivery_trkorrs.
*       message i815(tg). " Piece list & added.
          sy-msgv1 = l_pat03-patch.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '815'
                                                iv_var1 = sy-msgv1 ).
        ENDSELECT.

** add all AOPs/CRTs to the list of commandfiles here
        SELECT * FROM pat03 INTO l_pat03
          WHERE addon_id   = l_avers-addonid AND
                addon_rel  = l_avers-addonrl AND
              ( patch_type = 'AOP' OR
                patch_type = 'CRT'    ) AND
                status     = 'I'.
          APPEND l_pat03-patch TO p_delivery_trkorrs.
*       message i815(tg). " Piece list & added.
          sy-msgv1 = l_pat03-patch.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '815'
                                                iv_var1 = sy-msgv1 ).
        ENDSELECT.

        IF l_avers-fulltask <> space.
*       Add the objects of the latest FULLTASK and exit
*       Print message for the next task being collected
*       message i815(tg). " Piece list & added.
          sy-msgv1 = l_avers-fulltask.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '815'
                                                iv_var1 = sy-msgv1 ).
          APPEND l_avers-fulltask TO p_delivery_trkorrs.
          "collect tasks included in fulltask
          SELECT obj_name AS trkorr FROM e071 APPENDING TABLE p_delivery_trkorrs
            WHERE trkorr = l_avers-fulltask AND
                  pgmid = 'LIMU' AND object = 'COMM'.
          EXIT.                  " collect for this add on
        ELSEIF l_avers-deltatask <> space.
*       Print message for the next task being collected
*       message i815(tg). " Piece list & added.
          sy-msgv1 = l_avers-deltatask.
          m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '815'
                                                iv_var1 = sy-msgv1 ).
          APPEND l_avers-deltatask TO p_delivery_trkorrs.
          "collect tasks included in delta task
          SELECT obj_name AS trkorr FROM e071 APPENDING TABLE p_delivery_trkorrs
            WHERE trkorr = l_avers-deltatask AND
          pgmid = 'LIMU' AND object = 'COMM'.
        ENDIF.
      ENDSELECT.
    ENDIF.
    LOOP AT p_delivery_trkorrs ASSIGNING <l_trkorr>.
      sy-msgv1 = <l_trkorr>.
      m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '012'
                                            iv_var1 = sy-msgv1
                                            iv_var2 = 'found as delivery transport' ).

    ENDLOOP.
  ENDMETHOD.

  METHOD collect_sum_exception_list.
    DATA: l_file    TYPE tstrf01-file,
          l_line    TYPE c LENGTH 200,
          l_e071_wa TYPE e071.

    CALL FUNCTION 'STRF_SETNAME'
      EXPORTING
        dirtype  = 'P'
        filename = 'RESCUECOMPCHECKEXC.LST'
        subdir   = 'bin'
      IMPORTING
        file     = l_file
      EXCEPTIONS
        OTHERS   = 2.
    IF sy-subrc <> 0.
      m_logger->write_log_line_s(
        EXPORTING
          iv_severity = 'E'
          iv_ag       = 'TG'
          iv_msgnr    = '011'
          iv_var1     = 'Could not find exception list file'   ).
      RETURN.
    ENDIF.

    " read the content of the file
    OPEN DATASET l_file IN TEXT MODE FOR INPUT
                         ENCODING UTF-8.
    IF sy-subrc = 0.
      DO.
        READ DATASET l_file INTO l_line.
        IF sy-subrc <> 0.
          EXIT.
        ELSEIF l_line(1) = '#' OR l_line IS INITIAL.
          CONTINUE.
        ELSE.
          CLEAR l_e071_wa.
          SPLIT l_line AT space INTO l_e071_wa-pgmid l_e071_wa-object l_e071_wa-obj_name.
          INSERT l_e071_wa INTO TABLE m_sum_exception_list.
        ENDIF.
      ENDDO.
    ELSE.
    ENDIF.
    CLOSE DATASET l_file.
    m_logger->write_log_line_s( EXPORTING iv_ag = 'TG' iv_msgnr = '011'
                                          iv_var1 = 'Exception list successfully read.'   ).
  ENDMETHOD.


  METHOD process_error_tab.
    DATA: l_msg_ag TYPE sprot-ag,
          l_msg_nr TYPE sprot-msgnr.
    FIELD-SYMBOLS: <err> TYPE LINE OF ty_trmess_tab.

    LOOP AT p_error_tab ASSIGNING <err>.
      l_msg_ag = <err>-msgid.
      l_msg_nr = <err>-msgno.
      m_logger->write_log_line_s(
        EXPORTING
          iv_ag       = l_msg_ag
          iv_msgnr    = l_msg_nr
          iv_var1     = <err>-msgv1
          iv_var2     = <err>-msgv2
          iv_var3     = <err>-msgv3
          iv_var4     = <err>-msgv4 ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
         ID 'S_ADMI_FCD' FIELD 'SUM'.
  IF sy-subrc <> 0.
    MESSAGE e342(tg) RAISING access_denied.
    EXIT.
  ENDIF.

  DATA: l_checker   TYPE REF TO lcl_tadir_checker,
        l_comps4fix TYPE RANGE OF dlvunit.

  l_comps4fix[] = p_comps[].
  CREATE OBJECT l_checker
    EXPORTING
      p_is_sum_mode = p_summod
      p_check       = p_check
      p_fixnocomp   = p_fixnoc
      p_fixloc      = p_fixloc
      p_comps4fix   = l_comps4fix[]
      p_trkorr      = p_trkorr.
  l_checker->run( ).
