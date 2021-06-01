FUNCTION /adesso/enet_nne_gas .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VNBG_NR) TYPE  /ADESSO/ENET_GAS_VNBG_NR
*"     REFERENCE(TARIFGEBIET) TYPE  /ADESSO/ENET_GAS_TARIFGEBIET
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(ZAEHLERNR) TYPE  /ADESSO/ZAEHLERD
*"  EXPORTING
*"     REFERENCE(AP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(LP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(GP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(FLEI) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(FARB) TYPE  /ADESSO/ENET_PREISE_T
*"----------------------------------------------------------------------

  DATA:

    ls_ever            TYPE ever,
    lv_lieferstelle    TYPE /adesso/g_zaehlr-lieferstelle,
    lt_tinv_inv_line_b TYPE TABLE OF tinv_inv_line_b,
    ls_tinv_inv_line_b TYPE tinv_inv_line_b,
    lv_quant_arbeit    TYPE inv_quant,
    lv_quant_leistung  TYPE inv_quant,
    lv_jahr_arbeit     TYPE inv_quant,
    lv_jahr_leistung   TYPE inv_quant,
    lv_leistung        TYPE inv_quant,
    lv_arbeit          TYPE inv_quant,
    lv_feldname        TYPE string,
    lv_index           TYPE i,
    lv_index2          TYPE i,
    lt_vnaslp          TYPE TABLE OF /adesso/g_vnaslp,
    ls_vnaslp          TYPE /adesso/g_vnaslp,
    lt_vnlslp          TYPE TABLE OF /adesso/g_vnlslp,
    ls_vnlslp          TYPE /adesso/g_vnlslp,
    lt_vkkslp          TYPE TABLE OF /adesso/g_vkkslp,
    ls_vkkslp          TYPE /adesso/g_vkkslp,
    lt_vnalgk          TYPE TABLE OF /adesso/g_vnalgk,
    ls_vnalgk          TYPE /adesso/g_vnalgk,
    lt_vnllgk          TYPE TABLE OF /adesso/g_vnllgk,
    ls_vnllgk          TYPE /adesso/g_vnllgk,
    lt_vlklgk          TYPE TABLE OF /adesso/g_vlklgk,
    ls_vlklgk          TYPE /adesso/g_vlklgk,
    lv_exit            TYPE c,
    lt_vaklgk          TYPE TABLE OF /adesso/g_vaklgk,
    ls_vaklgk          TYPE /adesso/g_vaklgk,
    lv_operarb         TYPE ettifn-operand,
    lv_operlei         TYPE ettifn-operand,
    lt_ettifn          TYPE TABLE OF ettifn,
    ls_ettifn          TYPE ettifn,
    ls_preis           TYPE LINE OF /adesso/enet_preise_t.
  FIELD-SYMBOLS: <comp>, <comp2>, <preis>, <bemerkung> , <zone_kum> , <max_verbr>.
  DATA lv_faktor_verbr TYPE p DECIMALS 8.

  lv_faktor_verbr = ( bis - ab ) / 365.
  "Zur Bestimmung der Preise benötigen wir die Menge Arbeit und Leistung


  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_operarb WHERE report = 'ANLAGEFAKT' AND field = 'ARBEIT_G'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_operlei WHERE report = 'ANLAGEFAKT' AND field = 'LEISTUNG_G'.



  SELECT  * FROM ettifn INTO TABLE lt_ettifn WHERE anlage = anlage AND operand = lv_operlei AND ab =< ab .
  IF sy-subrc = 0.
    SORT lt_ettifn BY ab DESCENDING.
    READ TABLE lt_ettifn INTO ls_ettifn INDEX 1.
    lv_jahr_leistung = ls_ettifn-wert1.
  ENDIF.

  SELECT  * FROM ettifn INTO TABLE lt_ettifn WHERE anlage = anlage AND operand = lv_operarb AND ab =< ab .
  IF sy-subrc = 0.
    SORT lt_ettifn BY ab DESCENDING.
    READ TABLE lt_ettifn INTO ls_ettifn INDEX 1.
    lv_jahr_arbeit = ls_ettifn-wert1.
  ENDIF.




  SELECT SINGLE lieferstelle FROM /adesso/g_zaehlr INTO lv_lieferstelle WHERE zaehler_id  = zaehlernr.

  SELECT * FROM tinv_inv_line_b INTO TABLE lt_tinv_inv_line_b WHERE int_inv_doc_no = int_inv_doc_no.
  LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE date_from = ab AND date_to = bis.
    IF lv_lieferstelle = 'SLP'.
      CASE ls_tinv_inv_line_b-product_id.
        WHEN '9990001000269' .
          lv_quant_arbeit =  lv_quant_arbeit + ls_tinv_inv_line_b-quantity.
        WHEN '9990001000053'.
          lv_quant_leistung =  lv_quant_leistung + ls_tinv_inv_line_b-quantity.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
      CASE ls_tinv_inv_line_b-product_id.
        WHEN '9990001000417' .
          lv_quant_arbeit =  lv_quant_arbeit + ls_tinv_inv_line_b-quantity.
        WHEN '9990001000053'.
          lv_quant_leistung =  lv_quant_leistung + ls_tinv_inv_line_b-quantity.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.


  ENDLOOP.


      lv_index = 2.
      lv_leistung = lv_quant_leistung.
      lv_arbeit =  lv_quant_arbeit.


    IF lv_lieferstelle = 'SLP'.
      IF lv_index = 1.
        LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE product_id = '9990001000269' AND date_from = ab AND date_to = bis.



          SELECT  * FROM /adesso/g_vnaslp INTO TABLE lt_vnaslp WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vnaslp BY gueltig_seit DESCENDING.
          READ TABLE lt_vnaslp INTO ls_vnaslp INDEX 1.
          IF sy-subrc = 0.
            DO 20 TIMES.
              lv_feldname = 'G' && sy-index && '_BIS'.
              ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnaslp TO <comp>.
              IF <comp>  > lv_arbeit  .
                ls_preis-ab = ls_tinv_inv_line_b-date_from.
                ls_preis-bis = ls_tinv_inv_line_b-date_to.
                lv_feldname = 'G' && sy-index && '_AP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnaslp TO <preis>.
                ls_preis-preis = <preis>.
                lv_feldname = 'G' && sy-index && '_BEZ'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnaslp TO <bemerkung>.
                ls_preis-bemerkung = <bemerkung>.
                APPEND ls_preis TO ap.
                lv_feldname = 'G' && sy-index && '_GP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnaslp TO <preis>.
                ls_preis-preis = <preis>.
                APPEND ls_preis TO gp.
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.

          SELECT  * FROM /adesso/g_vkkslp INTO TABLE lt_vkkslp WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vnaslp BY gueltig_seit DESCENDING.
          READ TABLE lt_vkkslp INTO ls_vkkslp INDEX 1.
          IF sy-subrc = 0.
            DO 20 TIMES.
              lv_feldname = 'G' && sy-index && '_BIS'.
              ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vkkslp TO <comp>.
              IF <comp>  > lv_arbeit  .
                ls_preis-ab = ls_tinv_inv_line_b-date_from.
                ls_preis-bis = ls_tinv_inv_line_b-date_to.
                lv_feldname = 'G' && sy-index && '_AP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vkkslp TO <preis>.
                ls_preis-preis = <preis>.
                lv_feldname = 'G' && sy-index && '_BEZ'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vkkslp TO <bemerkung>.
                ls_preis-bemerkung = <bemerkung>.
                APPEND ls_preis TO ap.
                lv_feldname = 'G' && sy-index && '_GP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vkkslp TO <preis>.
                ls_preis-preis = <preis>.
                APPEND ls_preis TO gp.
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.

        ENDLOOP.

        LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE product_id = '9990001000053' AND date_from = ab AND date_to = bis.

          SELECT  * FROM /adesso/g_vnlslp INTO TABLE lt_vnlslp WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vnlslp BY gueltig_seit DESCENDING.
          READ TABLE lt_vnlslp INTO ls_vnlslp INDEX 1.
          IF sy-subrc = 0.
            DO 15 TIMES.
              lv_feldname = 'SLP' && sy-index && '_L_BIS'.
              ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnlslp TO <comp>.
              IF <comp> > lv_arbeit.
                ls_preis-ab = ls_tinv_inv_line_b-date_from.
                ls_preis-bis = ls_tinv_inv_line_b-date_to.
                lv_feldname = 'SLP' && sy-index && '_L_AP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnlslp TO <preis>.
                ls_preis-preis = <preis>.
                lv_feldname = 'SLP' && sy-index && '_L_BEZ'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnlslp TO <bemerkung>.
                ls_preis-bemerkung = <bemerkung>.
                APPEND ls_preis TO lp.
                lv_feldname = 'SLP' && sy-index && '_L_GP'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnlslp TO <preis>.
                ls_preis-preis = <preis>.
                APPEND ls_preis TO gp.
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ELSEIF lv_lieferstelle = 'LGK'.

      LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE product_id = '9990001000269' AND date_from = ab AND date_to = bis..

        IF lv_arbeit IS NOT INITIAL.
          SELECT  * FROM /adesso/g_vnalgk INTO TABLE lt_vnalgk WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vnalgk BY gueltig_seit DESCENDING.
          READ TABLE lt_vnalgk INTO ls_vnalgk INDEX 1.
          IF sy-subrc = 0.
            IF ls_vnalgk-sigmoid_ovap = 0.
              "Berechnung nach Zonen
              DO 22 TIMES.
                lv_feldname = 'LGK' && sy-index && '_A_BIS'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <comp>.
                lv_feldname = 'LGK' && sy-index && '_A_VON'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <comp2>.
                IF <comp2> * lv_faktor_verbr <= lv_arbeit AND <comp> * lv_faktor_verbr >= lv_arbeit or <comp> = 0.
                  ls_preis-ab = ls_tinv_inv_line_b-date_from.
                  ls_preis-bis = ls_tinv_inv_line_b-date_to.
                  lv_feldname = 'LGK' && sy-index && '_A_AP'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <preis>.
                  ls_preis-preis = <preis>.
                  lv_feldname = 'LGK' && sy-index && '_A_BEZ'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <bemerkung>.
                  ls_preis-bemerkung = <bemerkung>.
                  APPEND ls_preis TO ap.
                  " APPEND ls_preis TO ap.
                  IF sy-index <> 1.
                    IF lv_index = 2.
                      lv_feldname = 'LGK' && sy-index && '_A_GP'.
                      ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <zone_kum>.
                      ls_preis-ab = ls_tinv_inv_line_b-date_from.
                      ls_preis-bis = ls_tinv_inv_line_b-date_to.
                      ls_preis-bemerkung = 'Fixe Arbeitkomponente'.
                      ls_preis-preis = <zone_kum>.
                      APPEND ls_preis TO farb.
                    ELSEIF lv_index = 1.
                      "Zonen vorher auch abbilden.
                      lv_index2 = sy-index.
                      DO lv_index2 - 1 TIMES.
                        lv_feldname = 'LGK' && sy-index && '_A_AP'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <preis>.
                        ls_preis-preis = <preis>.
                        lv_feldname = 'LGK' && sy-index && '_A_BEZ'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <bemerkung>.
                        ls_preis-bemerkung = <bemerkung>.
                        ls_preis-ab = ls_tinv_inv_line_b-date_from.
                        ls_preis-bis = ls_tinv_inv_line_b-date_to.
                        APPEND ls_preis TO ap.

                      ENDDO.
                    ENDIF.
