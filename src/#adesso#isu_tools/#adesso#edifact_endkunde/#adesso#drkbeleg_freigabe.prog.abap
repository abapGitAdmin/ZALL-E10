*&---------------------------------------------------------------------*
*& Report  /ADESSO/DRKBELEG_FREIGABE
*&
*&---------------------------------------------------------------------*
* Report zur Freigabe von Druckbelegen zum INVOIC Versand oder auch
* Papierdruck.
*&---------------------------------------------------------------------*
* Änderungshistorie:
*     Datum  Benutzer Grund
*&---------------------------------------------------------------------*
REPORT /adesso/drkbeleg_freigabe.

INCLUDE /adesso/drkbeleg_freigabetop.    " TOP  INCLUDE

*-----------------------------------------------------------------------
* Selectionscreen
*-----------------------------------------------------------------------
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK segvkont WITH FRAME TITLE text-001.
PARAMETER:
                p_gpart  TYPE  fkkvkp-gpart,
                p_vkont  TYPE  fkkvkp-vkont.
SELECT-OPTIONS:
                s_sva    FOR gs_eservprovp-serviceid NO INTERVALS,
                s_bukrs  FOR gs_ever-bukrs NO INTERVALS.
PARAMETER:
                p_vktyp  TYPE fkkvk-vktyp.

SELECT-OPTIONS:
                s_sparte FOR gs_eanl-sparte NO INTERVALS OBLIGATORY,
                s_edivar FOR gs_zeide_edivar-edivariante MATCHCODE OBJECT zeideh_edivar NO INTERVALS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK segvkont.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK seldbel WITH FRAME TITLE text-002.
SELECT-OPTIONS:
                s_abrdat FOR gs_erdk-bldat OBLIGATORY,
                s_dblg   FOR gs_erdk-opbel NO INTERVALS.
PARAMETERS:
  p_storno AS CHECKBOX,
  p_sch    AS CHECKBOX,
  p_turnus AS CHECKBOX,
  p_zwi    AS CHECKBOX,
  p_abschl AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK seldbel.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK freisel WITH FRAME TITLE text-003.

PARAMETERS:     p_invoic TYPE c RADIOBUTTON GROUP gr1,
                p_papier TYPE c RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK freisel.

INITIALIZATION.

**Authority Check
*  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD '/ADESSO/DRKBEL_FREE'.
*  IF sy-subrc NE 0.
*    MESSAGE e172(00) WITH '/ADESSO/DRKBEL_FREE'.
*  ENDIF.

**Authority Check
*  AUTHORITY-CHECK OBJECT 'F_KKKO_BUK'
*  ID 'BUKRS' FIELD '1283'
*  ID 'ACTVT' FIELD '02'.
*  IF sy-subrc NE 0.
*    MESSAGE e172(00) WITH '/ADESSO/DRKBEL_FREE'.
*  ENDIF.

AT SELECTION-SCREEN.
  IF p_invoic IS INITIAL AND p_papier IS INITIAL.
    MESSAGE e012(/adesso/edifact_inv).
  ENDIF.
  IF p_storno IS INITIAL AND
     p_sch IS INITIAL AND
     p_turnus IS INITIAL AND
     p_zwi IS INITIAL AND
     p_abschl IS INITIAL.
    MESSAGE e033(/adesso/edifact_inv).
  ENDIF.
  IF '01' NOT IN s_sparte.
    IF '02' NOT IN s_sparte.
      MESSAGE e038(/adesso/edifact_inv).
    ENDIF.
  ENDIF.
*-----------------------------------------------------------------------
* Start of selection
*-----------------------------------------------------------------------

START-OF-SELECTION.

