*&---------------------------------------------------------------------*
*&  Include           /ADESSO/SPT_CONST
*&---------------------------------------------------------------------*
* Konstantenvereinbarungen

CONSTANTS:
** Mandanten
    gc_netzmandant LIKE sy-mandt VALUE '721',
    gc_vertriebsmandant LIKE sy-mandt VALUE '021',
    gc_vertriebsmandant2 LIKE sy-mandt VALUE '022',
    gc_vertriebsmandant3 LIKE sy-mandt VALUE '023',
    gc_rolle_vertrieb type c value 'V',
    gc_rolle_netz type c value 'N',

** Allgemein
    gc_true TYPE kennzx VALUE 'X',
    gc_false TYPE kennzx VALUE ' ',
    gc_separator(1) TYPE c VALUE ',',
    gc_separator_semi(1) TYPE c VALUE ';',
    gc_alle(1) TYPE c VALUE '*',
    gc_buchkreis_vertrieb  TYPE bukrs value '0005',
    gc_buchkreis_netz  TYPE bukrs value '0009',

** Meldungstypen
    gc_fehler LIKE sy-msgty VALUE 'E',
    gc_info LIKE sy-msgty VALUE 'I',
    gc_warnung LIKE sy-msgty VALUE 'W',
    gc_erfolg LIKE sy-msgty VALUE 'S',

** Nachrichtenklasse
    gc_nakl LIKE sy-msgid VALUE '/ADESSO/EA_GPKE',  "auch als Prokokollobjekt verwendet
    gc_slg0 type BALSUBOBJ VALUE 'ZLEERST',

** Datum und Zeit
   gc_maxdatum TYPE d VALUE '99991231',
   gc_inidatum TYPE d VALUE '00000000',

* WMODE  Verarbeitungsart 1=disp 2=chng 3=creat
   gc_wmode_disp  TYPE regen-wmode VALUE '1',
   gc_wmode_chng  TYPE regen-wmode VALUE '2',
   gc_wmode_creat TYPE regen-wmode VALUE '3',

* Geschäftspartner-Gruppierung
   gc_group_int_nv_hb TYPE bu_group VALUE '0001',
   gc_group_int_nv_bhv TYPE bu_group VALUE '0002',

* Geschäftspartnertypen
   gc_gp_type_person TYPE bu_type VALUE '1',
   gc_gp_type_org TYPE bu_type VALUE '2',
   gc_gp_type_group TYPE bu_type VALUE '3',

* berechtigungsgruppen
   gc_augrp_netz TYPE bu_augrp VALUE 'NETZ',

* zählverfahren
   gc_metmethod_rlm TYPE eideswtmdmetmethod VALUE 'E01',
   gc_metmethod_slp TYPE eideswtmdmetmethod VALUE 'E02',
   gc_metmethod_pau TYPE eideswtmdmetmethod VALUE 'Z29',

* Servicetypen
   gc_intcode_verteilung TYPE intcode VALUE '01',
   gc_intcode_lieferung TYPE intcode VALUE '02',

* Profilzuordnung
   gc_profrole_verbrauch_bilanz TYPE profrole VALUE '0005',

* Nachrichtenkategorien
   gc_category_anmeldung TYPE eideswtmdcat VALUE 'E01',
   gc_category_kuend TYPE eideswtmdcat VALUE 'E35',
   gc_category_vbeginn TYPE eideswtmdcat VALUE 'E34',
   gc_category_abmeld TYPE eideswtmdcat VALUE 'E02',
   gc_category_info TYPE eideswtmdcat VALUE 'E44',
   gc_category_aenderung TYPE eideswtmdcat VALUE 'E03',

* Nachrichtentypen
   gc_nachrtyp_vnbae01(10) TYPE c VALUE 'VNBAE01',
   gc_nachrtyp_vnbae02(10) TYPE c VALUE 'VNBAE02',
   gc_nachrtyp_lare02(10) TYPE c VALUE 'LARE02',
   gc_nachrtyp_laae35(10) TYPE c VALUE 'LAAE35',
   gc_nachrtyp_lnre01(10) TYPE c VALUE 'LNRE01',
   gc_nachrtyp_lnre35(10) TYPE c VALUE 'LNRE35',
   gc_nachrtyp_vnbre02(10) TYPE c VALUE 'VNBRE02',
   gc_nachrtyp_laae02(10) TYPE c VALUE 'LAAE02',
   gc_nachrtyp_vnbre44(10) TYPE c VALUE 'VNBRE44',
   gc_nachrtyp_vnbae02e05(10) TYPE c VALUE 'VNBAE02E05',
   gc_nachrtyp_vnbae01e05(10) TYPE c VALUE 'VNBAE01E05',
   gc_nachrtyp_lnae01(10) TYPE c VALUE 'LNAE01',
   gc_nachrtyp_vnbre01(10) TYPE c VALUE 'VNBRE01',

