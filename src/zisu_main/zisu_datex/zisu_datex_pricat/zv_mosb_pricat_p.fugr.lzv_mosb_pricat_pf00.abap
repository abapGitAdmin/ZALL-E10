*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 03.01.2018 at 11:07:30
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_MOSB_PRICAT_P................................*
FORM GET_DATA_ZV_MOSB_PRICAT_P.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZMOSB_PRICE WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MOSB_PRICAT_P .
ZV_MOSB_PRICAT_P-MANDT =
ZMOSB_PRICE-MANDT .
ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID =
ZMOSB_PRICE-PRICE_CATALOGUE_ID .
ZV_MOSB_PRICAT_P-PRICE_VERSION =
ZMOSB_PRICE-PRICE_VERSION .
ZV_MOSB_PRICAT_P-PRICE_CLASS =
ZMOSB_PRICE-PRICE_CLASS .
ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD =
ZMOSB_PRICE-PRICE_CLASS_ADD .
ZV_MOSB_PRICAT_P-PRICE_CURR =
ZMOSB_PRICE-PRICE_CURR .
ZV_MOSB_PRICAT_P-PRICE =
ZMOSB_PRICE-PRICE .
<VIM_TOTAL_STRUC> = ZV_MOSB_PRICAT_P.
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
FORM DB_UPD_ZV_MOSB_PRICAT_P .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MOSB_PRICAT_P.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MOSB_PRICAT_P-ST_DELETE EQ GELOESCHT.
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
  SELECT SINGLE FOR UPDATE * FROM ZMOSB_PRICE WHERE
  PRICE_CATALOGUE_ID = ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID AND
  PRICE_VERSION = ZV_MOSB_PRICAT_P-PRICE_VERSION AND
  PRICE_CLASS = ZV_MOSB_PRICAT_P-PRICE_CLASS AND
  PRICE_CLASS_ADD = ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD AND
  PRICE_CURR = ZV_MOSB_PRICAT_P-PRICE_CURR .
    IF SY-SUBRC = 0.
    DELETE ZMOSB_PRICE .
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
  SELECT SINGLE FOR UPDATE * FROM ZMOSB_PRICE WHERE
  PRICE_CATALOGUE_ID = ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID AND
  PRICE_VERSION = ZV_MOSB_PRICAT_P-PRICE_VERSION AND
  PRICE_CLASS = ZV_MOSB_PRICAT_P-PRICE_CLASS AND
  PRICE_CLASS_ADD = ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD AND
  PRICE_CURR = ZV_MOSB_PRICAT_P-PRICE_CURR .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZMOSB_PRICE.
    ENDIF.
ZMOSB_PRICE-MANDT =
ZV_MOSB_PRICAT_P-MANDT .
ZMOSB_PRICE-PRICE_CATALOGUE_ID =
ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID .
ZMOSB_PRICE-PRICE_VERSION =
ZV_MOSB_PRICAT_P-PRICE_VERSION .
ZMOSB_PRICE-PRICE_CLASS =
ZV_MOSB_PRICAT_P-PRICE_CLASS .
ZMOSB_PRICE-PRICE_CLASS_ADD =
ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD .
ZMOSB_PRICE-PRICE_CURR =
ZV_MOSB_PRICAT_P-PRICE_CURR .
ZMOSB_PRICE-PRICE =
ZV_MOSB_PRICAT_P-PRICE .
    IF SY-SUBRC = 0.
    UPDATE ZMOSB_PRICE .
    ELSE.
    INSERT ZMOSB_PRICE .
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
CLEAR: STATUS_ZV_MOSB_PRICAT_P-UPD_FLAG,
STATUS_ZV_MOSB_PRICAT_P-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MOSB_PRICAT_P.
  SELECT SINGLE * FROM ZMOSB_PRICE WHERE
PRICE_CATALOGUE_ID = ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID AND
PRICE_VERSION = ZV_MOSB_PRICAT_P-PRICE_VERSION AND
PRICE_CLASS = ZV_MOSB_PRICAT_P-PRICE_CLASS AND
PRICE_CLASS_ADD = ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD AND
PRICE_CURR = ZV_MOSB_PRICAT_P-PRICE_CURR .
ZV_MOSB_PRICAT_P-MANDT =
ZMOSB_PRICE-MANDT .
ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID =
ZMOSB_PRICE-PRICE_CATALOGUE_ID .
ZV_MOSB_PRICAT_P-PRICE_VERSION =
ZMOSB_PRICE-PRICE_VERSION .
ZV_MOSB_PRICAT_P-PRICE_CLASS =
ZMOSB_PRICE-PRICE_CLASS .
ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD =
ZMOSB_PRICE-PRICE_CLASS_ADD .
ZV_MOSB_PRICAT_P-PRICE_CURR =
ZMOSB_PRICE-PRICE_CURR .
ZV_MOSB_PRICAT_P-PRICE =
ZMOSB_PRICE-PRICE .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MOSB_PRICAT_P USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MOSB_PRICAT_P-PRICE_CATALOGUE_ID TO
ZMOSB_PRICE-PRICE_CATALOGUE_ID .
MOVE ZV_MOSB_PRICAT_P-PRICE_VERSION TO
ZMOSB_PRICE-PRICE_VERSION .
MOVE ZV_MOSB_PRICAT_P-PRICE_CLASS TO
ZMOSB_PRICE-PRICE_CLASS .
MOVE ZV_MOSB_PRICAT_P-PRICE_CLASS_ADD TO
ZMOSB_PRICE-PRICE_CLASS_ADD .
MOVE ZV_MOSB_PRICAT_P-PRICE_CURR TO
ZMOSB_PRICE-PRICE_CURR .
MOVE ZV_MOSB_PRICAT_P-MANDT TO
ZMOSB_PRICE-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZMOSB_PRICE'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZMOSB_PRICE TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZMOSB_PRICE'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