*open message log
  CLEAR gs_param.
  gs_eemsg_sub-msgty = co_msg_error.
  gs_eemsg_sub-sub_object = 'ERROR'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_eemsg_sub-msgty = co_msg_warning.
  gs_eemsg_sub-sub_object = 'WARNING'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_eemsg_sub-msgty = co_msg_success.
  gs_eemsg_sub-sub_object = 'SUCCESS'.
  APPEND gs_eemsg_sub TO gt_eemsg_sub.
  gs_param-appl_log  = '/ADESSO/EDIFACT_INV'.
  gs_param-subs = gt_eemsg_sub.

  CALL FUNCTION 'MSG_OPEN'
    EXPORTING
      x_no_dialog  = ' '
      x_log        = 'X'
      x_next_msg   = ' '
      x_obj_twice  = ' '
    IMPORTING
      y_msg_handle = gv_handle
    CHANGING
      xy_parm      = gs_param
    EXCEPTIONS
      failed       = 1
      subs_invalid = 2
      log_invalid  = 3
      OTHERS       = 4.
  IF sy-subrc <> 0.
    MESSAGE e021(/adesso/edifact_inv).
  ENDIF.

* Mapping SP <-> BP
  IF s_sva IS NOT INITIAL.
    SELECT SINGLE * FROM eservprovp INTO gs_eservprovp
      WHERE serviceid IN s_sva.
*  EDI Variante-Structure
    SELECT * FROM /adesso/edivar INTO TABLE gt_zeide_edivar
      WHERE edivariante IN s_edivar AND
            serviceid IN s_sva AND
            sparte IN s_sparte.
  ELSE.
* EDI Variante-Structure
    SELECT * FROM /adesso/edivar INTO TABLE gt_zeide_edivar
      WHERE edivariante IN s_edivar AND
            sparte IN s_sparte.
  ENDIF.
  IF sy-subrc <> 0.
    mac_msg_putx co_msg_error '015' '/ADESSO/EDIFACT_INV'
    space space space space space.
    SET EXTENDED CHECK OFF.
    IF 1 = 2. MESSAGE e015(/adesso/edifact_inv) WITH space space space space. ENDIF.
    SET EXTENDED CHECK ON.
  ENDIF.

  LOOP AT gt_zeide_edivar INTO gs_zeide_edivar.

* wenn Druckbeleg explizit gewählt
    IF s_dblg IS NOT INITIAL.
* Selektiere Druckbelege aus ERDK
      SELECT * FROM erdk INTO TABLE gt_erdk
        WHERE opbel IN s_dblg   AND
              bldat IN s_abrdat AND
              simulated <> 'X'.

      IF sy-subrc <> 0.
        mac_msg_putx co_msg_error '013' '/ADESSO/EDIFACT_INV'
        space space space space space.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE e013(/adesso/edifact_inv) WITH space space space space. ENDIF.
        SET EXTENDED CHECK ON.
      ELSE.
* Selektiere dazugehörige VKontos

        SELECT * FROM fkkvkp INTO TABLE gt_fkkvkp FOR ALL ENTRIES IN gt_erdk
          WHERE vkont        EQ gt_erdk-vkont               AND
                gpart        EQ gt_erdk-partner             AND
                zzedivar EQ gs_zeide_edivar-edivariante.

        IF sy-subrc <> 0.
          mac_msg_putx co_msg_error '013' '/ADESSO/EDIFACT_INV'
          space space space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e013(/adesso/edifact_inv) WITH space space space space. ENDIF.
          SET EXTENDED CHECK ON.
        ENDIF.
      ENDIF.

    ELSE.

      IF p_vktyp IS NOT INITIAL.
* Vertragskonten mit VKTYP, VKONT, GPART und BUKRS selektieren
        CLEAR gv_cond.

        CONCATENATE gv_cond 'k~vktyp EQ p_vktyp AND' INTO gv_cond SEPARATED BY space.

        IF p_vkont IS NOT INITIAL.
          CONCATENATE gv_cond 'p~vkont EQ p_vkont AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF p_gpart IS NOT INITIAL.
          CONCATENATE gv_cond 'p~gpart EQ p_gpart AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF s_bukrs IS NOT INITIAL.
          CONCATENATE gv_cond 'p~opbuk IN s_bukrs AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        TRY.
            SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_fkkvkp
              FROM fkkvkp AS p INNER JOIN fkkvk AS k
              ON p~vkont EQ k~vkont
              WHERE (gv_cond).
          CATCH cx_sy_dynamic_osql_error.
            MESSAGE `Wrong WHERE condition.` TYPE 'E'.
            EXIT.
        ENDTRY.

      ELSE.
