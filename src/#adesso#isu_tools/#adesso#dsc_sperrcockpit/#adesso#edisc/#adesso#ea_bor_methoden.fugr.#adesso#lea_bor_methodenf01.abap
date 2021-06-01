*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LEA_BOR_METHODENF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTACT
*&---------------------------------------------------------------------*
FORM CREATE_CONTACT USING X_PARTNER TYPE BUT000-PARTNER
                          X_CCLASS TYPE BCONT-CCLASS
                          X_ACTIVITY TYPE BCONT-ACTIVITY.
  TYPE-POOLS: BPC01.
  DATA: H_BCONT TYPE BCONT.
  DATA: H_AUTO    TYPE  BPC01_BCONTACT_AUTO.
  DATA: H_BPC_OBJ TYPE BPC_OBJ.
  DATA: H_PRGCONTEXT LIKE  BCONTCFIND-PRGCONTEXT.
  H_PRGCONTEXT = SY-REPID.
* Kopfdaten des Kontakts
  MOVE X_PARTNER        TO H_AUTO-BCONTD-PARTNER.
  MOVE X_CCLASS         TO H_AUTO-BCONTD-CCLASS.
  MOVE X_ACTIVITY       TO H_AUTO-BCONTD-ACTIVITY.

** Kontaktart
*  IF sy-mandt EQ gc_vertriebsmandant_swk OR sy-mandt EQ gc_netzmandant_swk.
*    MOVE '006'          TO h_auto-bcontd-ctype.
*  ENDIF.
*  move x_f_com          to h_auto-bcontd-f_coming.
*  move x_addin          to h_auto-bcontd-addinfo.
*  move x_prior          to h_auto-bcontd-priority.
*  move x_custi          to h_auto-bcontd-custinfo.
*  move x_wvdat          to h_auto-bcontd-zzecswvdatum.
* Objektbezug
*  if     h_feldname = 'VKONTO'.
** Vertragskonto als Objektbezug
*    h_bpc_obj-objrole = 'ZKONTO'.
*    h_bpc_obj-objtype = 'ISUACCOUNT'.
*    h_bpc_obj-objkey  = zealvkeys-vkonto.
*    append h_bpc_obj to h_auto-iobjects.
*  elseif h_feldname = 'VERTRAG'.
** Vertrag als Objektbezug
*    h_bpc_obj-objrole = 'ZVERTRAG'.
*    h_bpc_obj-objtype = 'ISUCONTRCT'.
*    h_bpc_obj-objkey  = zealvkeys-vertrag.
*    append h_bpc_obj to h_auto-iobjects.
*  endif.
* Auto-Daten verwenden
  H_AUTO-BCONTD_USE = 'X'.
* Kontakt erzeugen
  CALL FUNCTION 'BCONTACT_CREATE'
    EXPORTING
      X_UPD_ONLINE   = 'X'
      X_NO_DIALOG    = 'X'
      X_AUTO         = H_AUTO
      X_PRGCONTEXT   = H_PRGCONTEXT
      X_PARTNER      = X_PARTNER
*    importing
*     y_new_bpcontact       = i_bpcontact
*     Y_EXIT_TYPE    =
*     y_new_bcont    = h_bcont
*     Y_CURFIELD     =
* TABLES
*     Y_NEW_BCONTO   =
    EXCEPTIONS
      EXISTING       = 1
      FOREIGN_LOCK   = 2
      NUMBER_ERROR   = 3
      GENERAL_FAULT  = 4
      INPUT_ERROR    = 5
      NOT_AUTHORIZED = 6
      OTHERS         = 7.
  IF SY-SUBRC <> 0.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GEBUEHR_BUCHEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_OKCODE  text
*      -->P_X_BETRW  text
*      -->P_X_BUKRS  text
*      -->P_I_SPERR_GPART  text
*      -->P_I_SPERR_VKONT  text
*      -->P_I_SPERR_VERTRAG  text
*      -->P_X_HVORG  text
*      -->P_X_TVORG  text
*      <--P_Y_OPBEL  text
*      <--P_X_COMMIT  text
*----------------------------------------------------------------------*
FORM GEBUEHR_BUCHEN  USING X_OKCODE  TYPE REGEN-OKCODE
                           X_BETRW   TYPE DFKKOP-BETRW
                           X_BUKRS   TYPE DFKKOP-BUKRS
                           X_PARTNER TYPE BU_PARTNER
                           X_VKONTO  TYPE VKONT_KK
                           X_VERTRAG TYPE  VERTRAG
                           X_HVORG   TYPE HVORG_KK
                           X_TVORG   TYPE TVORG_KK
                      CHANGING Y_OPBEL
                               X_COMMIT.
  DATA: I_PRODUCT_ID TYPE INV_PRODUCT_ID,
        I_BEMERKUNG  TYPE EFKKOP-OPTXT,
        I_XNETT      TYPE BOOLE-BOOLE.
  DATA: AMOUNT TYPE FKKCHG-BETRW.

  DATA LF_TFK047I TYPE TFK047I.
  DATA LT_FKKCHG  TYPE TABLE OF FKKCHG .
  DATA LF_FKKCHG  TYPE FKKCHG .

  CASE X_OKCODE.
    WHEN 'DARKDCED'.
      I_BEMERKUNG = 'Sperrgebühr'.
      I_XNETT     = 'X'.
      MOVE  'SP' TO LF_TFK047I-CHGID.
    WHEN 'DARKRCED'.
      I_BEMERKUNG = 'Wiederinebtriebnahmegebühr'.
      CLEAR I_XNETT.
      MOVE  'WG' TO LF_TFK047I-CHGID.
    WHEN OTHERS.
* keine Gebührbuchung
      EXIT.
  ENDCASE.

* Gebühr buchen
  DATA: I_EFKKOP LIKE EFKKOP.
* Steuerungsparameter mitgeben
  I_EFKKOP-BLDAT   = SY-DATUM.
  I_EFKKOP-BUDAT   = SY-DATUM.

* Solingen
  IF SY-MANDT EQ GC_VERTRIEBSMANDANT OR
     SY-MANDT EQ GC_VERTRIEBSMANDANT2 OR
     SY-MANDT EQ GC_VERTRIEBSMANDANT3.

    I_EFKKOP-BLART   = 'RK'.
    I_EFKKOP-BETRW   = X_BETRW.
  ENDIF.
* Kiel: VKK Gebühren - Ermittlung aller Gebühren eines Schemas
*  IF sy-mandt EQ gc_vertriebsmandant_swk.
*    i_efkkop-blart   = 'SK'.
*
*    MOVE 'EUR' TO lf_tfk047i-waers.
*    CLEAR lf_tfk047i-mahng.
*    CLEAR lf_tfk047i-bonit.
*
*    CALL FUNCTION 'FKK_CALC_CHARGES'
*      EXPORTING
*        i_waers  = lf_tfk047i-waers
*        i_betrw  = lf_tfk047i-mahng
*        i_bonit  = lf_tfk047i-bonit
*        i_chgid  = lf_tfk047i-chgid
*      TABLES
*        t_fkkchg = lt_fkkchg.
*
*    READ TABLE lt_fkkchg  INTO lf_fkkchg INDEX 1.
*
*    MOVE lf_fkkchg-betrg TO amount.
*    i_efkkop-betrw   = amount.
*  ENDIF.

  I_EFKKOP-WAERS   = 'EUR'.
  I_EFKKOP-FIKEY   = 'AG&1&2'.
  I_EFKKOP-HERKF   = '01'.
  REPLACE '&1' WITH SY-DATUM INTO I_EFKKOP-FIKEY.
  REPLACE '&2' WITH SY-UNAME INTO I_EFKKOP-FIKEY.
  I_EFKKOP-BUKRS   = X_BUKRS.
  I_EFKKOP-GPART   = X_PARTNER.
  I_EFKKOP-VKONT   = X_VKONTO.
  I_EFKKOP-VERTRAG = X_VERTRAG.
*  i_efkkop-hvorg   = wa_edereg_sidproint-hvorg.
*  i_efkkop-tvorg   = wa_edereg_sidproint-tvorg.
  I_EFKKOP-HVORG   = X_HVORG.
  I_EFKKOP-TVORG   = X_TVORG.
*  i_efkkop-betrw   = x_betrw.
  I_EFKKOP-FAEDN   = SY-DATUM.
  I_EFKKOP-OPTXT   = I_BEMERKUNG.


  CALL FUNCTION 'ISU_CREATE_DOCUMENT'
    EXPORTING
      I_EFKKOP      = I_EFKKOP
*     I_FKKVKP      =
*     I_EVER        =
      I_COMMIT      = 'X'
      I_XNETT       = I_XNETT
*     i_update_task = 'X'
      I_UPDATE_TASK = ' '
    IMPORTING
      E_OPBEL       = Y_OPBEL
    EXCEPTIONS
      MISSING_FIELD = 1
      IU_ERROR      = 2
      OTHERS        = 3.
  IF SY-SUBRC = 0.
*    COMMIT WORK.
  ELSE.
*    'Fehler bei Gebührenbuchung'
    CLEAR X_COMMIT.
  ENDIF.
ENDFORM.                    " GEBUEHR_BUCHEN
*&---------------------------------------------------------------------*
*&      Form  BAUE_MSGDATA_COMMENT_EDISCDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_COMMENTTXT  text
*      <--P_LT_MSGDATACO  text
*----------------------------------------------------------------------*
FORM BAUE_MSGDATA_COMMENT_EDISCDOC
                           USING    PF_COMMENTTXT TYPE EIDESWTMSGDATACO-COMMENTTXT
                           CHANGING PT_MSGDATACO TYPE TEIDESWTMSGDATACO.

  DATA LF_MSGDATACO TYPE EIDESWTMSGDATACO.

  CLEAR LF_MSGDATACO-SWITCHNUM.
  CLEAR LF_MSGDATACO-MSGDATANUM.
  MOVE '001' TO LF_MSGDATACO-COMMENTNUM.
  MOVE '' TO LF_MSGDATACO-COMMENTTAG.
  MOVE PF_COMMENTTXT TO LF_MSGDATACO-COMMENTTXT.

  APPEND LF_MSGDATACO TO PT_MSGDATACO.
ENDFORM.                    " BAUE_MSGDATA_COMMENT_EDISCDOC
*&---------------------------------------------------------------------*
*&      Form  BAUE_MSGDATA_SPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_SPERRDAT  text
*      -->P_LD_WIB_DAT  text
*      -->P_X_INT_UI  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_X_TRANSREASON  text
*      -->P_X_CATEGORY  text
*      <--P_LF_EIDESWTMSGDATA  text
*      <--P_LD_RCODE  text
*----------------------------------------------------------------------*
FORM BAUE_MSGDATA_SPERRE  USING    PD_SPERRDATUM TYPE DATS
                                   PD_WIB_DATUM TYPE DATS
                                   PD_INT_UI TYPE INT_UI
                                   PF_EIDESWTDOC TYPE EIDESWTDOC
                                  PF_TRANSREASON TYPE EIDESWTMDTRAN
                                  PF_CATEGORY TYPE EIDESWTMDCAT
                          CHANGING PF_EIDESWTMSGDATA TYPE EIDESWTMSGDATA
                                   PD_RCODE TYPE SY-SUBRC.

  CHECK PD_RCODE LT 100.

* Nachrichtendaten aufbauen
  CALL FUNCTION '/ADESSO/LW_GET_MESSAGEDATA'
    EXPORTING
      I_SWITCHNUM   = SPACE
*     I_MSGDATA     =
      I_BEGINNZUM   = PD_SPERRDATUM
      I_ENDEZUM     = PD_WIB_DATUM
*     i_transreason = gc_transreason_sperrung
      I_TRANSREASON = PF_TRANSREASON
*     I_BKV         =
*     i_category    = gc_category_abmeld
      I_CATEGORY    = PF_CATEGORY
*     I_METMETHOD   =
      I_INT_UI      = PD_INT_UI
*     I_POSSEND     =
*     I_NETZANSCHLKAP        =
*     I_EMPF_SERVICEID       =
      I_EIDESWTDOC  = PF_EIDESWTDOC
    IMPORTING
      E_MSGDATA     = PF_EIDESWTMSGDATA
*     E_SERVICEID_OLD        =
*     E_ZWAUS_STORNO         =
    .

  MOVE GC_DIRECTION_IMPORT TO PF_EIDESWTMSGDATA-DIRECTION.



ENDFORM.                    " BAUE_MSGDATA_SPERRE



FORM HOLE_MSGDATA_LAREQE01Z28  USING PD_BEGINNZUM    TYPE EIDEMOVEINDATE
                                     PD_ENDEZUM      TYPE EIDEMOVEOUTDATE
                                     PD_SWITCHNUM    TYPE EIDESWTNUM
                                     PD_MSGDATANUM   TYPE EIDESWTMDNUM
                                     PF_EIDESWTDOC   TYPE EIDESWTDOC
                                     PD_POD          TYPE INT_UI
                                     PD_TRANSREASON  TYPE EIDESWTMDTRAN
                                     PD_ANSWERSTATUS TYPE EIDESWTMDSTATUS
                                     PD_NETZANSCHKAP TYPE /ADESSO/EIDESWTMDNETZKAP
                                     PD_CATEGORY     TYPE EIDESWTMDCAT
                                     PD_ANFRAGE      TYPE KENNZX
                                     PD_SWTVIEW      TYPE EIDESWTVIEW
                            CHANGING PF_MSGDATA      TYPE EIDESWTMSGDATA
                                     PD_COMMENTTXT     TYPE EIDESWTMDCOMMENT.


  DATA LF_ANLAGE TYPE V_EANL.
  DATA LD_KEYDATUM TYPE SY-DATUM.
  DATA LD_METMETHOD TYPE EIDESWTMDMETMETHOD.


* (24a - MUSS) Einzugsdatum (Beginn zum - Lieferbeginn) wird gefüllt
* (24c - KEIN) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* Muss vor hole_keydatum durchgeführt werden.
  PERFORM MOVEIN_MOVEOUT_DATE USING PD_BEGINNZUM
                                    SY-DATUM            "wird eh nicht gebraucht
                                    PD_CATEGORY
                           CHANGING PF_MSGDATA.


* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM HOLE_KEYDATUM USING  PF_MSGDATA
                     CHANGING  LD_KEYDATUM.


* (5b - KANN) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM HOLE_EXT_UI  USING PF_EIDESWTDOC
                             LD_KEYDATUM
                    CHANGING PF_MSGDATA.

* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM HOLE_ANLAGE USING PD_POD
                            LD_KEYDATUM
                   CHANGING LF_ANLAGE.


* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)


* (V2 - KEIN) Referenz zu einem Vorgang (Nur bei Antwortnachricht)


* (4a - MUSS) Adresse Lieferstelle (Lieferadresse)
* Hü: 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM HOLE_VS USING PF_EIDESWTDOC
                        LD_KEYDATUM
                        LF_ANLAGE
               CHANGING PF_MSGDATA.


* (1a - MUSS) Name des Anschlussnutzers + (1b - KANN) Anschrift des Kunden (Nur genutzt, wenn Kunde nicht an Lieferstelle wohnt)
* GP (Geschäftspartner)
  PERFORM HOLE_GP USING PD_POD
                        LD_KEYDATUM
                        PD_CATEGORY
                        PD_TRANSREASON
                        PD_ANSWERSTATUS
                        PF_EIDESWTDOC-PARTNER
                        SPACE
               CHANGING PF_MSGDATA.


** (2a - KANN) Kundennummer des Kunden beim Lieferanten
** 07.08.2008 Hü: Explizit von Kiel gewünscht, dass die Vertragskontonummer an den Netzbetreiber übermittelt wird.
*  PERFORM hole_vkonto_lief USING pf_eideswtdoc
*                                 ld_keydatum
*                                 lf_anlage
*                                 pf_eideswtdoc-partner
*                        CHANGING pf_msgdata.

* (2b - KANN) Kundennummer des Kunden bei dem Verteilnetzbetreiber
* Für gewöhnlich weiß nur der Verteilnetzbetreiber die eigene Kundenummer


* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - KANN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - KANN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus

* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - KANN) Zählpunkt als Aggregationspunkt


* (7 - KANN (außer bei Pauschalanlagen)) Zählernummer (Zählernummer / Eigentumsnummer)
  PERFORM HOLE_ZAEHLER USING LF_ANLAGE
                             LD_KEYDATUM
                    CHANGING PF_MSGDATA.


* (8a - KANN) Bisheriger Lieferant: VDEW-Code-Nummer


* (8b - KANN) Kundennummer beim bisherigen Lieferanten


* (9 - KANN) Sonstige Hinweise zur Identifizierung


* (10 - KEIN) Antwortkategorien


* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt


* (12 - MUSS) Art der Versorgung
*  PERFORM hole_versart USING pf_eideswtdoc
*                             ld_keydatum
*                             pd_pod
*                    CHANGING pf_msgdata.


* (13 - KANN) Regelzone
*  PERFORM hole_regelzone USING pf_eideswtdoc
*                               ld_keydatum
*                               lf_anlage-sparte
*                      CHANGING pf_msgdata.


** (14a - MUSS) Bilanzkreisbezeichnung (EICode Bilanzkreis) (= Bilanzkreisverantwortlicher in den Nachrichtendaten = 11Xer-Nummer)
*** Bilanzkreisverantwortlicher bei Zwangsabmeldungen
**    IF ( ld_anfrage EQ gc_true OR ld_anfrage EQ lc_msgstat001 ).
*  PERFORM hole_bilanzkreisverantw USING pf_eideswtdoc
*                                        pd_transreason
*                                        pd_category
*                                        pd_anfrage
*                                        pd_swtview
*                              CHANGING  pf_msgdata.
**    PERFORM hole_bilanzkreis USING lf_eideswtdoc
**                                   ld_keydatum
**                          CHANGING lf_msgdata.


