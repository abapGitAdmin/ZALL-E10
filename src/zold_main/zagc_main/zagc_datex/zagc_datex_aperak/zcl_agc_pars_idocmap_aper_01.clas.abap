class ZCL_AGC_PARS_IDOCMAP_APER_01 definition
  public
  inheriting from /IDXGC/CL_PARS_IDOCMAP_APER_01
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_IDOC_DATA type EDEX_IDOCDATA optional
      !IV_KEY_DATE type /IDXGC/DE_PARSER_DATEFROM optional
    raising
      /IDXGC/CX_IDE_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_PARS_IDOCMAP_APER_01 IMPLEMENTATION.


  METHOD constructor.
**************************************************************************************************
* THIMEL.R 20150630 Einführung CL
*   Standard COMEV festlegen
**************************************************************************************************
    CALL METHOD super->constructor
      EXPORTING
        is_idoc_data = is_idoc_data
        iv_key_date  = iv_key_date.

* Set attribute in inbound process
    IF is_idoc_data-control-direct = /idxgc/cl_parser_idoc=>co_idoc_direction_inbound.
      me->mv_de_old_fm     = zif_agc_datex_aperak_co=>gc_de_fm_aperak_1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
