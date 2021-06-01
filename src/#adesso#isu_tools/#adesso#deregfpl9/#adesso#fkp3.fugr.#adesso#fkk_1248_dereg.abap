FUNCTION /adesso/fkk_1248_dereg.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_HERKF_GROUP) TYPE  HERKF_KK OPTIONAL
*"     VALUE(I_FKKEPOS) TYPE  FKKEPOS OPTIONAL
*"     VALUE(I_VATYP) TYPE  VATYP_KK OPTIONAL
*"  TABLES
*"      T_CONTEXTTAB STRUCTURE  FKKL1_CTMENU
*"----------------------------------------------------------------------

  DATA: h_ftext TYPE ktext_ari.

* Aufruf des bisher verwendeten Funktionsbaustein
  CALL FUNCTION 'ISU_EVENT_1248'
    EXPORTING
      i_herkf_group = i_herkf_group
    TABLES
      t_contexttab  = t_contexttab.


  CASE i_herkf_group.

    WHEN 'R4' OR 'RA' OR 'R9'.  " invoicing documents
* line to separate new entries from others
      t_contexttab-uline  = 'X'.
      MODIFY t_contexttab INDEX 1 TRANSPORTING uline.
      t_contexttab-uline = space.

* display aggr.Document
      t_contexttab-fcode  = '&CT_NND1'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND1'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND1'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display Serviceprovider
      t_contexttab-fcode  = '&CT_NND2'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND2'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND2'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display REMADV
      t_contexttab-fcode  = '&CT_NND3'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND3'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND3'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display ETHI_DIS
      t_contexttab-fcode  = '&CT_NND5'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND5'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND5'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display aggr VK
      t_contexttab-fcode  = '&CT_NND6'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND6'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND6'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

    WHEN '05'.  " payment
* line to separate new entries from others
      t_contexttab-uline  = 'X'.
      MODIFY t_contexttab INDEX 1 TRANSPORTING uline.
      t_contexttab-uline = space.

* display Serviceprovider
      t_contexttab-fcode  = '&CT_NND2'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND2'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND2'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display REMADV
      t_contexttab-fcode  = '&CT_NND3'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND3'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND3'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display Distribution Lot
      t_contexttab-fcode  = '&CT_NND4'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND4'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND4'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display ETHI_DIS
      t_contexttab-fcode  = '&CT_NND5'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND5'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND5'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

* display aggr VK
      t_contexttab-fcode  = '&CT_NND6'.
      t_contexttab-funcname = '/ADESSO/FKK_1206_NND6'.
      CALL FUNCTION '/ADESSO/FKK_1206_NND6'
        EXPORTING
          i_give_only_text = 'X'
        IMPORTING
          e_ftext          = h_ftext
          e_messages       = t_contexttab-xmess.
      t_contexttab-ftext = h_ftext.
      INSERT t_contexttab INDEX 1.

  ENDCASE.

ENDFUNCTION.