*                  lv_index = sy-index - 1.
*                  lv_feldname = 'LGK' &&  lv_index && '_A_BIS'.
*                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <max_verbr>.
*                  ls_preis-preis = ( <zone_kum> + <preis> * ( lv_quant_arbeit - <max_verbr> ) / lv_quant_arbeit ).
*                  APPEND ls_preis TO ap.
                  ELSE.
                    ls_preis-preis = <preis>.
                    APPEND ls_preis TO ap.
                  ENDIF.
                  EXIT.
                ENDIF.
              ENDDO.
            ELSE.
              "Berechnung nach Formel
              ls_preis-ab = ls_tinv_inv_line_b-date_from.
              ls_preis-bis = ls_tinv_inv_line_b-date_to.
              ls_preis-bemerkung = 'Berechnung über Sigmoid Formel'.
              ls_preis-preis = ( ( ls_vnalgk-sigmoid_ovap / ( 1 + ( ( lv_quant_arbeit / ls_vnalgk-sigmoid_wpa ) ** ls_vnalgk-sigmoid_ea ) ) ) + ls_vnalgk-sigmoid_otap ) / lv_quant_arbeit.
              APPEND ls_preis TO ap.
              lv_exit = 'X'.

            ENDIF.
          ENDIF.

          SELECT  * FROM /adesso/g_vaklgk INTO TABLE lt_vaklgk WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vaklgk BY gueltig_seit DESCENDING.
          READ TABLE lt_vaklgk INTO ls_vaklgk INDEX 1.
          IF sy-subrc = 0.
            IF ls_vaklgk-sigmoid_ovap = 0.
              DO 16 TIMES.
                lv_feldname = 'LGK' && sy-index && '_A_BIS'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <comp>.
                lv_feldname = 'LGK' && sy-index && '_A_VON'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <comp2>.
                IF <comp2> * lv_faktor_verbr <= lv_arbeit AND <comp> * lv_faktor_verbr >= lv_arbeit or <comp> = 0.
                  ls_preis-ab = ls_tinv_inv_line_b-date_from.
                  ls_preis-bis = ls_tinv_inv_line_b-date_to.
                  lv_feldname = 'LGK' && sy-index && '_A_AP'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vaklgk TO <preis>.
                  ls_preis-preis = <preis>.
                  lv_feldname = 'LGK' && sy-index && '_A_BEZ'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vaklgk TO <bemerkung>.
                  ls_preis-bemerkung = <bemerkung>.
                  APPEND ls_preis TO ap.
                  IF sy-index <> 1.
                    IF lv_index = 2.
                      lv_feldname = 'LGK' && sy-index && '_A_GP'.
                      ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <zone_kum>.
                      ls_preis-ab = ls_tinv_inv_line_b-date_from.
                      ls_preis-bis = ls_tinv_inv_line_b-date_to.
                      ls_preis-bemerkung = 'Fixe Arbeitkomponente'.
                      ls_preis-preis = <zone_kum>.
                      APPEND ls_preis TO farb.
                    ELSEIF lv_index = 1.
                      "Zonen vorher auch abbilden.
                      lv_index2 = sy-index.
                      DO lv_index2 - 1 TIMES.
                        lv_feldname = 'LGK' && sy-index && '_A_AP'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <preis>.
                        ls_preis-preis = <preis>.
                        lv_feldname = 'LGK' && sy-index && '_A_BEZ'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <bemerkung>.
                        ls_preis-bemerkung = <bemerkung>.
                        ls_preis-ab = ls_tinv_inv_line_b-date_from.
                        ls_preis-bis = ls_tinv_inv_line_b-date_to.
                        APPEND ls_preis TO ap.

                      ENDDO.
                    ENDIF.


                  ELSE.
                    ls_preis-preis = <preis>.
                    APPEND ls_preis TO ap.
                  ENDIF.
                  EXIT.
                ENDIF.
              ENDDO.
            ELSE.
              "Berechnung nach Formel
              ls_preis-ab = ls_tinv_inv_line_b-date_from.
              ls_preis-bis = ls_tinv_inv_line_b-date_to.
              ls_preis-bemerkung = 'Berechnung über Sigmoid Formel'.
              ls_preis-preis = ( ( ls_vaklgk-sigmoid_ovap / ( 1 + ( ( lv_quant_arbeit / ls_vaklgk-sigmoid_wpa ) ** ls_vaklgk-sigmoid_ea ) ) ) + ls_vaklgk-sigmoid_otap ) / lv_quant_arbeit.
              APPEND ls_preis TO ap.
              lv_exit = 'X'.

            ENDIF.
          ENDIF.
        ENDIF.
