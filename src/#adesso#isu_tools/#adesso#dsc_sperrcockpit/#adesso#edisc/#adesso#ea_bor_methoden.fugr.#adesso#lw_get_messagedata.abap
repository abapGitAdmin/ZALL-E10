FUNCTION /ADESSO/LW_GET_MESSAGEDATA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_SWITCHNUM) TYPE  EIDESWTDOC-SWITCHNUM OPTIONAL
*"     REFERENCE(I_MSGDATA) TYPE  EIDESWTMSGDATA OPTIONAL
*"     REFERENCE(I_BEGINNZUM) TYPE  EIDESWTMSGDATA-MOVEINDATE OPTIONAL
*"     REFERENCE(I_ENDEZUM) TYPE  EIDESWTMSGDATA-MOVEOUTDATE OPTIONAL
*"     REFERENCE(I_TRANSREASON) TYPE  EIDESWTMSGDATA-TRANSREASON
*"       OPTIONAL
*"     REFERENCE(I_BKV) TYPE  ESERVPROV-SERVICEID OPTIONAL
*"     REFERENCE(I_CATEGORY) TYPE  EIDESWTMDCAT OPTIONAL
*"     REFERENCE(I_METMETHOD) TYPE  EIDESWTMDMETMETHOD OPTIONAL
*"     REFERENCE(I_INT_UI) TYPE  INT_UI OPTIONAL
*"     REFERENCE(I_NETZANSCHLKAP) TYPE  /ADESSO/EIDESWTMDNETZKAP
*"       OPTIONAL
*"     REFERENCE(I_EMPF_SERVICEID) TYPE  EIDESWTDOC-SERVICE_PROV_OLD
*"       OPTIONAL
*"     REFERENCE(I_EIDESWTDOC) TYPE  EIDESWTDOC OPTIONAL
*"     REFERENCE(I_ANSWERSTATUS) TYPE  EIDESWTMSGDATA-MSGSTATUS
*"       OPTIONAL
*"     REFERENCE(I_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"       OPTIONAL
*"     REFERENCE(I_KENNZE44) TYPE  REGEN-KENNZX OPTIONAL
*"     REFERENCE(I_ZWANGSAUSZUGSTORNO) TYPE  REGEN-KENNZX OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_MSGDATA) TYPE  EIDESWTMSGDATA
*"     REFERENCE(E_SERVICEID_OLD) TYPE  ESERVPROV-SERVICEID
*"     REFERENCE(E_ZWAUS_STORNO) TYPE  REGEN-KENNZX
*"     REFERENCE(E_ANSWERSTATUS) TYPE  EIDESWTMSGDATA-MSGSTATUS
*"     REFERENCE(E_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"----------------------------------------------------------------------

** Unterscheidung der Verschiedenen Meldungsarten
** nach Kategrie (K), Wechselsicht (WS), Antwort (AN)
** Antwort des VNB auf Anmeldung: K E01, WS 01, AN X
** Antwort des VNB auf Abmeldung: K E02, WS 01, AN X
** Abmeldung gesendet durch Lief alt: K E02, WS 03, AN space
** Kündigung beantwortet duch Lief alt: K E35, WS 03, AN X
** Anmeldung gesendet durch Lief neu: K E01, WS 02, AN space
** Kündigung gesendet durch Lief neu: K E35, WS 02, AN space
** Zwangsabmeldung gesendet durch VNB: K E02, WS 01, AN space
** Zwangsabmeldung beantwortet durch LA: K E02, WS 03, AN X
** Info zu Lief-Konk gesendet durch VNB: K E44, WS 01, AN space

** Gesondert behandelt werden Antworten aus Storno
** Erkennbar aus AN X und Transaktionsgrund = E05.

* Für Stammdatenänderungen (Kategorie E03) müssen die Felder gemäß
* Datengruppe (= Transaktonsgrund) gefüllt werden.


