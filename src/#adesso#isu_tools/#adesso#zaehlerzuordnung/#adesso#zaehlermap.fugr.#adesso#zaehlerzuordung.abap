FUNCTION /ADESSO/ZAEHLERZUORDUNG.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(ZPKT) TYPE  EXT_UI
*"     VALUE(SPARTE) TYPE  INT2
*"     VALUE(FROM) TYPE  DATE
*"     VALUE(TO) TYPE  DATE
*"  EXPORTING
*"     VALUE(T_ETYP) TYPE  ISUWA_ETYP
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_instal,

           anlage   TYPE euiinstln-anlage,
           equnr    TYPE equi-equnr,
           zwnummer TYPE e_zwnummer,
           ab       TYPE dats,
           bis      TYPE dats,
           matnr    TYPE equi-matnr,
           sernr    TYPE equi-sernr,
           ext_ui   TYPE ext_ui,

         END OF ty_instal.

  TYPES: BEGIN OF ty_anlage,

           ext_ui   TYPE  euitrans-ext_ui,
           int_ui   TYPE euiinstln-int_ui,
           anlage   TYPE euiinstln-anlage,
           datefrom TYPE euiinstln-datefrom,
           dateto   TYPE euiinstln-dateto,
           timeto   TYPE euiinstln-timeto,


         END OF ty_anlage.

  DATA: lt_euilzw TYPE TABLE OF euilzw.
  DATA: ls_euilzw TYPE euilzw.
  DATA: ls_ezuz TYPE ezuz.
  DATA: lt_ezuz TYPE TABLE OF ezuz.
  DATA: ls_egerh TYPE egerh.
  DATA: lt_egerh TYPE TABLE OF egerh.
  DATA: ls_etyp TYPE etyp.
  DATA: ls_equi TYPE equi.
  DATA: lt_etyp TYPE TABLE OF etyp.


  DATA lt_anlage TYPE TABLE OF ty_anlage WITH HEADER LINE.
  DATA it_instal TYPE TABLE OF ty_instal.
  DATA ls_instal TYPE  ty_instal.

  IF 1 = 1.

    SELECT
         euitrans~ext_ui
         euiinstln~int_ui
         euiinstln~anlage
         euiinstln~datefrom
         euiinstln~dateto
         euiinstln~timeto

  INTO TABLE lt_anlage
  FROM ( euitrans
         INNER JOIN euiinstln   ON  euiinstln~dateto = euitrans~dateto
                                AND euiinstln~int_ui = euitrans~int_ui
                                AND euiinstln~timeto = euitrans~timeto )
   CLIENT SPECIFIED
       WHERE euitrans~mandt              = sy-mandt
         AND euitrans~ext_ui    = zpkt
         AND euitrans~datefrom  =< from
         AND euitrans~dateto    => to.


    IF sy-subrc = 0.
      SELECT
           easts~anlage
           etdz~equnr
          etdz~zwnummer
           etdz~ab
           etdz~bis
           equi~matnr
     equi~sernr
       INTO TABLE it_instal
    FROM ( easts
           INNER JOIN etdz   ON  etdz~logikzw = easts~logikzw
           INNER JOIN equi   ON  equi~equnr   = etdz~equnr
          )
    FOR ALL ENTRIES          IN lt_anlage
         WHERE easts~anlage  = lt_anlage-anlage
           AND etdz~bis  >=  from
           AND etdz~ab   =<  to
           AND easts~bis >=  from
           AND easts~ab  =<  to.

      LOOP AT it_instal INTO ls_instal.



        SELECT * FROM equi INTO  ls_equi WHERE equnr = ls_instal-equnr.

          SELECT * FROM etyp INTO ls_etyp WHERE matnr = ls_equi-matnr.

            READ TABLE lt_etyp TRANSPORTING NO FIELDS WITH  KEY matnr = ls_etyp-matnr.
            IF sy-subrc <> 0.
              APPEND ls_etyp TO lt_etyp.
            ENDIF.
          ENDSELECT.
        ENDSELECT.

      ENDLOOP.
    ENDIF.
    t_etyp = lt_etyp.

  ELSE.
    " EUILNR -> EGERR -> ETYP
    "1. Einträge aus EUILZW
    SELECT * FROM euilzw INTO TABLE lt_euilzw WHERE int_ui = zpkt.
    IF sy-subrc <> 0.
      break exstruck.
    ENDIF.

    LOOP AT lt_euilzw INTO ls_euilzw.

      SELECT * FROM ezuz INTO ls_ezuz  WHERE logikzw = ls_euilzw-logikzw.

        READ TABLE lt_ezuz TRANSPORTING NO FIELDS WITH  KEY logiknr2 = ls_ezuz-logiknr2.
        IF sy-subrc <> 0.
          APPEND ls_ezuz TO lt_ezuz.
        ENDIF.
      ENDSELECT.
    ENDLOOP.

    LOOP AT lt_ezuz INTO ls_ezuz.

      SELECT * FROM egerh INTO ls_egerh WHERE logiknr = ls_ezuz-logiknr2 AND bis => to AND ab =< from.

        READ TABLE lt_egerh TRANSPORTING NO FIELDS WITH  KEY equnr = ls_egerh-equnr.
        IF sy-subrc <> 0.
          APPEND ls_egerh TO lt_egerh.
        ENDIF.
      ENDSELECT.
    ENDLOOP.

    LOOP AT lt_egerh INTO ls_egerh.

      SELECT * FROM equi INTO  ls_equi WHERE equnr = ls_egerh-equnr.

        SELECT * FROM etyp INTO ls_etyp WHERE matnr = ls_equi-matnr.

          READ TABLE lt_etyp TRANSPORTING NO FIELDS WITH  KEY matnr = ls_etyp-matnr.
          IF sy-subrc <> 0.
            APPEND ls_etyp TO lt_etyp.
          ENDIF.
        ENDSELECT.
      ENDSELECT.
    ENDLOOP.

    t_etyp = lt_etyp.
  ENDIF.

ENDFUNCTION.
