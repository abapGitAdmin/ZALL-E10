FUNCTION /ADESSO/FKK_SAMPLE_5062_SWK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_FKKCOLL STRUCTURE  DFKKCOLL OPTIONAL
*"      T_FKKOP STRUCTURE  FKKOP OPTIONAL
*"      T_FKKMAZE STRUCTURE  FKKMAZE OPTIONAL
*"  CHANGING
*"     VALUE(C_FKKCOLFILE_HEADER) LIKE  FKKCOLFILE_HEADER
*"  STRUCTURE  FKKCOLFILE_HEADER
*"--------------------------------------------------------------------

  DATA: ls_but000 TYPE but000,
        l_count   TYPE i.


  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcolfile_header-inkgp.

  DESCRIBE TABLE t_fkkop LINES l_count.

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

  c_fkkcolfile_header-zzcount       = l_count.
  c_fkkcolfile_header-zzdatum       = sy-datum.

ENDFUNCTION.