* msgstatus für Bilanzkreisverantwortlichenermittlung kann auch 001 für OK sein.
  CONSTANTS: lc_msgstat001(3) TYPE c VALUE '001'. "OK



  DATA lf_msgdata TYPE eideswtmsgdata.
  DATA lf_eideswtdoc TYPE eideswtdoc.
  DATA lf_anlage TYPE v_eanl.
  DATA ld_keydatum TYPE sy-datum.
  DATA ld_swtview TYPE eideswtview.
  DATA ld_category TYPE eideswtmdcat.
  DATA ld_anfrage TYPE kennzx.
  DATA ld_metmethod TYPE eideswtmdmetmethod.
  DATA ld_transreason TYPE eideswtmdtran.
  DATA ld_msgdatanum TYPE eideswtmdnum.
  DATA ld_switchnum TYPE eideswtdoc-switchnum.
  DATA flg_zustimmung TYPE kennz VALUE 'X'. "X = Zustimmung
  DATA ld_nachrtyp_alt(10) TYPE c.
  DATA ld_nachrtyp_neu(10) TYPE c.
  DATA lt_ddtext TYPE ZEAGP_t_ddtext.
  DATA ld_flag_gue TYPE flag. " Wir haben mehrere Transaktionsgründe für GuE


*Wird ein Wechselbeleg aus einem Aus- oder Einzugsbeleg erstellt, werden weniger Daten diesem Funktionsbaustein übergeben.
*Aus diesem Grund müssen zusätzliche Prüfungen durchgeführt werden, um auch für diese Fälle die Nachrichtendanten zu sammeln.
*Dann wissen wir, dass dieser Wechselbeleg aus einem Aus- oder Einzugsbeleg erstellt werden soll
  IF i_switchnum IS INITIAL.
    ld_switchnum = i_eideswtdoc-switchnum.
  ELSE.
    ld_switchnum = i_switchnum.
  ENDIF.


*HÜ: I_MSGDATA ist bei Einzugsbeleg/Auszugsbeleg nicht gefüllt ==> lf_msgdata bleibt leer
*In der I_MSGDATA befinden sich die Daten, die bei der manuellen Erfassung der Nachrichtendaten eingetragen werden
  MOVE i_msgdata TO lf_msgdata.

* Daten sichern, die wir noch brauchen
*HÜ: EZB/AZB ld_msgdatanum kriegen wir nicht.
  MOVE lf_msgdata-msgdatanum TO ld_msgdatanum.

* Daten zum Verschicken vorbereiten
  CLEAR: lf_msgdata-dextaskid,
         lf_msgdata-msgdatanum,
         lf_msgdata-msgdate,
         lf_msgdata-msgtime,
         lf_msgdata-direction.
** 2016-04-06 - PhL
*         lf_msgdata-ZZ_EXTGUID.
*/ 2016-04-06 - PhL

* Voraussetzungen: I_EIDESWTDOC und I_MSGDATA sind gültig gefüllt.

  PERFORM hole_eideswtdoc USING ld_switchnum
                       CHANGING lf_eideswtdoc.
  IF NOT i_eideswtdoc IS INITIAL.
    MOVE i_eideswtdoc TO lf_eideswtdoc.
  ENDIF.

  MOVE lf_eideswtdoc-swtview TO ld_swtview .

  IF NOT i_int_ui IS INITIAL.
    MOVE i_int_ui TO lf_eideswtdoc-pod.
  ENDIF.


* Bestimmen, ob Antwort oder Anfrage
  IF i_answerstatus IS INITIAL.
    IF lf_msgdata-msgstatus IS INITIAL.
      MOVE gc_true TO ld_anfrage.
    ENDIF.
  ENDIF.


* Zustimmung oder Ablehnung
  IF NOT i_answerstatus IS INITIAL.
    IF i_answerstatus = 'E07'
    OR i_answerstatus = 'E15'
    OR i_answerstatus = 'Z01'
    OR i_answerstatus = 'Z04'
    OR i_answerstatus = 'Z05'
    OR i_answerstatus = 'Z15'
    OR i_answerstatus = 'Z43'
    OR i_answerstatus = 'Z44'.

