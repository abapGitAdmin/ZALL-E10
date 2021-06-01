FUNCTION /ADZ/ENET_NETZE_ZU_ADRESSE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ADRC) TYPE  ADRC
*"     REFERENCE(AB) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(NETZ_NSP) TYPE  GRID_ID
*"     REFERENCE(NETZ_MSP) TYPE  GRID_ID
*"     REFERENCE(NETZ_HSP) TYPE  GRID_ID
*"     REFERENCE(KA_ID) TYPE  GRID_ID
*"  EXCEPTIONS
*"      KEIN_NETZ
*"----------------------------------------------------------------------
  DATA: ls_adrc            TYPE adrc,
        ls_zadenet_plz_hnr TYPE /adz/plz_hnr,
        ls_zadenet_plz_str TYPE /adz/plz_str,
        ls_zadenet_plz_ot  TYPE /adz/plz_ot,
        ls_zadenet_plz     TYPE /adz/enet_plz.



  ls_adrc = adrc.
  "Netz auf hausnummernebene
  SELECT SINGLE * FROM /adz/plz_hnr
    INTO ls_zadenet_plz_hnr
    WHERE plz      = ls_adrc-post_code1
    "AND   ortsteil = ls_adrc-city2
    AND   strasse  = ls_adrc-street
    AND str_hnrbis >= ls_adrc-house_num1
    AND str_hnrvon <= ls_adrc-house_num1 AND gueltig_seit <= ab AND gueltig_bis > ab...
  IF sy-subrc = 0.

    netz_nsp = ls_zadenet_plz_hnr-netz_nsp.
    netz_msp = ls_zadenet_plz_hnr-netz_nr_msp.
    netz_hsp = ls_zadenet_plz_hnr-netz_nr_hsp.
    ka_id    = ls_zadenet_plz_hnr-ka_id.


  ELSE.

    "Netz auf Strassenebene
    SELECT SINGLE * FROM /adz/plz_str
      INTO ls_zadenet_plz_str
      WHERE plz      = ls_adrc-post_code1
      AND   ortsteil = ls_adrc-city2
      AND   strasse  = ls_adrc-street AND gueltig_seit <= ab AND gueltig_bis > ab...

    IF sy-subrc = 0.

      netz_nsp = ls_zadenet_plz_str-netz_nsp.
      netz_msp = ls_zadenet_plz_str-netz_nr_msp.
      netz_hsp = ls_zadenet_plz_str-netz_nr_hsp.
      ka_id    = ls_zadenet_plz_str-ka_id.

    ELSE.
      "Netz auf Ortsteilebene
      SELECT SINGLE * FROM /adz/plz_ot
        INTO ls_zadenet_plz_ot
        WHERE plz      = ls_adrc-post_code1
        AND   ortsteil = ls_adrc-city2 AND gueltig_seit <= ab AND gueltig_bis > ab...

      IF sy-subrc = 0.

        netz_nsp = ls_zadenet_plz_ot-netz_nsp.
        netz_msp = ls_zadenet_plz_ot-netz_nr_msp.
        netz_hsp = ls_zadenet_plz_ot-netz_nr_hsp.
        " ka_id    = ls_zadenet_plz_ot-ka_id.
        SELECT SINGLE * FROM /adz/enet_plz
          INTO ls_zadenet_plz
          WHERE plz      = ls_adrc-post_code1 AND gueltig_seit <= ab AND gueltig_bis > ab.


        ka_id    = ls_zadenet_plz-ka_id .

      ELSE.

        SELECT SINGLE * FROM /adz/enet_plz
          INTO ls_zadenet_plz
          WHERE plz      = ls_adrc-post_code1 AND gueltig_seit <= ab AND gueltig_bis > ab..

        IF sy-subrc = 0.

          netz_nsp = ls_zadenet_plz-netz_nr.
          netz_msp = ls_zadenet_plz-netz_nr_msp.
          netz_hsp = ls_zadenet_plz-netz_nr_hsp.
          ka_id    = ls_zadenet_plz-ka_id.

        ELSE.
          RAISE kein_netz.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.




ENDFUNCTION.
