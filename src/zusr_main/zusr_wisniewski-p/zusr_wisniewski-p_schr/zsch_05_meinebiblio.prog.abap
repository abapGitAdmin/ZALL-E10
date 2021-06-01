*&---------------------------------------------------------------------*
*& Report ZSCH_05_MEINEBIBLIO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_05_meinebiblio.

DATA: gt_biblio TYPE zsch_05_tt_biblio,
      gs_biblio LIKE LINE OF gt_biblio.

START-OF-SELECTION.

  gs_biblio-buch_titel = 'Patrick programmiert ABAP'.
  gs_biblio-anz_seiten = 5432.
*APPEND gs_biblio TO gt_biblio.
  INSERT gs_biblio INTO TABLE gt_biblio.

  gs_biblio-buch_titel = 'Einstieg in Web Dynpro ABAP'.
  gs_biblio-anz_seiten = 350.
* APPEND gs_biblio TO gt_biblio.
  INSERT gs_biblio INTO TABLE gt_biblio.

  gs_biblio-buch_titel = 'Web Dynpro ABAP Kompendium'.
  gs_biblio-anz_seiten = 1200.
* APPEND gs_biblio TO gt_biblio.
  INSERT gs_biblio INTO TABLE gt_biblio.

  gs_biblio-buch_titel = 'ROSA-TOM: Agile Prozesserfassung'.
  gs_biblio-anz_seiten = 50.
* APPEND gs_biblio TO gt_biblio.
  INSERT gs_biblio INTO TABLE gt_biblio.

  SORT gt_biblio BY anz_seiten DESCENDING.



  READ TABLE gt_biblio INTO gs_biblio INDEX 1.
  WRITE: / gs_biblio-buch_titel, gs_biblio-anz_seiten.
