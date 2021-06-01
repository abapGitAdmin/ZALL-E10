CLASS /adz/cl_hmv_constants DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      get_constants
        importing
           iv_repid  type repid OPTIONAL
           iv_slset  type SYST_SLSET OPTIONAL
        RETURNING VALUE(rs_constants) TYPE /adz/hmv_s_constants.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA :
      mv_read      TYPE abap_bool VALUE abap_false,
      ms_constants TYPE /adz/hmv_s_constants.
    CLASS-METHODS :
      assign_constants.

ENDCLASS.


CLASS /adz/cl_hmv_constants IMPLEMENTATION.
  METHOD get_constants.
    IF mv_read NE abap_true.
      assign_constants( ).
    ENDIF.
    if iv_repid is not INITIAL.
      ms_constants-repid = iv_repid.
    endif.
    if iv_slset is not INITIAL.
      ms_constants-slset = iv_slset.
    endif.

    rs_constants = ms_constants.

  ENDMETHOD.

  METHOD assign_constants.
    DATA lt_hmv_cons TYPE HASHED TABLE OF /adz/hmv_cons WITH UNIQUE KEY konstante.

    CLEAR ms_constants.
    mv_read = abap_true.
    " Konstanten Tabelle lesen
    SELECT *  FROM /adz/hmv_cons  INTO TABLE lt_hmv_cons.

    " Mahnsperrgrund
    TRY.
        ms_constants-c_lockr   = lt_hmv_cons[ konstante = 'C_LOCKR' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Mahnsperren
    TRY.
        ms_constants-c_mansp   = lt_hmv_cons[ konstante = 'C_MANSP' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Mahnverfahren
    TRY.
        ms_constants-c_mahnv   = lt_hmv_cons[ konstante = 'C_MAHNV' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_FAEDN_FROM   = lt_hmv_cons[ konstante = 'C_FAEDN_FROM' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_FAEDN_TO   = lt_hmv_cons[ konstante = 'C_FAEDN_TO' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_DOC_KZD   = lt_hmv_cons[ konstante = 'C_DOC_KZD' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_DOC_KZM   = lt_hmv_cons[ konstante = 'C_DOC_KZM' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_DOC_KZMSB   = lt_hmv_cons[ konstante = 'C_DOC_KZMSB' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_PROID   = lt_hmv_cons[ konstante = 'C_PROID' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_PRTIO   = lt_hmv_cons[ konstante = 'C_PRTIO' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_MAXTB   = lt_hmv_cons[ konstante = 'C_MAXTB' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_MAXTD   = lt_hmv_cons[ konstante = 'C_MAXTD' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_LISTHEADER_TYP   = lt_hmv_cons[ konstante = 'C_LISTHEADER_TYP' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-G_USER_COMMAND   = lt_hmv_cons[ konstante = 'G_USER_COMMAND' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-G_STATUS   = lt_hmv_cons[ konstante = 'G_STATUS' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_LOTYP_GP_VK   = lt_hmv_cons[ konstante = 'C_LOTYP_GP_VK' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_PROID_DUNN   = lt_hmv_cons[ konstante = 'C_PROID_DUNN' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_LOCKAKTYP   = lt_hmv_cons[ konstante = 'C_LOCKAKTYP' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_LOTYP   = lt_hmv_cons[ konstante = 'C_LOTYP' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_INVOICE_PAYMST   = lt_hmv_cons[ konstante = 'C_INVOICE_PAYMST' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-C_INVOICE_PAYM   = lt_hmv_cons[ konstante = 'C_INVOICE_PAYM' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoic Status 03
    TRY.
        ms_constants-C_INVOICE_STATUS_03   = lt_hmv_cons[ konstante = 'C_INVOICE_STATUS_03' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
    " Invoic Status 04
    TRY.
        ms_constants-C_INVOICE_STATUS_04   = lt_hmv_cons[ konstante = 'C_INVOICE_STATUS_04' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoice Type 2
    TRY.
        ms_constants-C_INVOICE_TYPE2   = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE2' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

   " Invoice Type 4
    TRY.
        ms_constants-C_INVOICE_TYPE4   = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE4' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoice Type 7
    TRY.
        ms_constants-C_INVOICE_TYPE7   = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE7' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoice Type 8
    TRY.
        ms_constants-C_INVOICE_TYPE8   = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE8' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoice Type 12
    TRY.
        ms_constants-C_INVOICE_TYPE12   = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE12' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Invoice Type 13
    TRY.
        ms_constants-C_INVOICE_TYPE13  = lt_hmv_cons[ konstante = 'C_INVOICE_TYPE13' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    " Status für MeMi-Beleg-Mahnsperre
    TRY.
        ms_constants-C_MEMIDOC_DNLCRSN   = lt_hmv_cons[ konstante = 'C_MEMIDOC_DNLCRSN' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

   " HMV2 - Mahnprozess nach MMMA SP03 aktiv?
    TRY.
        ms_constants-C_IDXMM_SP03_DUNN   = lt_hmv_cons[ konstante = 'C_IDXMM_SP03_DUNN' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-c_mahnen   = lt_hmv_cons[ konstante = 'C_AVIS_MAHN' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-c_mahnen_memi   = lt_hmv_cons[ konstante = 'C_AVIS_MAHN_MEMI' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-c_mahnen_msb   = lt_hmv_cons[ konstante = 'C_AVIS_MAHN_MSB' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

    TRY.
        ms_constants-c_max_selcond_tasks  = lt_hmv_cons[ konstante = 'MAX_SELCOND_PER_TASK' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
        ms_constants-c_max_selcond_tasks = 5000.
    ENDTRY.

    TRY.
        ms_constants-c_min_selcond_tasks   = lt_hmv_cons[ konstante = 'MIN_SELCOND_PER_TASK' ]-attvalue.
      CATCH cx_sy_itab_line_not_found.
      ms_constants-c_min_selcond_tasks = 2000.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
