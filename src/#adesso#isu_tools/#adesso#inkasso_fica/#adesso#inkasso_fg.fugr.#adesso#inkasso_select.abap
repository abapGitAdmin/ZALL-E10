FUNCTION /adesso/inkasso_select.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(X_OPT) TYPE  /ADESSO/INKASSO_OPT
*"     VALUE(X_CHECK) TYPE  FLAG OPTIONAL
*"     VALUE(X_OVRDUE) TYPE  /ADESSO/OVERDUE OPTIONAL
*"     VALUE(XT_SPART) TYPE  /ADESSO/INKASSO_SPARTT OPTIONAL
*"     VALUE(XT_VKTYP) TYPE  /ADESSO/INKASSO_VKTYPT OPTIONAL
*"     VALUE(XT_REGIO) TYPE  /ADESSO/INKASSO_REGIOT OPTIONAL
*"     VALUE(XT_LOCKR) TYPE  /ADESSO/INKASSO_LOCKRT OPTIONAL
*"  EXPORTING
*"     VALUE(ET_OUT) TYPE  /ADESSO/T_INKASSO_OUT
*"  TABLES
*"      IT_SELECT STRUCTURE  /ADESSO/INKASSO_SELECT
*"----------------------------------------------------------------------
  DATA: wa_dfkkop TYPE dfkkop.
  DATA: it_dfkkop TYPE STANDARD TABLE OF dfkkop.
  DATA: wa_fkkmaze TYPE fkkmaze.
  DATA: it_fkkmaze TYPE STANDARD TABLE OF fkkmaze.
  DATA: wa_out TYPE /adesso/inkasso_out.
  DATA: lt_sfkkop TYPE STANDARD TABLE OF sfkkop.
  DATA: lw_sfkkop TYPE sfkkop.
  DATA: lw_dfkkzp TYPE dfkkzp.


  DATA: lt_wheretab TYPE TABLE OF sdit_qry.
  DATA: lw_wheretab TYPE sdit_qry.

  DATA: ls_dfkkcoll TYPE dfkkcoll.             "Nuss 21.11.2014
  DATA: ls_dfkkcollh TYPE dfkkcollh.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  DATA: lt_out_vkont TYPE STANDARD TABLE OF /adesso/inkasso_out.
  DATA: ls_out_vkont TYPE /adesso/inkasso_out.
  DATA: ls_opt_vkont TYPE  /adesso/inkasso_opt.
  DATA: lt_inkasso_vk TYPE /adesso/inkasso_sumt.

  DATA: only_xopwo  TYPE  /adesso/inkasso_opt.
  DATA: only_xreca  TYPE  /adesso/inkasso_opt.
  DATA: only_xagip  TYPE  /adesso/inkasso_opt.
  DATA: only_xfact  TYPE  /adesso/inkasso_opt.
  DATA: only_abbri  TYPE  /adesso/inkasso_opt.
  DATA: only_xsell  TYPE  /adesso/inkasso_opt.
  DATA: only_xdsel  TYPE  /adesso/inkasso_opt.
  DATA: only_apprse TYPE  /adesso/inkasso_opt.
  DATA: only_apprwo TYPE  /adesso/inkasso_opt.
  DATA: only_wroff  TYPE  /adesso/inkasso_opt.
  DATA: newin_xopwo TYPE  /adesso/inkasso_opt.

  DATA: ls_ever    TYPE ever,
        ls_but000  TYPE but000,
        ls_dd07t   TYPE dd07t,
        lv_vertrag TYPE ever-vertrag.
  DATA: ls_erdb    TYPE erdb.
  DATA: ls_dfkkko  TYPE dfkkko.

  DATA: mahnv_um TYPE char1.

  DATA: lv_mahnv TYPE mahnv_kk.                "Nuss 04.2017
  DATA: lv_mahns TYPE mahns_kk.                "Nuss 05.2017
  DATA: lv_iban  TYPE iban.
  DATA: lv_dfkkzp-iban TYPE iban_kk.

  DATA: h_partner TYPE but000-partner,
        h_name    TYPE char80,
        h_birthdt TYPE bu_birthdt.

  DATA: lv_sum_nf TYPE betrw_kk,
        lv_sum_hf TYPE betrw_kk.

  DATA: ls_fkkvk  TYPE fkkvk,                "Nuss 04.2018
        ls_fkkvkp TYPE fkkvkp.               "Nuss 04.2018

  DATA: ls_duedate TYPE dats.                "Nuss 04.2018

  DATA: ls_tfk050at TYPE tfk050at.           "Nuss 05.2018
  DATA: ls_pattern  TYPE char30,             "Nuss 05.2018
        ls_select   TYPE char30,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        ls_lines    TYPE tline,
        lt_lines    TYPE TABLE OF tline,
        lv_object   TYPE thead-tdobject,
        lv_id       TYPE thead-tdid.
  DATA: lv_tdname  TYPE tdobname.

  DATA: lv_wosta(3).

  CONSTANTS: const_marked(1) TYPE c VALUE 'X'.
  CONSTANTS: const_abbri     TYPE /adesso/ink_abbruch VALUE 'SEG'.
