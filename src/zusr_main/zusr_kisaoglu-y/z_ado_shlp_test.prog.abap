************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT z_ado_shlp_test.


DATA: shlp_tab    TYPE shlp_desct,
      record_tab  LIKE TABLE OF seahlpres,
      shlp        TYPE  shlp_descr,
      callcontrol LIKE  ddshf4ctrl.

CALL FUNCTION 'FUNCTION_EXISTS'
  EXPORTING
    funcname           = 'KRED_F4IF_SHLP_EXIT'
  EXCEPTIONS
    function_not_exist = 1
    OTHERS             = 2.
IF sy-subrc = 0.
  CALL FUNCTION 'KRED_F4IF_SHLP_EXIT'
    TABLES
      shlp_tab    = shlp_tab
      record_tab  = record_tab
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol ##EXISTS.
ENDIF.
