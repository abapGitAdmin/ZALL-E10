*&---------------------------------------------------------------------*
*& Report  ZSCH_12_MY_LITTLE_FARM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zsch_12_my_little_farm.
* Run Time Type Identification
TYPE-POOLS: abap.
* Konstanten für Symbole, Icons und Farben
TYPE-POOLS: icon,
            sym,
            col.

* Für Select-Option und RTTI
DATA: gd_beet TYPE zsch_12_td_beet.
**********************************************************************
* PARAMETERS: pa_gdat TYPE d DEFAULT '19690722'.
* Block für Gartenfreude
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-f10.
* Gartendatum
PARAMETERS: pa_gdat TYPE dats DEFAULT '19690722' OBLIGATORY MEMORY ID rid.
* Beetauswahl
SELECT-OPTIONS: so_beet FOR gd_beet.
* Ende Block Gartenfreude
SELECTION-SCREEN END OF BLOCK b1.

* Block Pflanzen
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-f20.
* Früchtchen Radio
PARAMETERS: pa_fruti RADIOBUTTON GROUP plat USER-COMMAND chng.
* Block Früchtchen
SELECTION-SCREEN BEGIN OF BLOCK b21 WITH FRAME TITLE TEXT-f21.
* Früchtchenchecker
PARAMETERS: pa_stra  AS CHECKBOX,
            pa_bana  AS CHECKBOX,
            pa_jelly AS CHECKBOX.
* Ende Block Früchtchen
SELECTION-SCREEN END OF BLOCK b21.

* Grünzeug Radio
PARAMETERS: pa_vegi RADIOBUTTON GROUP plat.
* Block Grünzeug
SELECTION-SCREEN BEGIN OF BLOCK b22 WITH FRAME TITLE TEXT-f22.
* Gemüsechecker
PARAMETERS: pa_caro AS CHECKBOX,
            pa_cucu AS CHECKBOX,
            pa_sala AS CHECKBOX.
* Ende Block Gemüse
SELECTION-SCREEN END OF BLOCK b22.
* Ende Block Pflanzen
SELECTION-SCREEN END OF BLOCK b2.
**********************************************************************
* Beschreibung der Festwerte
DATA: gr_beet_descr     TYPE REF TO cl_abap_elemdescr,
* Die Fixwerte für die Beete, d.h. Namen, etc.
      gt_beet_fixvalues TYPE ddfixvalues,
* Arbeitsstruktur zu Beet
      gs_beet_fixvalue  LIKE LINE OF gt_beet_fixvalues,
* Die Auswahl für GET CURSOR zum Zeitpunkt AT-LINE-SELECTION
      gd_val(80)        TYPE c, "Der Wert, der ausgewählt wurde
      gd_line           TYPE i, "Die Zeile in der ausgewählt wurde
      gd_offset         TYPE i, "Der Offset der Auswahl
      gd_icon           TYPE icon_d, "Das Icon die dargestellt werden sollte
* Anzahl der Beete
      gd_nr_beet        TYPE i,
* Anzahl der Fürchte
      gd_nr_fruti       TYPE i,
* Anzahl der Gemüse
      gd_nr_vegi        TYPE i,
* Anzahl der Pflanzen
      gd_nr_plants      TYPE i,
* Tabelle der Gemüse
      gt_vegis          TYPE stringtab,
* Tabelle der Früchtchen
      gt_frutis         TYPE stringtab,
      gs_plant          TYPE LINE OF stringtab,
* Textpool
      gt_textpool       TYPE TABLE OF textpool,
      gs_textpool       LIKE LINE OF gt_textpool,
* Beete
      gt_beete          TYPE stringtab,
      gs_beet           LIKE LINE OF gt_beete,
* Zeilenindex
      gd_tabix          LIKE sy-tabix.
**********************************************************************
INITIALIZATION.
  pa_fruti = pa_stra = pa_bana = pa_jelly = abap_true.
* Text holen für Ausgabe
  READ TEXTPOOL sy-cprog INTO gt_textpool LANGUAGE sy-langu.
* Alle Beete aus dem Datenelement ermitteln
  gr_beet_descr ?= cl_abap_typedescr=>describe_by_data( gd_beet ).
* Die Festwerte holen
  gt_beet_fixvalues = gr_beet_descr->get_ddic_fixed_values( ).
* Icon für Ausgabe auf Liste (schöne Pflanze)
  gd_icon = icon_selection+1(2).
**********************************************************************
AT SELECTION-SCREEN OUTPUT.
  SET TITLEBAR 'TITLELIST'.

AT SELECTION-SCREEN.
* Was war die Aktion?
  CASE sy-ucomm.
