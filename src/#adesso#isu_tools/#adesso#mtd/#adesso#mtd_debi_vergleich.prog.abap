*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_DEBI_VERGLEICH
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_DEBI_VERGLEICH.

TABLES: fkkvk, fkkvkp, dfkkop, dfkkopw, eabp.
PARAMETERS: vkontmin LIKE fkkvk-vkont NO-DISPLAY.
PARAMETERS: vkontmax LIKE fkkvk-vkont NO-DISPLAY.
SELECT-OPTIONS: so_vkont FOR dfkkop-vkont, " no extension  01.07.08_kb
                s_bukrs FOR dfkkop-bukrs NO-DISPLAY.
PARAMETERS: aend_ab  LIKE dfkkko-cpudt.
PARAMETERS: abs_bis  LIKE dfkkko-cpudt DEFAULT '99991231'.
*                                        Datum, bis zu dem Abschläge
*                                        berücksichtigt werden sollen

PARAMETERS: s_vkont TYPE c RADIOBUTTON GROUP s1.
PARAMETERS: s_gpart TYPE c RADIOBUTTON GROUP s1.

SELECTION-SCREEN SKIP 1.
 .
PARAMETERS: fname LIKE rlgrap-filename. "Pfad-Unix

PARAMETERS: dat_aus AS CHECKBOX DEFAULT ' '.


DATA: betrw LIKE dfkkop-betrw.
DATA: BEGIN OF vkont OCCURS 0,
        vkont LIKE fkkvk-vkont,
        gpart LIKE fkkvkp-gpart,
        vkona LIKE fkkvk-vkona,
        abs_zahl LIKE dfkkop-betrw,
        abs_ford LIKE dfkkop-betrw,
        saldo LIKE dfkkop-betrw,
        aend  TYPE c,              " VK wurde geändert
      END OF vkont.

* interne Tabelle für Ausgabe in Datei    (Kle)
DATA: BEGIN OF vkonta OCCURS 0,
        vkont(12) TYPE c,      " LIKE FKKVK-VKONT,
        gpart(10) TYPE c,      " LIKE FKKVKP-GPART,
        vkona(11) TYPE c,      " LIKE FKKVK-VKONA,
        vz1(1)    TYPE c,      " Vorzeichen
        abs_zahl(10) TYPE c,   " LIKE DFKKOP-betrw,
        vz2(1)    TYPE c,      " Vorzeichen
        abs_ford(10) TYPE c,   " LIKE DFKKOP-betrw,
        vz3(1)    TYPE c,      " Vorzeichen
        saldo(10) TYPE c,      " LIKE DFKKOP-betrw,
        vz4(1)    TYPE c,      " Vorzeichen
        betrw(10) TYPE c,      " Saldo mit Abschläge
        aend  TYPE c,          " VK wurde geändert
      END OF vkonta.
*




DATA: BEGIN OF wa_eabp OCCURS 0,
        aedat LIKE eabp-aedat,
      END OF wa_eabp.


DATA: t_index LIKE sy-tabix.
DATA: wa_dfkkop_i LIKE sy-tabix.
DATA: sum_abfo LIKE dfkkop-betrw.
DATA: sum_abza LIKE dfkkop-betrw.
DATA: sum_sald LIKE dfkkop-betrw.
DATA: sum_sala LIKE dfkkop-betrw.
DATA: akt_opbel LIKE dfkkop-opbel.
DATA: akt_vkont LIKE dfkkop-vkont.

DATA: BEGIN OF t_wdh OCCURS 0,
        nr TYPE i,
        betrw LIKE dfkkop-betrw,
      END OF t_wdh.

DATA: bet_bas LIKE dfkkop-betrw.
DATA: lin     TYPE i.
DATA: t_wdh_i LIKE sy-tabix.
DATA: saldo_ma LIKE dfkkop-betrw.

DATA: BEGIN OF wa_dfkkko OCCURS 0,
        cpudt LIKE dfkkko-cpudt,
      END OF wa_dfkkko.

DATA: BEGIN OF wa_dfkkop OCCURS 0,
        opbel LIKE dfkkop-opbel,
        opupw LIKE dfkkop-opupw,
        vkont LIKE dfkkop-vkont,
        betrh LIKE dfkkop-betrh,
        hvorg LIKE dfkkop-hvorg,
        tvorg LIKE dfkkop-tvorg,
        augst LIKE dfkkop-augst,
        augrd LIKE dfkkop-augrd,
        whang LIKE dfkkop-whang,
        whgrp LIKE dfkkop-whgrp,
        xanza LIKE dfkkop-xanza,
        stakz LIKE dfkkop-stakz,
        faedn LIKE dfkkop-faedn,
      END OF wa_dfkkop.