* (14b - KANN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - KANN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB


* (14d - KEIN) Bilanzierungsgebiet


** (15 - MUSS (wenn Haushaltskunde)) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt,
** handelt es sich um einen Haushaltskunden, sonst nicht.
*  PERFORM hole_ist_haushaltskunde USING    pf_eideswtdoc
*                                           ld_keydatum
*                                           lf_anlage
*                                 CHANGING pf_msgdata.


* (16 - MUSS) Zählverfahren, wird aus dem IS-U bestimmt
  PERFORM HOLE_METMETHOD USING PD_POD
                               LD_KEYDATUM
                      CHANGING PF_MSGDATA-METMETHOD.

*  PERFORM hole_metmethod_msgdata USING pf_eideswtdoc
*                                       ld_keydatum
*                                       pf_msgdata-metmethod
*                              CHANGING pf_msgdata
*                                       ld_metmethod.


* (17a - KEIN) Start Abrechnungsjahr (nur bei RLM)
* (17b - KEIN) Bisher gemessene Maximalleistung (nur bei RLM)


* (17c - KANN) Reservenetzkapazität (bestellt)


* (17d - KANN) Netzanschlusskapazität (nur bei RLM)
*  IF NOT pd_netzanschkap IS INITIAL.
*    MOVE pd_netzanschkap TO pf_msgdata-zz_netzanschkap.
*  ENDIF.


* (18a - KANN (nur bei SLP/ ALP Kunde))
* Standardlastprofilzuordnung oder (Tarif-/Kunden-) Gruppenzuordnung bei analytischen Verfahren oder sonstige Zuordnung
*  PERFORM hole_slp USING lf_anlage
*                         ld_keydatum
*                         ld_metmethod
*                         pd_pod
*                CHANGING pf_msgdata.


** (18b - Kann bei SLP/ALP) Jahresverbrauch
** hole_jvb_pau , hole_jvb Jahresverbrauch
*  IF ld_metmethod EQ gc_metmethod_pau.
*    PERFORM hole_jvb_pau
*                USING
*                   lf_anlage
*                   ld_keydatum
*                CHANGING
*                   pf_msgdata.
*  ELSE.
*    PERFORM hole_jvb
*                USING
*                   lf_anlage
*                   ld_keydatum
*                   pd_pod
*                   space
*                CHANGING
*                   pf_msgdata.
*  ENDIF.


* (19a - KEIN) Profilschar


** (19b - KANN) Spezifische Arbeit
** =  spezifischer Verbrauch (kWh/K) HT / NT
*  PERFORM hole_spez_verbr  USING pf_eideswtdoc
*                                 ld_keydatum
*                        CHANGING pf_msgdata.


* (19c - KEIN) Temperaturmessstelle
* (19d - KEIN) Verbrauchsaufteilung
* (19e - KEIN) Steuerungsart
* (19f - KEIN) Anlagetyp
* (19g - KEIN) Installierte Leistung


* (20 - KANN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird


* (21a/b - KANN) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
*  PERFORM hole_next_abl USING pf_eideswtdoc
*                              ld_keydatum
*                              lf_anlage
*                              ld_metmethod
*                     CHANGING pf_msgdata.


* (22 - KANN) Art der Messwerte (OBIS-Kennzahlen)
*  PERFORM hole_obis_kennzahl USING pf_eideswtdoc
*                                   ld_keydatum
*                                   lf_anlage
*                          CHANGING pf_msgdata.


* (23a - KEIN) Spannungsebene der Anschlussstelle der Lieferstelle
* (23b - KEIN) Messung findet statt in
* (23c - KEIN) Verlustfaktor in Prozent


* (24a - MUSS) SIEHE OBEN
* (24b - KEIN) Änderung zum (Start der Änderung)
* (24c - KEIN) SIEHE OBEN
* (24d - KEIN) Ende zum (nächstmöglichen Termin)
* (24e - KEIN) Bilanzierungsbeginn
* (24f - KEIN) Bilanzierungsende


** (25a - MUSS) Status
*  PERFORM hole_zz_statusnenu CHANGING pf_msgdata.
** (25b - Kann) Abweichender Rechnungsempfänger
** Hier übergeben wir den abweichenden Rechnungsempfänger
*  PERFORM hole_abw_rechnempf USING  pf_eideswtdoc
*                                    ld_keydatum
*                                    pd_category
*                           CHANGING pf_msgdata.
*
** (25c - MUSS) Zahler der Netznutzung
*  PERFORM hole_zz_zahler CHANGING pf_msgdata.
*
*
** (25d - KEIN) Rechnungsadresse
*
*
** (26a - KANN) Konzessionsabgabe (vorläufige Annahme)
** (Konzessionsabgabe S/AA/E)
*  PERFORM hole_konzabgabe  USING lf_anlage
*                         CHANGING pf_msgdata.


* (26b - KEIN) Betrag (KA)


* (27 - KANN (MUSS bei E07,E14, Z07 in SG4-STS)) Bemerkungen (Vorgangsbezogen)
  PERFORM HOLE_COMMENT USING PD_MSGDATANUM
                             PD_SWITCHNUM
                    CHANGING PD_COMMENTTXT.



* ENDE 'WIB-Auftrag' (E01)
*--------------------------------------------------------------------------------------------------*

ENDFORM.                    " HOLE_MSGDATA_LAREQE01Z28
*&---------------------------------------------------------------------*
*&      Form  HOLE_ANLAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_POD  text
*      -->P_LD_KEYDATUM  text
*      <--P_LF_ANLAGE  text
*----------------------------------------------------------------------*
FORM hole_anlage USING    pd_int_ui TYPE int_ui
                          pd_keydatum TYPE sy-datum
                 CHANGING pf_anlage TYPE v_eanl.

  DATA ld_anlage TYPE anlage.
  DATA lf_eanl TYPE v_eanl.

  PERFORM hole_anlage_int_ui  USING  pd_keydatum
                                     pd_int_ui
                           CHANGING  ld_anlage.

  CALL FUNCTION 'ISU_DB_EANL_SELECT'
    EXPORTING
      x_anlage     = ld_anlage
      x_keydate    = pd_keydatum
      x_actual     = gc_true
    IMPORTING
      y_v_eanl     = lf_eanl
    EXCEPTIONS
      not_found    = 1
      system_error = 2
      invalid_date = 3
      OTHERS       = 4.
  IF sy-subrc <> 0.
    CLEAR lf_eanl.
  ENDIF.

  MOVE lf_eanl TO pf_anlage.

ENDFORM.                    " hole_netzanlage
*&---------------------------------------------------------------------*
*&      Form  HOLE_ANLAGE_INT_UI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_KEYDATUM  text
*      -->P_PD_INT_UI  text
*      <--P_LD_ANLAGE  text
*----------------------------------------------------------------------*
FORM hole_anlage_int_ui  USING    pd_keydatum LIKE sy-datum
                                  pd_int_ui TYPE int_ui
                         CHANGING pd_anlage TYPE anlage.


  DATA: lf_euiinstln TYPE euiinstln,
        lt_euiinstln TYPE ieuiinstln,
        lf_eanl      TYPE eanl.

  CLEAR pd_anlage.

  CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
    EXPORTING
      x_int_ui      = pd_int_ui
      x_dateto      = pd_keydatum
*     X_TIMETO      = '235959'
      x_datefrom    = pd_keydatum
*     X_TIMEFROM    = '000000'
      x_only_dereg  = 'X'
*     X_ONLY_TECH   = ' '
    IMPORTING
      y_euiinstln   = lt_euiinstln
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT lt_euiinstln INTO lf_euiinstln .
    SELECT SINGLE * FROM eanl INTO lf_eanl WHERE anlage = lf_euiinstln-anlage.
    IF NOT lf_eanl-service IS INITIAL.
      EXIT.
    ENDIF.
  ENDLOOP.

  MOVE lf_euiinstln-anlage TO pd_anlage.



ENDFORM.                    " HOLE_ANLAGE_INT_UI
*&---------------------------------------------------------------------*
*&      Form  HOLE_COMMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_MSGDATANUM  text
*      -->P_PD_SWITCHNUM  text
*      <--P_PD_COMMENTTXT  text
*----------------------------------------------------------------------*
FORM hole_comment  USING    pd_msgdatanum TYPE eideswtmdnum
                            pd_switchnum  TYPE eideswtnum
                   CHANGING pd_commenttxt TYPE eideswtmdcomment.

*  DATA lt_eideswtmsgdataco TYPE TABLE OF eideswtmsgdataco.
  DATA lf_eideswtmsgdataco TYPE eideswtmsgdataco.
*  DATA lt_commenttxt TYPE TABLE OF zlw_commenttxt.
*  DATA lf_commenttxt TYPE zlw_commenttxt.

* Kommentare zur Vorlage holen
  SELECT * FROM eideswtmsgdataco INTO lf_eideswtmsgdataco UP TO 1 ROWS
   WHERE switchnum = pd_switchnum
     AND msgdatanum = pd_msgdatanum.
  ENDSELECT.

  IF sy-subrc = 0.
    pd_commenttxt = lf_eideswtmsgdataco-commenttxt.
  ENDIF.

ENDFORM.                    " HOLE_COMMENT
*&---------------------------------------------------------------------*
*&      Form  HOLE_EXT_UI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PF_EIDESWTDOC  text
*      -->P_LD_KEYDATUM  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_ext_ui USING    pf_eideswtdoc TYPE eideswtdoc
                          pd_keydatum TYPE sy-datum
                 CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA lf_euitrans TYPE euitrans.
  DATA lt_euitrans TYPE TABLE OF euitrans.


  CALL FUNCTION 'ISU_DB_EUITRANS_SELECT'
    EXPORTING
      x_int_ui      = pf_eideswtdoc-pod
      x_dateto      = pd_keydatum
      x_datefrom    = pd_keydatum
    IMPORTING
      y_euitrans    = lt_euitrans
    EXCEPTIONS
      not_found     = 1
      not_qualified = 2
      system_error  = 3
      OTHERS        = 4.
  IF sy-subrc = 0.
    READ TABLE lt_euitrans INTO lf_euitrans INDEX 1.
    IF sy-subrc EQ 0.
      MOVE lf_euitrans-ext_ui TO pf_msgdata-ext_ui.
    ENDIF.
  ENDIF.

** Sonderbehandlung für den LN:
** temporäre ZP-Bez. dürfen nicht kommuniziert werden.
*  IF pf_eideswtdoc-swtview = gc_swtview_ln.
*    CALL FUNCTION 'Z_LW_CHECK_KOMM_EXT_UI'
*      EXPORTING
*        x_ext_ui = pf_msgdata-ext_ui
*      EXCEPTIONS
*        no_komm  = 1
*        OTHERS   = 2.
*    IF sy-subrc <> 0.
*      CLEAR pf_msgdata-ext_ui.
*    ENDIF.
*
*  ENDIF.


ENDFORM.                    " hole_Ext_ui
*&---------------------------------------------------------------------*
*&      Form  HOLE_GP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_POD  text
*      -->P_LD_KEYDATUM  text
*      -->P_PD_CATEGORY  text
*      -->P_PD_TRANSREASON  text
*      -->P_PD_ANSWERSTATUS  text
*      -->P_PF_EIDESWTDOC_PARTNER  text
*      -->P_SPACE  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_gp USING    pd_pod TYPE int_ui
                      pd_keydate TYPE sy-datum
                      pd_category TYPE eideswtmdcat
                      pd_transreason TYPE eideswtmdtran
                      pd_msgstatus TYPE eideswtmsgdata-msgstatus
                      pd_partner TYPE bu_partner
                      pd_zwangsauzstorno TYPE flag
             CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA lf_eadrdat TYPE eadrdat.
  DATA lf_bu_type TYPE bu_type.
  DATA lf_partner TYPE bu_partner.
  DATA ld_flag_zustimm TYPE kennzx.
  DATA ld_flag_ablehn TYPE kennzx.
  DATA ld_seconds TYPE i.
  DATA ld_stepseconds TYPE i VALUE '20'.
  DATA ld_maxseconds TYPE i VALUE '300'.
  DATA ld_anlage TYPE anlage.


  IF pd_zwangsauzstorno EQ gc_true.
* Es ist die Antwort auf eine Zwangsabmeldung, die durch
* Storno des Vertrags druchgeführt wurde.
    lf_partner = pd_partner.
  ELSEIF pd_msgstatus IS INITIAL.
* Es ist eine Anfrage (hier kommt eigentlich nur Zwangsabmeldung in
* Frage) Verwendet wird der zum keydate versorgte Partner
    CALL FUNCTION '/ADESSO/LW_GET_POD_PARTNER'
      EXPORTING
        i_int_ui  = pd_pod
        i_keydate = pd_keydate
      IMPORTING
        e_gpart   = lf_partner.

  ELSE.
* Die Partnernummer finden wir entweder im Wechselbeleg
* (bei Ablehnung) oder am Zählpunkt (bei Zustimmung).
    PERFORM check_status_zustimm
                USING
                   pd_msgstatus
                CHANGING
                   ld_flag_zustimm
                   ld_flag_ablehn.

    IF ld_flag_zustimm EQ gc_true.

* Partner zum ZP und Datum besorgen
* Da es sein kann, dass der Partner noch nicht am Zählpunkt
* zu finden ist, obwohl wir bereits das Versorgungsszenario
* aufgebaut haben werden wir hier eine Zeit warten wenn wir
* keinen Partner finden.
      DO.

        CALL FUNCTION '/ADESSO/LW_GET_POD_PARTNER'
          EXPORTING
            i_int_ui  = pd_pod
            i_keydate = pd_keydate
          IMPORTING
            e_gpart   = lf_partner.

        IF NOT lf_partner IS INITIAL.
          EXIT.
        ENDIF.
* Wartezyklus abwarten
        WAIT UP TO ld_stepseconds SECONDS.

* Gesamtwartezeit checken
        ADD ld_stepseconds TO ld_seconds.
        IF ld_seconds GT ld_maxseconds.
          EXIT.
        ENDIF.
      ENDDO.

    ELSEIF ld_flag_ablehn EQ gc_true.
      lf_partner = pd_partner.
    ENDIF.
  ENDIF.

  CHECK NOT lf_partner IS INITIAL.

* Es kann nicht der GP aus dem Wechselbeleg genutzt werden,
* sondern wir brauchen den GP am Zählpunkt zum Keydatum.

  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_partner                  = lf_partner
      x_actual                   = 'X'
    IMPORTING
*     Y_ADDR_LINES               =
*     Y_LINE_COUNT               =
      y_eadrdat                  = lf_eadrdat
*     Y_ADRC_REGIO               =
*     Y_ADDR_DATA                =
*     Y_CUST_REGIO               =
*     Y_EHAU                     =
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  SELECT SINGLE type FROM but000 INTO lf_bu_type
   WHERE partner = lf_partner.

*Unterscheidung nach Organisation / Person
  IF lf_bu_type = gc_gp_type_org.
    MOVE lf_eadrdat-name1 TO pf_msgdata-name_l.
    MOVE lf_eadrdat-name2 TO pf_msgdata-name_f.
*    MOVE lf_eadrdat-name3 TO pf_msgdata-zz_name_f2.
*    MOVE lf_eadrdat-name4 TO pf_msgdata-zz_name_l2.
  ELSEIF lf_bu_type = gc_gp_type_person.
    MOVE lf_eadrdat-name1 TO pf_msgdata-name_l.
    MOVE lf_eadrdat-name2 TO pf_msgdata-name_f.
*    MOVE lf_eadrdat-name3 TO pf_msgdata-zz_name_f2.
*    MOVE lf_eadrdat-name4 TO pf_msgdata-zz_name_l2.
  ELSEIF lf_bu_type =  gc_gp_type_group .
    MOVE lf_eadrdat-name1 TO pf_msgdata-name_l.
    MOVE lf_eadrdat-name2 TO pf_msgdata-name_f.
*    MOVE lf_eadrdat-name3 TO pf_msgdata-zz_name_f2.
*    MOVE lf_eadrdat-name4 TO pf_msgdata-zz_name_l2.
  ENDIF.

  IF pd_category NE gc_category_kuend
  AND pd_transreason NE gc_transreason_storno.




*Berücksichtigt wurde bislang nur die Straßenadresse (nicht die Postfachadresse)
*Wenn Straße leer + Postfach gefüllt-> Verwendung der Postfachadresse
    IF lf_eadrdat-street IS INITIAL
    AND NOT lf_eadrdat-po_box IS INITIAL.

*Postfach + Postfachnummer
*      pf_msgdata-street_bu     = 'Postfach'.
*      pf_msgdata-zz_street2_bu = lf_eadrdat-po_box.


*Postleitzahl (POST_CODE2) des Postfachs), falls gefüllt (ansonsten die normale Postleitzahl (POST_CODE1))
      IF NOT lf_eadrdat-post_code2 IS INITIAL.
        pf_msgdata-postcode_bu = lf_eadrdat-post_code2.
      ELSE.
        pf_msgdata-postcode_bu = lf_eadrdat-post_code1.
      ENDIF.

*Ort (PO_BOX_LOC) des Postfachs, falls gefüllt (ansonsten der normale Ort (CITY1))
      IF NOT lf_eadrdat-po_box_loc IS INITIAL.
        pf_msgdata-city_bu = lf_eadrdat-po_box_loc.
      ELSE.
        pf_msgdata-city_bu = lf_eadrdat-city1.
      ENDIF.

*Region des Postfachs, falls gefüllt (ansonsten die normale Region)
*WIRD NICHT BERÜCKSICHTIGT:

*Land (PO_BOX_CTY) des Postfachs, falls gefüllt (ansonsten das normale Land (COUNTRY))
*      IF NOT lf_eadrdat-po_box_cty IS INITIAL.
*        pf_msgdata-zz_country_bu = lf_eadrdat-po_box_cty.
*      ELSE.
*        pf_msgdata-zz_country_bu = lf_eadrdat-country.
*      ENDIF.

*Löschen der unnötigen Felder
      CLEAR: pf_msgdata-housenr_bu,
             pf_msgdata-housenrext_bu.

    ENDIF.
  ELSE.
* Berücksichtigt wurde bislang nur die Straßenadresse (nicht die Postfachadresse)






* Adresse BU, nur wenn abweichend von Lieferstelle
    IF lf_eadrdat-street NE pf_msgdata-street
    OR lf_eadrdat-house_num1 NE pf_msgdata-housenr
    OR lf_eadrdat-house_num2 NE pf_msgdata-housenrext
    OR lf_eadrdat-city1 NE pf_msgdata-city
    OR lf_eadrdat-post_code1 NE pf_msgdata-postcode.
** PhL 2016-04-06
*    OR lf_eadrdat-country NE pf_msgdata-zz_land.
*/ PhL 2016-04-06
*    OR lf_eadrdat-str_suppl1 NE pf_msgdata-zz_street2_bu.


      MOVE lf_eadrdat-street TO pf_msgdata-street_bu.
      MOVE lf_eadrdat-house_num1 TO pf_msgdata-housenr_bu.
      MOVE lf_eadrdat-house_num2 TO pf_msgdata-housenrext_bu.
      MOVE lf_eadrdat-city1 TO pf_msgdata-city_bu.
      MOVE lf_eadrdat-post_code1 TO pf_msgdata-postcode_bu.
** PhL 2016-04-06
*      MOVE lf_eadrdat-country TO pf_msgdata-zz_land_bu.
*/ PhL 2016-04-06
*      MOVE lf_eadrdat-str_suppl1 TO pf_msgdata-zz_street2_bu.

    ELSE.
      CLEAR: pf_msgdata-street_bu,
             pf_msgdata-housenr_bu,
             pf_msgdata-housenrext_bu,
             pf_msgdata-city_bu,
             pf_msgdata-postcode_bu.
** PhL 2016-04-06
*             pf_msgdata-zz_land_bu.
*/ PhL 2016-04-06
*             pf_msgdata-zz_street2_bu.
    ENDIF.
  ENDIF.


* Bei einer Nachricht der Kategorie E35
*    oder einer Nachricht mit dem Transaktionsgrund E05 (Stornierung)
*    ist die Anschrift des Kunden (Feld 1b) leer
  IF pd_category EQ gc_category_kuend
  OR pd_transreason EQ gc_transreason_storno.

    CLEAR: pf_msgdata-street_bu,
           pf_msgdata-housenr_bu,
           pf_msgdata-housenrext_bu,
           pf_msgdata-city_bu,
           pf_msgdata-postcode_bu.
** PhL 2016-04-06
*             pf_msgdata-zz_land_bu.
*/ PhL 2016-04-06
*           pf_msgdata-zz_street2_bu.

  ENDIF.
ENDFORM.                    " hole_GP

FORM hole_ersten_vertrag USING    pd_int_ui TYPE int_ui
                                  pd_keydate TYPE d
                         CHANGING pf_ever TYPE ever.

  DATA: lf_euiinstln TYPE euiinstln,
        lt_euiinstln TYPE ieuiinstln,
        lt_ever      TYPE ieever,
        lf_ever      TYPE ever.


  CLEAR pf_ever.

  CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
    EXPORTING
      x_int_ui      = pd_int_ui
      x_dateto      = pd_keydate
*     X_TIMETO      = '235959'
      x_datefrom    = pd_keydate
*     X_TIMEFROM    = '000000'
      x_only_dereg  = 'X'
*     X_ONLY_TECH   = ' '
    IMPORTING
      y_euiinstln   = lt_euiinstln
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT lt_euiinstln INTO lf_euiinstln.
    lf_ever-anlage  = lf_euiinstln-anlage.
    lf_ever-einzdat = pd_keydate.
    lf_ever-auszdat = pd_keydate.
    APPEND lf_ever TO lt_ever.
  ENDLOOP.

  CALL FUNCTION 'ISU_DB_EVER_SELECT_ANLAGE'
    EXPORTING
      x_actual         = gc_true
*   IMPORTING
*     Y_COUNT          =
    TABLES
      txy_ever         = lt_ever
    EXCEPTIONS
      not_found        = 1
      system_error     = 2
      interval_invalid = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  READ TABLE lt_ever INTO pf_ever INDEX 1.


ENDFORM.                    " hole_ersten_vertrag
*&---------------------------------------------------------------------*
*&      Form  CHECK_STATUS_ZUSTIMM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_MSGSTATUS  text
*      <--P_LD_FLAG_ZUSTIMM  text
*      <--P_LD_FLAG_ABLEHN  text
*----------------------------------------------------------------------*
FORM check_status_zustimm
    USING    pd_msgstatus TYPE eideswtmsgdata-msgstatus
    CHANGING pd_flag_zustimm TYPE kennzx
             pd_flag_ablehn TYPE kennzx.

  DATA lf_eideswtstatust TYPE eideswtmstatust.


* Entscheidung Zustimmung oder Ablehnung
  SELECT SINGLE * FROM eideswtmstatust
    INTO lf_eideswtstatust
   WHERE status = pd_msgstatus
     AND spras = 'D'.
  CLEAR: pd_flag_zustimm , pd_flag_ablehn.
  IF lf_eideswtstatust-statustxt(4) = text-007.
    MOVE gc_true TO pd_flag_zustimm.
  ELSEIF lf_eideswtstatust-statustxt(4) = text-008.
    MOVE gc_true TO pd_flag_ablehn.
  ENDIF.

ENDFORM.                    " check_status_zustimm
*&---------------------------------------------------------------------*
*&      Form  HOLE_KEYDATUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PF_MSGDATA  text
*      <--P_LD_KEYDATUM  text
*----------------------------------------------------------------------*
FORM hole_keydatum USING    pf_msgdata TYPE eideswtmsgdata
                   CHANGING pd_keydatum TYPE sy-datum.

  CLEAR pd_keydatum.
  IF NOT pf_msgdata-moveindate IS INITIAL.
    MOVE pf_msgdata-moveindate TO pd_keydatum.
  ELSEIF NOT pf_msgdata-moveoutdate IS INITIAL.
    MOVE pf_msgdata-moveoutdate TO pd_keydatum.
*  ELSEIF NOT pf_msgdata-zz_changedate IS INITIAL.
*    MOVE pf_msgdata-zz_changedate TO pd_keydatum.
  ELSE.
    MOVE sy-datum TO pd_keydatum.
  ENDIF.

ENDFORM.                    " hole_keydatum
*&---------------------------------------------------------------------*
*&      Form  HOLE_METMETHOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_POD  text
*      -->P_LD_KEYDATUM  text
*      <--P_PF_MSGDATA_METMETHOD  text
*----------------------------------------------------------------------*
FORM hole_metmethod USING    pd_int_ui TYPE int_ui
                             pd_keydatum TYPE sy-datum
                    CHANGING pd_metmethod TYPE eideswtmsgdata-metmethod.

  DATA:  BEGIN OF lf_logikzw ,
           logikzw TYPE logikzw,
         END OF lf_logikzw.
  DATA i_logikzw LIKE TABLE OF lf_logikzw.

  DATA i_etdz TYPE TABLE OF etdz.
  DATA lf_etdz TYPE etdz.
  DATA ld_anlage TYPE anlage.

  MOVE gc_metmethod_slp TO pd_metmethod.

* Anlage
  PERFORM hole_anlage_int_ui USING pd_keydatum
                                   pd_int_ui
                          CHANGING ld_anlage.
* Alle Zählwerke einlesen
  SELECT logikzw FROM easts
    INTO TABLE i_logikzw
  WHERE anlage EQ ld_anlage
    AND ab     LE pd_keydatum
    AND bis    GE pd_keydatum.

  CHECK NOT i_logikzw IS INITIAL.

* Nur Zählwerke mit OBIS-Kennziffern übriglassen
  SELECT * FROM etdz INTO TABLE i_etdz
     FOR ALL ENTRIES IN i_logikzw
   WHERE logikzw = i_logikzw-logikzw
     AND kennziff NE space
     AND ab     LE pd_keydatum
     AND bis    GE pd_keydatum.

  LOOP AT i_etdz INTO lf_etdz.
    IF NOT lf_etdz-intsizeid IS INITIAL.
      MOVE gc_metmethod_rlm TO pd_metmethod.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " hole_metmethod
*&---------------------------------------------------------------------*
*&      Form  HOLE_VS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PF_EIDESWTDOC  text
*      -->P_LD_KEYDATUM  text
*      -->P_LF_ANLAGE  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_vs USING                pf_eideswtdoc TYPE eideswtdoc
                                  pd_keydatum TYPE sy-datum
                                  pf_netzanlage TYPE v_eanl
                         CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA lf_eadrdat TYPE eadrdat.

  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_anlage                   = pf_netzanlage-anlage
    IMPORTING
      y_eadrdat                  = lf_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.

  CHECK sy-subrc EQ 0.

* Übernahme der Adressdaten
  MOVE lf_eadrdat-street TO pf_msgdata-street.
*  MOVE lf_eadrdat-str_suppl1 TO pf_msgdata-zz_street2.
  MOVE lf_eadrdat-house_num1 TO pf_msgdata-housenr.
  MOVE lf_eadrdat-house_num2 TO pf_msgdata-housenrext.
  MOVE lf_eadrdat-city1 TO pf_msgdata-city.
  MOVE lf_eadrdat-post_code1 TO pf_msgdata-postcode.
** PhL 2016-04-06
*  MOVE lf_eadrdat-country TO pf_msgdata-zz_land.
*/ PhL 2016-04-06

ENDFORM.                    " hole_vs
*&---------------------------------------------------------------------*
*&      Form  HOLE_ZAEHLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LF_ANLAGE  text
*      -->P_LD_KEYDATUM  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_zaehler USING    pf_anlage TYPE v_eanl
                           pd_keydatum TYPE sy-datum
                  CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA lt_eastl TYPE TABLE OF eastl.
  DATA lf_eastl TYPE eastl.
  DATA lt_v_eger TYPE STANDARD TABLE OF v_eger.
  DATA lf_v_eger TYPE v_eger.

* Für den Vertriebsmandanten
  DATA lt_egerr TYPE STANDARD TABLE OF egerr.
  DATA lf_egerr TYPE egerr.

* Ermitteln der logischen Gerätenummern zur Anlage
  CALL FUNCTION 'ISU_DB_EASTL_SELECT'
    EXPORTING
      x_anlage      = pf_anlage-anlage
      x_ab          = pd_keydatum
      x_bis         = pd_keydatum
    TABLES
      t_eastl       = lt_eastl
    EXCEPTIONS
      not_found     = 1
      system_error  = 2
      not_qualified = 3
      OTHERS        = 4.

  CHECK sy-subrc EQ 0.


*Cleare die internen Tabellen
  REFRESH: lt_v_eger, lt_egerr.

* Ermitteln des Geräts zur Log. Gerätenummer
  LOOP AT lt_eastl INTO lf_eastl.

    CLEAR lf_egerr.
    MOVE lf_eastl-logiknr TO lf_egerr-logiknr.
    MOVE pd_keydatum TO lf_egerr-ab.
    MOVE pd_keydatum TO lf_egerr-bis.
    APPEND lf_egerr TO lt_egerr.


  ENDLOOP.

*  IF NOT lt_v_eger IS INITIAL.
*    CALL FUNCTION 'ISU_DB_EGER_FORALL_LOGIKNR'
*      TABLES
*        t_v_eger  = lt_v_eger
*      EXCEPTIONS
*        not_found = 1
*        OTHERS    = 2.
*    IF sy-subrc = 0.
*      LOOP AT lt_v_eger INTO lf_v_eger.
*        IF lf_v_eger-kombinat CS 'Z'.
*          WRITE lf_v_eger-geraet TO pf_msgdata-meternr.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.

  IF NOT lt_v_eger IS INITIAL.

*Auf dem Vertriebsmandanten gibt es nur Geräteinfosätze. Die Konsequenz ist, dass die Informationen über das Gerät
*nicht (wie beim Netzmandanten) in der Struktur V_EGER_H, sondern in der Tabelle EGERR stehen. Daher muss ein anderer
*Funktionsbaustein ausgewählt werden.
    CALL FUNCTION 'ISU_DB_EGER_FORALL_LOGIKNR'
      TABLES
        t_v_eger  = lt_v_eger
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc = 0.
      LOOP AT lt_v_eger INTO lf_v_eger.
        IF lf_v_eger-kombinat CS 'Z'.
          WRITE lf_v_eger-geraet TO pf_msgdata-meternr.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ELSEIF NOT lt_egerr IS INITIAL.
    CALL FUNCTION 'ISU_DB_EGERR_FORALL_LOGIKNR'
      TABLES
        t_egerr   = lt_egerr
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      LOOP AT lt_egerr INTO lf_egerr.
        IF lf_egerr-kombinat CS 'Z'.
          WRITE lf_egerr-geraet TO pf_msgdata-meternr.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " hole_zaehler
*&---------------------------------------------------------------------*
*&      Form  MOVEIN_MOVEOUT_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_BEGINNZUM  text
*      -->P_SY_DATUM  text
*      -->P_PD_CATEGORY  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM movein_moveout_date
   USING    pd_beginnzum TYPE eideswtmsgdata-moveindate
            pd_endezum TYPE eideswtmsgdata-moveoutdate
            pd_category TYPE eideswtmdcat
   CHANGING pf_msgdata TYPE eideswtmsgdata.

  CASE pd_category.
    WHEN gc_category_anmeldung OR gc_category_info.
      IF NOT pd_beginnzum IS INITIAL.
        MOVE pd_beginnzum TO pf_msgdata-moveindate.
      ENDIF.
      CLEAR pf_msgdata-moveoutdate.
    WHEN gc_category_abmeld OR gc_category_kuend.
      IF NOT pd_endezum IS INITIAL.
        MOVE pd_endezum TO pf_msgdata-moveoutdate.
      ENDIF.
* bei Zwangsabmeldungen haben wir nur ein Einzugsdatum, d.h.
* wir müssen das Auszugsdatum berechnen.
      IF pf_msgdata-moveoutdate IS INITIAL
      AND NOT pd_beginnzum IS INITIAL.
        COMPUTE pf_msgdata-moveoutdate =
                pd_beginnzum - 1.
      ENDIF.
      CLEAR pf_msgdata-moveindate.

    WHEN OTHERS.
      IF NOT pd_beginnzum IS INITIAL.
        MOVE pd_beginnzum TO pf_msgdata-moveindate.
      ENDIF.
      IF NOT pd_endezum IS INITIAL.
        MOVE pd_endezum TO pf_msgdata-moveoutdate.
      ENDIF.
  ENDCASE.

ENDFORM.                    " movein_moveout_date
*&---------------------------------------------------------------------*
*&      Form  HOLE_GPART_EVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LF_EVER  text
*      <--P_E_GPART  text
*----------------------------------------------------------------------*
FORM hole_gpart_ever USING    pf_ever TYPE ever
                     CHANGING pd_gpart TYPE bu_partner.

  CLEAR pd_gpart.

  SELECT SINGLE gpart FROM fkkvkp INTO pd_gpart
   WHERE vkont = pf_ever-vkonto.

ENDFORM.                    " hole_gpart_ever
*&---------------------------------------------------------------------*
*&      Form  HOLE_INT_UI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EXT_UI  text
*      -->P_I_KEYDATE  text
*      <--P_LD_INT_UI  text
*----------------------------------------------------------------------*
FORM hole_int_ui USING    pd_ext_ui TYPE ext_ui
                          pd_keydate TYPE d
                 CHANGING pd_int_ui TYPE int_ui.

  DATA lf_euitrans TYPE euitrans.

  CLEAR pd_int_ui.
  CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
    EXPORTING
      x_ext_ui     = pd_ext_ui
      x_keydate    = pd_keydate
*     X_KEYTIME    = SY-UZEIT
    IMPORTING
      y_euitrans   = lf_euitrans
    EXCEPTIONS
      not_found    = 1
      system_error = 2
      OTHERS       = 3.
  IF sy-subrc = 0.
    MOVE lf_euitrans-int_ui TO pd_int_ui.
  ENDIF.


ENDFORM.                    " hole_int_ui
*&---------------------------------------------------------------------*
*&      Form  GET_IDREF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LF_MSGDATA  text
*----------------------------------------------------------------------*
FORM get_idref CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA: lv_idrefnr_guid TYPE guid_32.

  CLEAR: pf_msgdata-idrefnr.

  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_32 = lv_idrefnr_guid.

  pf_msgdata-idrefnr = lv_idrefnr_guid.

ENDFORM.                    " get_idref
*&---------------------------------------------------------------------*
*&      Form  HOLE_BEMERKUNGEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_ANFRAGE  text
*      -->P_LD_CATEGORY  text
*      -->P_LF_MSGDATA  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LT_DDTEXT  text
*      <--P_E_COMMENTTXT  text
*----------------------------------------------------------------------*
FORM hole_bemerkungen  USING    pd_anfrage        TYPE kennzx
                                pd_category       TYPE eideswtmdcat
                                pf_msgdata        TYPE eideswtmsgdata
                                pf_eideswtdoc     TYPE eideswtdoc
                                pt_ddtext         TYPE zeagp_t_ddtext
                       CHANGING pd_commenttxt     TYPE eideswtmdcomment.


  DATA wa_eideswtmsgfield TYPE eideswtmsgfield.
  DATA l_fieldcheckid     TYPE eideswtfieldcheckid.
  DATA l_ddtext TYPE dd04t-ddtext.



  IF  pd_anfrage  = gc_false.                   "Keine Anfrage, sondern Antwort
    IF pd_category = gc_category_anmeldung      "E01
    OR pd_category = gc_category_abmeld         "E02
    OR pd_category = gc_category_kuend.         "E35

*E07 - Zustimmung mit Korrektur
      IF pf_msgdata-msgstatus = 'E07'.
*        OR pf_msgdata-zz_sammelstatus CS 'E07'.

        IF NOT pt_ddtext[] IS INITIAL.
          LOOP AT pt_ddtext INTO l_ddtext.
            CONCATENATE l_ddtext pd_commenttxt
                  INTO pd_commenttxt SEPARATED BY space.

          ENDLOOP.
        ELSE.
          CONCATENATE 'Zustimmung mit Korrektur' pd_commenttxt
                 INTO pd_commenttxt SEPARATED BY space.

        ENDIF.

*E14 - Ablehnung Sonstiges
      ELSEIF pf_msgdata-msgstatus = 'E14'.
*              OR pf_msgdata-zz_sammelstatus CS 'E14'.


        CONCATENATE 'Ablehnung Sonstiges' pd_commenttxt
               INTO pd_commenttxt SEPARATED BY space.



*Z07 - Ablehnung keine Berechtigung
*(Dieser Antwortstatus wird zumindest laut Verwendungsnachweis im VNB-Workflow nicht verwendet.)
      ELSEIF pf_msgdata-msgstatus = 'Z07'.
*              OR pf_msgdata-zz_sammelstatus CS 'Z07'.

        CONCATENATE 'Entnahmestelle durch anderen Lieferanten beliefert' pd_commenttxt
                 INTO pd_commenttxt SEPARATED BY space.


*Alle anderen Antwortkategorien
      ELSE.
        "clear pd_commenttxt.  "UG Wir brauchen das noch !
      ENDIF.
    ELSE.
    ENDIF.
  ENDIF.

ENDFORM.                    " HOLE_BEMERKUNGEN
*&---------------------------------------------------------------------*
*&      Form  HOLE_EIDESWTDOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_SWITCHNUM  text
*      <--P_LF_EIDESWTDOC  text
*----------------------------------------------------------------------*
FORM hole_eideswtdoc USING    pd_switchnum TYPE eideswtnum
                     CHANGING pf_eideswtdoc TYPE eideswtdoc.

  SELECT SINGLE * FROM eideswtdoc
    INTO pf_eideswtdoc WHERE switchnum = pd_switchnum.

ENDFORM.                    " hole_eideswtdoc
*&---------------------------------------------------------------------*
*&      Form  HOLE_MSGDATA_LAREQE02Z27
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ENDEZUM  text
*      -->P_LD_SWITCHNUM  text
*      -->P_LD_MSGDATANUM  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LF_EIDESWTDOC_POD  text
*      -->P_LD_TRANSREASON  text
*      -->P_LD_CATEGORY  text
*      -->P_LD_ANFRAGE  text
*      -->P_LD_SWTVIEW  text
*      <--P_LF_MSGDATA  text
*      <--P_E_COMMENTTXT  text
*----------------------------------------------------------------------*
FORM hole_msgdata_lareqe02z27  USING    pd_endezum TYPE dats
                                        pd_switchnum
                                        pd_msgdatanum
                                        pf_eideswtdoc TYPE eideswtdoc
                                        pd_pod TYPE int_ui
                                        pd_transreason    TYPE eideswtmdtran
                                        pd_category       TYPE eideswtmdcat
                                        pd_anfrage        TYPE kennzx
                                        pd_swtview        TYPE eideswtview
                               CHANGING pf_msgdata TYPE eideswtmsgdata
                                        pd_commenttxt   TYPE eideswtmdcomment.

* Aufbau 'Sperrauftrag' (E02) (Lieferant an VNB)
* Hü 09.06.2008: Aufgrund der Tatsache, dass im UTILMD 4.1 Anwendungshandbuch keine Vorgaben zur dieser Nachricht
* gemacht wurden, wird aktuell die normale E02-Nachricht (angepasst an dieses Szenario) als Basis verwendet.

  DATA lf_anlage TYPE v_eanl.
  DATA ld_keydatum TYPE sy-datum.
  DATA ld_metmethod TYPE eideswtmdmetmethod.

* (24a - NEIN) Einzugsdatum (Beginn zum - Lieferbeginn) wird gefüllt
* (24c - MUSS) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* Diese Methode muss vor hole_keydatum durchgeführt werden
  PERFORM movein_moveout_date USING sy-datum
                                    pd_endezum
                                    gc_category_abmeld
                           CHANGING pf_msgdata.

* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM hole_keydatum USING  pf_msgdata
                     CHANGING  ld_keydatum.


* (5b - MUSS) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM hole_ext_ui  USING pf_eideswtdoc
                             ld_keydatum
                    CHANGING pf_msgdata.


* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM hole_anlage USING pd_pod
                            ld_keydatum
                   CHANGING lf_anlage.


* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)
* (V2 - NEIN) Referenz zu einem Vorgang (Nur bei Antwortnachricht)
* (4a - MUSS) Adresse Lieferstelle (Lieferadresse)
* Hü: 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM hole_vs USING pf_eideswtdoc
                        ld_keydatum
                        lf_anlage
               CHANGING pf_msgdata.


