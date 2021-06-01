CLASS /ado/cl_sql_importer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS import_csv_to_datacatalog
      IMPORTING
        !seperator          TYPE char01 DEFAULT ';'
        !delete_datacatalog TYPE abap_bool DEFAULT ' ' .
    METHODS constructor .
    METHODS generate_from_datacat
      IMPORTING
        !delete_suprem TYPE abap_bool DEFAULT ' '
        !p_n           TYPE i .
    METHODS join_database
      IMPORTING
        !row_quantaty TYPE i DEFAULT 500000
        !p_database   TYPE dd03l-tabname DEFAULT '/ADO/SQL_ALL' .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA seperator TYPE char01 VALUE ',' ##NO_TEXT.
    DATA delete_datacatalog TYPE abap_bool VALUE ' ' ##NO_TEXT.
    DATA p_n TYPE i VALUE 10 ##NO_TEXT.
    DATA delete_suprem TYPE abap_bool VALUE ' ' ##NO_TEXT.
    DATA sap_database TYPE dd02l-tabname .
ENDCLASS.



CLASS /ADO/CL_SQL_IMPORTER IMPLEMENTATION.


  METHOD constructor.

    "Parameter in Methoden übergeben statt Constructor

*    me->seperator = SEPERATOR.
*    me->delete_datacatalog = DELETE_DATACATALOG.
*    me->p_n = p_n.
*    me->delete_suprem = delete_suprem.
*     me->sap_database = sap_database.



  ENDMETHOD.


  METHOD generate_from_datacat.

    TRY .
        DATA: ls_datasuprem  TYPE /ado/sql_suprem.

*      erzeuge tiefe struktur <struc_expl> mit einer tabelle von beispieldaten für jede komponente
        DATA(o_struc_desc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_datasuprem ) ).
        DATA(lt_component) = VALUE cl_abap_structdescr=>component_table(
          FOR <comp> IN o_struc_desc->components FROM 2 (
            VALUE #(
              name = <comp>-name
              type = CAST #( cl_abap_tabledescr=>describe_by_name( 'STRING_TABLE' ) )
            )
          )
        ).
        o_struc_desc = cl_abap_structdescr=>create( lt_component ).
        DATA o_struc_expl TYPE REF TO data.
        CREATE DATA o_struc_expl TYPE HANDLE o_struc_desc.
        ASSIGN o_struc_expl->* TO FIELD-SYMBOL(<struc_expl>).


*      fülle die tabellen der tiefen struktur mit daten
        FIELD-SYMBOLS <tab> TYPE table.
        LOOP AT o_struc_desc->components ASSIGNING FIELD-SYMBOL(<comp1>).
          ASSIGN COMPONENT <comp1>-name OF STRUCTURE <struc_expl> TO <tab>.

          SELECT exampledata
            FROM /ado/sql_datacat
            INTO TABLE <tab>
            WHERE fieldname = <comp1>-name.

          IF lines( <tab> ) = 0.
            MESSAGE 'Missing data!' TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.
        ENDLOOP.

