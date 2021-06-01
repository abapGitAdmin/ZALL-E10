class /ADESSO/CL_HMV_CUSTOMIZING definition
  public
  create public .

public section.

  types:
    BEGIN OF t_constant,
        konstante TYPE /idxgc/de_constant,
        attvalue  TYPE seovalue,
      END OF t_constant .
  types:
    BEGIN OF ty_ab_bis,
        sign(1)   TYPE c,
        option(2) TYPE c,
        low       TYPE datefrom,
        high      TYPE dateto,
      END OF ty_ab_bis .

  data:
    it_const TYPE TABLE OF t_constant .
  data IS_CONST type T_CONSTANT .

*      IMPORTING
*        !iv_so_date         TYPE it_segmentdat OPTIONAL
  class-methods GET_IDOC_STATUS
    importing
      !IS_SO_DATUM type TY_AB_BIS
    exporting
      value(ET_STAT) type /ADESSO/HMV_RT_STAT
      value(ET_SART) type /ADESSO/HMV_T_SART .
*      IMPORTING
*        !iv_so_datum        TYPE it_sydatum OPTIONAL
  class-methods GET_DEXPROC_INVOUT
    importing
      !IS_SO_DATUM type TY_AB_BIS
    returning
      value(RT_CUST_XPRO) type /ADESSO/HMV_RT_XPRO .
*      IMPORTING
*        !ls_date            TYPE it_segmentdat OPTIONAL
  class-methods GET_MESSAGE_TYPE
    importing
      !IS_SO_DATUM type TY_AB_BIS
    returning
      value(RT_CUST_MSGT) type /ADESSO/HMV_RT_MSGT .
*      IMPORTING
*        !iv_so_datum         TYPE it_segmentdat OPTIONAL
  class-methods GET_EDI_SEGMENT
    importing
      !IS_SO_DATUM type TY_AB_BIS
    returning
      value(LS_EDISEG) type /ADESSO/HMV_SEGN .
  methods GET_CONSTANTS
    importing
      value(IV_CONS) type /IDXGC/DE_CONSTANT
    returning
      value(RV_ATTR) type SEOVALUE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_HMV_CUSTOMIZING IMPLEMENTATION.


  METHOD get_constants.

    DATA: lv_const LIKE iv_cons,
          rs_const LIKE LINE OF it_const.

    SELECT konstante attvalue FROM /adesso/hmv_cons INTO TABLE it_const.
    IF sy-subrc = 0.
      CLEAR rv_attr.
      READ TABLE it_const INTO is_const WITH KEY konstante = iv_cons.
      MOVE is_const-attvalue TO rv_attr.
    ENDIF.
  ENDMETHOD.


  METHOD get_dexproc_invout.
* Selektiert alle gültigen Basisprozesse


    DATA: ls_xproc     TYPE /adesso/hmv_xpro,
          lt_xproc     TYPE /adesso/hmv_rt_xpro,
          rs_cust_xpro TYPE /adesso/hmv_rs_xpro.


    IF rt_cust_xpro IS INITIAL.
      SELECT * FROM /adesso/hmv_xpro INTO ls_xproc
        WHERE datefrom < is_so_datum-high
          AND dateto   > is_so_datum-low.

        CLEAR rs_cust_xpro.
        rs_cust_xpro-sign   = 'I'.
        rs_cust_xpro-option = 'EQ'.
        rs_cust_xpro-low    = ls_xproc-dexbasicproc.
        APPEND rs_cust_xpro TO rt_cust_xpro.
      ENDSELECT.
    ENDIF.
  ENDMETHOD.


  METHOD get_edi_segment.



*    DATA: ls_ediseg    TYPE /adesso/hmv_segn,
     DATA:     rs_cust_segn TYPE /adesso/hmv_rs_segn.

    SELECT * FROM /adesso/hmv_segn INTO CORRESPONDING FIELDS OF ls_ediseg
            WHERE datefrom < is_so_datum-high AND dateto > is_so_datum-low.

*      CLEAR rs_cust_segn.
*      rs_cust_segn-sign   = 'I'.
*      rs_cust_segn-option = 'EQ'.
*      rs_cust_segn-low    = ls_ediseg-segnam.
*      APPEND rs_cust_segn TO rt_cust_segn.
    ENDSELECT.
  ENDMETHOD.


  METHOD get_idoc_status.
* <ET 20160201>
* Abfrage der gültigen Versandarten mit dem entsprechenden
* IDoc-Status (01, 03, 14)


    DATA:
      lt_sart     TYPE TABLE OF /adesso/hmv_sart,
      ls_sart     TYPE          /adesso/hmv_sart,
      ls_rng_stat TYPE          /adesso/hmv_rs_stat.

      SELECT * FROM /adesso/hmv_sart
        INTO TABLE et_sart
        WHERE datab < is_so_datum-high
          AND datbi > is_so_datum-low.

      LOOP AT et_sart INTO ls_sart.
        CLEAR ls_rng_stat.
        ls_rng_stat-sign   = 'I'.
        ls_rng_stat-option = 'EQ'.
        ls_rng_stat-low    = ls_sart-status.
        APPEND ls_rng_stat TO et_stat.
      ENDLOOP.
  ENDMETHOD.


  METHOD get_message_type.

* Nachrichtentypen

    DATA: ls_msgt TYPE /adesso/hmv_msgt,
          rs_cust_msgt TYPE /adesso/hmv_rs_msgt.

    IF rt_cust_msgt IS INITIAL.
      SELECT * FROM /adesso/hmv_msgt
       INTO CORRESPONDING FIELDS OF ls_msgt
        WHERE datab < is_so_datum-high
          AND datbi > is_so_datum-low.

        rs_cust_msgt-sign   = 'I'.
        rs_cust_msgt-option = 'EQ'.
        rs_cust_msgt-low    = ls_msgt-msgtyp.
        APPEND rs_cust_msgt to rt_cust_msgt.
      ENDSELECT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
