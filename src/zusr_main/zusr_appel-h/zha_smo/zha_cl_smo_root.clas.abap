CLASS zha_cl_smo_root DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    INTERFACES if_shm_build_instance .

    DATA:
      mt_info_tab  TYPE TABLE OF zha_smo_tab,
      mo_obj       type ref to object.

    METHODS set_info_tab .
    METHODS  insert_smo_tab_entry
      IMPORTING is_smo_tab TYPE zha_smo_tab.
    METHODS  write_to_database.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zha_cl_smo_root IMPLEMENTATION.


  METHOD if_shm_build_instance~build.
    "INST_NAME type SHM_INST_NAME
    DATA lo_smo_area TYPE REF TO zha_cl_smo_area.
    DATA lo_smo_root TYPE REF TO zha_cl_smo_root.
    DATA lx_exception TYPE REF TO cx_root.


    TRY.
        lo_smo_area = zha_cl_smo_area=>attach_for_write( ).
        CREATE OBJECT lo_smo_root AREA HANDLE lo_smo_area.
        lo_smo_area->set_root( lo_smo_root ).

        lo_smo_root->set_info_tab( ).

        lo_smo_area->detach_commit( ).

      CATCH cx_shm_error INTO  lx_exception.
        RAISE EXCEPTION TYPE cx_shm_build_failed EXPORTING previous = lx_exception.
    ENDTRY.

    IF invocation_mode = cl_shm_area=>invocation_mode_auto_build.
      CALL FUNCTION 'DB_COMMIT'.
    ENDIF.
  ENDMETHOD.


  METHOD set_info_tab.
    CLEAR mt_info_tab.
    SELECT * FROM zha_smo_tab INTO TABLE mt_info_tab.
  ENDMETHOD.

  METHOD insert_smo_tab_entry.
    TRY.
        ASSIGN mt_info_tab[ id = is_smo_tab-id ] TO FIELD-SYMBOL(<ls_info_tab>).
        IF sy-subrc EQ 0.
          <ls_info_tab>-info = is_smo_tab-info.
        ELSE.
          INSERT is_smo_tab INTO TABLE mt_info_tab.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    "set_info_tab( ).
  ENDMETHOD.

  METHOD write_to_database.
    MODIFY zha_smo_tab FROM TABLE mt_info_tab.
    DATA lt_rng_id TYPE RANGE OF zha_smo_tab-id.
    lt_rng_id = VALUE #( FOR ls IN mt_info_tab ( sign = 'I'  option = 'EQ'  low = ls-id ) ).
    "DELETE FROM zha_smo_tab WHERE NOT id IN lt_rng_id.
    "modify zha_smo_tab from table mt_info_tab.
    delete from zha_smo_tab.
    insert zha_smo_tab from table mt_info_tab.
    commit work.
    "set_info_tab( ).
  ENDMETHOD.





ENDCLASS.
