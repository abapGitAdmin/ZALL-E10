CLASS /adz/cl_inv_func_invoice DEFINITION
  PUBLIC
  INHERITING FROM /adz/cl_inv_func_common
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    METHODS show_text REDEFINITION .

    METHODS execute_process REDEFINITION .
    METHODS dun_lock       REDEFINITION.
    METHODS dun_unlock     REDEFINITION.
    METHODS balance        REDEFINITION.
    METHODS beende_remadv  REDEFINITION.
    METHODS cancel_ap      REDEFINITION.
    METHODS cancel_abr     REDEFINITION.
    METHODS cancel_memi    REDEFINITION.
    METHODS cancel_mgv     REDEFINITION.
    METHODS cancel_nne     REDEFINITION.
    METHODS send_mail      REDEFINITION.
    METHODS show_pdoc      REDEFINITION.
    METHODS show_swt       REDEFINITION.
    METHODS write_note     REDEFINITION.
    METHODS abl_per_comdis REDEFINITION.

  PRIVATE SECTION.

ENDCLASS.



CLASS /adz/cl_inv_func_invoice IMPLEMENTATION.


 METHOD execute_process.
    CHECK NOT me->check_sperre( ).
    me->ucom_proc( ).
    WAIT UNTIL mv_akt_proz = 0.
  ENDMETHOD.

  METHOD show_text.
** variablen
    DATA: lt_fieldcat_ext TYPE TABLE OF slis_fieldcat_alv.

    SELECT * FROM /adz/invtext INTO TABLE @DATA(lt_texte) WHERE int_inv_doc_nr = @iv_doc_no.

* Kennung
    lt_fieldcat_ext = value #(
     ( " Kennung
       fieldname = 'INT_INV_DOC_NR' ref_tabname = '/ADZ/INVTEXT' )
     ( " AB
       fieldname = 'DATUM'         ref_tabname = '/ADZ/INVTEXT' )
     ( " BIS
       fieldname = 'UNAME'         ref_tabname = '/ADZ/INVTEXT' )
     ( "  Menge
       fieldname = 'ACTION'       ref_tabname = '/ADZ/INVTEXT' )
     ( "  Text
       fieldname = 'TEXT'         ref_tabname = '/ADZ/INVTEXT' )
     ).


    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat           = lt_fieldcat_ext
        i_screen_start_column = 10
        i_screen_start_line   = 10
        i_screen_end_column   = 200
        i_screen_end_line     = 20
      TABLES
        t_outtab              = lt_texte
      EXCEPTIONS
        program_error         = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE sy-msgty.
    ENDIF.

  ENDMETHOD.

  METHOD dun_lock.
  ENDMETHOD.

  METHOD dun_unlock.
  ENDMETHOD.

  METHOD balance.
  ENDMETHOD.

  METHOD beende_remadv.
  ENDMETHOD.

  METHOD cancel_abr.
  ENDMETHOD.

  METHOD cancel_ap.
  ENDMETHOD.


  METHOD cancel_memi.
  ENDMETHOD.

  METHOD cancel_mgv.
  ENDMETHOD.

  METHOD cancel_nne.
  ENDMETHOD.

  METHOD send_mail.
  ENDMETHOD.

  METHOD show_pdoc.
  ENDMETHOD.

  METHOD show_swt.
  ENDMETHOD.

  METHOD write_note.
  ENDMETHOD.

  METHOD abl_per_comdis.
  ENDMETHOD.

ENDCLASS.