* Auswahl von Select-Option Zusatz
    WHEN '%002'.
      EXIT.
* Änderung der Auswahl Früchtchen/Gemüsezeug
    WHEN 'CHNG'. "Siehe Parameter pa_fruti
* Wenn Früchtchen
      IF pa_fruti = abap_true.
* Gemüsezeug abwählen
        pa_caro = pa_cucu = pa_sala = abap_false.
* Früchtchen auswählen
        pa_stra = pa_bana = pa_jelly = abap_true.
* Lob Nachricht Früchtchen
        MESSAGE s001(zsch_12) WITH sy-uname TEXT-s01.
* Wenn Gemüsezeug
      ELSEIF pa_vegi = abap_true.
* Gemüsezeug auswählen
        pa_caro = pa_cucu = pa_sala = abap_true.
* Früchtchen abwählen
        pa_stra = pa_bana = pa_jelly = abap_false.
* Lob Nachricht Gemüsezeug
        MESSAGE s001(zsch_12) WITH sy-uname TEXT-s02.
      ENDIF.
* Jede andere Aktion des Benutzers
    WHEN OTHERS.
* Falls Früchtchen, dann prüfen, ob zumindest eines gewählt wurde
      IF pa_fruti = abap_true
        AND pa_stra = abap_false
        AND pa_bana = abap_false
        AND pa_jelly = abap_false.
* Nein, Schlimmer Benutzer
        MESSAGE e002(zsch_12) WITH sy-uname.
* Falls Gemüsezeug, dann prüfen, ob zumindest eines gewählt wurde
      ELSEIF pa_vegi = abap_true
        AND pa_caro = abap_false
        AND pa_cucu = abap_false
        AND pa_sala = abap_false.
* Nein, Schlimmer Benutzer
        MESSAGE e002(zsch_12) WITH sy-uname.
      ENDIF.
  ENDCASE.
* Anzahl und Texte zu gewählten Beeten ermitteln
  CLEAR gt_beete. "Starte ohne Einträge
  gd_nr_beet = 0. "Starte mit 0 Ausgewählten
* Ermitteln der Texte zu den Beeten, die vom Benutzer gewählt wurden
  LOOP AT gt_beet_fixvalues INTO gs_beet_fixvalue "Alle Beete
    WHERE low IN so_beet. "Die vom Benutzer gewählten
    ADD 1 TO gd_nr_beet.
    APPEND gs_beet_fixvalue-ddtext TO gt_beete.
  ENDLOOP.
* Zählung der ausgewählten Früchtchen oder Gemüsezeug
* Früchtchen wurden gewählt
  IF pa_fruti = abap_true.
    CLEAR gt_frutis. "Starte ohne Einträge
    gd_nr_fruti = 0. "Starte mit 0 Ausgewählten
* Falls Erdbeere gewählt
    IF pa_stra = abap_true.
      ADD 1 TO gd_nr_fruti. "Eine Ausgewählte dazu
* Hole den Text zur Erdbeere
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_STRA'.
* Namen der Erdbeere in die Fruchttabelle
      APPEND gs_textpool-entry TO gt_frutis.
    ENDIF.
* Banane
    IF pa_bana = abap_true.
      ADD 1 TO gd_nr_fruti.
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_BANA'.
      APPEND gs_textpool-entry TO gt_frutis.
    ENDIF.
* Jelly-Beans
    IF pa_jelly = abap_true.
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_JELLY'.
      APPEND gs_textpool-entry TO gt_frutis.
      ADD 1 TO gd_nr_fruti.
    ENDIF.
* Anzahl der Pflanzen setzen
    gd_nr_plants = gd_nr_fruti.
* Gemüsezeug wurde gewählt
  ELSEIF pa_vegi = abap_true.
    CLEAR gt_vegis. "Starte ohne Einträge
    gd_nr_vegi = 0. "Starte mit 0 Ausgewählten
* Karotte
    IF pa_caro = abap_true.
      ADD 1 TO gd_nr_vegi. "Eine Ausgewählte dazu
* Hole den Text zur Karotte
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_CARO'.
* Namen der Karotte in die Gemüsetabelle
      APPEND gs_textpool-entry TO gt_vegis.
    ENDIF.
* Gurke
    IF pa_cucu = abap_true.
      ADD 1 TO gd_nr_vegi.
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_CUCU'.
      APPEND gs_textpool-entry TO gt_vegis.
    ENDIF.
* Salat
    IF pa_sala = abap_true.
      ADD 1 TO gd_nr_vegi.
      READ TABLE gt_textpool INTO gs_textpool WITH KEY key = 'PA_SALA'.
      APPEND gs_textpool-entry TO gt_vegis.
    ENDIF.
