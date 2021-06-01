FUNCTION /adesso/fkk_1205_dereg.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_POSTAB) LIKE  FKKEPOS STRUCTURE  FKKEPOS
*"     VALUE(I_FKKL1) LIKE  FKKL1 STRUCTURE  FKKL1 OPTIONAL
*"     VALUE(I_FKKEPOSC) LIKE  FKKEPOSC STRUCTURE  FKKEPOSC OPTIONAL
*"     VALUE(I_HEADER_ARC) LIKE  FKKKO STRUCTURE  FKKKO OPTIONAL
*"     VALUE(I_FIRST_CALL) TYPE  BOOLEAN DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_POSTAB) LIKE  FKKEPOS STRUCTURE  FKKEPOS
*"     VALUE(E_DO_NOT_DISPLAY_LINE) TYPE  BOOLEAN
*"     VALUE(E_ONLY_SHOW_IN_PAYMENT_LIST) TYPE  BOOLEAN
*"----------------------------------------------------------------------
  CONSTANTS: co_false      TYPE kennz VALUE 'X',
             co_deritm     LIKE dfkkthi-crsrf VALUE 'DERITM',
             co_segnam_unb LIKE edid4-segnam VALUE '/ISIDEX/E1VDEWUNB_1'.


  DATA: h_csrf  LIKE dfkkthi-crsrf,     "int. Crossreferenz
        h_stkz  LIKE dfkkthi-stidc,     "Storno-Kennzeichen
        h_herkf LIKE dfkkko-herkf.      "Belegherkunft

  DATA: BEGIN OF s_beleg,                   "Struktur Belegposition
          f_opbel LIKE dfkkop-opbel,
          f_opupk LIKE dfkkop-opupk,
          f_opupz LIKE dfkkop-opupz,
        END OF s_beleg.

  DATA: BEGIN OF s_thidat,                        "Struktur DFKKTHI-Daten
          f_date    TYPE dats,                    "Übertragungsdatum
          f_inv     LIKE dfkkthi-bcbln,           "Agg. Beleg / Verteilstapel
          f_recid   LIKE dfkkthi-recid,           "Serviceanbieter
          f_prn     TYPE crossrefno,              "ext. Crossreferenz
          f_contrl  TYPE edi_docnum,              "Idoc Contrl (Aggr)
          f_bulkref TYPE char14,                  "Bulk_Ref Contrl
        END OF s_thidat.

  DATA: s_vdewunb TYPE e1vdewunb.
  DATA: s_edid4   TYPE edid4.

  DATA: BEGIN OF s_avis,
          f_extinv  TYPE inv_ext_invoice_no,    "ext. Avisnr
          f_avis(4) TYPE c,                     "Avisart
        END OF s_avis.

  CLEAR: h_csrf, h_stkz, s_beleg, s_avis, h_herkf, s_thidat, s_vdewunb.

* Aufruf des bisher verwendeten Funktionsbaustein

  CALL FUNCTION 'ISU_ACC_DISP_BASIC_LIST_1205'
    EXPORTING
      i_postab                    = i_postab
      i_fkkl1                     = i_fkkl1
      i_langu                     = sy-langu
    IMPORTING
      e_postab                    = i_postab
      e_do_not_display_line       = e_do_not_display_line
      e_only_show_in_payment_list = e_only_show_in_payment_list.



* Verarbeitung
* Die weitere Verarbeitung erfolgt in Abhängigkeit vom Hernkunftschlüssel des Beleg

  SELECT SINGLE herkf FROM dfkkko INTO h_herkf
    WHERE opbel = i_postab-opbel.


* Verarbeitung Rechnung

  IF h_herkf NE '05' AND h_herkf NE '09' AND h_herkf IS NOT INITIAL.

    CASE h_herkf.


* Ermittlung int. Crossreferenz - Abschlag und Faktura

      WHEN 'R4' OR 'RA'.

        SELECT MAX( crsrf ) FROM dfkkthi INTO h_csrf
          WHERE opbel = i_postab-opbel
          AND   opupk = i_postab-opupk
          AND   opupz = i_postab-opupz
          AND   stidc NE co_false.