* Vertragskonten mit VKONT, GPART, BUKRS und EDI-Variante selektieren
        CLEAR gv_cond.
        IF p_vkont IS NOT INITIAL.
          CONCATENATE gv_cond 'vkont EQ p_vkont AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF p_gpart IS NOT INITIAL.
          CONCATENATE gv_cond 'gpart EQ p_gpart AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF s_bukrs IS NOT INITIAL.
          CONCATENATE gv_cond 'opbuk IN s_bukrs AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        CONCATENATE gv_cond 'zzedivar EQ gs_zeide_edivar-edivariante' INTO gv_cond SEPARATED BY space.

        TRY.
            SELECT * FROM fkkvkp INTO TABLE gt_fkkvkp
              WHERE (gv_cond).
          CATCH cx_sy_dynamic_osql_error.
            MESSAGE `Wrong WHERE condition.` TYPE 'E'.
            EXIT.
        ENDTRY.

      ENDIF.

      IF sy-subrc <> 0.
        mac_msg_putx co_msg_error '014' '/ADESSO/EDIFACT_INV'
        space space space space space.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE e014(/adesso/edifact_inv) WITH space space space space. ENDIF.
        SET EXTENDED CHECK ON.

      ELSE.

        SORT gt_fkkvkp BY vkont ASCENDING.
        DELETE ADJACENT DUPLICATES FROM gt_fkkvkp COMPARING vkont.

* Druckbeleg selektieren
        CLEAR gv_cond.

        IF s_dblg IS NOT INITIAL.
          CONCATENATE gv_cond 'opbel IN s_dblg AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF NOT p_invoic IS INITIAL.
          CONCATENATE gv_cond 'druckdat = ''00000000'' AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF s_abrdat IS NOT INITIAL.
          CONCATENATE gv_cond 'bldat IN s_abrdat AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF p_gpart IS NOT INITIAL.
          CONCATENATE gv_cond 'partner EQ p_gpart AND' INTO gv_cond SEPARATED BY space.
        ENDIF.

        CONCATENATE gv_cond 'vkont = gt_fkkvkp-vkont AND' INTO gv_cond SEPARATED BY space.
        CONCATENATE gv_cond 'TOBRELEASD = space AND'      INTO gv_cond SEPARATED BY space.
        CONCATENATE gv_cond 'simulated <> ''X''' INTO gv_cond SEPARATED BY space.

        IF NOT p_papier IS INITIAL.
          CONCATENATE gv_cond 'and edisenddate = ''00000000''' INTO gv_cond SEPARATED BY space.
        ENDIF.

        IF NOT p_invoic IS INITIAL.
          CONCATENATE gv_cond 'and zzdb_freidat = ''00000000''' INTO gv_cond SEPARATED BY space.
        ENDIF.

        TRY.
            SELECT * FROM erdk INTO TABLE gt_erdk  FOR ALL ENTRIES IN gt_fkkvkp
              WHERE (gv_cond).
          CATCH cx_sy_dynamic_osql_error.
            MESSAGE `Wrong WHERE condition.` TYPE 'E'.

        ENDTRY.

        IF sy-subrc <> 0.
          mac_msg_putx co_msg_error '013' '/ADESSO/EDIFACT_INV'
          space space space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e013(/adesso/edifact_inv) WITH space space space space. ENDIF.
          SET EXTENDED CHECK ON.
        ENDIF.

      ENDIF.

    ENDIF.

