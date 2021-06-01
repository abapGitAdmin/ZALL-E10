FUNCTION /ADESSO/MTB_REP_GENERATE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(OBJECT) TYPE  EMG_OBJECT
*"  EXPORTING
*"     REFERENCE(REP_NAME) TYPE  PROGRAMM
*"     REFERENCE(FORM_NAME) TYPE  TEXT30
*"     REFERENCE(SYN_FEHLER) TYPE  TEXT60
*"  TABLES
*"      CODING STRUCTURE  RSSOURCE OPTIONAL
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
 DATA: h_done TYPE c.

  CLEAR: irep.
  REFRESH: irep.

* Prüfen ob die Firma und Objekt existiert
  SELECT SINGLE * FROM temfirma
    WHERE firma EQ firma.
  IF sy-subrc NE 0.
    CONCATENATE  'Firma' firma 'nicht vorhanden -' object
     INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
*    RAISE no_firma.
    RAISE error.
  ENDIF.

  SELECT SINGLE * FROM temob
    WHERE firma  EQ firma
      AND object EQ object.
  IF sy-subrc NE 0.
    CONCATENATE 'Objekt' object 'nicht ausgeprägt'
     INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
*    RAISE no_object.
    RAISE error.
  ENDIF.


* Datenermittlung
  SELECT * FROM temdb INTO TABLE itemdb
    WHERE firma   EQ firma
      AND object  EQ object
      AND dttyp   NE space
      AND gen     NE space.

  IF sy-subrc NE 0.
    CONCATENATE object 'Fehlerhaftes Customizing'
          INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
*    RAISE no_data.
    RAISE error.
  ENDIF.


  LOOP AT itemdb.
    SELECT * FROM temre APPENDING TABLE itemre
      WHERE firma     EQ firma
        AND object    EQ object
        AND inpstruct EQ itemdb-inpstruct.

    SELECT * FROM temru APPENDING TABLE itemru
     WHERE firma     EQ firma
       AND object    EQ object
       AND inpstruct EQ itemdb-inpstruct.

  ENDLOOP.
  SORT itemre BY inpstruct fldnr field.


* Generischen Report erstellen

  CONCATENATE 'Z_' firma '_' object INTO repname.
  CONDENSE repname NO-GAPS.

  CLEAR irep.
  CONCATENATE 'report' repname '.' INTO irep SEPARATED BY space.
  TRANSLATE irep TO LOWER CASE.
  APPEND irep.
  APPEND INITIAL LINE TO irep.

  CONCATENATE 'U_' firma '_' object INTO formname.
  CONDENSE formname NO-GAPS.
  MOVE formname TO form_name.
  TRANSLATE form_name TO UPPER CASE.

  CLEAR irep.
  CONCATENATE 'form' formname 'using dttyp'
    INTO irep SEPARATED BY space.
  TRANSLATE irep TO LOWER CASE.
  APPEND irep.

  CLEAR irep.
  MOVE 'x_daten' TO irep.
  SHIFT irep RIGHT BY 27 PLACES.
  APPEND irep.

  CLEAR irep.
* MOVE 'y_daten.' TO irep.
  MOVE 'y_daten'  TO irep.
  SHIFT irep RIGHT BY 27 PLACES.
  APPEND irep.


  CLEAR irep.
  MOVE 'regel_kz.' TO irep.
  SHIFT irep RIGHT BY 27 PLACES.
  APPEND irep.


  APPEND INITIAL LINE TO irep.

* Datendeklaration der maximal ausgeprägten Strukturen (X_...)
  LOOP AT itemdb.

    CLEAR h_done.
    LOOP AT itemru
      WHERE firma     = itemdb-firma
        AND object    = itemdb-object
        AND inpstruct = itemdb-inpstruct
        AND inksv     = 'X'.
*     Definition der um KSV-Kennz erweiterten Strukturen
*     (pro Feld)
*     Begin of und Struktur darf nur einmal deklariert werden
      IF h_done IS INITIAL.
        CLEAR irep.
        CONCATENATE 'data: begin of x_' itemdb-dttyp '.' INTO irep.
        APPEND irep.

        CONCATENATE 'include structure ' itemdb-inpstruct '.' INTO irep
          RESPECTING BLANKS.
        CONDENSE irep.
        APPEND irep.
        h_done = 'X'.
      ENDIF.                    "

      CONCATENATE 'data: k_' itemru-field ' type char1.' INTO irep.
      APPEND irep.

*      CONCATENATE 'data: end of x_' itemdb-dttyp '.' INTO irep.
*      APPEND irep.

    ENDLOOP.