* (1a - Name des Anschlussnutzers - MUSS) + (1b - Anschrift des Kunden (Nur genutzt, wenn Kunde nicht an Lieferstelle wohnt) - KANN)
* GP (Geschäftspartner)
  PERFORM hole_gp USING pd_pod
                        ld_keydatum
                        gc_category_abmeld
                        gc_transreason_sperrung
                        space
                        pf_eideswtdoc-partner
                        space
               CHANGING pf_msgdata.

** (2a - KANN) Kundennummer des Kunden beim Lieferanten
** 07.08.2008 Hü: Explizit von Kiel gewünscht, dass die Vertragskontonummer an den Netzbetreiber übermittelt wird.
*  PERFORM hole_vkonto_lief USING pf_eideswtdoc
*                                 ld_keydatum
*                                 lf_anlage
*                                 pf_eideswtdoc-partner
*                        CHANGING pf_msgdata.

* (2b - KANN) Kundennummer des Kunden bei dem Verteilnetzbetreiber
* Für gewöhnlich weiß nur der Verteilnetzbetreiber die eigene Kundenummer


* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - KANN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - KANN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus
* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - KANN) Zählpunkt als Aggregationspunkt


* (7 - MUSS (außer bei Pauschalanlagen)) Zählernummer (Zählernummer / Eigentumsnummer)
  PERFORM hole_zaehler USING lf_anlage
                             ld_keydatum
                    CHANGING pf_msgdata.