* Zustimmung oder Ablehnung
   gc_zust_able TYPE kennzx VALUE 'X', "X = Zustimmung

* Servicearten
   gc_sercode_biko_strom TYPE sercode VALUE 'SBIK',
* Kiel
   gc_sercode_stromlieffremd TYPE sercode VALUE 'SLFR',
   gc_sercode_abwasserlief TYPE sercode VALUE 'ALIE',
   gc_sercode_ersatzversorgung TYPE sercode VALUE 'SERS',


* Versorgungsszenarien
   gc_scenario_strom_lief TYPE e_deregscenario VALUE '001',
   gc_scenario_gas_lief TYPE e_deregscenario VALUE '002',
   gc_scenario_wasser_lief TYPE e_deregscenario VALUE '003',
   gc_scenario_warmwasser_lief TYPE e_deregscenario VALUE '004',
   gc_scenario_heizenergie_lief TYPE e_deregscenario VALUE '005',
   gc_scenario_fernwaerme_lief TYPE e_deregscenario VALUE '004',

   gc_scenario_strom_nn TYPE e_deregscenario VALUE '001',
   gc_scenario_gas_nn TYPE e_deregscenario VALUE '002',
   gc_scenario_wasser_nn TYPE e_deregscenario VALUE '003',
   gc_scenario_warmwasser_nn TYPE e_deregscenario VALUE '004',
   gc_scenario_heizenergie_nn TYPE e_deregscenario VALUE '005',
   gc_scenario_fernwaerme_nn TYPE e_deregscenario VALUE '004',

* Ersatzversorgung
   gc_scen_strom_lief_ers TYPE e_deregscenario VALUE '001',
   gc_scen_gas_lief_ers TYPE e_deregscenario VALUE '002',
   gc_scen_wasser_lief_ers TYPE e_deregscenario VALUE '003',
   gc_scen_warmwasser_lief_ers TYPE e_deregscenario VALUE '004',
   gc_scen_heizenergie_lief_ers TYPE e_deregscenario VALUE '005',
   gc_scen_fernwaerme_lief_ers TYPE e_deregscenario VALUE '004',

   gc_scen_strom_nn_ers TYPE e_deregscenario VALUE '001',
   gc_scen_gas_nn_ers TYPE e_deregscenario VALUE '002',
   gc_scen_wasser_nn_ers TYPE e_deregscenario VALUE '003',
   gc_scen_warmwasser_nn_ers TYPE e_deregscenario VALUE '004',
   gc_scen_heizenergie_nn_ers TYPE e_deregscenario VALUE '005',
   gc_scen_fernwaerme_nn_ers TYPE e_deregscenario VALUE '004',

* Grundversorgung
   gc_scen_strom_lief_grundv TYPE e_deregscenario VALUE '001',
   gc_scen_gas_lief_grundv TYPE e_deregscenario VALUE '002',
   gc_scen_wasser_lief_grundv TYPE e_deregscenario VALUE '003',
   gc_scen_warmwasser_lief_grundv TYPE e_deregscenario VALUE '004',
   gc_scen_heizener_lief_grundv TYPE e_deregscenario VALUE '005',
   gc_scen_fernwaerme_lief_grundv TYPE e_deregscenario VALUE '004',

   gc_scen_strom_nn_grundv TYPE e_deregscenario VALUE '001',
   gc_scen_gas_nn_grundv TYPE e_deregscenario VALUE '002',
   gc_scen_wasser_nn_grundv TYPE e_deregscenario VALUE '003',
   gc_scen_warmwasser_nn_grundv TYPE e_deregscenario VALUE '004',
   gc_scen_heizenergie_nn_grundv TYPE e_deregscenario VALUE '005',
   gc_scen_fernwaerme_nn_grundv TYPE e_deregscenario VALUE '004',




   gc_scenario_nn TYPE e_deregscenario VALUE '001',
   gc_scenario_vv TYPE e_deregscenario VALUE '002',
   gc_scenario_nn_direkt TYPE e_deregscenario VALUE '010',
   gc_scenario_nn_fremd_direkt TYPE e_deregscenario VALUE '011',

* Switchview
   gc_swtview_vnb TYPE eideswtview VALUE '01',
   gc_swtview_ln TYPE eideswtview VALUE '02',
   gc_swtview_la TYPE eideswtview VALUE '03',

