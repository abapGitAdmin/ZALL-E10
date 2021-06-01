*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 08.01.2021 at 14:23:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/V_INV_CUST.................................*
FORM GET_DATA_/ADZ/V_INV_CUST.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADZ/INV_CUST WHERE
(VIM_WHERETAB) .
    CLEAR /ADZ/V_INV_CUST .
/ADZ/V_INV_CUST-MANDT =
/ADZ/INV_CUST-MANDT .
/ADZ/V_INV_CUST-REPORT =
/ADZ/INV_CUST-REPORT .
/ADZ/V_INV_CUST-FIELD =
/ADZ/INV_CUST-FIELD .
/ADZ/V_INV_CUST-VALUE =
/ADZ/INV_CUST-VALUE .
/ADZ/V_INV_CUST-DESCRIPTION =
/ADZ/INV_CUST-DESCRIPTION .
/ADZ/V_INV_CUST-SELECT_PARAMETER =
/ADZ/INV_CUST-SELECT_PARAMETER .
<VIM_TOTAL_STRUC> = /ADZ/V_INV_CUST.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_/ADZ/V_INV_CUST .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADZ/V_INV_CUST.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADZ/V_INV_CUST-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_CUST WHERE
  REPORT = /ADZ/V_INV_CUST-REPORT AND
  FIELD = /ADZ/V_INV_CUST-FIELD .
    IF SY-SUBRC = 0.
    DELETE /ADZ/INV_CUST .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_CUST WHERE
  REPORT = /ADZ/V_INV_CUST-REPORT AND
  FIELD = /ADZ/V_INV_CUST-FIELD .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADZ/INV_CUST.
    ENDIF.
/ADZ/INV_CUST-MANDT =
/ADZ/V_INV_CUST-MANDT .
/ADZ/INV_CUST-REPORT =
/ADZ/V_INV_CUST-REPORT .
/ADZ/INV_CUST-FIELD =
/ADZ/V_INV_CUST-FIELD .
/ADZ/INV_CUST-VALUE =
/ADZ/V_INV_CUST-VALUE .
/ADZ/INV_CUST-DESCRIPTION =
/ADZ/V_INV_CUST-DESCRIPTION .
/ADZ/INV_CUST-SELECT_PARAMETER =
/ADZ/V_INV_CUST-SELECT_PARAMETER .
    IF SY-SUBRC = 0.
    UPDATE /ADZ/INV_CUST ##WARN_OK.
    ELSE.
    INSERT /ADZ/INV_CUST .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_/ADZ/V_INV_CUST-UPD_FLAG,
STATUS_/ADZ/V_INV_CUST-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADZ/V_INV_CUST.
  SELECT SINGLE * FROM /ADZ/INV_CUST WHERE
REPORT = /ADZ/V_INV_CUST-REPORT AND
FIELD = /ADZ/V_INV_CUST-FIELD .
/ADZ/V_INV_CUST-MANDT =
/ADZ/INV_CUST-MANDT .
/ADZ/V_INV_CUST-REPORT =
/ADZ/INV_CUST-REPORT .
/ADZ/V_INV_CUST-FIELD =
/ADZ/INV_CUST-FIELD .
/ADZ/V_INV_CUST-VALUE =
/ADZ/INV_CUST-VALUE .
/ADZ/V_INV_CUST-DESCRIPTION =
/ADZ/INV_CUST-DESCRIPTION .
/ADZ/V_INV_CUST-SELECT_PARAMETER =
/ADZ/INV_CUST-SELECT_PARAMETER .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADZ/V_INV_CUST USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADZ/V_INV_CUST-REPORT TO
/ADZ/INV_CUST-REPORT .
MOVE /ADZ/V_INV_CUST-FIELD TO
/ADZ/INV_CUST-FIELD .
MOVE /ADZ/V_INV_CUST-MANDT TO
/ADZ/INV_CUST-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADZ/INV_CUST'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADZ/INV_CUST TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADZ/INV_CUST'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: /ADZ/V_INV_FUNC.................................*
FORM GET_DATA_/ADZ/V_INV_FUNC.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADZ/INV_FUNC WHERE
(VIM_WHERETAB) .
    CLEAR /ADZ/V_INV_FUNC .
/ADZ/V_INV_FUNC-MANDT =
/ADZ/INV_FUNC-MANDT .
/ADZ/V_INV_FUNC-FUNCTIONS =
/ADZ/INV_FUNC-FUNCTIONS .
/ADZ/V_INV_FUNC-FUNCTION =
/ADZ/INV_FUNC-FUNCTION .
<VIM_TOTAL_STRUC> = /ADZ/V_INV_FUNC.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_/ADZ/V_INV_FUNC .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADZ/V_INV_FUNC.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADZ/V_INV_FUNC-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_FUNC WHERE
  FUNCTIONS = /ADZ/V_INV_FUNC-FUNCTIONS AND
  FUNCTION = /ADZ/V_INV_FUNC-FUNCTION .
    IF SY-SUBRC = 0.
    DELETE /ADZ/INV_FUNC .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_FUNC WHERE
  FUNCTIONS = /ADZ/V_INV_FUNC-FUNCTIONS AND
  FUNCTION = /ADZ/V_INV_FUNC-FUNCTION .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADZ/INV_FUNC.
    ENDIF.