*    ENDIF.
      ENDLOOP.

      LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE product_id = '9990001000053' AND date_from = ab AND date_to = bis..

        IF lv_leistung IS NOT INITIAL.
          SELECT  * FROM /adesso/g_vnllgk INTO TABLE lt_vnllgk WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vnllgk BY gueltig_seit DESCENDING.
          READ TABLE lt_vnllgk INTO ls_vnllgk INDEX 1.
          IF sy-subrc = 0.
            IF ls_vnllgk-sigmoid_ovlp = 0.
              "Berechnung nach Zonen
              DO 30 TIMES.
                lv_feldname = 'LGK' && sy-index && '_L_BIS'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnllgk TO <comp>.
                IF <comp> > lv_leistung .
                  ls_preis-ab = ls_tinv_inv_line_b-date_from.
                  ls_preis-bis = ls_tinv_inv_line_b-date_to.
                  lv_feldname = 'LGK' && sy-index && '_L_LP'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnllgk TO <preis>.
                  ls_preis-preis = <preis>.
                  lv_feldname = 'LGK' && sy-index && '_L_BEZ'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnllgk TO <bemerkung>.
                  ls_preis-bemerkung = <bemerkung>.
                  APPEND ls_preis TO lp.
                  IF sy-index <> 1.
                    IF lv_index = 2.
                      lv_feldname = 'LGK' && sy-index && '_L_GP'.
                      ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnllgk TO <zone_kum>.
                      ls_preis-ab = ls_tinv_inv_line_b-date_from.
                      ls_preis-bis = ls_tinv_inv_line_b-date_to.
                      ls_preis-bemerkung = 'Fixe Leistungskomponente'.
                      ls_preis-preis = <zone_kum>.
                      APPEND ls_preis TO flei.

                    ELSEIF lv_index = 1.
                      "Zonen vorher auch abbilden.
                      lv_index2 = sy-index.
                      DO lv_index2 - 1 TIMES.
                        lv_feldname = 'LGK' && sy-index && '_L_LP'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <preis>.
                        ls_preis-preis = <preis>.
                        lv_feldname = 'LGK' && sy-index && '_L_BEZ'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <bemerkung>.
                        ls_preis-bemerkung = <bemerkung>.
                        ls_preis-ab = ls_tinv_inv_line_b-date_from.
                        ls_preis-bis = ls_tinv_inv_line_b-date_to.
                        APPEND ls_preis TO lp.

                      ENDDO.
                    ENDIF.


                  ELSE.
                    ls_preis-preis = <preis>.
                    APPEND ls_preis TO lp.
                  ENDIF.
                  EXIT.
                ENDIF.
              ENDDO.
            ELSE.
              "Berechnung nach Formel
              ls_preis-ab = ls_tinv_inv_line_b-date_from.
              ls_preis-bis = ls_tinv_inv_line_b-date_to.
              ls_preis-bemerkung = 'Berechnung über Sigmoid Formel'.
              ls_preis-preis = ( ( ls_vnllgk-sigmoid_ovlp / ( 1 + ( ( lv_quant_leistung / ls_vnllgk-sigmoid_wpl ) ** ls_vnllgk-sigmoid_el ) ) ) + ls_vnllgk-sigmoid_otlp ) / lv_quant_leistung.
              APPEND ls_preis TO lp.
              lv_exit = 'X'.

            ENDIF.
          ENDIF.

          SELECT  * FROM /adesso/g_vlklgk INTO TABLE lt_vlklgk WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND gueltig_seit < ls_tinv_inv_line_b-date_from AND id = '01'.
          SORT lt_vlklgk BY gueltig_seit DESCENDING.
          READ TABLE lt_vlklgk INTO ls_vlklgk INDEX 1.
          IF sy-subrc = 0.
            IF ls_vlklgk-sigmoid_ovlp = 0.
              DO 30 TIMES.
                lv_feldname = 'LGK' && sy-index && '_L_BIS'.
                ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vlklgk TO <comp>.
                IF <comp> > lv_leistung  .
                  ls_preis-ab = ls_tinv_inv_line_b-date_from.
                  ls_preis-bis = ls_tinv_inv_line_b-date_to.
                  lv_feldname = 'LGK' && sy-index && '_L_LP'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vlklgk TO <preis>.
                  ls_preis-preis = <preis>.
                  lv_feldname = 'LGK' && sy-index && '_L_BEZ'.
                  ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vlklgk TO <bemerkung>.
                  ls_preis-bemerkung = <bemerkung>.
                  APPEND ls_preis TO lp.
                  IF sy-index <> 1.
                    IF lv_index = 2.
                      lv_feldname = 'LGK' && sy-index && '_L_GP'.
                      ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <zone_kum>.
                      ls_preis-ab = ls_tinv_inv_line_b-date_from.
                      ls_preis-bis = ls_tinv_inv_line_b-date_to.
                      ls_preis-bemerkung = 'Fixe Leistungskomponente'.
                      ls_preis-preis = <zone_kum>.
                      APPEND ls_preis TO flei.

                    ELSEIF lv_index = 1.
                      "Zonen vorher auch abbilden.
                      lv_index2 = sy-index.
                      DO lv_index2 - 1 TIMES.
                        lv_feldname = 'LGK' && sy-index && '_L_LP'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <preis>.
                        ls_preis-preis = <preis>.
                        lv_feldname = 'LGK' && sy-index && '_L_BEZ'.
                        ASSIGN COMPONENT lv_feldname OF STRUCTURE ls_vnalgk TO <bemerkung>.
                        ls_preis-bemerkung = <bemerkung>.
                        ls_preis-ab = ls_tinv_inv_line_b-date_from.
                        ls_preis-bis = ls_tinv_inv_line_b-date_to.
                        APPEND ls_preis TO lp.

                      ENDDO.
                    ENDIF.


                  ELSE.
                    ls_preis-preis = <preis>.
                    APPEND ls_preis TO lp.
                  ENDIF.
                  EXIT.
                ENDIF.
              ENDDO.
            ELSE.
              "Berechnung nach Formel
              ls_preis-ab = ls_tinv_inv_line_b-date_from.
              ls_preis-bis = ls_tinv_inv_line_b-date_to.
              ls_preis-bemerkung = 'Berechnung über Sigmoid Formel'.
              ls_preis-preis = ( ( ls_vlklgk-sigmoid_ovlp / ( 1 + ( ( lv_quant_leistung / ls_vlklgk-sigmoid_wpl ) ** ls_vlklgk-sigmoid_el ) ) ) + ls_vlklgk-sigmoid_otlp ) / lv_quant_leistung.
              APPEND ls_preis TO lp.
              lv_exit = 'X'.

            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.






ENDFUNCTION.
