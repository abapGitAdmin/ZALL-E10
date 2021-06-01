*&---------------------------------------------------------------------*
*& Report ZSCH_03_DURCHBLICK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_03_durchblick.
* TABLES-Struktur für Dynpro-Daten
TABLES: zsch03project.
* Parameter für das Projekt
PARAMETERS: pa_proj TYPE zsch03project-projekt OBLIGATORY.
* Die Variable zum Befüllen
DATA: gs_project TYPE zsch03project.
* Controls
DATA: gr_container TYPE REF TO cl_gui_custom_container,
      gr_picture   TYPE REF TO cl_gui_picture.
* Hier springt die Laufzeitumgebung rein
START-OF-SELECTION.
* Das mächtige WRITE zaubert eine Zeile in die Liste
  WRITE: / 'Durchblick 2.0'.
* Einzelsatz lesen
  SELECT SINGLE * FROM zsch03project INTO gs_project
  WHERE projekt = pa_proj.
* Jetzt auch mit logischer Kontrolle
  IF sy-subrc = 0.
* und in der Liste ausgeben
    WRITE: / gs_project.
  ELSE.
* der arme Anwender
    WRITE: / 'Och schade, nichts gefunden für Projekt = ', pa_proj.
  ENDIF.
* Hier springt die Laufzeitumgebung rein
AT LINE-SELECTION.
* Daten in die TABLES-Struktur
  zsch03project = gs_project.
* Dynpro aufrufen
  CALL SCREEN 9100.
*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROLS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_controls OUTPUT.
* Control instanziieren
  IF gr_container IS NOT BOUND.
* Container
    CREATE OBJECT gr_container
      EXPORTING
        container_name = 'BILD'.
* Bild
    CREATE OBJECT gr_picture
      EXPORTING
        parent = gr_container.
* Bild laden
    CALL METHOD gr_picture->load_picture_from_url
      EXPORTING
        url = gs_project-bild.
  ENDIF.
ENDMODULE.