TYPES:  BEGIN OF twa_dfkkopw,
        opbel LIKE dfkkopw-opbel,
        whgrp LIKE dfkkop-whgrp,
        faedn LIKE dfkkop-faedn,
       END OF twa_dfkkopw.

DATA wa_dfkkopw TYPE SORTED TABLE OF twa_dfkkopw
     WITH NON-UNIQUE KEY opbel WITH HEADER LINE.

DATA: count TYPE i,
      opbel LIKE dfkkop-opbel,
      whgrp LIKE dfkkop-whgrp,
      counter TYPE i,
      cursor TYPE cursor,
      exit.
* Initialization  (Kle)
INITIALIZATION.
  PERFORM unix_pfad.
*
AT SELECTION-SCREEN ON fname.
  IF fname(12) <> '/Mig/SWL_BI/'.
    MESSAGE e011(zabc) WITH '/Mig/SWL_BI/'.
  ENDIF.

****** START-OF-SELECTION ******
START-OF-SELECTION.


  WRITE: / 'Datum der Auswertung  :', sy-datum.
  WRITE: / 'Uhrzeit der Auswertung:', sy-uzeit.
  WRITE: / 'System /  Mandant     :', sy-sysid, ' / ', sy-mandt.
  WRITE: /.

*  IF vkontmin IS INITIAL AND vkontmax IS INITIAL.
** keine Angabe zu einem Vertragskonto, also alles ...
*    vkontmin = '000000000000'.
*    vkontmax = '999999999999'.
*  ELSEIF vkontmin IS INITIAL.
*    vkontmin = vkontmax.
*  ELSEIF vkontmax IS INITIAL.
*    vkontmax = vkontmin.
*  ENDIF.

  CLEAR counter.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE vkont FROM fkkvk
        WHERE vkont IN so_vkont.

* Interne Tabelle für relevante OP's aufbauen
  OPEN CURSOR cursor FOR  SELECT opbel opupw
           vkont betrw betrh hvorg tvorg augst augrd whang whgrp
           xanza stakz faedn
*         INTO CORRESPONDING FIELDS OF wa_dfkkop

           FROM dfkkop WHERE vkont IN so_vkont
           AND bukrs IN s_bukrs.

*       VKONT LE VKONTMAX AND (
*       ( HVORG = '0050' AND TVORG = '0010' AND
*       AUGRD = ' ' ) OR
*       (  HVORG = '0050' AND ( XANZA = 'X' AND STAKZ = 'P' )
*          AND OPUPW = 0  ) OR
*       ( ( HVORG = '6100' OR HVORG = '0060' ) AND AUGST = ' ' )
*       ).

* Jetzt noch Wiederholungen bis Fälligkeitsdatum abholen
* SELECT opbel whgrp faedn INTO CORRESPONDING FIELDS OF TABLE wa_dfkkopw
*          FROM dfkkopw FOR ALL ENTRIES IN wa_dfkkop
*          WHERE opbel = wa_dfkkop-opbel
*          AND faedn LE abs_bis.

*  SORT wa_dfkkop BY vkont opbel.
  DO.
    CLEAR : wa_dfkkop, wa_dfkkop[].
    FETCH NEXT CURSOR cursor
          INTO CORRESPONDING FIELDS OF TABLE wa_dfkkop
          PACKAGE SIZE 1000.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    LOOP AT wa_dfkkop.
      counter = counter + 1.
      wa_dfkkop_i = counter.

* Falls neuer Beleg, Daten aus Wiederholposition berücksichtigen
      IF akt_opbel NE wa_dfkkop-opbel.
        akt_opbel = wa_dfkkop-opbel.
*
** Aufgelöste Wiederholungen (AW) sind zu berücksichtigen
*        DESCRIBE TABLE t_wdh LINES lin.
*    IF lin > 0. " Aufgelöste Wiederholungen (AW) sind zu
* berücksichtigen
*          vkont-abs_ford = vkont-abs_ford - lin * bet_bas.
*          LOOP AT t_wdh. "AW abziehen und Ersatzpositionen hinzu ...
*            vkont-abs_ford = vkont-abs_ford + t_wdh-betrw.
*          ENDLOOP.
*          CLEAR t_wdh[].
*        ENDIF.
*        CLEAR bet_bas.
*
*        IF akt_vkont = wa_dfkkop-vkont.
*          PERFORM vk_pruef.
*        ENDIF.

      ENDIF.

