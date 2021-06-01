*----------------------------------------------------------------------*
***INCLUDE LGTDISO02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS_0200 OUTPUT.

   refresh excltab.
   if gd-show_layouts = true and
      gd-hana_active  = true.
   else.
      excltab-fcode = 'TOGGLE_LAY'.
      append excltab.
   endif.
   if gd-edit = true.
      set pf-status '0200' excluding excltab.
   else.
      excltab-fcode = 'SAVE'.
      append excltab.
      excltab-fcode = 'TRANSPORT'.
      append excltab.
      set pf-status '0200' excluding excltab.
   endif.
   set titlebar '200' with gd-tab.

ENDMODULE.                 " SET_STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_0220  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_STATUS_0220 OUTPUT.

   refresh excltab.
   if gd-show_layouts = true and
      gd-hana_active  = true.
   else.
      excltab-fcode = 'TOGGLE_LAY'.
      append excltab.
   endif.

   if gd-edit <> true.
      excltab-fcode = 'SAVE'.
      append excltab.
      excltab-fcode = 'TRANSPORT'.
      append excltab.
   endif.

   set pf-status '0220' excluding excltab.
   set titlebar '220' with gd-ext_gui_title.

ENDMODULE.                 " SET_STATUS_0220  OUTPUT
