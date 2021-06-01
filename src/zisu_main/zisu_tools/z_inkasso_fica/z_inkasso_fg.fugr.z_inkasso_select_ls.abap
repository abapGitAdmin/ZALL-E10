FUNCTION z_inkasso_select_ls.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(X_OPT) TYPE  ZINKASSO_OPT
*"  TABLES
*"      IT_SELECT STRUCTURE  ZINKASSO_SELECT
*"      ET_OUT STRUCTURE  ZINKASSO_OUT
*"----------------------------------------------------------------------

  DATA: wa_dfkkop TYPE dfkkop.
  DATA: help_dfkkop TYPE dfkkop.
  DATA: it_dfkkop TYPE STANDARD TABLE OF dfkkop.
  DATA: wa_fkkmaze TYPE fkkmaze.
  DATA: it_fkkmaze TYPE STANDARD TABLE OF fkkmaze.
  DATA: wa_out TYPE zinkasso_out.
*  DATA: ft_out TYPE STANDARD TABLE OF zinkasso_out.
  DATA: lt_sfkkop TYPE STANDARD TABLE OF sfkkop.
  DATA: lw_sfkkop TYPE sfkkop.

  DATA: lt_wheretab TYPE TABLE OF sdit_qry.
  DATA: lw_wheretab TYPE sdit_qry.

  DATA: ls_dfkkcoll TYPE dfkkcoll.             "Nuss 21.11.2014


  DATA: ls_ever TYPE ever,
        ls_but000 TYPE but000,
        ls_dd07t     TYPE dd07t,
        lv_vertrag TYPE ever-vertrag.

  DATA: mahnv_um TYPE char1.

  LOOP AT it_select.

**  Prüfen, ob für GP/VKONT  offene DFKKOP mit Hauptvorgang 0200
** (Schlussabgerechnetr)
    CLEAR it_dfkkop.
    SELECT * FROM dfkkop INTO TABLE it_dfkkop
      WHERE ( augst = space OR
              augst = '9' )
        AND gpart = it_select-gpart
        AND vkont = it_select-vkont
        AND hvorg = 'SABR'.

**  Ist einer dieser Belege in der Mahnstufe 02 mit dem Mahnverfahren 30
    CHECK it_dfkkop IS NOT INITIAL.

    LOOP AT it_dfkkop INTO wa_dfkkop.
      CLEAR: it_fkkmaze, wa_fkkmaze, mahnv_um .
      SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
*      FOR ALL ENTRIES IN it_dfkkop
        WHERE gpart = wa_dfkkop-gpart
          AND vkont = wa_dfkkop-vkont
          AND opbel = wa_dfkkop-opbel
          AND opupk = wa_dfkkop-opupk
          AND opupw = wa_dfkkop-opupw
          AND opupz = wa_dfkkop-opupz
          AND xmsto NE 'X'
          AND mahns = '02'
          AND mahnv = 'UM'.



*   Der schlussabgerechnete Beleg ist nicht gemahnt
      CHECK it_fkkmaze IS INITIAL.
*  Jetzt alle Mahnungen zum Vertragskonto lesen
      SELECT * FROM fkkmaze INTO wa_fkkmaze
        WHERE gpart = wa_dfkkop-gpart
        AND   vkont = wa_dfkkop-vkont
        AND   xmsto NE 'X'.
        CLEAR help_dfkkop.
        SELECT SINGLE * FROM dfkkop INTO help_dfkkop
          WHERE opbel = wa_fkkmaze-opbel
           AND opupk = wa_fkkmaze-opupk
           AND opupw = wa_fkkmaze-opupw
           AND opupz = wa_fkkmaze-opupz
           AND augst NE '9'.
        IF sy-subrc = 0.
          APPEND wa_fkkmaze TO it_fkkmaze.
          CLEAR wa_fkkmaze.
        ENDIF.
      ENDSELECT.
