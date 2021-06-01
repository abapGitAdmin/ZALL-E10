REPORT /ADESSO/ZAEHLERMAP.

TABLES tinv_inv_extid.
TYPES: BEGIN OF t_equnr ,
         equnr TYPE equnr,
         bis   TYPE d,
       END OF t_equnr.


TYPES: BEGIN OF t_ausgabe ,
         extid      TYPE tinv_inv_extid-ext_ident,
         ab         TYPE d,
         bis        TYPE d,
         zaehler    TYPE i,
         herkft(20) TYPE c,
       END OF t_ausgabe.

SELECTION-SCREEN BEGIN OF BLOCK doc WITH FRAME TITLE text-002.
SELECT-OPTIONS: s_extid FOR tinv_inv_extid-ext_ident.
PARAMETERS p_pfad TYPE string LOWER CASE .
SELECTION-SCREEN END OF BLOCK doc.

DATA: lt_eastl           TYPE TABLE OF eastl,
      lt_gertab          TYPE  isu07_twd_gertab_t,
      ls_gertab          TYPE isu07_twd_gertab,
      lt_ext_id          TYPE TABLE OF tinv_inv_extid-ext_ident,
      ls_egerr           TYPE egerr,
      ls_egerr_old       TYPE egerr,
      lt_egerr           TYPE TABLE OF egerr,
      lv_egerrcnt        TYPE i,
      lv_msccnt          TYPE i,
      lv_nocnt           TYPE i,
      lv_found           TYPE c,
      lv_aklasse         TYPE eanlh-aklasse,
      lt_eideswtdoc      TYPE TABLE OF eideswtdoc,
      ls_eideswtdoc      TYPE  eideswtdoc,
      lv_int_ui          TYPE int_ui,
      wa_euitrans        TYPE euitrans,
      wa_euiinstln       TYPE euiinstln,
      lv_lieferstelle(3) TYPE c,
      lt_ausgabe         TYPE TABLE OF t_ausgabe,
      ls_ausgabe         TYPE t_ausgabe,
      n                  TYPE i VALUE 50,
      ls_eideswtmsgdata  TYPE eideswtmsgdata,
      ls_ext_id          TYPE tinv_inv_extid-ext_ident.

DATA lv_percentage1 TYPE i.
DATA lv_percentage2 TYPE i.

*DATA lv_int_ui TYPE int_ui.
DATA lt_isuwa_etyp TYPE isuwa_etyp.
DATA ls_isuwa_etyp TYPE LINE OF isuwa_etyp.

DATA:   ls_isu07_install_struc TYPE isu07_install_struc.
DATA: lv_anlage      TYPE anlage,
      lt_istln       TYPE TABLE OF ederegpodinstln,
      ls_istln       TYPE ederegpodinstln,
      ls_ietdz       TYPE etdz,
      lt_equnr       TYPE TABLE OF t_equnr,
*      ls_equnr       TYPE equnr,
      ls_ever        TYPE ever,
      lv_spg_ent(3)  TYPE c,
      ls_equnrt      TYPE t_equnr,
      lv_spg_mess(3) TYPE c,
      lt_zaehler     TYPE TABLE OF /adesso/zaehler,
      lt_zaehler_g   TYPE TABLE OF /adesso/g_zaehlr,
      ls_zaehler     TYPE  /adesso/zaehler,
      ls_zaehler_g   TYPE  /adesso/g_zaehlr,
      ls_euigrid     TYPE euigrid,
      lv_anz_instln  TYPE i.

DATA lv_int2 TYPE int2.
DATA:
  lt_eanlh       TYPE TABLE OF eanlh,
  ls_eanlh       TYPE  eanlh,
  lt_int_id      TYPE TABLE OF euiinstln,
  ls_int_ui      TYPE euiinstln,
  lv_devcat      TYPE egerr-zz_e_devcat,
  lv_dratcnt     TYPE egerr-zz_e_dratcnt,
  lv_ddirect     TYPE egerr-zz_e_ddirect,
  lv_meter_size  TYPE egerr-zz_e_meter_size,
  lv_datab       TYPE d.
  lv_zz_meter_id TYPE egerr-zz_meter_id,
  lv_meter_type  TYPE egerr-zz_e_ddirect.


