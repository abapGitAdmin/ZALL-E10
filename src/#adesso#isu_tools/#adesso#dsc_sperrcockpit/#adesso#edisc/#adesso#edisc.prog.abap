*&---------------------------------------------------------------------*
*& Report  /ADESSO/EDISC
*& Sperrcockpit
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

REPORT  /ADESSO/EDISC.

TYPE-POOLS: SLIS, ISU05.
TABLES: EDISCDOC, /ADESSO/SPT_EDI1, EFKKOP, FKKVKP,
        BUT020, "GP: Adressen
        ADRC,   "Adressen (Business Address Services)
        ADRPSTCDD.

TABLES /ADESSO/SPT_PRKZ.  "KZ für Ausdruck (Wiederinbetriebnahme / Sperrauftrag)

CONSTANTS: I_SAVE VALUE 'A'.

DATA: ITAB             LIKE STANDARD TABLE OF /ADESSO/SPT_EDI1,
      WA_ITAB          LIKE /ADESSO/SPT_EDI1,
      WA_SPT_EDI1  TYPE /ADESSO/SPT_EDI1,
      WA_EDISCDOC      TYPE EDISCDOC,
      IT_EDISCDOC      TYPE TABLE OF EDISCDOC,
      I_ANZAHL         TYPE I,
      I_SCHWELLE       TYPE I,
      I_PERCENTAGE     TYPE P,
      I_PRINTPARAMS    TYPE EPRINTPARAMS,
      IT_DD07          TYPE STANDARD TABLE OF DD07V,
      WA_DD07          TYPE DD07V,
      I_KZ_FEHLER      TYPE KENNZX,
      IS_VARIANT       TYPE DISVARIANT,
      IT_ERROR         TYPE STANDARD TABLE OF CHAR480,
      I_ERROR          TYPE CHAR480,
      IT_EDISCORDSTATE TYPE STANDARD TABLE OF EDISCORDSTATE,
      IS_ALLOW         TYPE RANGE OF EDISCORDSTATE-ORDSTATE WITH HEADER LINE,
      GD_FORM          TYPE FORMKEY.

DATA: LF_CUSTOMIZING TYPE /ADESSO/SPT_EDCU.
CONSTANTS: CO_SCHWELLE TYPE I VALUE 5.   " Schwelle für Fortschrittsanzeige

DATA: LV_FORM TYPE /ADESSO/SPT_EDCU-FORM_POST.

DATA:  LV_UCOMM TYPE SY-UCOMM.

DATA: GT_EVENTS     TYPE SLIS_T_EVENT.
DATA: GS_LISTHEADER TYPE SLIS_LISTHEADER.
DATA: GT_LISTHEADER TYPE SLIS_T_LISTHEADER.
DATA: BEGIN OF T_STATI OCCURS 0,
        STATUS     LIKE /ADESSO/SPT_EDI1-STATUS,
        STATUSTEXT LIKE /ADESSO/SPT_EDI1-STATUSTEXT,
        COUNT      LIKE SY-TABIX,
      END OF T_STATI.
FIELD-SYMBOLS: <ITAB> LIKE /ADESSO/SPT_EDI1.

SELECTION-SCREEN BEGIN OF BLOCK S1 WITH FRAME TITLE TEXT-S01.
SELECT-OPTIONS: S_DISCNO FOR EDISCDOC-DISCNO,
                S_STATUS FOR EDISCDOC-STATUS,
                S_DISCPR FOR EDISCDOC-DISCPROCV,
                S_MAHNV  FOR FKKVKP-MAHNV,
                S_DATUM  FOR EDISCDOC-ERDAT,
                S_NAME   FOR EDISCDOC-ERNAM.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS: S_GPART FOR /ADESSO/SPT_EDI1-GPART,
                S_VKONT FOR /ADESSO/SPT_EDI1-VKONT,
                S_BUKRS FOR /ADESSO/SPT_EDI1-BUKRS.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK S2 WITH FRAME TITLE TEXT-S02.
SELECT-OPTIONS: S_PLZ  FOR ADRPSTCDD-POST_CODE.
SELECTION-SCREEN END OF BLOCK S2.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK S3 WITH FRAME TITLE TEXT-S03.
SELECT-OPTIONS: S_PLZ_K FOR FKKVKP-REGIOGR_CA_B.
SELECTION-SCREEN END OF BLOCK S3.


SELECTION-SCREEN SKIP 1.
PARAMETERS:     P_OP     TYPE KENNZX AS CHECKBOX   DEFAULT 'X'.
SELECT-OPTIONS: S_LIMIT  FOR /ADESSO/SPT_EDI1-SUM_OP NO-EXTENSION.
SELECTION-SCREEN SKIP 1.


SELECTION-SCREEN SKIP 1.

PARAMETERS:
*                p_reorg  TYPE kennzx,
                P_VARIAN TYPE SLIS_VARI.
PARAMETERS: PA_STATI AS CHECKBOX.
*Max.Wert offene Posten zum Abschließen Sperrbelege -->
PARAMETERS: P_SCHWEL TYPE /ADESSO/SPT_ESUMOI.
*Max.Wert offene Posten zum Abschließen Sperrbelege <--

SELECTION-SCREEN END OF BLOCK S1.

INITIALIZATION.
  S_STATUS-SIGN   = 'I'.
  S_STATUS-OPTION = 'BT'.
  S_STATUS-LOW    = '00'.
  S_STATUS-HIGH   = '30'.
  APPEND S_STATUS.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'SC1'.
      SCREEN-INTENSIFIED = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARIAN.
  PERFORM F4_REPORT_VARIANT.


START-OF-SELECTION.
  PERFORM INIT.

  CLEAR I_KZ_FEHLER.

* alle aktuellen Sperrbelege lesen
  SELECT * FROM EDISCDOC INTO TABLE IT_EDISCDOC
    WHERE DISCNO    IN S_DISCNO
      AND STATUS    IN S_STATUS
      AND DISCPROCV IN S_DISCPR
      AND ERDAT     IN S_DATUM
      AND ERNAM     IN S_NAME.

  DESCRIBE TABLE IT_EDISCDOC LINES I_ANZAHL.
  CLEAR: I_SCHWELLE,
         I_PERCENTAGE.
  I_SCHWELLE = CO_SCHWELLE.

  LOOP AT IT_EDISCDOC INTO WA_EDISCDOC.
    CLEAR WA_ITAB.

    SELECT SINGLE * FROM /ADESSO/SPT_EDI1 INTO WA_ITAB
        WHERE DISCNO EQ WA_EDISCDOC-DISCNO.

    IF SY-SUBRC EQ 0
      AND SY-BATCH IS INITIAL.
