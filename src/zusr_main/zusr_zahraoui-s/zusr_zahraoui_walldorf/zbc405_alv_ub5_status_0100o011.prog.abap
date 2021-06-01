*----------------------------------------------------------------------*
***INCLUDE ZBC405_ALV_UB5_STATUS_0100O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'DYN'.
  SET TITLEBAR 'T1'.
ENDMODULE.

MODULE create_and_transfer OUTPUT.

  IF go_container is INITIAL.


  CREATE OBJECT go_container
    EXPORTING
*      parent                      =
      container_name              = 'MY_CONTROL_AREA'

EXCEPTIONS
  OTHERS = 1
      .
  IF sy-subrc <> 0.
    MESSAGE a010(bc405_408).
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CREATE OBJECT go_alv
    EXPORTING
*      i_shellstyle =
*      i_lifetime =
      i_parent = go_container
      EXCEPTIONS
        OTHERS = 1.

  IF sy-subrc <> 0.
    MESSAGE a010(bc405_408).
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "set_table aufrufen mit objekt von alv
  go_alv->set_table_for_first_display(
  EXPORTING
    i_structure_name = 'spfli'
    CHANGING
      it_outtab = gt_flights
    EXCEPTIONS
    OTHERS = 1 ).
  IF sy-subrc <> 0.
     MESSAGE a010(bc405_408).
    ENDIF.
  ENDIF.
  ENDMODULE.