* (8a - NEIN) Bisheriger Lieferant: VDEW-Code-Nummer
* (8b - NEIN) Kundennummer beim bisherigen Lieferanten
* (9 - KANN) Sonstige Hinweise zur Identifizierung
* (10 - NEIN) Antwortkategorien

* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt

* (12 - NEIN) Art der Versorgung
* (13 - NEIN) Regelzone

** (14a - MUSS) Bilanzkreisbezeichnung (EICode Bilanzkreis) (= Bilanzkreisverantwortlicher in den Nachrichtendaten = 11Xer-Nummer)
*** Bilanzkreisverantwortlicher bei Zwangsabmeldungen
**    IF ( ld_anfrage EQ gc_true OR ld_anfrage EQ lc_msgstat001 ).
*  PERFORM hole_bilanzkreisverantw USING pf_eideswtdoc
*                                        pd_transreason
*                                        pd_category
*                                        pd_anfrage
*                                        pd_swtview
*                              CHANGING  pf_msgdata.
*    ENDIF.
*    PERFORM hole_bilanzkreis USING lf_eideswtdoc
*                                   ld_keydatum
*                          CHANGING lf_msgdata.

* (14b - KANN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - NEIN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB


** (14d - MUSS) Bilanzierungsgebiet
** EICode Bilanzierungsgebiet - Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
*  PERFORM hole_bilanzierunggebiet  USING pf_eideswtdoc
*                                         lf_anlage
*                                         ld_keydatum
*                                CHANGING pf_msgdata.


* (15 - NEIN) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt, handelt es sich um einen Haushaltskunden, sonst nicht.
* (16 - NEIN) Zählverfahren, wird aus dem IS-U bestimmt
* (17a - NEIN) Start Abrechnungsjahr (nur bei RLM)
* (17b - NEIN) Bisher gemessene Maximalleistung (nur bei RLM)
* (17c - NEIN) Reservenetzkapazität (bestellt)
* (17d - NEIN) Netzanschlusskapazität (nur bei RLM)
* (18a - NEIN) Standardlastprofilzuordnung oder (Tarif-/Kunden-) Gruppenzuordnung bei analytischen Verfahren oder sonstige Zuordnung
* (18b - NEIN) Jahresverbrauch
* (19a - NEIN) Profilschar
* (19b - NEIN) Spezifische Arbeit
* (19c - NEIN) Temperaturmessstelle
* (19d - NEIN) Verbrauchsaufteilung
* (19e - NEIN) Steuerungsart
* (19f - NEIN) Anlagetyp
* (19g - NEIN) Installierte Leistung
* (20 - KANN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird
* (21a/b - NEIN) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
* (22 - NEIN) Art der Messwerte (OBIS-Kennzahlen)
* (23a - NEIN) Spannungsebene der Anschlussstelle der Lieferstelle
* (23b - NEIN) Messung findet statt in
* (23c - NEIN) Verlustfaktor in Prozent
* (24b - NEIN) Änderung zum (Start der Änderung)
* (24d - NEIN) Ende zum (nächstmöglichen Termin)
* (24e - NEIN) Bilanzierungsbeginn
* (24f - NEIN) Bilanzierungsende
* (25a - NEIN) Status
* (25c - NEIN) Zahler der Netznutzung
* (26a - NEIN) Konzessionsabgabe (vorläufige Annahme); (Konzessionsabgabe S/AA/E)
* (26b - NEIN) Betrag (KA)
* (27 - KANN (MUSS bei E07,E14, Z07 in SG4-STS)) Bemerkungen (Vorgangsbezogen)
  PERFORM hole_comment USING pd_msgdatanum
                             pd_switchnum
                    CHANGING pd_commenttxt.

* ENDE 'Sperrauftrag' (E02)
*--------------------------------------------------------------------------------------------------*

ENDFORM.                    " HOLE_MSGDATA_LAREQE02Z27
*&---------------------------------------------------------------------*
*&      Form  HOLE_MSGDATA_LREQE05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BEGINNZUM  text
*      -->P_I_ENDEZUM  text
*      -->P_LD_SWITCHNUM  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LD_TRANSREASON  text
*      -->P_I_ANSWERSTATUS  text
*      -->P_LD_CATEGORY  text
*      -->P_LD_SWTVIEW  text
*      -->P_I_EMPF_SERVICEID  text
*      -->P_LD_MSGDATANUM  text
*      <--P_LF_MSGDATA  text
*      <--P_E_SERVICEID_OLD  text
*----------------------------------------------------------------------*
FORM hole_msgdata_lreqe05    USING   pd_beginnzum      TYPE eidemoveindate
                                     pd_endezum        TYPE eidemoveoutdate
                                     pd_switchnum      TYPE eideswtnum
                                     pf_eideswtdoc     TYPE eideswtdoc
                                     pd_transreason    TYPE eideswtmdtran
                                     pd_answerstatus   TYPE eideswtmdstatus
                                     pd_category       TYPE eideswtmdcat
                                     pd_swtview        TYPE eideswtview
                                     pd_empf_serviceid TYPE eideswtdoc-service_prov_old
                                     pd_msgdatanum     TYPE eideswtmdnum
                            CHANGING pf_msgdata        TYPE eideswtmsgdata
                                     pd_serviceid_old  TYPE service_prov.


  DATA pf_anlage TYPE v_eanl.
  DATA pd_keydatum TYPE sy-datum.

* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM hole_keydatum USING  pf_msgdata
                     CHANGING  pd_keydatum.


* (5b - MUSS (leer, wenn zu stornierende Nachricht keinen Zählpunkt hat)) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM hole_ext_ui  USING pf_eideswtdoc
                             pd_keydatum
                    CHANGING pf_msgdata.


* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM hole_anlage USING pf_eideswtdoc-pod
                            pd_keydatum
                   CHANGING pf_anlage.


* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)
* Wird am Ende des Funktionsbausteins gepflegt


* (V2 - MUSS) Referenz zu einem Vorgang
* Beim Storno einer Kategorie E01 Anfrage brauchen wir die ID-Refnr der versendeten Nachricht aus der Datenbank
* und füllen sie in das Feld ZZ_IDREF
* Hü 26.06.2008: Das gleiche gilt für eine Stornonachricht der Kategorie E02
*  IF  pd_category = gc_category_anmeldung.    "E01
  IF  pd_category = gc_category_anmeldung      "E01
    OR pd_category = gc_category_abmeld.
    PERFORM hole_idrefnr_nachricht USING pf_eideswtdoc-switchnum
                                         pd_msgdatanum
                                CHANGING pf_msgdata.
  ELSE.
    PERFORM hole_refnummer CHANGING pf_msgdata.
  ENDIF.


* (4a - KANN) Adresse Lieferstelle (Lieferadresse)
* Hü: 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM hole_vs USING pf_eideswtdoc
                        pd_keydatum
                        pf_anlage
               CHANGING pf_msgdata.


* (1a - Name des Anschlussnutzers - KANN) + (1b - Anschrift des Kunden - NEIN)
* GP (Geschäftspartner)
  PERFORM hole_gp USING pf_eideswtdoc-pod
                        pd_keydatum
                        pd_category
                        pd_transreason
                        pd_answerstatus
                        pf_eideswtdoc-partner
                        space
               CHANGING pf_msgdata.


** (2a - KANN) Kundennummer des Kunden beim Lieferanten
*  PERFORM hole_exvko USING  pf_eideswtdoc
*                            pd_keydatum
*                            pf_anlage
*                            pd_category
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.


* (2b - KANN) Kundennummer des Kunden bei dem Verteilnetzbetreiber
* Diese Stelle kann auf beiden Mandanten durchlaufen werden
*  PERFORM hole_vkonto USING pf_eideswtdoc
*                            pd_keydatum
*                            pf_anlage
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.


* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - NEIN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - NEIN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus
* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - NEIN) Zählpunkt als Aggregationspunkt


* (7 - KANN) Zählernummer (Zählernummer / Eigentumsnummer)
  PERFORM hole_zaehler USING pf_anlage
                             pd_keydatum
                    CHANGING pf_msgdata.


* (8a - NEIN) Bisheriger Lieferant: VDEW-Code-Nummer
* (8b - NEIN) Kundennummer beim bisherigen Lieferanten
* (9 - KANN) Sonstige Hinweise zur Identifizierung
* (10 - NEIN) Antwortkategorien


* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt


* (12 - NEIN) Art der Versorgung
* (13 - NEIN) Regelzone
* (14a - NEIN) Bilanzkreisbezeichnung
* (14b - NEIN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - NEIN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14d - NEIN) Bilanzierungsgebiet; EICode Bilanzierungsgebiet - Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
* (15 - NEIN) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt, handelt es sich um einen Haushaltskunden, sonst nicht.


* (16 - NEIN) Zählverfahren, wird aus dem IS-U bestimmt
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-metmethod.


* (17a - NEIN) Start Abrechnungsjahr (nur bei RLM)
* (17b - NEIN) Bisher gemessene Maximalleistung (nur bei RLM)
* (17c - NEIN) Reservenetzkapazität (bestellt)
* (17d - NEIN) Netzanschlusskapazität (nur bei RLM)


* (18a - NEIN) Standardlastprofilzuordnung oder (Tarif-/Kunden-) Gruppenzuordnung bei analytischen Verfahren oder sonstige Zuordnung
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-profile.


* (18b - NEIN) Jahresverbrauch
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-progyearcons.



* (19a - NEIN) Profilschar
* (19b - NEIN) Spezifische Arbeit
* (19c - NEIN) Temperaturmessstelle
* (19d - NEIN) Verbrauchsaufteilung
* (19e - NEIN) Steuerungsart
* (19f - NEIN) Anlagetyp
* (19g - NEIN) Installierte Leistung
* (20 - NEIN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird


** (21a/b - NEIN) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
** Ansonsten wird dennoch ein Wert übernommen.
*  CLEAR pf_msgdata-zz_ablweek.


* (22 - NEIN) Art der Messwerte (OBIS-Kennzahlen)
* Ansonsten wird dennoch ein Wert übernommen.
** PhL 2016-04-06
* CLEAR pf_msgdata-zz_obiskennzahl.
*/ PhL 2016-04-06

* (23a - NEIN) Spannungsebene der Anschlussstelle der Lieferstelle
* (23b - NEIN (Kann bei Ablehnung)) Messung findet statt in
* (23c - NEIN) Verlustfaktor in Prozent


* (24a - NEIN) Einzugsdatum (Beginn zum - Lieferbeginn)
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-moveindate.


* (24b - NEIN) Änderung zum (Start der Änderung)


* (24c - NEIN) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-moveoutdate.


* (24d - NEIN) Ende zum (nächstmöglichen Termin)
* (24e - NEIN) Bilanzierungsbeginn
* (24f - NEIN) Bilanzierungsende
* (25a - NEIN) Status
* (25c - NEIN) Zahler der Netznutzung


* (26a - NEIN) Konzessionsabgabe (vorläufige Annahme) (Konzessionsabgabe S/AA/E)
* Ansonsten wird dennoch ein Wert übernommen.
** PhL 2016-04-06
*  CLEAR pf_msgdata-zz_konzabgabe.
*/ PhL 2016-04-06

* (26b - NEIN) Betrag (KA)

* (27 - KANN) Bemerkungen (Vorgangsbezogen)

ENDFORM.                    " HOLE_MSGDATA_LREQE05
*&---------------------------------------------------------------------*
*&      Form  HOLE_IDREFNR_NACHRICHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PF_EIDESWTDOC_SWITCHNUM  text
*      -->P_PD_MSGDATANUM  text
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_idrefnr_nachricht USING    pd_switchnum TYPE eideswtnum
                                     pd_msgdatanum TYPE eideswtmdnum
                            CHANGING pf_msgdata TYPE eideswtmsgdata.

  DATA ld_idrefnr TYPE eideswtmdidrefnr.

  SELECT SINGLE idrefnr FROM eideswtmsgdata
    INTO ld_idrefnr
   WHERE switchnum  = pd_switchnum
     AND msgdatanum = pd_msgdatanum.

  IF sy-subrc EQ 0.
** PhL 2016-04-06
*    MOVE ld_idrefnr TO pf_msgdata-zz_old_idrefnr.
*/ PhL 2016-04-06
  ENDIF.

ENDFORM.                    " Hole_IDREFNR_Nachricht
*&---------------------------------------------------------------------*
*&      Form  HOLE_REFNUMMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PF_MSGDATA  text
*----------------------------------------------------------------------*
FORM hole_refnummer CHANGING pf_msgdata TYPE eideswtmsgdata.

** PhL 2016-04-06
*  MOVE pf_msgdata-idrefnr TO pf_msgdata-zz_old_idrefnr.
*/ PhL 2016-04-06

ENDFORM.                    " hole_refnummer
*&---------------------------------------------------------------------*
*&      Form  HOLE_MSGDATA_VNBRESE01Z28
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BEGINNZUM  text
*      -->P_I_ENDEZUM  text
*      -->P_LD_SWITCHNUM  text
*      -->P_LD_MSGDATANUM  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LF_EIDESWTDOC_POD  text
*      -->P_LD_TRANSREASON  text
*      -->P_I_ANSWERSTATUS  text
*      -->P_I_NETZANSCHLKAP  text
*      -->P_LD_CATEGORY  text
*      -->P_FLG_ZUSTIMMUNG  text
*      <--P_LF_MSGDATA  text
*      <--P_E_COMMENTTXT  text
*----------------------------------------------------------------------*
FORM hole_msgdata_vnbrese01z28  USING pd_beginnzum    TYPE eidemoveindate
                                      pd_endezum      TYPE eidemoveoutdate
                                      pd_switchnum    TYPE eideswtnum
                                      pd_msgdatanum   TYPE eideswtmdnum
                                      pf_eideswtdoc   TYPE eideswtdoc
                                      pd_pod          TYPE int_ui
                                      pd_transreason  TYPE eideswtmdtran
                                      pd_answerstatus TYPE eideswtmdstatus
                                      pd_netzanschkap TYPE /ADESSO/EIDESWTMDNETZKAP
                                      pd_category     TYPE eideswtmdcat
                                      pd_zustimmung   TYPE kennz
                             CHANGING pf_msgdata      TYPE eideswtmsgdata
                                      pd_commenttxt     TYPE eideswtmdcomment.

*Hinweis: Bei Ablehnung (= Antwort) schicke ich die gleichen Nachrichtendaten zurück + Antwortstatus.


  DATA lf_anlage TYPE v_eanl.
  DATA ld_keydatum TYPE sy-datum.
  DATA ld_metmethod TYPE eideswtmdmetmethod.


* (24a - MUSS) Einzugsdatum (Beginn zum - Lieferbeginn) wird gefüllt
* (24c - KEIN) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* Muss vor hole_keydatum durchgeführt werden.
  PERFORM movein_moveout_date USING pd_beginnzum
                                    pd_endezum
                                    pd_category
                           CHANGING pf_msgdata.

* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM hole_keydatum USING  pf_msgdata
                     CHANGING  ld_keydatum.


* (5b - MUSS) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM hole_ext_ui  USING pf_eideswtdoc
                             ld_keydatum
                    CHANGING pf_msgdata.


* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM hole_anlage USING pd_pod
                            ld_keydatum
                   CHANGING lf_anlage.


* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)


* (V2 - MUSS) Referenz zu einem Vorgang (Nur bei Antwortnachricht)
  PERFORM hole_refnummer CHANGING pf_msgdata.


* (4a - MUSS) Adresse Lieferstelle (Lieferadresse)
* Hü: 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM hole_vs USING pf_eideswtdoc
                        ld_keydatum
                        lf_anlage
               CHANGING pf_msgdata.


* (1a - MUSS) Name des Anschlussnutzers + (1b - KANN) Anschrift des Kunden (Nur genutzt, wenn Kunde nicht an Lieferstelle wohnt)
* GP (Geschäftspartner)
  PERFORM hole_gp USING pd_pod
                        ld_keydatum
                        pd_category
                        pd_transreason
                        pd_answerstatus
                        pf_eideswtdoc-partner
                        space
               CHANGING pf_msgdata.


** (2a - KANN) Kundennummer des Kunden beim Lieferanten
*  PERFORM hole_exvko USING  pf_eideswtdoc
*                            ld_keydatum
*                            lf_anlage
*                            pd_category
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.


** (2b - KANN) Kundennummer des Kunden bei dem Verteilnetzbetreiber
*** (2b - MUSS bei Zustimmung, sonst leer) Kundennummer des Kunden bei dem Verteilnetzbetreiber
*  IF pd_zustimmung = gc_true.
*    PERFORM hole_vkonto USING pf_eideswtdoc
*                              ld_keydatum
*                              lf_anlage
*                              pf_eideswtdoc-partner
*                     CHANGING pf_msgdata.
*  ELSE.
*    CLEAR pf_msgdata-zz_partner_n.
*  ENDIF.


* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - KANN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - KANN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus
* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - KANN) Zählpunkt als Aggregationspunkt


* (7 - MUSS (außer bei Pauschalanlagen)) Zählernummer (Zählernummer / Eigentumsnummer)
  PERFORM hole_zaehler USING lf_anlage
                             ld_keydatum
                    CHANGING pf_msgdata.