*
* Jetzt zum neuen VK wechseln ??
      IF akt_vkont NE wa_dfkkop-vkont.
        akt_vkont = wa_dfkkop-vkont.
        IF wa_dfkkop_i > 1.
          MODIFY vkont INDEX t_index.
        ENDIF.
        READ TABLE vkont WITH KEY vkont = wa_dfkkop-vkont.
        t_index = sy-tabix.
        PERFORM vk_pruef.
      ENDIF.



* Gezahlte Abschläge aufsummieren
      IF ( wa_dfkkop-hvorg = '0050' AND wa_dfkkop-tvorg = '0010' AND
             wa_dfkkop-augrd = ' ' )
*          OR ( wa_dfkkop-hvorg = '0060' AND wa_dfkkop-augst = ' ' )

***TTT
        OR ( wa_dfkkop-hvorg = '0045' AND wa_dfkkop-tvorg = '0020' AND
             wa_dfkkop-augrd = '  ' ).
***TTT

        vkont-abs_zahl = vkont-abs_zahl + wa_dfkkop-betrh.

* Abschlagsforderungen ermitteln
      ELSEIF wa_dfkkop-hvorg = '0050' AND
*    ( WA_DFKKOP-TVORG = '0120' OR WA_DFKKOP-TVORG = '0220' ).
           ( wa_dfkkop-xanza = 'X' AND wa_dfkkop-stakz = 'P' ).
        IF wa_dfkkop-whang GE 1. " Wiederholpositionen


*          IF opbel <> wa_dfkkop-opbel OR whgrp <> wa_dfkkop-whgrp.
*            opbel = wa_dfkkop-opbel.
*            whgrp = wa_dfkkop-whgrp.
*            CLEAR count.
* Keine aufgelösten Positionen berücksichtigen
          SELECT COUNT( * ) INTO count
                   FROM dfkkopw
                   WHERE opbel = wa_dfkkop-opbel
                   AND   whgrp = wa_dfkkop-whgrp
                   AND faedn LE abs_bis
                   AND xaufl <> 'X'.
*            WRITE: / wa_dfkkop-opbel, count.
          DO count TIMES.
*        LOOP AT wa_dfkkopw transporting no fields
*                                 WHERE opbel = wa_dfkkop-opbel AND
*                                 whgrp = wa_dfkkop-whgrp.
            vkont-abs_ford = vkont-abs_ford +
*                              WA_DFKKOP-betrw * WA_DFKKOP-WHANG.
                                    wa_dfkkop-betrh.
*        ENDLOOP.
          ENDDO.
*          ENDIF.
*          bet_bas = wa_dfkkop-betrw.
*        ELSEIF wa_dfkkop-opupw NE 0.
*          READ TABLE t_wdh WITH KEY nr = wa_dfkkop-opupw.
*          t_wdh_i = sy-tabix.
*          IF sy-subrc NE 0.
*            t_wdh-nr = wa_dfkkop-opupw.
*            t_wdh-betrw = wa_dfkkop-betrw.
*            APPEND t_wdh.
*          ELSE.
*            t_wdh-betrw = t_wdh-betrw + wa_dfkkop-betrw.
*            MODIFY t_wdh INDEX t_wdh_i.
*          ENDIF.
        ELSE.
          IF wa_dfkkop-faedn LE abs_bis.
            vkont-abs_ford = vkont-abs_ford + wa_dfkkop-betrh.
          ENDIF.
        ENDIF.

*
* Saldo offener Posten ermitteln ...
      ELSEIF
*  ( WA_DFKKOP-HVORG = '6100' OR WA_DFKKOP-HVORG = '0060' ) AND
          wa_dfkkop-augst = ' '.
***TTT
*          AND wa_dfkkop-tvorg <> '0030'.
***TTT.
        IF wa_dfkkop-whang GE 1. " Wiederholpositionen


*          IF opbel <> wa_dfkkop-opbel OR whgrp <> wa_dfkkop-whgrp.
*            opbel = wa_dfkkop-opbel.
*            whgrp = wa_dfkkop-whgrp.
*            CLEAR count.
* Keine aufgelösten Positionen berücksichtigen
          SELECT COUNT( * ) INTO count
                   FROM dfkkopw
                   WHERE opbel = wa_dfkkop-opbel
                   AND   whgrp = wa_dfkkop-whgrp
                   AND xaufl <> 'X'.
*            WRITE: / wa_dfkkop-opbel, count.
          DO count TIMES.