*   Am Ende der Schleife Ende Deklarieren
    IF sy-subrc EQ 0.
      CONCATENATE 'data: end of x_' itemdb-dttyp '.' INTO irep.
      APPEND irep.
    ENDIF.



    IF sy-subrc NE 0.
      CLEAR h_done.
*   Erst nach Prüfen, ob es Kundenfelder gibt.
      LOOP AT itemre
        WHERE firma  = itemdb-firma
            AND object = itemdb-object
            AND inpstruct = itemdb-inpstruct
            AND prtype = '6'.

*       Definition der Struktur mit den Kundenfeldern
*       Struktur und Überschrift darf nur einmal reingeschrieben werden
        IF h_done IS INITIAL.
          CLEAR irep.
          CONCATENATE 'data: begin of x_' itemdb-dttyp '.' INTO irep.
          APPEND irep.
          CONCATENATE 'include structure ' itemdb-inpstruct '.' INTO irep
           RESPECTING BLANKS.
          CONDENSE irep.
          APPEND irep.
          h_done = 'X'.
        ENDIF.
*       Und nun das Kundenfeld
        CONCATENATE 'data: '
                    itemre-field
                     '(' itemre-fldlen ')'
                     ' type c.' INTO irep.
        APPEND irep.
      ENDLOOP.
*     Am Ende der Schleife Ende Deklarieren
      IF sy-subrc EQ 0.
        CONCATENATE 'data: end of x_' itemdb-dttyp '.' INTO irep.
        APPEND irep.
      ENDIF.

    ENDIF.


    CHECK sy-subrc > 0.
*   KSV-Kennz kammen gar nicht vor --> normale Definition
    CLEAR irep.
    CLEAR struktur.
    CONCATENATE 'x_' itemdb-dttyp INTO struktur.
    CONDENSE struktur NO-GAPS.

    CONCATENATE 'data:' struktur 'type' itemdb-inpstruct '.'
      INTO irep SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    APPEND irep.
    APPEND INITIAL LINE TO irep.

  ENDLOOP.

* Datendeklaration der ausgeprägten Strukturen (Y_....)
  LOOP AT itemdb.

* prüfen, ob überhaupt Felder in der ausgeprägten Struktur
* ungleich prtype = '2' sind. Ansonsten Struktur garnicht anlegen.
    LOOP AT itemre
      WHERE firma     EQ firma
        AND object    EQ object
        AND inpstruct EQ itemdb-inpstruct
        AND prtype    NE '2'
        AND cust      NE space.
    ENDLOOP.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
*

    CLEAR irep.
    CLEAR struktur.
    CONCATENATE 'y_' itemdb-dttyp INTO struktur.
    CONDENSE struktur NO-GAPS.

    CONCATENATE 'data: begin of' struktur ','
      INTO irep SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    APPEND irep.

    LOOP AT itemre
      WHERE firma     EQ firma
        AND object    EQ object
        AND inpstruct EQ itemdb-inpstruct
        AND cust      NE space.

      CASE itemre-prtype.

        WHEN '2'.
*       Feld wird in irep nicht aufgebaut (nichts machen)

        WHEN '5'.
*       bei Umschlüsselung über KSV wird die Ausgabelänge auf 30
*       Zeichen gesetzt (TEMKSV-NEWKEY)
          CLEAR struk_feld.
          MOVE 'TEMKSV-NEWKEY' TO struk_feld.
          CONDENSE struk_feld NO-GAPS.

          CLEAR irep.
          CONCATENATE itemre-field 'like' struk_feld ','
            INTO irep SEPARATED BY space.
          TRANSLATE irep TO LOWER CASE.
          SHIFT irep RIGHT BY 7 PLACES.
          APPEND irep.



          READ TABLE itemru WITH KEY firma     = itemre-firma
                                     object    = itemre-object
                                     inpstruct = itemre-inpstruct
                                     field     = itemre-field.
          IF itemru-inksv = 'X'.
            CLEAR irep.
            CONCATENATE 'k_' itemre-field ' type C,' INTO irep.
            TRANSLATE irep TO LOWER CASE.
            SHIFT irep RIGHT BY 7 PLACES.
            APPEND irep.
          ENDIF.



*      Kundenfelder
        WHEN '6'.
          CLEAR: struk_feld, struk_feld2.
          CONCATENATE itemre-field '(' itemre-fldlen ')' INTO
            struk_feld2.
          CONCATENATE struk_feld2 ' type C,'
          INTO irep.
          TRANSLATE irep TO LOWER CASE.
          SHIFT irep RIGHT BY 7 PLACES.
          APPEND irep.



        WHEN '9'.
