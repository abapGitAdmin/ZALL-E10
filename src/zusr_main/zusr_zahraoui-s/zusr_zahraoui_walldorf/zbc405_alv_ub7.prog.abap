*&---------------------------------------------------------------------*
*& Report ZBC405_ALV_UB5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBC405_ALV_UB7.

DATA:
      gt_FLIGHTs TYPE TABLE OF SFLIGHT,
      gs_FLIGHT TYPE SFLIGHT,
      ok_code LIKE  sy-ucomm,
      go_alv type REF TO cl_gui_custom_alv_grid,
      go_cont TYPE REF TO cl_gui_custom_container,
      "üb7.
      gv_variant TYPE disvariant.
PARAMETERS:
pa_lv TYPE   disvariant-variant.



SELECT-OPTIONS:
so_car FOR gs_FLIGHT-carrid,
so_con FOR gs_FLIGHT-connid.


" so_con FOR gs_SFLIGHT-connid.


START-OF-SELECTION.

SELECT * from SFLIGHT INTO TABLE gt_FLIGHTs
  WHERE carrid in so_car
  and   connid in so_con.
  call SCREEN 100.
INCLUDE ZBC405_ALV_UB70_CLEAR_OK.
*INCLUDE zbc405_alv_ub5_clear_ok_codo01.
INCLUDE ZBC405_ALV_UB7_STATUS.
*INCLUDE zbc405_alv_ub5_status_0100o01.
INCLUDE ZALV_UB7CREATE_AND_TRANSFER.
*include zalv_ub6create_and_transfer.
INCLUDE ZBC405_ALV_UB7_USER_COMMANDI01.
*INCLUDE zbc405_alv_ub5_user_commandi01.