* Druckbelege werden nach dem Abrechnungsvorgang gefiltert
    SORT gt_erdk BY opbel ASCENDING.
    LOOP AT gt_erdk ASSIGNING <gs_erdk>.
      CALL FUNCTION 'ISU_DB_ERDZ_SELECT_DOC'
        EXPORTING
          x_opbel       = <gs_erdk>-opbel
        TABLES
          yt_erdz       = gt_erdz
        EXCEPTIONS
          not_found     = 1
          not_qualified = 2
          system_error  = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
        CONTINUE.
      ELSE.
        IF <gs_erdk>-abrvorg <> '03'.
          CLEAR gv_mark.
          READ TABLE gt_erdz INTO gs_erdz INDEX 1.
          IF gs_erdz-sparte NE gs_zeide_edivar-sparte.
            CONTINUE.
          ELSE.
            gv_vertrag = gs_erdz-vertrag.
            CLEAR: gs_ever.
            SELECT SINGLE * FROM ever INTO gs_ever WHERE vertrag = gv_vertrag.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.
          ENDIF.
          LOOP AT gt_erdz INTO gs_erdz.
            IF gs_erdz-sparte NE gs_ever-sparte AND gs_erdz-sparte IS NOT INITIAL.
              gv_mark = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF gv_mark = 'X'.
            CLEAR gv_mark.
            CONTINUE.
          ELSE.
* Check VSZ für EDIFACT-Service
            CLEAR: gs_euiinstln, gs_eservice.
            SELECT SINGLE * FROM euiinstln INTO gs_euiinstln
              WHERE anlage = gs_ever-anlage AND
                    dateto >= '99991231'.
            IF sy-subrc <> 0.
              CONTINUE.
            ELSE.

              APPEND <gs_erdk> TO gt_erdk_temp.
            ENDIF.
          ENDIF.
        ELSE.
          CLEAR gv_mark.
          READ TABLE gt_erdz INTO gs_erdz INDEX 1.
          IF gs_erdz-sparte NE gs_zeide_edivar-sparte.
            CONTINUE.
          ENDIF.
          CLEAR gs_erdz.
          LOOP AT gt_erdz INTO gs_erdz WHERE sparte NE gs_zeide_edivar-sparte.
            IF gs_erdz-sparte IS NOT INITIAL AND gs_erdz-buchrel IS NOT INITIAL.
              gv_mark = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF gv_mark = 'X'.
            CLEAR gv_mark.
            CONTINUE.
          ELSE.
            APPEND <gs_erdk> TO gt_erdk_temp.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    CLEAR gt_erdk[].
    gt_erdk[] = gt_erdk_temp[].
    CLEAR gt_erdk_temp[].

* Druckbeleg nach Buchungskreis filtern
    IF NOT s_bukrs IS INITIAL.
      LOOP AT gt_erdk ASSIGNING <gs_erdk>.
        CALL FUNCTION 'ISU_DB_ERDZ_SELECT_DOC'
          EXPORTING
            x_opbel       = <gs_erdk>-opbel
          TABLES
            yt_erdz       = gt_erdz
          EXCEPTIONS
            not_found     = 1
            not_qualified = 2
            system_error  = 3
            OTHERS        = 4.
        IF sy-subrc <> 0.
          CONTINUE.
        ELSE.
* Alle Druckbelegzeilen müssen den selben Buchungskreis haben
          CLEAR gv_mark.
          LOOP AT gt_erdz INTO gs_erdz.
            IF gs_erdz-bukrs NOT IN s_bukrs.
              gv_mark = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF gv_mark = 'X'.
            CLEAR gv_mark.
            CONTINUE.
          ELSE.
            APPEND <gs_erdk> TO gt_erdk_temp.
          ENDIF.
        ENDIF.
      ENDLOOP.
      CLEAR gt_erdk[].
      gt_erdk[] = gt_erdk_temp[].
      CLEAR gt_erdk_temp[].
    ENDIF.

* Storno invoices
    IF NOT p_storno IS INITIAL.
      SORT gt_erdk BY ergrd ASCENDING.
      LOOP AT gt_erdk ASSIGNING <gs_erdk>
                          WHERE ergrd EQ '04'.
