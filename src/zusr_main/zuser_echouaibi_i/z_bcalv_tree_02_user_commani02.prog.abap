*----------------------------------------------------------------------*
***INCLUDE Z_BCALV_TREE_02_USER_COMMANI02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'ADD'.
      SELECT SINGLE *
            INTO ls_artikel
            FROM zdev_artikel
            WHERE artikelnr = zdev_artikel-artikelnr .

        ls_artikel-gesamtpreis = ls_artikel-verkpreis * ls_artikel-menge.

         summe = summe + ls_artikel-gesamtpreis.

      APPEND ls_artikel TO lt_artikel.
      CLEAR: ls_artikel.
      CLEAR: ok_code.
*      modify zdev_warenkorb from ls_artikel.
    WHEN 'REMOVE'.
      SELECT SINGLE artikelnr kurztext verkpreis
      INTO (ls_artikel-artikelnr, ls_artikel-kurztext , ls_artikel-verkpreis)
      FROM zdev_artikel
      WHERE artikelnr = zdev_artikel-artikelnr .

      DELETE lt_artikel WHERE artikelnr = ls_artikel-artikelnr.
        modify zdev_wk from ls_artikel.
          CLEAR: ls_artikel.
          CLEAR: ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
    WHEN OTHERS.

      MOVE-CORRESPONDING zdev_artikel TO ls_artikel.
      SELECT  SINGLE *
        FROM  zdev_artikel
        WHERE artikelnr = @ls_artikel-artikelnr
        INTO  CORRESPONDING FIELDS OF @ls_artikel.

  ENDCASE.

ENDMODULE.