SELECT DISTINCT ext_ident FROM tinv_inv_extid  INTO TABLE lt_ext_id WHERE ext_ident_type = '01' AND ext_ident IN s_extid.

LOOP AT lt_ext_id INTO ls_ext_id.

  SELECT SINGLE int_ui datefrom FROM euitrans INTO (lv_int_ui,lv_datab) WHERE ext_ui = ls_ext_id.
  "1. Im Netz-System nachschauen. K1NCLNT725 Z_ADESSO_ZAEHLERZUORDUNG

  CALL FUNCTION 'ISU_GET_UIINSTLN_FROM_BUFFER'
    EXPORTING
      x_int_ui      = lv_int_ui
    IMPORTING
      y_iinstln     = lt_istln
    EXCEPTIONS
      general_fault = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
  ENDIF.

  DESCRIBE TABLE lt_istln LINES lv_anz_instln.
  IF lv_anz_instln > 1.
    LOOP AT lt_istln INTO ls_istln.
      IF  ls_istln-service <> 'SLIF' .
        DELETE lt_istln INDEX sy-tabix .
      ENDIF.
    ENDLOOP.
  ENDIF    .

  READ TABLE lt_istln INTO ls_istln INDEX 1.
  lv_anlage = ls_istln-anlage.

  DATA lt_device_data TYPE TABLE OF zisu_device_data.
  DATA ls_device_data TYPE zisu_device_data.
  lv_datab = sy-datum.
  DO 10 TIMES.
    CLEAR lt_device_data.
    CALL METHOD zcl_datex_utility=>get_device_data
      EXPORTING
        iv_int_ui       = lv_int_ui
        iv_keydate      = lv_datab
*       iv_invlist      = SPACE
      IMPORTING
        et_device_data  = lt_device_data
*       et_subdevice_data =
      EXCEPTIONS
        parameter_error = 1
        not_found       = 2
        genereal_error  = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.

      lv_datab = sy-datum(4) - 1.
    ELSE.

      EXIT.
    ENDIF.
  ENDDO.


  LOOP AT lt_device_data INTO ls_device_data.
    SELECT * FROM egerr INTO TABLE lt_egerr WHERE equnr = ls_device_data-equnr AND bis >= lv_datab.
      LOOP at lt_egerr INTO ls_egerr.
      IF sy-subrc = 0.
        CLEAR ls_ausgabe.

        CLEAR: lv_spg_ent  ,
               lv_spg_mess.

        CLEAR: lv_devcat, lv_dratcnt, lv_ddirect, lv_meter_size, lt_zaehler ,lt_zaehler_g, lt_isuwa_etyp, ls_ever, ls_euigrid, lv_zz_meter_id.
        SELECT SINGLE * FROM euigrid INTO ls_euigrid WHERE int_ui = lv_int_ui AND  dateto >= ls_egerr-bis AND datefrom <= ls_egerr-ab.
        IF  ls_device_data-zaehlertyp1  IS NOT INITIAL OR
            ls_device_data-tarifanz IS NOT INITIAL OR
            ls_device_data-energierichtung IS NOT INITIAL OR
            ls_device_data-gasgroesse IS NOT INITIAL.

          lv_devcat     =  ls_device_data-zaehlertyp1 .
          lv_dratcnt    =  ls_device_data-tarifanz .
          lv_ddirect    =  ls_device_data-energierichtung .
          lv_meter_size =  ls_device_data-gasgroesse.

          ls_ausgabe-ab = ls_egerr-ab.
          ls_ausgabe-bis = ls_egerr-bis.
          ls_ausgabe-extid = ls_ext_id.
          ls_ausgabe-herkft = 'System'.

        ELSE.
          DATA lv_rfcdest TYPE string.
          SELECT SINGLE value FROM /adesso/inv_cust INTO lv_rfcdest WHERE report = '/ADESSO/ZAEHLERMAP' AND field = 'RFCDEST'.
          CALL FUNCTION '/ADESSO/ZAEHLERZUORDUNG'
            DESTINATION lv_rfcdest
            EXPORTING
              zpkt     = ls_ext_id
              sparte   = lv_int2
              from     = ls_egerr-ab
              to       = ls_egerr-bis
*             X_ONLY_KEYDATE       = ' '
            IMPORTING
              t_etyp   = lt_isuwa_etyp
              t_devdat = ls_device_data