*        LOOP AT wa_dfkkopw transporting no fields
*                                 WHERE opbel = wa_dfkkop-opbel AND
*                                 whgrp = wa_dfkkop-whgrp.
            vkont-saldo = vkont-saldo +
*                              WA_DFKKOP-betrw * WA_DFKKOP-WHANG.
                                    wa_dfkkop-betrh.
*        ENDLOOP.
          ENDDO.
        ELSE.
          vkont-saldo = vkont-saldo + wa_dfkkop-betrh.
        ENDIF.
      ENDIF.


    ENDLOOP.
  ENDDO.
*endselect.
  CLOSE CURSOR cursor.
*
** Aufgelöste Wiederholungen (AW) sind zu berücksichtigen
*  DESCRIBE TABLE t_wdh LINES lin.
*  IF lin > 0. " Aufgelöste Wiederholungen (AW) sind zu berücksichtigen
*    vkont-abs_ford = vkont-abs_ford - lin * bet_bas.
*    LOOP AT t_wdh. "AW abziehen und Ersatzpositionen hinzu ...
*      vkont-abs_ford = vkont-abs_ford + t_wdh-betrw.
*    ENDLOOP.
*  ENDIF.


  MODIFY vkont INDEX t_index.


  IF s_vkont IS INITIAL.
    LOOP AT vkont.
*   Geschäftspartner eintragen ...
      SELECT SINGLE gpart INTO vkont-gpart FROM fkkvkp
             WHERE vkont = vkont-vkont.
      MODIFY vkont.
* Summen bilden ...
      sum_abfo = sum_abfo + vkont-abs_ford.
      sum_abza = sum_abza + vkont-abs_zahl.
      sum_sald = sum_sald + vkont-saldo.
    ENDLOOP.

    SORT vkont BY gpart.
    WRITE: / ' G-Partner ! Konto IS-U   ! Alt-Konto   !'.
    WRITE:   'Forderung Abschläge!  Zahlung Abschläge  !'.
    WRITE:   'Saldo ohne Abschläge! Saldo mit Abschläge ! Ä !'.
    LOOP AT vkont.
*   Geschäftspartner eintragen ...
*    SELECT SINGLE GPART INTO VKONT-GPART FROM FKKVKP
*           WHERE VKONT = VKONT-VKONT.
      betrw = vkont-abs_ford + vkont-abs_zahl + vkont-saldo.
      WRITE: / vkont-gpart, '!', vkont-vkont,'!',
               vkont-vkona(11), '!', vkont-abs_ford,'! ',
                vkont-abs_zahl, '! ', vkont-saldo, '! ', betrw, '!',
                vkont-aend, '!'.
    ENDLOOP.
  ELSE.
    SORT vkont BY vkont.
    WRITE: / 'Konto IS-U   ! G-Partner  !  Alt-Konto  !'.
    WRITE:   'Forderung Abschläge!  Zahlung Abschläge  !'.
    WRITE:   'Saldo ohne Abschläge! Saldo mit Abschläge ! Ä !'.
    LOOP AT vkont.
* Summen bilden ...
      sum_abfo = sum_abfo + vkont-abs_ford.
      sum_abza = sum_abza + vkont-abs_zahl.
      sum_sald = sum_sald + vkont-saldo.

*   Geschäftspartner eintragen ...
      IF vkont-gpart IS INITIAL.
        SELECT SINGLE gpart INTO vkont-gpart FROM fkkvkp
               WHERE vkont = vkont-vkont.
      ENDIF.
      betrw = vkont-abs_ford + vkont-abs_zahl + vkont-saldo.
      WRITE: / vkont-vkont, '!', vkont-gpart, '!', vkont-vkona(11), '!',
               vkont-abs_ford, '! ',
               vkont-abs_zahl, '! ', vkont-saldo, '! ', betrw, '!',
               vkont-aend, '!'.
    ENDLOOP.
  ENDIF.

  WRITE: / ' '.
  WRITE: / 'Summe Forderung Abschläge: ', sum_abfo.
  WRITE: / 'Summe Zahlung Abschläge  : ', sum_abza.
  WRITE: / 'Summe Saldo              : ', sum_sald.
  sum_sald = sum_sald + sum_abfo + sum_abza.
  WRITE: / 'Summe Saldo  mit Abschl. : ', sum_sald.



**************************** Änderung Kleeberg *******
  IF dat_aus = 'X'.             "Wenn im Selektionbild ausgewählt