*Zustimmung
      flg_zustimmung = gc_true.
    ELSE.
*Ablehnung
      flg_zustimmung = gc_false.
    ENDIF.
  ENDIF.


* Kategorie
  IF NOT i_category IS INITIAL.
    MOVE i_category TO lf_msgdata-category.
  ENDIF.
  MOVE lf_msgdata-category TO ld_category.


* Transaktionsgrund
  IF NOT i_transreason IS INITIAL.
    MOVE i_transreason TO lf_msgdata-transreason.
  ENDIF.
  MOVE lf_msgdata-transreason TO ld_transreason.

  IF ld_transreason EQ gc_transreason_ers_grv
  OR ld_transreason EQ gc_transreasion_guev_einz_aus
  OR ld_transreason EQ gc_transreasion_guev_neu
  OR ld_transreason EQ gc_transreasion_guev_lw
  OR ld_transreason EQ gc_transreasion_guev_temp.
    MOVE gc_true TO ld_flag_gue.
  ENDIF.



* Bemerkungen
* IMport-Paramter übergeben. Später kann in den einzelnen Forms bei Bedarf noch
* ergänzt werden
  MOVE i_commenttxt TO e_commenttxt.



* Felder befüllen.
* das Befüllend der weiteren Felder der Nachrichtendaten erfolgt getrennt
* nach Anwendungsfall. Folgende Forms stehen zur Verfügung

* movein_moveout_date, Einzugs- Auszugs- datum
* hole_keydatum Aufruf nach movein_moveout_date, Stichtag für weitere Selektionen
* hole_metmethod_msgdata Zählverfahren
* hole_ext_ui Ext Zählpunkt
* hole_anlage Anlage
* hole_zaehler zählernummer
* hole_vs Adresse Lieferstelle
* hole_gp  GP
* hole_slp SLP
* hole_jvb_pau , hole_jvb Jahresverbrauch
* hole_vkonto Kundennummer Netzbetreiber (VKONTO)
* hole_versart Versorgungsart
* hole_regelzone Regelzone
* hole_start_abrjahr Start Abrechungsjahr
* hole_spez_verbr  Spez. Verbrauch
* Konzessionsabgabe
* hole_spannungsebene Spannungsebene Entnahme/Messung.
* hole_bilanz_beg_ende,hole_bilanz_ende_plan  Bilanzierungsbeginn / Bilanzierungsende
* hole_bilanzkreis EICode Bilanzkreis
* EICode Bilanzierungsgebiet
* hole_bilanzierunggebiet Immer bei Sicht VNB und bei Antwort LA auf Zwangsabmeldung
* hole_next_abl nächste Turnusablesung - Woche
* hole_ist_haushaltskunde Ist Haushaltskunden
* hole_exvko Kundennummer bei Lieferanten
* hole_obis_kennzahl Obis-Kennzahl
* hole_refnummer hole_refnummer_e44  Referenznummer
* Mögliches Ende.
* Netzanschlusskapazität.
* Transaktionsgrund ist immer Z25 bei Kategrie E44
* hole_lieferant_konk  Konkurrierender Lieferant
* In allen anderen Fällen bestimmen wir den
*  hole_alt_lieferant Alten Lieferante
* hole_zwangsauszug_durch_storno Zwangsauszug durch Storno
* hole_bilanzkreisverantw Bilanzkreisverantwortlicher bei Zwangsabmeldungen
* Hole_IDREFNR_Nachricht Beim Storno eines Kategorie E01 Anfrage brauchen wir