*"----------------------------------------------------------------------

  only_xopwo-xopwo   = const_marked.
  only_xreca-xreca   = const_marked.
  only_xagip-xagip   = const_marked.
  only_xfact-xfact   = const_marked.
  only_abbri-abbri   = const_marked.
  only_xsell-xsell   = const_marked.
  only_xdsel-xdsel   = const_marked.
  only_apprse-apprse = const_marked.
  only_apprwo-apprwo = const_marked.
  only_wroff-xwroff  = const_marked.
  newin_xopwo-xopwo  = const_marked.
  newin_xopwo-xopwo  = const_marked.
  newin_xopwo-xnewin = const_marked.

  PERFORM get_customizing.

  CLEAR ls_duedate.
  ls_duedate = sy-datum - x_ovrdue.

  REFRESH et_out.

  LOOP AT it_select.

*   Prüfen Mahnsperre im VK
    CLEAR ls_locks.
    REFRESH lt_locks.
    CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
      EXPORTING
        iv_vkont = it_select-vkont
        iv_gpart = it_select-gpart
        iv_date  = sy-datum
        iv_proid = '01'
      IMPORTING
        et_locks = lt_locks.

    DELETE lt_locks  WHERE lotyp NE '06'.
    READ TABLE lt_locks INTO ls_locks INDEX 1.
    IF sy-subrc NE 0.
      CLEAR ls_locks.
    ENDIF.

    CHECK ls_locks-lockr IN gr_lockr.
    CHECK ls_locks-lockr IN xt_lockr.

    CLEAR it_dfkkop.

    SELECT * FROM dfkkop INTO TABLE it_dfkkop
      WHERE augst = space
        AND gpart = it_select-gpart
        AND vkont = it_select-vkont
*       and hvorg = 'SABR'
        AND hvorg IN gr_hvorg
        AND faedn LT ls_duedate.

    IF it_dfkkop IS NOT INITIAL.

      LOOP AT it_dfkkop INTO wa_dfkkop.

        CLEAR: it_fkkmaze, wa_fkkmaze, mahnv_um .

**   --> Nuss 04.2018
**   Wenn der Beleg einen Ratenplan hat, darf er nicht in der Liste auftauchen
        IF wa_dfkkop-abwtp = 'R'.
          DELETE it_dfkkop INDEX sy-tabix.
          CONTINUE.
        ENDIF.

*    FKKMAZE lesen
**   Prüfen Mahnstufe Mahnverfahren aus Customizing
        SELECT * FROM fkkmaze INTO TABLE it_fkkmaze
*      FOR ALL ENTRIES IN it_dfkkop
          WHERE gpart = wa_dfkkop-gpart
            AND vkont = wa_dfkkop-vkont
            AND opbel = wa_dfkkop-opbel
            AND opupk = wa_dfkkop-opupk
*          AND opupw = wa_dfkkop-opupw
            AND opupz = wa_dfkkop-opupz
            AND xmsto NE 'X'.
*        AND mahns = '02'
*        AND mahnv = 'UM'.

**   --> Nuss 04.2017
        CLEAR gs_inkasso_cust.
        READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
          WITH KEY inkasso_option = 'FKKMAZE'
                   inkasso_field = 'MAHNV'.
*                 inkasso_id = 1.
        IF sy-subrc = 0.
          MOVE gs_inkasso_cust-inkasso_value TO lv_mahnv.
        ENDIF.

        CLEAR gs_inkasso_cust.
        READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
           WITH KEY inkasso_option = 'FKKMAZE'
                    inkasso_field = 'MAHNS'.
        IF sy-subrc = 0.
          MOVE gs_inkasso_cust-inkasso_value TO lv_mahns.
        ENDIF.

**    <-- Nuss 04.2017

*     Jetzt Prüfen, ob die jüngste Mahnung im Mahnverfahren und der Mahnstufe aus dem
*     Customizing ist
        IF it_fkkmaze IS NOT INITIAL.
          SORT it_fkkmaze BY laufd DESCENDING.
          READ TABLE it_fkkmaze INTO wa_fkkmaze INDEX 1.
          IF ( wa_fkkmaze-mahnv = lv_mahnv AND
               wa_fkkmaze-mahns = lv_mahns ).
            mahnv_um = 'X'.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

**  --> Nuss 04.2018
**  Soll das Customizing für MV / MS berücksichtigt werden ?
*    CHECK mahnv_um = 'X'.
    IF x_check IS NOT INITIAL.
      CHECK mahnv_um = 'X'.
    ENDIF.
** <-- Nuss 04.2018

*  Prüfen, ob schon abgegeben ?
    SELECT SINGLE @abap_true FROM dfkkcoll
       WHERE gpart = @it_select-gpart
       AND   vkont = @it_select-vkont
       AND   agsta BETWEEN '02' AND '40'
       INTO  @DATA(exists).

*   Abgegeben, dann nicht nur offene Posen betrachten
    IF sy-subrc = 0  AND
       exists = abap_true.
      REFRESH lt_wheretab.
      CLEAR exists.
*      lw_wheretab = 'INKPS NE ''0'''.
*      APPEND lw_wheretab TO lt_wheretab.
    ELSE.
