CLASS /adz/cl_hmv_customizing DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF t_constant,
        konstante TYPE /idxgc/de_constant,
        attvalue  TYPE seovalue,
      END OF t_constant .
    TYPES:
      BEGIN OF ty_ab_bis,
        sign(1)   TYPE c,
        option(2) TYPE c,
        low       TYPE datefrom,
        high      TYPE dateto,
      END OF ty_ab_bis .

    DATA:
      it_const TYPE TABLE OF t_constant .
    DATA is_const TYPE t_constant .

    CLASS-METHODS get_hmv_sart
      RETURNING VALUE(rrt_hmv_sart) TYPE REF TO /adz/hmv_t_sart.

    CLASS-METHODS get_idoc_status
      IMPORTING
        !is_so_datum   TYPE ty_ab_bis
      EXPORTING
        VALUE(et_stat) TYPE /adz/hmv_rt_stat
        VALUE(et_sart) TYPE /adz/hmv_t_sart .
*      IMPORTING
*        !iv_so_datum        TYPE it_sydatum OPTIONAL
    CLASS-METHODS get_dexproc_invout
      IMPORTING
        !is_so_datum        TYPE ty_ab_bis
      RETURNING
        VALUE(rt_cust_xpro) TYPE /adz/hmv_rt_xpro .
*      IMPORTING
*        !ls_date            TYPE it_segmentdat OPTIONAL
    CLASS-METHODS get_message_type
      IMPORTING
        !is_so_datum        TYPE ty_ab_bis
      RETURNING
        VALUE(rt_cust_msgt) TYPE /adz/hmv_rt_msgt .
*      IMPORTING
*        !iv_so_datum         TYPE it_segmentdat OPTIONAL
    CLASS-METHODS get_edi_segment
      IMPORTING
        !is_so_datum     TYPE ty_ab_bis
      RETURNING
        VALUE(rs_ediseg) TYPE /adz/hmv_segn .
    METHODS get_constants
      IMPORTING
        VALUE(iv_cons) TYPE /idxgc/de_constant
      RETURNING
        VALUE(rv_attr) TYPE seovalue .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /adz/cl_hmv_customizing IMPLEMENTATION.


  METHOD get_constants.

    DATA: lv_const LIKE iv_cons,
          rs_const LIKE LINE OF it_const.

    SELECT konstante attvalue FROM /adz/hmv_cons INTO TABLE it_const.
    IF sy-subrc = 0.
      CLEAR rv_attr.
      READ TABLE it_const INTO is_const WITH KEY konstante = iv_cons.
      MOVE is_const-attvalue TO rv_attr.
    ENDIF.
  ENDMETHOD.


  METHOD get_dexproc_invout.
* Selektiert alle gültigen Basisprozesse


    DATA: ls_xproc     TYPE /adz/hmv_xpro,
          lt_xproc     TYPE /adz/hmv_rt_xpro,
          rs_cust_xpro TYPE /adz/hmv_rs_xpro.


    IF rt_cust_xpro IS INITIAL.
      SELECT * FROM /adz/hmv_xpro INTO ls_xproc
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
*    DATA: ls_ediseg    TYPE /ADZ/hmv_segn,
    "DATA:     ls_cust_segn TYPE /adz/hmv_rs_segn.
    STATICS st_ediseg TYPE SORTED TABLE OF /adz/hmv_segn  WITH  NON-UNIQUE KEY datefrom.
    IF st_ediseg IS INITIAL.
      SELECT * FROM /adz/hmv_segn INTO TABLE st_ediseg.
    ENDIF.
    loop at st_ediseg into rs_ediseg where datefrom < is_so_datum-high AND dateto > is_so_datum-low.
        exit.
    endloop.

*    SELECT SINGLE * FROM /adz/hmv_segn INTO CORRESPONDING FIELDS OF rs_ediseg
*            WHERE datefrom < is_so_datum-high AND dateto > is_so_datum-low.

*      CLEAR rs_cust_segn.
*      rs_cust_segn-sign   = 'I'.
*      rs_cust_segn-option = 'EQ'.
*      rs_cust_segn-low    = ls_ediseg-segnam.
*      APPEND rs_cust_segn TO rt_cust_segn.
  ENDMETHOD.


  METHOD get_idoc_status.
* <ET 20160201>
* Abfrage der gültigen Versandarten mit dem entsprechenden
* IDoc-Status (01, 03, 14)
    DATA:
      lt_sart     TYPE TABLE OF /adz/hmv_sart,
      ls_sart     TYPE          /adz/hmv_sart,
      ls_rng_stat TYPE          /adz/hmv_rs_stat.

    SELECT * FROM /adz/hmv_sart
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

  METHOD get_hmv_sart.
    STATICS srt_sart TYPE REF TO /adz/hmv_t_sart.
    IF srt_sart IS INITIAL.
      SELECT * FROM /adz/hmv_sart INTO TABLE @DATA(lt_hmv_sart).
      CREATE DATA srt_sart.
      INSERT LINES OF lt_hmv_sart INTO TABLE srt_sart->*.
    ENDIF.
    rrt_hmv_sart = srt_sart.
  ENDMETHOD.

  METHOD get_message_type.

* Nachrichtentypen

    DATA: ls_msgt      TYPE /adz/hmv_msgt,
          rs_cust_msgt TYPE /adz/hmv_rs_msgt.

    IF rt_cust_msgt IS INITIAL.
      SELECT * FROM /adz/hmv_msgt
       INTO CORRESPONDING FIELDS OF ls_msgt
        WHERE datab < is_so_datum-high
          AND datbi > is_so_datum-low.

        rs_cust_msgt-sign   = 'I'.
        rs_cust_msgt-option = 'EQ'.
        rs_cust_msgt-low    = ls_msgt-msgtyp.
        APPEND rs_cust_msgt TO rt_cust_msgt.
      ENDSELECT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
