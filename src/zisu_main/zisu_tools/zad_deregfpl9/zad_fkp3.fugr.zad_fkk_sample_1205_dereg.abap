FUNCTION ZAD_FKK_SAMPLE_1205_DEREG.
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

CONSTANTS: co_false   TYPE KENNZ VALUE 'X',
           co_deritm  LIKE DFKKTHI-CRSRF VALUE 'DERITM',
           co_segnam_unb like edid4-segnam value '/ISIDEX/E1VDEWUNB_1'.


DATA: h_csrf      LIKE DFKKTHI-CRSRF,     "int. Crossreferenz
      h_stkz      LIKE DFKKTHI-STIDC,     "Storno-Kennzeichen
      h_herkf     LIKE DFKKKO-HERKF.      "Belegherkunft

DATA: BEGIN OF s_beleg,                   "Struktur Belegposition
        f_opbel LIKE DFKKOP-OPBEL,
        f_opupk LIKE DFKKOP-OPUPK,
        f_opupz LIKE DFKKOP-OPUPZ,
      END OF s_beleg.

DATA: BEGIN OF s_thidat,                        "Struktur DFKKTHI-Daten
        f_date    TYPE DATS,                    "Übertragungsdatum
        f_inv     LIKE DFKKTHI-BCBLN,           "Agg. Beleg / Verteilstapel
        f_recid   LIKE DFKKTHI-RECID,           "Serviceanbieter
        f_prn     TYPE CROSSREFNO,              "ext. Crossreferenz
        f_contrl  type EDI_DOCNUM,              "Idoc Contrl (Aggr)
        f_bulkref type char14,                  "Bulk_Ref Contrl
      END OF s_thidat.

data: s_vdewunb type e1vdewunb.
data: s_edid4   type edid4.

DATA: BEGIN of s_avis,
        f_extinv    TYPE INV_EXT_INVOICE_NO,    "ext. Avisnr
        f_avis(4)   TYPE c,                     "Avisart
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

  SELECT SINGLE HERKF FROM DFKKKO INTO h_herkf
    WHERE OPBEL = I_POSTAB-OPBEL.


* Verarbeitung Rechnung

  IF h_herkf NE '05' AND h_herkf NE '09' AND h_herkf IS NOT INITIAL.

    CASE h_herkf.


* Ermittlung int. Crossreferenz - Abschlag und Faktura

    WHEN 'R4' OR 'RA'.

    SELECT MAX( CRSRF ) FROM DFKKTHI INTO h_csrf
      WHERE OPBEL = I_POSTAB-OPBEL
      AND   OPUPK = I_POSTAB-OPUPK
      AND   OPUPZ = I_POSTAB-OPUPZ
      AND   STIDC NE co_false.


* Ermittlung int. Crossreferenz - Storno

    WHEN 'R9'.

    h_stkz = co_false.        "Kennzeichen für Storno

    SELECT OPBEL OPUPK OPUPZ FROM DFKKOP INTO s_beleg
      WHERE AUGBL = I_POSTAB-OPBEL.
    ENDSELECT.

    SELECT MAX( CRSRF ) FROM DFKKTHI INTO h_csrf
      WHERE OPBEL = s_beleg-f_opbel
      AND   OPUPK = s_beleg-f_opupk
      AND   OPUPZ = s_beleg-f_opupz
      AND   STIDC EQ co_false.


* Ermittlung int. Crossreferenz - Sonstige Belege für Rechnungsstellung (Manuelle Buchungen, Zinsen, etc.)

    WHEN '01' OR '07'.

      IF I_POSTAB-AUGRD = '05'.

        h_stkz = co_false.      "Kennzeichen für Storno

          SELECT MAX( CRSRF ) FROM DFKKTHI INTO h_csrf
          WHERE OPBEL = I_POSTAB-OPBEL
          AND   OPUPK = I_POSTAB-OPUPK
          AND   OPUPZ = I_POSTAB-OPUPZ
          AND   STIDC EQ co_false.

      ELSE.
          SELECT MAX( CRSRF ) FROM DFKKTHI INTO h_csrf
          WHERE OPBEL = I_POSTAB-OPBEL
          AND   OPUPK = I_POSTAB-OPUPK
          AND   OPUPZ = I_POSTAB-OPUPZ
          AND   STIDC NE co_false.
      ENDIF.

    ENDCASE.


* Abfangen des Sonderfall "Untere Position noch nicht versendet": Ext. Crossref. und THI-Status nicht ermittelbar

    IF h_csrf = co_deritm OR h_csrf IS INITIAL.

      s_thidat-f_prn = TEXT-Z04. "Ausgabe Text bei Crossreferenz DERITM

    ELSE.


* Rechnung: Ermittlung xt. Crossreferenz, Übertragungsdatum, agg. Beleg und Fakt.SA

      IF h_stkz IS INITIAL.   "Ermittlung für Storno
         SELECT SINGLE CROSSREFNO FROM ECROSSREFNO INTO s_thidat-f_prn
           WHERE INT_CROSSREFNO = h_csrf.

         SELECT SINGLE THPRD      as f_date
                       BCBLN      as f_inv
                       RECID      as f_recid
                FROM DFKKTHI
                INTO corresponding fields of s_thidat
                WHERE  CRSRF = h_csrf
                AND    BUREL = co_false
                AND    STIDC NE co_false.

      ELSE.                   "Ermittlung für Nicht-Storno
         SELECT SINGLE CRN_REV FROM ECROSSREFNO INTO s_thidat-f_prn
           WHERE INT_CROSSREFNO = h_csrf.

         SELECT SINGLE THPRD      as f_date
                       BCBLN      as f_inv
                       RECID      as f_recid
                FROM DFKKTHI
                INTO corresponding fields of s_thidat
                WHERE  CRSRF = h_csrf
                AND    BUREL = co_false
                AND    STIDC EQ co_false.

      ENDIF.

    ENDIF.


