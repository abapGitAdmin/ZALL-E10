*----------------------------------------------------------------------*
*   INCLUDE LFICA_MACROSDAT                                            *
*----------------------------------------------------------------------*

* access to function module table
  DATA: _mac_h_fbstab_lines TYPE i.

* application log handling
  DATA: _mac_h_message TYPE balmi.
  DATA: _mac_h_subobject TYPE balsubobj.
  DATA: _mac_h_aktyp TYPE aktyp_kk.
  DATA: _mac_h_desired_probclass TYPE balprobcl.
  DATA: _mac_h_probclass_this_message TYPE balprobcl.
  DATA: _mac_h_changed_probclass TYPE balprobcl.

  DATA overflow TYPE xfeld.                              "1669876