* Ermittlung int. Crossreferenz - Storno

      WHEN 'R9'.

        h_stkz = co_false.        "Kennzeichen für Storno

        SELECT opbel opupk opupz FROM dfkkop INTO s_beleg
          WHERE augbl = i_postab-opbel.
        ENDSELECT.

        SELECT MAX( crsrf ) FROM dfkkthi INTO h_csrf
          WHERE opbel = s_beleg-f_opbel
          AND   opupk = s_beleg-f_opupk
          AND   opupz = s_beleg-f_opupz
          AND   stidc EQ co_false.


* Ermittlung int. Crossreferenz - Sonstige Belege für Rechnungsstellung (Manuelle Buchungen, Zinsen, etc.)

      WHEN '01' OR '07'.

        IF i_postab-augrd = '05'.

          h_stkz = co_false.      "Kennzeichen für Storno

          SELECT MAX( crsrf ) FROM dfkkthi INTO h_csrf
          WHERE opbel = i_postab-opbel
          AND   opupk = i_postab-opupk
          AND   opupz = i_postab-opupz
          AND   stidc EQ co_false.

        ELSE.
          SELECT MAX( crsrf ) FROM dfkkthi INTO h_csrf
          WHERE opbel = i_postab-opbel
          AND   opupk = i_postab-opupk
          AND   opupz = i_postab-opupz
          AND   stidc NE co_false.
        ENDIF.

    ENDCASE.


* Abfangen des Sonderfall "Untere Position noch nicht versendet": Ext. Crossref. und THI-Status nicht ermittelbar

    IF h_csrf = co_deritm OR h_csrf IS INITIAL.

      s_thidat-f_prn = text-z04. "Ausgabe Text bei Crossreferenz DERITM

    ELSE.


* Rechnung: Ermittlung xt. Crossreferenz, Übertragungsdatum, agg. Beleg und Fakt.SA

      IF h_stkz IS INITIAL.   "Ermittlung für Storno
        SELECT SINGLE crossrefno FROM ecrossrefno INTO s_thidat-f_prn
          WHERE int_crossrefno = h_csrf.

        SELECT SINGLE thprd      AS f_date
                      bcbln      AS f_inv
                      recid      AS f_recid
               FROM dfkkthi
               INTO CORRESPONDING FIELDS OF s_thidat
               WHERE  crsrf = h_csrf
               AND    burel = co_false
               AND    stidc NE co_false.

      ELSE.                   "Ermittlung für Nicht-Storno
        SELECT SINGLE crn_rev FROM ecrossrefno INTO s_thidat-f_prn
          WHERE int_crossrefno = h_csrf.

        SELECT SINGLE thprd      AS f_date
                      bcbln      AS f_inv
                      recid      AS f_recid
               FROM dfkkthi
               INTO CORRESPONDING FIELDS OF s_thidat
               WHERE  crsrf = h_csrf
               AND    burel = co_false
               AND    stidc EQ co_false.

      ENDIF.

    ENDIF.


