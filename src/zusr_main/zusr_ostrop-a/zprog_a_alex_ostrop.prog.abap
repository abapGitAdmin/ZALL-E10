*&---------------------------------------------------------------------*
*& Report ZPROG_A_ALEX_OSTROP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zprog_a_alex_ostrop.

TABLES: zprog_tabelle.
PARAMETERS: pa_prog TYPE zprog_tabelle-prog_a OBLIGATORY.
DATA: gt_zprog_tabelle type TABLE OF zprog_tabelle,
      filefromdb   TYPE zprog_tabelle,
      gr_container TYPE REF TO cl_gui_custom_container,
      gr_picture   TYPE REF TO cl_gui_picture.

START-OF-SELECTION.
  WRITE: / 'Willkommen in meinem Testprogramm! / Es ist', sy-uzeit.
  SELECT SINGLE * FROM zprog_tabelle INTO filefromdb WHERE prog_a = pa_prog.
  IF sy-subrc = 0.
    WRITE: / filefromdb.
  ELSE.
    WRITE: / 'Nix da, leider!'.
  ENDIF.

AT LINE-SELECTION.
*  Daten in die TABLES-Struktur
  zprog_tabelle = filefromdb.
  CALL SCREEN 9100.

*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROLS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_controls OUTPUT.

  IF gr_container IS NOT BOUND.
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
        url = zprog_tabelle-bild.
  ENDIF.
ENDMODULE.
