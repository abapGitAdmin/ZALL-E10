FUNCTION /ADZ/ENET_NETZE_ZU_ADR_GAS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ADRC) TYPE  ADRC
*"     REFERENCE(AB) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(ND_VNBG_NR) TYPE  /ADZ/ENET_GAS_VNBG_NR
*"     REFERENCE(ND_TEILNETZ_NR) TYPE  /ADZ/ENET_GAS_TEILNETZ_NR
*"     REFERENCE(ND_NETZBEREICH_NR) TYPE  /ADZ/ENET_GAS_NETZBER_NR
*"     REFERENCE(MD_VNBG_NR) TYPE  /ADZ/ENET_GAS_VNBG_NR
*"     REFERENCE(MD_TEILNETZ_NR) TYPE  /ADZ/ENET_GAS_TEILNETZ_NR
*"     REFERENCE(MD_NETZBEREICH_NR) TYPE  /ADZ/ENET_GAS_NETZBER_NR
*"     REFERENCE(HD_VNBG_NR) TYPE  /ADZ/ENET_GAS_VNBG_NR
*"     REFERENCE(HD_TEILNETZ_NR) TYPE  /ADZ/ENET_GAS_TEILNETZ_NR
*"     REFERENCE(HD_NETZBEREICH_NR) TYPE  /ADZ/ENET_GAS_NETZBER_NR
*"     REFERENCE(KA_ID) TYPE  /ADZ/ENET_GAS_VNBG_NR
*"  EXCEPTIONS
*"      KEIN_NETZ
*"----------------------------------------------------------------------
  DATA: ls_adrc            TYPE adrc,
        ls_zadenet_plz_hnr TYPE /adz/g_n_haus,
        ls_zadenet_plz_str TYPE /adz/g_n_str,
        ls_zadenet_plz_ot  TYPE /adz/g_n_orte,
        ls_zadenet_plz     TYPE /adz/g_plz_nb.



  ls_adrc = adrc.
  "Netz auf hausnummernebene
  SELECT SINGLE * FROM /adz/g_n_haus
    INTO ls_zadenet_plz_hnr
    WHERE plz      = ls_adrc-post_code1
    "AND   ortsteil = ls_adrc-city2
    AND   strasse  = ls_adrc-street
    AND str_hnrbis >= ls_adrc-house_num1
    AND str_hnrvon <= ls_adrc-house_num1 AND gueltig_seit <= ab AND gueltig_bis > ab...
  IF sy-subrc = 0.

    nd_vnbg_nr = ls_zadenet_plz_hnr-nd_vnbg_nr.
    nd_teilnetz_nr = ls_zadenet_plz_hnr-nd_teilnetz_nr.
    nd_netzbereich_nr = ls_zadenet_plz_hnr-nd_netzbereich_nr.
    ka_id    = ls_zadenet_plz_hnr-ka_id.

  ENDIF.


  "Netz auf Strassenebene
  SELECT SINGLE * FROM /adz/g_n_str
    INTO ls_zadenet_plz_str
    WHERE plz      = ls_adrc-post_code1
    AND   ortsteil = ls_adrc-city2
    AND   strasse  = ls_adrc-street AND gueltig_seit <= ab AND gueltig_bis > ab...

  IF sy-subrc = 0.
    IF nd_vnbg_nr IS INITIAL.
      nd_vnbg_nr = ls_zadenet_plz_str-nd_vnbg_nr.
      nd_teilnetz_nr = ls_zadenet_plz_str-nd_teilnetz_nr.
      nd_netzbereich_nr = ls_zadenet_plz_str-nd_netzbereich_nr.
      ka_id    = ls_zadenet_plz_str-ka_id.
    ENDIF.
  ENDIF.
  "Netz auf Ortsteilebene
  SELECT SINGLE * FROM /adz/g_n_orte
    INTO ls_zadenet_plz_ot
    WHERE plz      = ls_adrc-post_code1
    AND   ortsteil = ls_adrc-city2 AND gueltig_seit <= ab AND gueltig_bis > ab...

  IF sy-subrc = 0.

    IF nd_vnbg_nr IS INITIAL.
      nd_vnbg_nr = ls_zadenet_plz_ot-nd_vnbg_nr.
      nd_teilnetz_nr = ls_zadenet_plz_ot-nd_teilnetz_nr.
      nd_netzbereich_nr = ls_zadenet_plz_ot-nd_netzbereich_nr.
    ENDIF.
    IF md_vnbg_nr IS INITIAL.
      md_vnbg_nr = ls_zadenet_plz_ot-md_vnbg_nr.
      md_teilnetz_nr = ls_zadenet_plz_ot-md_teilnetz_nr.
      md_netzbereich_nr = ls_zadenet_plz_ot-md_netzbereich_nr.
    ENDIF.
    IF hd_vnbg_nr IS INITIAL.
      hd_vnbg_nr = ls_zadenet_plz_ot-hd_vnbg_nr.
      hd_teilnetz_nr = ls_zadenet_plz_ot-hd_teilnetz_nr.
      hd_netzbereich_nr = ls_zadenet_plz_ot-hd_netzbereich_nr.
    ENDIF.
    SELECT SINGLE * FROM /adz/g_plz_nb
      INTO ls_zadenet_plz
      WHERE plz      = ls_adrc-post_code1 AND gueltig_seit <= ab AND gueltig_bis > ab.


    ka_id    = ls_zadenet_plz-ka_id .

  ENDIF.

  SELECT SINGLE * FROM /adz/g_plz_nb
    INTO ls_zadenet_plz
    WHERE plz      = ls_adrc-post_code1 AND gueltig_seit <= ab AND gueltig_bis > ab..

  IF sy-subrc = 0.
    IF nd_vnbg_nr IS INITIAL.
      nd_vnbg_nr = ls_zadenet_plz-nd_vnbg_nr.
      nd_teilnetz_nr = ls_zadenet_plz-nd_teilnetz_nr.
      nd_netzbereich_nr = ls_zadenet_plz-nd_netzbereich_nr.
    ENDIF.
    IF md_vnbg_nr IS INITIAL.
      md_vnbg_nr = ls_zadenet_plz-md_vnbg_nr.
      md_teilnetz_nr = ls_zadenet_plz-md_teilnetz_nr.
      md_netzbereich_nr = ls_zadenet_plz-md_netzbereich_nr.
    ENDIF.
    IF hd_vnbg_nr IS INITIAL.
      hd_vnbg_nr = ls_zadenet_plz-hd_vnbg_nr.
      hd_teilnetz_nr = ls_zadenet_plz-hd_teilnetz_nr.
      hd_netzbereich_nr = ls_zadenet_plz-hd_netzbereich_nr.
    ENDIF.
    if ka_id IS INITIAL.
    ka_id    = ls_zadenet_plz-ka_id .
    endif.
  ELSE.
    RAISE kein_netz.
  ENDIF.





ENDFUNCTION.
