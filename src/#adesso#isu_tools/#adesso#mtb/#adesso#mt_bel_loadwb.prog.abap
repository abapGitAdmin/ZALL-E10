*&---------------------------------------------------------------------*
*& Report  /ADESSO/MT_BEL_LOADWB
*&
*----------------------------------------------------------------------
* Dieser Report ist der Grundeinstieg in die Befüllung der Migrations-
* objekte. Die entladenen Daten pro Objekt werden hier eingelesen und
* für die Beladung der Migrationsworkbench aufbereitet.
* erstellt am 14.04.2004 von Frank Kleeberg
*----------------------------------------------------------------------
REPORT /adesso/mt_bel_loadwb.

INCLUDE /adesso/mt_bel_loadwb_top.
INCLUDE /adesso/mt_bel_loadwb_sel.
INCLUDE /adesso/mt_bel_loadwb_f01.




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
              obj_cno obj_rrl obj_drt obj_phd obj_pas
              obj_lop obj_acs obj_dcd obj_dno obj_dco
              obj_dce obj_dcr obj_dcm obj_dgr obj_dir
              obj_moh obj_moo obj_inn obj_icn

       INTO aktiv.
  IF  aktiv+1(1)  EQ  'X'.
    MESSAGE  e001(/adesso/mt_n)  WITH  'Bitte nur ein Objekt auswählen'.
  ENDIF.


*---------------------------------------------------------------------
*START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM migrationsdateien_erstellen.



*---------------------------------------------------------------------
*END-OF-SELECTION
*---------------------------------------------------------------------