*      fülle die datenbanktabelle mit random daten aus der tiefen
        DATA(randomi) = cl_abap_random=>create( ).
        IF delete_suprem = abap_true.
          DELETE FROM /ado/sql_suprem.
        ENDIF.
        DO p_n TIMES.
          ls_datasuprem-id = sy-index.

          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = ( sy-index * 100 ) DIV p_n
              text       = |Bitte warten... { sy-index } von { p_n }|.

          LOOP AT o_struc_desc->components ASSIGNING FIELD-SYMBOL(<comp2>).
            ASSIGN COMPONENT <comp2>-name OF STRUCTURE <struc_expl> TO <tab>.
            ASSIGN COMPONENT <comp2>-name OF STRUCTURE ls_datasuprem TO FIELD-SYMBOL(<value>).

            IF lines( <tab> ) > 0.
              <value> = <tab>[ randomi->intinrange( low = 1 high = lines( <tab> ) ) ].
            ENDIF.
          ENDLOOP.

          " INSERT /ado/sql_suprem FROM ls_datasuprem.
        ENDDO.

        CALL TRANSACTION 'SE16N'.

      CATCH cx_root INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'I'.
    ENDTRY.


  ENDMETHOD.


  METHOD import_csv_to_datacatalog.



    DATA: lt_files       TYPE filetable,
          lv_rc          TYPE i,
          lv_action      TYPE i,

          lt_csv_records TYPE string_table.

    cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                           multiselection          = abap_true
                                                CHANGING   file_table              = lt_files
                                                           rc                      = lv_rc
                                                           user_action             = lv_action
                                                EXCEPTIONS file_open_dialog_failed = 1
                                                           cntl_error              = 2
                                                           error_no_gui            = 3
                                                           not_supported_by_gui    = 4
                                                           OTHERS                  = 5 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    IF lv_action <> cl_gui_frontend_services=>action_ok OR
       lines( lt_files ) <> 1.
      MESSAGE 'Fehler beim Auswählen der Datei' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    TRY.
        cl_gui_frontend_services=>gui_upload( EXPORTING
                                                filename = CONV #( lt_files[ 1 ]-filename )
                                                filetype = 'ASC'
                                              CHANGING
                                                data_tab = lt_csv_records ).
      CATCH cx_root INTO DATA(e_text2).
        MESSAGE e_text2->get_text( ) TYPE 'E'.
    ENDTRY.

    IF delete_datacatalog = abap_true.
      "  DELETE FROM /ado/sql_datacat.
    ENDIF.

    TYPES: BEGIN OF abc.
             INCLUDE TYPE /ado/sql_food.
           TYPES:  END OF abc.
    DATA:lt_film TYPE TABLE OF abc.
    DATA:ls_film TYPE abc.






    DATA lv_counter TYPE i.
    DATA: idtemp TYPE char07.

    DATA counter TYPE i.

    LOOP AT lt_csv_records INTO DATA(ls_data).
      lv_counter = lv_counter + 1.
      idtemp = lv_counter.
      idtemp = |{ idtemp  WIDTH = 7 ALPHA = IN }|.

      ls_film-id_food = idtemp.

      "ls_data-id... = idtemp.




*********     medical
********data: BEGIN OF wa,
********        field1 type c,
********        field2 type d,
********        field3 type i,
********      END OF wa.
********DATA: r_descr TYPE REF TO cl_abap_structdescr,
********      wa_comp TYPE abap_compdescr.
********
********r_descr ?= cl_abap_typedescr=>describe_by_data( ls_film ).
********
********
********
********  WRITE:/ wa_comp-name.
********  SPLIT ls_data AT ';' INTO TABLE DATA(split_tab).
********
********  LOOP at split_tab INTO DATA(split_wa).
********    APPEND SPLIT_wa to lt_film.
********    endloop.
********
********
********Write 'Debug'.


**     medical

*DATA: tempchildren TYPE string,
*      tempavg_comm TYPE string,
*      tempav TYPE string.
*
*
*
*
*
*      SPLIT ls_data AT ';' INTO
*
*                              ls_film-name
*                              ls_film-gender
*                              ls_film-dob ls_film-zipcode
*                              ls_film-employment_status
*                              ls_film-education
*                              ls_film-marital_status
*                              tempchildren
*                              "ls_film-children
*                              ls_film-ancestry
*                              tempavg_comm
*                              "ls_film-avg_commute
*                              ls_film-daily_internet_use
*                              tempav
*                              "ls_film-available_vehicles
*                              ls_film-military_service
*                              ls_film-disease.
*
*     ls_film-children =  tempchildren .
*     ls_film-available_vehicles = tempav.
*
*
*     DATA var_for_dec TYPE p DECIMALS 2.
*    TRANSLATE tempavg_comm USING '.'.
*    CONDENSE tempavg_comm no-GAPS.
*    CLEAr var_for_dec.
*    var_for_dec = var_for_dec + tempavg_comm.
*
*    ls_film-avg_commute = var_for_dec.
*
*
*
*
*      APPEND ls_film TO lt_film.
*     medical