* Zahlungseingang: Avisdatum, Verteilstapel, Fakt. SA und ext. Crossref aus Avis

  ELSEIF h_herkf = '05'.

    SELECT d~invoice_date   AS f_date
           a~keyz1          AS f_inv
           e~int_sender     AS f_recid
           c~own_invoice_no AS f_prn
      INTO CORRESPONDING FIELDS OF s_thidat
      FROM (  ( ( ( dfkkzp AS a
                    INNER JOIN iueedpplotatref AS b
                    ON a~keyz1 = b~keyz1
                    AND a~posza = b~posza )
                    INNER JOIN tinv_inv_line_a AS c
                    ON b~tinv_doc = c~int_inv_doc_no
                    AND b~tinv_line = c~int_inv_line_no )
                    INNER JOIN tinv_inv_doc AS d
                    ON c~int_inv_doc_no = d~int_inv_doc_no )
                    INNER JOIN tinv_inv_head AS e
                    ON d~int_inv_no = e~int_inv_no )
      WHERE a~opbel = i_postab-opbel.
    ENDSELECT.

    IF sy-subrc <> 0.   "Zahlbeleg nicht gefunden, daher Suche über Klärungsbeleg

      SELECT d~invoice_date   AS f_date
             a~keyz1          AS f_inv
             e~int_sender     AS f_recid
             c~own_invoice_no AS f_prn
        INTO CORRESPONDING FIELDS OF s_thidat
        FROM (  ( ( ( dfkkzp AS a
                      INNER JOIN iueedpplotatref AS b
                      ON a~keyz1 = b~keyz1
                      AND a~posza = b~posza )
                      INNER JOIN tinv_inv_line_a AS c
                      ON b~tinv_doc = c~int_inv_doc_no
                      AND b~tinv_line = c~int_inv_line_no )
                      INNER JOIN tinv_inv_doc AS d
                      ON c~int_inv_doc_no = d~int_inv_doc_no )
                      INNER JOIN tinv_inv_head AS e
                      ON d~int_inv_no = e~int_inv_no )
        WHERE a~klaeb = i_postab-opbel.
      ENDSELECT.

    ENDIF.

  ELSEIF h_herkf = '09'.

    s_thidat-f_prn = text-z03.

  ENDIF.


* Ermittlung vorliegender Avise (Art und Nr.) anhand ext. Crossrefno

  IF s_thidat-f_prn IS NOT INITIAL AND s_thidat-f_prn NE co_deritm.

    SELECT b~int_inv_doc_no b~doc_type INTO s_avis
      FROM (  tinv_inv_line_a AS a
              INNER JOIN tinv_inv_doc AS b
              ON a~int_inv_doc_no = b~int_inv_doc_no )
      WHERE a~own_invoice_no = s_thidat-f_prn
      ORDER BY b~doc_type DESCENDING.
    ENDSELECT.

    SHIFT s_avis-f_extinv LEFT DELETING LEADING '0'.

* Avisart in Text umwandeln

    IF s_avis-f_avis = 4.
      s_avis-f_avis = text-z01.
    ELSEIF s_avis-f_avis = 9.
      s_avis-f_avis = text-z02.
    ENDIF.

  ENDIF.


* Ermittlung der Mahnstufe für Deregulierung (im SAP-Standard nicht verfügbar)

  IF h_csrf IS NOT INITIAL AND h_csrf NE co_deritm AND i_postab-mahns IS INITIAL.

    SELECT MAX( mahns ) FROM fkkmaze INTO i_postab-mahns
      WHERE opbel = i_postab-opbel
      AND   opupk = i_postab-opupk
      AND   opupz = i_postab-opupz
      AND   mdrkd NE '00000000'
      AND   xmsto NE co_false.

  ENDIF.


* Ermittlung Bulk_Ref aus Invoic Idoc
  IF s_thidat-f_contrl IS NOT INITIAL.

    SELECT SINGLE * FROM edid4 INTO s_edid4
      WHERE docnum = s_thidat-f_contrl
      AND   segnam = co_segnam_unb.

    IF sy-subrc = 0.
      s_vdewunb = s_edid4-sdata.
    ELSE.
      CLEAR s_vdewunb.
    ENDIF.

  ENDIF.

* Zuweisung der ermittelten Daten zur Ausgabestruktur

  i_postab-zzcrossrefno  = s_thidat-f_prn.     "ext. Crossreferenz
  i_postab-zzinv         = s_thidat-f_inv.     "Agg. Beleg / Verteilstapel
  i_postab-zzinvdate     = s_thidat-f_date.    "Übertragungsdatum
  i_postab-zzrecid       = s_thidat-f_recid.   "Serviceanbieter
  i_postab-zzavisart     = s_avis-f_avis.      "Avisart
  i_postab-zzavis2       = s_avis-f_extinv.    "ext. Avisnr.
  i_postab-zzbulkref     = s_vdewunb-bulk_ref. "Bulk_ref Invoic Contrl (Aggr)

  e_postab = i_postab.





ENDFUNCTION.
