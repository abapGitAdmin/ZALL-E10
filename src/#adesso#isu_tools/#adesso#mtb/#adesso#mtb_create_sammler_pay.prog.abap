*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTB_CREATE_SAMMLER_PAY
*&
*&---------------------------------------------------------------------*
* Dieser Report liest die Sammler-Summensatztabelle und erstellt
* aus den Informationen eine Migrationsdatei für die Sammlerkonten

REPORT /adesso/mtb_create_sammler_pay.

TABLES: dfkkop.
DATA: isamm LIKE TABLE OF /adesso/mtb_samm WITH HEADER LINE,
      betrw(20) TYPE c.
* Datendeklaration für Entlade-FUBA PAYMENT
DATA: oldkey_pay(30) TYPE c. " /evuit/mt_transfer-oldkey.

DATA: ipay_out  LIKE TABLE OF /adesso/mt_transfer,
      wpay_out  LIKE /adesso/mt_transfer.
* interne Tabellen für PAYMENT
DATA: ipay_fkkko  TYPE /adesso/mt_emig_pay_fkkko
                                        OCCURS 0 WITH HEADER LINE.
DATA: ipay_fkkopk TYPE /adesso/mt_fkkopk OCCURS 0 WITH HEADER LINE.
DATA: ipay_seltns TYPE /adesso/mt_emig_pay_seltns
                                        OCCURS 0 WITH HEADER LINE.
DATA:  object          TYPE  emg_object VALUE 'PAYMENT'.

PARAMETERS: pfile LIKE filename-fileextern OBLIGATORY
                  DEFAULT '/Mig/SWL_BI/Migration/Ent/PAYSAM.EXP'.
PARAMETERS: firma           TYPE  emg_firma DEFAULT 'SWL'.

START-OF-SELECTION.

  SELECT * FROM /adesso/mtb_samm INTO TABLE isamm.
*           where firma = firma.

  IF NOT isamm[] IS INITIAL.
    OPEN DATASET pfile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  ELSE.
    WRITE: / 'Keine zu buchenden Belege gefunden'.
    STOP.
  ENDIF.
  LOOP AT isamm.
    PERFORM init_pay.


    CONCATENATE isamm-vkont isamm-faedn INTO oldkey_pay.
    ipay_fkkko-applk = 'R'.
    ipay_fkkko-augrd = '01'. "Einzahlung
*    ipay_fkkko-blart = 'ZM'. "Zahlung Migration
     ipay_fkkko-blart = 'XZ'. "Zahlung Migration
*     ipay_fkkko-bldat = sy-datum. "Änderung am 19.06.08 x_bruenken.y

*    ipay_fkkko-budat = sy-datum.
    ipay_fkkko-herkf = 'RZ'. "IS-U Migr. Zahlungen
*    ipay_fkkko-oibel = space. "??? (  )
      SELECT SINGLE * FROM dfkkop
            WHERE opupk = '0001' AND
                  bukrs = '0520' AND
                  vkont = isamm-vkont AND
                  hvorg = '0075' AND
                  tvorg = '0013' AND
                  faedn = isamm-faedn AND
                  blart = 'SA'.
     IF sy-subrc = 0.
     ipay_fkkko-oibel = dfkkop-opbel.
     ipay_fkkko-bldat = dfkkop-bldat. "Änderung am 19.06.08 x_bruenken.y

     ENDIF.
    ipay_fkkko-waers = 'EUR'.
    APPEND ipay_fkkko.
    CLEAR  ipay_fkkko.

    ipay_fkkopk-bukrs = '1000'.
*    ipay_fkkopk-opupk = '1000'.
     ipay_fkkopk-opupk = '0001'.
*    ipay_fkkopk-valut = sy-datum.
    ipay_fkkopk-betrw = isamm-betrw.
    APPEND ipay_fkkopk.
    CLEAR ipay_fkkopk.
    CLEAR ipay_seltns.
    ipay_seltns-augrd = '01'.
    ipay_seltns-betrw = isamm-betrw.
    ipay_seltns-fiedn = isamm-faedn.
    SELECT SINGLE gpart FROM fkkvkp INTO ipay_seltns-giart
           WHERE vkont = isamm-vkont.
*    ipay_seltns-oibel = space. "wa_eabps-opbel.
     ipay_seltns-oibel = dfkkop-opbel.
    ipay_seltns-viont = isamm-vkont.
    ipay_seltns-waers = isamm-waers.
    APPEND ipay_seltns.
    CLEAR  ipay_seltns.

    WRITE : / 'SVK', isamm-vkont, 'Fällig', isamm-faedn, 'Betrag',
               isamm-betrw CURRENCY isamm-waers, isamm-waers.
* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_pay_out USING oldkey_pay
                              firma
                               object.
  ENDLOOP.
  LOOP AT ipay_out INTO wpay_out.
    TRANSFER wpay_out TO pfile.
  ENDLOOP.
  CLOSE DATASET pfile.
*&---------------------------------------------------------------------*
*&      Form  init_pay
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_pay.

  CLEAR: ipay_fkkko, ipay_fkkopk, ipay_seltns.

  REFRESH: ipay_fkkko, ipay_fkkopk, ipay_seltns.

ENDFORM.                    " init_pay
*---------------------------------------------------------------------*
*       FORM fill_pay_out                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  COLDKEY                                                       *
*  -->  CFIRMA                                                        *
*  -->  COBJECT                                                       *
*---------------------------------------------------------------------*
FORM fill_pay_out USING   coldkey
                           cfirma
                           cobject.

  LOOP AT ipay_fkkko.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKKO'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkko.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_fkkopk.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'FKKOPK'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_fkkopk.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.

  LOOP AT ipay_seltns.
    wpay_out-firma  = cfirma.
    wpay_out-object = cobject.
    wpay_out-dttyp  = 'SELTNS'.
    wpay_out-oldkey = coldkey.
    wpay_out-data   = ipay_seltns.
    APPEND wpay_out TO ipay_out.
  ENDLOOP.


* initialisieren der Tabellen je Altsystemschlüssel
  PERFORM init_pay.


ENDFORM.                    " fill_pay_out