*    Prüfen EDI Variante Einstellung im Vertragskonto bzgl.INVOIC zum Rechnungstorno
        READ TABLE gt_fkkvkp INTO gs_fkkvkp
                             WITH KEY vkont = <gs_erdk>-vkont.
        IF gs_fkkvkp-zzedivar = gs_zeide_edivar-edivariante AND gs_zeide_edivar-storno IS NOT INITIAL.
          APPEND <gs_erdk> TO gt_erdk_temp.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDIF.

* Schlussrechung Invoices
    IF NOT p_sch IS INITIAL.
      SORT gt_erdk BY abrvorg ASCENDING.
      LOOP AT gt_erdk ASSIGNING <gs_erdk>
        WHERE ( abrvorg EQ '03'  OR
                abrvorg EQ space    ) AND
                ergrd   NE '04'.
        APPEND <gs_erdk> TO gt_erdk_temp.
      ENDLOOP.
    ENDIF.

* Turnusrechnung Invoices
    IF NOT p_turnus IS INITIAL.
      SORT gt_erdk BY abrvorg ASCENDING.
      LOOP AT gt_erdk ASSIGNING <gs_erdk> WHERE ( abrvorg EQ '01' OR abrvorg EQ '04' OR abrvorg EQ space ) AND ergrd NE '04'.
        APPEND <gs_erdk> TO gt_erdk_temp.
      ENDLOOP.
    ENDIF.

* Zwischenabrechung Invoices
    IF NOT p_zwi IS INITIAL.
      SORT gt_erdk BY abrvorg ASCENDING.
      LOOP AT gt_erdk ASSIGNING <gs_erdk> WHERE ( abrvorg EQ '02' OR abrvorg EQ '07' OR abrvorg EQ space ) AND ergrd NE '04'.
        APPEND <gs_erdk> TO gt_erdk_temp.
      ENDLOOP.
    ENDIF.

* Abschlagsplan
    IF NOT p_abschl IS INITIAL.
      SORT gt_erdk BY ergrd ASCENDING.
      LOOP AT gt_erdk ASSIGNING <gs_erdk> WHERE ergrd = '02' OR ergrd = '07' OR ergrd = '08'.
        APPEND <gs_erdk> TO gt_erdk_temp.
      ENDLOOP.
    ENDIF.

    SORT gt_erdk_temp BY opbel.

    DELETE ADJACENT DUPLICATES FROM gt_erdk_temp.

    IF gt_erdk_temp[] IS NOT INITIAL.
      CLEAR gt_erdk[].
      gt_erdk[] = gt_erdk_temp[].
      CLEAR gt_erdk_temp[].
    ENDIF.

    IF gt_erdk[] IS INITIAL.
      mac_msg_putx co_msg_error '016' '/ADESSO/EDIFACT_INV'
      space space space space space.
      SET EXTENDED CHECK OFF.
      IF 1 = 2. MESSAGE e016(/adesso/edifact_inv) WITH space space space space. ENDIF.
      SET EXTENDED CHECK ON.
    ENDIF.

    CLEAR: gv_00.

* INVOIC approval is active. Coming to this step means, that the print doc print table
* has been processed/Filtered accroding to user input at selection screen.
    IF NOT p_invoic IS INITIAL.
      LOOP AT gt_erdk ASSIGNING <gs_erdk>.
        IF     NOT <gs_erdk>-zzdb_freidat IS INITIAL.
          CONTINUE.
        ELSEIF NOT <gs_erdk>-druckdat IS INITIAL.
          CONTINUE.
        ELSE.
* Rechnungsstorno
          IF <gs_erdk>-ergrd = '04'.
            IF gs_zeide_edivar-storno IS INITIAL.
              mac_msg_putx co_msg_error '018' '/ADESSO/EDIFACT_INV'
              <gs_erdk>-opbel space space space space.
              SET EXTENDED CHECK OFF.
              IF 1 = 2. MESSAGE e018(/adesso/edifact_inv) WITH <gs_erdk>-opbel space space space. ENDIF.
              SET EXTENDED CHECK ON.
              CONTINUE.
            ENDIF.
          ENDIF.
