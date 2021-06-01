FUNCTION /adesso/fkk_sample_5052.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_POSTYP) TYPE  POSTYP_KK
*"     REFERENCE(I_FKKCOLLH_I) LIKE  FKKCOLLH_I STRUCTURE  FKKCOLLH_I
*"       OPTIONAL
*"     REFERENCE(I_LFDNR) TYPE  LFDNR_KK OPTIONAL
*"  CHANGING
*"     REFERENCE(C_FKKCOLLP_IM) LIKE  FKKCOLLP_IM STRUCTURE
*"        FKKCOLLP_IM OPTIONAL
*"     REFERENCE(C_FKKCOLLP_IP) LIKE  FKKCOLLP_IP STRUCTURE
*"        FKKCOLLP_IP OPTIONAL
*"     REFERENCE(C_FKKCOLLP_IR) LIKE  FKKCOLLP_IR STRUCTURE
*"        FKKCOLLP_IR OPTIONAL
*"----------------------------------------------------------------------

  DATA: ls_dfkkzp    TYPE dfkkzp.
  DATA: ls_dfkkop    TYPE dfkkop.
  DATA: ls_dfkkcollh TYPE dfkkcollh.
  DATA: lt_nfhf      TYPE TABLE OF /adesso/ink_nfhf.  "Hauptvorgänge SR/HF/NF
  DATA: ls_nfhf      TYPE /adesso/ink_nfhf.
  DATA: gr_hvorg     TYPE RANGE OF hvorg_kk.
  DATA: gs_hvorg     LIKE LINE OF gr_hvorg.


* Customizing
  SELECT * FROM /adesso/ink_nfhf
           INTO TABLE lt_nfhf
           WHERE schlr = const_marked.

  LOOP AT lt_nfhf INTO ls_nfhf.
    CLEAR gs_hvorg.
    gs_hvorg-option = 'EQ'.
    gs_hvorg-sign   = 'I'.
    gs_hvorg-low    = ls_nfhf-hvorg.
    APPEND gs_hvorg TO gr_hvorg.
  ENDLOOP.

  CASE i_postyp .

    WHEN '1'     "Zahlung
      OR '4'     "Storno Zahlung
      OR '5'     "Augleich bzw. Teilausgleich
      OR '6'     "Zahlung Inkassobüro
      OR '8'.    "Ausbuchung abgegebene Forderung

*     Payment: use structure C_FKKCOLLP_IP
      PERFORM fill_c_fkkcollp_ip USING c_fkkcollp_ip.

** Zusätzliche Daten zur Zahlung
*      CLEAR: ls_dfkkzp, ls_dfkkop.
*      SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
*        WHERE opbel = c_fkkcollp_ip-opbel
*        AND   inkps = c_fkkcollp_ip-inkps
*        and   augbl ne ' '.
*
*      IF sy-subrc = 0.

** Zusätzliche Daten zur Zahlung
** Ausgleichsbeleg holen aus DFKKCOLLH
      SELECT SINGLE * FROM dfkkcollh INTO ls_dfkkcollh
             WHERE opbel = c_fkkcollp_ip-opbel
             AND   inkps = c_fkkcollp_ip-inkps
             AND   lfdnr = i_lfdnr.

      IF sy-subrc = 0.

        SELECT SINGLE * FROM dfkkzp INTO ls_dfkkzp
          WHERE opbel = ls_dfkkcollh-augbl.

        CHECK sy-subrc = 0.

        MOVE ls_dfkkzp-opbel TO c_fkkcollp_ip-zzopbel.
        MOVE ls_dfkkzp-valut TO c_fkkcollp_ip-zzvaluta.
        MOVE ls_dfkkzp-betrz TO c_fkkcollp_ip-zzbetrz.
        MOVE ls_dfkkzp-koinh TO c_fkkcollp_ip-zzkoinhzahlung.
        MOVE ls_dfkkzp-iban  TO c_fkkcollp_ip-zzibanzahlung.
        MOVE ls_dfkkzp-txtvw TO c_fkkcollp_ip-zztxtvw.

*       Prüfung, ob ZE vom Inkassobüro
        PERFORM check_paym_ink
                USING c_fkkcollp_ip
                      i_lfdnr
                      ls_dfkkzp-opbel.
      ELSE.
        c_fkkcollp_ip-zzopbel = ls_dfkkcollh-augbl.
      ENDIF.


    WHEN '2' .  "Rückruf
*      recall: use structure c_fkkcollp_ir
      PERFORM fill_c_fkkcollp_ir USING c_fkkcollp_ir i_lfdnr.

    WHEN '7'.     "Storno abgegebene Forderung
*     Payment: use structure C_FKKCOLLP_IP
      PERFORM fill_c_fkkcollp_ip USING c_fkkcollp_ip.


**    Position aus dfkkop
      SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
             WHERE opbel = c_fkkcollp_ip-opbel
             AND   inkps = c_fkkcollp_ip-inkps.

      IF sy-subrc = 0.

*       Nur wenn SR
        CHECK ls_dfkkop-hvorg IN gr_hvorg.

*       Mahnsperre auf VK löschen
        PERFORM del_mahnsperre
                USING c_fkkcollp_ip-gpart
                      c_fkkcollp_ip-vkont.

        PERFORM create_intverm
                USING c_fkkcollp_ip-gpart
                      c_fkkcollp_ip-vkont.
      ENDIF.

    WHEN 'A'     "Ablehnung Verkauf
      OR 'V'.    "Verkauf

*      recall: use structure c_fkkcollp_ir
      PERFORM fill_c_fkkcollp_ir USING c_fkkcollp_ir i_lfdnr.

*   when '3' .
*     Master data changes: use structure C_FKKCOLLP_IM

  ENDCASE .



ENDFUNCTION.
