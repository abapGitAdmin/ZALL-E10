FUNCTION ZAD_FKK_SAMPLE_1248_DEREG.
*"----------------------------------------------------------------------
*!!!! ACHTUNG
*!!!! Namen der aufzurufenden FKTBs müssen manuell geändert werden
*!!!! ACHTUNG
*
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_HERKF_GROUP) TYPE  HERKF_KK OPTIONAL
*"  TABLES
*"      T_CONTEXTTAB STRUCTURE  FKKL1_CTMENU
*"----------------------------------------------------------------------

  data: h_ftext type ktext_ari.

* Aufruf des bisher verwendeten Funktionsbaustein
  call function 'ISU_EVENT_1248'
    exporting
      i_herkf_group = i_herkf_group
    tables
      t_contexttab  = t_contexttab.


  case i_herkf_group.

    when 'R4' or 'RA' or 'R9'.  " invoicing documents
* line to separate new entries from others
      t_contexttab-uline  = 'X'.
      modify t_contexttab index 1 transporting uline.
      t_contexttab-uline = space.

* display aggr.Document
      t_contexttab-fcode  = '&CT_NND1'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND1'.
      call function 'ZAD_FKK_SAMPLE_1206_NND1'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display Serviceprovider
      t_contexttab-fcode  = '&CT_NND2'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND2'.
      call function 'ZAD_FKK_SAMPLE_1206_NND2'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display REMADV
      t_contexttab-fcode  = '&CT_NND3'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND3'.
      call function 'ZAD_FKK_SAMPLE_1206_NND3'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display ETHI_DIS
      t_contexttab-fcode  = '&CT_NND5'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND5'.
      call function 'ZAD_FKK_SAMPLE_1206_NND5'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display aggr VK
      t_contexttab-fcode  = '&CT_NND6'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND6'.
      call function 'ZAD_FKK_SAMPLE_1206_NND6'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

    when '05'.  " payment
* line to separate new entries from others
      t_contexttab-uline  = 'X'.
      modify t_contexttab index 1 transporting uline.
      t_contexttab-uline = space.

* display Serviceprovider
      t_contexttab-fcode  = '&CT_NND2'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND2'.
      call function 'ZAD_FKK_SAMPLE_1206_NND2'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display REMADV
      t_contexttab-fcode  = '&CT_NND3'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND3'.
      call function 'ZAD_FKK_SAMPLE_1206_NND3'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display Distribution Lot
      t_contexttab-fcode  = '&CT_NND4'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND4'.
      call function 'ZAD_FKK_SAMPLE_1206_NND4'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display ETHI_DIS
      t_contexttab-fcode  = '&CT_NND5'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND5'.
      call function 'ZAD_FKK_SAMPLE_1206_NND5'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

* display aggr VK
      t_contexttab-fcode  = '&CT_NND6'.
      t_contexttab-funcname = 'ZAD_FKK_SAMPLE_1206_NND6'.
      call function 'ZAD_FKK_SAMPLE_1206_NND6'
        exporting
          i_give_only_text = 'X'
        importing
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      insert t_contexttab index 1.

  endcase.

ENDFUNCTION.
