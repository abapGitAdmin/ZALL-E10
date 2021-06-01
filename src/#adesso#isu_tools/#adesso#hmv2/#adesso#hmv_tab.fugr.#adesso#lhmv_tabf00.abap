*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 15.12.2016 at 10:02:22
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_HMV_AR................................*
FORM GET_DATA_/ADESSO/V_HMV_AR.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADESSO/HMV_SART WHERE
(VIM_WHERETAB) .
    CLEAR /ADESSO/V_HMV_AR .
/ADESSO/V_HMV_AR-DEXPROC =
/ADESSO/HMV_SART-DEXPROC .
/ADESSO/V_HMV_AR-SERVICEANBIETER =
/ADESSO/HMV_SART-SERVICEANBIETER .
/ADESSO/V_HMV_AR-DEXIDOCSENT =
/ADESSO/HMV_SART-DEXIDOCSENT .
/ADESSO/V_HMV_AR-DEXIDOCSENDCAT =
/ADESSO/HMV_SART-DEXIDOCSENDCAT .
/ADESSO/V_HMV_AR-DATBI =
/ADESSO/HMV_SART-DATBI .
/ADESSO/V_HMV_AR-DATAB =
/ADESSO/HMV_SART-DATAB .
/ADESSO/V_HMV_AR-STATUS =
/ADESSO/HMV_SART-STATUS .
/ADESSO/V_HMV_AR-INV =
/ADESSO/HMV_SART-INV .
/ADESSO/V_HMV_AR-CTRL =
/ADESSO/HMV_SART-CTRL .
<VIM_TOTAL_STRUC> = /ADESSO/V_HMV_AR.
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
FORM DB_UPD_/ADESSO/V_HMV_AR .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADESSO/V_HMV_AR.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADESSO/V_HMV_AR-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_SART WHERE
  DEXPROC = /ADESSO/V_HMV_AR-DEXPROC AND
  SERVICEANBIETER = /ADESSO/V_HMV_AR-SERVICEANBIETER AND
  DEXIDOCSENT = /ADESSO/V_HMV_AR-DEXIDOCSENT AND
  DEXIDOCSENDCAT = /ADESSO/V_HMV_AR-DEXIDOCSENDCAT AND
  DATBI = /ADESSO/V_HMV_AR-DATBI .
    IF SY-SUBRC = 0.
    DELETE /ADESSO/HMV_SART .
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_SART WHERE
  DEXPROC = /ADESSO/V_HMV_AR-DEXPROC AND
  SERVICEANBIETER = /ADESSO/V_HMV_AR-SERVICEANBIETER AND
  DEXIDOCSENT = /ADESSO/V_HMV_AR-DEXIDOCSENT AND
  DEXIDOCSENDCAT = /ADESSO/V_HMV_AR-DEXIDOCSENDCAT AND
  DATBI = /ADESSO/V_HMV_AR-DATBI .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADESSO/HMV_SART.
    ENDIF.
/ADESSO/HMV_SART-DEXPROC =
/ADESSO/V_HMV_AR-DEXPROC .
/ADESSO/HMV_SART-SERVICEANBIETER =
/ADESSO/V_HMV_AR-SERVICEANBIETER .
/ADESSO/HMV_SART-DEXIDOCSENT =
/ADESSO/V_HMV_AR-DEXIDOCSENT .
/ADESSO/HMV_SART-DEXIDOCSENDCAT =
/ADESSO/V_HMV_AR-DEXIDOCSENDCAT .
/ADESSO/HMV_SART-DATBI =
/ADESSO/V_HMV_AR-DATBI .
/ADESSO/HMV_SART-DATAB =
/ADESSO/V_HMV_AR-DATAB .
/ADESSO/HMV_SART-STATUS =
/ADESSO/V_HMV_AR-STATUS .
/ADESSO/HMV_SART-INV =
/ADESSO/V_HMV_AR-INV .
/ADESSO/HMV_SART-CTRL =
/ADESSO/V_HMV_AR-CTRL .
    IF SY-SUBRC = 0.
    UPDATE /ADESSO/HMV_SART .
    ELSE.
    INSERT /ADESSO/HMV_SART .
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
CLEAR: STATUS_/ADESSO/V_HMV_AR-UPD_FLAG,
STATUS_/ADESSO/V_HMV_AR-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADESSO/V_HMV_AR.
  SELECT SINGLE * FROM /ADESSO/HMV_SART WHERE