* EXCEPTIONS
*             INTERNAL_ERROR       = 1
*             SYSTEM_ERROR         = 2
*             OTHERS   = 3
            .
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
          IF  ls_device_data-zaehlertyp1  IS NOT INITIAL OR
        ls_device_data-tarifanz IS NOT INITIAL OR
        ls_device_data-energierichtung IS NOT INITIAL OR
        ls_device_data-gasgroesse IS NOT INITIAL.

            lv_devcat     =  ls_device_data-zaehlertyp1 .
            lv_dratcnt    =  ls_device_data-tarifanz .
            lv_ddirect    =  ls_device_data-energierichtung .
            lv_meter_size =  ls_device_data-gasgroesse.

            ls_ausgabe-ab = ls_egerr-ab.
            ls_ausgabe-bis = ls_egerr-bis.
            ls_ausgabe-extid = ls_ext_id.
            ls_ausgabe-herkft = 'System'.
            CLEAR lt_isuwa_etyp.
          ELSE.
            SORT lt_isuwa_etyp BY aedat DESCENDING.
          ENDIF.

        ENDIF.

        CALL FUNCTION 'ISU_DB_EVER_SELECT_ANLAGE1'
          EXPORTING
            x_instln     = lv_anlage
            x_keydate    = ls_egerr-ab
          IMPORTING
            y_ever       = ls_ever
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
        ENDIF.
        IF ls_ever-sparte = '10' OR ls_ever-sparte = ' '."Strom.

          LOOP AT lt_isuwa_etyp INTO ls_isuwa_etyp WHERE sparte = '10'.
            lv_devcat     =    ls_isuwa_etyp-/idexge/devtyp.
            lv_dratcnt    =   ls_isuwa_etyp-/idexge/rate_num.
            lv_ddirect    =   ls_isuwa_etyp-/idexge/engy_dir.
            lv_meter_size =   ls_isuwa_etyp-/IDEXGE/SCHARA.
            lv_meter_type =    ls_isuwa_etyp-/idexge/met_typ.
            IF lv_devcat IS NOT INITIAL OR
               lv_dratcnt IS NOT INITIAL OR
               lv_ddirect IS NOT INITIAL OR
               lv_meter_size IS NOT INITIAL OR
               lv_meter_type IS NOT INITIAL .

              ls_ausgabe-ab = ls_egerr-ab.
              ls_ausgabe-bis = ls_egerr-bis.
              ls_ausgabe-extid = ls_ext_id.
              ls_ausgabe-herkft = 'Netz-System'.

              EXIT.
            ENDIF.
          ENDLOOP.

          IF lv_devcat IS  INITIAL  AND
             lv_dratcnt IS  INITIAL  AND
             lv_ddirect IS  INITIAL  AND
             lv_meter_size IS  INITIAL  AND
             lv_meter_type IS  INITIAL .
            PERFORM map_utilmd USING lv_int_ui ls_device_data CHANGING
            lv_devcat
            lv_dratcnt
            lv_ddirect
            lv_meter_size
            lv_meter_type
            lv_spg_ent
            lv_spg_mess
              .

            ls_ausgabe-ab = ls_egerr-ab.
            ls_ausgabe-bis = ls_egerr-bis.
            ls_ausgabe-extid = ls_ext_id.
            ls_ausgabe-herkft = 'Utilmd'.

          ENDIF.
          IF lv_spg_ent  IS INITIAL AND lv_spg_mess IS INITIAL.
            CASE ls_euigrid-grid_level.
              WHEN '01'.
                lv_spg_ent = 'E06'.
                lv_spg_mess = 'E06'.
              WHEN '02'.
                lv_spg_ent = 'E05'.
                lv_spg_mess = 'E05'.
              WHEN '03'.
                lv_spg_ent = 'E04'.
                lv_spg_mess = 'E04'.
              WHEN '11'.
                lv_spg_ent = 'E05'.
                lv_spg_mess = 'E06'.
              WHEN '12'.
                lv_spg_ent = 'E09'.
                lv_spg_mess = 'E06'.
              WHEN '13'.
                lv_spg_ent = 'E08'.
                lv_spg_mess = 'E05'.
              WHEN '80'.
                lv_spg_ent = 'E06'.
                lv_spg_mess = 'E06'.
              WHEN '81'.
                lv_spg_ent = 'E06'.
                lv_spg_mess = 'E06'.
              WHEN '82'.
                lv_spg_ent = 'E05'.
                lv_spg_mess = 'E06'.
              WHEN '83'.
                lv_spg_ent = 'E09'.
                lv_spg_mess = 'E06'.
              WHEN '84'.
                lv_spg_ent = 'E05'.
                lv_spg_mess = 'E05'.
              WHEN '85'.
                lv_spg_ent = 'E04'.
                lv_spg_mess = 'E04'.
              WHEN '86'.
                lv_spg_ent = 'E04'.
                lv_spg_mess = 'E04'.

              WHEN OTHERS.
            ENDCASE.
          ENDIF.
          IF ls_isuwa_etyp-messart < 0.
            CLEAR lv_dratcnt.
            lv_lieferstelle = 'RLM'.
          ELSE.

            "Kunden Exit zum Identifikatiom RLM/SLP
            "Kunden Exit zum Identifikatiom RLM/SLP
            DATA: lv_custreport TYPE string,
                  lv_rlmslp     TYPE c,
                  lv_custrlmslp TYPE string.


            SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custreport WHERE report = 'GLOBAL' AND field = 'CUST_REPORT'.
            SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custrlmslp WHERE report = 'GLOBAL' AND field = 'RLMSLP_FORM'.
            IF lv_custrlmslp IS NOT INITIAL AND lv_custreport IS NOT INITIAL.
              CALL FUNCTION '/ADESSO/CUST_RLM_SLP'
                EXPORTING
                  anlage       = lv_anlage
                  custform     = lv_custrlmslp
                  custprogramm = lv_custreport
                IMPORTING
                  rlmslp       = lv_rlmslp.

              IF lv_rlmslp = '1'. "Sonderkunden
                lv_lieferstelle = 'RLM'.
              ELSE.
                lv_lieferstelle = 'SLP'.
              ENDIF.

            ELSE.
              SELECT * FROM eanlh INTO ls_eanlh
                WHERE anlage = lv_anlage
                  AND bis GE ls_egerr-bis.
                EXIT.
              ENDSELECT.

              IF ls_eanlh-aklasse = '02'. "Sonderkunden
                lv_lieferstelle = 'RLM'.
              ELSE.
                lv_lieferstelle = 'SLP'.
              ENDIF.
            ENDIF.


          ENDIF.
          SELECT * FROM /adesso/zaehler INTO TABLE lt_zaehler
            WHERE energierichtung = lv_ddirect
            AND tarifanzahl = lv_dratcnt
            AND zaehlermerkmal = lv_meter_size
            AND energierichtung = lv_ddirect
            AND spg_ebene_entnahme = lv_spg_ent
            AND spg_ebene_messung = lv_spg_mess
            AND zaehlertyp = lv_meter_type
            AND lieferstelle = lv_lieferstelle.

          READ TABLE lt_zaehler INTO ls_zaehler INDEX 1.
          lv_zz_meter_id = ls_zaehler-zaehler_id.

        ELSEIF ls_ever-sparte = '20'."Gas

          LOOP AT lt_isuwa_etyp INTO ls_isuwa_etyp WHERE sparte = '20'.
            lv_devcat     =    ls_isuwa_etyp-/idexge/devtyp.
            lv_dratcnt    =   ls_isuwa_etyp-/idexge/rate_num.
            lv_ddirect    =   ls_isuwa_etyp-/idexge/engy_dir.
            lv_meter_size =   ls_isuwa_etyp-/idexge/meter_size.
            lv_meter_type =    ls_isuwa_etyp-/idexge/met_typ.
            IF lv_devcat IS NOT INITIAL OR
               lv_dratcnt IS NOT INITIAL OR
               lv_ddirect IS NOT INITIAL OR
               lv_meter_size IS NOT INITIAL OR
               lv_meter_type IS NOT INITIAL .
              EXIT.

              ls_ausgabe-ab = ls_egerr-ab.
              ls_ausgabe-bis = ls_egerr-bis.
              ls_ausgabe-extid = ls_ext_id.
              ls_ausgabe-herkft = 'Netz-System'.


            ENDIF.
          ENDLOOP.

          IF lv_devcat IS  INITIAL  AND
              lv_dratcnt IS  INITIAL  AND
              lv_ddirect IS  INITIAL  AND
              lv_meter_size IS  INITIAL  AND
              lv_meter_type IS  INITIAL .
            PERFORM map_utilmd USING lv_int_ui ls_device_data CHANGING
            lv_devcat
            lv_dratcnt
            lv_ddirect
            lv_meter_size
            lv_meter_type
            lv_spg_ent
            lv_spg_mess          .

            ls_ausgabe-ab = ls_egerr-ab.
            ls_ausgabe-bis = ls_egerr-bis.
            ls_ausgabe-extid = ls_ext_id.
            ls_ausgabe-herkft = 'Utilmd'.

          ENDIF.
          IF lv_spg_ent  IS INITIAL AND lv_spg_mess IS INITIAL.

            CASE ls_euigrid-grid_level.
              WHEN 'HT'.
                lv_spg_ent = 'Y01'.
                lv_spg_mess = 'Y01'.
              WHEN 'HV'.
                lv_spg_ent = 'Y01'.
                lv_spg_mess = 'Y01'.
              WHEN 'MT'.
                lv_spg_ent = 'Y02'.
                lv_spg_mess = 'Y02'.
              WHEN 'MV'.
                lv_spg_ent = 'Y02'.
                lv_spg_mess = 'Y02'.
              WHEN 'NT'.
                lv_spg_ent = 'Y03'.
                lv_spg_mess = 'Y03'.
              WHEN 'NV'.
                lv_spg_ent = 'Y03'.
                lv_spg_mess = 'Y03'.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.

          SELECT * FROM /adesso/g_zaehlr INTO TABLE lt_zaehler_g
            WHERE energierichtung = lv_ddirect
            AND tarifanzahl = lv_dratcnt
            AND zaehlermerkmal = lv_meter_size
            AND energierichtung = lv_ddirect
            AND druck_ebene_entnahme = lv_spg_ent
            AND druck_ebene_messung  = lv_spg_mess
            AND zaehlertyp = lv_meter_type.

          " ls_egerr_old = ls_egerr.
          READ TABLE lt_zaehler_g INTO ls_zaehler_g INDEX 1.
          lv_zz_meter_id = ls_zaehler_g-zaehler_id.

        ENDIF.

        ls_egerr_old = ls_egerr.
        ls_egerr-zz_meter_id = lv_zz_meter_id.
        IF ls_egerr-zz_meter_id <> ls_egerr_old-zz_meter_id.
          WRITE : / lv_int_ui , 'Zugeordnet eq:' , ls_egerr-equnr , 'Value',  ls_egerr-zz_meter_id.

          ls_ausgabe-zaehler = ls_egerr-zz_meter_id.


          CALL FUNCTION 'ISU_DB_EGERR_UPDATE'
            EXPORTING
              x_egerr     = ls_egerr
              x_egerr_old = ls_egerr_old
              x_upd_mode  = 'U'
