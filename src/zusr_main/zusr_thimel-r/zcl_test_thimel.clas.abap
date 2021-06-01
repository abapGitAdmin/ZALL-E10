class ZCL_TEST_THIMEL definition
  public
  inheriting from /IDXGL/CL_BDR_ORDERS_REQ_CNTR
  create public .

public section.

  class-methods TEST_THIMEL .

  methods HANDLE_OK_CODE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_TEST_THIMEL IMPLEMENTATION.


  METHOD handle_ok_code.

        super->handle_ok_code( ).

test_thimel( ).

*    TRY.
    "lv_result = prepare_process_data( is_bdr_orders_req = '' ).
*     CATCH /idxgc/cx_process_error .
*    ENDTRY.

    TRY.

        DATA: gr_obj TYPE REF TO zcl_test_thimel.

         "gr_obj = NEW #( is_bdr_orders_hdr = '' ).

      CATCH /idxgc/cx_process_error .
    ENDTRY.



  ENDMETHOD.


  method TEST_THIMEL.
  endmethod.
ENDCLASS.