DEXPROC = /ADESSO/V_HMV_AR-DEXPROC AND
SERVICEANBIETER = /ADESSO/V_HMV_AR-SERVICEANBIETER AND
DEXIDOCSENT = /ADESSO/V_HMV_AR-DEXIDOCSENT AND
DEXIDOCSENDCAT = /ADESSO/V_HMV_AR-DEXIDOCSENDCAT AND
DATBI = /ADESSO/V_HMV_AR-DATBI .
/ADESSO/V_HMV_AR-DEXPROC =
/ADESSO/HMV_SART-DEXPROC .
/ADESSO/V_HMV_AR-SERVICEANBIETER =
/ADESSO/HMV_SART-SERVICEANBIETER .
/ADESSO/V_HMV_AR-DEXIDOCSENT =
/ADESSO/HMV_SART-DEXIDOCSENT .
/ADESSO/V_HMV_AR-DEXIDOCSENDCAT =
/ADESSO/HMV_SART-DEXIDOCSENDCAT .
/ADESSO/V_HMV_AR-DATBI =
/ADESSO/HMV_SART-DATBI .
/ADESSO/V_HMV_AR-DATAB =
/ADESSO/HMV_SART-DATAB .
/ADESSO/V_HMV_AR-STATUS =
/ADESSO/HMV_SART-STATUS .
/ADESSO/V_HMV_AR-INV =
/ADESSO/HMV_SART-INV .
/ADESSO/V_HMV_AR-CTRL =
/ADESSO/HMV_SART-CTRL .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADESSO/V_HMV_AR USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADESSO/V_HMV_AR-DEXPROC TO
/ADESSO/HMV_SART-DEXPROC .
MOVE /ADESSO/V_HMV_AR-SERVICEANBIETER TO
/ADESSO/HMV_SART-SERVICEANBIETER .
MOVE /ADESSO/V_HMV_AR-DEXIDOCSENT TO
/ADESSO/HMV_SART-DEXIDOCSENT .
MOVE /ADESSO/V_HMV_AR-DEXIDOCSENDCAT TO
/ADESSO/HMV_SART-DEXIDOCSENDCAT .
MOVE /ADESSO/V_HMV_AR-DATBI TO
/ADESSO/HMV_SART-DATBI .
MOVE SY-MANDT TO
/ADESSO/HMV_SART-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADESSO/HMV_SART'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADESSO/HMV_SART TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADESSO/HMV_SART'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_HMV_MS................................*
FORM GET_DATA_/ADESSO/V_HMV_MS.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADESSO/HMV_MSGT WHERE
(VIM_WHERETAB) .
    CLEAR /ADESSO/V_HMV_MS .
/ADESSO/V_HMV_MS-MSGTYP =
/ADESSO/HMV_MSGT-MSGTYP .
/ADESSO/V_HMV_MS-DATBI =
/ADESSO/HMV_MSGT-DATBI .
/ADESSO/V_HMV_MS-DATAB =
/ADESSO/HMV_MSGT-DATAB .
<VIM_TOTAL_STRUC> = /ADESSO/V_HMV_MS.
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
FORM DB_UPD_/ADESSO/V_HMV_MS .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADESSO/V_HMV_MS.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADESSO/V_HMV_MS-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_MSGT WHERE
  MSGTYP = /ADESSO/V_HMV_MS-MSGTYP AND
  DATBI = /ADESSO/V_HMV_MS-DATBI .
    IF SY-SUBRC = 0.
    DELETE /ADESSO/HMV_MSGT .
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_MSGT WHERE
  MSGTYP = /ADESSO/V_HMV_MS-MSGTYP AND
  DATBI = /ADESSO/V_HMV_MS-DATBI .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADESSO/HMV_MSGT.
    ENDIF.
