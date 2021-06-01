FUNCTION /ADESSO/ENET_UPLOAD.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(FILES) TYPE  /ADESSO/ENET_IMPORT_STRINGTAB
*"     VALUE(FILENAME) TYPE  LOCALFILE
*"--------------------------------------------------------------------



  DATA:
    ls_component   TYPE abap_componentdescr,
    lt_component   TYPE abap_component_tab,
    lr_strucdescr  TYPE REF TO cl_abap_structdescr,
    lr_data_struct TYPE REF TO data.

  DATA:
    ls_component2  TYPE abap_componentdescr,
    lt_component2  TYPE abap_component_tab,
    lr_strucdescr2 TYPE REF TO cl_abap_structdescr,
    lr_data_table2 TYPE REF TO data,
    uv_filename    TYPE localfile,
    lr_tabledescr2 TYPE REF TO cl_abap_tabledescr,
    lr_row_enet    TYPE REF TO data.

  DATA: lt_felder TYPE TABLE OF string,
        lv_type   TYPE c.

  DATA lv_tabelle TYPE string.
  DATA ut_daten_aus_datei TYPE /ADESSO/ENET_IMPORT_STRINGTAB.
  DATA lv_dats TYPE LINE OF /ADESSO/ENET_IMPORT_STRINGTAB.
  DATA lv_string TYPE string.
  DATA lv_string_temp TYPE string.
  ut_daten_aus_datei = files.
  uv_filename = filename.
  TRANSLATE uv_filename TO UPPER CASE.
  SELECT SINGLE tabelle FROM /adesso/ec_enet INTO lv_tabelle WHERE datei = uv_filename+21.
  IF sy-subrc = 0.


    FIELD-SYMBOLS: <fs>, <tab> , <enet_tab> TYPE STANDARD TABLE, <enet_line>,  <line>, <enet_work> , <mandt>, <a>.
    ls_component-type ?= cl_abap_typedescr=>describe_by_name( lv_tabelle ).
    ls_component-name = 'A'.
    INSERT ls_component INTO TABLE lt_component.
    lr_strucdescr = cl_abap_structdescr=>create( lt_component ).
    CLEAR ls_component.

    CREATE DATA lr_data_struct TYPE HANDLE lr_strucdescr.
    ASSIGN lr_data_struct->* TO <fs>.
    ASSIGN COMPONENT 'A' OF STRUCTURE <fs> TO <tab>.

    LOOP AT ut_daten_aus_datei INTO lv_dats.
      lv_string = lv_dats-inhalt.
      IF sy-tabix = 1.
        REPLACE ALL OCCURRENCES OF 'ß' IN lv_string WITH 'ss'.
        TRANSLATE lv_string TO UPPER CASE.
        DO 1000 TIMES.
          SEARCH lv_string FOR ';'.
          IF sy-subrc = 0.
            lv_string_temp = lv_string(sy-fdpos).
            SHIFT lv_string_temp LEFT DELETING LEADING 'XY'. "Reservierte Sap Felder haben xy vorangestellt
            APPEND lv_string_temp TO lt_felder.
            lv_string = lv_string+sy-fdpos.
            lv_string = lv_string+1.
          ELSE.
            lv_string_temp = lv_string.
            SHIFT lv_string_temp LEFT DELETING LEADING 'XY'. "Reservierte Sap Felder haben xy vorangestellt
            APPEND lv_string_temp TO lt_felder.
            EXIT.
          ENDIF.
        ENDDO.
        LOOP AT lt_felder INTO lv_string.
          CLEAR ls_component2.
          ls_component2-name =  lv_string .
          " lv_string = lv_tabelle && '-' && lv_string.
          TRY .
              IF lv_string = 'FORMAT'. lv_string = 'XYFORMAT'. ENDIF.
              ASSIGN COMPONENT lv_string OF STRUCTURE <tab> TO <fs>.
              IF sy-subrc <> 0.
                lv_string = lv_string.
              ENDIF.
              ls_component2-type ?= cl_abap_typedescr=>describe_by_data( <fs> ).
            CATCH  cx_root.
          ENDTRY.
          INSERT ls_component2 INTO TABLE lt_component2.

        ENDLOOP.
        lr_strucdescr2 = cl_abap_structdescr=>create( lt_component2 ).
        CLEAR ls_component2.
        lv_string = lv_string.
        lr_tabledescr2 = cl_abap_tabledescr=>create( p_line_type = lr_strucdescr2 ).
        CREATE DATA lr_data_table2 TYPE HANDLE lr_tabledescr2.
        ASSIGN lr_data_table2->* TO <enet_tab>.

        CREATE DATA lr_row_enet LIKE LINE OF <enet_tab>.
        ASSIGN lr_row_enet->* TO <enet_line>.
        IF sy-subrc = 0.
          DELETE FROM (lv_tabelle).
        ENDIF.
      ELSE.
        DO 1000 TIMES.

          "  ASSIGN COMPONENT 'A' OF STRUCTURE <enet_line> TO <a>.
          SEARCH lv_string FOR ';'.
          IF sy-subrc = 0.

            lv_string_temp = lv_string(sy-fdpos).

            ASSIGN COMPONENT sy-index OF STRUCTURE <enet_line> TO <enet_work>.
            DESCRIBE FIELD: <enet_work>       TYPE lv_type.
            IF lv_type = 'P' OR  lv_type = 'a' OR lv_type = 'e' OR lv_type = 'F'.
              REPLACE ',' WITH '.' INTO lv_string_temp.
            ELSEIF lv_type = 'D'.
              IF strlen( lv_string_temp ) > 6.
                lv_string_temp = lv_string_temp+6 && lv_string_temp+3(2) && lv_string_temp(2).
              ENDIF.
            ENDIF.
            TRY .
                <enet_work> = lv_string_temp.
              CATCH cx_root.
                WRITE : / lv_tabelle,';', sy-index ,';' ,lv_string_temp.
                EXIT.
            ENDTRY.
            lv_string = lv_string+sy-fdpos.
            lv_string = lv_string+1.
          ELSE.
            lv_string_temp = lv_string.
            ASSIGN COMPONENT sy-index OF STRUCTURE <enet_line> TO <enet_work>.
            DESCRIBE FIELD: <enet_work>       TYPE lv_type.
            IF lv_type = 'P' OR  lv_type = 'a' OR lv_type = 'e' OR lv_type = 'F'.
              REPLACE ',' WITH '.' INTO lv_string_temp.
            ELSEIF lv_type = 'D'.
              IF strlen( lv_string_temp ) > 6.
                lv_string_temp = lv_string_temp+6 && lv_string_temp+3(2) && lv_string_temp(2).
              ENDIF.
            ENDIF.
            TRY .
                <enet_work> = lv_string_temp.
              CATCH cx_root.
                WRITE : / lv_tabelle,';', sy-index, ';' ,lv_string_temp.
                EXIT.
            ENDTRY.

            MOVE-CORRESPONDING <enet_line> TO <tab>.

            ASSIGN COMPONENT 'MANDT' OF STRUCTURE <tab> TO <mandt>.
            <mandt> = sy-mandt.

            INSERT INTO (lv_tabelle) VALUES <tab>.
            COMMIT WORK.
            EXIT.
          ENDIF.

        ENDDO.

      ENDIF.
    ENDLOOP.


*    LOOP AT <enet_tab> INTO <enet_line>.
*
*      MOVE-CORRESPONDING <enet_line> TO <tab>.
*
*      ASSIGN COMPONENT 'MANDT' OF STRUCTURE <tab> TO <mandt>.
*      <mandt> = sy-mandt.
*
*      INSERT INTO (lv_tabelle) VALUES <tab>.
*      COMMIT WORK.
*
*
*    ENDLOOP.


  ENDIF.



ENDFUNCTION.
