MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.

MODULE output OUTPUT.
  IF gr_custom_cont IS NOT BOUND.
    CREATE OBJECT gr_custom_cont
      EXPORTING
        container_name = 'CCONT'.
  ENDIF.
  gr_mdc_cntr = /adz/cl_mdc_cntr=>get_instance(
      ir_cont      = gr_custom_cont
      is_selection = gs_selection ).
ENDMODULE.

MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN cl_isu_okcode=>co_back.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN /adz/if_mdc_co=>gc_okcode_send.
      gr_mdc_cntr->start_process( ).
  ENDCASE.
ENDMODULE.
