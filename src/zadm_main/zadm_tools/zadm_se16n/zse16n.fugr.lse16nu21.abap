FUNCTION se16n_cds_select_prepare.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_TAB) TYPE  SE16N_TAB
*"     VALUE(I_TESTMODE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_CDS_NO_SYS) TYPE  CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_DONE) TYPE  CHAR1
*"  CHANGING
*"     VALUE(C_STRING) TYPE  STRING OPTIONAL
*"  EXCEPTIONS
*"      NO_DDL_SOURCE
*"      NO_ROLLNAME_REFERENCE_FOUND
*"      NO_BATCH_POSSIBLE
*"      ABORT_BY_USER
*"----------------------------------------------------------------------

  DATA: lr_handler       TYPE REF TO if_dd_ddl_handler,
        ld_rsdxx_objname TYPE ddobjname,
        ld_ddlname       TYPE ddlname.
  DATA: lv_entity_name TYPE ddstrucobjname,
        lv_ddfield     TYPE ddfield.
  DATA(lo_utility) = cl_dd_sobject_factory=>create( ).
  DATA: BEGIN OF fields OCCURS 2.
      INCLUDE STRUCTURE sval.
  DATA: END OF fields.
  DATA: BEGIN OF ls_params,
          param     TYPE ddparname,
          tabname   TYPE tabname,
          fieldname TYPE fieldname,
          value     TYPE string,
        END OF ls_params.
  DATA: lt_params       LIKE ls_params OCCURS 2.
  DATA: returncode(1)   TYPE c,
        popup_title(30) TYPE c.
  DATA: ls_ddftx        TYPE ddftx.
  DATA: ld_tabix        TYPE sy-tabix.
  DATA: ld_count        TYPE sy-tabix.
  DATA: ld_tab          TYPE ddobjname.
  DATA: ld_field        LIKE dfies-lfieldname.
  DATA: ld_found(1).
  DATA: BEGIN OF ls_syst,
          fix(3)  VALUE 'SY-',
          var(10),
        END OF ls_syst.
  FIELD-SYMBOLS: <syst_field>.

*.this function sends a popup, so only possible online
  IF sy-batch = true.
    RAISE no_batch_possible.
  ENDIF.

*.define the handler to read DDL-definition
  lr_handler = cl_dd_ddl_handler_factory=>create( ).
  ld_rsdxx_objname = i_tab.
  TRY.
      ld_ddlname =
          lr_handler->get_ddl_name_4_dd_artefact( EXPORTING ddname =  ld_rsdxx_objname ).
    CATCH cx_dd_ddl_exception.
      MESSAGE w345(e2) WITH ld_rsdxx_objname RAISING no_ddl_source.
  ENDTRY.

*.if table has no DDL, just finish
  IF ld_ddlname = space.
    e_done = false.
*.table is a view that has a DDL
  ELSE.
*...read the parameters defined, if available
    TRY.
        lv_entity_name = ld_ddlname.
        lo_utility->read(
          EXPORTING
            get_state         = 'A'    " Status of the Data Dictionary Object
            sobjnames         = VALUE #( ( lv_entity_name ) ) " Names of objects to be read
          IMPORTING
            dd10bv_tab        = DATA(dd10bv_tab) " Table for Parameters for Views/Table Functions
        ).
      CATCH cx_dd_sobject_get INTO DATA(lo_err).
        MESSAGE lo_err TYPE 'I'.
    ENDTRY.

*...if no parameters exist, step out
    IF dd10bv_tab[] IS INITIAL.
      e_done = false.
      EXIT.
    ENDIF.

*...if parameters exist, ask for their value
    SORT dd10bv_tab BY rollname.
    CLEAR fields.
    LOOP AT dd10bv_tab INTO DATA(dd10bv_line).   "append parameters to lt_ddfields