* (8a - NEIN) Bisheriger Lieferant: VDEW-Code-Nummer
* (8b - NEIN) Kundennummer beim bisherigen Lieferanten
* (9 - KANN) Sonstige Hinweise zur Identifizierung


* (10 - MUSS) Antwortkategorien
* = answerstatus (wird unten gesetzt)


* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt


* (12 - MUSS) Art der Versorgung
*  PERFORM hole_versart USING pf_eideswtdoc
*                             ld_keydatum
*                             pd_pod
*                    CHANGING pf_msgdata.


** (13 - MUSS bei Zustimmung, sonst leer) Regelzone
*  IF pd_zustimmung = gc_true.
*    PERFORM hole_regelzone USING pf_eideswtdoc
*                                 ld_keydatum
*                                 lf_anlage-sparte
*                        CHANGING pf_msgdata.
*  ELSE.
*    CLEAR pf_msgdata-zz_regelzone.
*  ENDIF.


* (14a - MUSS) Bilanzkreisbezeichnung (EICode Bilanzkreis)
*    PERFORM hole_bilanzkreis USING lf_eideswtdoc
*                                   ld_keydatum
*                          CHANGING lf_msgdata.
* Bei Antwort müsste der bei der Anfrage übermittelte Wert einfach zurückgegeben werden.


* (14b - KANN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - KANN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB


** (14d - MUSS) Bilanzierungsgebiet
** EICode Bilanzierungsgebiet - Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
*  PERFORM hole_bilanzierunggebiet  USING pf_eideswtdoc
*                                         lf_anlage
*                                         ld_keydatum
*                                CHANGING pf_msgdata.
*
*
** (15 - MUSS (wenn Haushaltskunde)) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt,
** handelt es sich um einen Haushaltskunden, sonst nicht.
*  PERFORM hole_ist_haushaltskunde USING   pf_eideswtdoc
*                                          ld_keydatum
*                                          lf_anlage
*                                 CHANGING pf_msgdata.


* (16 - MUSS) Zählverfahren, wird aus dem IS-U bestimmt
  PERFORM hole_metmethod USING pd_pod
                               ld_keydatum
                      CHANGING pf_msgdata-metmethod.

*  PERFORM hole_metmethod_msgdata USING pf_eideswtdoc
*                                       ld_keydatum
*                                       pf_msgdata-metmethod
*                              CHANGING pf_msgdata
*                                       ld_metmethod.


** (17a - MUSS) Start Abrechnungsjahr (nur bei RLM)
*  PERFORM hole_start_abrjahr USING pf_eideswtdoc
*                                   ld_keydatum
*                                   ld_metmethod
*                                   lf_anlage
*                          CHANGING pf_msgdata.
*
*
** (17b - MUSS bei unterjährigen Messungen (sonst Kann)) Bisher gemessene Maximalleistung (nur bei RLM)
*
*
** (17c - KANN) Reservenetzkapazität (bestellt)
*
*
** (17d - MUSS) Netzanschlusskapazität (nur bei RLM)
*  IF NOT pd_netzanschkap IS INITIAL.
*    MOVE pd_netzanschkap TO pf_msgdata-zz_netzanschkap.
*  ENDIF.
*
*
** (18a - MUSS bei SLP/ ALP Kunde)
** Standardlastprofilzuordnung oder (Tarif-/Kunden-) Gruppenzuordnung bei analytischen Verfahren oder sonstige Zuordnung
*  PERFORM hole_slp USING lf_anlage
*                         ld_keydatum
*                         ld_metmethod
*                         pd_pod
*                CHANGING pf_msgdata.
*
*
** (18b - MUSS bei Zustimmung und SLP/ALP, sonst leer) Jahresverbrauch
** hole_jvb_pau , hole_jvb Jahresverbrauch
*  IF ld_metmethod EQ gc_metmethod_pau.
*    PERFORM hole_jvb_pau
*                USING
*                   lf_anlage
*                   ld_keydatum
*                CHANGING
*                   pf_msgdata.
*  ELSE.
*    PERFORM hole_jvb
*                USING
*                   lf_anlage
*                   ld_keydatum
*                   pd_pod
*                   space
*                CHANGING
*                   pf_msgdata.
*  ENDIF.
*
*
** (19a - MUSS bei gemeinsam gemessener temp. Anlage) Profilschar
*
*
** (19b - MUSS bei unterbrechbaren SLP/ALPAnlagen und nicht nach Anhang D der VDN Vorschrift) Spezifische Arbeit
** =  spezifischer Verbrauch (kWh/K) HT / NT
*  PERFORM hole_spez_verbr  USING pf_eideswtdoc
*                                 ld_keydatum
*                        CHANGING pf_msgdata.
*
*
** (19c - MUSS bei TLP) Temperaturmessstelle
*
*
** (19d - MUSS bei gemeinsam gemessener temp. Anlage) Verbrauchsaufteilung
*
*
** (19e - KANN) Steuerungsart
** (19f - KANN) Anlagetyp
** (19g - KANN) Installierte Leistung
** (20 - KANN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird
*
*
** (21a/b - MUSS bei SLP/ALP/TLP) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
*  PERFORM hole_next_abl USING pf_eideswtdoc
*                              ld_keydatum
*                              lf_anlage
*                              ld_metmethod
*                     CHANGING pf_msgdata.
*
*
** (22 - MUSS) Art der Messwerte (OBIS-Kennzahlen)
*  PERFORM hole_obis_kennzahl USING pf_eideswtdoc
*                                   ld_keydatum
*                                   lf_anlage
*                          CHANGING pf_msgdata.
*
*
** (23a - MUSS (Kann bei Ablehnung)) Spannungsebene der Anschlussstelle der Lieferstelle
** (23b - MUSS (Kann bei Ablehnung)) Messung findet statt in
*  PERFORM hole_spannungsebene USING pd_pod
*                                    ld_keydatum
*                                    lf_anlage
*                           CHANGING pf_msgdata.
*
*
** (23c - KANN) Verlustfaktor in Prozent
*
*
** (24b - NEIN) Änderung zum (Start der Änderung)
** (24d - NEIN) Ende zum (nächstmöglichen Termin)
*
*
** (24e - MUSS (nur bei Zustimmung)) Bilanzierungsbeginn
** (24f - NEIN) Bilanzierungsende
*  IF pd_zustimmung = gc_true.
*    PERFORM hole_bilanz_beg_ende USING pf_eideswtdoc
*                                       ld_keydatum
*                                       pd_category
*                              CHANGING pf_msgdata.
*  ENDIF.
*
** (25a - MUSS) Status
*  PERFORM hole_zz_statusnenu CHANGING pf_msgdata.
*
*
** (25c - MUSS) Zahler der Netznutzung
*  PERFORM hole_zz_zahler CHANGING pf_msgdata.
*
*
** (26a - MUSS) Konzessionsabgabe (vorläufige Annahme)
** (Konzessionsabgabe S/AA/E)
*  IF pd_zustimmung = gc_true.
*    PERFORM hole_konzabgabe  USING lf_anlage
*                         CHANGING pf_msgdata.
*  ELSE.
** Bei einer Ablehnung darf der möglicherweise vorher enthaltene Wert nicht gelöscht werden, sondern muss in der Antwort enthalten sein
** clear pf_msgdata-zz_konzabgabe.
*  ENDIF.
*
*
** (26b - KANN) Betrag (KA)

ENDFORM.                    " HOLE_MSGDATA_VNBRESE01Z28
*&---------------------------------------------------------------------*
*&      Form  HOLE_MSGDATA_VNBRESE02Z27
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ENDEZUM  text
*      -->P_LD_SWITCHNUM  text
*      -->P_LD_MSGDATANUM  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LF_EIDESWTDOC_POD  text
*      <--P_LF_MSGDATA  text
*      <--P_E_COMMENTTXT  text
*----------------------------------------------------------------------*
FORM hole_msgdata_vnbrese02z27  USING    pd_endezum        TYPE dats
                                         pd_switchnum
                                         pd_msgdatanum
                                         pf_eideswtdoc     TYPE eideswtdoc
                                         pf_eideswtdoc_pod TYPE int_ui
                                CHANGING pf_msgdata        TYPE eideswtmsgdata
                                         pd_commenttxt     TYPE eideswtmdcomment.

* BEGINN 'Antwort zum Sperrauftrag' (E02A) (VNB an Lieferant)
* Aufgrund der Tatsache, dass im UTILMD 4.1 Anwendungshandbuch keine Vorgaben zur dieser Nachricht
* gemacht wurden, wird aktuell die normale E02A-Nachricht (angepasst an dieses Szenario) als Basis verwendet.


  DATA ld_keydatum TYPE sy-datum.
  DATA lf_anlage TYPE v_eanl.

* (24a - NEIN) Einzugsdatum (Beginn zum - Lieferbeginn) wird gefüllt
* (24c - MUSS) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* Diese Methode muss vor hole_keydatum durchgeführt werden.
  PERFORM movein_moveout_date USING sy-datum
                                    pd_endezum
                                    gc_category_abmeld
                           CHANGING pf_msgdata.

* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM hole_keydatum USING  pf_msgdata
                     CHANGING  ld_keydatum.


* (5b - MUSS) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM hole_ext_ui  USING pf_eideswtdoc
                             ld_keydatum
                    CHANGING pf_msgdata.


* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM hole_anlage USING pf_eideswtdoc_pod
                            ld_keydatum
                   CHANGING lf_anlage.


* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)


* (V2 - MUSS) Referenz zu einem Vorgang (Nur bei Antwortnachricht)
  PERFORM hole_refnummer CHANGING pf_msgdata.


* (4a - MUSS) Adresse Lieferstelle (Lieferadresse)
* 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM hole_vs USING pf_eideswtdoc
                        ld_keydatum
                        lf_anlage
               CHANGING pf_msgdata.


* (1a - Name des Anschlussnutzers - MUSS) + (1b - Anschrift des Kunden (Nur genutzt, wenn Kunde nicht an Lieferstelle wohnt) - KANN)
* GP (Geschäftspartner)
  PERFORM hole_gp USING pf_eideswtdoc_pod
                        ld_keydatum
                        gc_category_abmeld
                        gc_transreason_sperrung
                        space
                        pf_eideswtdoc-partner
                        space
               CHANGING pf_msgdata.


** (2a - KANN) Kundennummer des Kunden beim Lieferanten
*  PERFORM hole_exvko USING  pf_eideswtdoc
*                            ld_keydatum
*                            lf_anlage
*                            gc_category_abmeld
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.

*
** (2b - KANN) Kundennummer des Kunden (GP-Nummer oder Vertragskonto) bei dem Verteilnetzbetreiber
*** (2b - MUSS) Kundennummer des Kunden (GP-Nummer oder Vertragskonto) bei dem Verteilnetzbetreiber
*  PERFORM hole_vkonto USING pf_eideswtdoc
*                            ld_keydatum
*                            lf_anlage
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.


* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - KANN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - KANN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus
* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - KANN) Zählpunkt als Aggregationspunkt


* (7 - MUSS (außer bei Pauschalanlagen)) Zählernummer (Zählernummer / Eigentumsnummer)
  PERFORM hole_zaehler USING lf_anlage
                             ld_keydatum
                    CHANGING pf_msgdata.


* (8a - NEIN) Bisheriger Lieferant: VDEW-Code-Nummer
* (8b - NEIN) Kundennummer beim bisherigen Lieferanten
* (9 - KANN) Sonstige Hinweise zur Identifizierung


* (10 - MUSS) Antwortkategorien
* = answerstatus (wird unten gesetzt)


* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt


* (12 - NEIN) Art der Versorgung
* (13 - NEIN) Regelzone


* Bei Antwort müsste der bei der Anfrage übermittelte Wert einfach zurückgegeben werden.
* (14a - MUSS) Bilanzkreisbezeichnung (EICode Bilanzkreis)
*    PERFORM hole_bilanzkreis USING lf_eideswtdoc
*                                   ld_keydatum
*                          CHANGING lf_msgdata.
* (14a - MUSS) Bilanzkreisbezeichnung (EICode Bilanzkreis) (= Bilanzkreisverantwortlicher in den Nachrichtendaten = 11Xer-Nummer)
*      PERFORM hole_bilanzkreisverantw USING lf_eideswtdoc
*                                  CHANGING  lf_msgdata.