**--------------------------------------------------------------------------------------------------*
** Beginnn 'Anmeldung Grund- und Ersatzversorgung' (E01)
*  IF  ld_anfrage EQ gc_true
*  AND ld_category EQ gc_category_anmeldung
*  AND ld_swtview EQ gc_swtview_vnb
*  AND ld_flag_gue EQ gc_true.
*
*    PERFORM hole_msgdata_vnbreqe01 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         lf_eideswtdoc-pod
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                CHANGING lf_msgdata
*                                         ld_transreason
*                                         e_commenttxt.
*
*
**--------------------------------------------------------------------------------------------------*
** Antwort auf Anmeldung zur Grund und Ersatzversorgung.
*  ELSEIF  ld_anfrage EQ gc_false
*  AND ld_category EQ gc_category_anmeldung
*  AND ld_swtview EQ gc_swtview_ln
*  AND ld_flag_gue EQ gc_true.
*
*    PERFORM hole_msgdata_lnrese01  USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                CHANGING lf_msgdata
*                                         e_commenttxt.
*
*
**--------------------------------------------------------------------------------------------------*
** BEGINN 'Anmeldung' (E01)
*  ELSEIF  ld_anfrage     EQ gc_true
*  AND ld_category    EQ gc_category_anmeldung
*  AND ld_swtview     EQ gc_swtview_ln
*  AND ld_transreason NE gc_transreason_storno.
*
*
** Anwendungsfall LNREQE01
*    PERFORM hole_msgdata_lnreqe01 USING i_beginnzum
*                                        i_endezum
*                                        ld_switchnum
*                                        ld_msgdatanum
*                                        lf_eideswtdoc
*                                        lf_eideswtdoc-pod
*                                        ld_transreason
*                                        i_answerstatus
*                                        i_netzanschlkap
*                                        ld_category
*                                        ld_anfrage
*                                        ld_swtview
*                               CHANGING lf_msgdata
*                                        e_commenttxt.
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Antwort auf Anmeldung' (E01) (Bestätigung oder Ablehnung)
*  ELSEIF ld_anfrage  = gc_false                   "Keine Anfrage, sondern Antwort
*  AND    ld_category = gc_category_anmeldung      "E01
*  AND    ld_swtview  = gc_swtview_vnb             "Sicht Verteilnetzbetreiber
*  AND    ld_transreason NE gc_transreason_storno.
*
*
*    PERFORM hole_msgdata_vnbrese01 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         lf_eideswtdoc-pod
*                                         ld_transreason
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                         flg_zustimmung
*                                CHANGING lf_msgdata.
*


*--------------------------------------------------------------------------------------------------*
* Aufbau 'WIB-Auftrag' (E01) (Lieferant an VNB)
  IF ld_anfrage     = gc_true                        "Anfrage
  AND    ld_category    = gc_category_anmeldung          "E01
  AND    ld_swtview     = gc_swtview_la                  "Sicht Lieferant Alt
  AND    ld_transreason = gc_transreasion_entsperrung.   "Entsperrung


    PERFORM hole_msgdata_lareqe01z28  USING i_beginnzum
                                            i_endezum
                                            ld_switchnum
                                            ld_msgdatanum
                                            lf_eideswtdoc
                                            lf_eideswtdoc-pod
                                            ld_transreason
                                            i_answerstatus
                                            i_netzanschlkap
                                            ld_category
                                            ld_anfrage
                                            ld_swtview
                                   CHANGING lf_msgdata
                                            e_commenttxt.


*--------------------------------------------------------------------------------------------------*
* Aufbau 'Antwort zum WIB-Auftrag' (E01A) (VNB an Lieferant)
  ELSEIF ld_anfrage     = gc_false                       "Antwort
  AND    ld_category    = gc_category_anmeldung          "E01
  AND    ld_swtview     = gc_swtview_vnb                 "Sicht VNB
  AND    ld_transreason = gc_transreasion_entsperrung.   "Entsperrung


    PERFORM hole_msgdata_vnbrese01z28 USING i_beginnzum
                                            i_endezum
                                            ld_switchnum
                                            ld_msgdatanum
                                            lf_eideswtdoc
                                            lf_eideswtdoc-pod
                                            ld_transreason
                                            i_answerstatus
                                            i_netzanschlkap
                                            ld_category
                                            flg_zustimmung
                                   CHANGING lf_msgdata
                                            e_commenttxt.