*       für film
*          SPLIT ls_data AT ';' INTO
*          ls_film-yearx
*          ls_film-length
*          ls_film-title
*          ls_film-subject
*          ls_film-actor
*          ls_film-actress
*          ls_film-director
*          ls_film-popularity
*          ls_film-awards
*          ls_film-imagex.
*          APPEND ls_film TO lt_film.
*          für film

*        food
        SPLIT ls_data AT ';' INTO
        ls_film-url
        ls_film-adresse
        ls_film-namefood
        ls_film-online_order
        ls_film-book_table
        ls_film-rate
        ls_film-votes
        ls_film-location
        ls_film-rest_type
        ls_film-dish_liked
        ls_film-cuisines
        ls_film-approx_cost_for_two_people
        ls_film-reviews_list
        ls_film-menu_item
        ls_film-listed_in_type
        ls_film-listed_in_city.
          APPEND ls_film TO lt_film.
*          food

*         911
*      SPLIT ls_data AT ';' INTO ls_film-latitude ls_film-longitude ls_film-description_of_emergency ls_film-zip ls_film-title_of_emergency ls_film-data_and_time_of_the_call ls_film-township ls_film-general_adress ls_film-info01 ls_film-info02
*         ls_film-info03 ls_film-info04 ls_film-info05.
*          APPEND ls_film TO lt_film.
*          911

*   sale rec
*
*      DATA temp_unit_price TYPE string.
*      DATA temp_unit_cost TYPE string.
*      DATA temp_total_revenue TYPE string.
*      DATA temp_total_cost TYPE string.
*      DATA temp_total_profit TYPE string.
*
*
*      SPLIT ls_data AT ';' INTO ls_film-region
*            ls_film-country
*            ls_film-item_type
*            ls_film-sales_channel
*            ls_film-order_priority
*            ls_film-order_date
*            ls_film-order_id
*            ls_film-ship_date
*            ls_film-units_sold
*            temp_unit_price
*            temp_unit_cost
*            temp_total_revenue
*            temp_total_cost
*            temp_total_profit.
*
*      DATA var_for_dec_unit_price TYPE /ado/sql_salerec-unit_price.
*      TRANSLATE temp_unit_price USING '.'.
*      CONDENSE temp_unit_price NO-GAPS.
*
*      var_for_dec_unit_price = var_for_dec_unit_price + temp_unit_price.
*
*      ls_film-unit_price = var_for_dec_unit_price.
*      CLEAR var_for_dec_unit_price.
*
*
*
*      DATA var_for_dec_unit_cost TYPE /ado/sql_salerec-unit_cost.
*      TRANSLATE temp_unit_cost USING '.'.
*      CONDENSE temp_unit_cost NO-GAPS.
*
*      var_for_dec_unit_cost = var_for_dec_unit_cost + temp_unit_cost.
*
*      ls_film-unit_cost = var_for_dec_unit_cost.
*      CLEAR var_for_dec_unit_cost.
*
*
*      DATA var_for_dec_total_revenue TYPE /ado/sql_salerec-total_revenue.
*      TRANSLATE temp_total_revenue USING '.'.
*      CONDENSE temp_total_revenue NO-GAPS.
*
*      var_for_dec_total_revenue = var_for_dec_total_revenue + temp_total_revenue.
*
*      ls_film-total_revenue = var_for_dec_total_revenue.
*      CLEAR var_for_dec_total_revenue.
*
*
*
*
*
*      DATA var_for_dec_total_cost TYPE /ado/sql_salerec-total_cost.
*      TRANSLATE temp_total_cost USING '.'.
*      CONDENSE temp_total_cost NO-GAPS.
*
*      var_for_dec_total_cost = var_for_dec_total_cost + temp_total_cost.
*
*      ls_film-total_cost = var_for_dec_total_cost.
*      CLEAR var_for_dec_total_cost.
*
*
*
*
*      DATA var_for_dec_total_profit TYPE /ado/sql_salerec-total_profit.
*      TRANSLATE temp_total_profit USING '.'.
*      CONDENSE temp_total_profit NO-GAPS.
*
*      var_for_dec_total_profit = var_for_dec_total_profit + temp_total_profit.
*
*      ls_film-total_profit = var_for_dec_total_profit.
*      CLEAR var_for_dec_total_profit.





