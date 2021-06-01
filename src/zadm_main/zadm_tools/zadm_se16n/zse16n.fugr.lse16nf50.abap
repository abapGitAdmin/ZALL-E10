*----------------------------------------------------------------------*
***INCLUDE LSE16NF50 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  transport_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transport_data.

data: ls_index    type LVC_S_ROW.
data: lt_index    type LVC_T_ROW.
data: ls_rowno    type LVC_S_ROID.
data: lt_rowno    type LVC_T_ROID.
data: ld_lines    like sy-tabix.
data: ld_start    like sy-tabix.
data: ld_len      like sy-tabix.
data: wa_fieldcat type lvc_s_fcat.
data: txtref      type ref to data.
data: ld_answer(1).
data: ld_type_error(1).
data: ld_key_error(1).
data: ld_max_len like sy-tabix.
data: typ1 type c length 1.
data: ld_contflag like dd02l-contflag.
data: ld_category LIKE E070-KORRDEV.

data: IKO200 LIKE KO200,
      IORDER LIKE E070-TRKORR,
      ITASK  LIKE E070-TRKORR,
      IE071K LIKE E071K OCCURS 0 WITH HEADER LINE,
      IE071  LIKE E071 OCCURS 0 WITH HEADER LINE.
field-symbols: <txt_wa>   type any,
               <wa_trans> type any,
               <f1>.

***????????????????????????????????????????????????????????????????
*..check if user is authorized to transport
   AUTHORITY-CHECK OBJECT 'S_TRANSPRT'
         ID 'TTYPE' FIELD 'TASK'
         ID 'ACTVT' FIELD '02'.
   if sy-subrc <> 0.
      MESSAGE I617(TK) WITH 'R3TR' 'TABU' gd-tab.
      exit.
   endif.
***????????????????????????????????????????????????????????????????

*..first get marked lines
   CALL METHOD ALV_GRID->GET_SELECTED_ROWS
      IMPORTING
        ET_INDEX_ROWS = lt_index
        ET_ROW_NO     = lt_rowno.

   describe table lt_index lines ld_lines.
   if ld_lines < 1.
      message i105(wusl).
      exit.
   endif.

*..ask customer if he really wants to transport
    call function 'POPUP_TO_CONFIRM'
         exporting
              titlebar       = 'Tabelleneinträge transportieren'(030)
              text_question  = 'WollT'(031)
         importing
              answer         = ld_answer
         exceptions
              text_not_found = 1
              others         = 2.

   check: ld_answer = '1'.
   IKO200-PGMID    = 'R3TR'.
   IKO200-OBJECT   = 'TABU'.
   IKO200-OBJFUNC  = 'K'.
   IKO200-OBJ_NAME = gd-tab.

   clear ie071.
   refresh ie071.
   IE071-PGMID    = 'R3TR'.
   IE071-OBJECT   = 'TABU'.
   IE071-OBJ_NAME = gd-tab.
   IE071-OBJFUNC  = 'K'.
   APPEND IE071.

   clear: ld_type_error, ld_key_error.

*..Fill key fields from table <all_table_cell> into tabkey
   loop at lt_index into ls_index.
      read table <all_table_cell> index ls_index-index
                 assigning <wa_trans>.
      check: sy-subrc = 0.
      clear: ld_start, ie071k.
      loop at gt_fieldcat_key into wa_fieldcat.
         assign component wa_fieldcat-fieldname of structure
                          <wa_trans> to <f1>.
*.check if field is character type -> otherwise only *-transport
         describe field <F1> type typ1.
         if typ1 NA 'CDNT'.
           ie071k-tabkey+ld_start(1) = '*'.
           ld_type_error = 'X'.
           exit.
         endif.
*.Unicode-Change <x>
         describe field <f1> length ld_len in character mode.
*.check if key is longer than C120 --> error
         ld_max_len = ld_len + ld_start.
         if ld_max_len > 120.
           ie071k-tabkey+ld_start(1) = '*'.
           ld_key_error = 'X'.
           exit.
         endif.
         ie071k-tabkey+ld_start(ld_len) = <f1>.
         add ld_len to ld_start.
      endloop.
      IE071K-PGMID      = 'R3TR'.
      IE071K-MASTERTYPE = 'TABU'.
      IE071K-OBJECT     = 'TABU'.
      IE071K-MASTERNAME = gd-tab.
      IE071K-OBJNAME    = gd-tab.
      APPEND IE071K.
   endloop.

   IF LD_TYPE_ERROR = 'X'.
      MESSAGE I320(TK) with gd-tab.
   ENDIF.
   IF LD_KEY_ERROR = 'X'.
      MESSAGE I320(TK) with gd-tab.
   ENDIF.