* Manuelle Abrechnung-Flag in EDI Variante
          IF <gs_erdk>-abrvorg = '06'.
            IF gs_zeide_edivar-ediea16 IS INITIAL.
              mac_msg_putx co_msg_error '029' '/ADESSO/EDIFACT_INV'
              <gs_erdk>-opbel space space space space.
              SET EXTENDED CHECK OFF.
              IF 1 = 2. MESSAGE e029(/adesso/edifact_inv) WITH <gs_erdk>-opbel space space space. ENDIF.
              SET EXTENDED CHECK ON.
              CONTINUE.
            ENDIF.
          ENDIF.

          <gs_erdk>-zzdb_freidat = sy-datum.

          CALL FUNCTION 'ISU_DB_ERDK_UPDATE'
            EXPORTING
              x_erdk     = <gs_erdk>
              x_upd_mode = 'U'.

          mac_msg_putx co_msg_success '019' '/ADESSO/EDIFACT_INV'
          <gs_erdk>-opbel space space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE s019(/adesso/edifact_inv) WITH <gs_erdk>-opbel space space space. ENDIF.
          SET EXTENDED CHECK ON.
          gv_00 = gv_00 + 1.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      IF gv_00 EQ 0.
        mac_msg_putx co_msg_error '032' '/ADESSO/EDIFACT_INV'
         space space space space space.
        SET EXTENDED CHECK OFF.
        IF 1 = 2. MESSAGE e032(/adesso/edifact_inv) WITH space space space space. ENDIF.
        SET EXTENDED CHECK ON.
      ENDIF.
    ENDIF.

* Printdoc for paper printing approval is active. Coming to this step means, that the print doc print table
* has been processed/Filtered accroding to user input at selection screen.
    IF NOT p_papier IS INITIAL.
      LOOP AT gt_erdk ASSIGNING <gs_erdk>.

        IF NOT <gs_erdk>-edisenddate IS INITIAL.
          CONTINUE.
        ENDIF.

        IF <gs_erdk>-printlock <> '2'.
          mac_msg_putx co_msg_error '020' '/ADESSO/EDIFACT_INV'
          <gs_erdk>-opbel space space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE e020(/adesso/edifact_inv) WITH <gs_erdk>-opbel space space space. ENDIF.
          SET EXTENDED CHECK ON.
          CONTINUE.
        ELSE.

          CALL FUNCTION 'ISU_INV_REVOKE_PRINTLOCK'
            EXPORTING
              x_printdoc   = <gs_erdk>-opbel
            IMPORTING
              y_erdk       = <gs_erdk>
            EXCEPTIONS
              not_released = 1
              not_found    = 2
              system_error = 3
              no_authority = 4
              OTHERS       = 5.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          mac_msg_putx co_msg_success '039' '/ADESSO/EDIFACT_INV'
          <gs_erdk>-opbel space space space space.
          SET EXTENDED CHECK OFF.
          IF 1 = 2. MESSAGE s039(/adesso/edifact_inv) WITH <gs_erdk>-opbel space space space. ENDIF.
          SET EXTENDED CHECK ON.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDLOOP.

* LOG sichern
  CALL FUNCTION 'MSG_ACTION'
    EXPORTING
      x_msg_handle         = gv_handle
      x_action             = co_msg_save
    EXCEPTIONS
      action_not_supported = 1
      handle_invalid       = 2
      not_found            = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    mac_msg_repeat co_msg_error internal_error.
  ENDIF.

* Display the log (no batch)
  IF sy-batch IS INITIAL.
    CALL FUNCTION 'MSG_ACTION'
      EXPORTING
        x_msg_handle         = gv_handle
        x_action             = co_msg_dspl
      EXCEPTIONS
        action_not_supported = 1
        handle_invalid       = 2
        not_found            = 3
        OTHERS               = 4.
    IF sy-subrc <> 0.
      mac_msg_repeat co_msg_error internal_error.
    ENDIF.
  ENDIF.

* LOG schließen
  CALL FUNCTION 'MSG_CLOSE'
    EXPORTING
      x_msg_handle = gv_handle.

END-OF-SELECTION.
