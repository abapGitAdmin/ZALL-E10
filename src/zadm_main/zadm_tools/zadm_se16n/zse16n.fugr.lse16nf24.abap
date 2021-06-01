*----------------------------------------------------------------------*
***INCLUDE LSE16NF24.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_TABLE_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_table_text .

data: ls_dd02v   type dd02v.
data: lt_dd27p   like dd27p occurs 0 with header line.
data: ls_dd25v   type dd25v.
data: ld_view    like DD25V-VIEWNAME.

*..Get text from table
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

   IF SY-SUBRC = 0.
      gd_tabl_text = ls_dd02v-ddtext.
   else.
      clear gd_tabl_text.
   ENDIF.
*..get text of View-hierarchies with explicite texts
   if sy-subrc = 0 and
     ls_dd02v-tabclass = 'VIEW'.
     ld_view = gd-tab.
     CALL FUNCTION 'DD_VIEW_GET'
       EXPORTING
         view_name            = ld_view
         WITHTEXT             = 'X'
       IMPORTING
         DD25V_WA_A           = ls_dd25v
       TABLES
         DD27P_TAB_A          = lt_dd27p
       EXCEPTIONS
         ACCESS_FAILURE       = 1
         OTHERS               = 2.
     IF sy-subrc = 0.
*......if text in logon language does not exits, get EN
       if ls_dd25v-ddtext = space and
          sy-langu        <> 'E'.
         CALL FUNCTION 'DD_VIEW_GET'
           EXPORTING
             view_name            = ld_view
             WITHTEXT             = 'X'
             langu                = 'E'
           IMPORTING
             DD25V_WA_A           = ls_dd25v
           EXCEPTIONS
             ACCESS_FAILURE       = 1
             OTHERS               = 2.
         if sy-subrc = 0.
            gd_tabl_text = ls_dd25v-ddtext.
         endif.
       else.
         gd_tabl_text = ls_dd25v-ddtext.
       endif.
     ENDIF.
   endif.

ENDFORM.                    " GET_TABLE_TEXT