*      APPEND ls_film TO lt_film.




*  sale rec


* pollution

*      DATA: tempstate_code  TYPE string,
*            tempcounty_code TYPE string,
*            tempsite_num    TYPE string,
*            tempno2val      TYPE string,
**            tempno2hour     TYPE string,
*            tempno2aqi      TYPE string,
*            tempno3val      TYPE string,
**            tempno3hour     TYPE string,
**            tempno3aqi      TYPE string,
*            tempso2val      TYPE string,
**            tempso2hour     TYPE string,
*            tempso2aqi      TYPE string,
*            tempcoval       TYPE string,
**            tempcohour      TYPE string,
*            tempcoaqi       TYPE string,
*            tempno2mean     TYPE string,
*            tempno3mean     TYPE string,
*            tempso2mean     TYPE string,
*            tempcomean      TYPE string.
*
*      SPLIT ls_data AT ';'
*      INTO
*
*           tempstate_code
*
*           tempcounty_code
*
*           tempsite_num
*           ls_film-address
*           ls_film-state
*           ls_film-county
*           ls_film-city
*           ls_film-date_local
*           ls_film-no2_units
*
*           tempno2mean
*
*           tempno2val
*            ls_film-no2_1st_max_hour
*
*            ls_film-no2_aqi
*
*           ls_film-o3_units
*
*tempno3mean
*
*tempno3val
*            ls_film-o3_1st_max_hour
*
*           ls_film-o3_aqi
*           ls_film-so2_units
*
*tempso2mean
*
*tempso2val
*            ls_film-so2_1st_max_hour
*
*           ls_film-so2_aqi
*           ls_film-co_units
*
*tempcomean
*
*tempcoval
*            ls_film-co_1st_max_hour
*
*
*tempcoaqi.
*
*      "auskommentieren?????
******************************************      ls_film-state_code = tempstate_code.
******************************************      ls_film-county_code = tempcounty_code.
******************************************      ls_film-site_num = tempsite_num.
******************************************      ls_film-no2_mean = tempno2mean.
******************************************      ls_film-no2_1st_max_value = tempno2val.
******************************************      ls_film-o3_mean = tempno3mean.
******************************************      ls_film-o3_1st_max_value = tempno2val.
******************************************      ls_film-so2_mean = tempso2mean.
******************************************      ls_film-so2_1st_max_value = tempso2val.
******************************************      ls_film-co_mean = tempcomean.
******************************************      ls_film-co_1st_max_value = tempcoval.
******************************************      ls_film-co_aqi = tempcoaqi.
*
*
*
*
*
*
*
*      "DATA var_for_dec_maxval_co TYPE p DECIMALS 2.
****************      DATA var_for_dec_maxval_co TYPE /ado/sql_plltion-co_1st_max_value.
****************      TRANSLATE tempcoval USING '.'.
****************      CONDENSE tempcoval NO-GAPS.
****************
****************      var_for_dec_maxval_co = var_for_dec_maxval_co + tempcoval.
****************
****************      ls_film-co_1st_max_value = var_for_dec_maxval_co.
****************      CLEAR var_for_dec_maxval_co.
*
*
*
****************      DATA var_for_dec_maxval_so2 TYPE p DECIMALS 2.
****************      TRANSLATE tempso2val USING '.'.
****************      CONDENSE tempso2val NO-GAPS.
****************
****************      var_for_dec_maxval_so2 = var_for_dec_maxval_so2 + tempso2val.
****************
****************      ls_film-so2_1st_max_value = var_for_dec_maxval_so2.
****************      CLEAR var_for_dec_maxval_so2.
*
*
*      DATA var_for_dec_maxval_o3 TYPE p DECIMALS 2.
*      TRANSLATE tempno3val USING '.'.
*      CONDENSE tempno3val NO-GAPS.
*
*      var_for_dec_maxval_o3 = var_for_dec_maxval_o3 + tempno3val.
*
*      ls_film-o3_1st_max_value = var_for_dec_maxval_o3.
*      CLEAR var_for_dec_maxval_o3.
*
*
*      DATA var_for_dec_maxval_no2 TYPE p DECIMALS 2.
*      TRANSLATE tempno2val USING '.'.
*      CONDENSE tempno2val NO-GAPS.
*
*      var_for_dec_maxval_no2 = var_for_dec_maxval_no2 + tempno2val.
*
*      ls_film-no2_1st_max_value = var_for_dec_maxval_no2.
*      CLEAR var_for_dec_maxval_no2.
*
*
*      DATA var_for_dec_co_aqi TYPE p DECIMALS 2.
*      IF tempcoaqi = ';' .
*          tempcoaqi = ''.
*      ENDIF.
*      TRANSLATE tempcoaqi USING '.'.
*      CONDENSE tempcoaqi NO-GAPS.
*
*      var_for_dec_co_aqi = var_for_dec_co_aqi + tempcoaqi.
*
*      ls_film-co_aqi = var_for_dec_co_aqi.
*      CLEAR var_for_dec_co_aqi.
*
*
*      DATA nummaxvalueco TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempcoval WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempcoval
*        IMPORTING
*          numcstr = nummaxvalueco.
*
*      ls_film-co_1st_max_value = nummaxvalueco.
*
*
*        DATA nummaxvalueso2 TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempso2val WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempso2val
*        IMPORTING
*          numcstr = nummaxvalueso2.
*
*      ls_film-so2_1st_max_value = nummaxvalueso2.
*
*
*
*
*
*      DATA numvalueno2mean TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempno2mean WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempno2mean
*        IMPORTING
*          numcstr = numvalueno2mean.
*
*      ls_film-no2_mean = numvalueno2mean.
*
*
*
*      DATA numvalueo3mean TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempno3mean WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempno3mean
*        IMPORTING
*          numcstr = numvalueo3mean.
*
*      ls_film-o3_mean = numvalueo3mean.
*
*
*      DATA numvalueso2mean TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempso2mean WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempso2mean
*        IMPORTING
*          numcstr = numvalueso2mean.
*
*      ls_film-so2_mean = numvalueso2mean.
*
*
*      DATA numvaluecomean TYPE i.
*      REPLACE ALL OCCURRENCES OF '.' IN tempcomean WITH ''.
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempcomean
*        IMPORTING
*          numcstr = numvaluecomean.
*
*      ls_film-co_mean = numvaluecomean.
*
*
*      DATA numvalue_state_code TYPE i.
*
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempstate_code
*        IMPORTING
*          numcstr = numvalue_state_code.
*
*      ls_film-state_code = numvalue_state_code.
*
*
*      DATA numvalue_county_code TYPE i.
*
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempcounty_code
*        IMPORTING
*          numcstr = numvalue_county_code.
*
*      ls_film-county_code = numvalue_county_code.
*
*
*      DATA numvalue_site_num TYPE i.
*
*      CALL FUNCTION 'CHAR_NUMC_CONVERSION'
*        EXPORTING
*          input   = tempsite_num
*        IMPORTING
*          numcstr = numvalue_site_num.
*
*      ls_film-site_num = numvalue_site_num.
*
*
*
*
*      APPEND ls_film TO lt_film.
*
*      counter = counter + 1.