**--------------------------------------------------------------------------------------------------*
** Aufbau 'Abmeldung Netznetzung' (E02)
*  ELSEIF ld_anfrage     = gc_true                    "Anfrage
*  AND    ld_category    = gc_category_abmeld         "E02
*  AND    ld_swtview     = gc_swtview_la              "Sicht Lieferant Alt
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason NE gc_transreason_sperrung.
*
*
*    PERFORM hole_msgdata_lareqe02  USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         lf_eideswtdoc-pod
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                         ld_anfrage
*                                         ld_swtview
*                                CHANGING ld_transreason
*                                         lf_msgdata.
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Antwort auf Abmeldung' (E02)
*  ELSEIF ld_anfrage     = gc_false                   "Keine Anfrage, sondern Antwort
*  AND    ld_category    = gc_category_abmeld         "E02
*  AND    ld_swtview     = gc_swtview_vnb             "Sicht Verteilnetzbetreiber
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason NE gc_transreason_sperrung.
*
*    PERFORM hole_msgdata_vnbrese02 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         lf_eideswtdoc-pod
*                                         ld_transreason
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                         ld_swtview
*                                         flg_zustimmung
*                                CHANGING lf_msgdata.
*
** ENDE 'Antwort auf Abmeldung' (E02)
**--------------------------------------------------------------------------------------------------*
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Zwangsabmeldung' (gesendet durch VNB) (E02)
*  ELSEIF ld_anfrage     = gc_true                    "Anfrage
*  AND    ld_category    = gc_category_abmeld         "E02
*  AND    ld_swtview     = gc_swtview_vnb             "Sicht VNB
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason NE gc_transreason_sperrung.
*
*    PERFORM hole_msgdata_vnbreqe02 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         ld_transreason
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                         ld_anfrage
*                                         ld_swtview
*                                CHANGING lf_eideswtdoc
*                                         lf_msgdata
*                                         e_serviceid_old
*                                         e_commenttxt.
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Antwort auf Zwangsabmeldung' (gesendet durch LA) (E02A)
*  ELSEIF ld_anfrage     = gc_false                   "Antwort
*  AND    ld_category    = gc_category_abmeld         "E02
*  AND   (    ld_swtview     = gc_swtview_la
*          OR ld_swtview     = gc_swtview_ln  )         "Sicht LA oder LN (bei GUE)
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason NE gc_transreason_sperrung.
*
*    PERFORM hole_msgdata_larese02 USING i_beginnzum
*                                        i_endezum
*                                        ld_switchnum
*                                        ld_msgdatanum
*                                        ld_transreason
*                                        i_answerstatus
*                                        i_netzanschlkap
*                                        ld_category
*                                        ld_anfrage
*                                        ld_swtview
*                                        i_zwangsauszugstorno
*                               CHANGING lf_eideswtdoc
*                                        lf_msgdata.
*

*--------------------------------------------------------------------------------------------------*
* Aufbau 'Sperrauftrag' (E02) (Lieferant an VNB)
  ELSEIF ld_anfrage     = gc_true                    "Anfrage
  AND    ld_category    = gc_category_abmeld         "E02
  AND    ld_swtview     = gc_swtview_la              "Sicht Lieferant Alt
  AND    ld_transreason = gc_transreason_sperrung.   "Sperrung


    PERFORM hole_msgdata_lareqe02z27  USING i_endezum
                                            ld_switchnum
                                            ld_msgdatanum
                                            lf_eideswtdoc
                                            lf_eideswtdoc-pod
                                            ld_transreason
                                            ld_category
                                            ld_anfrage
                                            ld_swtview
                                   CHANGING lf_msgdata
                                            e_commenttxt.


*--------------------------------------------------------------------------------------------------*
* Aufbau 'Antwort zum Sperrauftrag' (E02A) (VNB an Lieferant)
  ELSEIF ld_anfrage     = gc_false                   "Antwort
  AND    ld_category    = gc_category_abmeld         "E02
  AND    ld_swtview     = gc_swtview_vnb             "Sicht VNB
  AND    ld_transreason = gc_transreason_sperrung.   "Sperrung


    PERFORM hole_msgdata_vnbrese02z27  USING i_endezum
                                            ld_switchnum
                                            ld_msgdatanum
                                            lf_eideswtdoc
                                            lf_eideswtdoc-pod
                                   CHANGING lf_msgdata
                                            e_commenttxt.