/ADZ/INV_FUNC-MANDT =
/ADZ/V_INV_FUNC-MANDT .
/ADZ/INV_FUNC-FUNCTIONS =
/ADZ/V_INV_FUNC-FUNCTIONS .
/ADZ/INV_FUNC-FUNCTION =
/ADZ/V_INV_FUNC-FUNCTION .
    IF SY-SUBRC = 0.
    UPDATE /ADZ/INV_FUNC ##WARN_OK.
    ELSE.
    INSERT /ADZ/INV_FUNC .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_/ADZ/V_INV_FUNC-UPD_FLAG,
STATUS_/ADZ/V_INV_FUNC-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADZ/V_INV_FUNC.
  SELECT SINGLE * FROM /ADZ/INV_FUNC WHERE
FUNCTIONS = /ADZ/V_INV_FUNC-FUNCTIONS AND
FUNCTION = /ADZ/V_INV_FUNC-FUNCTION .
/ADZ/V_INV_FUNC-MANDT =
/ADZ/INV_FUNC-MANDT .
/ADZ/V_INV_FUNC-FUNCTIONS =
/ADZ/INV_FUNC-FUNCTIONS .
/ADZ/V_INV_FUNC-FUNCTION =
/ADZ/INV_FUNC-FUNCTION .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADZ/V_INV_FUNC USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADZ/V_INV_FUNC-FUNCTIONS TO
/ADZ/INV_FUNC-FUNCTIONS .
MOVE /ADZ/V_INV_FUNC-FUNCTION TO
/ADZ/INV_FUNC-FUNCTION .
MOVE /ADZ/V_INV_FUNC-MANDT TO
/ADZ/INV_FUNC-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADZ/INV_FUNC'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADZ/INV_FUNC TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADZ/INV_FUNC'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: /ADZ/V_INV_USR..................................*
FORM GET_DATA_/ADZ/V_INV_USR.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADZ/INV_USR WHERE
(VIM_WHERETAB) .
    CLEAR /ADZ/V_INV_USR .
/ADZ/V_INV_USR-MANDT =
/ADZ/INV_USR-MANDT .
/ADZ/V_INV_USR-GRUPPE =
/ADZ/INV_USR-GRUPPE .
/ADZ/V_INV_USR-FUNCTIONS =
/ADZ/INV_USR-FUNCTIONS .
<VIM_TOTAL_STRUC> = /ADZ/V_INV_USR.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_/ADZ/V_INV_USR .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADZ/V_INV_USR.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADZ/V_INV_USR-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_USR WHERE
  GRUPPE = /ADZ/V_INV_USR-GRUPPE .
    IF SY-SUBRC = 0.
    DELETE /ADZ/INV_USR .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM /ADZ/INV_USR WHERE
  GRUPPE = /ADZ/V_INV_USR-GRUPPE .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADZ/INV_USR.
    ENDIF.
/ADZ/INV_USR-MANDT =
/ADZ/V_INV_USR-MANDT .
/ADZ/INV_USR-GRUPPE =
/ADZ/V_INV_USR-GRUPPE .
/ADZ/INV_USR-FUNCTIONS =
/ADZ/V_INV_USR-FUNCTIONS .
    IF SY-SUBRC = 0.
    UPDATE /ADZ/INV_USR ##WARN_OK.
    ELSE.
    INSERT /ADZ/INV_USR .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_/ADZ/V_INV_USR-UPD_FLAG,
STATUS_/ADZ/V_INV_USR-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADZ/V_INV_USR.
  SELECT SINGLE * FROM /ADZ/INV_USR WHERE
GRUPPE = /ADZ/V_INV_USR-GRUPPE .
/ADZ/V_INV_USR-MANDT =
/ADZ/INV_USR-MANDT .
/ADZ/V_INV_USR-GRUPPE =
/ADZ/INV_USR-GRUPPE .
/ADZ/V_INV_USR-FUNCTIONS =
/ADZ/INV_USR-FUNCTIONS .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADZ/V_INV_USR USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADZ/V_INV_USR-GRUPPE TO
/ADZ/INV_USR-GRUPPE .
MOVE /ADZ/V_INV_USR-MANDT TO
/ADZ/INV_USR-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADZ/INV_USR'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADZ/INV_USR TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADZ/INV_USR'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*

* base table related FORM-routines.............
INCLUDE LSVIMFTX .