* pollution
 counter = counter + 1.
 Data perc TYPE i.
 perc = 100 / 65406 * counter.
CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
 EXPORTING
   PERCENTAGE       = perc
   TEXT             = 'Fortschritt: ' && perc && '%'
          .


    ENDLOOP.
    WRITE ''.

    "INSERT /ado/sql_food FROM TABLE lt_film.
    WRITE ''.



******************************************* zu viele SQL zugriffe + duplicate werden nicht abgefangen (sy-subrc = 4)!
******************************************* -> "insert from table" und vorher die tabelle mit select lesen!
******************************************  DATA(lt_table) = VALUE /ado/sql_datacat(
******************************************    FOR <>
******************************************  )
*****************************************    DATA(ls_datacat) = VALUE ztc_minor(  ).
*****************************************    LOOP AT lt_csv_records ASSIGNING FIELD-SYMBOL(<row>).
*****************************************
*****************************************      AT FIRST.
*****************************************        TRANSLATE <row> TO UPPER CASE.
*****************************************        SPLIT <row> AT seperator INTO TABLE DATA(lt_header).
*****************************************        CONTINUE.
*****************************************      ENDAT.
*****************************************
*****************************************      SPLIT <row> AT seperator INTO TABLE DATA(lt_columns).
*****************************************      LOOP AT lt_columns ASSIGNING FIELD-SYMBOL(<example>) WHERE NOT table_line CO ' '.
*****************************************
******************************************      ls_datacat-fieldname = lt_header[ sy-tabix ].
******************************************      ls_datacat-exampledata = <example>.
*****************************************      ENDLOOP.
*****************************************    ENDLOOP.
*****************************************
*****************************************   " INSERT /ADO/SQL_FILM FROM TABLE lt_columns.



