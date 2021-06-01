*&---------------------------------------------------------------------*
*& Report ZBC405_ALV_UB5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBC405_ALV_UB5.

DATA:
      gt_FLIGHTs TYPE TABLE OF SFLIGHT,
      gs_FLIGHT TYPE SFLIGHT,
      ok_code LIKE  sy-ucomm.
    "  go_alv type REF TO cl_gui_custom_alv_grid,
     " go_cont TYPE REF TO cl_gui_custom_container..

SELECT-OPTIONS:
so_car FOR gs_FLIGHT-carrid,
so_con FOR gs_FLIGHT-connid.


" so_con FOR gs_SFLIGHT-connid.


START-OF-SELECTION.

SELECT * from SFLIGHT INTO TABLE gt_FLIGHTs
  WHERE carrid in so_car
  and   connid in so_con.
  call SCREEN 100.
INCLUDE zbc405_alv_ub5_clear_ok_codo01.
INCLUDE zbc405_alv_ub5_status_0100o01.

INCLUDE zbc405_alv_ub5_user_commandi01.
