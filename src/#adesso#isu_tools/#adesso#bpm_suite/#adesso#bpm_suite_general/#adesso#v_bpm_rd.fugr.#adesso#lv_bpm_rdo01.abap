*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LV_BPM_RDO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_DP_CLASS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_dp_class OUTPUT.
  DATA: ls_gen_cust TYPE /adesso/bpm_gen.

  TRY.
      ls_gen_cust = /adesso/cl_bpm_utility=>det_gen_cust( iv_bparea = /adesso/v_bpm_rd-bparea ).
    CATCH /adesso/cx_bpm_utility.
  ENDTRY.

  CALL FUNCTION '/ADESSO/FM_SET_DP_CLASS_NAME'
    EXPORTING
      iv_dp_class = ls_gen_cust-ad_bpm_dp_cl_rul.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHK_DP_METHOD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE chk_dp_method INPUT.
  DATA: lr_dp_class TYPE REF TO cl_oo_class,
        lt_methods  TYPE seo_methods.

  TRY.
      ls_gen_cust = /adesso/cl_bpm_utility=>det_gen_cust( iv_bparea = /adesso/v_bpm_rd-bparea ).
    CATCH /adesso/cx_bpm_utility.
      MESSAGE e003(/adesso/bpm_utility) WITH ls_gen_cust-ad_bpm_dp_cl_rul.
  ENDTRY.

  TRY.
      CREATE OBJECT lr_dp_class
        EXPORTING
          clsname                   = ls_gen_cust-ad_bpm_dp_cl_rul
          with_inherited_components = abap_true
          with_interface_components = abap_true.

      lt_methods = lr_dp_class->get_methods( ).

      READ TABLE lt_methods TRANSPORTING NO FIELDS WITH KEY cmpname = /adesso/v_bpm_rd-dp_method.
      IF sy-subrc <> 0.
        MESSAGE e003(/adesso/bpm_utility) WITH ls_gen_cust-ad_bpm_dp_cl_rul.
      ELSE.
        RETURN.
      ENDIF.

    CATCH cx_class_not_existent .
  ENDTRY.

ENDMODULE.