/ADESSO/HMV_MSGT-MSGTYP =
/ADESSO/V_HMV_MS-MSGTYP .
/ADESSO/HMV_MSGT-DATBI =
/ADESSO/V_HMV_MS-DATBI .
/ADESSO/HMV_MSGT-DATAB =
/ADESSO/V_HMV_MS-DATAB .
    IF SY-SUBRC = 0.
    UPDATE /ADESSO/HMV_MSGT .
    ELSE.
    INSERT /ADESSO/HMV_MSGT .
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
CLEAR: STATUS_/ADESSO/V_HMV_MS-UPD_FLAG,
STATUS_/ADESSO/V_HMV_MS-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADESSO/V_HMV_MS.
  SELECT SINGLE * FROM /ADESSO/HMV_MSGT WHERE
MSGTYP = /ADESSO/V_HMV_MS-MSGTYP AND
DATBI = /ADESSO/V_HMV_MS-DATBI .
/ADESSO/V_HMV_MS-MSGTYP =
/ADESSO/HMV_MSGT-MSGTYP .
/ADESSO/V_HMV_MS-DATBI =
/ADESSO/HMV_MSGT-DATBI .
/ADESSO/V_HMV_MS-DATAB =
/ADESSO/HMV_MSGT-DATAB .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADESSO/V_HMV_MS USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADESSO/V_HMV_MS-MSGTYP TO
/ADESSO/HMV_MSGT-MSGTYP .
MOVE /ADESSO/V_HMV_MS-DATBI TO
/ADESSO/HMV_MSGT-DATBI .
MOVE SY-MANDT TO
/ADESSO/HMV_MSGT-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADESSO/HMV_MSGT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADESSO/HMV_MSGT TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADESSO/HMV_MSGT'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_HMV_SG................................*
FORM GET_DATA_/ADESSO/V_HMV_SG.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADESSO/HMV_SEGN WHERE
(VIM_WHERETAB) .
    CLEAR /ADESSO/V_HMV_SG .
/ADESSO/V_HMV_SG-SEGNAM =
/ADESSO/HMV_SEGN-SEGNAM .
/ADESSO/V_HMV_SG-DATETO =
/ADESSO/HMV_SEGN-DATETO .
/ADESSO/V_HMV_SG-DATEFROM =
/ADESSO/HMV_SEGN-DATEFROM .
<VIM_TOTAL_STRUC> = /ADESSO/V_HMV_SG.
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
FORM DB_UPD_/ADESSO/V_HMV_SG .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADESSO/V_HMV_SG.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADESSO/V_HMV_SG-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_SEGN WHERE
  SEGNAM = /ADESSO/V_HMV_SG-SEGNAM AND
  DATETO = /ADESSO/V_HMV_SG-DATETO .
    IF SY-SUBRC = 0.
    DELETE /ADESSO/HMV_SEGN .
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_SEGN WHERE
  SEGNAM = /ADESSO/V_HMV_SG-SEGNAM AND
  DATETO = /ADESSO/V_HMV_SG-DATETO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADESSO/HMV_SEGN.
    ENDIF.
/ADESSO/HMV_SEGN-SEGNAM =
/ADESSO/V_HMV_SG-SEGNAM .
/ADESSO/HMV_SEGN-DATETO =
/ADESSO/V_HMV_SG-DATETO .
/ADESSO/HMV_SEGN-DATEFROM =
/ADESSO/V_HMV_SG-DATEFROM .
    IF SY-SUBRC = 0.
    UPDATE /ADESSO/HMV_SEGN .
    ELSE.
    INSERT /ADESSO/HMV_SEGN .
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
CLEAR: STATUS_/ADESSO/V_HMV_SG-UPD_FLAG,
STATUS_/ADESSO/V_HMV_SG-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADESSO/V_HMV_SG.
  SELECT SINGLE * FROM /ADESSO/HMV_SEGN WHERE