* interne Tabelle für Ausgabedatei füllen
    OPEN DATASET fname FOR OUTPUT IN TEXT MODE encoding default.
    IF sy-subrc NE 0.
*    WRITE:/ 'Fehler beim ÖFFNEN der Datei ', filename1, sy-subrc.
*    EXIT.
    ENDIF.


    LOOP AT vkont.
      CLEAR saldo_ma.

      MOVE vkont-vkont TO vkonta-vkont.
      MOVE vkont-gpart TO vkonta-gpart.
      MOVE vkont-vkona(11) TO vkonta-vkona.
      saldo_ma = vkont-abs_ford + vkont-abs_zahl + vkont-saldo.
* Vorzeichen bestimmen
      IF vkont-abs_zahl < 0.
        MOVE '-' TO vkonta-vz1.
      ELSE.
        MOVE '+' TO vkonta-vz1.
      ENDIF.
*
* Vorzeichen bestimmen
      IF vkont-abs_ford < 0.
        MOVE '-' TO vkonta-vz2.
      ELSE.
        MOVE '+' TO vkonta-vz2.
      ENDIF.
*
* Vorzeichen bestimmen
      IF vkont-saldo < 0.
        MOVE '-' TO vkonta-vz3.
      ELSE.
        MOVE '+' TO vkonta-vz3.
      ENDIF.
*
* Vorzeichen bestimmen
      IF saldo_ma < 0.
        MOVE '-' TO vkonta-vz4.
      ELSE.
        MOVE '+' TO vkonta-vz4.
      ENDIF.
*
      UNPACK vkont-abs_zahl TO vkonta-abs_zahl.
      vkonta-abs_zahl = vkonta-abs_zahl / 100.
      UNPACK vkont-abs_ford TO vkonta-abs_ford.
      vkonta-abs_ford = vkonta-abs_ford / 100.
      UNPACK vkont-saldo TO vkonta-saldo.
      vkonta-saldo = vkonta-saldo / 100.
      UNPACK saldo_ma TO vkonta-betrw.
      vkonta-betrw = vkonta-betrw / 100.
      MOVE vkont-aend TO vkonta-aend.

      APPEND vkonta.



* ---- Dateierstellung -----

      PERFORM write_data.
    ENDLOOP.
    CLOSE DATASET fname.

  ENDIF.

************************Ende Änderung *******


*&---------------------------------------------------------------------*
*&      Form  VK_PRUEF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vk_pruef.
*   Prüfen, ob VK geändert wurde.
  IF vkont-aend IS INITIAL.
    SELECT cpudt INTO wa_dfkkko-cpudt FROM dfkkko UP TO 1 ROWS
                   WHERE opbel = wa_dfkkop-opbel
                   AND cpudt >= aend_ab.
    ENDSELECT.
*    LOOP AT WA_DFKKKO.
    IF wa_dfkkko-cpudt GE aend_ab.
      vkont-aend = 'X'.
      EXIT.
    ENDIF.
*    ENDLOOP.
    IF wa_dfkkop-hvorg = '0050' AND vkont-aend IS INITIAL.
      SELECT aedat INTO wa_eabp-aedat UP TO 1 ROWS
             FROM eabp WHERE opbel = wa_dfkkop-opbel AND
                             aedat GE aend_ab.
      ENDSELECT.
      IF sy-subrc EQ 0.
        vkont-aend = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " VK_PRUEF

*&---------------------------------------------------------------------*
*&      Form  UNIX_PFAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM unix_pfad.

  DATA: maschine(3) TYPE c.


  CASE sy-sysid.
*    WHEN 'EW2'.
*      MOVE 'ew2' TO maschine.
    when 'IE1'.
       move 'ie1' to maschine.
    WHEN 'SM3'.
      MOVE 'sm3' TO maschine.
    WHEN 'SE2'.
      MOVE 'se2' TO maschine.
  ENDCASE.

  CONCATENATE '/Mig/SWL_BI/'    "muss noch geändert werden!
               'm' sy-mandt '_' maschine '_deb_dat.txt' INTO fname.
  CONDENSE fname NO-GAPS.



ENDFORM.                    " UNIX_PFAD

*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_data.

*  LOOP AT vkonta.
  TRANSFER vkonta TO fname.
  IF sy-subrc NE 0.
    WRITE:/ 'Fehler beim SCHREIBEN in Datei',fname, sy-subrc.
    EXIT.
  ELSE.
*      counter_a = counter_a + 1.
  ENDIF.
*  ENDLOOP.
*
*


ENDFORM.                    " WRITE_DATA