*       bei der Umschlüsselung über Tabelle kann es auch sein,
*       dass die Ausgabelänge anders als die Feldlänge ist.
*       Ausgabelänge aus Tabellen TEMRC und TEMCNV ermitteln
          SELECT SINGLE * FROM temrc
            WHERE firma EQ itemre-firma
              AND object EQ itemre-object
              AND inpstruct EQ itemre-inpstruct
              AND field EQ itemre-field.
          IF sy-subrc NE 0.
            CONCATENATE object 'Fehlerhaftes Customizing'
               INTO meldung-meldung SEPARATED BY space.
            APPEND meldung.
*            RAISE no_data.
            RAISE error.
          ENDIF.
          SELECT SINGLE * FROM temcnv
            WHERE convobject EQ temrc-convobject.
          IF sy-subrc NE 0.
            CONCATENATE object 'Fehlerhaftes Customizing'
               INTO meldung-meldung SEPARATED BY space.
            APPEND meldung.
*            RAISE no_data.
            RAISE error.
          ENDIF.

          CLEAR: struk_feld, struk_feld2.
          CONCATENATE 'type' temcnv-type_output ','
            INTO struk_feld2 SEPARATED BY space.

          CONCATENATE itemre-field '('  temcnv-len_output ')'
            INTO struk_feld.
          CONDENSE struk_feld NO-GAPS.

          CLEAR irep.
          CONCATENATE struk_feld  struk_feld2
             INTO irep SEPARATED BY space.
          TRANSLATE irep TO LOWER CASE.
          SHIFT irep RIGHT BY 7 PLACES.
          APPEND irep.


        WHEN OTHERS.
          CLEAR struk_feld.

          SELECT * FROM dd03l WHERE tabname   = itemdb-inpstruct
                            AND fieldname = itemre-field


                            AND ( inttype   = 'P' OR inttype = 'X' ).


            SELECT SINGLE outputlen FROM dd01l INTO out_len
                              WHERE  domname = dd03l-domname.

          ENDSELECT.
          IF sy-subrc EQ 0  AND       " and itemre-field ne 'SBASW'.
             itemre-movetype = 'X'
**  --> Nuss 17.11.2015
            or itemre-field = 'SBASW'.
**  <-- Nuss 17.11.2015
            CONCATENATE itemre-field '('  out_len ')'
              INTO struk_feld.
            CONDENSE struk_feld NO-GAPS.

            CLEAR irep.
            CONCATENATE struk_feld  'type  c,'
              INTO irep SEPARATED BY space.
            TRANSLATE irep TO LOWER CASE.
            SHIFT irep RIGHT BY 7 PLACES.
            APPEND irep.



          ELSE.

            CONCATENATE itemdb-inpstruct '-' itemre-field INTO struk_feld.
            CONDENSE struk_feld NO-GAPS.

            CLEAR irep.
            CONCATENATE itemre-field 'like' struk_feld ','
              INTO irep SEPARATED BY space.
            TRANSLATE irep TO LOWER CASE.
            SHIFT irep RIGHT BY 7 PLACES.
            APPEND irep.

          ENDIF.

      ENDCASE.

    ENDLOOP.

    IF sy-subrc NE 0.

    ENDIF.

    CLEAR irep.
    CONCATENATE 'end of' struktur '.' INTO irep SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    SHIFT irep RIGHT BY 6 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.


  ENDLOOP.


* Füllen der Strukturen über CASE
  CLEAR irep.
  MOVE 'case dttyp.' TO irep.
  APPEND irep.
  APPEND INITIAL LINE TO irep.

  LOOP AT itemdb
    WHERE firma   EQ firma
      AND object  EQ object
      AND dttyp   NE space
      AND gen     NE space.


* prüfen, ob überhaupt Felder in der ausgeprägten Struktur
* ungleich prtype = '2' sind. Ansonsten Struktur garnicht anlegen.
    LOOP AT itemre
      WHERE firma     EQ firma
        AND object    EQ object
        AND inpstruct EQ itemdb-inpstruct
        AND prtype    NE '2'
        AND cust      NE space.
    ENDLOOP.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.


    CLEAR irep.
    CONCATENATE '''' itemdb-dttyp '''' INTO dat_typ.
    TRANSLATE dat_typ TO UPPER CASE.
    CONCATENATE 'when' dat_typ '.'
      INTO irep SEPARATED BY space.
    SHIFT irep RIGHT BY 2 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.

    CONCATENATE 'x_' itemdb-dttyp INTO x_struktur.
    CONDENSE x_struktur NO-GAPS.

    CONCATENATE 'y_' itemdb-dttyp INTO y_struktur.
    CONDENSE y_struktur NO-GAPS.

    CLEAR irep.
