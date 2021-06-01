************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
REPORT zha_test_smo.

TABLES zha_smo_tab.

PARAMETERS p_select  RADIOBUTTON GROUP mod.
PARAMETERS p_upddb   RADIOBUTTON GROUP mod.
PARAMETERS p_free    RADIOBUTTON GROUP mod.
PARAMETERS p_inser1  RADIOBUTTON GROUP mod.
PARAMETERS p_inser2  RADIOBUTTON GROUP mod.

PARAMETERS p_id     TYPE zha_smo_tab-id.
PARAMETERS p_info   TYPE zha_smo_tab-info.




DATA lo_smo_area TYPE REF TO zha_cl_smo_area.
DATA lo_smo_root TYPE REF TO zha_cl_smo_root.
DATA lx_exception TYPE REF TO cx_root.

IF p_select EQ 'X'.
  TRY.
      TRY.
          lo_smo_area = zha_cl_smo_area=>attach_for_read( ).
        CATCH cx_shm_error INTO  lx_exception.
          WAIT UP TO 2 SECONDS.
          lo_smo_area = zha_cl_smo_area=>attach_for_read( ).
      ENDTRY.
      IF lo_smo_area IS NOT INITIAL.
        DATA(lv_lines) = lines( lo_smo_area->root->mt_info_tab ).
        WRITE:  / 'table rows ', lv_lines.
        LOOP AT lo_smo_area->root->mt_info_tab INTO DATA(ls_info_tab).
          WRITE:  / ls_info_tab-id, (50) ls_info_tab-info.
        ENDLOOP.
        "-----------------datenobj
        IF lo_smo_area->root->mo_obj IS INITIAL.
          WRITE: /(5)'obj:', 'null'.
        ELSE.
          CASE  TYPE OF lo_smo_area->root->mo_obj.
            WHEN TYPE  zha_cl_smo_data.
              DATA(lo_smo_data) = CAST zha_cl_smo_data( lo_smo_area->root->mo_obj ).
              WRITE: /'obj(zha_cl_smo_data):',  (6) 'num = ', (4) lo_smo_data->num, (6) 'str = ', lo_smo_data->str.
            WHEN TYPE  zha_cl_smo_data2.
              DATA(lo_smo_data2) = CAST zha_cl_smo_data2( lo_smo_area->root->mo_obj ).
              WRITE: /'obj(zha_cl_smo_data2):',  lo_smo_data2->to_string( ).
          ENDCASE.
        ENDIF.
      ENDIF.
      lo_smo_area->detach( ).
    CATCH cx_shm_error INTO  lx_exception.
      DATA(lv_text) = lx_exception->get_text( ).
      "RAISE EXCEPTION TYPE cx_shm_build_failed EXPORTING previous = lx_exception.
      WRITE : / 'exception', lv_text.
  ENDTRY.

ELSEIF p_inser1 EQ 'X'  or  p_inser2 EQ 'X'.
  CHECK p_id IS NOT INITIAL.
  TRY.
      lo_smo_area = zha_cl_smo_area=>attach_for_update(
*                  inst_name   = cl_shm_area=>default_instance
*                  attach_mode = cl_shm_area=>attach_mode_default
*                  wait_time   = 0
                    ).
      DATA(ls_smo_tab) = VALUE zha_smo_tab( id = p_id  info = p_info ).
      lo_smo_area->root->insert_smo_tab_entry( is_smo_tab = ls_smo_tab ).

      " dataenobj
      if p_inser1 eq  abap_true.
          DATA lo_obj TYPE REF TO zha_cl_smo_data.
          CREATE OBJECT lo_obj AREA HANDLE lo_smo_area.
          lo_smo_area->root->mo_obj = lo_obj.
          lo_obj->num = p_id.
          lo_obj->str = p_info.
      elseif p_inser2 eq  abap_true.
          DATA lo_obj2 TYPE REF TO zha_cl_smo_data2.
          CREATE OBJECT lo_obj2 AREA HANDLE lo_smo_area.
          lo_smo_area->root->mo_obj = lo_obj2.
          lo_obj2->mv_blubber = p_info.
          data ls_data type sflight.
          " geht nicht da reference nicht shared memory
          "lo_obj2->mo_struct  ?= cl_abap_structdescr=>describe_by_data( ls_data ).
      endif.

      lo_smo_area->detach_commit( ).
      COMMIT WORK.
      IF sy-subrc EQ 0.
        WRITE / 'modify ok'.
      ELSE.
        WRITE / 'error at commit'.
      ENDIF.

    CATCH cx_shm_error INTO  lx_exception.
      lv_text = lx_exception->get_text( ).
      "RAISE EXCEPTION TYPE cx_shm_build_failed EXPORTING previous = lx_exception.
      WRITE : / 'exception', lv_text.
  ENDTRY.

ELSEIF p_upddb EQ 'X'.
  TRY.
      lo_smo_area = zha_cl_smo_area=>attach_for_update(
*                  inst_name   = cl_shm_area=>default_instance
*                  attach_mode = cl_shm_area=>attach_mode_default
*                  wait_time   = 0
                    ).
      lo_smo_area->root->write_to_database( ).

      lo_smo_area->detach_commit( ).
      COMMIT WORK.
      IF sy-subrc EQ 0.
        WRITE / 'write to database  ok'.
      ELSE.
        WRITE / 'error at write to database '.
      ENDIF.

    CATCH cx_shm_error INTO  lx_exception.
      lv_text = lx_exception->get_text( ).
      "RAISE EXCEPTION TYPE cx_shm_build_failed EXPORTING previous = lx_exception.
      WRITE : / 'exception', lv_text.
  ENDTRY.

ELSEIF p_free EQ 'X'.
  DATA lv_area_name TYPE shm_inst_name VALUE '$DEFAULT_INSTANCE$'.
  TRY.
      DATA(lv_rc) = zha_cl_smo_area=>free_instance(
*      EXPORTING
*        inst_name         = cl_shm_area=>default_instance " Name einer Shared Object Instanz eines Areas
*        terminate_changer = abap_true                     " Schreiber werden beendet
*      RECEIVING
*        rc                =                               " Rückgabewert (Konstanten in CL_SHM_AREA)
      ).
      WRITE: / 'The memory object has been deleted'.
    CATCH cx_shm_parameter_error INTO lx_exception. " Falscher Parameter übergeben
      lv_text = lx_exception->get_text( ).
      WRITE : / 'exception', lv_text.
  ENDTRY.

ENDIF.