*   Jetzt Ptrüfen, ob eine Mahnung im Umzugsmahnverfahren vorhanden ist
*   mit Mahnstufe 2
      IF it_fkkmaze IS NOT INITIAL.
        CLEAR wa_fkkmaze.
        READ TABLE it_fkkmaze INTO wa_fkkmaze
          WITH KEY mahns = '02'
                   mahnv = 'UM'.
        IF sy-subrc = 0.
          mahnv_um = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CHECK mahnv_um = 'X'.

    REFRESH lt_wheretab.
    lw_wheretab = 'AUGST EQ '''''.
    APPEND lw_wheretab TO lt_wheretab.
    CLEAR: lt_sfkkop.
    REFRESH lt_sfkkop.

    CALL FUNCTION 'FKK_LINE_ITEMS_SELECT_LOGICAL'
      EXPORTING
        i_vkont        = wa_fkkmaze-vkont
*       IX_VKONT       = ' '
        i_gpart        = wa_fkkmaze-gpart
*       IX_GPART       = ' '
*       I_OPBEL        =
*       IX_OPBEL       = ' '
*       IX_SAMPLE_FLAG = ' '
      TABLES
        pt_logfkkop    = lt_sfkkop
*       pt_wheretab    = lt_wheretab
*       TP_VKONT_RANGE =
*       TP_GPART_RANGE =
*       TP_OPBEL_RANGE =
      .

    LOOP AT lt_sfkkop INTO lw_sfkkop.

      CLEAR wa_out.

      MOVE-CORRESPONDING lw_sfkkop TO wa_out.

*    Sparte reinschreiben
      IF wa_out-spart IS NOT INITIAL.
        SELECT SINGLE vtext FROM tspat INTO wa_out-vtext
          WHERE spras = sy-langu AND spart = wa_out-spart.
      ENDIF.

* Text zum Vorgang reinschreiben
      SELECT SINGLE txt30 FROM tfktvot INTO wa_out-txt30
              WHERE spras = sy-langu
               AND applk = 'R'
               AND hvorg = wa_out-hvorg
               AND tvorg = wa_out-tvorg.

*    nur abzugebende Posten (auch ausgebuchte möglich)
      IF x_opt-xagapi = 'X'.
        IF wa_out-inkps = 0.
          IF NOT x_opt-xopwo IS INITIAL.
            CHECK wa_out-augdt IS INITIAL OR
                  ( wa_out-augrd CS '04' OR
                    wa_out-augrd CS '14' ).
            IF wa_out-augrd = '04' OR
              wa_out-augrd = '14'.
              wa_out-ausgeb = 'X'.
            ENDIF.
          ELSE.
            CHECK wa_out-augdt IS INITIAL.
          ENDIF.
**        --> Nuss 24.11.2014
**        Select der DFKKCOLL auf Status 99
          CLEAR ls_dfkkcoll.
          SELECT SINGLE * FROM dfkkcoll INTO ls_dfkkcoll
            WHERE opbel = wa_out-opbel
              AND agsta = '99'.
          IF sy-subrc = 0.
            wa_out-agsta = ls_dfkkcoll-agsta.
            wa_out-agstatxt = 'Vorgemerkt'.
          ENDIF.
**        <-- Nuss 24.11.2014

          APPEND wa_out TO et_out.
          CLEAR wa_out.
        ELSE.
          IF x_opt-xagip IS INITIAL.
            SELECT SINGLE inkps agsta aggrd inkgp FROM dfkkcoll
                     INTO CORRESPONDING FIELDS OF wa_out
                        WHERE inkps = wa_out-inkps
                        AND   opbel = wa_out-opbel
                        AND   ( agsta NE '02' AND
                                agsta NE '03' AND
                                agsta NE '06' ).
            IF sy-subrc EQ 0.
**         --> Nuss 11.07.2014
**         Wenn nur abzugebende angezeigt werden sollen,
**         dann nur Abgabestatus 01 oder leer
              IF wa_out-agsta = '01' OR
                wa_out-agsta IS INITIAL.
**            do nothing
              ELSE.
                CLEAR wa_out.
                CONTINUE.
              ENDIF.
**         --> Nuss 11.07.2014
*            PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
*       Kurztext zum Abgabestatus reinschreiben
              CLEAR ls_dd07t.
              SELECT * FROM dd07t INTO ls_dd07t
                 WHERE domname = 'AGSTA_KK'
                  AND ddlanguage = sy-langu
                  AND domvalue_l = wa_out-agsta.
                wa_out-agstatxt = ls_dd07t-ddtext.
              ENDSELECT.

*      Name zum Inkassobüro lesen
              SELECT SINGLE name_org1 FROM but000 INTO wa_out-inkname
                  WHERE partner = wa_out-inkgp.

*    Wenn ORG1 nicht gefüllt ist, prüfen, ob es eine Gruppe ist
              IF wa_out-inkname IS INITIAL.
                SELECT SINGLE name_grp1 FROM but000 INTO wa_out-inkname
                  WHERE partner = wa_out-inkgp.
              ENDIF.

*    Letztendlich noch Vorname Nachname
              IF wa_out-inkname IS INITIAL.
                CLEAR ls_but000.
                SELECT SINGLE * FROM but000 INTO ls_but000
                  WHERE partner = wa_out-inkgp.
                CONCATENATE ls_but000-name_first ls_but000-name_last
                  INTO wa_out-inkname SEPARATED BY space.
              ENDIF.

              APPEND wa_out TO et_out.
              CLEAR  wa_out.
            ENDIF.
          ENDIF.
*      nur ausgebuchte Posten
          IF wa_out-inkps = 0.
            IF x_opt-xopwo = 'X'.
              CHECK ( wa_out-augrd CS '04' OR
                      wa_out-augrd CS '14' ).
*            PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
              wa_out-ausgeb = 'X'.
              APPEND wa_out TO et_out.
              CLEAR wa_out.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
**   abgegebene Posten (zusätzlich auch Abgabestatus und Abgabegrund)
      IF x_opt-xagip = 'X'.
        IF wa_out-inkps > 0.
          SELECT SINGLE inkps agsta aggrd inkgp FROM dfkkcoll
                    INTO CORRESPONDING FIELDS OF wa_out
                       WHERE inkps = wa_out-inkps
                       AND   opbel = wa_out-opbel.
*                       AND   agsta IN so_agsta
*                       AND   aggrd IN so_aggrd.
          IF sy-subrc EQ 0.
*            PERFORM process_pos_4_req_drs USING itab_fkkop  CHANGING p_pos_wa.
*       Kurztext zum Abgabestatus reinschreiben
            CLEAR ls_dd07t.
            SELECT * FROM dd07t INTO ls_dd07t
               WHERE domname = 'AGSTA_KK'
                AND ddlanguage = sy-langu
                AND domvalue_l = wa_out-agsta.
              wa_out-agstatxt = ls_dd07t-ddtext.
            ENDSELECT.

*      Name zum Inkassobüro lesen
            SELECT SINGLE name_org1 FROM but000 INTO wa_out-inkname
                WHERE partner = wa_out-inkgp.

*    Wenn ORG1 nicht gefüllt ist, prüfen, ob es eine Gruppe ist
            IF wa_out-inkname IS INITIAL.
              SELECT SINGLE name_grp1 FROM but000 INTO wa_out-inkname
                WHERE partner = wa_out-inkgp.
            ENDIF.

*    Letztendlich noch Vorname Nachname
            IF wa_out-inkname IS INITIAL.
              CLEAR ls_but000.
              SELECT SINGLE * FROM but000 INTO ls_but000
                WHERE partner = wa_out-inkgp.
              CONCATENATE ls_but000-name_first ls_but000-name_last
                INTO wa_out-inkname SEPARATED BY space.
            ENDIF.

            APPEND wa_out TO et_out.
            CLEAR  wa_out.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

* Prüfen, ob Vertrag schlussgerechnet ist
* und Status setzen
  LOOP AT et_out INTO wa_out.

    IF wa_out-vtref IS NOT INITIAL.
      CALL FUNCTION 'ISU_INTERNAL_VTREF_TO_VERTRAG'
        EXPORTING
          i_vtref   = wa_out-vtref
        IMPORTING
          e_vertrag = lv_vertrag.

      CLEAR ls_ever.
      SELECT SINGLE * FROM ever INTO ls_ever
        WHERE vertrag = lv_vertrag.

      IF   ls_ever-billfinit = 'X'.
        wa_out-billfin = 'X'.
        MODIFY et_out FROM wa_out
          TRANSPORTING billfin.
      ENDIF.
    ENDIF.

    IF wa_out-inkps >= 998.
*   Special case: internal collection case
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_BUSINAV_PROC_EXIST'
          info                  = text-008
        IMPORTING
          result                = wa_out-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

* Abzugebende Posten
    ELSEIF wa_out-inkps = 0    AND
           wa_out-aggrd IS INITIAL AND
           wa_out-inkgp IS INITIAL AND
           wa_out-agsta IS INITIAL.

**post for release
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_GREEN'
          info                  = text-006
        IMPORTING
          result                = wa_out-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
*released post
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_RED'
          info                  = text-007
        IMPORTING
          result                = wa_out-status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    MODIFY et_out FROM wa_out
      TRANSPORTING status.

    CLEAR it_fkkmaze.
    SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
      WHERE gpart = wa_out-gpart
        AND vkont = wa_out-vkont
        AND opbel = wa_out-opbel
        AND opupw = wa_out-opupw
        AND opupk = wa_out-opupk
        AND opupz = wa_out-opupz
        AND xmsto NE 'X'.

    IF sy-subrc = 0.
      SORT it_fkkmaze BY laufd DESCENDING.
      READ TABLE it_fkkmaze INTO wa_fkkmaze INDEX 1.

      IF sy-subrc = 0.
        MOVE wa_fkkmaze-mahnv TO wa_out-mahnv.
        MOVE wa_fkkmaze-mahns TO wa_out-mahns.

        MODIFY et_out FROM wa_out
                      TRANSPORTING mahnv mahns.

      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
