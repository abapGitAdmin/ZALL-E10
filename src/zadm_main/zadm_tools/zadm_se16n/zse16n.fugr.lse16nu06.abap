FUNCTION SE16N_SHOW_GRID_LINE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_ROW) OPTIONAL
*"     VALUE(I_COLUMN) OPTIONAL
*"----------------------------------------------------------------------
data: wa_fieldcat type lvc_s_fcat.
data: ls_dfies    like dfies.
data: ld_tab      type DDOBJNAME.
data: ld_field    like dfies-lfieldname.
data: ls_rseumod  like rseumod.
data: ld_timestmp LIKE CEST1-TIMESTMP.
data: ld_date     like sy-datum.
data: ld_time     like sy-uzeit.
data: ld_view     like DD25V-VIEWNAME.
data: ls_dd02v    type dd02v.
data: lt_dd27p    like dd27p occurs 0 with header line.
field-symbols: <f>, <g>,                                      "1424238
               <wa_table> type any.

*.In gt_fieldcat_out, I have all fields that are shown in this ALV
*.from table <all_table>.
*.Now display them in a popup.
* read table <all_table> index i_row assigning <wa_table>.
*.If we are in edit-mode, only <all_table_cell> contains all lines
  if gd-edit = true.
     read table <all_table_cell> index i_row assigning <wa_table>.
  else.
     read table <all_table> index i_row assigning <wa_table>.
  endif.
  check: sy-subrc = 0.

*.in case of views, some texts are not read by FIELDINFO_GET
  CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
       NAME                = gd-tab
*      STATE               = 'A'
       LANGU               = sy-langu
     IMPORTING
*      GOTSTATE            =
       DD02V_WA            = ls_dd02v
     EXCEPTIONS
       ILLEGAL_INPUT       = 1
       OTHERS              = 2.
  if sy-subrc = 0 and
     ls_dd02v-tabclass = 'VIEW'.
     ld_view = gd-tab.
     CALL FUNCTION 'DD_VIEW_GET'
       EXPORTING
         view_name            = ld_view
         WITHTEXT             = 'X'
       TABLES
         DD27P_TAB_A          = lt_dd27p
       EXCEPTIONS
         ACCESS_FAILURE       = 1
         OTHERS               = 2.
     IF sy-subrc <> 0.
* Implement suitable error handling here
     ENDIF.
  endif.

  refresh gt_detail.
  loop at gt_fieldcat into wa_fieldcat.
     clear gt_detail.
     ld_tab   = wa_fieldcat-ref_table.
     ld_field = wa_fieldcat-ref_field.
*     ld_field = wa_fieldcat-fieldname.
     CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
         TABNAME              = ld_tab
         LFIELDNAME           = ld_field
       IMPORTING
         DFIES_WA             = ls_dfies
       EXCEPTIONS
         OTHERS               = 1.
     IF SY-SUBRC = 0.
         move-corresponding ls_dfies to gt_detail.
*........fixed type in table leads to missing text
         if gt_detail-scrtext_l is initial.
*......if the table is a view with tables with direct type input even
*......fieldtext could be empty
           if ls_dfies-fieldtext is initial.
              read table lt_dd27p with key viewfield = ls_dfies-fieldname.
              if sy-subrc = 0.
                gt_detail-scrtext_l = lt_dd27p-ddtext.
              else.
                gt_detail-scrtext_l = wa_fieldcat-fieldname.
              endif.
           else.
              gt_detail-scrtext_l = ls_dfies-fieldtext.
           endif.
         endif.
     else.
        gt_detail-scrtext_l = wa_fieldcat-fieldname.
     ENDIF.
     assign component wa_fieldcat-fieldname of structure <wa_table>
                      to <f>.
     gt_detail-fieldname = wa_fieldcat-fieldname.
     gt_detail-tabname   = wa_fieldcat-ref_table.
*    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< begin of 1424238
     if ls_dfies-datatype = 'CURR' and
        ls_dfies-tabname = ls_dfies-reftable.
       assign component ls_dfies-reffield of structure <wa_table>
                        to <g>.
       write <f> to gt_detail-low currency <g> left-justified.
     else.
*.......convert timestamp into nice format
        if ls_dfies-domname = 'RKE_TSTMP'.
          ld_timestmp = <f>.
          CALL FUNCTION 'RKE_TIMESTAMP_CONVERT_OUTPUT'
            EXPORTING
              I_DAYST          = sy-dayst
              I_TIMESTMP       = ld_timestmp
              I_TZONE          = sy-tzone
            IMPORTING
              E_DATE           = ld_date
              E_TIME           = ld_time.
*          concatenate ld_date ',' ld_time into gt_detail-low
*             in CHARACTER MODE.
          write ld_date to gt_detail-low(10).
          write ld_time to gt_detail-low+12(8).
        else.
       write <f> to gt_detail-low left-justified.
        endif.
     endif.
*    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< end of 1424238
*..consider user setting in terms of conversion exits
*..if tbconvert is set, show the value always converted
     select single * from rseumod into ls_rseumod
                   where uname = sy-uname.
     if sy-subrc             = 0 and
        ls_rseumod-tbconvert = true.
        gt_detail-low_noconv = gt_detail-low.
     else.
*......unconverted line
        gt_detail-low_noconv = <f>.
        SHIFT gt_detail-low_noconv LEFT DELETING LEADING space.

     endif.
     append gt_detail.
  endloop.

  CALL FUNCTION 'TSWUSL_SHOW_DETAIL'
*   Exporting
*     e_row              = i_row
*     e_col              = i_column
    TABLES
      IT_SELFIELDS       = gt_detail.

ENDFUNCTION.