* (14b - KANN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - NEIN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB


** (14d - MUSS) Bilanzierungsgebiet
** EICode Bilanzierungsgebiet - Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
*  PERFORM hole_bilanzierunggebiet  USING pf_eideswtdoc
*                                         lf_anlage
*                                         ld_keydatum
*                                CHANGING pf_msgdata.


* (15 - NEIN) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt, handelt es sich um einen Haushaltskunden, sonst nicht.
* (16 - NEIN) Zählverfahren, wird aus dem IS-U bestimmt
* (17a - NEIN) Start Abrechnungsjahr (nur bei RLM)
* (17b - NEIN) Bisher gemessene Maximalleistung (nur bei RLM)
* (17c - NEIN) Reservenetzkapazität (bestellt)
* (17d - NEIN) Netzanschlusskapazität (nur bei RLM)
* (18a - NEIN) Standardlastprofilzuordnung
* (18b - NEIN) Jahresverbrauch
* (19a - NEIN) Profilschar
* (19b - NEIN) Spezifische Arbeit
* (19c - NEIN) Temperaturmessstelle
* (19d - NEIN) Verbrauchsaufteilung
* (19e - NEIN) Steuerungsart
* (19f - NEIN) Anlagetyp
* (19g - NEIN) Installierte Leistung
* (20 - KANN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird
* (21a/b - NEIN) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
* (22 - NEIN) Art der Messwerte (OBIS-Kennzahlen)


* (23a - NEIN) Spannungsebene der Anschlussstelle der Lieferstelle
* (23b - NEIN) Messung findet statt in
* (23c - NEIN) Verlustfaktor in Prozent
* (24b - NEIN) Änderung zum (Start der Änderung)
* (24d - NEIN) Ende zum (nächstmöglichen Termin)

*
** (24e - NEIN) Bilanzierungsbeginn
** (24f - MUSS) Bilanzierungsende
*  PERFORM hole_bilanz_beg_ende USING pf_eideswtdoc
*                                     ld_keydatum
*                                     gc_category_abmeld
*                            CHANGING pf_msgdata.


* (25a - NEIN) Status
* (25c - NEIN) Zahler der Netznutzung
* (26a - NEIN) Konzessionsabgabe (vorläufige Annahme) (Konzessionsabgabe S/AA/E)
* (26b - NEIN) Betrag (KA)

* ENDE 'Antwort zum Sperrauftrag' (E02A) (VNB an Lieferant)* ENDE 'Antwort zum Sperrauftrag' (E02A) (VNB an Lieferant)

ENDFORM.                    " HOLE_MSGDATA_VNBRESE02Z27
*&---------------------------------------------------------------------*
*&      Form  HOLE_MSGDATA_VNBRESE05
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BEGINNZUM  text
*      -->P_I_ENDEZUM  text
*      -->P_LD_SWITCHNUM  text
*      -->P_LF_EIDESWTDOC  text
*      -->P_LD_TRANSREASON  text
*      -->P_I_ANSWERSTATUS  text
*      -->P_LD_CATEGORY  text
*      -->P_LD_SWTVIEW  text
*      -->P_I_EMPF_SERVICEID  text
*      -->P_LD_MSGDATANUM  text
*      <--P_LF_MSGDATA  text
*      <--P_E_SERVICEID_OLD  text
*----------------------------------------------------------------------*
FORM hole_msgdata_vnbrese05  USING   pd_beginnzum      TYPE eidemoveindate
                                     pd_endezum        TYPE eidemoveoutdate
                                     pd_switchnum      TYPE eideswtnum
                                     pf_eideswtdoc     TYPE eideswtdoc
                                     pd_transreason    TYPE eideswtmdtran
                                     pd_answerstatus   TYPE eideswtmdstatus
                                     pd_category       TYPE eideswtmdcat
                                     pd_swtview        TYPE eideswtview
                                     pd_empf_serviceid TYPE eideswtdoc-service_prov_old
                                     pd_msgdatanum     TYPE eideswtmdnum
                            CHANGING pf_msgdata        TYPE eideswtmsgdata
                                     pd_serviceid_old  TYPE service_prov.


  DATA pf_anlage TYPE v_eanl.
  DATA pd_keydatum TYPE sy-datum.
* Löschen nicht mehr benötigter Felder

  CLEAR:
pf_msgdata-name_l,
pf_msgdata-name_f,
pf_msgdata-street,
pf_msgdata-housenr,
pf_msgdata-housenrext,
pf_msgdata-postcode,
pf_msgdata-city,
pf_msgdata-settlresp,
pf_msgdata-metmethod,
pf_msgdata-profile,
pf_msgdata-progyearcons,
pf_msgdata-maxdemand,
pf_msgdata-moveindate,
pf_msgdata-moveoutdate,
pf_msgdata-street_bu,
pf_msgdata-housenr_bu,
pf_msgdata-housenrext_bu,
pf_msgdata-postcode_bu,
pf_msgdata-city_bu.

** PhL 2016-04-06
*pf_msgdata-zz_formatversion,
*pf_msgdata-zz_verbrauchnt,
*pf_msgdata-zz_versart,
*pf_msgdata-zz_regelzone,
*pf_msgdata-zz_subbk,
*pf_msgdata-zz_aggkreis,
*pf_msgdata-zz_resnetzkap,
*pf_msgdata-zz_netzanschkap,
*pf_msgdata-zz_ablesung,
*pf_msgdata-zz_obiskennzahl,
*pf_msgdata-zz_gerwechsel,
*pf_msgdata-zz_zahler,
*pf_msgdata-zz_namelstabwre,
*pf_msgdata-zz_namefstabwre,
*pf_msgdata-zz_strabwre,
*pf_msgdata-zz_hsnrabwre,
*pf_msgdata-zz_hsnrergabwre,
*pf_msgdata-zz_plzabwre,
*pf_msgdata-zz_ortabwre,
*pf_msgdata-zz_strtabrjahr,
*pf_msgdata-zz_relmaxp,
*pf_msgdata-zz_profilschar,
*pf_msgdata-zz_speverbrht,
*pf_msgdata-zz_speverbrnt,
*pf_msgdata-zz_tempms,
*pf_msgdata-zz_verbrauftlg,
*pf_msgdata-zz_konzabgabe,
*pf_msgdata-zz_spebene,
*pf_msgdata-zz_spebenemess.
*/ PhL 2016-04-06


* Stichtag (wie Einzugsdatum, Auszugsdatum, Änderungsdatum) für weitere Selektionen
* Das Datum wird nicht direkt in die Message-Daten geschrieben, aber z. B. für die Bestimmung des Zählverfahren benötigt
  PERFORM hole_keydatum USING  pf_msgdata
                     CHANGING  pd_keydatum.

* (5b - MUSS (leer, wenn zu stornierende Nachricht keinen Zählpunkt hat)) Ext. Zählpunkt (Zählpunkt (lt. Metering-Code))
* Dieses Perform muss bereits an dieser Stelle ausgeführt werden, weil ich für die Anlage den Ext_ZP benötige
  PERFORM hole_ext_ui  USING pf_eideswtdoc
                             pd_keydatum
                    CHANGING pf_msgdata.

* Anlage
* Es wird nicht für die Message benötigt, sondern für die weitere Datenbeschaffung (Lieferadresse und Zählernummer)
  PERFORM hole_anlage USING pf_eideswtdoc-pod
                            pd_keydatum
                   CHANGING pf_anlage.

* (V1 - MUSS) Vorgangsidentifikationsnummer (pro Lieferung)

* (V2 - MUSS) Referenz zu einem Vorgang
  PERFORM hole_refnummer CHANGING pf_msgdata.

* (4a - KANN) Adresse Lieferstelle (Lieferadresse)
* Hü: 4a muss vor 1b berechnet werden (sonst fehlerhaft)
  PERFORM hole_vs USING pf_eideswtdoc
                        pd_keydatum
                        pf_anlage
               CHANGING pf_msgdata.

* (1a - Name des Anschlussnutzers - KANN) + (1b - Anschrift des Kunden (Nur genutzt, wenn Kunde nicht an Lieferstelle wohnt) - NEIN)
* GP (Geschäftspartner)
* Wir übernehmen die Angaben aus der Storno-Anfrage
*  PERFORM hole_gp USING pf_eideswtdoc-pod
*                        pd_keydatum
*                        pd_category
*                        pd_transreason
*                        pd_answerstatus
*                        pf_eideswtdoc-partner
*                        space
*               CHANGING pf_msgdata.

* (2a - KANN) Kundennummer des Kunden beim Lieferanten
*  PERFORM hole_exvko USING  pf_eideswtdoc
*                            pd_keydatum
*                            pf_anlage
*                            pd_category
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.

* (2b - KANN) Kundennummer des Kunden bei dem Verteilnetzbetreiber
* Diese Stelle kann auf beiden Mandanten durchlaufen werden
*  PERFORM hole_vkonto USING pf_eideswtdoc
*                            pd_keydatum
*                            pf_anlage
*                            pf_eideswtdoc-partner
*                   CHANGING pf_msgdata.

* (2c - KANN) Kundennummer des Kunden bei Dritter Partei
* (3a - NEIN) Name, (Vorname) oder Firmenname des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht
* (3b - NEIN) Anschrift des Netzanschlusseigentümers, sofern dieser vom Kunden abweicht, bestehend aus
* (4b - KANN) Ggf. Name einer 3. Partei in der Lieferstelle abweichend vom Anschlussnutzer (z. B. Mieter)
* (5a - NEIN) Zählpunkt als Aggregationspunkt

* (7 - KANN) Zählernummer (Zählernummer / Eigentumsnummer)
*  PERFORM hole_zaehler USING pf_anlage
*                             pd_keydatum
*                    CHANGING pf_msgdata.

* (8a - NEIN) Bisheriger Lieferant: VDEW-Code-Nummer
* (8b - NEIN) Kundennummer beim bisherigen Lieferanten
* (9 - KANN) Sonstige Hinweise zur Identifizierung

* (10 - MUSS) Antwortkategorien
* = answerstatus (wird unten gesetzt)


* (11 - MUSS) Transaktionsgrund
* Wird schon weiter oben gesetzt


* (12 - NEIN) Art der Versorgung
* Ansonsten wird dennoch ein Wert übernommen.
*  CLEAR pf_msgdata-zz_versart.


* (13 - NEIN) Regelzone


* (14a - NEIN) Bilanzkreisbezeichnung
* Ansonsten wird dennoch ein Wert übernommen.
  CLEAR pf_msgdata-settlresp.


* (14b - NEIN) Subbilanzkreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14c - NEIN) Aggregationskreisbezeichnung - Findet derzeit keine Verwendung aus Sicht VNB
* (14d - NEIN) Bilanzierungsgebiet; EICode Bilanzierungsgebiet - Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
* (15 - NEIN) Haushaltskunde gem. EnWG Wird dieses Segment mit dem Qualifier Z15 übermittelt, handelt es sich um einen Haushaltskunden, sonst nicht.
* (16 - NEIN) Zählverfahren, wird aus dem IS-U bestimmt
* (17a - NEIN) Start Abrechnungsjahr (nur bei RLM)
* (17b - NEIN) Bisher gemessene Maximalleistung (nur bei RLM)
* (17c - NEIN) Reservenetzkapazität (bestellt)
* (17d - NEIN) Netzanschlusskapazität (nur bei RLM)
* (18a - NEIN) Standardlastprofilzuordnung oder (Tarif-/Kunden-) Gruppenzuordnung bei analytischen Verfahren oder sonstige Zuordnung
* (18b - NEIN) Jahresverbrauch
* (19a - NEIN) Profilschar
* (19b - NEIN) Spezifische Arbeit
* (19c - NEIN) Temperaturmessstelle
* (19d - NEIN) Verbrauchsaufteilung
* (19e - NEIN) Steuerungsart
* (19f - NEIN) Anlagetyp
* (19g - NEIN) Installierte Leistung
* (20 - NEIN (nur rückwirkende mit Lieferende/Lieferbeginn)) Ankündigung, dass Endzählerstand per MSCONS übermittelt wird
* (21a/b - NEIN) Nächste turnusmäßige Ablesung (Ablesemonat inkl. Woche) empfohlene Variante 21b
* (22 - NEIN) Art der Messwerte (OBIS-Kennzahlen)
* (23a - NEIN (Kann bei Ablehnung)) Spannungsebene der Anschlussstelle der Lieferstelle
* (23b - NEIN (Kann bei Ablehnung)) Messung findet statt in
* (23c - NEIN) Verlustfaktor in Prozent
* (24a - NEIN) Einzugsdatum (Beginn zum - Lieferbeginn) wird gefüllt
* (24b - NEIN) Änderung zum (Start der Änderung)
* (24c - NEIN) Auszugsdatum (Ende zum - Lieferende) hier nicht gefordert, wird gecleared
* (24d - NEIN) Ende zum (nächstmöglichen Termin)
* (24e - NEIN) Bilanzierungsbeginn
* (24f - NEIN) Bilanzierungsende


* (25a - NEIN) Status
* Ansonsten wird dennoch ein Wert übernommen.
*  CLEAR pf_msgdata-zz_statusnenu.


* (25c - NEIN) Zahler der Netznutzung
* Ansonsten wird dennoch ein Wert übernommen.
** PhL 2016-04-06
*  CLEAR pf_msgdata-zz_zahler.
*/ PhL 2016-04-06

* (26a - NEIN) Konzessionsabgabe (vorläufige Annahme) (Konzessionsabgabe S/AA/E)
* (26b - NEIN) Betrag (KA)
* (27 - KANN) Bemerkungen (Vorgangsbezogen)

ENDFORM.                    " HOLE_MSGDATA_VNBRESE05
*&---------------------------------------------------------------------*
*&      Form  HOLE_NACHRICHTENTYPEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_CATEGORY  text
*      -->P_LD_ANFRAGE  text
*      -->P_LD_TRANSREASON  text
*      -->P_LD_SWTVIEW  text
*      <--P_LD_NACHRTYP_ALT  text
*      <--P_LD_NACHRTYP_NEU  text
*----------------------------------------------------------------------*
FORM hole_nachrichtentypen  USING    pd_category
                                     pd_anfrage
                                     pd_transreason
                                     pd_swtview
                            CHANGING pd_nachrtyp_alt
                                     pd_nachrtyp_neu.

  CASE pd_swtview.
    WHEN gc_swtview_vnb.

      CASE pd_transreason.
        WHEN gc_transreason_storno.

          CASE pd_category.
            WHEN  gc_category_anmeldung.
              MOVE gc_nachrtyp_vnbae01e05 TO pd_nachrtyp_neu.
              MOVE gc_nachrtyp_lnre01 TO pd_nachrtyp_alt.

            WHEN gc_category_abmeld.
              MOVE gc_nachrtyp_vnbae02e05 TO pd_nachrtyp_neu.
              MOVE gc_nachrtyp_lare02 TO pd_nachrtyp_alt.
          ENDCASE.

        WHEN OTHERS.

          CASE pd_category.
            WHEN gc_category_info.
              MOVE gc_nachrtyp_vnbre44 TO pd_nachrtyp_neu.
              CLEAR pd_nachrtyp_alt.

            WHEN gc_category_anmeldung.
              MOVE gc_nachrtyp_vnbae01 TO pd_nachrtyp_neu.
              MOVE gc_nachrtyp_lnre01 TO pd_nachrtyp_alt.

            WHEN gc_category_abmeld.
              IF pd_anfrage EQ gc_true.
                MOVE gc_nachrtyp_vnbre02 TO pd_nachrtyp_neu.
                CLEAR pd_nachrtyp_alt.

              ELSE.
                MOVE gc_nachrtyp_vnbae02 TO pd_nachrtyp_neu.
                MOVE gc_nachrtyp_lare02 TO pd_nachrtyp_alt.
              ENDIF.
          ENDCASE.
      ENDCASE.

    WHEN gc_swtview_ln.
      CASE pd_category.
        WHEN  gc_category_anmeldung.
          IF pd_anfrage EQ gc_true.
* Anmeldung zur Netznutzung
            MOVE gc_nachrtyp_lnre01 TO pd_nachrtyp_neu.
            CLEAR pd_nachrtyp_alt.
          ELSE.
* Antwort auf Anmeldung zur GuE
            MOVE gc_nachrtyp_lnae01 TO pd_nachrtyp_neu.
            MOVE gc_nachrtyp_vnbre01 TO pd_nachrtyp_alt.
          ENDIF.
        WHEN  gc_category_kuend .
          MOVE gc_nachrtyp_lnre35 TO pd_nachrtyp_neu.
          CLEAR pd_nachrtyp_alt.
      ENDCASE.

    WHEN gc_swtview_la.
      CASE pd_category.
        WHEN gc_category_abmeld.

          IF pd_anfrage EQ gc_true.
            MOVE gc_nachrtyp_lare02 TO pd_nachrtyp_neu.
            CLEAR pd_nachrtyp_alt.

          ELSE.
            MOVE gc_nachrtyp_laae02 TO pd_nachrtyp_neu.
            MOVE gc_nachrtyp_vnbre02 TO pd_nachrtyp_alt.
          ENDIF.

        WHEN gc_category_kuend.
          MOVE gc_nachrtyp_laae35 TO pd_nachrtyp_neu.
          MOVE gc_nachrtyp_lnre35 TO pd_nachrtyp_alt.

      ENDCASE.
  ENDCASE.
ENDFORM.                    " HOLE_NACHRICHTENTYPEN
*&---------------------------------------------------------------------*
*&      Form  SETZE_ANTWORTSTATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MSGDATA  text
*      -->P_LD_NACHRTYP_ALT  text
*      -->P_LD_NACHRTYP_NEU  text
*      <--P_LF_MSGDATA  text
*      <--P_LT_DDTEXT  text
*----------------------------------------------------------------------*
FORM setze_antwortstatus USING    pf_org_msgdata TYPE eideswtmsgdata
                                  pd_nachrtyp_alt TYPE c
                                  pd_nachrtyp_neu TYPE c
                         CHANGING pf_msgdata TYPE eideswtmsgdata
                                  pt_ddtext TYPE  zeagp_t_ddtext.

*  FIELD-SYMBOLS: <fs_field_org> TYPE ANY.            "Feld aus der ersten Nachricht
*  FIELD-SYMBOLS: <fs_field> TYPE ANY.                "Feld aus der zweiten Nachricht
*  FIELD-SYMBOLS: <fs_mussfeld_neu> TYPE ANY.
*  FIELD-SYMBOLS: <fs_mussfeld_alt> TYPE ANY.
*
*  DATA lt_dd03l TYPE TABLE OF dd03l.
*  DATA lf_dd03l TYPE dd03l.
*  DATA lf_zlwmsgstatus TYPE zlwmsgstatus.
*  DATA ld_flag_zustimm TYPE kennzx.
*  DATA ld_flag_ablehn TYPE kennzx.
*  DATA lf_status TYPE eideswtmdstatus.
*  DATA ld_status_zustimm.
*  DATA ld_mussfeld_alt TYPE c.
*  DATA ld_mussfeld_neu TYPE c.
*
** Übernommenen Antwortstatus in Sammelfeld übernehmen
*  IF NOT pf_msgdata-msgstatus IS INITIAL.
*    CALL FUNCTION 'Z_LW_SET_MSGSTATUS'
*      EXPORTING
*        x_status       = pf_msgdata-msgstatus
*      CHANGING
*        xy_msgdata     = pf_msgdata
*      EXCEPTIONS
*        invalid_status = 0
*        OTHERS         = 0.
*  ENDIF.
*
*
*  PERFORM check_status_zustimm USING pf_msgdata-msgstatus
*                            CHANGING ld_flag_zustimm
*                                     ld_flag_ablehn.
*
**einlesen der Felder der Struktur EIDESWTMSGDATA
*  SELECT * FROM dd03l INTO TABLE lt_dd03l
*   WHERE tabname = 'EIDESWTMSGDATA'
*     AND fieldname NE '.INCLUDE'
*   ORDER BY position.
*
*
*  DO.
*
*    ASSIGN COMPONENT sy-index OF
*           STRUCTURE pf_org_msgdata TO <fs_field_org>.
*    IF sy-subrc <> 0. EXIT. ENDIF.
*    ASSIGN COMPONENT sy-index OF
*          STRUCTURE pf_msgdata TO <fs_field>.
*    IF sy-subrc <> 0. EXIT. ENDIF.
*
** vergleichen
*    IF <fs_field> NE <fs_field_org>.
*      READ TABLE lt_dd03l INTO lf_dd03l INDEX sy-index.
*
*      SELECT SINGLE * FROM zlwmsgstatus INTO lf_zlwmsgstatus
*        WHERE feld = lf_dd03l-fieldname.
*
**      IF sy-subrc NE 0.
*      IF sy-subrc EQ 0.
*
*        CLEAR: ld_mussfeld_alt, ld_mussfeld_neu.
*
*        IF NOT pd_nachrtyp_neu IS INITIAL.
*          ASSIGN COMPONENT pd_nachrtyp_neu OF STRUCTURE lf_zlwmsgstatus TO <fs_mussfeld_neu>.
*          MOVE <fs_mussfeld_neu> TO ld_mussfeld_neu.
*        ENDIF.
*
*        IF NOT pd_nachrtyp_alt IS INITIAL.
*          ASSIGN COMPONENT pd_nachrtyp_alt OF STRUCTURE lf_zlwmsgstatus TO <fs_mussfeld_alt>.
*          MOVE <fs_mussfeld_alt> TO ld_mussfeld_alt.
*        ENDIF.
*
** Statusbehandlung nur, wenn Mussfeld in den Nachrichtendaten oder
** Kann-Feld und gefüllt.
*
*        CHECK    ld_mussfeld_neu EQ 'M'
*        OR (     ld_mussfeld_neu EQ 'K'
*        AND NOT <fs_field> IS INITIAL ).
*
** Statusbehandlung nur, wenn Mussfeld in den org. Nachrichtendaten oder
** Kann-Feld und gefüllt.
*
*        CHECK    ld_mussfeld_alt EQ 'M'
*        OR (     ld_mussfeld_alt EQ 'K'
*        AND NOT <fs_field_org> IS INITIAL ).            "Hü 18.06.2008
**        AND NOT <fs_field> IS INITIAL ).
*
*
*        CLEAR lf_status.
*
*        IF ld_flag_zustimm EQ gc_true.
*          MOVE lf_zlwmsgstatus-msgstatus_z TO lf_status.
*
*
** Ergänzung zur Befüllung des Bemerkungsfeldes
*          DATA l_ddtext TYPE as4text.
*
*          SELECT ddtext FROM dd04t INTO l_ddtext UP TO 1 ROWS
*            WHERE rollname = lf_dd03l-rollname
*            AND   ddlanguage = 'D'.
*          ENDSELECT.
*
*          IF sy-subrc = 0.
** Hier werden die KOmmentare vorgehalten, aber noch
** nicht in pd_comment geschrieben
**            pd_commenttxt = l_DDTEXT.
*            APPEND l_ddtext TO pt_ddtext.
*          ENDIF.
*
*        ELSEIF ld_flag_ablehn EQ gc_true.
*          "         MOVE lf_zlwmsgstatus-msgstatus_a TO lf_status.
*        ENDIF.
*
*        IF NOT lf_status IS INITIAL.
*          CALL FUNCTION 'Z_LW_SET_MSGSTATUS'
*            EXPORTING
*              x_status       = lf_status
*            CHANGING
*              xy_msgdata     = pf_msgdata
*            EXCEPTIONS
*              invalid_status = 0
*              OTHERS         = 0.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDDO.

ENDFORM.                    " setze_antwortstatus
*&---------------------------------------------------------------------*
*&      Form  BAUE_WBKOPF_SPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_SPERRDAT  text
*      -->P_LD_WIB_DAT  text
*      -->P_X_INT_UI  text
*      -->P_X_CATEGORY  text
*      -->P_X_TRANSREASON  text
*      -->P_LD_DISCREASON  text
*      <--P_LF_EIDESWTDOC  text
*      <--P_LD_RCODE  text
*----------------------------------------------------------------------*
FORM baue_wbkopf_sperre  USING    pd_sperrdatum TYPE dats
                                  pd_wib_datum TYPE dats
                                  pd_int_ui TYPE int_ui
                                  pd_category TYPE eideswtmsgdata-category
                                  pd_transreason TYPE eideswtmsgdata-transreason
                                  pd_discreason TYPE discreason
                         CHANGING pf_eideswtdoc TYPE eideswtdoc
                                  pd_rcode TYPE sy-subrc.

  DATA: ld_serviceid       TYPE service_prov,
        ld_invoicing_party TYPE invoicing_party,
        ld_gpart           TYPE bu_partner,
        ld_scenario        TYPE e_deregscenario,
        ld_sparte          TYPE sparte,
        i_keydat           TYPE datum,
        l_keydat           TYPE datum.

  CHECK pd_rcode LT 100.


* Zählpunkt
  MOVE pd_int_ui TO pf_eideswtdoc-pod.

* Switchtype                                             "Hü 10.06.2008 Änderung Wechselart
*  MOVE gc_swttype_end TO pf_eideswtdoc-switchtype.
  MOVE gc_swttype_spe TO pf_eideswtdoc-switchtype.

* Sperrdatum = Auszugsdatum
  MOVE pd_sperrdatum TO pf_eideswtdoc-moveoutdate.
  MOVE pd_sperrdatum TO pf_eideswtdoc-realmoveoutdate.

* WIB-Datum = Einzugsdatum
  MOVE pd_wib_datum TO pf_eideswtdoc-moveindate.
  MOVE pd_wib_datum TO pf_eideswtdoc-realmoveindate.

* Switchview
  IF sy-mandt EQ gc_netzmandant.
    MOVE gc_swtview_vnb TO pf_eideswtdoc-swtview.
  ELSE.
    MOVE gc_swtview_la TO pf_eideswtdoc-swtview.
  ENDIF.

  IF NOT pd_sperrdatum IS INITIAL.
    i_keydat = pd_sperrdatum.
  ELSE.
    i_keydat = pd_wib_datum.
  ENDIF.