**--------------------------------------------------------------------------------------------------*
** Aufbau 'Kündigung beim alten Lieferanten' (E35) zum Erzeugen eines Wechselbelegs
*  ELSEIF ld_anfrage     = gc_true                    "Anfrage
*  AND    ld_category    = gc_category_kuend          "E35
*  AND    ld_swtview     = gc_swtview_ln              "Sicht Lieferant Neu
*  AND    ld_transreason NE gc_transreason_storno.
*
*    PERFORM hole_msgdata_lnreqe35 USING i_beginnzum
*                                        i_endezum
*                                        ld_switchnum
*                                        ld_msgdatanum
*                                        ld_transreason
*                                        i_answerstatus
*                                        i_netzanschlkap
*                                        ld_category
*                                        ld_swtview
*                                        i_possend
*                               CHANGING lf_eideswtdoc
*                                        lf_msgdata.
*
** ENDE 'Kündigung beim alten Lieferanten' (E35)
**--------------------------------------------------------------------------------------------------*
*
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Antwort auf Kündigung' (E35)
*  ELSEIF ld_anfrage     = gc_false                   "Antwort
*  AND    ld_category    = gc_category_kuend          "E35
*  AND    ld_swtview     = gc_swtview_la              "Sicht Lieferant Alt
*  AND    ld_transreason NE gc_transreason_storno.
*
*    PERFORM hole_msgdata_larese35 USING i_beginnzum
*                                        i_endezum
*                                        ld_switchnum
*                                        ld_msgdatanum
*                                        ld_transreason
*                                        i_answerstatus
*                                        i_netzanschlkap
*                                        ld_category
*                                        ld_swtview
*                                        i_possend
*                                        flg_zustimmung
*                               CHANGING lf_eideswtdoc
*                                        lf_msgdata
*                                        e_commenttxt.
*
** ENDE 'Antwort auf Kündigung' (E35)
**--------------------------------------------------------------------------------------------------*
*
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Informationsmeldung' (E44)
*  ELSEIF ld_anfrage     = gc_true                    "(E44 =) Anfrage
*  AND    ld_category    = gc_category_info           "E44
*  AND    ld_swtview     = gc_swtview_vnb             "Sicht Verteilnetzbetreiber
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason NE gc_transreason_sperrung.
*
*    PERFORM hole_msgdata_vnbreqe44 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         lf_eideswtdoc
*                                         ld_transreason
*                                         i_answerstatus
*                                         ld_category
*                                         ld_swtview
*                                         i_empf_serviceid
*                                         i_kennze44
*                                CHANGING lf_msgdata
*                                         e_serviceid_old.
*
** ENDE 'Informationsmeldung' (E44)
**--------------------------------------------------------------------------------------------------*
*
*
*
**--------------------------------------------------------------------------------------------------*
** Aufbau 'Informationsmeldung' (E44) (Sperrung auf VNB-Wunsch)
*  ELSEIF ld_anfrage     = gc_true                    "(E44 =) Anfrage
*  AND    ld_category    = gc_category_info           "E44
*  AND    ld_swtview     = gc_swtview_vnb             "Sicht Verteilnetzbetreiber
*  AND    ld_transreason NE gc_transreason_storno
*  AND    ld_transreason = gc_transreason_sperrung.
*
*    PERFORM hole_msgdata_vnbreqe44z27 USING i_beginnzum
*                                            i_endezum
*                                            ld_switchnum
*                                            lf_eideswtdoc
*                                            ld_transreason
*                                            i_answerstatus
*                                            ld_category
*                                            ld_swtview
*                                            i_empf_serviceid
*                                            i_kennze44
*                                   CHANGING lf_msgdata
*                                         e_serviceid_old.
*
** ENDE 'Informationsmeldung' (E44)
**--------------------------------------------------------------------------------------------------*



