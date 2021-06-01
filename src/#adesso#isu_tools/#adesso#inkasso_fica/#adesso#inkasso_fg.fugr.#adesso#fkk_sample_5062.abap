FUNCTION /adesso/fkk_sample_5062.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_FKKCOLL STRUCTURE  DFKKCOLL OPTIONAL
*"      T_FKKOP STRUCTURE  FKKOP OPTIONAL
*"      T_FKKMAZE STRUCTURE  FKKMAZE OPTIONAL
*"  CHANGING
*"     VALUE(C_FKKCOLFILE_HEADER) LIKE  FKKCOLFILE_HEADER STRUCTURE
*"        FKKCOLFILE_HEADER
*"----------------------------------------------------------------------

  DATA: ls_but000     TYPE but000.
  DATA: lf_count      TYPE i.
  DATA: lf_laufict(2) TYPE n.

  DATA: ls_colfile_h TYPE dfkkcolfile_h_w.


  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcolfile_header-inkgp.

  DESCRIBE TABLE t_fkkop LINES lf_count.

* Name des Inkassobüros ermitteln
* Hängt vom GP-Typ ab.
  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      c_fkkcolfile_header-zzname_inkgp1 = ls_but000-name_first.
      c_fkkcolfile_header-zzname_inkgp2 = ls_but000-name_last.

    WHEN '2'.                  "Organisation.
      c_fkkcolfile_header-zzname_inkgp1 = ls_but000-name_org1.
      c_fkkcolfile_header-zzname_inkgp2 = ls_but000-name_org2.
      c_fkkcolfile_header-zzname_inkgp3 = ls_but000-name_org3.
      c_fkkcolfile_header-zzname_inkgp4 = ls_but000-name_org4.

    WHEN '3'.                    "Gruppe
      c_fkkcolfile_header-zzname_inkgp1 = ls_but000-name_grp1.
      c_fkkcolfile_header-zzname_inkgp2 = ls_but000-name_grp2.

  ENDCASE.

*  c_fkkcolfile_header-zzname_inkgp1 = ls_but000-name_org1.
*  c_fkkcolfile_header-zzname_inkgp2 = ls_but000-name_org2.
*  c_fkkcolfile_header-zzname_inkgp3 = ls_but000-name_org3.
*  c_fkkcolfile_header-zzname_inkgp4 = ls_but000-name_org4.

  c_fkkcolfile_header-zzcount       = lf_count.
  c_fkkcolfile_header-zzdatum       = sy-datum.

  CLEAR ls_colfile_h.
  MOVE-CORRESPONDING c_fkkcolfile_header TO ls_colfile_h.

  ls_colfile_h-laufd = sy-datum.
  ls_colfile_h-laufi = 'SAM%'.
  SELECT COUNT( * ) FROM dfkkcolfile_h_w
         WHERE laufd =    @ls_colfile_h-laufd
         AND   laufi LIKE @ls_colfile_h-laufi
         INTO  @DATA(count).

  lf_laufict = count + 1.
  REPLACE '%' IN ls_colfile_h-laufi WITH lf_laufict .

  INSERT dfkkcolfile_h_w FROM ls_colfile_h.

  IF sy-subrc = 0.
    gf_laufd = ls_colfile_h-laufd.
    gf_laufi = ls_colfile_h-laufi.
  ENDIF.

ENDFUNCTION.