*      lv_ddfield-fieldname = to_upper( dd10bv_line-parametername_raw ).
*      lv_ddfield-datatype  = dd10bv_line-datatype.
*      lv_ddfield-leng      = dd10bv_line-leng.
*      lv_ddfield-decimals  = dd10bv_line-decimals.
*      APPEND lv_ddfield TO lt_param_metadata.
*.....popup can only handle table/field, so find usage in real tables
      CLEAR ld_found.
      IF dd10bv_line-rollname = space.
        SELECT DISTINCT c~tabname     AS tabname,
                        c~fieldname   AS fieldname
           INTO CORRESPONDING FIELDS OF @ls_ddftx
              FROM dd03l AS c
           INNER JOIN dd02l AS t ON t~tabname = c~tabname
           INNER JOIN tadir AS p
              ON p~pgmid    = 'R3TR'
             AND p~object   = 'TABL'
             AND p~obj_name = c~tabname
             WHERE datatype    = @dd10bv_line-datatype
               AND leng        = @dd10bv_line-leng
               AND decimals    = @dd10bv_line-decimals
               AND depth       = '00'
               AND t~as4local  = 'A'
               AND c~tabname  <> @fields-tabname.      "#EC CI_BUFFJOIN
*.......every usage must only occur once
          READ TABLE fields WITH KEY tabname   = ls_ddftx-tabname
                                     fieldname = ls_ddftx-fieldname.
          IF sy-subrc <> 0.
*...........check that field really can be used as a reference
            ld_tab   = ls_ddftx-tabname.
            ld_field = ls_ddftx-fieldname.
            CALL FUNCTION 'DDIF_FIELDINFO_GET'
              EXPORTING
                tabname        = ld_tab
                lfieldname     = ld_field
              EXCEPTIONS
                not_found      = 1
                internal_error = 2
                OTHERS         = 3.
*...........only if reference can be read, take field
            IF sy-subrc = 0.
              ld_found = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDSELECT.
      ELSE.
        SELECT DISTINCT c~tabname     AS tabname,
                        c~fieldname   AS fieldname
           INTO CORRESPONDING FIELDS OF @ls_ddftx
              FROM dd03l AS c
            INNER JOIN dd02l AS t ON t~tabname = c~tabname
            INNER JOIN tadir AS p
               ON p~obj_name = c~tabname
              AND p~pgmid    = 'R3TR'
              AND p~object   = 'TABL'
            WHERE rollname    = @dd10bv_line-rollname
              AND depth       = '00'
              AND c~datatype <> 'REF'
               AND c~tabname  <> @fields-tabname.      "#EC CI_BUFFJOIN
*.......every usage must only occur once
          READ TABLE fields WITH KEY tabname   = ls_ddftx-tabname
                                     fieldname = ls_ddftx-fieldname.
          IF sy-subrc <> 0.
*...........check that field really can be used as a reference
            ld_tab   = ls_ddftx-tabname.
            ld_field = ls_ddftx-fieldname.
            CALL FUNCTION 'DDIF_FIELDINFO_GET'
              EXPORTING
                tabname        = ld_tab
                lfieldname     = ld_field
              EXCEPTIONS
                not_found      = 1
                internal_error = 2
                OTHERS         = 3.
*...........only if reference can be read, take field
            IF sy-subrc = 0.
              ld_found = 'X'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDSELECT.
*.......data element is not used at all -> check for something similar
        IF sy-subrc <> 0 or
           ld_found <> 'X'.
          SELECT DISTINCT c~tabname     AS tabname,
                        c~fieldname   AS fieldname
           INTO CORRESPONDING FIELDS OF @ls_ddftx
              FROM dd03l AS c
           INNER JOIN dd02l AS t ON t~tabname = c~tabname
           INNER JOIN tadir AS p
              ON p~pgmid    = 'R3TR'
             AND p~object   = 'TABL'
             AND p~obj_name = c~tabname
             WHERE datatype    = @dd10bv_line-datatype
               AND leng        = @dd10bv_line-leng
               AND decimals    = @dd10bv_line-decimals
               AND depth       = '00'
               AND t~as4local  = 'A'
               AND c~tabname  <> @fields-tabname.      "#EC CI_BUFFJOIN