*    SET PARAMETER ID 'DTB' FIELD '/ADO/SQL_DATACAT'.
*    CALL TRANSACTION 'SE16N'.


  ENDMETHOD.


  METHOD join_database.

    TYPES: BEGIN OF ty_data.
             INCLUDE TYPE /ado/sql_salerec.
             INCLUDE TYPE /ado/sql_plltion.
             INCLUDE TYPE /ado/sql_medical.
             INCLUDE TYPE /ado/sql_911.
             INCLUDE TYPE /ado/sql_film.
             INCLUDE TYPE /ado/sql_food.
           TYPES: END OF ty_data.

    DATA: it_status TYPE STANDARD TABLE OF ty_data WITH DEFAULT KEY.

    DATA ls_status TYPE ty_data.
    DATA ls_salerec TYPE /ado/sql_salerec.
    DATA ls_plltion TYPE /ado/sql_plltion.
    DATA ls_medical TYPE /ado/sql_medical.
    DATA ls_911 TYPE /ado/sql_911.
    DATA ls_film TYPE /ado/sql_film.
    DATA ls_food TYPE /ado/sql_food.



    SELECT * FROM /ado/sql_salerec INTO TABLE @DATA(lt_salerec).
    SELECT * FROM /ado/sql_plltion INTO TABLE @DATA(lt_plltion).
    SELECT * FROM /ado/sql_medical INTO TABLE @DATA(lt_medical).
    SELECT * FROM /ado/sql_911 INTO TABLE @DATA(lt_911).
    SELECT * FROM /ado/sql_film INTO TABLE @DATA(lt_film).
    SELECT * FROM /ado/sql_food INTO TABLE @DATA(lt_food).


    DATA: lv_salerec TYPE i,
          lv_plltion TYPE i,
          lv_medical TYPE i,
          lv_911     TYPE i,
          lv_film    TYPE i,
          lv_food    TYPE i.


    DO 300000 TIMES.

      lv_salerec = sy-index MOD lines( lt_salerec ).
      lv_plltion = sy-index MOD lines( lt_plltion ).
      lv_medical = sy-index MOD lines( lt_medical ).
      lv_911 = sy-index MOD lines( lt_911 ).
      lv_film = sy-index MOD lines( lt_film ).
      lv_food = sy-index MOD lines( lt_food ).



      MOVE-CORRESPONDING lt_salerec[ 700000 + sy-index ] TO ls_status.
      MOVE-CORRESPONDING lt_plltion[ 700000 + sy-index ] TO ls_status.
      MOVE-CORRESPONDING lt_medical[ 700000 + sy-index ] TO ls_status.
      MOVE-CORRESPONDING lt_911[ 700000 + sy-index ] TO ls_status.
      MOVE-CORRESPONDING lt_film[ 700000 + sy-index ] TO ls_status.
      MOVE-CORRESPONDING lt_food[ 700000 + sy-index ] TO ls_status.

      APPEND ls_status TO it_status.


      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDDO.
    WRITE ''.
    "insert /ado/sql_all FROM TABLE it_status.
    WRITE ''.

















  ENDMETHOD.
ENDCLASS.
