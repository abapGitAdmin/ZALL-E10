CLASS /adesso/cl_fi_remad_cust_data DEFINITION PUBLIC FINAL.
  PUBLIC SECTION.


    TYPES: type_t_cust TYPE TABLE OF /adesso/fi_remad WITH DEFAULT KEY,
           type_t_bdc  TYPE TABLE OF bdcdata WITH DEFAULT KEY.

    METHODS:    constructor.
    CLASS-METHODS: get_config IMPORTING VALUE(iv_option)   TYPE /adesso/fi_neg_remadv_option OPTIONAL
                                        VALUE(iv_category) TYPE /adesso/fi_neg_remadv_cat OPTIONAL
                                        VALUE(iv_field)    TYPE /adesso/fi_neg_remadv_field OPTIONAL
                                        VALUE(iv_id)       TYPE /adesso/fi_neg_remadv_id OPTIONAL
                              RETURNING VALUE(rv_t_values) TYPE type_t_cust,

      get_config_value IMPORTING VALUE(iv_option)   TYPE /adesso/fi_neg_remadv_option
                                 VALUE(iv_category) TYPE /adesso/fi_neg_remadv_cat
                                 VALUE(iv_field)    TYPE /adesso/fi_neg_remadv_field
                                 VALUE(iv_id)       TYPE /adesso/fi_neg_remadv_id
                       RETURNING VALUE(rv_value)    TYPE /adesso/fi_neg_remadv_val,

      get_batch_data IMPORTING VALUE(iv_option) TYPE /adesso/fi_neg_remadv_option
                     RETURNING VALUE(rv_t_bdc)  TYPE type_t_bdc,


      determine_values  IMPORTING VALUE(iv_t_bdc)   TYPE type_t_bdc
                                  VALUE(iv_wa_data) TYPE any
                        RETURNING VALUE(rv_t_bdc)   TYPE type_t_bdc

                        .
  PRIVATE SECTION.

ENDCLASS.



CLASS /adesso/cl_fi_remad_cust_data IMPLEMENTATION.
  METHOD constructor.


  ENDMETHOD.                    "constructor

  METHOD get_config.

    DATA: where_tab   TYPE TABLE OF edpline,
          source_line TYPE          edpline.

    IF iv_option IS NOT INITIAL.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_OPTION EQ ''' iv_option ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_category IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_CATEGORY EQ ''' iv_category ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_field IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.
      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_FIELD EQ ''' iv_field ''' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    IF iv_id IS NOT INITIAL.
      IF lines( where_tab ) <> 0.
        APPEND ' AND ' TO where_tab.
      ENDIF.

      DATA: lv_id(3) TYPE c.
      lv_id = iv_id.

      CONCATENATE '/ADESSO/FI_REMAD~NEGREM_ID EQ ' lv_id ' ' INTO source_line.
      APPEND source_line TO where_tab.
    ENDIF.

    SELECT *
      INTO TABLE rv_t_values
      FROM /adesso/fi_remad
      WHERE     /adesso/fi_remad~mandt EQ sy-mandt AND (where_tab).


  ENDMETHOD.                    "get_config

  METHOD get_config_value.


    SELECT SINGLE negrem_value
      INTO rv_value
      FROM /adesso/fi_remad
      WHERE negrem_option    EQ iv_option
        AND negrem_category  EQ iv_category
        AND negrem_field     EQ iv_field
       AND negrem_id        EQ iv_id.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = rv_value
      IMPORTING
        output = rv_value.



  ENDMETHOD.                    "get_config_value

  METHOD get_batch_data.

    DATA: wa_bdc TYPE bdcdata.

    DATA: lv_bdc_data      TYPE /adesso/fi_remad,
          lv_x_segcomplete TYPE x,
          x01              TYPE x VALUE '01',
          x02              TYPE x VALUE '02',
          x03              TYPE x VALUE '03',
          x04              TYPE x VALUE '04',
          x07              TYPE x VALUE '07'.


    SELECT *
      INTO lv_bdc_data
      FROM /adesso/fi_remad
         WHERE negrem_option = iv_option
            AND negrem_category LIKE 'BDC_%'
      ORDER BY negrem_category
               negrem_id
               negrem_field.

      CASE lv_bdc_data-negrem_category.

        WHEN 'BDC_START'.

          CASE lv_bdc_data-negrem_field.

            WHEN 'PROGRAM'.
              wa_bdc-program = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x01.
            WHEN 'DYNPRO'.
              wa_bdc-dynpro = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x02.
            WHEN 'DYNBEGIN'.
              wa_bdc-dynbegin = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x04.
          ENDCASE.

          IF lv_x_segcomplete = x07.

            APPEND wa_bdc TO rv_t_bdc.
            CLEAR lv_x_segcomplete.
            CLEAR wa_bdc.

          ENDIF.

        WHEN 'BDC_DATA'.

          CASE lv_bdc_data-negrem_field.

            WHEN 'FIELD'.
              wa_bdc-fnam = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x01.
            WHEN 'VALUE'.
              wa_bdc-fval = lv_bdc_data-negrem_value.
              lv_x_segcomplete = lv_x_segcomplete BIT-OR x02.

          ENDCASE.

          IF  lv_x_segcomplete = x03.

            APPEND wa_bdc TO rv_t_bdc.
            CLEAR lv_x_segcomplete.
            CLEAR wa_bdc.

          ENDIF.

      ENDCASE.

    ENDSELECT.

*   Die Startwerte müssen immer an Indexposition 1 stehen,
*   da sonst der Batchaufruf fehlschlägt
    SORT rv_t_bdc
                 BY program DESCENDING
                    fnam    ASCENDING.

  ENDMETHOD.                    "get_batch_data

  METHOD determine_values.

    FIELD-SYMBOLS: <fs_tab>   TYPE table,
                   <fs_line>  TYPE bdcdata,
                   <fs_field> TYPE any.

    LOOP AT iv_t_bdc ASSIGNING <fs_line>.

      IF <fs_line> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.


      IF <fs_line>-fval IS NOT INITIAL AND <fs_line>-fval(1) EQ ''''.
        REPLACE ALL OCCURRENCES OF '''' IN <fs_line>-fval WITH ''.
        APPEND <fs_line> TO rv_t_bdc.
        CONTINUE.
      ELSE.

        ASSIGN COMPONENT <fs_line>-fval
                              OF STRUCTURE iv_wa_data
                              TO <fs_field>
                              CASTING TYPE (<fs_line>-fnam).

        IF <fs_field> IS NOT ASSIGNED.
          APPEND <fs_line> TO rv_t_bdc.
          CONTINUE.
        ENDIF.
      ENDIF.

      <fs_line>-fval = <fs_field>.
      APPEND <fs_line> TO rv_t_bdc.

    ENDLOOP.


  ENDMETHOD.                    "determine_values

ENDCLASS.