*.......every usage must only occur once
            READ TABLE fields WITH KEY tabname   = ls_ddftx-tabname
                                       fieldname = ls_ddftx-fieldname.
            IF sy-subrc <> 0.
*...........check that field really can be used as a reference
              ld_tab   = ls_ddftx-tabname.
              ld_field = ls_ddftx-fieldname.
              CALL FUNCTION 'DDIF_FIELDINFO_GET'
                EXPORTING
                  tabname        = ld_tab
                  lfieldname     = ld_field
                EXCEPTIONS
                  not_found      = 1
                  internal_error = 2
                  OTHERS         = 3.
*...........only if reference can be read, take field
              IF sy-subrc = 0.
                ld_found = 'X'.
                EXIT.
              ENDIF.
            ENDIF.
          ENDSELECT.
        ENDIF.
      ENDIF.
*.....data element has no usage
      IF sy-subrc <> 0 OR
         ld_found <> 'X'.
        RAISE no_rollname_reference_found.
      ENDIF.
      CLEAR fields.
      fields-tabname     = ls_ddftx-tabname.
      fields-fieldname   = ls_ddftx-fieldname.
      fields-fieldtext   = dd10bv_line-parametername_raw.
      fields-field_attr  = '00'.    "input-able
      fields-field_obl   = true.    "obligatory
*.....in case there is a reference to a system field fill default
*      IF dd10bv_line-systfield <> space.
*        ls_syst-var = dd10bv_line-systfield.
*        CONDENSE ls_syst.
*        ASSIGN (ls_syst) TO <syst_field>.
*        IF sy-subrc = 0.
*          fields-value = <syst_field>.
*        ENDIF.
*        IF i_cds_no_sys <> true.
*          APPEND fields.
**.....store information which parameter is which line
*          ls_params-param     = dd10bv_line-parametername_raw.
*          ls_params-tabname   = fields-tabname.
*          ls_params-fieldname = fields-fieldname.
*          APPEND ls_params TO lt_params.
*        ENDIF.
*      ELSE.
      APPEND fields.
*.....store information which parameter is which line
      ls_params-param     = dd10bv_line-parametername_raw.
      ls_params-tabname   = fields-tabname.
      ls_params-fieldname = fields-fieldname.
      APPEND ls_params TO lt_params.
*      ENDIF.
    ENDLOOP.

*..due to system parameters it could be that no parameter is left
*..in that case, do not send popup
    IF fields[] IS INITIAL.
      e_done = false.
      EXIT.
    ENDIF.

    popup_title  = TEXT-c01.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title = popup_title
      IMPORTING
        returncode  = returncode
      TABLES
        fields      = fields.
*...abort by user
    IF returncode = 'A'.
      RAISE abort_by_user.
    ELSE.
*.....now generate select-string
      DESCRIBE TABLE lt_params LINES ld_count.
*.This leads to error that field MANDT does not exist
*      CONCATENATE ld_ddlname '(#' INTO c_string.
*.So I have to take the table-name
      CONCATENATE i_tab '(#' INTO c_string.
      ld_tabix = 0.
      LOOP AT lt_params INTO ls_params.
        ADD 1 TO ld_tabix.
        READ TABLE fields WITH KEY tabname   = ls_params-tabname
                                   fieldname = ls_params-fieldname.
        IF sy-subrc = 0.
          IF ld_tabix < ld_count.
            CONCATENATE c_string ls_params-param '#=#' '''' fields-value '''' ',#'
            INTO c_string.
*.........last one
          ELSE.
            CONCATENATE c_string ls_params-param '#=#' '''' fields-value '''' ' )'
            INTO c_string.
          ENDIF.
        ENDIF.
      ENDLOOP.
*      REPLACE ALL OCCURRENCES OF '#' IN c_string WITH space.
      WHILE sy-subrc = 0.
        REPLACE '#' WITH space INTO c_string.
      ENDWHILE.
      e_done = true.
    ENDIF.
  ENDIF.

*.in testmode show string
  IF i_testmode = true.
    WRITE c_string.
  ENDIF.

ENDFUNCTION.