*             X_NO_CHANGE_DOC       = ' '
*             X_INT_NUM_RANGE       = 'X'
* TABLES
*             T_EGERR_INSERT        =
*             T_EGERR_UPDATE        =
*             T_EGERR_DELETE        =
*             T_EGERR_OLD =
            .
        ELSEIF ls_egerr = ls_egerr_old AND ls_egerr-zz_meter_id IS NOT INITIAL.
          ls_ausgabe-zaehler = ls_egerr-zz_meter_id.
        ELSE.
          WRITE : / lv_int_ui , 'nicht Zugeordnet'.
          ls_ausgabe-zaehler = '0'.
        ENDIF.
      ENDIF.
      APPEND ls_ausgabe TO lt_ausgabe.
      CLEAR ls_ausgabe.
     endloop.
    IF sy-subrc = 4.
      WRITE : / lv_int_ui , 'keine Geräte gefunden'.
      ls_ausgabe-zaehler = '0'.
    ENDIF.
  ENDLOOP.
ENDLOOP.

PERFORM datei_schreiben USING lt_ausgabe p_pfad.


FORM datei_schreiben USING lt_data TYPE STANDARD TABLE lv_filepath TYPE string.

  DATA: lt_text TYPE truxs_t_text_data,
        ls_text TYPE LINE OF truxs_t_text_data.

  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = lt_data
    CHANGING
      i_tab_converted_data = lt_text
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



  OPEN DATASET lv_filepath FOR OUTPUT IN TEXT MODE ENCODING UTF-8.

  IF sy-subrc EQ 0.

    LOOP AT lt_text INTO ls_text.
      TRANSFER ls_text TO lv_filepath.
    ENDLOOP.
    CLOSE DATASET lv_filepath.

    MESSAGE i899(f2) WITH 'Datei im Pfad: ' lv_filepath ' geschrieben.'.

  ENDIF.

