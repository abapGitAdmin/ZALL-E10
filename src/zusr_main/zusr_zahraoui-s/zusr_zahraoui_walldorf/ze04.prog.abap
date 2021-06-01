*&---------------------------------------------------------------------*
*&  Include           ZE01
*&---------------------------------------------------------------------*
 " für tabstrip.

 INITIALIZATION.
   " s.o initialisieren für carrid
   MOVE: 'AA'TO so_fnr-low,
         'QF'TO  so_fnr-high,
         'BT' TO so_fnr-option,
         'I' TO so_fnr-sign.
   APPEND so_fnr.
clear so_fnr.
move: 'AZ' to so_fnr-low,
      'EQ' to so_fnr-option,
      'E' to so_fnr-sign.
append so_fnr.
"änderungen für tabstrip von der Puschbutton.


   tab1 = 'Verbindungen'.
   tab2 = 'Datum'.
   tab3 = 'Type von der fluege'.
   " setzen zweites seite der Tab als initial tab

   Flugsgeselschaft-activetab = 'Date'.
   Flugsgeselschaft-dynnr = '1002'.
   " text für Drucktaste" text für anzeigen uns

   gv_text = 'Details ausblenden'(p02).



   " block para
   at SELECTION-SCREEN on BLOCK param .
     CHECK pa_kn2 = 'X' and  so_land = space.
     MESSAGE e003(0100).

" überprüfen Länder gür national flüge.
   " Ereignisse bei selection screen output
 AT SELECTION-SCREEN OUTPUT.
   CASE  sy-dynnr.
     	WHEN 1001.
       LOOP AT SCREEN.
         IF screen-group1 = 'DET'.
           screen-active = 1.
           MODIFY SCREEN.

         ENDIF.
       ENDLOOP.

       IF gv_switch = '1'.
         gv_text = TEXT-p02.
       ELSE.
         gv_text = TEXT-p01.
         " löschen additional s.o.
         REFRESH :
         so_ab,
         so_an.
       ENDIF.
   ENDCASE.
   " Ereigniss at Selection screen input

 AT SELECTION-SCREEN.
   " evaluiren pushbutton commnad.
   CASE sscrfields-ucomm.
     WHEN 'DETAILS'.
       CHECK sy-dynnr = 1001.
       IF gv_switch = '1'.
         gv_switch = '0'.
       ELSE.
         gv_switch = '1'.

       ENDIF.

   ENDCASE.
   START-OF-SELECTION.

  CASE gc_mark.
    WHEN pa_kn1.

      SELECT * FROM spfli INTO gs_spfli
        WHERE carrid IN so_fnr
        AND fltime IN so_datu2
        AND arrtime IN so_datu2
        AND cityfrom IN so_ab
        AND cityto IN so_an
        AND countryto <> spfli~countryfr
      .


        WRITE: / gs_spfli-connid,
                 gs_spfli-carrid,
      "           gs_spfli-fldate,
                 gs_spfli-countryfr,
                 gs_spfli-airpfrom,
                 gs_spfli-cityfrom,
                 gs_spfli-countryto,
                 gs_spfli-cityfrom,
                 gs_spfli-airpto.


      ENDSELECT.

    WHEN pa_kn2.

      SELECT * FROM spfli INTO gs_spfli
     WHERE carrid IN so_fnr
     AND fltime IN so_datu2
     AND arrtime IN so_datu2
         AND cityfrom IN so_ab
     AND cityto IN so_an
     AND countryto = spfli~countryfr.

        WRITE: / gs_spfli-connid,
          gs_spfli-carrid,
"           gs_spfli-fldate,
          gs_spfli-countryfr,
          gs_spfli-airpfrom,
          gs_spfli-cityfrom,
          gs_spfli-countryto,
          gs_spfli-cityfrom,
          gs_spfli-airpto.
      ENDSELECT.

    WHEN pa_kn3.
      "radiobutton international ist markiert.

      SELECT * FROM spfli INTO gs_spfli
          WHERE carrid IN so_fnr
          AND connid IN so_con
          AND arrtime IN so_datu2
          AND cityfrom IN so_ab
          AND cityto IN so_an
          AND countryto <> spfli~countryfr.

        WRITE: / gs_spfli-connid,
          gs_spfli-carrid,
"           gs_spfli-fldate,
          gs_spfli-countryfr,
          gs_spfli-airpfrom,
          gs_spfli-cityfrom,
          gs_spfli-countryto,
          gs_spfli-cityfrom,
          gs_spfli-airpto.
      ENDSELECT.

  ENDCASE.
