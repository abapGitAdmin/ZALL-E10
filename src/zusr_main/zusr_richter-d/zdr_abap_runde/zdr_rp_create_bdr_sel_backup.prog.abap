*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*
selection-screen begin of block gb_hdr with frame title text-bk1.
parameters:
  p_ownsp type e_dexservprovself matchcode object serviceprovider obligatory,
  p_rcver type e_dexservprov obligatory.
selection-screen begin of line.
selection-screen comment 1(31) text-t02 for field p_pvw.
parameters:
  p_pvw  type /idxgc/de_proc_view  modif id txt,
  p_pvwt type eideswtviewtxt modif id txt.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(31) text-t03 for field p_pty.
parameters:
  p_pty  type /idxgc/de_proc_type modif id txt,
  p_ptyt type eideswttypetxt modif id txt.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(31) text-t01 for field p_pid.
parameters:
  p_pid  type /idxgc/de_proc_id obligatory,
  p_pidt type /idxgc/de_proc_descr modif id txt.
selection-screen end of line.

selection-screen end of block gb_hdr.

selection-screen begin of block gb_msg with frame title text-bk2.

* Z14: Master Data for Point of Delivery
selection-screen begin of line.
parameters: p_z14  radiobutton group g1 default 'X'.
selection-screen comment 6(70) text-t04 for field p_z14.
selection-screen end of line.

* Z27: Transfer of Transaction Data
selection-screen begin of line.
parameters: p_z27  radiobutton group g1.
selection-screen comment 6(60) text-t05 for field p_z27.
selection-screen end of line.

* Z28: Transfer of Energy and Demand Maximum
selection-screen begin of line.
parameters: p_z28  radiobutton group g1.
selection-screen comment 6(70) text-t06 for field p_z28.
selection-screen end of line.
selection-screen end of block gb_msg.

**********************************************************************
* ################################################################## *
**********************************************************************

**********************************************************************
* Radiobuttons zur Auswahl der Nachrichtentypen
**********************************************************************
selection-screen begin of block gb_rad with frame title text-bk3.

* Z30: Änderung des Bilazierungsverfahrens
selection-screen begin of line.
parameters  p_r30 radiobutton group g2 user-command radcom default 'X'.
selection-screen comment: 6(70) text-t11 for field p_r30.
selection-screen end of line.

* Z34: Reklamation von Lastgängen
selection-screen begin of line.
parameters  p_r34 radiobutton group g2.
selection-screen comment 6(70) text-t12 for field p_r34.
selection-screen end of line.
selection-screen end of block gb_rad.

**********************************************************************
* Block für Z30
**********************************************************************
selection-screen begin of block gb_s30 with frame title text-bk4.
data gv_locid type ext_ui.

* ID der Marktlokation
selection-screen begin of line.
selection-screen comment 1(28) text-t08.
select-options:
  p_locid        for gv_locid modif id m30.
selection-screen end of line.

* Ausführungsdatum
selection-screen begin of line.
selection-screen comment 1(31) text-t09.
parameters:
  p_ausfd       type /idxgc/de_proc_date modif id m30.
selection-screen end of line.

* Bilanzierungsverfahren
selection-screen begin of line.
selection-screen comment 1(31) text-t10.
parameters:
  p_bilav        type /idxgc/de_settl_proc modif id m30.
selection-screen end of line.
selection-screen end of block gb_s30.

**********************************************************************
* Block für Z34
**********************************************************************
selection-screen begin of block gb_s34 with frame title text-bk5.
data gv_begnr type e_logbelnr.

* Import-Belegnummer
selection-screen begin of line.
selection-screen comment 1(28) text-t13.
select-options:
  p_belnr        for gv_begnr modif id m34. "obligatory.
selection-screen end of line.
selection-screen end of block gb_s34.