*..check category of table
   select single contflag from DD02L into ld_contflag
            where tabname  = gd-tab
              and as4local = 'A'.
   if sy-subrc = 0 and
      ( ld_contflag = 'C' or ld_contflag = 'G') and
      gd-clnt = true.
      ld_category = 'CUST'.
   else.
      ld_category = 'SYST'.
   endif.

   CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
           EXPORTING
                IV_CATEGORY            = ld_category
*               IV_CLI_DEP             = 'X'
           IMPORTING
                EV_ORDER               = IORDER
                EV_TASK                = ITASK
           EXCEPTIONS
                OTHERS                 = 3.
   IF SY-SUBRC <> 0.
      EXIT.
   ENDIF.
   CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
           EXPORTING
                WI_SIMULATION                  = ' '
                WI_SUPPRESS_KEY_CHECK          = ' '
                WI_TRKORR                      = ITASK
           TABLES
                WT_E071                        = IE071
                WT_E071K                       = IE071K
           EXCEPTIONS
                OTHERS                         = 68.
   IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

*..transport text table as well
   if not gd-txt_tab is initial.
      clear: ie071, ie071k.
      REFRESH: IE071K, IE071.
      IKO200-PGMID    = 'R3TR'.
      IKO200-OBJECT   = 'TABU'.
      IKO200-OBJFUNC  = 'K'.
      IKO200-OBJ_NAME = gd-txt_tab.
      IE071-PGMID     = 'R3TR'.
      IE071-OBJECT    = 'TABU'.
      IE071-OBJ_NAME  = gd-txt_tab.
      IE071-OBJFUNC   = 'K'.
      APPEND IE071.
*.....fill keyfields from text table into tabkey (create <txt_wa>,
*.....because of langu field
      create data txtref type (gd-txt_tab).
      assign txtref->* to <txt_wa>.
      loop at lt_index into ls_index.
         read table <all_table_cell> index ls_index-index
                    assigning <wa_trans>.
         check: sy-subrc = 0.
         clear: ld_start, ie071k.
         loop at gt_fieldcat_txttab into wa_fieldcat
                          where key = true.
*...........Fill language with current one
            if wa_fieldcat-datatype = 'LANG'.
               ASSIGN COMPONENT wa_fieldcat-fieldname
                                OF STRUCTURE <txt_wa> TO <F1>.
               <f1> = sy-langu.
            else.
               assign component wa_fieldcat-fieldname of structure
                             <wa_trans> to <f1>.
            endif.
*.Unicode-Change <x>
            describe field <f1> length ld_len in character mode.
*.check if key is longer than C120 --> error  "Note 1982083
         ld_max_len = ld_len + ld_start.
         if ld_max_len > 120.
           ie071k-tabkey+ld_start(1) = '*'.
           ld_key_error = 'X'.
           exit.
         endif.
         ie071k-tabkey+ld_start(ld_len) = <f1>.
            add ld_len to ld_start.
         endloop.
         IE071K-PGMID      = 'R3TR'.
         IE071K-MASTERTYPE = 'TABU'.
         IE071K-OBJECT     = 'TABU'.
         IE071K-MASTERNAME = gd-txt_tab.
         IE071K-OBJNAME    = gd-txt_tab.
         APPEND IE071K.
      endloop.
*..check category of table
      select single contflag from DD02L into ld_contflag
            where tabname  = gd-txt_tab
              and as4local = 'A'.
      if sy-subrc = 0 and
         ( ld_contflag = 'C' or ld_contflag = 'G') and
         gd-clnt = true.
         ld_category = 'CUST'.
      else.
         ld_category = 'SYST'.
      endif.
      CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
           EXPORTING
                IV_CATEGORY            = ld_category
*               IV_CLI_DEP             = 'X'
           IMPORTING
                EV_ORDER               = IORDER
                EV_TASK                = ITASK
           EXCEPTIONS
                OTHERS                 = 3.
      IF SY-SUBRC <> 0.
         EXIT.
      ENDIF.
      CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
           EXPORTING
                WI_SIMULATION                  = ' '
                WI_SUPPRESS_KEY_CHECK          = ' '
                WI_TRKORR                      = ITASK
           TABLES
                WT_E071                        = IE071
                WT_E071K                       = IE071K
           EXCEPTIONS
                OTHERS                         = 68.
      IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.

*.If everything o.k., send message
  message s101(wusl).

ENDFORM.                    " transport_data
