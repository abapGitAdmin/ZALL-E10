*&---------------------------------------------------------------------*
*& Report zmarvin_hello_world
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmarvin_hello_world.

DATA(lv_user) = sy-uname.

WRITE: |Hi { lv_user }|.

SELECT SINGLE * FROM T100 INTO @DATA(ls_t100)
 WHERE sprsl = 'E'.

WRITE: ls_t100.
