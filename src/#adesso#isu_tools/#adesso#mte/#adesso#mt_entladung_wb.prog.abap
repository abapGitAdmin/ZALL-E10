*&---------------------------------------------------------------------*
*& Report  /ADESSO/MT_ENTLADUNG_WB
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------
* Dieser Report ist der Grundeinstieg in die Entladung der Migrations-
* objekte. Die entladenen Daten pro Objekt werden hier in eine Datei
* gestellt. Auf  diese Datei greift dann das Beladeprogramm zu.
*----------------------------------------------------------------------
REPORT /ADESSO/MT_ENTLADUNG_WB.

include /adesso/MT_ENTLADUNG_WB_TOP.
include /adesso/MT_ENTLADUNG_WB_SEL.
include /adesso/MT_ENTLADUNG_WB_F01.

*---------------------------------------------------------------------
*AT SELECTION-SCREEN.
*---------------------------------------------------------------------
AT SELECTION-SCREEN.
* >>> Eingabeprüfung
  DATA: aktiv(50) TYPE c.

  CONCATENATE obj_acc obj_acn obj_bpm obj_bct obj_bcn
              obj_mru obj_420 obj_con obj_dev obj_mrd
              obj_dlc obj_doc obj_fac obj_ins obj_poc
              obj_ich obj_ipl obj_inm obj_lot obj_moi
              obj_noc obj_nod obj_par obj_pno obj_pay
              obj_pos obj_pre obj_rva obj_pod obj_srt
              obj_CNO obj_RRL obj_DRT obj_PHD obj_PAS
              obj_LOP obj_ACS obj_DCD obj_DNO obj_DCO
              obj_DCE obj_DCR obj_DCM obj_DGR obj_dir
              obj_moh obj_moo obj_inn obj_icn
       INTO aktiv.

  IF  aktiv+1(1)  EQ  'X'.
    MESSAGE  e001(/adesso/mt_n)  WITH  'Bitte nur ein Objekt auswählen'.
  ENDIF.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.


  CLEAR: imig_err[].
  clear cnt_index.

  PERFORM migrationsdateien_erstellen.


*---------------------------------------------------------------------
*END-OF-SELECTION
*---------------------------------------------------------------------
