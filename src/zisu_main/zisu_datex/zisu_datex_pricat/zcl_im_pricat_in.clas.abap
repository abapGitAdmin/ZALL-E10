class ZCL_IM_PRICAT_IN definition
  public
  final
  create public .

public section.

  interfaces /IDEXGE/IF_EX_PRICAT_IN .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_PRICAT_IN IMPLEMENTATION.


  method /IDEXGE/IF_EX_PRICAT_IN~CHANGE_PRICE_DATA.
  endmethod.


  METHOD /idexge/if_ex_pricat_in~overwrite_idoc_data.
    DATA: ls_edex_idocdata TYPE edex_idocdata.

    ls_edex_idocdata-control = is_idoc_control.
    ls_edex_idocdata-data = ct_idoc_data.

    zcl_datex_utility=>modify_externalid_inbound( CHANGING cs_idoc_data = ls_edex_idocdata ).

    ct_idoc_data = ls_edex_idocdata-data.
  ENDMETHOD.
ENDCLASS.