* Settleview
   gc_settleview_vnb TYPE eideswtview VALUE '01',     "VNB
   gc_settleview_l TYPE eideswtview VALUE '02',       "Lieferant

* Zählpunktgruppe am Zählpunkt
   gc_deregproc_info_zpgrp TYPE e_deregproc VALUE 'INFO_ZPGRP',
   gc_podgroup_slp TYPE e_deregpodgroup VALUE '1000',
   gc_podgroup_rlm TYPE e_deregpodgroup VALUE '2000',
   gc_podgroup     type char3 VALUE 'Z15', "Z15-->für Haushaltskunde
   gc_podgroup_gas     type char3 VALUE 'Z17', "Z15-->für Haushaltskunde

* Anlagenarten
   gc_anlart_pausschal TYPE anlart VALUE 'PANL',

* Transaktionsgründe
   gc_transreason_lief_konk TYPE eideswtmdtran VALUE 'Z26',
   gc_transreason_storno TYPE eideswtmdtran VALUE 'E05',
   gc_transreason_dg_ls TYPE eideswtmdtran VALUE 'Z19',
   gc_transreason_ers_grv TYPE eideswtmdtran VALUE 'Z03',
   gc_transreason_sperrung TYPE eideswtmdtran VALUE 'Z27',
   gc_transreasion_entsperrung TYPE eideswtmdtran VALUE 'Z28',
   gc_transreasion_GuEV_EINZ_AUS TYPE eideswtmdtran VALUE 'Z36',
   gc_transreasion_GuEV_NEU TYPE eideswtmdtran VALUE 'Z37',
   gc_transreasion_GuEV_LW TYPE eideswtmdtran VALUE 'Z38',
   gc_transreasion_GuEV_Temp TYPE eideswtmdtran VALUE 'Z39',

* Transaktionsgründe im Vertrag
   gc_transreason_einz TYPE eideswtmdtran VALUE 'E01',
   gc_transreason_einz_neu TYPE eideswtmdtran VALUE 'E02',
   gc_transreason_lw TYPE eideswtmdtran VALUE 'E03',

* SwitchType
   gc_swttype_lw  TYPE eideswttype VALUE '01',
   gc_swttype_end TYPE eideswttype VALUE '02',
   gc_swttype_beg TYPE eideswttype VALUE '03',
   gc_swttype_ers TYPE eideswttype VALUE '04',
   gc_swttype_spe TYPE eideswttype VALUE '94',
   gc_swttype_dev TYPE eideswttype VALUE '95',
   gc_swttype_ch  TYPE eideswttype VALUE '90',

* Direction
   gc_direction_import TYPE e_dexdirection VALUE '1',
   gc_direction_export TYPE e_dexdirection VALUE '2',

* Profiltypen
  gc_slptyp TYPE proftype VALUE '04',  "synthetisches Lastprofil

* Anlagenarten
  gc_anlart_pauschalanlage TYPE anlart VALUE 'PANL',

   gc_sparte_strom      TYPE spart VALUE '10',
   gc_sparte_gas        TYPE spart VALUE '20',
   gc_sparte_wasser     TYPE spart VALUE '30',
   gc_sparte_fernwaerme TYPE spart VALUE '40',
   gc_sparte_abwasser   TYPE spart VALUE '60',
   gc_sparte_heizenergie TYPE spart VALUE '08',
   gc_sparte_warmwasser TYPE spart VALUE '09',


* spartentypen
   gc_spartyp_strom TYPE spartyp VALUE '01',"Strom
   gc_spartyp_gas TYPE spartyp VALUE '02',  "Gas
   gc_spartyp_wasser TYPE spartyp VALUE '03',	"Wasser
   gc_spartyp_abwasser TYPE spartyp VALUE '04',	"Abwasser
   gc_spartyp_fernwaerme TYPE spartyp VALUE '05',	"Fernwärme
   gc_spartyp_entsorgung TYPE spartyp VALUE '06',	"Entsorgungswirtschaft
   gc_spartyp_gegenhilfe TYPE spartyp VALUE '11',	"Gegenseitigkeitshilfe
   gc_spartyp_uebergreifend TYPE spartyp VALUE '99',  "Spartenübergreifend'

* Servicestatus
  gc_deregscenservstat_anlegen TYPE e_deregscenservstat VALUE '001',

* Modus für autom. Zählpunktidentifikation
  gc_ident_mode TYPE /isidex/e_ident_procvarstep VALUE 'I',
  gc_search_mode TYPE /isidex/e_ident_procvarstep VALUE 'S',