* Servprov old = derzeitiger Liefert
  CALL FUNCTION '/ADESSO/EA_POD_DATA'
    EXPORTING
      i_int_ui          = pd_int_ui
      i_keydatum        = i_keydat
    IMPORTING
      e_serviceid       = ld_serviceid
      e_invoicing_party = ld_invoicing_party
      e_gpart           = ld_gpart
      e_scenario        = ld_scenario
      e_sparte          = ld_sparte.

  IF ld_serviceid IS INITIAL.
    IF pd_discreason <> '02'.
      MOVE gc_rcode_sperre_no_servprov TO pd_rcode.
    ELSE.

*Falls bei einer Ersatzversorgung nicht der alte Lieferant gefunden werden kann,
*als Keydatum einen Tag früher nehmen
      l_keydat = i_keydat.
      COMPUTE i_keydat = l_keydat - 1.

* Servprov old = derzeitiger Liefert
      CALL FUNCTION '/ADESSO/EA_POD_DATA'
        EXPORTING
          i_int_ui          = pd_int_ui
          i_keydatum        = i_keydat
        IMPORTING
          e_serviceid       = ld_serviceid
          e_invoicing_party = ld_invoicing_party
          e_gpart           = ld_gpart
          e_scenario        = ld_scenario.

    ENDIF.
  ENDIF.

  IF ( pd_transreason EQ 'Z27' AND pd_category EQ 'E44' ) .
    MOVE ld_invoicing_party TO  pf_eideswtdoc-service_prov_old.
  ELSE.
    MOVE ld_serviceid TO  pf_eideswtdoc-service_prov_old.
  ENDIF.

* Servprov new - Leer
  CLEAR pf_eideswtdoc-service_prov_new.

* Partner
  IF ld_gpart IS INITIAL.
    IF pd_discreason <> '02'.
      MOVE gc_rcode_sperre_no_gpart TO pd_rcode.
    ENDIF.
  ENDIF.

  MOVE ld_gpart TO pf_eideswtdoc-partner.

*  Netzbetreiber
  PERFORM hole_netzbetreiber_pod USING pd_int_ui
                                       i_keydat
                              CHANGING pf_eideswtdoc-distributor.

  IF pf_eideswtdoc-distributor IS INITIAL.
    IF pd_discreason <> '02'.
      MOVE gc_rcode_sperre_no_distributor TO pd_rcode.
    ENDIF.
  ENDIF.

* Startszenario
  MOVE ld_scenario TO pf_eideswtdoc-startscenario.
* Zielszenario
  MOVE ld_scenario TO pf_eideswtdoc-targetscenario.

* Spartentyp
  PERFORM hole_spartentyp USING pd_int_ui
                                i_keydat
                       CHANGING pf_eideswtdoc.

  IF pf_eideswtdoc-spartyp IS INITIAL.
    IF pd_discreason <> '02'.
      MOVE gc_rcode_sperre_no_spartentyp TO pd_rcode.
    ENDIF.
  ENDIF.

ENDFORM.                    " BAUE_WBKOPF_SPERRE
*&---------------------------------------------------------------------*
*&      Form  HOLE_NETZBETREIBER_POD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_INT_UI  text
*      -->P_I_KEYDAT  text
*      <--P_PF_EIDESWTDOC_DISTRIBUTOR  text
*----------------------------------------------------------------------*
FORM hole_netzbetreiber_pod   USING pd_int_ui TYPE int_ui
                                    pd_keydatum LIKE sy-datum
                           CHANGING pd_distributor TYPE eideserprov_dist.


  CALL FUNCTION '/ADESSO/EA_POD_DATA'
    EXPORTING
      i_int_ui      = pd_int_ui
      i_keydatum    = pd_keydatum
    IMPORTING
      e_distributor = pd_distributor.

ENDFORM.                    " hole_netzbetreiber_pod
*&---------------------------------------------------------------------*
*&      Form  HOLE_SPARTENTYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_INT_UI  text
*      -->P_I_KEYDAT  text
*      <--P_PF_EIDESWTDOC  text
*----------------------------------------------------------------------*
FORM hole_spartentyp  USING    pd_int_ui TYPE int_ui
                               pd_keydate TYPE dats
                      CHANGING pf_eideswtdoc TYPE eideswtdoc.

  DATA ld_sparte TYPE sparte.
  DATA lf_tespt TYPE tespt.

  CALL FUNCTION '/ADESSO/EA_POD_DATA'
    EXPORTING
      i_int_ui   = pd_int_ui
      i_keydatum = pd_keydate
    IMPORTING
      e_sparte   = ld_sparte.

  SELECT SINGLE * FROM tespt
    INTO lf_tespt
   WHERE sparte = ld_sparte.

  CHECK sy-subrc EQ 0.

  MOVE lf_tespt-spartyp TO pf_eideswtdoc-spartyp.

ENDFORM.                    " HOLE_SPARTENTYP
*&---------------------------------------------------------------------*
*&      Form  HOLE_ABLEINH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_ABLEINH  text
*----------------------------------------------------------------------*
FORM hole_ableinh  USING    pd_keydatum TYPE dats
                            pd_int_ui TYPE int_ui
                   CHANGING pd_ableinh TYPE ableinh.

  DATA ld_anlage TYPE anlage.
  DATA lf_v_eanl TYPE v_eanl.

  CLEAR pd_ableinh.

  PERFORM hole_anlage_int_ui USING pd_keydatum
                                       pd_int_ui
                              CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

  CALL FUNCTION 'ISU_DB_EANL_SELECT'
    EXPORTING
      x_anlage           = ld_anlage
      x_keydate          = pd_keydatum
*       X_ACTUAL           =
    IMPORTING
      y_v_eanl           = lf_v_eanl
   EXCEPTIONS
     not_found          = 1
     system_error       = 2
     invalid_date       = 3
     OTHERS             = 4
            .
  CHECK sy-subrc EQ 0.
  MOVE lf_v_eanl-ableinh TO pd_ableinh.

ENDFORM.                    " HOLE_ABLEINH
*&---------------------------------------------------------------------*
*&      Form  HOLE_AKLASSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_AKLASSE  text
*----------------------------------------------------------------------*
FORM hole_aklasse  USING    pd_keydatum LIKE sy-datum
                             pd_int_ui TYPE int_ui
                    CHANGING pd_aklasse TYPE aklasse.

  DATA ld_anlage TYPE anlage.
  DATA lf_v_eanl TYPE v_eanl.

  CLEAR pd_aklasse.


  PERFORM hole_anlage_int_ui USING pd_keydatum
                                       pd_int_ui
                              CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

  CALL FUNCTION 'ISU_DB_EANL_SELECT'
    EXPORTING
      x_anlage           = ld_anlage
      x_keydate          = pd_keydatum
*       X_ACTUAL           =
    IMPORTING
      y_v_eanl           = lf_v_eanl
   EXCEPTIONS
     not_found          = 1
     system_error       = 2
     invalid_date       = 3
     OTHERS             = 4
            .
  CHECK sy-subrc EQ 0.
  MOVE lf_v_eanl-aklasse TO pd_aklasse.


ENDFORM.                    " HOLE_TARIFTYP
*&---------------------------------------------------------------------*
*&      Form  HOLE_ANZAHL_ZW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_ANZAHL_ZW  text
*----------------------------------------------------------------------*
FORM hole_anzahl_zw USING pd_keydatum TYPE sy-datum
                          pd_int_ui TYPE int_ui
                 CHANGING pd_anzahl_zw TYPE i.

* Anlage besorgen

  DATA: lf_euiinstln    TYPE euiinstln,
        lt_euiinstln TYPE ieuiinstln,
        ld_logikzw   TYPE logikzw,
        lt_logikzw TYPE TABLE OF logikzw,
        lf_etdz TYPE etdz.

  CLEAR pd_anzahl_zw.

  CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
    EXPORTING
      x_int_ui            = pd_int_ui
      x_dateto            = pd_keydatum
*     X_TIMETO            = '235959'
      x_datefrom          = pd_keydatum
*     X_TIMEFROM          = '000000'
      x_only_dereg        = 'X'
*     X_ONLY_TECH         = ' '
   IMPORTING
      y_euiinstln         = lt_euiinstln
    EXCEPTIONS
      not_found           = 1
      system_error        = 2
      not_qualified       = 3
      OTHERS              = 4
            .
  CHECK sy-subrc EQ 0.

  READ TABLE lt_euiinstln INTO lf_euiinstln INDEX 1.

* Logische Zählwerke zur Anlage besorgen

  SELECT logikzw
    FROM easts INTO TABLE lt_logikzw
   WHERE anlage EQ lf_euiinstln-anlage
     AND bis GE pd_keydatum
     AND ab LE pd_keydatum.

  CHECK sy-subrc EQ 0.

  SORT lt_logikzw.
  DELETE ADJACENT DUPLICATES FROM lt_logikzw.

* Prüfen, auf zählende ZW
  LOOP AT lt_logikzw INTO ld_logikzw.

    SELECT SINGLE * FROM etdz
      INTO lf_etdz WHERE logikzw = ld_logikzw.

    IF lf_etdz-kzmessw EQ gc_false.
      ADD 1 TO pd_anzahl_zw.
    ENDIF.

  ENDLOOP.


ENDFORM.                    " hole_anzahl_zw
*&---------------------------------------------------------------------*
*&      Form  HOLE_DISCNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_INT_UI  text
*      -->P_I_KEYDATUM  text
*      -->P_E_ANLAGE  text
*      <--P_E_DISCNO  text
*----------------------------------------------------------------------*
FORM hole_discno  USING i_int_ui TYPE eideswtdoc-pod
                        i_datum  TYPE sy-datum
                        i_anlage TYPE anlage
                        CHANGING y_discno type discno.
  DATA: it_zedmb_discno TYPE ECRM_EDISCNO_TAB,
        wa_discno       TYPE ECRM_EDISCNO,
        wa_ediscdoc     TYPE ediscdoc.
  CALL FUNCTION '/ADESSO/EA_FIND_GESPERRTE_ANLA'
    EXPORTING
      i_int_ui                  = i_int_ui
      i_datum                   = i_datum
   IMPORTING
*     E_ANLAGEN_GESPERRT        =
*     E_ANLAGEN_SPERREING       =
     e_discno                  = it_zedmb_discno
*     E_SPERREN                 =
   EXCEPTIONS
     no_pod                    = 1
     no_anlagen                = 2
     OTHERS                    = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  SORT it_zedmb_discno BY discno DESCENDING.
  READ TABLE it_zedmb_discno INDEX 1 INTO wa_discno.
  y_discno = wa_discno-discno.

* bei Sperrbelegstatus 1, 30 und 99 kann kein Sperrbeleg ermittelt werden,
* daher wird verucht, den aktuellste Sperrbeleg, in dem die Anlage als Bezugsobjekt hinterlegt ist, zu lesen
  IF NOT i_anlage IS INITIAL.
    SELECT * FROM ediscdoc INTO wa_ediscdoc
                  WHERE refobjtype EQ 'INSTLN'
                    AND refobjkey EQ i_anlage
                    AND status NE '99'
      ORDER BY discno DESCENDING.
      IF sy-subrc EQ 0.
        y_discno =  wa_ediscdoc-discno.
      ENDIF.
    ENDSELECT.
  ENDIF.
ENDFORM.                    " HOLE_DISCNO
*&---------------------------------------------------------------------*
*&      Form  HOLE_DISTRIBUTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_DISTRIBUTOR  text
*----------------------------------------------------------------------*
FORM hole_distributor USING    pd_keydatum TYPE sy-datum
                               pd_int_ui TYPE int_ui
                      CHANGING pd_distributor TYPE service_prov_dist.


  DATA ld_grid_id TYPE grid_id.


  CLEAR pd_distributor.

  SELECT SINGLE grid_id
    FROM euigrid
    INTO ld_grid_id
   WHERE int_ui = pd_int_ui
     AND datefrom LE pd_keydatum
     AND dateto GE pd_keydatum.

  CHECK sy-subrc EQ 0.

  SELECT SINGLE distributor
    FROM egridh
    INTO pd_distributor
   WHERE grid_id = ld_grid_id
     AND bis GE pd_keydatum
     AND ab LE pd_keydatum.

ENDFORM.                    " hole_distributor
*&---------------------------------------------------------------------*
*&      Form  HOLE_EINZDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_EINZDAT  text
*----------------------------------------------------------------------*
FORM hole_einzdat  USING    pd_keydatum TYPE dats
                            pd_int_ui TYPE int_ui
                   CHANGING pd_einzdat TYPE dats.
  DATA lf_ever TYPE ever.

  CLEAR pd_einzdat.

  PERFORM hole_pod_vertrag  USING pd_keydatum
                                  pd_int_ui
                         CHANGING lf_ever-vertrag.


  SELECT SINGLE * FROM ever INTO lf_ever
   WHERE vertrag = lf_ever-vertrag.

  CHECK sy-subrc EQ 0.

  MOVE lf_ever-einzdat TO pd_einzdat.

ENDFORM.                    " HOLE_EINZDAT
*&---------------------------------------------------------------------*
*&      Form  HOLE_POD_VERTRAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PD_KEYDATUM  text
*      -->P_PD_INT_UI  text
*      <--P_LF_EVER_VERTRAG  text
*----------------------------------------------------------------------*
FORM hole_pod_vertrag  USING    pd_keydatum TYPE sy-datum
                                pd_int_ui TYPE int_ui
                       CHANGING pd_vertrag TYPE vertrag.

  DATA ld_anlage TYPE anlage.

  PERFORM hole_anlage_int_ui USING pd_keydatum
                                   pd_int_ui
                          CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.
  SELECT SINGLE vertrag FROM ever INTO pd_vertrag
   WHERE anlage = ld_anlage
     AND einzdat LE pd_keydatum
     AND auszdat GE pd_keydatum.

ENDFORM.                    " HOLE_POD_VERTRAG
*&---------------------------------------------------------------------*
*&      Form  HOLE_EQUNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_EQUNR  text
*----------------------------------------------------------------------*
FORM hole_equnr  USING    px_keydatum TYPE dats
                          px_int_ui TYPE int_ui
                 CHANGING py_equnr TYPE equnr.

  DATA ld_anlage TYPE anlage.
  DATA ld_logiknr TYPE logiknr.
  DATA:  BEGIN OF lf_logikzw ,
           logikzw TYPE logikzw,
         END OF lf_logikzw.
  DATA lt_logikzw LIKE TABLE OF lf_logikzw.
  DATA lt_etdz TYPE TABLE OF etdz.
  DATA ld_equnr TYPE equnr.

* Anlage
  PERFORM hole_anlage_int_ui USING px_keydatum
                                   px_int_ui
                          CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

* Alle Zählwerke einlesen
  SELECT logikzw FROM easts
    INTO TABLE lt_logikzw
  WHERE anlage EQ ld_anlage
    AND ab     LE px_keydatum
    AND bis    GE px_keydatum.

* Nur Zählwerke mit OBIS-Kennziffern übriglassen
  SELECT * FROM etdz INTO TABLE lt_etdz
     FOR ALL ENTRIES IN lt_logikzw
   WHERE logikzw = lt_logikzw-logikzw
     AND kennziff NE space
     AND ab     LE px_keydatum
     AND bis    GE px_keydatum.


  SELECT logiknr
    INTO ld_logiknr
    FROM eastl
   WHERE anlage = ld_anlage
     AND ab LE px_keydatum
     AND bis GE px_keydatum.
* Es werden nur Geräte betrachtet, die auch Zählwerke mit
* OBIS-Kennziffern haben

    SELECT SINGLE equnr
      INTO ld_equnr
      FROM egerh
     WHERE logiknr = ld_logiknr
       AND ab LE px_keydatum
       AND bis GE px_keydatum.

* Wenn nicht gefunden, probieren wir den Geräteinfosatz
    IF sy-subrc NE 0.
      SELECT SINGLE equnr
      INTO ld_equnr
      FROM egerr
     WHERE logiknr = ld_logiknr
       AND ab LE px_keydatum
       AND bis GE px_keydatum.
    ENDIF.

* Prüfe, ob es ein Gerät mit Zählwerken ist
    READ TABLE lt_etdz WITH KEY equnr = ld_equnr
    TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      MOVE ld_equnr TO py_equnr.
      EXIT.
    ENDIF.

  ENDSELECT.

ENDFORM.                    " HOLE_EQUNR
*&---------------------------------------------------------------------*
*&      Form  HOLE_GPART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_INT_UI  text
*      -->P_I_KEYDATUM  text
*      <--P_E_GPART  text
*----------------------------------------------------------------------*
FORM hole_gpart USING    pd_int_ui TYPE int_ui
                         pd_keydatum TYPE sy-datum
                CHANGING pd_gpart TYPE bu_partner.

  DATA ld_ext_ui TYPE ext_ui.
  DATA lt_inst TYPE TABLE OF bapiisupodinstln.
  DATA lf_inst TYPE bapiisupodinstln.
  DATA lt_eanl TYPE v_eanl_tab.
  DATA lf_eanl TYPE v_eanl.


** Ext. Zählpunkt besorgen
  SELECT SINGLE ext_ui INTO ld_ext_ui
    FROM euitrans
   WHERE int_ui = pd_int_ui
     AND dateto GE pd_keydatum
     AND datefrom LE pd_keydatum.
** Anlagen zum ZP besorgen
  CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
    EXPORTING
      pointofdelivery = ld_ext_ui
      keydate         = pd_keydatum
    TABLES
      installation    = lt_inst.


  CHECK NOT lt_inst IS INITIAL.

  LOOP AT lt_inst INTO lf_inst.
    MOVE lf_inst-installation TO lf_eanl-anlage.
    APPEND lf_eanl TO lt_eanl.
  ENDLOOP.

  CALL FUNCTION 'ISU_DB_EANL_FORALL'
    EXPORTING
      x_actual         = 'X'
    TABLES
      t_v_eanl         = lt_eanl
    EXCEPTIONS
      not_found        = 1
      system_error     = 2
      invalid_interval = 3
      OTHERS           = 4.
  CHECK sy-subrc EQ 0.

* Wir versuchen es mit der Lieferanlage
  PERFORM gib_anlage USING lt_eanl
                           '01'
                           pd_keydatum
                  CHANGING lf_eanl.

* Gibt es hier einen Partner
  PERFORM hole_gpart_zu_eanl USING lf_eanl
                                   pd_keydatum
                          CHANGING pd_gpart.

  CHECK pd_gpart IS INITIAL.
* Wir versuchen es mit der netzanlage
  PERFORM gib_anlage USING lt_eanl
                           '02'
                           pd_keydatum
                  CHANGING lf_eanl.

* Gibt es hier einen Partner
  PERFORM hole_gpart_zu_eanl USING lf_eanl
                                   pd_keydatum
                          CHANGING pd_gpart.


ENDFORM.                    " hole_gpart
*&---------------------------------------------------------------------*
*&      Form  GIB_ANLAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_EANL  text
*      -->P_4125   text
*      -->P_PD_KEYDATUM  text
*      <--P_LF_EANL  text
*----------------------------------------------------------------------*
FORM gib_anlage USING    pt_eanl TYPE v_eanl_tab
                         p_intcode TYPE intcode
                         pd_keydate TYPE sy-datum
                CHANGING pf_eanl TYPE v_eanl.

  DATA lf_eanl TYPE v_eanl.
  DATA lf_tecde TYPE tecde.

  CLEAR pf_eanl.

  LOOP AT pt_eanl INTO lf_eanl.
