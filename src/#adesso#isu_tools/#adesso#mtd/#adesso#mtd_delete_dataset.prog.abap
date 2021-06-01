*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_DELETE_DATASET
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /adesso/mtd_delete_dataset.



DATA: del_file LIKE rlgrap-filename.


****************************************************************************
* Selektionsbildschirm
****************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME.
PARAMETERS: co_ent LIKE rlgrap-filename default '\\srv8705\migWBD1\Entladung\',
            co_bel LIKE rlgrap-filename default '\\srv8705\migWBD1\Beladung\'.

PARAMETERS: p_ent RADIOBUTTON GROUP fil,
            p_bel RADIOBUTTON GROUP fil.
SELECTION-SCREEN SKIP.
PARAMETERS: p_datei(20) TYPE c.
SELECTION-SCREEN END OF BLOCK bl1.


******************************************************************************
* START-OF-SELECTION
******************************************************************************
START-OF-SELECTION.
  PERFORM delete_dataset.

******************************************************************************
* END-OF-SELECTION
******************************************************************************
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  DELETE_DATASET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_dataset .

  IF p_ent IS NOT INITIAL.
    CONCATENATE co_ent p_datei INTO del_file.
  ELSEIF p_bel IS NOT INITIAL.
    CONCATENATE co_bel p_datei INTO del_file.
  ENDIF.

  DELETE DATASET del_file.
  IF sy-subrc = 0.
    SKIP 2.
    WRITE: /5 'Datensatz', del_file, 'wurde gelöscht'.
  ELSE.
    SKIP 2.
    WRITE: /5 'Datensatz', del_file, 'konnte nicht gelöscht werden'.
  ENDIF.

ENDFORM.                    " DELETE_DATASET