* Zählwerksarten
  gc_zwart_ht TYPE e_zwart VALUE 'HT', "Hochtarif
  gc_zwart_nt TYPE e_zwart VALUE 'NT', "Niedertarif

* Unterscheidung der Zählwerksart (HT oder NT) anhand der OBIS-Kennziffern
* Obis-Kennziffern Solingen
  gc_obis_sws_strom_ht  TYPE etdz-kennziff VALUE '1-1:1.8.1', "Strom Hochtarif
  gc_obis_sws_strom_nt  TYPE etdz-kennziff VALUE '1-1:1.8.2', "Strom Niedertarif
  gc_obis_sws_gas_ht    TYPE etdz-kennziff VALUE '7-1:7.8.1', "Gas Hochtarif
  gc_obis_sws_wasser_ht TYPE etdz-kennziff VALUE '3-1:1.8.0', "Wasser Hochtarif
  gc_obis_sws_waerme_ht TYPE etdz-kennziff VALUE '6-1:1.8.1', "Wärme Hochtarif
* Obis-Kennziffern Kiel (erstmal von Solingen übernommen)
  gc_obis_swk_strom_ht  TYPE etdz-kennziff VALUE '1-1:1.8.1', "Strom Hochtarif
  gc_obis_swk_strom_nt  TYPE etdz-kennziff VALUE '1-1:1.8.2', "Strom Niedertarif
  gc_obis_swk_gas_ht    TYPE etdz-kennziff VALUE '7-1:7.8.1', "Gas Hochtarif
  gc_obis_swk_wasser_ht TYPE etdz-kennziff VALUE '3-1:1.8.0', "Wasser Hochtarif
  gc_obis_swk_waerme_ht TYPE etdz-kennziff VALUE '6-1:1.8.1', "Wärme Hochtarif

* Abschlagszyklen
  gc_abszyk_no TYPE abszykter VALUE '00', "Keine Abschläge

********************************************************************************
* Kennzeichen in den Kommentaren zu den Nachrichtendaten
* Nur für die Kommunikation zwischen Netz und Grundversorger+
* Diese werden, durch Semikolon abgeteilt, an den Bemerkungstext angehängt.
* Siehe auch Tabelle ZLW_COMMENTTXT
********************************************************************************
* Grund-und Ersatzversorgung
  gc_ersatzversorgung TYPE /ADESSO/SPT_VERSART VALUE 'ERS',  "Anmeldung zur Ersatzversorgung
  gc_grundversorgung TYPE /ADESSO/SPT_VERSART VALUE 'GRV',   "Anmeldung zur Grundversorgung
  gc_anmeldfolgt  TYPE char3 VALUE 'AFL',            "Anmeldung zur Grundversorgung
  gc_gue_erster_wb   TYPE char3  VALUE 'GE1',        "Erster WB für eine Verbrauchstelle
  gc_einzdritte  TYPE /ADESSO/SPT_LWVERSART VALUE 'EDD',       "Einzug gemeldet durch Dritte
  gc_neusetzer   TYPE char3  VALUE 'NAN',            "Neusetzer
  gc_rcode_grundversorger_leer like sy-subrc value '5019',
  gc_rcode_gpart_gue_leer like sy-subrc value '5020',
gc_rcode_distributor_not_found like sy-subrc value '5021',
gc_rcode_zielscenario_not_foun like sy-subrc value '5022',
gc_rcode_spartentyp_not_found like sy-subrc value '5023',


* Texte für Kommentare zu den Nachrichtendaten
  gc_text_grundversorgung TYPE eideswtmsgdataco-commenttxt VALUE 'Grundversorgung',
  "#EC NOTEXT
  gc_text_ersatzversorgung TYPE eideswtmsgdataco-commenttxt VALUE 'Ersatzversorgung',
  "#EC NOTEXT
* Tariftypen
  gc_tariftyp_kaltwasser TYPE tariftyp_anl VALUE 'TW-AT-001',
  gc_tariftyp_warmwasser TYPE tariftyp_anl VALUE 'TW-AT-014',

  gc_ktoklasse_privat TYPE ktoklasse VALUE 'P',
  gc_ktoklasse_gewerbe TYPE ktoklasse VALUE 'XX',

* Typen der Versorgungsscenarien
  gc_scenariotype_ers TYPE e_deregscenariotype VALUE '03',