*     sonst nur offene Posen betrachten
      CHECK it_dfkkop IS NOT INITIAL.
      REFRESH lt_wheretab.
      lw_wheretab = 'AUGST EQ '''''.
      APPEND lw_wheretab TO lt_wheretab.
    ENDIF.

    CLEAR: lt_sfkkop.
    REFRESH lt_sfkkop.

* Jetzt alle OPs zum Vertragskonto lesen
    CALL FUNCTION 'FKK_LINE_ITEMS_SELECT_LOGICAL'
      EXPORTING
        i_vkont     = it_select-vkont
        i_gpart     = it_select-gpart
      TABLES
        pt_logfkkop = lt_sfkkop
        pt_wheretab = lt_wheretab.

    CLEAR:   ls_opt_vkont.
    REFRESH: lt_out_vkont.

* Alle ausgeglichenen, die nie frei-/abgegeben wurden, löschen.
    DELETE lt_sfkkop
           WHERE augst = '9'
           AND   inkps = '000'.

    LOOP AT lt_sfkkop INTO lw_sfkkop.

      CHECK lw_sfkkop-spart IN xt_spart.     "Nuss 04.2018

      CLEAR wa_out.

      MOVE-CORRESPONDING lw_sfkkop TO wa_out.

*    --> Nuss 04.2008
*    Kaufmännische Regionslstukturgruppe und Mahnsperre ausb VK
      PERFORM get_fields_from_vk CHANGING wa_out.
*    <-- Nuss 04.2008

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

* Posten schon in DFKKCOLL und mit welchem Status?
      SELECT SINGLE inkps agsta aggrd inkgp agdat rudat rugrd
             FROM dfkkcoll
             INTO CORRESPONDING FIELDS OF wa_out
                WHERE opbel = wa_out-opbel
                AND   inkps = wa_out-inkps.

      IF sy-subrc NE 0.
*       Prüfen, ob erledigt
        SELECT SINGLE @abap_true FROM dfkkcollh
               WHERE opbel = @wa_out-opbel
               AND   inkps = @wa_out-inkps
               AND   agsta = 'XX'
               INTO  @DATA(finished).

        IF sy-subrc = 0  AND
           finished = abap_true.
          CLEAR finished.
          CONTINUE.
        ENDIF.

        CLEAR: wa_out-inkps, wa_out-agsta, wa_out-aggrd, wa_out-inkgp,
               wa_out-agdat.
      ELSE.
* Prüfen, ob ausgeglichener Posten schon mal abgegeben war
* wenn nein, rausschmeißen
* Steht in DFKKCOLL aber AGDAT leer
* z.B. Storno nach Freigabe vor Abgabe
        IF lw_sfkkop-augdt IS NOT INITIAL.
          IF wa_out-agdat IS INITIAL.
            CONTINUE.
          ENDIF.
        ENDIF.
* wenn schon abgegeben, lesen Name Abgabedatlauf
        SELECT SINGLE laufd laufi FROM dfkkcolfile_p_w
            INTO  (wa_out-laufd, wa_out-laufi)
            WHERE laufd = wa_out-agdat
            AND   opbel = wa_out-opbel
            AND   inkps = wa_out-inkps
            AND   inkgp = wa_out-inkgp.
        IF sy-subrc NE 0.
          CLEAR wa_out-laufd.
          CLEAR wa_out-laufi.
        ENDIF.
      ENDIF.

** Zusätzliche Daten zur Zahlung
** (Zur Sicherheit, wird eigentlich bei Erstellung Info-Datei FPCPI gesetzt)
      IF wa_out-agsta BETWEEN '10' AND '11'.

        CLEAR: lv_dfkkzp-iban.
        CLEAR: lv_iban.

        CLEAR gs_inkasso_cust.
        READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
          WITH KEY inkasso_option   = 'ZAHLUNG'
                   inkasso_category = 'INKGP'
                   inkasso_field    = 'IBAN'.
        IF sy-subrc = 0.
          MOVE gs_inkasso_cust-inkasso_value TO lv_iban.
        ENDIF.


        SELECT SINGLE dfkkzp~iban INTO lv_dfkkzp-iban
               FROM dfkkcollh
                 INNER JOIN dfkkzp
                  ON dfkkzp~opbel = dfkkcollh~augbl
               WHERE dfkkcollh~opbel = wa_out-opbel
               AND   dfkkcollh~inkps = wa_out-inkps
               AND   dfkkcollh~inkgp = wa_out-inkgp
               AND   dfkkcollh~agsta = wa_out-agsta.

        IF sy-subrc = 0 AND
           lv_dfkkzp-iban = lv_iban.
          CASE wa_out-agsta.
            WHEN '10'.
              wa_out-agsta = '03'.
            WHEN '11'.
              wa_out-agsta = '04'.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDIF.

      SELECT SINGLE astxt FROM tfk050at INTO wa_out-agstatxt
           WHERE spras = sy-langu
           AND agsta   = wa_out-agsta.
      IF sy-subrc NE 0.
        wa_out-agstatxt = ' '.
      ENDIF.

*    Übertragen der Daten in die Sammeltabelle
*    Summentabelle wird immer gefüllt, unabhängig davon,
*    ob das VK nacher ausgegeben wird
      MOVE wa_out-gpart TO gs_inkasso_sum-gpart.
      MOVE wa_out-vkont TO gs_inkasso_sum-vkont.
      MOVE wa_out-waers TO gs_inkasso_sum-waers.
      CLEAR gs_nfhf.
      READ TABLE gt_nfhf INTO gs_nfhf
         WITH KEY hvorg = wa_out-hvorg.
      IF sy-subrc = 0 AND gs_nfhf-art = 'HF'.
        wa_out-hf = 'X'.
        MOVE wa_out-betrw TO gs_inkasso_sum-hf.
      ELSE.
        CLEAR gs_nfhf.
        MOVE wa_out-betrw TO gs_inkasso_sum-nf.
      ENDIF.
      COLLECT gs_inkasso_sum INTO gt_inkasso_sum.
      CLEAR gs_inkasso_sum.

      CASE wa_out-agsta.
        WHEN ' '.
          ls_opt_vkont-xagapi = const_marked.
        WHEN '01'.
          ls_opt_vkont-xfrei = const_marked.
        WHEN '02'.
          ls_opt_vkont-xagip = const_marked.
        WHEN '03'  OR '04' OR '06' OR '07' OR '08'.
          ls_opt_vkont-xopwo = const_marked.
        WHEN '05'.
          IF gs_nfhf-schlr = 'X'.
            ls_opt_vkont-xnewin = const_marked.
            wa_out-ssr = 'X'.
          ENDIF.
          ls_opt_vkont-xopwo = const_marked.
        WHEN '09'.
          ls_opt_vkont-xreca  = const_marked.
        WHEN '10'  OR '11' OR '12' OR '13'.
          ls_opt_vkont-xopwo  = const_marked.
        WHEN '20'.
          ls_opt_vkont-xwroff = const_marked.
        WHEN '30'.
          ls_opt_vkont-xsell  = const_marked.
        WHEN '31'.
          ls_opt_vkont-xwroff = const_marked.
        WHEN '32'.
          ls_opt_vkont-xdsel  = const_marked.
        WHEN '97'.
          ls_opt_vkont-xchkd  = const_marked.
        WHEN '98'.
          ls_opt_vkont-xlook  = const_marked.
        WHEN '99'.
          ls_opt_vkont-xvorm  = const_marked.
        WHEN OTHERS.
*         alle anderen Stati erstmal als abgegeben
          ls_opt_vkont-xagip = const_marked.
      ENDCASE.

* Status im Ausbuchungsmonitor
      CLEAR: gs_wo_mon.
      SELECT SINGLE * FROM /adesso/wo_mon
             INTO gs_wo_mon
             WHERE opbel = wa_out-opbel
             AND   opupw = wa_out-opupw
             AND   opupk = wa_out-opupk
             AND   opupz = wa_out-opupz
             AND   inkps = wa_out-inkps.

      IF sy-subrc = 0.
        wa_out-wosta = gs_wo_mon-wosta.
      ELSE.
        CLEAR: wa_out-wosta.
      ENDIF.

* Letzte Info vom Inkassobüro
      REFRESH: gt_ink_infi.
      CLEAR:   gs_ink_infi.

*     Nur Lesen wenn Posten schon abgegeben
      IF wa_out-agdat IS NOT INITIAL.
        SELECT * FROM /adesso/ink_infi
               INTO TABLE gt_ink_infi
               WHERE gpart   =  wa_out-gpart
               AND   vkont   =  wa_out-vkont
               AND   inkgp   =  wa_out-inkgp
               AND   infodat GE wa_out-agdat.
      ENDIF.

      SORT gt_ink_infi BY infodat DESCENDING.
      READ TABLE gt_ink_infi INTO gs_ink_infi INDEX 1.

      IF sy-subrc = 0.
        wa_out-ink_ms  = gs_ink_infi-mahnung.
        wa_out-satztyp = gs_ink_infi-satztyp.
        wa_out-abbruch = gs_ink_infi-abbruch.

        CASE gs_ink_infi-satztyp.
*         Ankaufangebot InkGP
          WHEN 'A'.
            IF wa_out-augdt = '00000000'.
              CASE wa_out-agsta.
*             Verkauf
                WHEN '30'.
                  CASE wa_out-wosta.
                    WHEN space.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-xfact = const_marked.
                    WHEN '01'.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-apprse = const_marked.
                    WHEN '02'.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-apprse = const_marked.
                    WHEN OTHERS.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-xsell = const_marked.
                  ENDCASE.
*               Ablehnung Verkauf, Ausbuchung
                WHEN '20' OR '31'.
                  CASE wa_out-wosta.
                    WHEN space.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-xfact = const_marked.
                    WHEN '01'.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-apprwo = const_marked.
                    WHEN '02'.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-apprwo = const_marked.
                    WHEN OTHERS.
                      CLEAR ls_opt_vkont.
                      ls_opt_vkont-xwroff = const_marked.
                  ENDCASE.
*               Ablehnung Verkauf, weitere Bearbeitung
                WHEN '32'.
                  CLEAR ls_opt_vkont.
                  ls_opt_vkont-xdsel = const_marked.
*               Rückruf, Ablehnung des Verkaufs
                WHEN '09'.
                  CLEAR ls_opt_vkont.
                  ls_opt_vkont-xreca = const_marked.
                WHEN OTHERS.
                  CLEAR ls_opt_vkont.
                  ls_opt_vkont-xfact = const_marked.
              ENDCASE.
            ENDIF.
*         Info vom InkGP
          WHEN 'I'.
            IF wa_out-augdt = '00000000'.
*             nur wenn nicht ausgelichen
              CASE wa_out-agsta.
                WHEN '09'.                  "normaler Rückruf, hier nix machen
                WHEN '20'.                  "Ausbuchung
                  IF wa_out-wosta = '01' OR "Vormerkung Ausbuchung
                     wa_out-wosta = '02'.   "Zur Korrektur
                    CLEAR ls_opt_vkont.
                    ls_opt_vkont-apprwo = const_marked.
                  ELSE.                   "Ausbuchung
                    CLEAR ls_opt_vkont.
                    ls_opt_vkont-xwroff = const_marked.
                  ENDIF.
                WHEN OTHERS.
                  IF gs_ink_infi-ratenvb = 'X'.
*                   Ratenzahlg InkGP
                    ls_opt_vkont-xinspl = const_marked.
                  ENDIF.
                  IF gs_ink_infi-abbruch = const_abbri.
*                   Abbruch durch InkGP
                    CLEAR ls_opt_vkont.
                    ls_opt_vkont-abbri = const_marked.
                  ENDIF.
              ENDCASE.
            ENDIF.
        ENDCASE.
      ELSE.
*       Direkte Ausbuchungen (ohne Abgabe)
        IF wa_out-augdt = '00000000' AND
           wa_out-agsta = '20'.
          IF wa_out-wosta = '01' OR "Vormerkung Ausbuchung
             wa_out-wosta = '02'.   "Zur Korrektur
            CLEAR ls_opt_vkont.
            ls_opt_vkont-apprwo = const_marked.
          ELSE.                   "Ausbuchung
            CLEAR ls_opt_vkont.
            ls_opt_vkont-xwroff = const_marked.
          ENDIF.
        ENDIF.
      ENDIF.

      IF wa_out-inkgp IS NOT INITIAL.

        CALL FUNCTION 'BUP_PARTNER_DESCRIPTION_GET'
          EXPORTING
            i_partner          = wa_out-inkgp
            i_valdt_sel        = sy-datum
          IMPORTING
            e_description_name = wa_out-inkname
          EXCEPTIONS
            OTHERS             = 5.

        IF sy-subrc <> 0.
          wa_out-inkname = '???'.
        ENDIF.

      ENDIF.

* Posten ausgebucht?
      IF wa_out-augrd = '04' OR
        wa_out-augrd = '14'.
        wa_out-ausgeb = 'X'.
        ls_opt_vkont-xopwo = const_marked.
      ENDIF.

*     und dann erstmal alle Posten in die Ausgabetabelle zum VK
      APPEND wa_out TO lt_out_vkont.
      CLEAR wa_out.

    ENDLOOP.

* Nur komplett zurückgerufene
    IF x_opt-xreca = const_marked.
      CASE ls_opt_vkont.
        WHEN only_xreca.
        WHEN OTHERS.
          CLEAR ls_opt_vkont-xreca.
      ENDCASE.
    ENDIF.

* Rechnungsneustellung alles ausgeglichen
    IF x_opt-xnewin = const_marked.
      CASE ls_opt_vkont.
        WHEN newin_xopwo.
          CLEAR ls_opt_vkont-xnewin.
        WHEN OTHERS.
          IF ls_opt_vkont-xnewin = const_marked AND
             ls_opt_vkont-xagip  = const_marked.
            CLEAR ls_opt_vkont-xnewin.
          ENDIF.
      ENDCASE.
    ENDIF.

* Nur komplett beim InkGP
    IF x_opt-xagip = const_marked.
      CASE ls_opt_vkont.
        WHEN only_xagip.
        WHEN OTHERS.
          CLEAR ls_opt_vkont-xagip.
      ENDCASE.
    ENDIF.

* Prüfen was in die Klärung soll
    IF x_opt-xrview = const_marked.
      CASE ls_opt_vkont.
        WHEN only_xopwo.
        WHEN only_xreca.
        WHEN only_xagip.
        WHEN only_xagip.
        WHEN only_xfact.
        WHEN only_abbri.
        WHEN only_xsell.
        WHEN only_xdsel.
        WHEN only_apprse.
        WHEN only_apprwo.
        WHEN only_wroff.
        WHEN OTHERS.
*          IF ls_opt_vkont(5)     = space and
          IF ls_opt_vkont-xinspl = space.
            ls_opt_vkont-xrview = const_marked.
          ENDIF.
          IF ls_opt_vkont-xnewin = const_marked.
            ls_opt_vkont-xrview = const_marked.
          ENDIF.
      ENDCASE.
    ENDIF.

* Nur komplett erledigt
    IF x_opt-xopwo = const_marked.
      CASE ls_opt_vkont.
        WHEN only_xopwo.
        WHEN OTHERS.
          CLEAR ls_opt_vkont-xopwo.
      ENDCASE.
    ENDIF.

* Alle posten zum VK abgearbeitet
* Jetzt entscheiden, ob VK ausgegeben werden soll
    IF ( x_opt-xagapi = const_marked AND ls_opt_vkont-xagapi = const_marked ) OR
       ( x_opt-xvorm  = const_marked AND ls_opt_vkont-xvorm  = const_marked ) OR
       ( x_opt-xlook  = const_marked AND ls_opt_vkont-xlook  = const_marked ) OR
       ( x_opt-xchkd  = const_marked AND ls_opt_vkont-xchkd  = const_marked ) OR
       ( x_opt-xfrei  = const_marked AND ls_opt_vkont-xfrei  = const_marked ) OR
       ( x_opt-xreca  = const_marked AND ls_opt_vkont-xreca  = const_marked ) OR
       ( x_opt-xagip  = const_marked AND ls_opt_vkont-xagip  = const_marked ) OR
       ( x_opt-xopwo  = const_marked AND ls_opt_vkont-xopwo  = const_marked ) OR
       ( x_opt-xinspl = const_marked AND ls_opt_vkont-xinspl = const_marked ) OR
       ( x_opt-xnewin = const_marked AND ls_opt_vkont-xnewin = const_marked ) OR
       ( x_opt-xrview = const_marked AND ls_opt_vkont-xrview = const_marked ) OR
       ( x_opt-xfact  = const_marked AND ls_opt_vkont-xfact  = const_marked ) OR
       ( x_opt-xsell  = const_marked AND ls_opt_vkont-xsell  = const_marked ) OR
       ( x_opt-xdsel  = const_marked AND ls_opt_vkont-xdsel  = const_marked ) OR
       ( x_opt-xwroff = const_marked AND ls_opt_vkont-xwroff = const_marked ) OR
       ( x_opt-abbri  = const_marked AND ls_opt_vkont-abbri  = const_marked ) OR
       ( x_opt-apprse = const_marked AND ls_opt_vkont-apprse = const_marked ) OR
       ( x_opt-apprwo = const_marked AND ls_opt_vkont-apprwo = const_marked ).

      APPEND LINES OF lt_out_vkont TO et_out.

    ENDIF.

  ENDLOOP.

  LOOP AT et_out INTO wa_out.

* Prüfen, ob Vertrag schlussgerechnet ist
* und Status setzen
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

*  --> Nuss 04.2018
*      Mahnverfahren auf Vertragsebene reinschreiben
*      Umzugsmahnverfahren
      IF ls_ever-mahnvumz IS NOT INITIAL.
        wa_out-mahnv = ls_ever-mahnvumz.
        MODIFY et_out FROM wa_out
           TRANSPORTING mahnv.
      ENDIF.
*   <-- Nuss 04.2018

    ENDIF.

* Prüfen ob Mahngebühr mit fakturiert wurde
    SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
    WHERE opbel = wa_out-opbel.

    READ TABLE gt_inkasso_cust TRANSPORTING NO FIELDS
      WITH KEY inkasso_value = ls_dfkkko-blart.

    IF sy-subrc = 0.
      SELECT SINGLE * FROM erdb
             INTO ls_erdb
             WHERE invopbel = wa_out-opbel.
      IF sy-subrc = 0.
        wa_out-xblnr = ls_erdb-opbel.
      ENDIF.
    ENDIF.

    IF wa_out-inkps  >= 998.
*   Special case: internal collection case
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_BUSINAV_PROC_EXIST'
          info                  = TEXT-008
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
      PERFORM set_status_icon USING wa_out-agsta wa_out-status.
    ENDIF.

* Prüfen Ausgleich vor Abgabe
    IF wa_out-agdat = '00000000' AND
       wa_out-agsta BETWEEN '03' AND '19'.
      PERFORM set_status_icon USING 'VA' wa_out-status.
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
*        MOVE wa_fkkmaze-mahnv TO wa_out-mahnv.   "Nuss 04.2018 Mahnverfahren wird oben befüllt
        MOVE wa_fkkmaze-mahns TO wa_out-mahns.

*    --> Nuss 04.2018
*        MODIFY et_out FROM wa_out
*                      TRANSPORTING mahnv mahns.
        MODIFY et_out FROM wa_out
               TRANSPORTING mahns.
*    <-- Nuss 04.2018

      ENDIF.
    ENDIF.

* Prüfen, ob Summe der Nebenforderungen höher als Summe der Hauptforderungen
    READ TABLE gt_inkasso_sum INTO gs_inkasso_sum
       WITH KEY gpart = wa_out-gpart
                vkont = wa_out-vkont.

    CASE gs_inkasso_sum-hf.
      WHEN  0.
        PERFORM create_icon_text
                USING 'ICON_MESSAGE_CRITICAL_SMALL' TEXT-022
                CHANGING wa_out-nfhf.
        MODIFY et_out FROM wa_out TRANSPORTING nfhf.
      WHEN OTHERS.
        IF gs_inkasso_sum-nf GT gs_inkasso_sum-hf.
          PERFORM create_icon_text
                  USING 'ICON_MESSAGE_ERROR_SMALL' TEXT-010
                  CHANGING wa_out-nfhf.
          MODIFY et_out FROM wa_out TRANSPORTING nfhf.
        ELSE.
* oder Gesamt-Betrag < Mindestbetrag
          READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
               WITH KEY inkasso_option   = 'FORDERUNG'
                        inkasso_category = 'MIN'
                        inkasso_field    = 'BETRW'.
          IF sy-subrc = 0.
            gs_sumbtrg = gs_inkasso_sum-hf + gs_inkasso_sum-nf.
            IF gs_sumbtrg < gs_inkasso_cust-inkasso_value.
              PERFORM create_icon_text
                      USING 'ICON_MESSAGE_WARNING_SMALL' TEXT-023
                      CHANGING wa_out-nfhf.
              MODIFY et_out FROM wa_out TRANSPORTING nfhf.
            ENDIF.
          ENDIF.

        ENDIF.
    ENDCASE.

*   Name und Geburtsdatum des Geschäftspartners
    SELECT SINGLE * FROM but000 INTO gs_but000
      WHERE partner = wa_out-gpart.

    CASE gs_but000-type.
      WHEN '1'.
*  --> Nuss 04.2018
*        CONCATENATE gs_but000-name_first
*                    gs_but000-name_last
*                    INTO wa_out-name
*                    SEPARATED BY space.
*        MODIFY et_out FROM wa_out TRANSPORTING name.
        MOVE gs_but000-name_first TO wa_out-name.
        MOVE gs_but000-name_last TO wa_out-name2.
        MODIFY et_out FROM wa_out TRANSPORTING name name2.
*   <-- Nuss 04.2018
      WHEN '2'.
*    --> Nuss 04.2018
*        CONCATENATE gs_but000-name_org1
*                    gs_but000-name_org2
*                    INTO wa_out-name
*                    SEPARATED BY space.
*        MODIFY et_out FROM wa_out TRANSPORTING name.
        MOVE gs_but000-name_org1 TO wa_out-name.
        MOVE gs_but000-name_org2 TO wa_out-name2.
        MOVE gs_but000-name_org3 TO wa_out-name3.
        MODIFY et_out FROM wa_out TRANSPORTING name name2 name3.
*      <-- Nuss 04.2018
      WHEN '3'.
*      --> Nuss 04.2018
*        CONCATENATE gs_but000-name_grp1
*                    gs_but000-name_grp2
*                    INTO wa_out-name
*                    SEPARATED BY space.
*        MODIFY et_out FROM wa_out TRANSPORTING name.
        MOVE gs_but000-name_grp1 TO wa_out-name.
        MOVE gs_but000-name_grp2 TO wa_out-name2.
        MODIFY et_out FROM wa_out TRANSPORTING name name2.
*     <-- Nuss 04.2018
    ENDCASE.

*  --> Nuss 04.2018
    IF gs_but000-birthdt IS NOT INITIAL.
      MOVE gs_but000-birthdt TO wa_out-birthdt.
      MODIFY et_out FROM wa_out TRANSPORTING birthdt.
    ENDIF.

*  Liegt eine Mahnsperre vor
    IF wa_out-lockr IN gr_lockr OR
       wa_out-lockr IS INITIAL.
* Bearbeitung erlaubt
    ELSE.
      PERFORM set_status_icon USING 'L' wa_out-locked.
      MODIFY et_out FROM wa_out TRANSPORTING locked.
    ENDIF.


** Freitextfeld und Zusatzinfos noch rein
    CLEAR gs_ink_addi.
    SELECT SINGLE * FROM /adesso/ink_addi
           INTO gs_ink_addi
           WHERE gpart = wa_out-gpart
           AND   vkont = wa_out-vkont
           AND   inkgp = wa_out-inkgp
           AND   agdat = wa_out-agdat.

    IF sy-subrc = 0.
      wa_out-freetext  = gs_ink_addi-freetext.
      wa_out-unbverz   = gs_ink_addi-unbverz.
      wa_out-minderj   = gs_ink_addi-minderj.
      wa_out-erbenhaft = gs_ink_addi-erbenhaft.
      wa_out-betreuung = gs_ink_addi-betreuung.
      wa_out-insolvenz = gs_ink_addi-insolvenz.
      MODIFY et_out FROM wa_out
             TRANSPORTING freetext  unbverz   minderj
                          erbenhaft betreuung insolvenz.
    ENDIF.

* Letzte Info vom Inkassobüro
    REFRESH: gt_ink_infi.
    CLEAR:   gs_ink_infi.

    SELECT * FROM /adesso/ink_infi
           INTO TABLE gt_ink_infi
           WHERE gpart = wa_out-gpart
           AND   vkont = wa_out-vkont
           AND   inkgp = wa_out-inkgp.

    SORT gt_ink_infi BY infodat DESCENDING.
    READ TABLE gt_ink_infi INTO gs_ink_infi INDEX 1.
    IF sy-subrc = 0.
      wa_out-infodat = gs_ink_infi-infodat.
      wa_out-ink_akte = gs_ink_infi-ink_akte.
      CASE gs_ink_infi-satztyp.
        WHEN 'A'.
          PERFORM set_status_icon USING 'A' wa_out-infosta.
        WHEN 'I'.
          IF gs_ink_infi-abbruch = const_abbri.
            PERFORM set_status_icon USING 'C' wa_out-infosta.
          ELSE.
            PERFORM set_status_icon USING 'I' wa_out-infosta.
          ENDIF.
      ENDCASE.
      MODIFY et_out FROM wa_out TRANSPORTING infodat infosta ink_akte.
    ENDIF.

* Status Ausbuchungsmonitor
    IF wa_out-wosta IS NOT INITIAL.
      CONCATENATE 'W' wa_out-wosta INTO lv_wosta.
      PERFORM set_status_icon USING lv_wosta wa_out-infosta.
      MODIFY et_out FROM wa_out TRANSPORTING infosta.
    ELSE.
      IF wa_out-agsta = '32'.
        PERFORM set_status_icon USING 'B' wa_out-infosta.
        MODIFY et_out FROM wa_out TRANSPORTING infosta.
      ENDIF.
    ENDIF.

*   Interne Vermerke
*   --> Nuss 05.2018
    CLEAR: ls_pattern, ls_select, ls_stxh, lt_stxh.

    CLEAR gs_inkasso_cust.
    READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
      WITH KEY inkasso_option = 'INTVERM'
               inkasso_field  = 'TDOBJECT'.

    IF sy-subrc = 0.
      MOVE gs_inkasso_cust-inkasso_value TO lv_object.
    ENDIF.


    CLEAR gs_inkasso_cust.
    READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
      WITH KEY inkasso_option = 'INTVERM'
               inkasso_field  = 'TDID'.

    IF sy-subrc = 0.
      MOVE gs_inkasso_cust-inkasso_value TO lv_id.
    ENDIF.

    CONCATENATE wa_out-gpart
                '_'
                wa_out-vkont
                '_'
                INTO ls_pattern.

    CONCATENATE ls_pattern '%' INTO ls_select.

    SELECT * FROM stxh INTO TABLE lt_stxh
             WHERE tdobject = lv_object
             AND tdname LIKE ls_select
             AND tdid = lv_id
             AND tdspras = sy-langu.

    SORT lt_stxh BY tdname DESCENDING.

    READ TABLE lt_stxh INTO ls_stxh INDEX 1.

    IF sy-subrc = 0.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lv_id
          language                = sy-langu
          name                    = ls_stxh-tdname
          object                  = lv_object
        TABLES
          lines                   = lt_lines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

    IF lt_lines IS NOT INITIAL.
      READ TABLE lt_lines INTO ls_lines INDEX 1.
      MOVE ls_lines-tdline TO wa_out-intverm.
      MODIFY et_out FROM wa_out TRANSPORTING intverm.
      CLEAR lt_lines.
    ENDIF.

* Dokumentation Ausbuchung vorhanden ?

    CLEAR gs_inkasso_cust.
    READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
         WITH KEY inkasso_option   = 'AUSBUCHUNG'
                  inkasso_category = 'DOCU'
                  inkasso_field    = 'TDOBJECT'.

    IF sy-subrc = 0.
      MOVE gs_inkasso_cust-inkasso_value TO lv_object.
    ENDIF.

    CLEAR gs_inkasso_cust.
    READ TABLE gt_inkasso_cust INTO gs_inkasso_cust
         WITH KEY inkasso_option   = 'AUSBUCHUNG'
                  inkasso_category = 'DOCU'
                  inkasso_field    = 'TDID'.

    IF sy-subrc = 0.
      MOVE gs_inkasso_cust-inkasso_value TO lv_id.
    ENDIF.

    CONCATENATE wa_out-gpart '_'
                wa_out-vkont '_'
                 '001'
                INTO lv_tdname.

*  Prüfen, ob Docu existiert
    SELECT SINGLE @abap_true FROM stxh
           WHERE tdobject = @lv_object
           AND   tdname   = @lv_tdname
           AND   tdid     = @lv_id
           AND   tdspras  = @sy-langu
           INTO  @DATA(docu_exists).

    IF sy-subrc = 0  AND
       docu_exists = abap_true.
      PERFORM set_status_icon
              USING 'DOCU'
                    wa_out-ic_docu.
    ELSE.
      PERFORM set_status_icon
              USING 'NODOCU'
                    wa_out-ic_docu.
    ENDIF.
    CLEAR docu_exists.

    IF wa_out-hvorg IN gr_hvorg.
* Infos im Ausbuchungsmonitor
      CLEAR: gs_wo_mon.
      SELECT SINGLE * FROM /adesso/wo_mon
             INTO gs_wo_mon
             WHERE opbel = wa_out-opbel
             AND   opupw = wa_out-opupw
             AND   opupk = wa_out-opupk
             AND   opupz = wa_out-opupz
             AND   inkps = wa_out-inkps.

      IF sy-subrc = 0.
        CONCATENATE wa_out-ic_docu  ' '
                    gs_wo_mon-abgrd '_'
                    gs_wo_mon-woigd '_'
                    gs_wo_mon-wovks
                    INTO wa_out-ic_docu.
      ENDIF.
    ENDIF.
    MODIFY et_out FROM wa_out TRANSPORTING ic_docu.

  ENDLOOP.


ENDFUNCTION.