*    CONCATENATE 'move x_daten to' x_struktur '.' INTO irep                "Nuss 23.09.2015
    CONCATENATE 'move-corresponding x_daten to' x_struktur '.' INTO irep   "Nuss 23.09.2015
      SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    SHIFT irep RIGHT BY 4 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.


    CLEAR irep.
    CONCATENATE 'move-corresponding' x_struktur 'to' y_struktur '.'
    INTO irep  SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    SHIFT irep RIGHT BY 4 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.


*   Dieses Coding wurde obsolet nachdem die x_struktur um
*   das KSV-Kz erweitert wurde (Übernahme ducrh ,move-corresponding')

*    LOOP AT itemru
*      WHERE firma     = itemdb-firma
*        AND object    = itemdb-object
*        AND inpstruct = itemdb-dttyp
*        AND inksv     = 'X'.
*      CLEAR irep.
*      CONCATENATE x_struktur '-' itemru-field INTO irep.
*      CONCATENATE 'if not' irep 'is initial.' INTO irep
*                   SEPARATED BY space.
*      TRANSLATE irep TO LOWER CASE.
*      SHIFT irep RIGHT BY 4 PLACES.
*      APPEND irep.
*
*      CLEAR irep.
*      CONCATENATE y_struktur '-k_' itemru-field INTO irep.
*      CONCATENATE 'move ''X'' to' irep '.' INTO irep
*                   SEPARATED BY space.
*      TRANSLATE irep TO LOWER CASE.
*      SHIFT irep RIGHT BY 6 PLACES.
*      APPEND irep.
*
*      CLEAR irep.
*      MOVE 'endif.' TO irep.
*      TRANSLATE irep TO LOWER CASE.
*      SHIFT irep RIGHT BY 4 PLACES.
*      APPEND irep.
*
*      APPEND INITIAL LINE TO irep.
*
*    ENDLOOP.



    CLEAR irep.
    CONCATENATE 'move' y_struktur 'to y_daten' '.' INTO irep SEPARATED BY space.
    TRANSLATE irep TO LOWER CASE.
    SHIFT irep RIGHT BY 4 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.


* Wenn es in einer Struktur Regeln gibt, die anders als '3' sind,
* muss eine Struktur auch dann aufgebaut werden, wenn alle Felder
* initial sind. Information darüber wird hier in einem Kennzeichen
* an den Aufrufer übermittelt.
    LOOP AT itemre
      WHERE firma     EQ firma
        AND object    EQ object
        AND inpstruct EQ itemdb-inpstruct
        AND prtype    NE '3'
        AND cust      NE space.
    ENDLOOP.
    IF sy-subrc NE 0.
      CLEAR irep.
      MOVE 'move ''3'' to  regel_kz.' TO irep.
      TRANSLATE irep TO LOWER CASE.
      SHIFT irep RIGHT BY 4 PLACES.
      APPEND irep.
      APPEND INITIAL LINE TO irep.
    ENDIF.


  ENDLOOP.


* Für die nicht generierten Strukturen des Objektes wird
* nur das Regel-Kennzeichen '3' übertragen
  CLEAR: itemdb.
  REFRESH: itemdb.
  SELECT * FROM temdb INTO TABLE itemdb
    WHERE firma   EQ firma
      AND object  EQ object
      AND dttyp   NE space
      AND gen     EQ space.

  LOOP AT itemdb
    WHERE firma   EQ firma
      AND object  EQ object
      AND dttyp   NE space
      AND gen     EQ space.

    CLEAR irep.
    CONCATENATE '''' itemdb-dttyp '''' INTO dat_typ.
    TRANSLATE dat_typ TO UPPER CASE.
    CONCATENATE 'when' dat_typ '.'
      INTO irep SEPARATED BY space.
    SHIFT irep RIGHT BY 2 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.

    CLEAR irep.
    MOVE 'move ''3'' to  regel_kz.' TO irep.
    TRANSLATE irep TO LOWER CASE.
    SHIFT irep RIGHT BY 4 PLACES.
    APPEND irep.
    APPEND INITIAL LINE TO irep.

  ENDLOOP.


* endcase
  CLEAR irep.
  MOVE 'endcase.' TO irep.
  APPEND irep.
  APPEND INITIAL LINE TO irep.

* endform
  CLEAR irep.
  MOVE 'endform.' TO irep.
  APPEND irep.


  MOVE irep[] TO coding[].

  SYNTAX-CHECK FOR irep MESSAGE syn_fehler LINE line WORD word.
  IF sy-subrc NE 0.
    CONCATENATE object 'Syntaxfehler im gen. Report'
     INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
*    RAISE syntax_fehler.
    RAISE error.
  ELSE.
    GENERATE SUBROUTINE POOL irep NAME rep_name.
    TRANSLATE rep_name TO UPPER CASE.
    IF sy-subrc NE 0.
*   BREAK-POINT.
    ENDIF.
  ENDIF.


ENDFUNCTION.
