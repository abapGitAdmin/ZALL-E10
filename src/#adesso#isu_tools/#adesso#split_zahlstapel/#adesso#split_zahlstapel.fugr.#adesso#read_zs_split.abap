FUNCTION /adesso/read_zs_split.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      E_ZS_SPLIT STRUCTURE  /ADESSO/ZS_SPLIT
*"----------------------------------------------------------------------

  SELECT *
    FROM        /adesso/zs_split
    INTO TABLE  e_zs_split.

ENDFUNCTION.
