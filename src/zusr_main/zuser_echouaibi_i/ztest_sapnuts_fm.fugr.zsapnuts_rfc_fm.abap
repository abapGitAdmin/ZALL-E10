FUNCTION ZSAPNUTS_RFC_FM.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IM_MATNR) TYPE  MARA-MATNR
*"  EXPORTING
*"     VALUE(EX_MARA) TYPE  MARA
*"----------------------------------------------------------------------

    select SINGLE * from mara INTO ex_mara
      WHERE matnr = im_matnr.



ENDFUNCTION.