* Wir brauchen nur die gültigen Anlagenzeitscheiben zum
* Keydate
    CHECK lf_eanl-ab LE pd_keydate AND lf_eanl-bis GE pd_keydate.

    CALL FUNCTION 'ISU_DB_TECDE_SINGLE'
      EXPORTING
        x_service    = lf_eanl-service
      IMPORTING
        y_service    = lf_tecde
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    CHECK sy-subrc EQ 0.
    IF lf_tecde-intcode EQ p_intcode.
      MOVE lf_eanl TO pf_eanl.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " gib_anlage
*&---------------------------------------------------------------------*
*&      Form  HOLE_GPART_ZU_EANL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LF_EANL  text
*      -->P_PD_KEYDATUM  text
*      <--P_PD_GPART  text
*----------------------------------------------------------------------*
FORM hole_gpart_zu_eanl USING    pf_eanl TYPE v_eanl
                                 pd_keydatum TYPE sy-datum
                        CHANGING pd_gpart TYPE bu_partner.


  DATA lt_ever TYPE ieever.
  DATA lf_ever TYPE ever.

  MOVE pf_eanl-anlage TO lf_ever-anlage.
  APPEND lf_ever TO lt_ever.

  CALL FUNCTION 'ISU_DB_EVER_SELECT_ANLAGE'
    EXPORTING
      x_actual         = 'X'
    TABLES
      txy_ever         = lt_ever
    EXCEPTIONS
      not_found        = 1
      system_error     = 2
      interval_invalid = 3
      OTHERS           = 4.

  CHECK sy-subrc EQ 0.

  LOOP AT lt_ever INTO lf_ever.
    IF lf_ever-einzdat LE pd_keydatum
    AND lf_ever-auszdat GE pd_keydatum.
* Wir haben den Vertrag
      SELECT SINGLE gpart FROM fkkvkp INTO pd_gpart
       WHERE vkont = lf_ever-vkonto.
    ENDIF.
  ENDLOOP.



ENDFORM.                    " hole_gpart_zu_eanl
*&---------------------------------------------------------------------*
*&      Form  HOLE_GUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_GUE  text
*----------------------------------------------------------------------*
FORM hole_gue  USING    pd_keydatum TYPE dats
                        pd_int_ui TYPE int_ui
               CHANGING pd_gue TYPE /ADESSO/SPT_LWVERSART.

  DATA lf_ever TYPE ever.
  CLEAR pd_gue.

  PERFORM hole_pod_vertrag  USING pd_keydatum
                                  pd_int_ui
                         CHANGING lf_ever-vertrag.

  SELECT SINGLE * FROM ever INTO lf_ever
   WHERE vertrag = lf_ever-vertrag.

  CHECK sy-subrc EQ 0.

** PhL 2016-04-06 - Lösung noch ausstehend
*  MOVE lf_ever-zzgue TO pd_gue.
*/ PhL 2016-04-06

ENDFORM.                    " HOLE_GUE
*&---------------------------------------------------------------------*
*&      Form  HOLE_KONDIGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_KONDIGR  text
*----------------------------------------------------------------------*
FORM hole_kondigr  USING    pd_keydatum TYPE dats
                            pd_int_ui TYPE int_ui
                   CHANGING pd_kondigr TYPE kondigr.

  DATA ld_anlage TYPE anlage.
  DATA lf_eastl TYPE eastl.

  CLEAR pd_kondigr.

  PERFORM hole_anlage_int_ui USING pd_keydatum
                                   pd_int_ui
                          CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

  SELECT SINGLE * FROM eastl INTO lf_eastl
                            WHERE anlage = ld_anlage
                              AND ab LE pd_keydatum
                              AND bis GE pd_keydatum.

  CHECK sy-subrc EQ 0.

  MOVE lf_eastl-kondigr TO pd_kondigr.

ENDFORM.                    " HOLE_KONDIGR
*&---------------------------------------------------------------------*
*&      Form  HOLE_POD_VKONTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_VKONTO  text
*----------------------------------------------------------------------*
FORM hole_pod_vkonto  USING    px_keydatum TYPE sy-datum
                               px_int_ui   TYPE int_ui
                      CHANGING py_vkonto   TYPE vkont_kk.

  DATA ld_vertrag TYPE vertrag.
* ZP=> Anlage => Vertrag => Vkonto

  PERFORM hole_pod_vertrag  USING px_keydatum
                                  px_int_ui
                         CHANGING ld_vertrag.

  SELECT SINGLE vkonto FROM ever INTO py_vkonto
   WHERE vertrag = ld_vertrag.

  IF sy-subrc NE 0.
    CLEAR py_vkonto.
  ENDIF.
ENDFORM.                    " HOLE_POD_VKONTO
*&---------------------------------------------------------------------*
*&      Form  HOLE_SCENARIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_SCENARIO  text
*----------------------------------------------------------------------*
FORM hole_scenario  USING    pd_keydatum LIKE sy-datum
                             pd_int_ui TYPE int_ui
                    CHANGING pd_scenario TYPE e_deregscenario.

  DATA lf_ederegscenario TYPE ederegscenario.

  CLEAR pd_scenario.

  CALL FUNCTION 'ISU_O_SCENARIO_AT_POD_GET'
   EXPORTING
    x_int_ui            = pd_int_ui
    x_keydate           = pd_keydatum
  IMPORTING
    y_scenario          = lf_ederegscenario
*   Y_SCENARIOTXT       =
  EXCEPTIONS
    general_fault       = 1
    OTHERS              = 2
 .

  IF sy-subrc EQ 0.
    MOVE lf_ederegscenario-scenario TO pd_scenario.
  ENDIF.

ENDFORM.                    " hole_scenario
*&---------------------------------------------------------------------*
*&      Form  HOLE_SERVICEID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_SERVICEID  text
*      <--P_E_INVOICING_PARTY  text
*----------------------------------------------------------------------*
FORM hole_serviceid  USING    pd_keydatum type dats
                              pd_int_ui type int_ui
                     CHANGING pd_serviceid  type eservprov-serviceid
                              pd_invoicing_party type eservprov-serviceid.


  DATA: lf_euiinstln    TYPE euiinstln,
        lt_euiinstln TYPE ieuiinstln,
        lf_ever         TYPE ever,
        lt_ever      TYPE ieever.

  CALL FUNCTION 'ISU_DB_EUIINSTLN_SELECT'
    EXPORTING
      x_int_ui            = pd_int_ui
       x_dateto            = pd_keydatum
*     X_TIMETO            = '235959'
       x_datefrom          = pd_keydatum
*     X_TIMEFROM          = '000000'
      x_only_dereg        = 'X'
*     X_ONLY_TECH         = ' '
   IMPORTING
      y_euiinstln         = lt_euiinstln
    EXCEPTIONS
      not_found           = 1
      system_error        = 2
      not_qualified       = 3
      OTHERS              = 4
            .
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT lt_euiinstln INTO lf_euiinstln.
    lf_ever-anlage  = lf_euiinstln-anlage.
    lf_ever-einzdat = pd_keydatum.
    lf_ever-auszdat = pd_keydatum.
    APPEND lf_ever TO lt_ever.
  ENDLOOP.

  CALL FUNCTION 'ISU_DB_EVER_SELECT_ANLAGE'
*   EXPORTING
*     X_ACTUAL               =
*   IMPORTING
*     Y_COUNT                =
    TABLES
      txy_ever               = lt_ever
    EXCEPTIONS
      not_found              = 1
      system_error           = 2
      interval_invalid       = 3
      OTHERS                 = 4
            .
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT lt_ever INTO lf_ever.
    IF NOT lf_ever-serviceid IS INITIAL.
      MOVE lf_ever-serviceid TO pd_serviceid.
    ENDIF.
    IF NOT lf_ever-invoicing_party IS INITIAL.
      MOVE lf_ever-invoicing_party TO pd_invoicing_party.
    ENDIF.
    EXIT.
  ENDLOOP.
ENDFORM.                    " hole_serviceid
*&---------------------------------------------------------------------*
*&      Form  HOLE_SPARTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_SPARTE  text
*----------------------------------------------------------------------*
FORM hole_sparte  USING    pd_keydatum LIKE sy-datum
                           pd_int_ui TYPE int_ui
                  CHANGING pd_sparte TYPE sparte.

  DATA ld_anlage TYPE anlage.
  DATA lf_v_eanl TYPE v_eanl.

  CLEAR pd_sparte.

  PERFORM hole_anlage_int_ui USING pd_keydatum
                                       pd_int_ui
                              CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

  CALL FUNCTION 'ISU_DB_EANL_SELECT'
    EXPORTING
      x_anlage           = ld_anlage
      x_keydate          = pd_keydatum
*       X_ACTUAL           =
    IMPORTING
      y_v_eanl           = lf_v_eanl
   EXCEPTIONS
     not_found          = 1
     system_error       = 2
     invalid_date       = 3
     OTHERS             = 4
            .
  CHECK sy-subrc EQ 0.
  MOVE lf_v_eanl-sparte TO pd_sparte.

ENDFORM.                    " HOLE_SPARTE
*&---------------------------------------------------------------------*
*&      Form  HOLE_TARIFTYP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_TARIFTYP  text
*----------------------------------------------------------------------*
FORM hole_tariftyp  USING    pd_keydatum LIKE sy-datum
                             pd_int_ui TYPE int_ui
                    CHANGING pd_tariftyp TYPE tariftyp_anl.

  DATA ld_anlage TYPE anlage.
  DATA lf_v_eanl TYPE v_eanl.

  CLEAR pd_tariftyp.


  PERFORM hole_anlage_int_ui USING pd_keydatum
                                       pd_int_ui
                              CHANGING ld_anlage.

  CHECK NOT ld_anlage IS INITIAL.

  CALL FUNCTION 'ISU_DB_EANL_SELECT'
    EXPORTING
      x_anlage           = ld_anlage
      x_keydate          = pd_keydatum
*       X_ACTUAL           =
    IMPORTING
      y_v_eanl           = lf_v_eanl
   EXCEPTIONS
     not_found          = 1
     system_error       = 2
     invalid_date       = 3
     OTHERS             = 4
            .
  CHECK sy-subrc EQ 0.
  MOVE lf_v_eanl-tariftyp TO pd_tariftyp.


ENDFORM.                    " HOLE_TARIFTYP
*&---------------------------------------------------------------------*
*&      Form  HOLE_VSTELLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEYDATUM  text
*      -->P_E_INT_UI  text
*      <--P_E_VSTELLE  text
*----------------------------------------------------------------------*
FORM hole_vstelle  USING    px_keydatum TYPE dats
                            px_int_ui   TYPE int_ui
                   CHANGING py_vstelle  TYPE vstelle.

  DATA ld_anlage TYPE anlage.

  PERFORM hole_anlage_int_ui USING px_keydatum
                                   px_int_ui
                          CHANGING ld_anlage.

  SELECT SINGLE vstelle INTO py_vstelle
    FROM eanl
   WHERE anlage = ld_anlage.

ENDFORM.                    " HOLE_VSTELLE
*&---------------------------------------------------------------------*
*&      Form  CREATE_FROM_MSGDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LF_EIDESWTDOC  text
*      -->P_LF_EIDESWTMSGDATA  text
*      -->P_LT_MSGDATACO  text
*      <--P_LD_RCODE  text
*      <--P_Y_SWITCHNUM  text
*----------------------------------------------------------------------*
FORM create_from_msgdata  USING    pf_eideswtdoc TYPE eideswtdoc
                                   pf_eideswtmsgdata TYPE eideswtmsgdata
                                   pt_msgdataco TYPE teideswtmsgdataco
                 CHANGING pd_rcode LIKE sy-subrc
                          pd_switchnum TYPE eideswtnum.



  CHECK pd_rcode LT 100.

  DATA ld_msgdatanum    TYPE eideswtmdnum.

  CALL METHOD cl_isu_switchdoc=>create_from_msg
    EXPORTING
      x_switchdocdata   = pf_eideswtdoc
      x_msgdata         = pf_eideswtmsgdata
      x_tmsgdatacomment = pt_msgdataco
      x_no_commit       = gc_true
      x_create_new      = abap_true
    IMPORTING
      y_switchnum       = pd_switchnum
      y_msgdatanum      = ld_msgdatanum
    EXCEPTIONS
      general_fault     = 1
      foreign_lock      = 2
      pod_missing       = 3
      not_authorized    = 4
      OTHERS            = 5.


  CASE sy-subrc.
    WHEN 0.
      COMMIT WORK.
    WHEN 1.
      MOVE gc_rcode_wb_general_fault TO pd_rcode.
    WHEN 2.
      MOVE gc_rcode_wb_foreign_lock TO pd_rcode.
    WHEN 3.
      MOVE gc_rcode_wb_pod_missing TO pd_rcode.
    WHEN 4.
      MOVE gc_rcode_wb_not_authorized TO pd_rcode.
    WHEN 5.
      MOVE gc_rcode_wb_others TO pd_rcode.
  ENDCASE.


ENDFORM.                    " create_from_msgdata
*&---------------------------------------------------------------------*
*&      Form  SET_ERFOLG_LEER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_INT_UI  text
*      -->P_LD_SPERRDAT  text
*      -->P_Y_SWITCHNUM  text
*      -->P_0204   text
*      -->P_X_COMMIT  text
*----------------------------------------------------------------------*
FORM set_erfolg_leer  USING    pd_int_ui TYPE int_ui
                               pd_moveindat TYPE dats
                               pd_switchnum TYPE eideswtnum
                               pd_art TYPE /ADESSO/SPT_LW_ART_EINZ
                               x_commit TYPE cose_commit.

  DATA lt_zlwvertrag_leer TYPE TABLE OF /ADESSO/SPT_ANWB.
  DATA lf_zlwvertrag_leer TYPE /ADESSO/SPT_ANWB.
  DATA ld_anlage TYPE anlage.

  IF NOT x_commit IS INITIAL.
    COMMIT WORK.
  ENDIF.

  SELECT SINGLE anlage FROM euiinstln INTO ld_anlage
   WHERE int_ui = pd_int_ui
     AND datefrom LE pd_moveindat
     AND dateto GE pd_moveindat.


  SELECT * FROM /ADESSO/SPT_ANWB
    INTO TABLE lt_zlwvertrag_leer
   WHERE anlage = ld_anlage
     AND int_ui = pd_int_ui
     AND moveindate = pd_moveindat.

  IF sy-subrc EQ 0.
    SORT lt_zlwvertrag_leer BY lfd_nr DESCENDING.
    READ TABLE lt_zlwvertrag_leer INTO lf_zlwvertrag_leer INDEX 1.
    ADD 1 TO lf_zlwvertrag_leer-lfd_nr.
  ELSE.
    MOVE ld_anlage TO lf_zlwvertrag_leer-anlage.
    MOVE pd_int_ui TO lf_zlwvertrag_leer-int_ui.
    MOVE pd_moveindat TO lf_zlwvertrag_leer-moveindate.
    MOVE '1' TO lf_zlwvertrag_leer-lfd_nr.
  ENDIF.
  MOVE pd_art TO lf_zlwvertrag_leer-art.
  MOVE pd_switchnum TO lf_zlwvertrag_leer-wechselbeleg.
  MOVE sy-uname TO lf_zlwvertrag_leer-ernam.
  MOVE sy-uzeit TO lf_zlwvertrag_leer-erzeit.
  MOVE sy-datum TO lf_zlwvertrag_leer-erdat.



  CLEAR: lf_zlwvertrag_leer-msgty,
         lf_zlwvertrag_leer-msgid,
         lf_zlwvertrag_leer-msgno,
         lf_zlwvertrag_leer-message,
         lf_zlwvertrag_leer-msg_v1,
         lf_zlwvertrag_leer-msg_v2,
         lf_zlwvertrag_leer-msg_v3,
         lf_zlwvertrag_leer-msg_v4.

  INSERT INTO /ADESSO/SPT_ANWB VALUES lf_zlwvertrag_leer.
  IF NOT x_commit IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " SET_ERFOLG_leer
*&---------------------------------------------------------------------*
*&      Form  SET_FEHLER_LEER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_X_INT_UI  text
*      -->P_LD_SPERRDAT  text
*      -->P_BAPIRETURN  text
*      -->P_0226   text
*      -->P_X_COMMIT  text
*----------------------------------------------------------------------*
FORM set_fehler_leer  USING  pd_int_ui TYPE int_ui
                             pd_moveindat TYPE dats
                             pf_bapireturn TYPE bapireturn1
                             pd_art TYPE /ADESSO/SPT_LW_ART_EINZ
                             x_commit TYPE cose_commit.

  DATA lt_zlwvertrag_leer TYPE TABLE OF /ADESSO/SPT_ANWB.
  DATA lf_zlwvertrag_leer TYPE /ADESSO/SPT_ANWB.

  DATA ld_anlage TYPE anlage.

*  ROLLBACK WORK.
  IF NOT x_commit IS INITIAL.
    ROLLBACK WORK.
  ENDIF.



  SELECT SINGLE anlage FROM euiinstln INTO ld_anlage
   WHERE int_ui = pd_int_ui
     AND datefrom LE pd_moveindat
     AND dateto GE pd_moveindat.


  SELECT * FROM /ADESSO/SPT_ANWB
    INTO TABLE lt_zlwvertrag_leer
   WHERE anlage = ld_anlage
     AND int_ui = pd_int_ui
     AND moveindate = pd_moveindat.

  IF sy-subrc EQ 0.
    SORT lt_zlwvertrag_leer BY lfd_nr DESCENDING.
    READ TABLE lt_zlwvertrag_leer INTO lf_zlwvertrag_leer INDEX 1.
    ADD 1 TO lf_zlwvertrag_leer-lfd_nr.
  ELSE.
    MOVE ld_anlage TO lf_zlwvertrag_leer-anlage.
    MOVE pd_int_ui TO lf_zlwvertrag_leer-int_ui.
    MOVE pd_moveindat TO lf_zlwvertrag_leer-moveindate.
    MOVE '1' TO lf_zlwvertrag_leer-lfd_nr.
  ENDIF.
  MOVE sy-uname TO lf_zlwvertrag_leer-ernam.
  MOVE sy-uzeit TO lf_zlwvertrag_leer-erzeit.
  MOVE sy-datum TO lf_zlwvertrag_leer-erdat.
  MOVE pd_art TO lf_zlwvertrag_leer-art.
  MOVE pf_bapireturn-type TO lf_zlwvertrag_leer-msgty.
  MOVE pf_bapireturn-id TO lf_zlwvertrag_leer-msgid.
  MOVE pf_bapireturn-number TO lf_zlwvertrag_leer-msgno.
  MOVE pf_bapireturn-message TO lf_zlwvertrag_leer-message.
  MOVE pf_bapireturn-message_v1 TO lf_zlwvertrag_leer-msg_v1.
  MOVE pf_bapireturn-message_v2 TO lf_zlwvertrag_leer-msg_v2.
  MOVE pf_bapireturn-message_v3 TO lf_zlwvertrag_leer-msg_v3.
  MOVE pf_bapireturn-message_v4 TO lf_zlwvertrag_leer-msg_v4.

  INSERT INTO /ADESSO/SPT_ANWB VALUES lf_zlwvertrag_leer.

*  COMMIT WORK.
  IF NOT x_commit IS INITIAL.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    " SET_FEHLER_LEER