* Haushalts- und Gewerbekunden
  gc_haushaltskunde TYPE /ADESSO/SPT_HHKGEWKL VALUE 'H',
  gc_gewerbekundebis10kwh TYPE /ADESSO/SPT_HHKGEWKL VALUE 'K',
  gc_gewerbekundeueber10kwh TYPE /ADESSO/SPT_HHKGEWKL VALUE 'G',

  gc_market_area_gas_swk TYPE /idexgg/a_market_area VALUE 'GAS_SWK',
  gc_netzkopplungspunkt_swk TYPE /idexgg/a_nwp_id VALUE 'SW-KIELGAS',

  gc_market_area_gas_sws TYPE /idexgg/a_market_area VALUE 'GAS_SWS',
  gc_netzkopplungspunkt_sws TYPE /idexgg/a_nwp_id VALUE '700221',

* Status Wechselbelege
  gc_status_wb_aktiv TYPE eideswtstat VALUE '03',
  gc_status_wb_ok TYPE eideswtstat VALUE '01',

* Fabrikkalender
  gc_fabrikkalender_de_stand TYPE bp_cal_id VALUE 'ZZ',

* Zeiten
  gc_maxseconds_fvkont TYPE i VALUE '3600',
  gc_stepseconds_fvkont TYPE i VALUE '60',

* Unterscheidung Kleingewerbe
  gc_perverbr_10000 TYPE eideswtmdprogyearcons VALUE '10000',
  gc_perverbr_100000 TYPE eideswtmdprogyearcons VALUE '100000',

* Adresstypen
  gc_adress_type_vstelle TYPE eadrgen-addr_type VALUE 'P',

* Verarbeitungsstatus Nachrichtendaten
  gc_procstatus_storniert TYPE eideswtmdprocstatus VALUE '004',


* User
  gc_user_wfbatch type sy-uname value 'WF-BATCH',

* Application Log
  gc_bal_object type bal_s_log-object value 'ZEA_GPKE',
  gc_bal_subobject_CREATEINST type  bal_s_log-subobject value 'ZCREATEINST',

* Verbrauchstellenarten
  gc_vbsart_STANDRWZ type VBSART value 'VBSART',

* Bedarfsarten in den Anlagen
  gc_anlart_wsp type eanl-anlart value 'WP',

* Operanden
  gc_operand_maxdemand type E_OPERAND value 'NZMAXMF',

* IH-Werk Auftrag (für Sperr-/WIB-Auftrag)
  gc_ih_werk type EDC_ORDERWERK value '0001'.

* Returncodes für z_lw_containerfubas.
constants:

gc_rcode_einv like sy-subrc value '5001',
gc_rcode_euihead like sy-subrc value '5002',
gc_rcode_ever like sy-subrc value '5003',
gc_rcode_create_swt like sy-subrc value '5004',
gc_rcode_open_swt like sy-subrc value '5005',
gc_rcode_edit_swt like sy-subrc value '5006',
gc_rcode_save_swt like sy-subrc value '5007',
gc_rcode_eein like sy-subrc value '5008',
gc_rcode_wb_general_fault like sy-subrc value '5009',
gc_rcode_wb_foreign_lock like sy-subrc value '5010',
gc_rcode_wb_pod_missing like sy-subrc value '5011',
gc_rcode_wb_not_authorized like sy-subrc value '5012',
gc_rcode_wb_others like sy-subrc value '5013',
gc_rcode_ausv like sy-subrc value '5014',
gc_rcode_eaus like sy-subrc value '5015',
gc_rcode_eeinv_scenario like sy-subrc value '5016',
gc_rcode_eeinv_trreason like sy-subrc value '5017',
gc_rcode_gpart_interaction like sy-subrc value '5018',


* WB für Sperrung
gc_rcode_sperre_no_servprov like sy-subrc value '5024',
gc_rcode_sperre_no_gpart like sy-subrc value '5025',
gc_rcode_sperre_no_distributor like sy-subrc value '5026',
gc_rcode_sperre_no_spartentyp like sy-subrc value '5027',

gc_rcode_kein_wb_ttyp like sy-subrc value '5028',

* Aufbau technischer Stammdaten im Vertrieb
gc_rcode_no_gue like sy-subrc value '5030',
gc_rcode_fehl_mdt like sy-subrc value '5031',
gc_rcode_pod_vorhanden like sy-subrc value '5032',
gc_rcode_no_customizing like sy-subrc value '5033',

* Anlegen Wechselbeleg für Leerstand
gc_rcode_wb_angelegt like sy-subrc value '5034',
gc_rcode_wb_vorhanden like sy-subrc value '5035',
gc_rcode_no_leerstand like sy-subrc value '5036',

gc_rcode_no_ao_data like sy-subrc value '5037',
gc_rcode_no_ableseeinheit like sy-subrc value '5038'.