*--------------------------------------------------------------------------------------------------*
* Aufbau 'Anfrage nach Stornierung' (E05)
  ELSEIF ld_anfrage     = gc_true                    "Anfrage
  AND    ld_transreason = gc_transreason_storno.     "Stornierung


    PERFORM hole_msgdata_lreqe05 USING i_beginnzum
                                          i_endezum
                                          ld_switchnum
                                          lf_eideswtdoc
                                          ld_transreason
                                          i_answerstatus
                                          ld_category
                                          ld_swtview
                                          i_empf_serviceid
                                          ld_msgdatanum
                                 CHANGING lf_msgdata
                                          e_serviceid_old.

** ENDE 'Anfrage nach Stornierung' (E05)
**--------------------------------------------------------------------------------------------------*



*--------------------------------------------------------------------------------------------------*
* Aufbau 'Antwort auf Anfrage Stornierung' (E05)
  ELSEIF ld_anfrage     = gc_false                   "Antwort
  AND    ld_transreason = gc_transreason_storno.     "Stornierung


    PERFORM hole_msgdata_vnbrese05 USING i_beginnzum
                                          i_endezum
                                          ld_switchnum
                                          lf_eideswtdoc
                                          ld_transreason
                                          i_answerstatus
                                          ld_category
                                          ld_swtview
                                          i_empf_serviceid
                                          ld_msgdatanum
                                 CHANGING lf_msgdata
                                          e_serviceid_old.

* ENDE 'Antwort auf Stornierung' (E05)
*--------------------------------------------------------------------------------------------------*



**--------------------------------------------------------------------------------------------------*
** Hü 20.02.2009 -->
** Beginnn 'Antwort auf Stammdatenänderung' (E03) (LN antwortet auf Änderung vom VNB)
*  elseIF  ld_anfrage EQ gc_false
*  AND ld_category EQ gc_category_aenderung.
*
*    PERFORM hole_msgdata_vnbreqe03 USING i_beginnzum
*                                         i_endezum
*                                         ld_switchnum
*                                         ld_msgdatanum
*                                         lf_eideswtdoc
*                                         lf_eideswtdoc-pod
*                                         i_answerstatus
*                                         i_netzanschlkap
*                                         ld_category
*                                CHANGING lf_msgdata
*                                         ld_transreason
*                                         e_commenttxt.
*
** Hü 20.02.2009 <--
**--------------------------------------------------------------------------------------------------*


  ENDIF.


* Wieder für alle Zugleich.


* Nachrichtentypen bestimmen
  PERFORM hole_nachrichtentypen USING ld_category
                                      ld_anfrage
                                      ld_transreason
                                      ld_swtview
                             CHANGING ld_nachrtyp_alt
                                      ld_nachrtyp_neu.


* Setzen der Antwortstati
  IF NOT i_answerstatus IS INITIAL.
    MOVE i_answerstatus TO lf_msgdata-msgstatus.
  ENDIF.

  PERFORM setze_antwortstatus USING i_msgdata
                                    ld_nachrtyp_alt
                                    ld_nachrtyp_neu
                           CHANGING lf_msgdata
                                    lt_ddtext.


*  IF NOT lf_msgdata-zz_sammelstatus CS i_answerstatus.
*    MOVE lf_msgdata-msgstatus TO e_answerstatus.
*  ENDIF.

** Übnernahme der Antwortstati in die Tabelle ZLW_EXTMSGDATA
*  PERFORM schreibe_antwortstatus CHANGING lf_msgdata.


* (27 - KANN (MUSS bei E07, E14, Z07 in SG4-STS)) Bemerkungen (Vorgangsbezogen)
  PERFORM hole_bemerkungen USING  ld_anfrage
                                  ld_category
                                  lf_msgdata
                                  lf_eideswtdoc
                                  lt_ddtext
                         CHANGING e_commenttxt.


* Referenznummer
  PERFORM get_idref CHANGING lf_msgdata.

  MOVE lf_msgdata TO e_msgdata.


ENDFUNCTION.