ENDFORM.

FORM map_utilmd USING intui TYPE int_ui u_egerr TYPE zisu_device_data CHANGING
  cv_devcat     TYPE egerr-zz_e_devcat
  cv_dratcnt    TYPE egerr-zz_e_dratcnt
  cv_ddirect    TYPE egerr-zz_e_ddirect
  cv_meter_size TYPE egerr-zz_e_meter_size
  cv_meter_type TYPE egerr-zz_e_ddirect
  cv_speben_mess TYPE eideswtmsgdata-zz_spebenemess
  cv_speben TYPE eideswtmsgdata-zz_spebene.

  DATA:
    lt_eideswtdoc     TYPE TABLE OF eideswtdoc,
    ls_eideswtdoc     TYPE  eideswtdoc,
    ls_prst_mdev      TYPE /idxgc/prst_mdev,
    ls_eideswtmsgdata TYPE eideswtmsgdata.



  SELECT * FROM eideswtdoc INTO  TABLE lt_eideswtdoc WHERE pod = intui.



  LOOP AT lt_eideswtdoc INTO ls_eideswtdoc.

    "Commonlayer
    SELECT * FROM /idxgc/prst_mdev
      INTO ls_prst_mdev
      WHERE proc_ref = ls_eideswtdoc-switchnum
      AND meternumber = u_egerr-equnr.
      IF ls_prst_mdev-metertype_value  IS NOT INITIAL OR
         ls_prst_mdev-ratenumber_code  IS NOT INITIAL  OR
         ls_prst_mdev-energy_direction IS NOT INITIAL  OR
         ls_prst_mdev-metersize_value  IS NOT INITIAL  OR
         ls_prst_mdev-metertype_value  IS NOT INITIAL .
        cv_devcat      = ls_prst_mdev-metertype_value.
        cv_dratcnt     = ls_prst_mdev-ratenumber_code.
        cv_ddirect     = ls_prst_mdev-energy_direction.
        cv_meter_size  = ls_prst_mdev-metersize_value.
        cv_meter_type  = ls_prst_mdev-metertype_value.
      ENDIF.

    ENDSELECT.
    IF cv_devcat IS NOT INITIAL OR
       cv_dratcnt  IS NOT INITIAL  OR
       cv_ddirect  IS NOT INITIAL  OR
       cv_meter_size  IS NOT INITIAL  OR
       cv_meter_type  IS NOT INITIAL .
      EXIT.
    ENDIF.

    "Kein Commonlayer EIDESWTMSGDATA
    SELECT * FROM eideswtmsgdata
      INTO ls_eideswtmsgdata
      WHERE switchnum = ls_eideswtdoc-switchnum
      AND category = 'E01'
      AND meternr = u_egerr-geraet
      AND direction = '1'.

      IF ls_eideswtmsgdata-meter_type  IS NOT INITIAL OR
         ls_eideswtmsgdata-/idexge/rate_num  IS NOT INITIAL  OR
         ls_eideswtmsgdata-/idexge/engy_dir IS NOT INITIAL   .
        cv_meter_type      = ls_eideswtmsgdata-meter_type.
        cv_dratcnt     = ls_eideswtmsgdata-zz_tarifanz.
        cv_ddirect     = ls_eideswtmsgdata-zz_enrichtanz.
        cv_speben_mess = ls_eideswtmsgdata-zz_spebenemess .
        cv_speben = ls_eideswtmsgdata-zz_spebene      .
        "  cv_meter_size  = ls_eideswtmsgdata-.
        "  cv_meter_type  = ls_prst_mdev-metertype_value.
      ENDIF.

    ENDSELECT.
    IF cv_devcat IS NOT INITIAL OR
       cv_dratcnt  IS NOT INITIAL  OR
       cv_ddirect  IS NOT INITIAL  OR
       cv_meter_size  IS NOT INITIAL  OR
       cv_meter_type  IS NOT INITIAL .
      EXIT.
    ENDIF.


  ENDLOOP.


ENDFORM.