* Anzahl der Pflanzen setzen
    gd_nr_plants = gd_nr_vegi.
  ENDIF.
* Prüfung, ob genügend Beete vorhanden sind
  IF gd_nr_beet < gd_nr_plants .
    MESSAGE e003(zsch_12) WITH sy-uname. "Nein, also Fehlermeldung
  ENDIF.

* Prüfung beim Früchtchen Block
AT SELECTION-SCREEN ON BLOCK b21.
* Nur prüfen, falls der Benutzer nicht gewechselt hat
  CHECK sy-ucomm <> 'CHNG'.
  IF pa_fruti = abap_true
    AND pa_stra = abap_false
    AND pa_bana = abap_false
    AND pa_jelly = abap_false.
* Nein, Schlimmer Benutzer
    MESSAGE e002(zsch_12) WITH sy-uname.
  ENDIF.

*Prüfung beim Gemüsezeug Block
AT SELECTION-SCREEN ON BLOCK b22.
* Nur prüfen, falls der Benutzer nicht gewechselt hat
  CHECK sy-ucomm <> 'CHNG'.
  IF pa_vegi = abap_true
    AND pa_caro = abap_false
    AND pa_cucu = abap_false
    AND pa_sala = abap_false.
* Nein, Schlimmer Benutzer
    MESSAGE e002(zsch_12) WITH sy-uname.
  ENDIF.
**********************************************************************
* Ausgabe der Grundliste, also das Beete Layout
END-OF-SELECTION.
* Titel setzen
  SET TITLEBAR 'TITLELIST'.
* Eine schöne Blume
  WRITE: / icon_selection AS ICON.
* Textausgabe
  WRITE: 'Gartendatum:'(t02), pa_gdat DD/MM/YYYY.
* Zeile auslassen
  SKIP.
* Für jeden Einrag in der Beete Tabelle ein Beet zeichnen
* mit Name des Beetes und der Pflanze
  LOOP AT gt_beete INTO gs_beet.
* Pflanze zum Beet lesen, dafür Beet-Index speichern und
* als Pflanzen-Index verwenden
    gd_tabix = sy-tabix.
* Arbeitsstruktur für Pflanzennamen initialisieren
    CLEAR gs_plant.
* Früchtchen oder Gemüsezeugs
    IF pa_fruti = abap_true.
      READ TABLE gt_frutis INTO gs_plant INDEX gd_tabix.
    ELSEIF pa_vegi = abap_true.
      READ TABLE gt_vegis INTO gs_plant INDEX gd_tabix.
    ENDIF.
* Beet zeichnen
    PERFORM draw_beet
                USING
                   gs_beet
                   gs_plant.
  ENDLOOP.
**********************************************************************
* Interaktion mit der Liste
* Schmäh: Nur Ausgabe auf Liste erhöht Verzweigungsindex!
AT LINE-SELECTION.
* Die Inforamtionen ermitteln, auf die der Benutzer geklickt hat
  GET CURSOR VALUE gd_val
             LINE gd_line
             OFFSET gd_offset.
* Blümchen malen
  sy-lisel+gd_offset(2) = gd_icon.
* undauf der Liste ändern
  MODIFY CURRENT LINE.

*&---------------------------------------------------------------------*
*&      Form  draw_beet
*&---------------------------------------------------------------------*
*       Zeichne ein Beet
*----------------------------------------------------------------------*
*      -->ID_NAME    Name des Beets
*      -->ID_PNAME   Name der Pflanze
*----------------------------------------------------------------------*
FORM draw_beet USING id_name TYPE string
                     id_pname TYPE string.
* Ein Beet
* Farbe an für Beet
  FORMAT COLOR COL_GROUP.
* Ausgefüllte Checkbox, Beetname und Pflanzenname
  WRITE: / sym_checkbox AS SYMBOL, id_name, id_pname.
* Farbe auf positiv für Beet
  FORMAT COLOR COL_POSITIVE.
* Der obere Rand des Beetes
  WRITE  / '-------------------------------------------------------------------'.
* Vier Pflanzenreihen
  DO 4 TIMES.
* Der linke Rand
    WRITE: / '|'.
* Die Pflanzpositionen
    DO 32 TIMES.
* Ein grüner Fleck, ohne Leerzeichen, als Hotspot (Mauszeiger ändert sich)
      WRITE icon_led_green AS ICON  NO-GAP HOTSPOT.
    ENDDO.
* Der rechte Rand
    WRITE: '|'.
  ENDDO.
* Der untere Rand
  WRITE  / '-------------------------------------------------------------------'.
* Farbe aus
  FORMAT COLOR OFF.
ENDFORM.                    "draw_beet