* Zahlungseingang: Avisdatum, Verteilstapel, Fakt. SA und ext. Crossref aus Avis

  ELSEIF h_herkf = '05'.

    SELECT d~INVOICE_DATE   as f_date
           a~KEYZ1          as f_inv
           e~INT_SENDER     as f_recid
           c~OWN_INVOICE_NO as f_prn
      INTO corresponding fields of s_thidat
      FROM (  ( ( ( DFKKZP AS a
                    INNER JOIN IUEEDPPLOTATREF AS b
                    ON a~KEYZ1 = b~KEYZ1
                    AND a~POSZA = b~POSZA )
                    INNER JOIN TINV_INV_LINE_A AS c
                    ON b~TINV_DOC = c~INT_INV_DOC_NO
                    AND b~TINV_LINE = c~INT_INV_LINE_NO )
                    INNER JOIN TINV_INV_DOC AS d
                    ON c~INT_INV_DOC_NO = d~INT_INV_DOC_NO )
                    INNER JOIN TINV_INV_HEAD AS e
                    ON d~INT_INV_NO = e~INT_INV_NO )
      WHERE a~OPBEL = I_POSTAB-OPBEL.
    ENDSELECT.

    IF SY-SUBRC <> 0.   "Zahlbeleg nicht gefunden, daher Suche über Klärungsbeleg

      SELECT d~INVOICE_DATE   as f_date
             a~KEYZ1          as f_inv
             e~INT_SENDER     as f_recid
             c~OWN_INVOICE_NO as f_prn
        INTO corresponding fields of s_thidat
        FROM (  ( ( ( DFKKZP AS a
                      INNER JOIN IUEEDPPLOTATREF AS b
                      ON a~KEYZ1 = b~KEYZ1
                      AND a~POSZA = b~POSZA )
                      INNER JOIN TINV_INV_LINE_A AS c
                      ON b~TINV_DOC = c~INT_INV_DOC_NO
                      AND b~TINV_LINE = c~INT_INV_LINE_NO )
                      INNER JOIN TINV_INV_DOC AS d
                      ON c~INT_INV_DOC_NO = d~INT_INV_DOC_NO )
                      INNER JOIN TINV_INV_HEAD AS e
                      ON d~INT_INV_NO = e~INT_INV_NO )
        WHERE a~KLAEB = I_POSTAB-OPBEL.
      ENDSELECT.

    ENDIF.

  ELSEIF h_herkf = '09'.

    s_thidat-f_prn = TEXT-Z03.

  ENDIF.


* Ermittlung vorliegender Avise (Art und Nr.) anhand ext. Crossrefno

  IF s_thidat-f_prn IS NOT INITIAL AND s_thidat-f_prn NE co_deritm.

    SELECT b~INT_INV_DOC_NO b~DOC_TYPE INTO s_avis
      FROM (  TINV_INV_LINE_A AS a
              INNER JOIN TINV_INV_DOC AS b
              ON a~INT_INV_DOC_NO = b~INT_INV_DOC_NO )
      WHERE a~OWN_INVOICE_NO = s_thidat-f_prn
      ORDER BY b~DOC_TYPE DESCENDING.
    ENDSELECT.

    SHIFT s_avis-f_extinv LEFT DELETING LEADING '0'.

* Avisart in Text umwandeln

    IF s_avis-f_avis = 4.
       s_avis-f_avis = TEXT-Z01.
    ELSEIF s_avis-f_avis = 9.
       s_avis-f_avis = TEXT-Z02.
    ENDIF.

  ENDIF.


* Ermittlung der Mahnstufe für Deregulierung (im SAP-Standard nicht verfügbar)

  IF h_csrf IS NOT INITIAL AND h_csrf NE co_deritm AND I_POSTAB-MAHNS IS INITIAL.

    SELECT MAX( MAHNS ) FROM FKKMAZE INTO I_POSTAB-MAHNS
      WHERE OPBEL = I_POSTAB-OPBEL
      AND   OPUPK = I_POSTAB-OPUPK
      AND   OPUPZ = I_POSTAB-OPUPZ
      AND   MDRKD NE '00000000'
      AND   XMSTO NE co_false.

  ENDIF.


* Ermittlung Bulk_Ref aus Invoic Idoc
  IF s_thidat-f_contrl IS NOT INITIAL.

    SELECT single * FROM edid4 INTO s_edid4
      WHERE docnum = s_thidat-f_contrl
      AND   segnam = co_segnam_unb.

    if sy-subrc = 0.
      s_vdewunb = s_edid4-sdata.
    else.
      clear s_vdewunb.
    endif.

  ENDIF.

* Zuweisung der ermittelten Daten zur Ausgabestruktur

  I_POSTAB-ZZCROSSREFNO  = s_thidat-f_prn.     "ext. Crossreferenz
  I_POSTAB-ZZINV         = s_thidat-f_inv.     "Agg. Beleg / Verteilstapel
  I_POSTAB-ZZINVDATE     = s_thidat-f_date.    "Übertragungsdatum
  I_POSTAB-ZZRECID       = s_thidat-f_recid.   "Serviceanbieter
  I_POSTAB-ZZAVISART     = s_avis-f_avis.      "Avisart
  I_POSTAB-ZZAVIS2       = s_avis-f_extinv.    "ext. Avisnr.
  I_POSTAB-ZZBULKREF     = s_vdewunb-bulk_ref. "Bulk_ref Invoic Contrl (Aggr)

  E_POSTAB = I_POSTAB.

ENDFUNCTION.