SEGNAM = /ADESSO/V_HMV_SG-SEGNAM AND
DATETO = /ADESSO/V_HMV_SG-DATETO .
/ADESSO/V_HMV_SG-SEGNAM =
/ADESSO/HMV_SEGN-SEGNAM .
/ADESSO/V_HMV_SG-DATETO =
/ADESSO/HMV_SEGN-DATETO .
/ADESSO/V_HMV_SG-DATEFROM =
/ADESSO/HMV_SEGN-DATEFROM .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADESSO/V_HMV_SG USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADESSO/V_HMV_SG-SEGNAM TO
/ADESSO/HMV_SEGN-SEGNAM .
MOVE /ADESSO/V_HMV_SG-DATETO TO
/ADESSO/HMV_SEGN-DATETO .
MOVE SY-MANDT TO
/ADESSO/HMV_SEGN-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADESSO/HMV_SEGN'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADESSO/HMV_SEGN TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADESSO/HMV_SEGN'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_HMV_XP................................*
FORM GET_DATA_/ADESSO/V_HMV_XP.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM /ADESSO/HMV_XPRO WHERE
(VIM_WHERETAB) .
    CLEAR /ADESSO/V_HMV_XP .
/ADESSO/V_HMV_XP-DEXBASICPROC =
/ADESSO/HMV_XPRO-DEXBASICPROC .
/ADESSO/V_HMV_XP-DATETO =
/ADESSO/HMV_XPRO-DATETO .
/ADESSO/V_HMV_XP-DATEFROM =
/ADESSO/HMV_XPRO-DATEFROM .
<VIM_TOTAL_STRUC> = /ADESSO/V_HMV_XP.
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
FORM DB_UPD_/ADESSO/V_HMV_XP .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO /ADESSO/V_HMV_XP.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_/ADESSO/V_HMV_XP-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_XPRO WHERE
  DEXBASICPROC = /ADESSO/V_HMV_XP-DEXBASICPROC AND
  DATETO = /ADESSO/V_HMV_XP-DATETO .
    IF SY-SUBRC = 0.
    DELETE /ADESSO/HMV_XPRO .
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
  SELECT SINGLE FOR UPDATE * FROM /ADESSO/HMV_XPRO WHERE
  DEXBASICPROC = /ADESSO/V_HMV_XP-DEXBASICPROC AND
  DATETO = /ADESSO/V_HMV_XP-DATETO .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR /ADESSO/HMV_XPRO.
    ENDIF.
/ADESSO/HMV_XPRO-DEXBASICPROC =
/ADESSO/V_HMV_XP-DEXBASICPROC .
/ADESSO/HMV_XPRO-DATETO =
/ADESSO/V_HMV_XP-DATETO .
/ADESSO/HMV_XPRO-DATEFROM =
/ADESSO/V_HMV_XP-DATEFROM .
    IF SY-SUBRC = 0.
    UPDATE /ADESSO/HMV_XPRO .
    ELSE.
    INSERT /ADESSO/HMV_XPRO .
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
CLEAR: STATUS_/ADESSO/V_HMV_XP-UPD_FLAG,
STATUS_/ADESSO/V_HMV_XP-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_/ADESSO/V_HMV_XP.
  SELECT SINGLE * FROM /ADESSO/HMV_XPRO WHERE
DEXBASICPROC = /ADESSO/V_HMV_XP-DEXBASICPROC AND
DATETO = /ADESSO/V_HMV_XP-DATETO .
/ADESSO/V_HMV_XP-DEXBASICPROC =
/ADESSO/HMV_XPRO-DEXBASICPROC .
/ADESSO/V_HMV_XP-DATETO =
/ADESSO/HMV_XPRO-DATETO .
/ADESSO/V_HMV_XP-DATEFROM =
/ADESSO/HMV_XPRO-DATEFROM .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_/ADESSO/V_HMV_XP USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE /ADESSO/V_HMV_XP-DEXBASICPROC TO
/ADESSO/HMV_XPRO-DEXBASICPROC .
MOVE /ADESSO/V_HMV_XP-DATETO TO
/ADESSO/HMV_XPRO-DATETO .
MOVE SY-MANDT TO
/ADESSO/HMV_XPRO-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = '/ADESSO/HMV_XPRO'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN /ADESSO/HMV_XPRO TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING '/ADESSO/HMV_XPRO'
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
