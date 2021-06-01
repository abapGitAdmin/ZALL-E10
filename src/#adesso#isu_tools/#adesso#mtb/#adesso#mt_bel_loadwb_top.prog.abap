*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MT_BEL_LOADWB_TOP
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------
* Datendeklaration
*---------------------------------------------------------------------
DATA ent_file TYPE emg_pfad.
DATA bel_file TYPE emg_pfad.

DATA: imeldung LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: mig_err LIKE /adesso/mt_messages OCCURS 0 WITH HEADER LINE.
DATA: anz_par TYPE i.
DATA: anz_con TYPE i.
DATA: anz_pre TYPE i.
DATA: anz_dlc TYPE i.
DATA: anz_pno TYPE i.
DATA: anz_noc TYPE i.
DATA: anz_nod TYPE i.
DATA: anz_dev TYPE i.
DATA: anz_ins TYPE i.
DATA: anz_ich TYPE i.
data: anz_inn type i.
data: anz_icn type i.
DATA: anz_fac TYPE i.
DATA: anz_acc TYPE i.
DATA: anz_acs TYPE i.
DATA: anz_rva TYPE i.
DATA: anz_acn TYPE i.
DATA: anz_moi TYPE i.
DATA: anz_bct TYPE i.
DATA: anz_bcn TYPE i.
DATA: anz_bpm TYPE i.
DATA: anz_pay TYPE i.
DATA: anz_doc TYPE i.
DATA: anz_ipl TYPE i.
DATA: anz_inm TYPE i.
DATA: anz_mrd TYPE i.
DATA: anz_lot TYPE i.
DATA: anz_srt TYPE i.
DATA: anz_pod TYPE i.
DATA: anz_poc TYPE i.
DATA: anz_pos TYPE i.
DATA: anz_drt TYPE i.
DATA: anz_dir TYPE i.
DATA: anz_cno TYPE i.
DATA: anz_lop TYPE i.
DATA: anz_dno TYPE i.
DATA: anz_dcd TYPE i.
DATA: anz_dco TYPE i.
DATA: anz_dce TYPE i.
DATA: anz_dcr TYPE i.
DATA: anz_dcm TYPE i.
DATA: anz_dgr TYPE i.
DATA: anz_moh TYPE i.
DATA: anz_moo TYPE i.




DATA: h_obj TYPE emg_object.
