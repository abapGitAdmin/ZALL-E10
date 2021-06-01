class ZCX_ISU_GENERAL definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  data SOURCE type /IDXGC/S_EXCP_SOURCE .
  data EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE .
  data TIMESTAMP type /IDXGC/DE_TIMESTAMP .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !SOURCE type /IDXGC/S_EXCP_SOURCE optional
      !EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE optional
      !TIMESTAMP type /IDXGC/DE_TIMESTAMP optional
      !GV_MTEXT type STRING optional .
  class-methods RAISE_EXCEPTION_FROM_MSG
    importing
      !IR_PREVIOUS type ref to CX_ROOT optional
      !IV_MSGID type SYMSGID default SY-MSGID
      !IV_MSGNO type SYMSGNO default SY-MSGNO
      !IV_MSGV1 type SYMSGV default SY-MSGV1
      !IV_MSGV2 type SYMSGV default SY-MSGV2
      !IV_MSGV3 type SYMSGV default SY-MSGV3
      !IV_MSGV4 type SYMSGV default SY-MSGV4
      !IS_TEXTID type SCX_T100KEY optional
      !IV_EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE default /IDXGC/IF_CONSTANTS=>GC_EXCEPTION_TECHNICAL_ERROR
    raising
      /ADESSO/CX_ISU_GENERAL .
protected section.

  class-data GV_MTEXT type STRING .
private section.
ENDCLASS.



CLASS ZCX_ISU_GENERAL IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->SOURCE = SOURCE .
me->EXCEPTION_CODE = EXCEPTION_CODE .
me->TIMESTAMP = TIMESTAMP .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD RAISE_EXCEPTION_FROM_MSG.
***************************************************************************************************
* THIMEL-R, 20150726, SDÄ auf Common Layer Engine
*    Generelle Ausnahmeklasse auf Basis /IDXGC/CX_GENERAL
***************************************************************************************************
    DATA:
      lv_timestamp TYPE /idxgc/de_timestamp,
      ls_textid    TYPE scx_t100key,
      ls_source    TYPE /idxgc/s_excp_source.

    IF is_textid IS INITIAL.
      ls_textid-msgid = iv_msgid.
      ls_textid-msgno = iv_msgno.
    ELSE.
      ls_textid = is_textid.
    ENDIF.

    IF ls_textid-attr1 IS INITIAL.
      ls_textid-attr1 = iv_msgv1.
      ls_textid-attr2 = iv_msgv2.
      ls_textid-attr3 = iv_msgv3.
      ls_textid-attr4 = iv_msgv4.
    ENDIF.

    CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
      EXPORTING
        iv_ignore_levels = 1
      IMPORTING
        ev_class_name    = ls_source-class_name
        ev_method_name   = ls_source-method_name.

    lv_timestamp = /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_timestamp( ).

    RAISE EXCEPTION TYPE /adesso/cx_isu_general
      EXPORTING
        previous       = ir_previous
        textid         = ls_textid
        source         = ls_source
        exception_code = iv_exception_code
        timestamp      = lv_timestamp.

  ENDMETHOD.
ENDCLASS.