* Sperrbeleg bekannt, daher hier nur Aktualisierung von Status u. Änderungsdatum
* (alle anderen Daten (bis auf offene/fällige Posten) bleiben "statisch )
      IF WA_EDISCDOC-AEDAT NE WA_ITAB-AEDAT
        OR WA_EDISCDOC-STATUS NE WA_ITAB-STATUS.
*  hier feststellen, ob ggf. weitere Änderungen zu Aktualisieren sind
        WA_ITAB-AEDAT  = WA_EDISCDOC-AEDAT.
        WA_ITAB-STATUS = WA_EDISCDOC-STATUS.
      ENDIF.
      PERFORM VKONT_LESEN CHANGING WA_ITAB. "
      PERFORM FORDERUNGEN_LESEN CHANGING WA_ITAB.
      PERFORM SET_ICON_STATUS   CHANGING WA_ITAB.
      PERFORM SET_LANGTEXTE     CHANGING WA_ITAB.
      PERFORM EVER_LESEN        CHANGING WA_ITAB.
      PERFORM EANLH_LESEN       CHANGING WA_ITAB.
      PERFORM LESEN_ZEDISC_PRINT_KZ  CHANGING WA_ITAB.
      PERFORM LESEN_NOTIZ            CHANGING WA_ITAB.
    ELSE.
* Sperrbeleg unbekannt oder Batch-Lauf, daher kompletter Aufbau der Daten
      WA_ITAB-DISCNO = WA_EDISCDOC-DISCNO.
      PERFORM READ_DISCDOC CHANGING WA_ITAB.
    ENDIF.

    APPEND WA_ITAB TO ITAB.

    PERFORM INDICATOR USING SY-TABIX.
  ENDLOOP.

* Daten in DB für den beschleunigten Zugriff zwischenspeichern
  CLEAR WA_ITAB.
  MODIFY ITAB FROM WA_ITAB TRANSPORTING MARK ERROR WHERE MANDT EQ SY-MANDT.
  MODIFY /ADESSO/SPT_EDI1 FROM TABLE ITAB.


* Nur Sperrbelege ausgeben, die über der Betragsgrenze liegen
  DELETE ITAB WHERE SUM_OP NOT IN S_LIMIT AND SUM_OP GE 0.
  DELETE ITAB WHERE GPART NOT IN S_GPART.
  DELETE ITAB WHERE VKONT NOT IN S_VKONT.
  DELETE ITAB WHERE ( BUKRS NOT IN S_BUKRS AND BUKRS NE SPACE ).
  DELETE ITAB WHERE POST_CODE1 NOT IN S_PLZ.
  DELETE ITAB WHERE MAHNV NOT IN S_MAHNV.
  DELETE ITAB WHERE REGIOGR_CA_B NOT IN S_PLZ_K.

* ALV-Tabelle ausgeben
  IF SY-BATCH IS INITIAL.
    PERFORM ERROR_MESSAGE.
    SORT ITAB BY DISCNO ASCENDING.
    PERFORM SET_STATISTIK.
    PERFORM AUSGABE. " Ausgabe der Liste Tabelle /ADESSO/SPT_EDI1
  ENDIF.

END-OF-SELECTION.
* Daten in DB für den beschleunigten Zugriff zwischenspeichern
* (Aufruf hier nochmal, um im Dialog geänderte Daten zu sichern)
  CLEAR WA_ITAB.
  MODIFY ITAB FROM WA_ITAB TRANSPORTING MARK ERROR WHERE MANDT EQ SY-MANDT.
  MODIFY /ADESSO/SPT_EDI1 FROM TABLE ITAB.

* Tabelle /ADESSO/SPT_EDI1 reorganisieren (alt: manuell auf Selektionsbildschirm einstellen - neu: automatisch im Batchlauf)
*  IF NOT p_reorg IS INITIAL.
  IF NOT SY-BATCH IS INITIAL.
    PERFORM REORG_SPT_EDI1.
  ENDIF.

  LOOP AT IT_ERROR INTO I_ERROR.
    WRITE / I_ERROR.
  ENDLOOP.



************************************************************************************************************************************************
************************************************************************************************************************************************
* ab hier FORM-Routinen
************************************************************************************************************************************************
************************************************************************************************************************************************

FORM INIT.
  PERFORM READ_CUSTOMIZING.
  PERFORM READ_EDISCORDSTATE.
* Domänen-Texte lesen
  PERFORM LANGTEXTE_LESEN USING 'DISCREASON' 'DCNREASTXT'.
  PERFORM LANGTEXTE_LESEN USING 'EDCDOCSTAT' 'STATUSTEXT'.
ENDFORM.                    "init

*&---------------------------------------------------------------------*
*&      Form  read_EDISCORDSTATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_EDISCORDSTATE.
  DATA: WA_EDISCORDSTATE TYPE EDISCORDSTATE.
  SELECT * FROM EDISCORDSTATE INTO TABLE IT_EDISCORDSTATE.

* alle Status für erfolgreiche Sperraktionen ermitteln
  LOOP AT IT_EDISCORDSTATE INTO WA_EDISCORDSTATE
    WHERE OBJALLOW NE SPACE.
    IS_ALLOW-SIGN = 'I'.
    IS_ALLOW-OPTION = 'EQ'.
    IS_ALLOW-LOW = WA_EDISCORDSTATE-ORDSTATE.
    APPEND IS_ALLOW.
  ENDLOOP.

ENDFORM.                    "read_EDISCORDSTATE

*&---------------------------------------------------------------------*
*&      Form  read_customizing
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_CUSTOMIZING.

  SELECT SINGLE * FROM /ADESSO/SPT_EDCU INTO LF_CUSTOMIZING.

ENDFORM.                    "read_customizing

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN 'REFRESH'.
      PERFORM UCOMM_REFRESH CHANGING RS_SELFIELD.
    WHEN 'FPL9'.
      PERFORM UCOMM_FPL9 USING RS_SELFIELD.
    WHEN 'EDIT'.
      PERFORM UCOMM_EDIT CHANGING RS_SELFIELD.
    WHEN 'COMPLETE'.
      PERFORM UCOMM_COMPLETE CHANGING RS_SELFIELD.
    WHEN 'POST'.
      LV_UCOMM = 'POST'.
      PERFORM UCOMM_POST CHANGING RS_SELFIELD.
    WHEN 'ORDER'.
      LV_UCOMM = 'ORDER'.
      PERFORM UCOMM_ORDER CHANGING RS_SELFIELD.
    WHEN 'ORDER_NETZ'.
      PERFORM UCOMM_ORDER_NETZ CHANGING RS_SELFIELD.
    WHEN 'CLERK'.
      PERFORM UCOMM_CLERK CHANGING RS_SELFIELD.
*>>> UH 21112012
    WHEN 'CIC'.
      READ TABLE ITAB INTO WA_ITAB INDEX RS_SELFIELD-TABINDEX.
      PERFORM UCOMM_CIC.
    WHEN 'CH_INSTLN'.
      READ TABLE ITAB INTO WA_ITAB INDEX RS_SELFIELD-TABINDEX.
      PERFORM UCOMM_CH_INSTLN.
*<<< UH 21112012
    WHEN OTHERS.
* Hotspot oder Doppelklick
      CASE  RS_SELFIELD-FIELDNAME.
        WHEN 'ICON'.
          READ TABLE ITAB INTO WA_ITAB INDEX RS_SELFIELD-TABINDEX.
          PERFORM DISCDOC_CHANGE USING RS_SELFIELD
                                       WA_ITAB.
        WHEN 'DISCNO'.
          PERFORM DISPLAY_DISCNO CHANGING RS_SELFIELD WA_ITAB.
        WHEN 'GPART'.
          PERFORM DISPLAY_GPART USING RS_SELFIELD.
        WHEN 'VKONT'.
          PERFORM DISPLAY_VKONT USING RS_SELFIELD.
        WHEN 'VERTRAG'.
          PERFORM DISPLAY_VERTRAG USING RS_SELFIELD.
        WHEN 'ANLAGE'.
          PERFORM DISPLAY_ANLAGE USING RS_SELFIELD.
        WHEN 'GERAET'.
          PERFORM DISPLAY_GERAET USING RS_SELFIELD.
        WHEN 'VSTELLE'.
          PERFORM DISPLAY_VSTELLE USING RS_SELFIELD.
        WHEN OTHERS.
      ENDCASE.
  ENDCASE.

  PERFORM ERROR_MESSAGE.
ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  read_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM READ_DISCDOC CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA: Y_OBJ          TYPE ISU05_DISCDOC_INTERNAL,
        WA_EKUN        TYPE EKUN,
        WA_FKKVKP      TYPE FKKVKP,
        WA_EVER        TYPE EVER,
        WA_EANL        TYPE V_EANL,
        WA_EASTL       TYPE EASTL,
        WA_EGER        TYPE V_EGER,
        I_KZ_ABSCHLUSS TYPE KENNZX,
        WA_EDISCACT    TYPE EDISCACT.

  CLEAR: Y_OBJ,
        WA_EKUN,
        WA_FKKVKP,
        WA_EVER,
        WA_EANL,
        WA_EASTL,
        WA_EGER,
        I_KZ_ABSCHLUSS.

  PERFORM OPEN_DISCDOC CHANGING I_SPT_EDI1
                                Y_OBJ.

* Sperrbeleg abschließen?
  PERFORM CHECK_EDISCDOC CHANGING Y_OBJ
                                  I_SPT_EDI1
                                  I_KZ_ABSCHLUSS.

  IF NOT I_KZ_ABSCHLUSS IS INITIAL
    AND NOT LF_CUSTOMIZING-COMPL IS INITIAL.
    PERFORM EDIT_DISCDOC USING I_SPT_EDI1
                               '99'.

    I_SPT_EDI1-STATUS = '99'.
* komplettes Nachlesen des Sperrbeleg-Umfeldes sollte nicht nötig sein, da nur Änderung des Status
    EXIT.
  ENDIF.

  READ TABLE Y_OBJ-DENV-IEKUN   INDEX 1 INTO WA_EKUN.
  READ TABLE Y_OBJ-DENV-IFKKVKP INDEX 1 INTO WA_FKKVKP.
  READ TABLE Y_OBJ-DENV-IEVER   INDEX 1 INTO WA_EVER.
  READ TABLE Y_OBJ-DENV-IEANL   INDEX 1 INTO WA_EANL.
  READ TABLE Y_OBJ-DENV-IEASTL  INDEX 1 INTO WA_EASTL.
  READ TABLE Y_OBJ-DENV-IEGER   INDEX 1 INTO WA_EGER.

  MOVE-CORRESPONDING WA_EASTL  TO I_SPT_EDI1.
  MOVE-CORRESPONDING WA_EGER   TO I_SPT_EDI1.
  MOVE-CORRESPONDING WA_EKUN   TO I_SPT_EDI1.
  MOVE-CORRESPONDING WA_FKKVKP TO I_SPT_EDI1.
  MOVE-CORRESPONDING WA_EVER   TO I_SPT_EDI1.
  MOVE-CORRESPONDING WA_EANL   TO I_SPT_EDI1.


  MOVE-CORRESPONDING Y_OBJ-EDISCDOC TO I_SPT_EDI1.
* aktuellste Aktion merken
  SORT Y_OBJ-EDISCACT BY DISCACT DESCENDING.
  READ TABLE Y_OBJ-EDISCACT INTO WA_EDISCACT INDEX 1.
  I_SPT_EDI1-DISCACT = WA_EDISCACT-DISCACT.
  I_SPT_EDI1-ACTDATE = WA_EDISCACT-ACTDATE.
  I_SPT_EDI1-ACTTIME = WA_EDISCACT-ACTTIME.

  PERFORM SET_NAME_GPART      CHANGING I_SPT_EDI1.
  PERFORM SET_ADRESSE_VSTELLE CHANGING I_SPT_EDI1.
  PERFORM SET_ICON_STATUS     CHANGING I_SPT_EDI1.
  PERFORM SET_SPERRDATUM      CHANGING I_SPT_EDI1 Y_OBJ.
  PERFORM FORDERUNGEN_LESEN   CHANGING I_SPT_EDI1.
  PERFORM WVDATUM_ERMITTELN   CHANGING I_SPT_EDI1 Y_OBJ.
  PERFORM SET_LANGTEXTE       CHANGING I_SPT_EDI1.
  PERFORM VKONT_LESEN CHANGING WA_ITAB.

  PERFORM EVER_LESEN        CHANGING I_SPT_EDI1.
  PERFORM EANLH_LESEN       CHANGING I_SPT_EDI1.

  PERFORM LESEN_ZEDISC_PRINT_KZ  CHANGING I_SPT_EDI1.
  PERFORM LESEN_NOTIZ            CHANGING I_SPT_EDI1.
*  PERFORM fkkvkp_lesen      CHANGING i_spt_edi1. "wa_itab.


ENDFORM.                    "read_discdoc

*&---------------------------------------------------------------------*
*&      Form  ausgabe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM AUSGABE.
  DATA: H_TITLE     TYPE LVC_TITLE,
        IS_LAYOUT   TYPE   SLIS_LAYOUT_ALV,
        IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
        WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.



  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = I_PERCENTAGE
      TEXT       = 'bereite Ausgabe vor...'
    EXCEPTIONS
      OTHERS     = 1.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = '/ADESSO/SPT_EDI1'
      I_BYPASSING_BUFFER     = 'X'
      I_BUFFER_ACTIVE        = ''
    CHANGING
      CT_FIELDCAT            = IT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.
  IF IT_FIELDCAT IS INITIAL.
    EXIT.
  ENDIF.

  WRITE SY-TITLE TO H_TITLE.
  IS_LAYOUT-ZEBRA  = 'X'.
  IS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  IS_LAYOUT-CONFIRMATION_PROMPT = LF_CUSTOMIZING-PROMPT.
  IS_LAYOUT-BOX_FIELDNAME = 'MARK'.

* events definieren
  PERFORM SET_EVENTS.

  LOOP AT IT_FIELDCAT INTO WA_FIELDCAT.
    CLEAR WA_FIELDCAT-KEY.
    CASE WA_FIELDCAT-FIELDNAME.
      WHEN 'MARK'.
        WA_FIELDCAT-CHECKBOX = 'X'.
        WA_FIELDCAT-NO_OUT   = 'X'.
        WA_FIELDCAT-TECH     = 'X'.
        WA_FIELDCAT-EDIT     = 'X'.
      WHEN 'ICON'.
        WA_FIELDCAT-ICON = 'X'.
        WA_FIELDCAT-HOTSPOT = 'X'.
        WA_FIELDCAT-SELTEXT_L = 'Status'.
        WA_FIELDCAT-SELTEXT_M = 'Status'.
        WA_FIELDCAT-SELTEXT_S = 'Status'.
        WA_FIELDCAT-REPTEXT_DDIC = 'Status'.
      WHEN 'DISCNO'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'VKONT'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'GPART'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'VERTRAG'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'ANLAGE'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'GERAET'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'VSTELLE'.
        WA_FIELDCAT-HOTSPOT = 'X'.
      WHEN 'ABWRH'.
        WA_FIELDCAT-NO_OUT = 'X'.
      WHEN 'ABWMA'.
        WA_FIELDCAT-NO_OUT = 'X'.
      WHEN OTHERS.
    ENDCASE.

    MODIFY IT_FIELDCAT FROM WA_FIELDCAT.
  ENDLOOP.

  IS_VARIANT-VARIANT = P_VARIAN.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_CALLBACK_PF_STATUS_SET = 'SET_STATUS'
      I_GRID_TITLE             = H_TITLE
      IS_LAYOUT                = IS_LAYOUT
      IT_FIELDCAT              = IT_FIELDCAT
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      I_SAVE                   = I_SAVE
      IS_VARIANT               = IS_VARIANT
      IT_EVENTS                = GT_EVENTS
*     i_structure_name         =
    TABLES
      T_OUTTAB                 = ITAB.

  CLEAR WA_ITAB.
  MODIFY ITAB FROM WA_ITAB TRANSPORTING MARK ERROR WHERE MANDT EQ SY-MANDT.


  IF SY-SUBRC NE 0.
    EXIT.
  ENDIF.
ENDFORM.                    "ausgabe

*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS LF_CUSTOMIZING-PFKEY EXCLUDING RT_EXTAB.
ENDFORM.                    "set_status

*&---------------------------------------------------------------------*
*&      Form  status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INDICATOR USING TABIX TYPE SY-TABIX.
* Userparameter "SIN" auf "0"?

  CHECK SY-BATCH IS INITIAL.
  I_PERCENTAGE = ( TABIX / I_ANZAHL ) * 100.

  IF I_PERCENTAGE > I_SCHWELLE.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = I_SCHWELLE
        TEXT       = 'lese Sperrbelege...'
      EXCEPTIONS
        OTHERS     = 1.
    I_SCHWELLE = I_SCHWELLE + CO_SCHWELLE.
  ENDIF.
ENDFORM.                    "status

*&---------------------------------------------------------------------*
*&      Form  langtexte_lesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LANGTEXTE_LESEN USING I_DOMNAME  TYPE DD07L-DOMNAME
                           I_FELDNAME TYPE CHAR10.
* Langtexte ausgeben
  DATA: IT_DD07V     TYPE STANDARD TABLE OF DD07V,
        I_DCNREASTXT LIKE EDISCDOCS-REASONTEXT.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME        = I_DOMNAME
      TEXT           = 'X'
      LANGU          = SY-LANGU
    TABLES
      DD07V_TAB      = IT_DD07V
    EXCEPTIONS
      WRONG_TEXTFLAG = 1
      OTHERS         = 2.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ELSE.
    APPEND LINES OF IT_DD07V TO IT_DD07.
  ENDIF.
ENDFORM.                    "langtexte_lesen

*&---------------------------------------------------------------------*
*&      Form  sperrbeleg_posten_lesen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->X_EDISCDOC text
*      -->Y_TEXT     text
*----------------------------------------------------------------------*
FORM FORDERUNGEN_LESEN CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA: IT_MAHNOP TYPE STANDARD TABLE OF TEMA01 WITH HEADER LINE.
  CHECK NOT I_SPT_EDI1-VKONT IS INITIAL.

  CHECK NOT P_OP IS INITIAL.

* Offene und sperrrelevante Posten lesen
  CALL FUNCTION 'ISU_DB_GET_DUE_AND_DISCREL_POS'
    EXPORTING
      X_VKONT             = I_SPT_EDI1-VKONT
    IMPORTING
      Y_SUMOI             = I_SPT_EDI1-SUM_OP
      Y_SUMDI             = I_SPT_EDI1-SUM_GP
    TABLES
      T_MAHNOP            = IT_MAHNOP
    EXCEPTIONS
      NOT_FOUND           = 0  "Fehler akzeptiert !
      CONCURRENT_CLEARING = 2
      OTHERS              = 3.
  IF SY-SUBRC NE 0.
    PERFORM WRITE_ERROR USING '001'
                        CHANGING I_SPT_EDI1.
    EXIT.
  ENDIF.

  PERFORM DETERMINE_CREDIT_RATING CHANGING I_SPT_EDI1.

ENDFORM.                    "sperrbeleg_posten_lesen

*&---------------------------------------------------------------------*
*&      Form  wvdatum_ermitteln
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*      -->I_OBJ      text
*----------------------------------------------------------------------*
FORM WVDATUM_ERMITTELN CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                                I_OBJ TYPE ISU05_DISCDOC_INTERNAL.
  DATA: WA_EDISCACT TYPE EDISCACT.

* Wiedervorlagedatum = aktuellstes Freigabedatum (wg. möglicher Stornierungen) + Anzahl Werktage gem. Customizing

* aktuellste Sperraktion mit "Freigabe Sperrbeleg" ermitteln
  SORT I_OBJ-EDISCACT BY DISCACT DESCENDING.
  LOOP AT I_OBJ-EDISCACT INTO WA_EDISCACT
    WHERE DISCACTTYP EQ '05' .   " Freigabe Sperrbeleg
    EXIT.
  ENDLOOP.

  IF WA_EDISCACT-ACTDATE IS INITIAL.   "29.07.2014 B.Duda
    WA_EDISCACT-ACTDATE = SY-DATUM.
  ENDIF.

* Wiedervorlagedatum berechnen
  CALL FUNCTION 'WFCS_FCAL_DATE_GET_S'
    EXPORTING
      PI_DATE           = WA_EDISCACT-ACTDATE
      PI_OFFSET         = LF_CUSTOMIZING-WVFRIST
      PI_FCALID         = LF_CUSTOMIZING-FCALID
    CHANGING
      PE_DATE_TO        = I_SPT_EDI1-WVDATUM
    EXCEPTIONS
      ERROR_INTERFACE   = 1
      ERROR_BUFFER_READ = 2
      OTHERS            = 3.
  IF SY-SUBRC <> 0.
* bei fehlerhaftem Kalender Tage ohne Berücksichtigung von Feiertagen addieren
    I_SPT_EDI1-WVDATUM = WA_EDISCACT-ACTDATE + LF_CUSTOMIZING-WVFRIST.
  ENDIF.

ENDFORM.                    "wvdatum_ermitteln

*&---------------------------------------------------------------------*
*&      Form  set_langtexte
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM SET_LANGTEXTE CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
* Langtexte zuweisen
  PERFORM READ_DD07 USING 'EDCDOCSTAT' CHANGING I_SPT_EDI1-STATUS I_SPT_EDI1-STATUSTEXT.
  PERFORM READ_DD07 USING 'DISCREASON' CHANGING I_SPT_EDI1-DISCREASON I_SPT_EDI1-DCNREASTXT.
ENDFORM.                    "set_langtexte

*&---------------------------------------------------------------------*
*&      Form  read_dd07
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DOMNAME  text
*      -->I_DOMVALUE text
*      -->I_TEXT     text
*----------------------------------------------------------------------*
FORM READ_DD07 USING I_DOMNAME
               CHANGING I_DOMVALUE I_TEXT.
  READ TABLE IT_DD07 INTO WA_DD07
  WITH KEY DOMNAME = I_DOMNAME
           DOMVALUE_L = I_DOMVALUE.
  I_TEXT = WA_DD07-DDTEXT.
ENDFORM.                                                    "read_dd07

*&---------------------------------------------------------------------*
*&      Form  set_icon_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ICON_STATUS CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
* Icon inkl. Langtext generieren
  CASE I_SPT_EDI1-STATUS.
    WHEN '00'.
      PERFORM ICON_CREATE USING 'ICON_STATUS_REVERSE' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '01'.
      PERFORM ICON_CREATE USING 'ICON_STATUS_OPEN' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '10'.
      PERFORM ICON_CREATE USING 'ICON_STATUS_BOOKED' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '20'.
      PERFORM ICON_CREATE USING 'ICON_ORDER' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '21'.
      PERFORM ICON_CREATE USING 'ICON_DISCONNECT' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '22'.
      PERFORM ICON_CREATE USING 'ICON_CONNECT' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '30'.
      PERFORM ICON_CREATE USING 'ICON_RELEASE' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN '99'.
      PERFORM ICON_CREATE USING 'ICON_COMPLETE' I_SPT_EDI1-STATUSTEXT
                          CHANGING I_SPT_EDI1.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "set_icon_status

*&---------------------------------------------------------------------*
*&      Form  set_sperrdatum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM SET_SPERRDATUM CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                             Y_OBJ TYPE ISU05_DISCDOC_INTERNAL.
  DATA: WA_EDISCACT TYPE EDISCACT,
        I_ACTDATE   TYPE EDISCACT-ACTDATE.

  SORT Y_OBJ-EDISCACT BY DISCACT DESCENDING.    "aktuellste Sperraktion zuerst

  LOOP AT Y_OBJ-EDISCACT INTO WA_EDISCACT
    WHERE DISCACTTYP EQ '02'   " Sperrerfassung
    AND   DISCCANCELD EQ SPACE.
    I_ACTDATE = WA_EDISCACT-ACTDATE.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    IF WA_EDISCACT-ORDERACT IS INITIAL.
* Sperrung wurde ohne Sperrauftrag durchgeführt
      I_SPT_EDI1-ACTDATE = I_ACTDATE.
    ELSE.
* war die Rückmeldung eines Sperrauftrags erfolgreich?
*   - hierzu die beteiligte Sperraktion (= Sperrauftrag) lesen
      READ TABLE Y_OBJ-EDISCACT INTO WA_EDISCACT
            WITH KEY DISCACT = WA_EDISCACT-ORDERACT.
* nur bei erfolgreichen Sperrvorgängen das Sperrdatum übernehmen
      IF WA_EDISCACT-ORDSTATE IN IS_ALLOW.
        I_SPT_EDI1-ACTDATE = I_ACTDATE.
      ENDIF.
    ENDIF.
  ENDIF.      " IF sy-subrc EQ 0.
ENDFORM.                                                "set_sperrdatum

*&---------------------------------------------------------------------*
*&      Form  icon_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->NAME       text
*      -->INFO       text
*----------------------------------------------------------------------*
FORM ICON_CREATE USING NAME INFO
      CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME                  = NAME
      INFO                  = INFO
*     ADD_STDINF            = 'X'
    IMPORTING
      RESULT                = I_SPT_EDI1-ICON
    EXCEPTIONS
      ICON_NOT_FOUND        = 1
      OUTPUTFIELD_TOO_SHORT = 2
      OTHERS                = 3.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "icon_create

*&---------------------------------------------------------------------*
*&      Form  reorg_spt_edi1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REORG_SPT_EDI1.
  SELECT * FROM /ADESSO/SPT_EDI1.
    SELECT SINGLE * FROM EDISCDOC INTO WA_EDISCDOC
        WHERE DISCNO EQ /ADESSO/SPT_EDI1-DISCNO.
    IF WA_EDISCDOC-STATUS EQ '99'.
      DELETE /ADESSO/SPT_EDI1.
    ENDIF.
  ENDSELECT.
ENDFORM.                    "reorg_spt_edi1

*&---------------------------------------------------------------------*
*&      Form  ucomm_refresh
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_REFRESH CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.

  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL
    AND   NOT DISCNO IS INITIAL.
    PERFORM READ_DISCDOC CHANGING WA_ITAB.

    MODIFY ITAB FROM WA_ITAB.
  ENDLOOP.
  RS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "ucomm_refresh

*&---------------------------------------------------------------------*
*&      Form  ucomm_fpl9
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UCOMM_FPL9 USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: Y_DB_UPDATE LIKE  REGEN-DB_UPDATE,
        WA_FKKEPOSC TYPE FKKEPOSC,
        IT_SELHEAD  TYPE STANDARD TABLE OF FKKEPOSS1,
        WA_SELHEAD  TYPE FKKEPOSS1.
  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL.
*    AND   NOT vkont IS INITIAL.
    REFRESH IT_SELHEAD.
    WA_SELHEAD-GPART = WA_ITAB-GPART.
    WA_SELHEAD-VKONT = WA_ITAB-VKONT.

    GET PARAMETER ID '818' FIELD WA_FKKEPOSC-BALA_ROLE.   " Kontenstandsrolle
    GET PARAMETER ID '8LT' FIELD WA_FKKEPOSC-LSTYP.       " Listtyp für die Kontenstandanzeige
    GET PARAMETER ID '812' FIELD WA_FKKEPOSC-VARNR.       " Zeilenaufbau / Variante
    GET PARAMETER ID '8SO' FIELD WA_FKKEPOSC-SRVAR.       " Sortiervariante
    GET PARAMETER ID '815' FIELD WA_FKKEPOSC-FITAB.       " Startbild der Liste
*   GET PARAMETER ID  '???' field     wa_fkkeposc-svvar     = ''.                   " Saldenvariante

    APPEND WA_SELHEAD TO IT_SELHEAD.
    CALL FUNCTION 'FKK_LINE_ITEMS_WITH_SELECTIONS'
      EXPORTING
        I_FKKEPOSC              = WA_FKKEPOSC
      TABLES
        T_SELHEAD               = IT_SELHEAD
      EXCEPTIONS
        NO_ITEMS_FOUND          = 1
        INVALID_SELECTION       = 2
        MAXIMAL_NUMBER_OF_ITEMS = 3
        OTHERS                  = 4.
    IF SY-SUBRC EQ 1.
      MESSAGE S429(>4).
    ELSE.
* keine Fehlerausgabe nötig
    ENDIF.
  ENDLOOP.
ENDFORM.                                                    "ucomm_fpl9

*&---------------------------------------------------------------------*
*&      Form  ucomm_edit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_EDIT CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL
    AND   NOT DISCNO IS INITIAL.
    PERFORM DISCDOC_CHANGE USING RS_SELFIELD
                                 WA_ITAB.
    MODIFY ITAB FROM WA_ITAB.
    RS_SELFIELD-REFRESH = 'X'.
  ENDLOOP.
ENDFORM.                                                    "ucomm_edit

*&---------------------------------------------------------------------*
*&      Form  ucomm_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_COMPLETE CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL
    AND   NOT DISCNO IS INITIAL
    AND   ( STATUS EQ 0 OR STATUS EQ 1 OR STATUS EQ 10 OR STATUS EQ 30 ).
    PERFORM DISCDOC_COMPLETE USING RS_SELFIELD
                                 WA_ITAB.
    MODIFY ITAB FROM WA_ITAB.
    RS_SELFIELD-REFRESH = 'X'.
  ENDLOOP.
ENDFORM.                                                "ucomm_complete

*&---------------------------------------------------------------------*
*&      Form  discdoc_complete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*      -->i_spt_edi1    text
*----------------------------------------------------------------------*
FORM DISCDOC_COMPLETE USING RS_SELFIELD TYPE SLIS_SELFIELD
                            I_SPT_EDI1   TYPE /ADESSO/SPT_EDI1.
  DATA: H_AUTO      TYPE ISU05_DISCDOC_AUTO,
        Y_DB_UPDATE LIKE  REGEN-DB_UPDATE,
        I_TABIX     TYPE SY-TABIX.

  I_TABIX = SY-TABIX.

  H_AUTO-CONTR-USE-OKCODE = 'X'.
  H_AUTO-CONTR-OKCODE = 'DARKCOMPL'.

  CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
    EXPORTING
      X_DISCNO           = I_SPT_EDI1-DISCNO
      X_UPD_ONLINE       = 'X'
      X_NO_DIALOG        = 'X'
      X_AUTO             = H_AUTO
    IMPORTING
      Y_DB_UPDATE        = Y_DB_UPDATE
    EXCEPTIONS
      NOT_FOUND          = 1
      FOREIGN_LOCK       = 2
      NOT_AUTHORIZED     = 3
      INPUT_ERROR        = 4
      GENERAL_FAULT      = 5
      OBJECT_INV_DISCDOC = 6
      OTHERS             = 7.
  IF   SY-SUBRC NE 0.
    IF SY-SUBRC EQ 2.
      MESSAGE 'Fehler! Sperrbeleg gesperrt!' TYPE 'S'.
    ENDIF.
  ELSE.
    IF Y_DB_UPDATE NE SPACE.
      COMMIT WORK.
      PERFORM READ_DISCDOC CHANGING I_SPT_EDI1.
      MODIFY ITAB FROM I_SPT_EDI1 INDEX I_TABIX.
      RS_SELFIELD-REFRESH = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    "discdoc_complete


*&---------------------------------------------------------------------*
*&      Form  Discdoc_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*      -->WA_ITAB      text
*----------------------------------------------------------------------*
FORM DISCDOC_CHANGE  USING RS_SELFIELD TYPE SLIS_SELFIELD
                           I_SPT_EDI1   TYPE /ADESSO/SPT_EDI1.
  DATA: Y_DB_UPDATE LIKE  REGEN-DB_UPDATE,
        I_TABIX     TYPE SY-TABIX,
        LD_CHARGE   TYPE CHARGE_DC,
        LF_EDISCACT TYPE EDISCACT.

  I_TABIX = SY-TABIX.


  CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
    EXPORTING
      X_DISCNO     = I_SPT_EDI1-DISCNO
      X_UPD_ONLINE = 'X'
      X_NO_OTHER   = 'X'
    IMPORTING
      Y_DB_UPDATE  = Y_DB_UPDATE
    EXCEPTIONS
      OTHERS       = 1.
  IF   SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
    MESSAGE 'Fehler! Sperrbeleg gesperrt!' TYPE 'S'.
  ELSE.
    IF Y_DB_UPDATE NE SPACE.
      COMMIT WORK.
      PERFORM READ_DISCDOC CHANGING I_SPT_EDI1.
      MODIFY ITAB FROM I_SPT_EDI1 INDEX I_TABIX.
      RS_SELFIELD-REFRESH = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "Discdoc_change

*&---------------------------------------------------------------------*
*&      Form  ucomm_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_POST CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: I_OPBEL     TYPE FKKKO-OPBEL,
        I_BPCONTACT TYPE BCONT-BPCONTACT,
        I_DUMFRIST  TYPE DATUM.


  IF SY-MANDT = '021'.

    I_DUMFRIST = SY-DATUM - LF_CUSTOMIZING-DUMFRIST.

    PERFORM GET_CHARGE_POST CHANGING LF_CUSTOMIZING-CHARGE_POST.



* Vorabdurchlauf für Nachdruck von Belegen im Status 10
    LOOP AT ITAB INTO WA_ITAB
       WHERE NOT MARK IS INITIAL
       AND   NOT DISCNO IS INITIAL
       AND       STATUS EQ 10.
* Beleg drucken
      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_POST WA_ITAB.
    ENDLOOP.



    LOOP AT ITAB INTO WA_ITAB
      WHERE NOT MARK IS INITIAL
      AND   NOT DISCNO IS INITIAL
      AND       STATUS EQ 0           " nur noch nicht freigegebene Sperrbelege verarbeiten
      AND       ERDAT LE I_DUMFRIST.  " nur Belege, deren Sperrfrist abgelaufen ist

* Gebühr buchen
      PERFORM GEBUEHR_BUCHEN USING LF_CUSTOMIZING-CHARGE_POST CHANGING WA_ITAB
                                    I_OPBEL.
* Sperrbeleg freigeben
      PERFORM EDIT_DISCDOC USING WA_ITAB
                                 '10'.

* Beleg drucken
      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_POST WA_ITAB.

* Kontakt anlegen
      PERFORM KONTAKT_ANLEGEN USING LF_CUSTOMIZING-BPC_POST
                                    WA_ITAB
                              CHANGING I_BPCONTACT.

*  Kontakt und Belegnummer in "Freigabe-Aktion" schreiben
      PERFORM CHANGE_DISCDOC USING '05'   " Freigabe Sperrbeleg
                             CHANGING WA_ITAB
                                      I_OPBEL
                                      I_BPCONTACT.


      PERFORM READ_DISCDOC CHANGING WA_ITAB.

      MODIFY ITAB FROM WA_ITAB.

      RS_SELFIELD-REFRESH = 'X'.
    ENDLOOP.

  ELSEIF SY-MANDT = '721'.

    LOOP AT ITAB INTO WA_ITAB
                      WHERE NOT MARK IS INITIAL
                        AND NOT DISCNO IS INITIAL.
*                        AND status EQ 20.
* Beleg drucken
      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_POST WA_ITAB.
    ENDLOOP.

  ENDIF..
ENDFORM.                    "ucomm_post

*&---------------------------------------------------------------------*
*&      Form  ucomm_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_ORDER CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: I_BPCONTACT  TYPE BCONT-BPCONTACT,
        I_OPBEL      TYPE FKKKO-OPBEL,
        LT_DFKKLOCKS TYPE DFKKLOCKS_T.

  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL
    AND   NOT DISCNO IS INITIAL.

* existiert zum Vertragskonto eine aktive Mahnsperre?
      IF NOT WA_ITAB-VKONT IS INITIAL.
        REFRESH LT_DFKKLOCKS.
        CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
          EXPORTING
            IV_VKONT = WA_ITAB-VKONT
            IV_DATE  = SY-DATUM
          IMPORTING
            ET_LOCKS = LT_DFKKLOCKS.

        IF NOT LT_DFKKLOCKS[] IS INITIAL.
* VK mit Mahnsperre gefunden
          CONTINUE.
        ENDIF.
      ENDIF.


***********************
* D R U C K E N
***********************

*Erstdruck und Order
    " nur Belege, deren WV-Frist abgelaufen ist
    " 01 = neu
    " 10 = freigegeben

    IF ( WA_ITAB-STATUS EQ '01' OR WA_ITAB-STATUS EQ '10' ).

* Sperrauftrag erstellen
      PERFORM EDIT_DISCDOC USING WA_ITAB
                                 '20'.

* Gebühr buchen
      PERFORM GEBUEHR_BUCHEN USING LF_CUSTOMIZING-CHARGE_DCOR
                          CHANGING WA_ITAB
                                   I_OPBEL.


* Kontakt anlegen
      PERFORM KONTAKT_ANLEGEN USING LF_CUSTOMIZING-BPC_DCOR
                                    WA_ITAB
                           CHANGING I_BPCONTACT.

*  Kontakt und Belegnummer in ersten "Sperrauftrag" schreiben
      PERFORM CHANGE_DISCDOC USING '01'   " im 01 = Sperrauftrag ändern
                          CHANGING WA_ITAB
                                   I_OPBEL
                                   I_BPCONTACT.


* Beleg drucken
      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_DCOR WA_ITAB.

      PERFORM READ_DISCDOC CHANGING WA_ITAB.

      MODIFY ITAB FROM WA_ITAB.

      RS_SELFIELD-REFRESH = 'X'.


****************
*  STATUS > 10
****************

    ELSEIF WA_ITAB-STATUS >= '10'.
*Wiederholungsdruck
* Sperrbelegsaktion um 1 verringern (wird später wieder dazu addiert)
*temp
*      CALL FUNCTION 'POPUP_TO_CONFIRM'
*        EXPORTING
*          text_question         = 'Wiederholungsdruck noch nicht'
*          &
*          'implementiert'
*          text_button_1         = 'OK'(001)
**         ICON_BUTTON_1         = ' '
*          text_button_2         = ''(001)
*          default_button        = '1'
*          display_cancel_button = ''
*          popup_type            = 'ICON_MESSAGE_INFORMATION'.

      SUBTRACT 1 FROM WA_ITAB-DISCACT.

      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_DCOR WA_ITAB.
    ENDIF.

  ENDLOOP.
ENDFORM.                    "ucomm_order
*&---------------------------------------------------------------------*
*&      Form  ucomm_order_netz
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_ORDER_NETZ CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: I_BPCONTACT TYPE BCONT-BPCONTACT,
        I_OPBEL     TYPE FKKKO-OPBEL.



  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL
    AND   NOT DISCNO IS INITIAL
    AND   STATUS >= '20'.
    IF WA_ITAB-STATUS = '20'.
*Erstdruck und buchen wie immer
* Sperrbelegsaktion um 1 verringern (wird später wieder dazu addiert)
      SUBTRACT 1 FROM WA_ITAB-DISCACT.


* Gebühr buchen
      PERFORM GEBUEHR_BUCHEN USING LF_CUSTOMIZING-CHARGE_DCOR
                          CHANGING WA_ITAB
                                   I_OPBEL.


* Kontakt anlegen
      PERFORM KONTAKT_ANLEGEN USING LF_CUSTOMIZING-BPC_DCOR
                                    WA_ITAB
                           CHANGING I_BPCONTACT.

*  Kontakt und Belegnummer in ersten "Sperrauftrag" schreiben
      PERFORM CHANGE_DISCDOC USING '01'   " Sperrauftrag
                          CHANGING WA_ITAB
                                   I_OPBEL
                                   I_BPCONTACT.


* Beleg drucken
      PERFORM DRUCK CHANGING LF_CUSTOMIZING-FORM_DCOR WA_ITAB.

      PERFORM READ_DISCDOC CHANGING WA_ITAB.
      MODIFY ITAB FROM WA_ITAB.
      RS_SELFIELD-REFRESH = 'X'.
    ELSE.
*Wiederholungsdruck
* Sperrbelegsaktion um 1 verringern (wird in druck wieder dazu addiert)
*temp
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TEXT_QUESTION         = 'Wiederholungsdruck noch nicht'
                                  &
                                  'implementiert'
          TEXT_BUTTON_1         = 'OK'(001)
*         ICON_BUTTON_1         = ' '
          TEXT_BUTTON_2         = ''(001)
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = ''
          POPUP_TYPE            = 'ICON_MESSAGE_INFORMATION'.

*      SUBTRACT 1 FROM wa_itab-discact.
*      PERFORM druck CHANGING lf_customizing-form_dcor wa_itab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "ucomm_order_netz

*&---------------------------------------------------------------------*
*&      Form  ucomm_clerk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM UCOMM_CLERK CHANGING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: IT_SVAL      TYPE STANDARD TABLE OF SVAL,
        WA_SVAL      TYPE SVAL,
        I_RETURNCODE.

  WA_SVAL-TABNAME = 'USR02'.
  WA_SVAL-FIELDNAME = 'BNAME'.
*  MOVE sy-uname TO wa_sval-value.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Zuordnung aufheben zu können
*  wa_sval-comp_code = 'EQ'.
  APPEND WA_SVAL TO IT_SVAL.


  CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
    EXPORTING
      CHECK_EXISTENCE = ' '    " keine Existenzprüfung, damit auch Kürzel etc. eingetragen werden können
      POPUP_TITLE     = 'zuständigen Sachbearbeiter auswählen'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = I_RETURNCODE
    TABLES
      FIELDS          = IT_SVAL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  READ TABLE IT_SVAL INTO WA_SVAL INDEX 1.
  LOOP AT ITAB INTO WA_ITAB
    WHERE NOT MARK IS INITIAL.
    MOVE WA_SVAL-VALUE TO WA_ITAB-BNAME.
    MODIFY ITAB FROM WA_ITAB.
    RS_SELFIELD-REFRESH = 'X'.
  ENDLOOP.
ENDFORM.                    "ucomm_clerk

*&---------------------------------------------------------------------*
*&      Form  display_discno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_DISCNO CHANGING RS_SELFIELD  TYPE SLIS_SELFIELD
                             I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA: X_DISCNO    LIKE EDISCDOC-DISCNO,
        Y_DB_UPDATE LIKE  REGEN-DB_UPDATE,
        H_NUM12(12) TYPE N,
        I_TABIX     TYPE SY-TABIX.

  I_TABIX = SY-TABIX.

  H_NUM12 = RS_SELFIELD-VALUE.
  X_DISCNO = H_NUM12.
  CALL FUNCTION 'ISU_S_DISCDOC_DISPLAY'
    EXPORTING
      X_DISCNO    = X_DISCNO
      X_NO_CHANGE = 'X'
      X_NO_OTHER  = 'X'
    IMPORTING
      Y_DB_UPDATE = Y_DB_UPDATE
    EXCEPTIONS
      OTHERS      = 1.
  IF   SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ELSE.
    IF Y_DB_UPDATE NE SPACE.
      COMMIT WORK.
      PERFORM READ_DISCDOC CHANGING I_SPT_EDI1.
      MODIFY ITAB FROM I_SPT_EDI1 INDEX I_TABIX.
      RS_SELFIELD-REFRESH = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "display_discno

*&---------------------------------------------------------------------*
*&      Form  display_gpart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_GPART USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_PARTNER   LIKE  BUT000-PARTNER,
        H_NUM10(10) TYPE N.
  H_NUM10 = RS_SELFIELD-VALUE.
  X_PARTNER = H_NUM10.
  CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
    EXPORTING
      X_PARTNER   = X_PARTNER
      X_NO_CHANGE = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_gpart

*&---------------------------------------------------------------------*
*&      Form  display_vkont
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_VKONT USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_ACCOUNT LIKE  FKKVK-VKONT.
  X_ACCOUNT = RS_SELFIELD-VALUE.
  CALL FUNCTION 'ISU_S_ACCOUNT_DISPLAY'
    EXPORTING
      X_ACCOUNT   = X_ACCOUNT
      X_NO_CHANGE = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_vkont

*&---------------------------------------------------------------------*
*&      Form  display_vertrag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_VERTRAG USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_VERTRAG   LIKE  EVER-VERTRAG,
        H_NUM10(10) TYPE N.
  MOVE RS_SELFIELD-VALUE TO H_NUM10.
  X_VERTRAG = H_NUM10.
  CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
    EXPORTING
      X_VERTRAG   = X_VERTRAG
      X_NO_CHANGE = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_vertrag

*&---------------------------------------------------------------------*
*&      Form  display_anlage
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_ANLAGE USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_ANLAGE    LIKE  V_EANL-ANLAGE,
        H_NUM10(10) TYPE N.
  MOVE RS_SELFIELD-VALUE TO H_NUM10.
  X_ANLAGE = H_NUM10.
  CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
    EXPORTING
      X_ANLAGE    = X_ANLAGE
      X_KEYDATE   = SY-DATUM
      X_NO_CHANGE = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_anlage

*&---------------------------------------------------------------------*
*&      Form  display_geraet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_GERAET USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_GERAET    LIKE  V_EGER-GERAET,
        H_NUM18(18) TYPE N.
  H_NUM18 = RS_SELFIELD-VALUE.
  X_GERAET = H_NUM18.
  CALL FUNCTION 'ISU_S_EGER_DISPLAY'
    EXPORTING
      X_GERAET = X_GERAET
    EXCEPTIONS
      OTHERS   = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_geraet

*&---------------------------------------------------------------------*
*&      Form  display_vstelle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM DISPLAY_VSTELLE USING RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: X_VSTELLE   LIKE  EVBS-VSTELLE,
        H_NUM10(10) TYPE N.
  H_NUM10 = RS_SELFIELD-VALUE.
  X_VSTELLE = H_NUM10.
  CALL FUNCTION 'ISU_S_PREMISE_DISPLAY'
    EXPORTING
      X_VSTELLE   = X_VSTELLE
      X_NO_CHANGE = 'X'
    EXCEPTIONS
      OTHERS      = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.
ENDFORM.                    "display_geraet

*&---------------------------------------------------------------------*
*&      Form  gebuehr_buchen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GEBUEHR_BUCHEN USING I_CHARGE TYPE CHARGE_DC
                 CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                          I_OPBEL   TYPE FKKKO-OPBEL.
  DATA: XY_OBJ TYPE ISU05_DISCDOC_INTERNAL.

* Gebührenbuchung nur möglich bei Vorgabe Gebührenschema
  CHECK NOT I_CHARGE IS INITIAL.

  PERFORM OPEN_DISCDOC CHANGING I_SPT_EDI1
                                XY_OBJ.

* Gebühr nach Gebührenschema buchen
  CALL FUNCTION 'ISU_DISCDOC_SAVE_CHARGE'
    EXPORTING
      X_CHARGE                     = I_CHARGE
      X_VKONT                      = I_SPT_EDI1-VKONT
      X_CONTRACT                   = I_SPT_EDI1-VERTRAG
    CHANGING
      XY_OPBEL                     = I_OPBEL
      XY_OBJ                       = XY_OBJ
    EXCEPTIONS
      CHARGE_NOT_FOUND             = 1
      ERROR_CREATE_CHARGE_DOCUMENT = 2
      OTHERS                       = 3.
  IF SY-SUBRC NE 0.
    PERFORM WRITE_ERROR USING '005'
                        CHANGING I_SPT_EDI1.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    "gebuehr_buchen

*&---------------------------------------------------------------------*
*&      Form  get_charge_post
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LD_CHARGE  text
*----------------------------------------------------------------------*
FORM GET_CHARGE_POST CHANGING LD_CHARGE TYPE CHARGE_DC.

*  IF sy-mandt EQ '255'.
  IF SY-MANDT EQ '021'.    " Vetrieb  ?
    DATA: IT_SVAL      TYPE STANDARD TABLE OF SVAL,
          WA_SVAL      TYPE SVAL,
          I_RETURNCODE.
* Pop-Up zur Eingabe eines Gebührenschmema
    WA_SVAL-TABNAME = '/ADESSO/SPT_EDCU'.
    WA_SVAL-FIELDNAME = 'CHARGE_POST'.
    MOVE LD_CHARGE TO WA_SVAL-VALUE.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Gebührenbuchung zu unterbinden
    WA_SVAL-COMP_CODE = 'EQ'.
    APPEND WA_SVAL TO IT_SVAL.

    CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
      EXPORTING
        CHECK_EXISTENCE = 'X'
        POPUP_TITLE     = 'Wählen Sie ein Gebührenschema aus'
*       START_COLUMN    = '5'
*       START_ROW       = '5'
      IMPORTING
        RETURNCODE      = I_RETURNCODE
      TABLES
        FIELDS          = IT_SVAL
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    IF I_RETURNCODE EQ 'A'.
      MESSAGE 'Abbruch durch Benutzer' TYPE 'W'.
    ENDIF.

    CLEAR WA_SVAL.
    READ TABLE IT_SVAL INTO WA_SVAL INDEX 1.
    LD_CHARGE = WA_SVAL-VALUE.
  ENDIF.
ENDFORM.                    "get_charge_post

*&---------------------------------------------------------------------*
*&      Form  get_charge_edit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LD_CHARGE  text
*----------------------------------------------------------------------*
FORM GET_CHARGE_EDIT CHANGING LD_CHARGE TYPE CHARGE_DC.

  DATA: IT_SVAL      TYPE STANDARD TABLE OF SVAL,
        WA_SVAL      TYPE SVAL,
        I_RETURNCODE.
* Pop-Up zur Eingabe eines Gebührenschmema
  WA_SVAL-TABNAME = 'TFK047ET'.
  WA_SVAL-FIELDNAME = 'CHGID'.
  MOVE LD_CHARGE TO WA_SVAL-VALUE.
*  wa_sval-field_obl = 'X'.      " leeres Feld zulassen, um Gebührenbuchung zu unterbinden
*  wa_sval-comp_code = 'EQ'.
  APPEND WA_SVAL TO IT_SVAL.

  CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
    EXPORTING
*     check_existence = ''
      POPUP_TITLE     = 'Wählen Sie ein Gebührenschema aus'
*     START_COLUMN    = '5'
*     START_ROW       = '5'
    IMPORTING
      RETURNCODE      = I_RETURNCODE
    TABLES
      FIELDS          = IT_SVAL
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF I_RETURNCODE EQ 'A'.
    MESSAGE 'Abbruch durch Benutzer' TYPE 'W'.
  ENDIF.

  CLEAR WA_SVAL.
  READ TABLE IT_SVAL INTO WA_SVAL INDEX 1.
  LD_CHARGE = WA_SVAL-VALUE.

ENDFORM.                    "get_charge_edit

*&---------------------------------------------------------------------*
*&      Form  edit_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->wa_spt_edi1 text
*----------------------------------------------------------------------*
FORM EDIT_DISCDOC CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                           I_STATUS   TYPE EDCDOCSTAT.
  DATA: H_AUTO      TYPE ISU05_DISCDOC_AUTO,
        I_NO_DIALOG TYPE KENNZX,
        Y_OBJ       TYPE ISU05_DISCDOC_INTERNAL,
        I_ZAEHLER   TYPE SY-TABIX.

* sollte im Datenumfeld des Sperrbelegs nur ein Gerät zu sperren sein, Sperrauftrag "dunkel" im Hintergrund anlegen
  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      X_DISCNO = I_SPT_EDI1-DISCNO
      X_WMODE  = '1'
    IMPORTING
      Y_OBJ    = Y_OBJ
    EXCEPTIONS
      OTHERS   = 1.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DESCRIBE TABLE Y_OBJ-DENV-IEGER LINES I_ZAEHLER.

  CLEAR H_AUTO.
  H_AUTO-CONTR-USE-OKCODE = 'X'.

  CASE I_STATUS.
    WHEN '10'.  " Sperrbeleg freigeben
      H_AUTO-CONTR-OKCODE = 'DARKRELE'.
      I_NO_DIALOG = 'X'.
    WHEN '20'.
      CASE I_ZAEHLER.
        WHEN 0.
*          MESSAGE 'Fehler! Keine sperrbaren Objekte im Datenumfeld des Bezugsobjekts!' TYPE 'E'.
          MESSAGE E426(EH).
        WHEN 1.
          H_AUTO-CONTR-OKCODE = 'DARKDCOR'.
          H_AUTO-INTERFACE-DARKDCOR-X_ACTDATE   = SY-DATUM.
          I_NO_DIALOG = 'X'.
        WHEN OTHERS.
          H_AUTO-CONTR-OKCODE = 'DCOR'.
          CLEAR I_NO_DIALOG.
      ENDCASE.
    WHEN '99'.
* Abschluss Sperrbeleg
      H_AUTO-CONTR-OKCODE = 'DARKCOMPL'.
      I_NO_DIALOG = 'X'.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  DO I_ZAEHLER TIMES.
    CALL FUNCTION 'ISU_S_DISCDOC_CHANGE'
      EXPORTING
        X_DISCNO           = I_SPT_EDI1-DISCNO
        X_UPD_ONLINE       = 'X'
        X_NO_DIALOG        = I_NO_DIALOG
        X_AUTO             = H_AUTO
        X_SET_COMMIT_WORK  = 'X'
      EXCEPTIONS
        NOT_FOUND          = 1
        FOREIGN_LOCK       = 2
        NOT_AUTHORIZED     = 3
        INPUT_ERROR        = 4
        GENERAL_FAULT      = 5
        OBJECT_INV_DISCDOC = 6
        OTHERS             = 7.
    IF SY-SUBRC NE 0.
      IF SY-SUBRC = 3.
        PERFORM WRITE_ERROR USING '008' CHANGING I_SPT_EDI1.
      ELSEIF SY-SUBRC = 6.
        PERFORM WRITE_ERROR USING '009' CHANGING I_SPT_EDI1.
      ELSE.
        PERFORM WRITE_ERROR USING '006' CHANGING I_SPT_EDI1.
      ENDIF.
    ELSE.

      COMMIT WORK.

      IF NOT SY-INDEX EQ I_ZAEHLER AND I_STATUS EQ '20'.
        DATA: I_QUESTION TYPE TEXT80,
              Y_ANSWER.
        I_QUESTION = 'Möchten Sie einen weiteren Sperrauftrag zu Sperrbeleg &1 anlegen?'.
        REPLACE '&1' WITH I_SPT_EDI1-DISCNO INTO I_QUESTION.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = 'Sperrauftrag erstellen'
            TEXT_QUESTION         = I_QUESTION
            TEXT_BUTTON_1         = 'Ja'
            TEXT_BUTTON_2         = 'Nein'
            DEFAULT_BUTTON        = '1'
            DISPLAY_CANCEL_BUTTON = ' '
            START_COLUMN          = 25
            START_ROW             = 6
          IMPORTING
            ANSWER                = Y_ANSWER
          EXCEPTIONS
            OTHERS                = 1.
        IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.
          IF Y_ANSWER EQ 2.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDDO.

ENDFORM.                    "edit_discdoc

*&---------------------------------------------------------------------*
*&      Form  druck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_FORM     text
*----------------------------------------------------------------------*
FORM DRUCK CHANGING I_FORM         TYPE EPRINTPARAMS-FORMKEY
                    I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  DATA: ISEL1  LIKE EFG_RANGES OCCURS 0 WITH HEADER LINE,
        ISEL2  LIKE EFG_RANGES OCCURS 0 WITH HEADER LINE,
        ISEL5  LIKE EFG_RANGES OCCURS 0 WITH HEADER LINE,
        H_AUTO TYPE ISU05_DISCDOC_AUTO.

** Druckfunktionen nur möglich bei Formularvorgabe
  CHECK NOT I_FORM IS INITIAL.

*  IF i_form IS INITIAL.
*    i_form = 'Z*'.
*  ENDIF.

* Druckparameter bei Erstaufruf zum Formular versorgen
* Druckdialog vor jedem Druck aufrufen
  IF I_PRINTPARAMS-FORMKEY <> I_FORM.
    I_PRINTPARAMS-FORMKEY = I_FORM.

* nur Formulare der Klasse IS_U_CS_DISCONNECTION_ORDER zulassen
    I_PRINTPARAMS-FORMCLASS = 'IS_U_CS_DISCONNECTION_ORDER'.

    CALL FUNCTION 'EFG_GET_PRINT_PARAMETERS'
      EXPORTING
        X_PRINTPARAMS = I_PRINTPARAMS
        X_NO_FORMKEY  = ''
      IMPORTING
        Y_PRINTPARAMS = I_PRINTPARAMS
      EXCEPTIONS
        CANCELLED     = 1
        INPUT_ERROR   = 2
        FAILED        = 3
        OTHERS        = 4.
    IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
      CLEAR I_PRINTPARAMS.
      EXIT.
    ENDIF.
  ENDIF.

* Sperrbelegsaktion um 1 erhöhen
  IF LV_UCOMM <> 'POST'.         "neu Abfrage B.Duda 24.11.2014
    ADD 1 TO I_SPT_EDI1-DISCACT.
  ENDIF.


* Druck durchführen
  ISEL1-LOW = I_SPT_EDI1-DISCNO.
  APPEND ISEL1.
  ISEL2-LOW = I_SPT_EDI1-DISCACT.
  APPEND ISEL2.

* neu wegen der zudruckenden Seiten
  IF I_FORM = 'ZDEW_CS_MANINKAS'.
    CASE LV_UCOMM.
      WHEN 'POST'.
        ISEL5-LOW = '1'.
        APPEND ISEL5.
      WHEN 'ORDER'.
        ISEL5-LOW = '2'.
        APPEND ISEL5.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

  CALL FUNCTION 'EFG_PRINT'
    EXPORTING
      X_PRINTPARAMS       = I_PRINTPARAMS
      X_DIALOG            = ' '
    IMPORTING
      Y_PRINTPARAMS       = I_PRINTPARAMS
    TABLES
      XT_RANGES           = ISEL1
      XT_RANGES1          = ISEL2
      XT_RANGES5          = ISEL5
    EXCEPTIONS
      NOT_QUALIFIED       = 1
      FORMCLASS_NOT_FOUND = 2
      FORM_NOT_FOUND      = 3
      INTERNAL_ERROR      = 4
      FORMCLASS_INVALID   = 5
      PRINT_FAILED        = 6
      FORM_INVALID        = 7
      FUNC_INVALID        = 8
      CANCELLED           = 9
      NOT_AUTHORIZED      = 10
      OTHERS              = 11.
  IF SY-SUBRC NE 0.

    "B.Duda 18.07.2014
    IF I_SPT_EDI1-STATUS <> '22' AND    "WiB eingeleitet
       I_SPT_EDI1-STATUS <> '30'.       "WiB komplett durchgeführt

      PERFORM WRITE_ERROR USING '002'            " Fehler beim Druck
                          CHANGING I_SPT_EDI1.
    ENDIF.

  ENDIF.

* ausgewähltes Formular als temporäres "Customizing-Formular" übernehmen
  I_FORM = I_PRINTPARAMS-FORMKEY.


* neu Ticket SR-1422747 B.Duda 07.11.2014
  LV_FORM = I_FORM.
  PERFORM MODIFY_ZEDISC_PRINT_KZ CHANGING I_SPT_EDI1.


ENDFORM.                    "druck

*&---------------------------------------------------------------------*
*&      Form  name_gpart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM SET_NAME_GPART CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA: Y_EADRDAT TYPE EADRDAT.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      X_ADDRESS_TYPE             = 'B'
      X_PARTNER                  = I_SPT_EDI1-GPART
    IMPORTING
      Y_EADRDAT                  = Y_EADRDAT
    EXCEPTIONS
      NOT_FOUND                  = 1
      PARAMETER_ERROR            = 2
      OBJECT_NOT_GIVEN           = 3
      ADDRESS_INCONSISTENCY      = 4
      INSTALLATION_INCONSISTENCY = 5
      OTHERS                     = 6.
  IF SY-SUBRC <> 0.
* keine Fehlerausgabe notwendig
  ENDIF.

  I_SPT_EDI1-NAME1 = Y_EADRDAT-NAME1.
  I_SPT_EDI1-NAME2 = Y_EADRDAT-NAME2.
  I_SPT_EDI1-NAME3 = Y_EADRDAT-NAME3.
  I_SPT_EDI1-NAME4 = Y_EADRDAT-NAME4.

ENDFORM.                    "name_gpart

*&---------------------------------------------------------------------*
*&      Form  adresse_vstelle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->wa_spt_edi1 text
*----------------------------------------------------------------------*
FORM SET_ADRESSE_VSTELLE CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA:
*        y_addr_lines TYPE eadrln,
        Y_EADRDAT TYPE EADRDAT.
  IF NOT I_SPT_EDI1-ANLAGE IS INITIAL.
    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
      EXPORTING
        X_ADDRESS_TYPE = 'I'
        X_ANLAGE       = I_SPT_EDI1-ANLAGE
      IMPORTING
*       y_addr_lines   = y_addr_lines
        Y_EADRDAT      = Y_EADRDAT
      EXCEPTIONS
        OTHERS         = 1.
    IF SY-SUBRC NE 0.
      PERFORM WRITE_ERROR USING '003'
                          CHANGING I_SPT_EDI1.
    ELSE.
      I_SPT_EDI1-STREET = Y_EADRDAT-STREET.
      I_SPT_EDI1-HOUSE_NUM1 = Y_EADRDAT-HOUSE_NUM1.
      I_SPT_EDI1-POST_CODE1 = Y_EADRDAT-POST_CODE1.
      I_SPT_EDI1-CITY1 = Y_EADRDAT-CITY1.
      I_SPT_EDI1-CITY2 = Y_EADRDAT-CITY2.
    ENDIF.
  ENDIF.
ENDFORM.                    "adresse_vstelle

*&---------------------------------------------------------------------*
*&      Form  check_ediscdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_OBJ           text
*      -->,               text
*      -->I_KZ_ABSCHLUSS  text
*----------------------------------------------------------------------*
FORM CHECK_EDISCDOC CHANGING I_OBJ          TYPE ISU05_DISCDOC_INTERNAL
                             I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                             I_KZ_ABSCHLUSS TYPE KENNZX.
*SR-1311545 - Max.Wert offene Posten zum Abschließen Sperrbelege -->
  DATA LV_OP TYPE /ADESSO/SPT_ESUMOI.
* prüfen, ob Sperrgrund obsolet
* Offene und sperrrelevante Posten lesen
  CALL FUNCTION 'ISU_DB_GET_DUE_AND_DISCREL_POS'
    EXPORTING
      X_VKONT             = I_SPT_EDI1-VKONT
    IMPORTING
      Y_SUMOI             = LV_OP
    EXCEPTIONS
      NOT_FOUND           = 0  "Fehler akzeptiert !
      CONCURRENT_CLEARING = 2
      OTHERS              = 3.
  IF SY-SUBRC NE 0.
    PERFORM WRITE_ERROR USING '004'
                        CHANGING I_SPT_EDI1.
    EXIT.
  ENDIF.

  IF I_OBJ-EDISCDOC-DAT_OBSOLT LE SY-DATUM
    AND I_OBJ-EDISCDOC-DAT_OBSOLT NE '00000000'
    AND LV_OP <= P_SCHWEL.        "Neu max. Schwellwert der OP berücks.
    I_KZ_ABSCHLUSS = 'X'.
  ENDIF.
*SR-1311545 - Max.Wert offene Posten zum Abschließen Sperrbelege <--
ENDFORM.                    "check_ediscdoc

*&---------------------------------------------------------------------*
*&      Form  open_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_DISCNO   text
*      -->I_OBJ      text
*----------------------------------------------------------------------*
FORM OPEN_DISCDOC CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                           I_OBJ TYPE ISU05_DISCDOC_INTERNAL.
  CALL FUNCTION 'ISU_O_DISCDOC_OPEN_INTERNAL'
    EXPORTING
      X_DISCNO       = I_SPT_EDI1-DISCNO
      X_WMODE        = '1'
    IMPORTING
      Y_OBJ          = I_OBJ
    EXCEPTIONS
      NOT_FOUND      = 1
      NOT_AUTHORIZED = 2
      EXISTING       = 3
      FOREIGN_LOCK   = 4
      INVALID_KEY    = 5
      NUMBER_ERROR   = 6
      INPUT_ERROR    = 7
      SYSTEM_ERROR   = 8
      OTHERS         = 9.
  IF SY-SUBRC NE 0.
    PERFORM WRITE_ERROR USING '004'
                        CHANGING I_SPT_EDI1.
  ENDIF.
ENDFORM.                    "open_discdoc

*&---------------------------------------------------------------------*
*&      Form  determine_credit_rating
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM DETERMINE_CREDIT_RATING CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  IF NOT I_SPT_EDI1-GPART IS INITIAL.
    CALL FUNCTION 'FKK_DETERMINE_CREDIT_RATING'
      EXPORTING
        I_GPART = I_SPT_EDI1-GPART
        I_DATUM = SY-DATUM
      IMPORTING
        E_BONIT = I_SPT_EDI1-BONIT.
    IF SY-SUBRC NE 0.
      PERFORM WRITE_ERROR USING '007'
                    CHANGING I_SPT_EDI1.
    ENDIF.
  ENDIF.
ENDFORM.                    "DETERMINE_CREDIT_RATING

*&---------------------------------------------------------------------*
*&      Form  write_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_MSGNO    text
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM WRITE_ERROR USING    I_MSGNO TYPE SYMSGNO
                 CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.
  DATA: I_TEXT TYPE CHAR255.
  I_KZ_FEHLER     = 'X'.
  I_SPT_EDI1-ERROR = 'X'.
  CASE I_MSGNO.
    WHEN '001'.
      I_TEXT = 'Fehler bei Ermittlung Offene Posten lesen (Error 001)'.
    WHEN '002'.
      I_TEXT = 'Fehler bei Druck (Error 002)'.
    WHEN '003'.
      I_TEXT = 'Fehler bei Ermittlung Adresse zur Verbrauchsstelle (Error 003)'.
    WHEN '004'.
      I_TEXT = 'Fehler bei Lesen Sperrbeleg (Error 004)'.
    WHEN '005'.
      I_TEXT = 'Fehler bei Gebührenbuchung (Error 005)'.
    WHEN '006'.
      I_TEXT = 'Fehler bei Änderung Sperrbelegstatus (Error 006)'.
    WHEN '007'.
      I_TEXT = 'Fehler bei Ermittlung Bonität (Error 007)'.
    WHEN '008'.
      I_TEXT = 'Keine Berechtigung (Error 008)'.
    WHEN '009'.
      I_TEXT = 'Objekt in anderem Sperrbeleg (Error 009)'.
    WHEN '010'.
      I_TEXT = 'Objekt in anderem Sperrbeleg (Error 010)'.
    WHEN OTHERS.
  ENDCASE.

  CONCATENATE 'Sperrbeleg' I_SPT_EDI1-DISCNO ':' I_TEXT INTO I_ERROR SEPARATED BY SPACE.
  APPEND I_ERROR TO IT_ERROR.
ENDFORM.                    "write_error

*&---------------------------------------------------------------------*
*&      Form  error_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ERROR_MESSAGE.
  IF NOT I_KZ_FEHLER IS INITIAL.
    MESSAGE 'Fehler! Bitte Ausgabe beachten!' TYPE 'S'.
  ENDIF.
ENDFORM.                    "error_message

*&---------------------------------------------------------------------*
*&      Form  F4_REPORT_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_REPORT_VARIANT.
  IS_VARIANT-REPORT = SY-REPID.
*  is_variant-USERNAME = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = IS_VARIANT
*     I_TABNAME_HEADER    = I_TABNAME_HEADER
*     I_TABNAME_ITEM      = I_TABNAME_ITEM
*     IT_DEFAULT_FIELDCAT = IT_DEFAULT_FIELDCAT
      I_SAVE        = I_SAVE
*     I_DISPLAY_VIA_GRID  = ' '
    IMPORTING
*     E_EXIT        = E_EXIT
      ES_VARIANT    = IS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2
      OTHERS        = 3.
  IF SY-SUBRC NE 0.
    MESSAGE 'Es wurden noch keine Varianten angelegt' TYPE 'S'.
  ELSE.
    P_VARIAN = IS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.                    "F4_REPORT_VARIANT

*&---------------------------------------------------------------------*
*&      Form  kontakt_anlegen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_TYP      text
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM KONTAKT_ANLEGEN USING I_BPCCONFIG TYPE BCONTCONF-BPCCONFIG
                           I_SPT_EDI1  TYPE  /ADESSO/SPT_EDI1
                  CHANGING I_BPCONTACT TYPE BCONT-BPCONTACT.

  TYPE-POOLS: BPC01.

* Kontakt anlegen nur möglich, falls
* entsprechende Kontaktkonfiguration gefüllt
  CHECK NOT I_BPCCONFIG IS INITIAL.

* Kontakt mitels Kontaktkonfiguration erzeugen
  CALL FUNCTION 'BCONTACT_CREATE'
    EXPORTING
      X_UPD_ONLINE    = 'X'
      X_NO_DIALOG     = 'X'
      X_BPCCONFIG     = I_BPCCONFIG
      X_PARTNER       = I_SPT_EDI1-GPART
    IMPORTING
      Y_NEW_BPCONTACT = I_BPCONTACT
    EXCEPTIONS
      EXISTING        = 1
      FOREIGN_LOCK    = 2
      NUMBER_ERROR    = 3
      GENERAL_FAULT   = 4
      INPUT_ERROR     = 5
      NOT_AUTHORIZED  = 6
      OTHERS          = 7.
  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

* Objektverknüpfungen anlegen
  DATA: LT_BCONTO TYPE STANDARD TABLE OF BCONT_OBJ,
        LF_BCONTO TYPE BCONT_OBJ.

* Sperrbeleg
  CLEAR LF_BCONTO.
  LF_BCONTO-BPCONTACT = I_BPCONTACT.
  LF_BCONTO-OBJROLE   = 'DEFAULT'.
  LF_BCONTO-OBJTYPE   = 'DISCONNECT'.
  LF_BCONTO-OBJKEY    = I_SPT_EDI1-DISCNO.
  LF_BCONTO-RELTYPE   = 'EREF'.
  APPEND LF_BCONTO TO LT_BCONTO.

* Geschäftspartner
  CLEAR LF_BCONTO.
  LF_BCONTO-BPCONTACT = I_BPCONTACT.
  LF_BCONTO-OBJROLE   = 'DEFAULT'.
  LF_BCONTO-OBJTYPE   = 'ISUPARTNER'.
  LF_BCONTO-OBJKEY    = I_SPT_EDI1-GPART.
  LF_BCONTO-RELTYPE   = 'EREF'.
  APPEND LF_BCONTO TO LT_BCONTO.

* Vertragskonto
  CLEAR LF_BCONTO.
  LF_BCONTO-BPCONTACT = I_BPCONTACT.
  LF_BCONTO-OBJROLE   = 'DEFAULT'.
  LF_BCONTO-OBJTYPE   = 'ISUACCOUNT'.
  LF_BCONTO-OBJKEY    = I_SPT_EDI1-VKONT.
  LF_BCONTO-RELTYPE   = 'EREF'.
  APPEND LF_BCONTO TO LT_BCONTO.

  CALL FUNCTION 'BCONTACT_CREATE_RELATIONS'
    TABLES
      TX_BCONTO    = LT_BCONTO
    EXCEPTIONS
      UPDATE_ERROR = 1
      OTHERS       = 2.

ENDFORM.                    "kontakt_anlegen

*&---------------------------------------------------------------------*
*&      Form  change_discdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->i_spt_edi1  text
*----------------------------------------------------------------------*
FORM CHANGE_DISCDOC USING I_DISCACTTYP
                    CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1
                             I_OPBEL   TYPE FKKKO-OPBEL
                             I_BPCONTACT TYPE BCONT-BPCONTACT.
  DATA: Y_OBJ       TYPE ISU05_DISCDOC_INTERNAL,
        WA_EDISCACT TYPE EDISCACT.

  CHECK NOT I_OPBEL IS INITIAL OR NOT I_BPCONTACT IS INITIAL.


  CLEAR: Y_OBJ.

  PERFORM OPEN_DISCDOC CHANGING I_SPT_EDI1
                                Y_OBJ.

* aktuellste Sperraktion mit "Freigabe Sperrbeleg" ermitteln
  SORT Y_OBJ-EDISCACT BY DISCACT DESCENDING.
  LOOP AT Y_OBJ-EDISCACT INTO WA_EDISCACT
    WHERE DISCACTTYP EQ I_DISCACTTYP.
    EXIT.
  ENDLOOP.

  WA_EDISCACT-BC_CONTACT = I_BPCONTACT.
  WA_EDISCACT-CHARGE_OPBEL = I_OPBEL.

  MODIFY EDISCACT FROM WA_EDISCACT.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.                    "change_discdoc

*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS
*&---------------------------------------------------------------------*
FORM SET_EVENTS .

  DATA: LS_EVENTS TYPE SLIS_ALV_EVENT.

  CHECK PA_STATI = 'X'.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                      "#EC *
    EXPORTING
      I_LIST_TYPE     = 4
    IMPORTING
      ET_EVENTS       = GT_EVENTS
    EXCEPTIONS
      LIST_TYPE_WRONG = 1
      OTHERS          = 2.

  READ TABLE GT_EVENTS  WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                         INTO LS_EVENTS.
  IF SY-SUBRC = 0.
    MOVE SLIS_EV_TOP_OF_PAGE TO LS_EVENTS-FORM.
    MODIFY GT_EVENTS FROM LS_EVENTS INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " SET_EVENTS

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
FORM TOP_OF_PAGE .                                          "#EC *

  CHECK PA_STATI = 'X'.

  CLEAR:  GS_LISTHEADER.
  REFRESH GT_LISTHEADER.

  SORT T_STATI.
  LOOP AT T_STATI.
    GS_LISTHEADER-TYP  = 'S'.
    WRITE T_STATI-COUNT TO GS_LISTHEADER-KEY RIGHT-JUSTIFIED.
    CONCATENATE T_STATI-STATUS T_STATI-STATUSTEXT
                INTO GS_LISTHEADER-INFO
                SEPARATED BY SPACE.
    APPEND GS_LISTHEADER TO GT_LISTHEADER.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LISTHEADER.

ENDFORM.                    " handle_event_top_of_page

*&---------------------------------------------------------------------*
*&      Form  SET_STATISTIK
*&---------------------------------------------------------------------*
FORM SET_STATISTIK .

  CHECK PA_STATI = 'X'.

  LOOP AT ITAB ASSIGNING <ITAB>.
    T_STATI-STATUS     = <ITAB>-STATUS.
    T_STATI-STATUSTEXT = <ITAB>-STATUSTEXT.
    T_STATI-COUNT = 1.
    COLLECT T_STATI.
  ENDLOOP.

ENDFORM.                    " SET_STATISTIK

*&---------------------------------------------------------------------*
*&      Form  UCOMM_CIC
*&---------------------------------------------------------------------*
FORM UCOMM_CIC .

  DATA: FT_CIC_PROF TYPE TABLE OF CICPROFILES.
  DATA: FF_FRAMEWORK_ID TYPE CICFRPROF.
  DATA: WA_CICCONF TYPE CICCONF.
  DATA: WA_BDC TYPE BDCDATA.
  DATA: T_BDC TYPE TABLE OF BDCDATA.
  DATA: T_MESSTAB TYPE TABLE OF BDCMSGCOLL.

  CALL FUNCTION 'CIC_GET_ORG_PROFILES'
    EXPORTING
      AGENT                 = SY-UNAME
    IMPORTING
      FRAMEWORK_ID          = FF_FRAMEWORK_ID
    TABLES
      PROFILE_LIST          = FT_CIC_PROF
    EXCEPTIONS
      CALL_CENTER_NOT_FOUND = 1
      AGENT_GROUP_NOT_FOUND = 2
      PROFILES_NOT_FOUND    = 3
      NO_HR_RECORD          = 4
      CANCEL                = 5
      OTHERS                = 6.

  IF SY-SUBRC <> 0.
    MESSAGE 'Kein CIC-Profil gefunden' TYPE 'I'.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM CICCONF
         INTO WA_CICCONF
         WHERE FRAME_CONF = FF_FRAMEWORK_ID.

  IF SY-SUBRC <> 0.
    MESSAGE 'Kein CIC-Profil gefunden' TYPE 'I'.
    EXIT.
  ENDIF.

  CLEAR WA_BDC.
  WA_BDC-PROGRAM = 'SAPLCIC0'.
  WA_BDC-DYNPRO = WA_CICCONF-FRAME_SCREEN.
  WA_BDC-DYNBEGIN = 'X'.
  APPEND WA_BDC TO T_BDC.

  CLEAR WA_BDC.
  WA_BDC-FNAM = 'BDC_OKCODE'.
  WA_BDC-FVAL = '=RFSH'.
  APPEND WA_BDC TO T_BDC.

  CLEAR WA_BDC.
  WA_BDC-FNAM = 'EFINDD_CIC-A_VKONT'.
  WA_BDC-FVAL = WA_ITAB-VKONT.
  APPEND WA_BDC TO T_BDC.

  CALL FUNCTION 'CALL_CIC_TRANSACTION'
    EXPORTING
      TCODE       = 'CIC0'
      SKIPFIRST   = 'X'
    TABLES
      IN_BDCDATA  = T_BDC
      OUT_MESSTAB = T_MESSTAB.
*     EXCEPTIONS
*       NO_AUTHORIZATION       = 1
*       OTHERS                 = 2
  .
  IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " UCOMM_CIC

*&---------------------------------------------------------------------*
*&      Form  UCOMM_CH_INSTLN
*&---------------------------------------------------------------------*
FORM UCOMM_CH_INSTLN .

  DATA: X_ANLAGE    LIKE  V_EANL-ANLAGE,
        H_NUM10(10) TYPE N.
  MOVE WA_ITAB-ANLAGE TO H_NUM10.
  X_ANLAGE = H_NUM10.
  CALL FUNCTION 'ISU_S_INSTLN_CHANGE'
    EXPORTING
      X_ANLAGE     = X_ANLAGE
      X_KEYDATE    = SY-DATUM
      X_UPD_ONLINE = 'X'
    EXCEPTIONS
      OTHERS       = 1.
  IF SY-SUBRC NE 0.
* keine Fehlerausgabe notwendig
  ENDIF.

ENDFORM.                    " UCOMM_CH_INSTLN

*&---------------------------------------------------------------------*
*&      Form  VKONT_LESEN
*&---------------------------------------------------------------------*
FORM VKONT_LESEN  CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  DATA: WA_FKKVKP TYPE FKKVKP.

  CHECK NOT I_SPT_EDI1-VKONT IS INITIAL.

  SELECT SINGLE * FROM FKKVKP
         INTO WA_FKKVKP
         WHERE VKONT = I_SPT_EDI1-VKONT
         AND   GPART = I_SPT_EDI1-GPART.

  IF SY-SUBRC = 0.
    I_SPT_EDI1-ABWRH        = WA_FKKVKP-ABWRH.
    I_SPT_EDI1-ABWMA        = WA_FKKVKP-ABWMA.
    I_SPT_EDI1-MAHNV        = WA_FKKVKP-MAHNV.         " 3.10.2014 B.Duda
    I_SPT_EDI1-REGIOGR_CA_B = WA_FKKVKP-REGIOGR_CA_B.  " 8.10.2014 B.Duda
  ENDIF.

ENDFORM.                    " VKONT_LESEN

*&---------------------------------------------------------------------*
*&      Form  EVER_LESEN
*&---------------------------------------------------------------------*
FORM EVER_LESEN  CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  DATA: WA_EVER TYPE EVER.

  CHECK NOT I_SPT_EDI1-VERTRAG IS INITIAL.

  SELECT SINGLE * FROM EVER
         INTO WA_EVER
         WHERE VERTRAG = I_SPT_EDI1-VERTRAG
         AND   AUSZDAT = '99991231'.

  IF SY-SUBRC = 0.
    I_SPT_EDI1-EINZDAT = WA_EVER-EINZDAT.
  ENDIF.

ENDFORM.                    " EVER_LESEN

*&---------------------------------------------------------------------*
*&      Form  EANLH_LESEN
*&---------------------------------------------------------------------*
FORM EANLH_LESEN  CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  DATA: WA_EANLH TYPE EANLH.

  CHECK NOT I_SPT_EDI1-ANLAGE IS INITIAL.

  SELECT SINGLE * FROM EANLH
         INTO WA_EANLH
         WHERE ANLAGE = I_SPT_EDI1-ANLAGE
         AND   BIS = '99991231'.

  IF SY-SUBRC = 0.
    I_SPT_EDI1-TARIFTYP = WA_EANLH-TARIFTYP.
  ENDIF.

ENDFORM.                    " EANLH_LESEN

*&---------------------------------------------------------------------*
*&      Form  LESEN_ZEDISC_PRINT_KZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LESEN_ZEDISC_PRINT_KZ CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  DATA: WA_ZEDISC_PRINT_KZ TYPE /ADESSO/SPT_PRKZ.

  CHECK NOT I_SPT_EDI1-VERTRAG IS INITIAL.

  SELECT SINGLE * FROM /ADESSO/SPT_PRKZ
         INTO WA_ZEDISC_PRINT_KZ
        WHERE DISCNO = I_SPT_EDI1-DISCNO
          AND Z_VKONT = I_SPT_EDI1-VKONT
          AND Z_GPART = I_SPT_EDI1-GPART.

  IF SY-SUBRC = 0.
    I_SPT_EDI1-KZ_DRUCK_WIB = WA_ZEDISC_PRINT_KZ-Z_PRINT_WIB.
    I_SPT_EDI1-KZ_DRUCK_SPA = WA_ZEDISC_PRINT_KZ-Z_PRINT_SPA.
    I_SPT_EDI1-DRUCK_WIB_DATE =  WA_ZEDISC_PRINT_KZ-Z_WIB_DATE.
    I_SPT_EDI1-DRUCK_SPA_DATE =  WA_ZEDISC_PRINT_KZ-Z_SPA_DATE.

  ENDIF.
ENDFORM.                    " LESEN_ZEDISC_PRINT_KZ

*&---------------------------------------------------------------------*
*&      Form  LESEN_NOTIZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_ITAB  text
*----------------------------------------------------------------------*
FORM LESEN_NOTIZ  CHANGING  I_SPT_EDI1  TYPE /ADESSO/SPT_EDI1.

  DATA : WA_STXH TYPE STXH.
  DATA: BEGIN OF ITAB_TXT OCCURS 0.
          INCLUDE STRUCTURE TLINE.
  DATA: END OF ITAB_TXT.

  CHECK NOT I_SPT_EDI1-DISCNO IS INITIAL.

  CLEAR WA_STXH.
  SELECT SINGLE * FROM STXH INTO WA_STXH
       WHERE TDOBJECT = 'EDCN' AND
             TDID     = 'ISU'  AND
             TDNAME   = I_SPT_EDI1-DISCNO  AND
             TDSPRAS  = SY-LANGU.
  IF SY-SUBRC = 0.
    CLEAR ITAB_TXT.
    REFRESH ITAB_TXT.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        CLIENT                  = SY-MANDT
        ID                      = WA_STXH-TDID
        LANGUAGE                = WA_STXH-TDSPRAS
        NAME                    = WA_STXH-TDNAME
        OBJECT                  = WA_STXH-TDOBJECT
      TABLES
        LINES                   = ITAB_TXT
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7
        OTHERS                  = 8.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
*  clear zevuit_edisc-tdline.
    ELSE.
      LOOP AT ITAB_TXT.
        MOVE ITAB_TXT-TDLINE(60) TO I_SPT_EDI1-TDLINE.
        EXIT.
      ENDLOOP.
    ENDIF.
  ELSE.
    CLEAR I_SPT_EDI1-TDLINE.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  MODIFY_ZEDISC_PRINTKZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_ZEDISC_PRINT_KZ CHANGING I_SPT_EDI1 TYPE /ADESSO/SPT_EDI1.

  SELECT SINGLE *
    FROM /ADESSO/SPT_PRKZ
    WHERE DISCNO = I_SPT_EDI1-DISCNO
      AND Z_VKONT = I_SPT_EDI1-VKONT
      AND Z_GPART = I_SPT_EDI1-GPART.

  IF SY-SUBRC EQ 0.

    IF LV_FORM = 'ZDEW_CS_MANINKAS '. "Sperren
      /ADESSO/SPT_PRKZ-Z_PRINT_SPA = 'X'.
      /ADESSO/SPT_PRKZ-Z_SPA_DATE  = SY-DATUM.

    ENDIF.

    IF LV_FORM = 'ZDEW_CS_SPERREN '. "WiB
      /ADESSO/SPT_PRKZ-Z_PRINT_WIB = 'X'.
      /ADESSO/SPT_PRKZ-Z_WIB_DATE  = SY-DATUM.
    ENDIF.

    /ADESSO/SPT_PRKZ-Z_AEDAT     = SY-DATUM.
    /ADESSO/SPT_PRKZ-Z_AENAM     = SY-UNAME.

    UPDATE /ADESSO/SPT_PRKZ FROM /ADESSO/SPT_PRKZ.

  ELSE.

    CLEAR /ADESSO/SPT_PRKZ.

    IF LV_FORM = 'ZDEW_CS_MANINKAS '. "Sperren
      /ADESSO/SPT_PRKZ-Z_PRINT_SPA = 'X'.
      /ADESSO/SPT_PRKZ-Z_SPA_DATE  = SY-DATUM.
    ENDIF.

    IF LV_FORM = 'ZDEW_CS_SPERREN '. "WiB
      /ADESSO/SPT_PRKZ-Z_PRINT_WIB = 'X'.
      /ADESSO/SPT_PRKZ-Z_WIB_DATE  = SY-DATUM.
    ENDIF.

    /ADESSO/SPT_PRKZ-DISCNO      = I_SPT_EDI1-DISCNO.
    /ADESSO/SPT_PRKZ-Z_VKONT     = I_SPT_EDI1-VKONT.
    /ADESSO/SPT_PRKZ-Z_GPART     = I_SPT_EDI1-GPART.
    /ADESSO/SPT_PRKZ-Z_ERDAT     = SY-DATUM.
    /ADESSO/SPT_PRKZ-Z_ERNAM     = SY-UNAME.

    INSERT /ADESSO/SPT_PRKZ FROM /ADESSO/SPT_PRKZ.

  ENDIF.

  COMMIT WORK.

ENDFORM.                    " MODIFY_ZEDISC_PRINTKZ
