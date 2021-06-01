*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LMT_BELADUNGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_ACC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ACC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_acc  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT iacc_init.
    CLEAR: i_acc_down, y_data , regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'INIT'
                                            iacc_init
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz  NE '3'.
    MOVE 'INIT'    TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.

  LOOP AT iacc_vk.
    CLEAR: i_acc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'VK'
                                            iacc_vk
                                            y_data
                                            regel_kz.
*    CHECK NOT y_data IS INITIAL.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'VK'      TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.

  LOOP AT iacc_vkp.
    CLEAR: i_acc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'VKP'
                                            iacc_vkp
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'VKP'     TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.

  LOOP AT iacc_vklock.
    CLEAR: i_acc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'VKLOCK'
                                            iacc_vklock
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'VKLOCK'  TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.

  LOOP AT iacc_vkcorr.
    CLEAR: i_acc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'VKCORR'
                                            iacc_vkcorr
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'VKCORR'  TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.

  LOOP AT iacc_vktxex.
    CLEAR: i_acc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'VKTXEX'
                                            iacc_vktxex
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'VKTXEX'  TO i_acc_down-dttyp.
    MOVE oldkey    TO i_acc_down-oldkey.
    MOVE y_data    TO i_acc_down-data.
    APPEND i_acc_down.

  ENDLOOP.


  CLEAR: iacc_init, iacc_vk, iacc_vkp, iacc_vklock,
         iacc_vkcorr, iacc_vktxex.

  REFRESH: iacc_init, iacc_vk, iacc_vkp, iacc_vklock,
           iacc_vkcorr, iacc_vktxex.



ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ERST_MIG_DATEI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ACC_DOWN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_IDTTYP  text
*      -->P_BEL_FILE  text
*----------------------------------------------------------------------*
FORM erst_mig_datei  TABLES   idown STRUCTURE /adesso/mt_down_mig_obj
                    USING    p_firma
                             p_object
                             p_idttyp
                             p_bel_file.


  TYPES: BEGIN OF ty_import_uc,
          oldkey TYPE emg_oldkey,
          dttyp  TYPE emg_dttyp,
          data   TYPE xstring,
         END OF ty_import_uc.


  DATA: imp TYPE ty_import_uc.
  DATA: iimp TYPE ty_import_uc OCCURS 0 WITH HEADER LINE,
        simp TYPE ty_import_uc OCCURS 10 WITH HEADER LINE,
        himp TYPE ty_import_uc OCCURS 10 WITH HEADER LINE,
        copy_imp TYPE ty_import_uc OCCURS 5 WITH HEADER LINE,
        paste_imp TYPE ty_import_uc.

  DATA: qcp LIKE tcp00-cpcodepage,
        knz_unicode TYPE c,
        lv_unicode TYPE abap_encod,
        rc         LIKE sy-subrc,
        h_record TYPE xstring.


  DATA: cl_view_nodata TYPE REF TO cl_abap_view_offlen.
  DATA: himp_header TYPE tem_import_header.
  DATA: cl_conv_in  TYPE REF TO cl_abap_conv_in_ce.
  DATA: cl_conv_out TYPE REF TO cl_abap_conv_out_ce.

  DATA: cl_view_info TYPE REF TO cl_abap_view_offlen.
  DATA: h_info LIKE teminfo.

  DATA: hstring TYPE string.
  data: encod type abap_encod.

* Codepage ermitteln
  SELECT SINGLE * FROM temob WHERE firma = p_firma AND object = p_object.

  IF temob-cpgfs IS NOT INITIAL.
    qcp = temob-cpgfs.
  ELSE.
    qcp = '1100'.
  ENDIF.

   move qcp to encod.

* IIMP-Datei aufbauen.
  LOOP AT idown.
    iimp-oldkey = idown-oldkey.
    iimp-dttyp = idown-dttyp.
    hstring = idown-data.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text     = hstring
*       MIMETYPE = ' '
        encoding = encod
      IMPORTING
        buffer   = iimp-data
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    APPEND iimp.

  ENDLOOP.


* check codepage
  PERFORM check_cp USING qcp rc.
  IF rc NE 0.
    MESSAGE e000(e4) WITH 'Codepage nicht vorhanden!'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'ISU_M_UNICODE_CHECK'
    EXPORTING
      x_codepage     = qcp
    IMPORTING
      y_is_uc_system = knz_unicode.


  IF knz_unicode EQ 'X'.
    cl_view_nodata = cl_abap_view_offlen=>create_unicode16_view(
himp_header ).
    cl_view_info = cl_abap_view_offlen=>create_unicode16_view( h_info ).
  ELSE.
    cl_view_nodata = cl_abap_view_offlen=>create_legacy_view(
himp_header ).
    cl_view_info = cl_abap_view_offlen=>create_legacy_view( h_info ).
  ENDIF.
  lv_unicode = qcp.
  cl_conv_in  = cl_abap_conv_in_ce=>create(
                  encoding = lv_unicode input = iimp-data
                  ignore_cerr = abap_true replacement = '#' ).
  cl_conv_out = cl_abap_conv_out_ce=>create( encoding = lv_unicode ).


  OPEN DATASET p_bel_file FOR OUTPUT IN BINARY MODE.


*> Kopf der Datei erzeugen
* create & write header record
  CLEAR himp_header.
  himp_header-dttyp = '&INFO'.
  h_info-firma  = p_firma.
  h_info-object = p_object.
  h_info-uname  = sy-uname.
  h_info-datum  = sy-datum.
  h_info-uzeit  = sy-uzeit.

  CALL METHOD cl_conv_out->reset( ).
  CALL METHOD cl_conv_out->write( data = himp_header
    view = cl_view_nodata ).
  CALL METHOD cl_conv_out->write( data = h_info
    view = cl_view_info ).
  h_record = cl_conv_out->get_buffer( ).
  CALL FUNCTION 'ISU_M_DATASET_BINARY_WRITE'
    EXPORTING
      x_dataset        = p_bel_file
      x_record         = h_record
    EXCEPTIONS
      file_write_error = 1.
  IF sy-subrc NE 0. ENDIF.

* now write the data records to the file
  LOOP AT iimp.
    IF sy-tabix > 1.
      IF iimp-dttyp = p_idttyp.
*       Endesatz erzeugen
        CALL METHOD cl_conv_out->reset( ).
        himp_header-oldkey = himp_header-oldkey.
        himp_header-dttyp = '&ENDE'.
        CALL METHOD cl_conv_out->write( data = himp_header
          view = cl_view_nodata ).
        h_record = cl_conv_out->get_buffer( ).
*        CLEAR iimp-data.
*        CONCATENATE h_record iimp-data INTO h_record IN BYTE MODE.
        CALL FUNCTION 'ISU_M_DATASET_BINARY_WRITE'
          EXPORTING
            x_dataset        = p_bel_file
            x_record         = h_record
          EXCEPTIONS
            file_write_error = 1.
        IF sy-subrc NE 0. ENDIF.
      ENDIF.
    ENDIF.
    CALL METHOD cl_conv_out->reset( ).
    himp_header-oldkey = iimp-oldkey.
    himp_header-dttyp  = iimp-dttyp.
    CALL METHOD cl_conv_out->write( data = himp_header
      view = cl_view_nodata ).
    h_record = cl_conv_out->get_buffer( ).
    CONCATENATE h_record iimp-data INTO h_record IN BYTE MODE.
    CALL FUNCTION 'ISU_M_DATASET_BINARY_WRITE'
      EXPORTING
        x_dataset        = p_bel_file
        x_record         = h_record
      EXCEPTIONS
        file_write_error = 1.
    IF sy-subrc NE 0. ENDIF.
  ENDLOOP.

* Endesatz
  CALL METHOD cl_conv_out->reset( ).
  himp_header-oldkey = iimp-oldkey.
  himp_header-dttyp = '&ENDE'.
  CALL METHOD cl_conv_out->write( data = himp_header
    view = cl_view_nodata ).
  h_record = cl_conv_out->get_buffer( ).
*  CLEAR iimp-data.
*  CONCATENATE h_record iimp-data INTO h_record IN BYTE MODE.
  CALL FUNCTION 'ISU_M_DATASET_BINARY_WRITE'
    EXPORTING
      x_dataset        = p_bel_file
      x_record         = h_record
    EXCEPTIONS
      file_write_error = 1.
  IF sy-subrc NE 0. ENDIF.


* close import file
  CALL FUNCTION 'ISU_M_DATASET_BINARY_CLOSE'
    EXPORTING
      x_dataset   = p_bel_file
      x_write_eof = 'X'.





*  OPEN DATASET p_bel_file FOR OUTPUT IN BINARY MODE.
*
*
*  FIELD-SYMBOLS: <f>.
*  DATA: wa_info LIKE teminfo.
*  DATA: s_laenge(2) TYPE x.  "Satzlänge (HEX)
*  DATA: s_oldkey LIKE /adesso/mt_down_mig_obj-oldkey.
*
** --> Nuss 14.09.2015
*  DATA: BEGIN OF wa_header,
*          field(1) TYPE c.
*          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
*  DATA: END OF wa_header.
*
*  DATA: BEGIN OF wa_ende,
*            reclength(4) TYPE c.           "Test Nuss 15.09.2015
*          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
*  DATA: END OF wa_ende.
** <-- Nuss 14.09.2015
*
*  DATA: BEGIN OF wa_satz,
*          reclength(4) TYPE c.              "Test Nuss 14.09.2015
**          reclength(2)  TYPE c.            "Test Nuss 14.09.2015
*          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
*  DATA: END OF wa_satz.





* --> Nuss 14.09.2015
*  CLEAR wa_info.
*  wa_info-firma  = p_firma.
*  wa_info-object = p_object.
*  wa_info-uname  = sy-uname.
*  wa_info-datum  = sy-datum.
*  wa_info-uzeit  = sy-uzeit.
*  CLEAR wa_satz.
*  wa_satz-oldkey   = space.
*  wa_satz-dttyp    = '&INFO'.
*  wa_satz-data     = wa_info.
*  s_laenge         = strlen( wa_satz ).
*  wa_satz-reclength = s_laenge.
*  ASSIGN wa_satz(s_laenge) TO <f>.
*  TRANSFER <f>   TO p_bel_file.
*  COMMIT WORK.

*  CLEAR wa_info.
*  wa_info-firma  = p_firma.
*  wa_info-object = p_object.
*  wa_info-uname  = sy-uname.
*  wa_info-datum  = sy-datum.
*  wa_info-uzeit  = sy-uzeit.
*  CLEAR wa_header.
*  wa_header-oldkey   = space.
*  wa_header-dttyp    = '&INFO'.
*  wa_header-data     = wa_info.
*  s_laenge         = strlen( wa_header ).
**  wa_satz-reclength = s_laenge.
*  ASSIGN wa_header(s_laenge) TO <f>.
*  TRANSFER <f>   TO p_bel_file.
*  COMMIT WORK.
** <
**  <-- Nuss 14.09.2015
*
** Datensätze mit jeweiligem Satzende erzeugen
*  LOOP AT idown.
*
*    IF sy-tabix > 1.
*      IF idown-dttyp EQ p_idttyp.
**>     Endesatz erzeugen
**        --> Nuss 14.09.2015
**        wa_satz-oldkey   = s_oldkey.
**        wa_satz-dttyp    = '&ENDE'.
**        wa_satz-data     = space.
**        s_laenge         = strlen( wa_satz ).
**        wa_satz-reclength = s_laenge.
**        ASSIGN wa_satz(s_laenge) TO <f>.
**        TRANSFER <f>   TO p_bel_file.
**        COMMIT WORK.                            "Nuss 14.09.2015
*        wa_ende-oldkey   = s_oldkey.
*        wa_ende-dttyp    = '&ENDE'.
*        wa_ende-data     = space.
*        s_laenge         = strlen( wa_ende ).
*        wa_ende-reclength = s_laenge.
*        ASSIGN wa_ende(s_laenge) TO <f>.
*        TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
*        COMMIT WORK.                            "Nuss 14.09.2015
**      <-- Nuss 14.09.2015
**<
*      ENDIF.
*    ENDIF.
*
**> Datensätze erzeugen
*    s_oldkey         = idown-oldkey.
*    wa_satz-oldkey   = idown-oldkey.
*    wa_satz-dttyp    = idown-dttyp.
*    wa_satz-data     = idown-data.
*    s_laenge         = strlen( wa_satz ).
*    wa_satz-reclength = s_laenge.           "Nuss 15.09.2015  auskommentier, da Feld draußen
*    ASSIGN wa_satz(s_laenge) TO <f>.
*    TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
*    COMMIT WORK.                             "Nuss 14.09.2015
**<
*  ENDLOOP.
*
*  IF sy-subrc EQ 0.
** Endedatensatz des letzten Altsystemschlüssels erzeugen
**   --> Nuss 14.09.2015
**    wa_satz-oldkey   = s_oldkey.
**    wa_satz-dttyp    = '&ENDE'.
**    wa_satz-data     = space.
**    s_laenge         = strlen( wa_satz ).
**    wa_satz-reclength = s_laenge.
**    ASSIGN wa_satz(s_laenge) TO <f>.
**    TRANSFER <f>   TO p_bel_file.
**    COMMIT WORK.                            "Nuss 14.09.2015
*    wa_ende-oldkey   = s_oldkey.
*    wa_ende-dttyp    = '&ENDE'.
*    wa_ende-data     = space.
*    s_laenge         = strlen( wa_ende ).
*    wa_ende-reclength = s_laenge.
*    ASSIGN wa_ende(s_laenge) TO <f>.
*    TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
*    COMMIT WORK.                            "Nuss 14.09.2015
**      <-- Nuss 14.09.2015
*
**<
*  ENDIF.
*
*
*  CLOSE DATASET p_bel_file.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_ACN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ACN  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_acn  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT iacn_notkey.
    CLEAR: i_acn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTKEY'
                                            iacn_notkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTKEY'  TO i_acn_down-dttyp.
    MOVE oldkey    TO i_acn_down-oldkey.
    MOVE y_data    TO i_acn_down-data.
    APPEND i_acn_down.

  ENDLOOP.


  LOOP AT iacn_notlin.
    CLEAR: i_acn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTLIN'
                                            iacn_notlin
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTLIN'  TO i_acn_down-dttyp.
    MOVE oldkey    TO i_acn_down-oldkey.
    MOVE y_data    TO i_acn_down-data.
    APPEND i_acn_down.

  ENDLOOP.

  CLEAR: iacn_notkey, iacn_notlin.
  REFRESH: iacn_notkey, iacn_notlin.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_BPM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BPM  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_bpm  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ibpm_eabp.
    CLEAR: i_bpm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EABP'
                                            ibpm_eabp
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EABP'    TO i_bpm_down-dttyp.
    MOVE oldkey    TO i_bpm_down-oldkey.
    MOVE y_data    TO i_bpm_down-data.
    APPEND i_bpm_down.

  ENDLOOP.

  LOOP AT ibpm_eabpv.
    CLEAR: i_bpm_down, y_data, regel_kz.
*   SHIFT ibpm_eabpv-vtref LEFT BY 10 PLACES.     "MAK130804
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EABPV'
                                            ibpm_eabpv
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EABPV'   TO i_bpm_down-dttyp.
    MOVE oldkey    TO i_bpm_down-oldkey.
    MOVE y_data    TO i_bpm_down-data.
    APPEND i_bpm_down.

  ENDLOOP.

  LOOP AT ibpm_eabps.
    CLEAR: i_bpm_down, y_data, regel_kz.
*   SHIFT ibpm_eabps-vtref LEFT BY 10 PLACES.     "MAK130804
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EABPS'
                                            ibpm_eabps
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EABPS'   TO i_bpm_down-dttyp.
    MOVE oldkey    TO i_bpm_down-oldkey.
    MOVE y_data    TO i_bpm_down-data.
    APPEND i_bpm_down.

  ENDLOOP.


  LOOP AT ibpm_ejvl.
    CLEAR: i_bpm_down, y_data, regel_kz.
*   SHIFT ibpm_ejvl-vertrag LEFT BY 10 PLACES.   "MAK130804
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EJVL'
                                            ibpm_ejvl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EJVL'    TO i_bpm_down-dttyp.
    MOVE oldkey    TO i_bpm_down-oldkey.
    MOVE y_data    TO i_bpm_down-data.
    APPEND i_bpm_down.

  ENDLOOP.


  CLEAR: ibpm_eabp, ibpm_eabpv, ibpm_eabps, ibpm_ejvl.
  REFRESH: ibpm_eabp, ibpm_eabpv, ibpm_eabps, ibpm_ejvl.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_BCT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BCT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_bct  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ibct_bcontd.
    CLEAR: i_bct_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BCONTD'
                                            ibct_bcontd
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BCONTD' TO i_bct_down-dttyp.
    MOVE oldkey   TO i_bct_down-oldkey.
    MOVE y_data   TO i_bct_down-data.
    APPEND i_bct_down.

  ENDLOOP.

  LOOP AT ibct_pbcobj.
    CLEAR: i_bct_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'PBCOBJ'
                                            ibct_pbcobj
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'PBCOBJ' TO i_bct_down-dttyp.
    MOVE oldkey   TO i_bct_down-oldkey.
    MOVE y_data   TO i_bct_down-data.
    APPEND i_bct_down.

  ENDLOOP.


  CLEAR: ibct_bcontd, ibct_pbcobj.
  REFRESH: ibct_bcontd, ibct_pbcobj.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_BCN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_BCN  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_bcn  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ibcn_notkey.
    CLEAR: i_bcn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTKEY'
                                            ibcn_notkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTKEY'  TO i_bcn_down-dttyp.
    MOVE oldkey    TO i_bcn_down-oldkey.
    MOVE y_data    TO i_bcn_down-data.
    APPEND i_bcn_down.

  ENDLOOP.


  LOOP AT ibcn_notlin.
    CLEAR: i_bcn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTLIN'
                                            ibcn_notlin
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTLIN'  TO i_bcn_down-dttyp.
    MOVE oldkey    TO i_bcn_down-oldkey.
    MOVE y_data    TO i_bcn_down-data.
    APPEND i_bcn_down.

  ENDLOOP.

  CLEAR: ibcn_notkey, ibcn_notlin.
  REFRESH: ibcn_notkey, ibcn_notlin.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_CON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_CON  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_con  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_co_eha.
    CLEAR: i_con_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'CO_EHA'
                                            i_co_eha
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'CO_EHA' TO i_con_down-dttyp.
    MOVE oldkey   TO i_con_down-oldkey.
    MOVE y_data   TO i_con_down-data.
    APPEND i_con_down.

  ENDLOOP.


  LOOP AT i_co_adr.
    CLEAR: i_con_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'CO_ADR'
                                            i_co_adr
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'CO_ADR' TO i_con_down-dttyp.
    MOVE oldkey   TO i_con_down-oldkey.
    MOVE y_data   TO i_con_down-data.
    APPEND i_con_down.

  ENDLOOP.



  LOOP AT i_co_com.
    CLEAR: i_con_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'CO_COM'
                                            i_co_com
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'CO_COM' TO i_con_down-dttyp.
    MOVE oldkey   TO i_con_down-oldkey.
    MOVE y_data   TO i_con_down-data.
    APPEND i_con_down.

  ENDLOOP.

  CLEAR: i_co_eha, i_co_adr, i_co_com.
  REFRESH: i_co_eha, i_co_adr, i_co_com.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_CNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_CNO  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_cno  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT icno_notkey.
    CLEAR: i_cno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTKEY'
                                            icno_notkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTKEY'  TO i_cno_down-dttyp.
    MOVE oldkey    TO i_cno_down-oldkey.
    MOVE y_data    TO i_cno_down-data.
    APPEND i_cno_down.

  ENDLOOP.


  LOOP AT icno_notlin.
    CLEAR: i_cno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTLIN'
                                            icno_notlin
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTLIN'  TO i_cno_down-dttyp.
    MOVE oldkey    TO i_cno_down-oldkey.
    MOVE y_data    TO i_cno_down-data.
    APPEND i_cno_down.

  ENDLOOP.

  CLEAR: icno_notkey, icno_notlin.
  REFRESH: icno_notkey, icno_notlin.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DGR  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dgr  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idgr_edevgr.
    CLEAR: i_dgr_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EDEVGR'
                                            idgr_edevgr
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
       OR regel_kz NE '3'.
    MOVE 'EDEVGR'  TO i_dgr_down-dttyp.
    MOVE oldkey    TO i_dgr_down-oldkey.
    MOVE y_data    TO i_dgr_down-data.
    APPEND i_dgr_down.

  ENDLOOP.

  LOOP AT idgr_device.
    CLEAR: i_dgr_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DEVICE'
                                            idgr_device
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DEVICE'  TO i_dgr_down-dttyp.
    MOVE oldkey    TO i_dgr_down-oldkey.
    MOVE y_data    TO i_dgr_down-data.
    APPEND i_dgr_down.

  ENDLOOP.


  CLEAR: idgr_edevgr, idgr_device.
  REFRESH: idgr_edevgr, idgr_device.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DEV  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dev  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_equi.
    CLEAR: i_dev_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EQUI'
                                            i_equi
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EQUI'    TO i_dev_down-dttyp.
    MOVE oldkey    TO i_dev_down-oldkey.
    MOVE y_data    TO i_dev_down-data.
    APPEND i_dev_down.

  ENDLOOP.


  LOOP AT i_egers.
    CLEAR: i_dev_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EGERS'
                                            i_egers
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EGERS'   TO i_dev_down-dttyp.
    MOVE oldkey    TO i_dev_down-oldkey.
    MOVE y_data    TO i_dev_down-data.
    APPEND i_dev_down.

  ENDLOOP.


  LOOP AT i_egerh.
    CLEAR: i_dev_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EGERH'
                                            i_egerh
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EGERH'   TO i_dev_down-dttyp.
    MOVE oldkey    TO i_dev_down-oldkey.
    MOVE y_data    TO i_dev_down-data.
    APPEND i_dev_down.

  ENDLOOP.


  LOOP AT i_clhead.
    CLEAR: i_dev_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'CLHEAD'
                                            i_clhead
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'CLHEAD'    TO i_dev_down-dttyp.
    MOVE oldkey      TO i_dev_down-oldkey.
    MOVE y_data      TO i_dev_down-data.
    APPEND i_dev_down.

  ENDLOOP.


  LOOP AT i_cldata.
    CLEAR: i_dev_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'CLDATA'
                                            i_cldata
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'CLDATA'    TO i_dev_down-dttyp.
    MOVE oldkey      TO i_dev_down-oldkey.
    MOVE y_data      TO i_dev_down-data.
    APPEND i_dev_down.

  ENDLOOP.


  CLEAR: i_equi, i_egers, i_egerh, i_clhead, i_cldata.
  REFRESH: i_equi, i_egers, i_egerh, i_clhead, i_cldata.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DRT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_drt  USING   oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idrt_drint.
    CLEAR: i_drt_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DRINT'
                                            idrt_drint
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DRINT'   TO i_drt_down-dttyp.
    MOVE oldkey    TO i_drt_down-oldkey.
    MOVE y_data    TO i_drt_down-data.
    APPEND i_drt_down.
  ENDLOOP.

  LOOP AT idrt_drdev.
    CLEAR: i_drt_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DRDEV'
                                            idrt_drdev
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DRDEV'   TO i_drt_down-dttyp.
    MOVE oldkey    TO i_drt_down-oldkey.
    MOVE y_data    TO i_drt_down-data.
    APPEND i_drt_down.
  ENDLOOP.

  LOOP AT idrt_drreg.
    CLEAR: i_drt_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DRREG'
                                            idrt_drreg
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DRREG'   TO i_drt_down-dttyp.
    MOVE oldkey    TO i_drt_down-oldkey.
    MOVE y_data    TO i_drt_down-data.
    APPEND i_drt_down.
  ENDLOOP.


  CLEAR: idrt_drint, idrt_drdev, idrt_drreg.
  REFRESH: idrt_drint, idrt_drdev, idrt_drreg.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DLC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DLC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dlc  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_egpld.
    CLEAR: i_dlc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EGPLD'
                                            i_egpld
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EGPLD'  TO i_dlc_down-dttyp.
    MOVE oldkey   TO i_dlc_down-oldkey.
    MOVE y_data   TO i_dlc_down-data.
    APPEND i_dlc_down.

  ENDLOOP.

  CLEAR: i_egpld.
  REFRESH: i_egpld.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DNO  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dno  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idno_notkey.
    CLEAR: i_dno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTKEY'
                                            idno_notkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTKEY'  TO i_dno_down-dttyp.
    MOVE oldkey    TO i_dno_down-oldkey.
    MOVE y_data    TO i_dno_down-data.
    APPEND i_dno_down.

  ENDLOOP.


  LOOP AT idno_notlin.
    CLEAR: i_dno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTLIN'
                                            idno_notlin
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTLIN'  TO i_dno_down-dttyp.
    MOVE oldkey    TO i_dno_down-oldkey.
    MOVE y_data    TO i_dno_down-data.
    APPEND i_dno_down.

  ENDLOOP.

  CLEAR: idno_notkey, idno_notlin.
  REFRESH: idno_notkey, idno_notlin.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DCD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCD  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dcd  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idcd_header.
    CLEAR: i_dcd_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HEADER'
                                            idcd_header
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'HEADER' TO i_dcd_down-dttyp.
    MOVE oldkey   TO i_dcd_down-oldkey.
    MOVE y_data   TO i_dcd_down-data.
    APPEND i_dcd_down.

  ENDLOOP.

  LOOP AT idcd_fkkmaz.
    CLEAR: i_dcd_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'FKKMAZ'
                                            idcd_fkkmaz
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'FKKMAZ' TO i_dcd_down-dttyp.
    MOVE oldkey   TO i_dcd_down-oldkey.
    MOVE y_data   TO i_dcd_down-data.
    APPEND i_dcd_down.

  ENDLOOP.


  CLEAR: idcd_header, idcd_fkkmaz.
  REFRESH: idcd_header, idcd_fkkmaz.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DCO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCO  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dco USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idco_header.
    CLEAR: i_dco_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HEADER'
                                            idco_header
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'HEADER' TO i_dco_down-dttyp.
    MOVE oldkey   TO i_dco_down-oldkey.
    MOVE y_data   TO i_dco_down-data.
    APPEND i_dco_down.

  ENDLOOP.


  CLEAR: idco_header.
  REFRESH: idco_header.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCE  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dce  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idce_header.
    CLEAR: i_dce_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HEADER'
                                            idce_header
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'HEADER' TO i_dce_down-dttyp.
    MOVE oldkey   TO i_dce_down-oldkey.
    MOVE y_data   TO i_dce_down-data.
    APPEND i_dce_down.

  ENDLOOP.

  LOOP AT idce_anlage.
    CLEAR: i_dce_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ANLAGE'
                                            idce_anlage
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ANLAGE' TO i_dce_down-dttyp.
    MOVE oldkey   TO i_dce_down-oldkey.
    MOVE y_data   TO i_dce_down-data.
    APPEND i_dce_down.

  ENDLOOP.


  LOOP AT idce_device.
    CLEAR: i_dce_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DEVICE'
                                            idce_device
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DEVICE' TO i_dce_down-dttyp.
    MOVE oldkey   TO i_dce_down-oldkey.
    MOVE y_data   TO i_dce_down-data.
    APPEND i_dce_down.

  ENDLOOP.

  CLEAR: idce_header, idce_anlage, idce_device.
  REFRESH: idce_header, idce_anlage, idce_device.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCR  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dcr  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idcr_header.
    CLEAR: i_dcr_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HEADER'
                                            idcr_header
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'HEADER' TO i_dcr_down-dttyp.
    MOVE oldkey   TO i_dcr_down-oldkey.
    MOVE y_data   TO i_dcr_down-data.
    APPEND i_dcr_down.

  ENDLOOP.


  CLEAR: idcr_header.
  REFRESH: idcr_header.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DCM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DCM  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dcm  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idcm_header.
    CLEAR: i_dcm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HEADER'
                                            idcm_header
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'HEADER' TO i_dcm_down-dttyp.
    MOVE oldkey   TO i_dcm_down-oldkey.
    MOVE y_data   TO i_dcm_down-data.
    APPEND i_dcm_down.

  ENDLOOP.

  LOOP AT idcm_anlage.
    CLEAR: i_dcm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ANLAGE'
                                            idcm_anlage
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ANLAGE' TO i_dcm_down-dttyp.
    MOVE oldkey   TO i_dcm_down-oldkey.
    MOVE y_data   TO i_dcm_down-data.
    APPEND i_dcm_down.

  ENDLOOP.


  LOOP AT idcm_device.
    CLEAR: i_dcm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DEVICE'
                                            idcm_device
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DEVICE' TO i_dcm_down-dttyp.
    MOVE oldkey   TO i_dcm_down-oldkey.
    MOVE y_data   TO i_dcm_down-data.
    APPEND i_dcm_down.

  ENDLOOP.

  CLEAR: idcm_header, idcm_anlage, idcm_device.
  REFRESH: idcm_header, idcm_anlage, idcm_device.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DOC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_doc  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT idoc_ko.
    CLEAR: i_doc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KO'
                                            idoc_ko
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KO'      TO i_doc_down-dttyp.
    MOVE oldkey    TO i_doc_down-oldkey.
    MOVE y_data    TO i_doc_down-data.
    APPEND i_doc_down.

  ENDLOOP.

  LOOP AT idoc_op.
    CLEAR: i_doc_down, y_data, regel_kz.
    SHIFT idoc_op-vtref LEFT BY 10 PLACES.
    PERFORM (formname) IN PROGRAM (repname)
                                             USING 'OP'
                                             idoc_op
                                             y_data
                                             regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'OP'      TO i_doc_down-dttyp.
    MOVE oldkey    TO i_doc_down-oldkey.
    MOVE y_data    TO i_doc_down-data.
    APPEND i_doc_down.

  ENDLOOP.

  LOOP AT idoc_opk.
    CLEAR: i_doc_down, y_data, regel_kz.
*    idoc_opk-betrw = idoc_opk-betrw * '-1'.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'OPK'
                                            idoc_opk
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'OPK'     TO i_doc_down-dttyp.
    MOVE oldkey    TO i_doc_down-oldkey.
    MOVE y_data    TO i_doc_down-data.
    APPEND i_doc_down.

  ENDLOOP.

  LOOP AT idoc_opl.
    CLEAR: i_doc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'OPL'
                                            idoc_opl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'OPL'     TO i_doc_down-dttyp.
    MOVE oldkey    TO i_doc_down-oldkey.
    MOVE y_data    TO i_doc_down-data.
    APPEND i_doc_down.

  ENDLOOP.

  LOOP AT idoc_addinf.
    CLEAR: i_doc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ADDINF'
                                            idoc_addinf
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ADDINF'  TO i_doc_down-dttyp.
    MOVE oldkey    TO i_doc_down-oldkey.
    MOVE y_data    TO i_doc_down-data.
    APPEND i_doc_down.

  ENDLOOP.


  CLEAR: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.
  REFRESH: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_PAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PAY  text
*      -->P_PREP_NAME  text
*      -->P_PFORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_pay  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ipay_fkkko.
    CLEAR: i_pay_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'FKKKO'
                                            ipay_fkkko
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'FKKKO'   TO i_pay_down-dttyp.
    MOVE oldkey    TO i_pay_down-oldkey.
    MOVE y_data    TO i_pay_down-data.
    APPEND i_pay_down.

  ENDLOOP.

  LOOP AT ipay_fkkopk.
    CLEAR: i_pay_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'FKKOPK'
                                            ipay_fkkopk
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'FKKOPK'  TO i_pay_down-dttyp.
    MOVE oldkey    TO i_pay_down-oldkey.
    MOVE y_data    TO i_pay_down-data.
    APPEND i_pay_down.

  ENDLOOP.

  LOOP AT ipay_seltns.
    CLEAR: i_pay_down, y_data, regel_kz.
    SHIFT ipay_seltns-viref LEFT BY 10 PLACES.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'SELTNS'
                                            ipay_seltns
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'SELTNS'  TO i_pay_down-dttyp.
    MOVE oldkey    TO i_pay_down-oldkey.
    MOVE y_data    TO i_pay_down-data.
    APPEND i_pay_down.

  ENDLOOP.


  CLEAR: ipay_fkkko, ipay_fkkopk, ipay_seltns.
  REFRESH: ipay_fkkko, ipay_fkkopk, ipay_seltns.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_FAC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_FAC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_fac  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  DATA: op_old LIKE /adesso/mt_facts-operand.

* Migrationsreihenfolge der Fakten bestimmen

  LOOP AT ifac_facts.

    CASE ifac_facts-optyp.

      WHEN 'QUANT'.
        MOVE '01' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'DEMAND'.
        MOVE '02' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'TQUANT'.
        MOVE '03' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'QPRICE'.
        MOVE '04' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'FACTOR'.
        MOVE '05' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'FLAG'.
        MOVE '06' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'AMOUNT'.
        MOVE '07' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'INTEGER'.
        MOVE '08' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'RATETYPE'.
        MOVE '09' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'ADISCABS'.
        MOVE '10' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'ADISCPER'.
        MOVE '11' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'DDISCNT'.
        MOVE '12' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'PDISCNT'.
        MOVE '13' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'QDISCNT'.
        MOVE '14' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'LPRICE'.
        MOVE '15' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'SPRICE'.
        MOVE '16' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'TPRICE'.
        MOVE '17' TO ifac_facts-nummer.
        MODIFY ifac_facts.
      WHEN 'USERDEF'.
        MOVE '18' TO ifac_facts-nummer.
        MODIFY ifac_facts.

    ENDCASE.

  ENDLOOP.

* sortieren der Fakten in die richtige Migrationsreihenfolge
  SORT ifac_facts BY nummer operand ab.


  LOOP AT ifac_key.
    CLEAR: i_fac_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            ifac_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_fac_down-dttyp.
    MOVE oldkey    TO i_fac_down-oldkey.
    MOVE y_data    TO i_fac_down-data.
    APPEND i_fac_down.

  ENDLOOP.


*  LOOP AT ifac_F_QUAN.
*    CLEAR: i_fac_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'F_QUAN'
*                                            ifac_F_QUAN
*                                            y_data.
*    MOVE 'F_QUAN'  TO i_fac_down-dttyp.
*    MOVE oldkey    TO i_fac_down-oldkey.
*    MOVE y_data    TO i_fac_down-data.
*    APPEND i_fac_down.
*
*  ENDLOOP.
*
*  LOOP AT ifac_V_QUAN.
*    CLEAR: i_fac_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'V_QUAN'
*                                            ifac_V_QUAN
*                                            y_data.
*    MOVE 'V_QUAN'  TO i_fac_down-dttyp.
*    MOVE oldkey    TO i_fac_down-oldkey.
*    MOVE y_data    TO i_fac_down-data.
*    APPEND i_fac_down.
*
*  ENDLOOP.



  CLEAR: ifac_facts, wfac_facts.

  LOOP AT ifac_facts. " INTO wfac_facts.

    CASE ifac_facts-optyp.
      WHEN 'QUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_QUAN
          MOVE-CORRESPONDING ifac_facts TO ifac_f_quan.
          MOVE 'X' TO ifac_f_quan-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QUAN'
                                                  ifac_f_quan
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QUAN'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_QUAN
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_quan.
        MOVE ifac_facts-wert1 TO  ifac_v_quan-menge.
        MOVE ifac_facts-wert2 TO  ifac_v_quan-menge2.       "KLE220904
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QUAN'
                                                ifac_v_quan
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QUAN'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.

*---------------------------------------------------------------------
      WHEN 'DEMAND'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_DEMA
          MOVE-CORRESPONDING ifac_facts TO ifac_f_dema.
          MOVE 'X' TO ifac_f_dema-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DEMA'
                                                  ifac_f_dema
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DEMA'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_DEMA
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_dema.
        MOVE ifac_facts-wert1 TO  ifac_v_dema-lmenge.
        MOVE ifac_facts-wert2 TO  ifac_v_dema-lmenge2.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DEMA'
                                                ifac_v_dema
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DEMA'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TQUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_TQUA
          MOVE-CORRESPONDING ifac_facts TO ifac_f_tqua.
          MOVE 'X' TO ifac_f_tqua-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TQUA'
                                                  ifac_f_tqua
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TQUA'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_TQUA
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_tqua.
        MOVE ifac_facts-wert1 TO  ifac_v_tqua-menge.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TQUA'
                                                ifac_v_tqua
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TQUA'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_QPRI
          MOVE-CORRESPONDING ifac_facts TO ifac_f_qpri.
          MOVE 'X' TO ifac_f_qpri-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QPRI'
                                                  ifac_f_qpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QPRI'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_QPRI
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_qpri.
        MOVE ifac_facts-string1 TO  ifac_v_qpri-preis.

*       bei bestimmten Konstellationen im Agger-Projekt fehlte noch der Wert
        MOVE ifac_facts-wert1   TO  ifac_v_qpri-prsbtr.

        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QPRI'
                                                ifac_v_qpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QPRI'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'AMOUNT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_AMOU
          MOVE-CORRESPONDING ifac_facts TO ifac_f_amou.
          MOVE 'X' TO ifac_f_amou-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AMOU'
                                                  ifac_f_amou
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AMOU'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_AMOU
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_amou.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AMOU'
                                                ifac_v_amou
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AMOU'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FACTOR'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_FACT
          MOVE-CORRESPONDING ifac_facts TO ifac_f_fact.
          MOVE 'X' TO ifac_f_fact-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FACT'
                                                  ifac_f_fact
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FACT'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_FACT
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_fact.
        MOVE ifac_facts-wert1         TO ifac_v_fact-factor.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FACT'
                                                ifac_v_fact
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FACT'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FLAG'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_FLAG
          MOVE-CORRESPONDING ifac_facts TO ifac_f_flag.
          MOVE 'X' TO ifac_f_flag-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FLAG'
                                                  ifac_f_flag
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FLAG'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_FLAG
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_flag.
        MOVE ifac_facts-string3       TO ifac_v_flag-boolkz.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FLAG'
                                                ifac_v_flag
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FLAG'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'INTEGER'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_INTE
          MOVE-CORRESPONDING ifac_facts TO ifac_f_inte.
          MOVE 'X' TO ifac_f_inte-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_INTE'
                                                  ifac_f_inte
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_INTE'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_INTE
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_inte.
        MOVE ifac_facts-wert1         TO ifac_v_inte-integer4.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_INTE'
                                                ifac_v_inte
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_INTE'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'RATETYPE'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_RATE
          MOVE-CORRESPONDING ifac_facts TO ifac_f_rate.
          MOVE 'X' TO ifac_f_rate-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_RATE'
                                                  ifac_f_rate
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_RATE'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_RATE
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_rate.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_RATE'
                                                ifac_v_rate
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_RATE'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.



*---------------------------------------------------------------------
      WHEN 'ADISCABS'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_AABS
          MOVE-CORRESPONDING ifac_facts TO ifac_f_aabs.
          MOVE 'X' TO ifac_f_aabs-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AABS'
                                                  ifac_f_aabs
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AABS'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_AABS
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_aabs.
        MOVE ifac_facts-string1          TO ifac_v_aabs-rabzus.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AABS'
                                                ifac_v_aabs
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AABS'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'ADISCPER'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_APER
          MOVE-CORRESPONDING ifac_facts TO ifac_f_aper.
          MOVE 'X' TO ifac_f_aper-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_APER'
                                                  ifac_f_aper
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_APER'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_APER
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_aper.
        MOVE ifac_facts-string1          TO ifac_v_aper-rabzus.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_APER'
                                                ifac_v_aper
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_APER'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'DDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_DDIS
          MOVE-CORRESPONDING ifac_facts TO ifac_f_ddis.
          MOVE 'X' TO ifac_f_ddis-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DDIS'
                                                  ifac_f_ddis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DDIS'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_DDIS
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_ddis.
        MOVE ifac_facts-string1          TO ifac_v_ddis-rabzus.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DDIS'
                                                ifac_v_ddis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DDIS'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'PDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_PDIS
          MOVE-CORRESPONDING ifac_facts TO ifac_f_pdis.
          MOVE 'X' TO ifac_f_pdis-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_PDIS'
                                                  ifac_f_pdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_PDIS'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_PDIS
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_pdis.
        MOVE ifac_facts-string1          TO ifac_v_pdis-rabzus.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_PDIS'
                                                ifac_v_pdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_PDIS'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_QDIS
          MOVE-CORRESPONDING ifac_facts TO ifac_f_qdis.
          MOVE 'X' TO ifac_f_qdis-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QDIS'
                                                  ifac_f_qdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QDIS'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_QDIS
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_qdis.
        MOVE ifac_facts-string1          TO ifac_v_qdis-rabzus.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QDIS'
                                                ifac_v_qdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QDIS'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'LPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_LPRI
          MOVE-CORRESPONDING ifac_facts TO ifac_f_lpri.
          MOVE 'X' TO ifac_f_lpri-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_LPRI'
                                                  ifac_f_lpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_LPRI'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_LPRI
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_lpri.
        MOVE ifac_facts-string1       TO ifac_v_lpri-preis.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_LPRI'
                                                ifac_v_lpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_LPRI'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'SPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_SPRI
          MOVE-CORRESPONDING ifac_facts TO ifac_f_spri.
          MOVE 'X' TO ifac_f_spri-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_SPRI'
                                                  ifac_f_spri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_SPRI'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_SPRI
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_spri.
        MOVE ifac_facts-string1       TO ifac_v_spri-preistuf.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_SPRI'
                                                ifac_v_spri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_SPRI'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_TPRI
          MOVE-CORRESPONDING ifac_facts TO ifac_f_tpri.
          MOVE 'X' TO ifac_f_tpri-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TPRI'
                                                  ifac_f_tpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TPRI'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_TPRI
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_tpri.
        MOVE ifac_facts-string1       TO ifac_v_tpri-preis.
        MOVE ifac_facts-betrag        TO ifac_v_tpri-prsbtr.
        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TPRI'
                                                ifac_v_tpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TPRI'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'USERDEF'.
        IF  op_old IS INITIAL OR
            op_old NE ifac_facts-operand.
*F_UDEF
          MOVE-CORRESPONDING ifac_facts TO ifac_f_udef.
          MOVE 'X' TO ifac_f_udef-auto_insert.
          CLEAR: i_fac_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_UDEF'
                                                  ifac_f_udef
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_UDEF'  TO i_fac_down-dttyp.
          MOVE oldkey    TO i_fac_down-oldkey.
          MOVE y_data    TO i_fac_down-data.
          APPEND i_fac_down.
        ENDIF.

*V_UDEF
*        LOOP AT ifac_facts WHERE operand EQ wfac_facts-operand.
        MOVE-CORRESPONDING ifac_facts TO ifac_v_udef.
*       Felder 'Wert1 und -2' werden bei den User-definierten Fakten
*       von Emigall nicht verarbeitet

*       MOVE ifac_facts-wert1         TO ifac_v_udef-udefval1.
*       MOVE ifac_facts-wert2         TO ifac_v_udef-udefval2.
*       MOVE ifac_facts-string1       TO ifac_v_udef-udefval3.
*       MOVE ifac_facts-string2       TO ifac_v_udef-udefval4.
        MOVE ifac_facts-string1       TO ifac_v_udef-udefval1.
        MOVE ifac_facts-string2       TO ifac_v_udef-udefval2.
        MOVE ifac_facts-string3       TO ifac_v_udef-udefval3.
        MOVE ifac_facts-string4       TO ifac_v_udef-udefval4.

        CLEAR: i_fac_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_UDEF'
                                                ifac_v_udef
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_UDEF'  TO i_fac_down-dttyp.
        MOVE oldkey    TO i_fac_down-oldkey.
        MOVE y_data    TO i_fac_down-data.
        APPEND i_fac_down.

        op_old = ifac_facts-operand.
*        ENDLOOP.

    ENDCASE.

  ENDLOOP.



  CLEAR: ifac_facts, wfac_facts.
  REFRESH: ifac_facts.


  CLEAR: ifac_key, ifac_f_quan, ifac_f_dema,
        ifac_f_tqua, ifac_f_qpri, ifac_f_amou, ifac_f_fact, ifac_f_flag,
        ifac_f_inte, ifac_f_rate, ifac_f_aabs, ifac_f_aper, ifac_f_ddis,
        ifac_f_pdis, ifac_f_qdis, ifac_f_lpri, ifac_f_spri, ifac_f_tpri,
        ifac_f_udef, ifac_v_quan, ifac_v_dema, ifac_v_tqua, ifac_v_qpri,
        ifac_v_amou, ifac_v_fact, ifac_v_flag, ifac_v_inte, ifac_v_rate,
        ifac_v_aabs, ifac_v_aper, ifac_v_ddis, ifac_v_pdis, ifac_v_qdis,
         ifac_v_lpri, ifac_v_spri, ifac_v_tpri, ifac_v_udef.

  REFRESH: ifac_key, ifac_f_quan, ifac_f_dema,
        ifac_f_tqua, ifac_f_qpri, ifac_f_amou, ifac_f_fact, ifac_f_flag,
        ifac_f_inte, ifac_f_rate, ifac_f_aabs, ifac_f_aper, ifac_f_ddis,
        ifac_f_pdis, ifac_f_qdis, ifac_f_lpri, ifac_f_spri, ifac_f_tpri,
        ifac_f_udef, ifac_v_quan, ifac_v_dema, ifac_v_tqua, ifac_v_qpri,
        ifac_v_amou, ifac_v_fact, ifac_v_flag, ifac_v_inte, ifac_v_rate,
        ifac_v_aabs, ifac_v_aper, ifac_v_ddis, ifac_v_pdis, ifac_v_qdis,
         ifac_v_lpri, ifac_v_spri, ifac_v_tpri, ifac_v_udef.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_INS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INS  text
*      -->P_ANLANZ  text
*      -->P_ANLCOUNT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_ins  USING    oldkey
                                   panlanz
                                   panlcount
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  DATA: op_old LIKE /adesso/mt_facts-operand.

* Migrationsreihenfolge der Fakten bestimmen

  LOOP AT ins_facts.

    CASE ins_facts-optyp.

      WHEN 'QUANT'.
        MOVE '01' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'DEMAND'.
        MOVE '02' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'TQUANT'.
        MOVE '03' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'QPRICE'.
        MOVE '04' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'AMOUNT'.
        MOVE '05' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'FACTOR'.
        MOVE '06' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'FLAG'.
        MOVE '07' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'INTEGER'.
        MOVE '08' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'RATETYPE'.
        MOVE '09' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'ADISCABS'.
        MOVE '10' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'ADISCPER'.
        MOVE '11' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'DDISCNT'.
        MOVE '12' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'PDISCNT'.
        MOVE '13' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'QDISCNT'.
        MOVE '14' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'LPRICE'.
        MOVE '15' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'SPRICE'.
        MOVE '16' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'TPRICE'.
        MOVE '17' TO ins_facts-nummer.
        MODIFY ins_facts.
      WHEN 'USERDEF'.
        MOVE '18' TO ins_facts-nummer.
        MODIFY ins_facts.

    ENDCASE.

  ENDLOOP.

* sortieren der Fakten in die richtige Migrationsreihenfolge
  SORT ins_facts BY nummer operand ab.



  LOOP AT ins_key.
    CLEAR: i_ins_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            ins_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_ins_down-dttyp.
    MOVE oldkey    TO i_ins_down-oldkey.
    MOVE y_data    TO i_ins_down-data.
    APPEND i_ins_down.

  ENDLOOP.

  LOOP AT ins_data.
    CLEAR: i_ins_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DATA'
                                            ins_data
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DATA'    TO i_ins_down-dttyp.
    MOVE oldkey    TO i_ins_down-oldkey.
    MOVE y_data    TO i_ins_down-data.
    APPEND i_ins_down.

  ENDLOOP.

  LOOP AT ins_rcat.
    CLEAR: i_ins_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'RCAT'
                                            ins_rcat
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'RCAT'    TO i_ins_down-dttyp.
    MOVE oldkey    TO i_ins_down-oldkey.
    MOVE y_data    TO i_ins_down-data.
    APPEND i_ins_down.

  ENDLOOP.

*  LOOP AT ins_pod.
*    CLEAR: i_ins_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'POD'
*                                            ins_pod
*                                            y_data.
*    CHECK NOT y_data IS INITIAL.
*    MOVE 'POD'     TO i_ins_down-dttyp.
*    MOVE oldkey    TO i_ins_down-oldkey.
*    MOVE y_data    TO i_ins_down-data.
*    APPEND i_ins_down.
*
*  ENDLOOP.



  CLEAR: ins_facts, wins_facts.

  LOOP AT ins_facts. " INTO wins_facts.

    CASE ins_facts-optyp.
      WHEN 'QUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_QUAN
          MOVE-CORRESPONDING ins_facts TO ins_f_quan.
          MOVE 'X' TO ins_f_quan-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QUAN'
                                                  ins_f_quan
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QUAN'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_QUAN
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_quan.
        MOVE ins_facts-wert1 TO  ins_v_quan-menge.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QUAN'
                                                ins_v_quan
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QUAN'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.

*---------------------------------------------------------------------
      WHEN 'DEMAND'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_DEMA
          MOVE-CORRESPONDING ins_facts TO ins_f_dema.
          MOVE 'X' TO ins_f_dema-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DEMA'
                                                  ins_f_dema
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DEMA'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_DEMA
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_dema.
        MOVE ins_facts-wert1 TO  ins_v_dema-lmenge.
        MOVE ins_facts-wert2 TO  ins_v_dema-lmenge2.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DEMA'
                                                ins_v_dema
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DEMA'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TQUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_TQUA
          MOVE-CORRESPONDING ins_facts TO ins_f_tqua.
          MOVE 'X' TO ins_f_tqua-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TQUA'
                                                  ins_f_tqua
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TQUA'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_TQUA
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_tqua.
        MOVE ins_facts-wert1 TO  ins_v_tqua-menge.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TQUA'
                                                ins_v_tqua
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TQUA'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_QPRI
          MOVE-CORRESPONDING ins_facts TO ins_f_qpri.
          MOVE 'X' TO ins_f_qpri-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QPRI'
                                                  ins_f_qpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QPRI'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_QPRI
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_qpri.
        MOVE ins_facts-string1 TO  ins_v_qpri-preis.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QPRI'
                                                ins_v_qpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QPRI'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'AMOUNT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_AMOU
          MOVE-CORRESPONDING ins_facts TO ins_f_amou.
          MOVE 'X' TO ins_f_amou-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AMOU'
                                                  ins_f_amou
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AMOU'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_AMOU
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_amou.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AMOU'
                                                ins_v_amou
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AMOU'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FACTOR'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_FACT
          MOVE-CORRESPONDING ins_facts TO ins_f_fact.
          MOVE 'X' TO ins_f_fact-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FACT'
                                                  ins_f_fact
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FACT'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_FACT
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_fact.
        MOVE ins_facts-wert1         TO ins_v_fact-factor.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FACT'
                                                ins_v_fact
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FACT'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FLAG'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_FLAG
          MOVE-CORRESPONDING ins_facts TO ins_f_flag.
          MOVE 'X' TO ins_f_flag-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FLAG'
                                                  ins_f_flag
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FLAG'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_FLAG
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_flag.
        MOVE ins_facts-string3       TO ins_v_flag-boolkz.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FLAG'
                                                ins_v_flag
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FLAG'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'INTEGER'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_INTE
          MOVE-CORRESPONDING ins_facts TO ins_f_inte.
          MOVE 'X' TO ins_f_inte-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_INTE'
                                                  ins_f_inte
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_INTE'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_INTE
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_inte.
        MOVE ins_facts-wert1         TO ins_v_inte-integer4.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_INTE'
                                                ins_v_inte
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_INTE'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'RATETYPE'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_RATE
          MOVE-CORRESPONDING ins_facts TO ins_f_rate.
          MOVE 'X' TO ins_f_rate-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_RATE'
                                                  ins_f_rate
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_RATE'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_RATE
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_rate.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_RATE'
                                                ins_v_rate
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_RATE'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.



*---------------------------------------------------------------------
      WHEN 'ADISCABS'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_AABS
          MOVE-CORRESPONDING ins_facts TO ins_f_aabs.
          MOVE 'X' TO ins_f_aabs-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AABS'
                                                  ins_f_aabs
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AABS'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_AABS
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_aabs.
        MOVE ins_facts-string1          TO ins_v_aabs-rabzus.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AABS'
                                                ins_v_aabs
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AABS'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'ADISCPER'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_APER
          MOVE-CORRESPONDING ins_facts TO ins_f_aper.
          MOVE 'X' TO ins_f_aper-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_APER'
                                                  ins_f_aper
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_APER'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_APER
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_aper.
        MOVE ins_facts-string1          TO ins_v_aper-rabzus.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_APER'
                                                ins_v_aper
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_APER'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'DDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_DDIS
          MOVE-CORRESPONDING ins_facts TO ins_f_ddis.
          MOVE 'X' TO ins_f_ddis-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DDIS'
                                                  ins_f_ddis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DDIS'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_DDIS
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_ddis.
        MOVE ins_facts-string1          TO ins_v_ddis-rabzus.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DDIS'
                                                ins_v_ddis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DDIS'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'PDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_PDIS
          MOVE-CORRESPONDING ins_facts TO ins_f_pdis.
          MOVE 'X' TO ins_f_pdis-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_PDIS'
                                                  ins_f_pdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_PDIS'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_PDIS
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_pdis.
        MOVE ins_facts-string1          TO ins_v_pdis-rabzus.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_PDIS'
                                                ins_v_pdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_PDIS'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_QDIS
          MOVE-CORRESPONDING ins_facts TO ins_f_qdis.
          MOVE 'X' TO ins_f_qdis-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QDIS'
                                                  ins_f_qdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QDIS'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_QDIS
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_qdis.
        MOVE ins_facts-string1          TO ins_v_qdis-rabzus.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QDIS'
                                                ins_v_qdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QDIS'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'LPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_LPRI
          MOVE-CORRESPONDING ins_facts TO ins_f_lpri.
          MOVE 'X' TO ins_f_lpri-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_LPRI'
                                                  ins_f_lpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_LPRI'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_LPRI
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_lpri.
        MOVE ins_facts-string1       TO ins_v_lpri-preis.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_LPRI'
                                                ins_v_lpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_LPRI'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'SPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_SPRI
          MOVE-CORRESPONDING ins_facts TO ins_f_spri.
          MOVE 'X' TO ins_f_spri-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_SPRI'
                                                  ins_f_spri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_SPRI'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_SPRI
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_spri.
        MOVE ins_facts-string1       TO ins_v_spri-preistuf.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_SPRI'
                                                ins_v_spri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_SPRI'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_TPRI
          MOVE-CORRESPONDING ins_facts TO ins_f_tpri.
          MOVE 'X' TO ins_f_tpri-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TPRI'
                                                  ins_f_tpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TPRI'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_TPRI
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_tpri.
        MOVE ins_facts-string1       TO ins_v_tpri-preis.
        MOVE ins_facts-betrag        TO ins_v_tpri-prsbtr.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TPRI'
                                                ins_v_tpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TPRI'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'USERDEF'.
        IF  op_old IS INITIAL OR
            op_old NE ins_facts-operand.
*F_UDEF
          MOVE-CORRESPONDING ins_facts TO ins_f_udef.
          MOVE 'X' TO ins_f_udef-auto_insert.
          CLEAR: i_ins_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_UDEF'
                                                  ins_f_udef
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_UDEF'  TO i_ins_down-dttyp.
          MOVE oldkey    TO i_ins_down-oldkey.
          MOVE y_data    TO i_ins_down-data.
          APPEND i_ins_down.
        ENDIF.

*V_UDEF
*        LOOP AT ins_facts WHERE operand EQ wins_facts-operand.
        MOVE-CORRESPONDING ins_facts TO ins_v_udef.
        MOVE ins_facts-wert1         TO ins_v_udef-udefval1.
        MOVE ins_facts-wert2         TO ins_v_udef-udefval2.
        MOVE ins_facts-string1       TO ins_v_udef-udefval3.
        MOVE ins_facts-string2       TO ins_v_udef-udefval4.
        CLEAR: i_ins_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_UDEF'
                                                ins_v_udef
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_UDEF'  TO i_ins_down-dttyp.
        MOVE oldkey    TO i_ins_down-oldkey.
        MOVE y_data    TO i_ins_down-data.
        APPEND i_ins_down.

        op_old = ins_facts-operand.
*        ENDLOOP.

    ENDCASE.

  ENDLOOP.


* POD (muss zuletzt)
  LOOP AT ins_pod.
    CLEAR: i_ins_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'POD'
                                            ins_pod
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'POD'     TO i_ins_down-dttyp.
    MOVE oldkey    TO i_ins_down-oldkey.
    MOVE y_data    TO i_ins_down-data.
    APPEND i_ins_down.

  ENDLOOP.

  IF panlcount >= panlanz.

    CLEAR: ins_facts, wins_facts.
    REFRESH: ins_facts.

    CLEAR: ins_key, ins_data, ins_rcat, ins_pod, ins_f_quan, ins_f_dema,
           ins_f_tqua, ins_f_qpri, ins_f_amou, ins_f_fact, ins_f_flag,
           ins_f_inte, ins_f_rate, ins_f_aabs, ins_f_aper, ins_f_ddis,
           ins_f_pdis, ins_f_qdis, ins_f_lpri, ins_f_spri, ins_f_tpri,
           ins_f_udef, ins_v_quan, ins_v_dema, ins_v_tqua, ins_v_qpri,
           ins_v_amou, ins_v_fact, ins_v_flag, ins_v_inte, ins_v_rate,
           ins_v_aabs, ins_v_aper, ins_v_ddis, ins_v_pdis, ins_v_qdis,
           ins_v_lpri, ins_v_spri, ins_v_tpri, ins_v_udef.

    REFRESH: ins_key, ins_data, ins_rcat, ins_pod, ins_f_quan, ins_f_dema,
               ins_f_tqua, ins_f_qpri, ins_f_amou, ins_f_fact, ins_f_flag,
               ins_f_inte, ins_f_rate, ins_f_aabs, ins_f_aper, ins_f_ddis,
               ins_f_pdis, ins_f_qdis, ins_f_lpri, ins_f_spri, ins_f_tpri,
               ins_f_udef, ins_v_quan, ins_v_dema, ins_v_tqua, ins_v_qpri,
               ins_v_amou, ins_v_fact, ins_v_flag, ins_v_inte, ins_v_rate,
               ins_v_aabs, ins_v_aper, ins_v_ddis, ins_v_pdis, ins_v_qdis,
                   ins_v_lpri, ins_v_spri, ins_v_tpri, ins_v_udef.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ERST_MIG_DATEI3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_INS_DOWN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_IDTTYP  text
*      -->P_BEL_FILE  text
*----------------------------------------------------------------------*
FORM erst_mig_datei3  TABLES   idown STRUCTURE /adesso/mt_down_mig_obj
                    USING    p_firma
                             p_object
                             p_idttyp
                             p_bel_file.

  FIELD-SYMBOLS: <f>.
  DATA: wa_info LIKE teminfo.
  DATA: s_laenge(2) TYPE x.  "Satzlänge (HEX)
  DATA: s_oldkey LIKE /adesso/mt_down_mig_obj-oldkey.

  DATA: BEGIN OF wa_satz,
          reclength(1) TYPE c.              "Test Nuss 14.09.2015
*          reclength(2)  type c.            "Test Nuss 14.09.2015
          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
  DATA: END OF wa_satz.



  OPEN DATASET p_bel_file FOR OUTPUT IN BINARY MODE.


*> Kopf der Datei erzeugen
  CLEAR wa_info.
  wa_info-firma  = p_firma.
  wa_info-object = p_object.
  wa_info-uname  = sy-uname.
  wa_info-datum  = sy-datum.
  wa_info-uzeit  = sy-uzeit.
  CLEAR wa_satz.
  wa_satz-oldkey   = space.
  wa_satz-dttyp    = '&INFO'.
  wa_satz-data     = wa_info.
  s_laenge         = strlen( wa_satz ).
  wa_satz-reclength = s_laenge.
  ASSIGN wa_satz(s_laenge) TO <f>.
  TRANSFER <f>   TO p_bel_file.
* <

* Datensätze mit jeweiligem Satzende erzeugen
  LOOP AT idown.

    IF sy-tabix > 1.
      IF idown-dttyp EQ p_idttyp.
*>     Endesatz erzeugen
        wa_satz-oldkey   = s_oldkey.
        wa_satz-dttyp    = '&ENDE'.
        wa_satz-data     = space.
        s_laenge         = strlen( wa_satz ).
        wa_satz-reclength = s_laenge.
        ASSIGN wa_satz(s_laenge) TO <f>.
        TRANSFER <f>   TO p_bel_file.
*<
      ENDIF.
    ENDIF.

*> Datensätze erzeugen
    s_oldkey         = idown-oldkey.
    wa_satz-oldkey   = idown-oldkey.
    wa_satz-dttyp    = idown-dttyp.
    wa_satz-data     = idown-data.
    s_laenge         = strlen( wa_satz ).
    wa_satz-reclength = s_laenge.
    ASSIGN wa_satz(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file.
*<
  ENDLOOP.

  IF sy-subrc EQ 0.
* Endedatensatz des letzten Altsystemschlüssels erzeugen
    wa_satz-oldkey   = s_oldkey.
    wa_satz-dttyp    = '&ENDE'.
    wa_satz-data     = space.
    s_laenge         = strlen( wa_satz ).
    wa_satz-reclength = s_laenge.
    ASSIGN wa_satz(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file.
*<
  ENDIF.


  CLOSE DATASET p_bel_file.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_ICH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ICH  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_ich  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  DATA: op_old LIKE /adesso/mt_facts-operand.

* Migrationsreihenfolge der Fakten bestimmen

  LOOP AT ich_facts.

    CASE ich_facts-optyp.

      WHEN 'QUANT'.
        MOVE '01' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'DEMAND'.
        MOVE '02' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'TQUANT'.
        MOVE '03' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'QPRICE'.
        MOVE '04' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'AMOUNT'.
        MOVE '05' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'FACTOR'.
        MOVE '06' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'FLAG'.
        MOVE '07' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'INTEGER'.
        MOVE '08' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'RATETYPE'.
        MOVE '09' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'ADISCABS'.
        MOVE '10' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'ADISCPER'.
        MOVE '11' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'DDISCNT'.
        MOVE '12' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'PDISCNT'.
        MOVE '13' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'QDISCNT'.
        MOVE '14' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'LPRICE'.
        MOVE '15' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'SPRICE'.
        MOVE '16' TO ich_facts-nummer.
        MODIFY ich_facts.
      WHEN 'TPRICE'.
        MOVE '17' TO ich_facts-nummer.
        MODIFY ich_facts.

    ENDCASE.

  ENDLOOP.

* sortieren der Fakten in die richtige Migrationsreihenfolge
  SORT ich_facts BY nummer operand ab.



  LOOP AT ich_key.
    CLEAR: i_ich_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            ich_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_ich_down-dttyp.
    MOVE oldkey    TO i_ich_down-oldkey.
    MOVE y_data    TO i_ich_down-data.
    APPEND i_ich_down.

  ENDLOOP.

  LOOP AT ich_data.
    CLEAR: i_ich_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DATA'
                                            ich_data
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DATA'    TO i_ich_down-dttyp.
    MOVE oldkey    TO i_ich_down-oldkey.
    MOVE y_data    TO i_ich_down-data.
    APPEND i_ich_down.

  ENDLOOP.

  LOOP AT ich_rcat.
    CLEAR: i_ich_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'RCAT'
                                            ich_rcat
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'RCAT'    TO i_ich_down-dttyp.
    MOVE oldkey    TO i_ich_down-oldkey.
    MOVE y_data    TO i_ich_down-data.
    APPEND i_ich_down.

  ENDLOOP.



  CLEAR: ich_facts, wich_facts.

  LOOP AT ich_facts." INTO wich_facts.

    CASE ich_facts-optyp.
      WHEN 'QUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_QUAN
          MOVE-CORRESPONDING ich_facts TO ich_f_quan.
          MOVE 'X' TO ich_f_quan-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QUAN'
                                                  ich_f_quan
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QUAN'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_QUAN
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_quan.
        MOVE ich_facts-wert1 TO  ich_v_quan-menge.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QUAN'
                                                ich_v_quan
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QUAN'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.

*---------------------------------------------------------------------
      WHEN 'DEMAND'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_DEMA
          MOVE-CORRESPONDING ich_facts TO ich_f_dema.
          MOVE 'X' TO ich_f_dema-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DEMA'
                                                  ich_f_dema
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DEMA'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_DEMA
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_dema.
        MOVE ich_facts-wert1 TO  ich_v_dema-lmenge.
        MOVE ich_facts-wert2 TO  ich_v_dema-lmenge2.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DEMA'
                                                ich_v_dema
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DEMA'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TQUANT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_TQUA
          MOVE-CORRESPONDING ich_facts TO ich_f_tqua.
          MOVE 'X' TO ich_f_tqua-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TQUA'
                                                  ich_f_tqua
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TQUA'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_TQUA
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_tqua.
        MOVE ich_facts-wert1 TO  ich_v_tqua-menge.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TQUA'
                                                ich_v_tqua
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TQUA'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_QPRI
          MOVE-CORRESPONDING ich_facts TO ich_f_qpri.
          MOVE 'X' TO ich_f_qpri-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QPRI'
                                                  ich_f_qpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QPRI'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_QPRI
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_qpri.
        MOVE ich_facts-string1 TO  ich_v_qpri-preis.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QPRI'
                                                ich_v_qpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QPRI'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'AMOUNT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_AMOU
          MOVE-CORRESPONDING ich_facts TO ich_f_amou.
          MOVE 'X' TO ich_f_amou-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AMOU'
                                                  ich_f_amou
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AMOU'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_AMOU
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_amou.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AMOU'
                                                ich_v_amou
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AMOU'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FACTOR'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_FACT
          MOVE-CORRESPONDING ich_facts TO ich_f_fact.
          MOVE 'X' TO ich_f_fact-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FACT'
                                                  ich_f_fact
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FACT'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_FACT
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_fact.
        MOVE ich_facts-wert1         TO ich_v_fact-factor.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FACT'
                                                ich_v_fact
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FACT'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'FLAG'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_FLAG
          MOVE-CORRESPONDING ich_facts TO ich_f_flag.
          MOVE 'X' TO ich_f_flag-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_FLAG'
                                                  ich_f_flag
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_FLAG'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_FLAG
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_flag.
        MOVE ich_facts-string3       TO ich_v_flag-boolkz.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_FLAG'
                                                ich_v_flag
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_FLAG'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'INTEGER'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_INTE
          MOVE-CORRESPONDING ich_facts TO ich_f_inte.
          MOVE 'X' TO ich_f_inte-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_INTE'
                                                  ich_f_inte
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_INTE'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_INTE
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_inte.
        MOVE ich_facts-wert1         TO ich_v_inte-integer4.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_INTE'
                                                ich_v_inte
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_INTE'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'RATETYPE'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_RATE
          MOVE-CORRESPONDING ich_facts TO ich_f_rate.
          MOVE 'X' TO ich_f_rate-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_RATE'
                                                  ich_f_rate
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_RATE'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_RATE
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_rate.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_RATE'
                                                ich_v_rate
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_RATE'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.



*---------------------------------------------------------------------
      WHEN 'ADISCABS'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_AABS
          MOVE-CORRESPONDING ich_facts TO ich_f_aabs.
          MOVE 'X' TO ich_f_aabs-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_AABS'
                                                  ich_f_aabs
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_AABS'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_AABS
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_aabs.
        MOVE ich_facts-string1          TO ich_v_aabs-rabzus.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_AABS'
                                                ich_v_aabs
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_AABS'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'ADISCPER'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_APER
          MOVE-CORRESPONDING ich_facts TO ich_f_aper.
          MOVE 'X' TO ich_f_aper-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_APER'
                                                  ich_f_aper
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_APER'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_APER
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_aper.
        MOVE ich_facts-string1          TO ich_v_aper-rabzus.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_APER'
                                                ich_v_aper
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_APER'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'DDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_DDIS
          MOVE-CORRESPONDING ich_facts TO ich_f_ddis.
          MOVE 'X' TO ich_f_ddis-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_DDIS'
                                                  ich_f_ddis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_DDIS'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_DDIS
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_ddis.
        MOVE ich_facts-string1          TO ich_v_ddis-rabzus.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_DDIS'
                                                ich_v_ddis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_DDIS'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'PDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_PDIS
          MOVE-CORRESPONDING ich_facts TO ich_f_pdis.
          MOVE 'X' TO ich_f_pdis-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_PDIS'
                                                  ich_f_pdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_PDIS'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_PDIS
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_pdis.
        MOVE ich_facts-string1          TO ich_v_pdis-rabzus.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_PDIS'
                                                ich_v_pdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_PDIS'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'QDISCNT'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_QDIS
          MOVE-CORRESPONDING ich_facts TO ich_f_qdis.
          MOVE 'X' TO ich_f_qdis-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_QDIS'
                                                  ich_f_qdis
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_QDIS'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_QDIS
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_qdis.
        MOVE ich_facts-string1          TO ich_v_qdis-rabzus.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_QDIS'
                                                ich_v_qdis
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_QDIS'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'LPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_LPRI
          MOVE-CORRESPONDING ich_facts TO ich_f_lpri.
          MOVE 'X' TO ich_f_lpri-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_LPRI'
                                                  ich_f_lpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_LPRI'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_LPRI
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_lpri.
        MOVE ich_facts-string1       TO ich_v_lpri-preis.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_LPRI'
                                                ich_v_lpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_LPRI'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'SPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_SPRI
          MOVE-CORRESPONDING ich_facts TO ich_f_spri.
          MOVE 'X' TO ich_f_spri-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_SPRI'
                                                  ich_f_spri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_SPRI'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_SPRI
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_spri.
        MOVE ich_facts-string1       TO ich_v_spri-preistuf.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_SPRI'
                                                ich_v_spri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_SPRI'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.


*---------------------------------------------------------------------
      WHEN 'TPRICE'.
        IF  op_old IS INITIAL OR
            op_old NE ich_facts-operand.
*F_TPRI
          MOVE-CORRESPONDING ich_facts TO ich_f_tpri.
          MOVE 'X' TO ich_f_tpri-auto_insert.
          CLEAR: i_ich_down, y_data, regel_kz.
          PERFORM (formname) IN PROGRAM (repname)
                                                  USING 'F_TPRI'
                                                  ich_f_tpri
                                                  y_data
                                                  regel_kz.
          CHECK NOT y_data IS INITIAL
                 OR regel_kz NE '3'.
          MOVE 'F_TPRI'  TO i_ich_down-dttyp.
          MOVE oldkey    TO i_ich_down-oldkey.
          MOVE y_data    TO i_ich_down-data.
          APPEND i_ich_down.
        ENDIF.

*V_TPRI
*        LOOP AT ich_facts WHERE operand EQ wich_facts-operand.
        MOVE-CORRESPONDING ich_facts TO ich_v_tpri.
        MOVE ich_facts-string1       TO ich_v_tpri-preis.
        MOVE ich_facts-betrag        TO ich_v_tpri-prsbtr.
        CLEAR: i_ich_down, y_data, regel_kz.
        PERFORM (formname) IN PROGRAM (repname)
                                                USING 'V_TPRI'
                                                ich_v_tpri
                                                y_data
                                                regel_kz.
        CHECK NOT y_data IS INITIAL
               OR regel_kz NE '3'.
        MOVE 'V_TPRI'  TO i_ich_down-dttyp.
        MOVE oldkey    TO i_ich_down-oldkey.
        MOVE y_data    TO i_ich_down-data.
        APPEND i_ich_down.

        op_old = ich_facts-operand.
*        ENDLOOP.

    ENDCASE.

  ENDLOOP.



  CLEAR: ich_facts, wich_facts.
  REFRESH: ich_facts.


  CLEAR: ich_key, ich_data, ich_rcat, ich_f_quan, ich_f_dema,
         ich_f_tqua, ich_f_qpri, ich_f_amou, ich_f_fact, ich_f_flag,
         ich_f_inte, ich_f_rate, ich_f_aabs, ich_f_aper, ich_f_ddis,
         ich_f_pdis, ich_f_qdis, ich_f_lpri, ich_f_spri, ich_f_tpri,
         ich_v_quan, ich_v_dema, ich_v_tqua, ich_v_qpri,
         ich_v_amou, ich_v_fact, ich_v_flag, ich_v_inte, ich_v_rate,
         ich_v_aabs, ich_v_aper, ich_v_ddis, ich_v_pdis, ich_v_qdis,
         ich_v_lpri, ich_v_spri, ich_v_tpri.

  REFRESH: ich_key, ich_data, ich_rcat, ich_f_quan, ich_f_dema,
         ich_f_tqua, ich_f_qpri, ich_f_amou, ich_f_fact, ich_f_flag,
         ich_f_inte, ich_f_rate, ich_f_aabs, ich_f_aper, ich_f_ddis,
         ich_f_pdis, ich_f_qdis, ich_f_lpri, ich_f_spri, ich_f_tpri,
         ich_v_quan, ich_v_dema, ich_v_tqua, ich_v_qpri,
         ich_v_amou, ich_v_fact, ich_v_flag, ich_v_inte, ich_v_rate,
         ich_v_aabs, ich_v_aper, ich_v_ddis, ich_v_pdis, ich_v_qdis,
         ich_v_lpri, ich_v_spri, ich_v_tpri.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_IPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_IPL  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_ipl  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ipl_ipkey.
    CLEAR: i_ipl_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'IPKEY'
                                            ipl_ipkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'IPKEY'   TO i_ipl_down-dttyp.
    MOVE oldkey    TO i_ipl_down-oldkey.
    MOVE y_data    TO i_ipl_down-data.
    APPEND i_ipl_down.

  ENDLOOP.

  LOOP AT ipl_ipdata.
    CLEAR: i_ipl_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'IPDATA'
                                            ipl_ipdata
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'IPDATA'  TO i_ipl_down-dttyp.
    MOVE oldkey    TO i_ipl_down-oldkey.
    MOVE y_data    TO i_ipl_down-data.
    APPEND i_ipl_down.

  ENDLOOP.

  LOOP AT ipl_ipopky.
    CLEAR: i_ipl_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'IPOPKY'
                                            ipl_ipopky
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'IPOPKY'  TO i_ipl_down-dttyp.
    MOVE oldkey    TO i_ipl_down-oldkey.
    MOVE y_data    TO i_ipl_down-data.
    APPEND i_ipl_down.

  ENDLOOP.

  CLEAR: ipl_ipkey, ipl_ipdata, ipl_ipopky.
  REFRESH: ipl_ipkey, ipl_ipdata, ipl_ipopky.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_INM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INM  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_inm  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT inm_di_int.
    CLEAR: i_inm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DI_INT'
                                            inm_di_int
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DI_INT'  TO i_inm_down-dttyp.
    MOVE oldkey    TO i_inm_down-oldkey.
    MOVE y_data    TO i_inm_down-data.
    APPEND i_inm_down.

  ENDLOOP.

  LOOP AT inm_di_zw.
    CLEAR: i_inm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DI_ZW'
                                            inm_di_zw
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DI_ZW'   TO i_inm_down-dttyp.
    MOVE oldkey    TO i_inm_down-oldkey.
    MOVE y_data    TO i_inm_down-data.
    APPEND i_inm_down.

  ENDLOOP.

  LOOP AT inm_di_ger.
    CLEAR: i_inm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DI_GER'
                                            inm_di_ger
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DI_GER'  TO i_inm_down-dttyp.
    MOVE oldkey    TO i_inm_down-oldkey.
    MOVE y_data    TO i_inm_down-data.
    APPEND i_inm_down.

  ENDLOOP.

  LOOP AT inm_di_cnt.
    CLEAR: i_inm_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DI_CNT'
                                            inm_di_cnt
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DI_CNT'  TO i_inm_down-dttyp.
    MOVE oldkey    TO i_inm_down-oldkey.
    MOVE y_data    TO i_inm_down-data.
    APPEND i_inm_down.

  ENDLOOP.


  CLEAR: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.
  REFRESH: inm_di_int, inm_di_zw, inm_di_ger, inm_di_cnt.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_LOP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_LOP  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_lop  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ilop_key.
    CLEAR: i_lop_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            ilop_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'  TO i_lop_down-dttyp.
    MOVE oldkey    TO i_lop_down-oldkey.
    MOVE y_data    TO i_lop_down-data.
    APPEND i_lop_down.

  ENDLOOP.


  LOOP AT ilop_elpass.
    CLEAR: i_lop_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ELPASS'
                                            ilop_elpass
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ELPASS'  TO i_lop_down-dttyp.
    MOVE oldkey    TO i_lop_down-oldkey.
    MOVE y_data    TO i_lop_down-data.
    APPEND i_lop_down.

  ENDLOOP.

  CLEAR: ilop_key, ilop_elpass.
  REFRESH: ilop_key, ilop_elpass.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_LOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_LOT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_lot  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ilot_lotd.
    CLEAR: i_lot_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'LOTD'
                                            ilot_lotd
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'LOTD'    TO i_lot_down-dttyp.
    MOVE oldkey    TO i_lot_down-oldkey.
    MOVE y_data    TO i_lot_down-data.
    APPEND i_lot_down.

  ENDLOOP.

  CLEAR: ilot_lotd.
  REFRESH: ilot_lotd.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_MRD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MRD  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_mrd  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT imrd_ieablu.
    CLEAR: i_mrd_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'IEABLU'
                                            imrd_ieablu
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'IEABLU'  TO i_mrd_down-dttyp.
    MOVE oldkey    TO i_mrd_down-oldkey.
    MOVE y_data    TO i_mrd_down-data.
    APPEND i_mrd_down.

  ENDLOOP.

  CLEAR: imrd_ieablu.
  REFRESH: imrd_ieablu.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_MOI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOI  text
*      -->P_VERCOUNT  text
*      -->P_VERANZ  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_moi  USING    oldkey
                                   pvercount
                                   pveranz
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT imoi_ever.
    CLEAR: i_moi_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EVER'
                                            imoi_ever
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EVER'   TO i_moi_down-dttyp.
    MOVE oldkey   TO i_moi_down-oldkey.
    MOVE y_data   TO i_moi_down-data.
    APPEND i_moi_down.

  ENDLOOP.

  IF pvercount >= pveranz.
    CLEAR: imoi_ever, imoi_ever2.
    REFRESH: imoi_ever, imoi_ever2.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_NOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_NOC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_noc  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT inoc_key.
    CLEAR: i_noc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            inoc_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_noc_down-dttyp.
    MOVE oldkey    TO i_noc_down-oldkey.
    MOVE y_data    TO i_noc_down-data.
    APPEND i_noc_down.

  ENDLOOP.


  LOOP AT inoc_notes.
    CLEAR: i_noc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTES'
                                            inoc_notes
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTES'     TO i_noc_down-dttyp.
    MOVE oldkey    TO i_noc_down-oldkey.
    MOVE y_data    TO i_noc_down-data.
    APPEND i_noc_down.

  ENDLOOP.


  LOOP AT inoc_text.
    CLEAR: i_noc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'TEXT'
                                            inoc_text
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'TEXT'     TO i_noc_down-dttyp.
    MOVE oldkey    TO i_noc_down-oldkey.
    MOVE y_data    TO i_noc_down-data.
    APPEND i_noc_down.

  ENDLOOP.

  CLEAR: inoc_key, inoc_notes, inoc_text.
  REFRESH: inoc_key, inoc_notes, inoc_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_NOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_NOD  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_nod  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT inod_key.
    CLEAR: i_nod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            inod_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_nod_down-dttyp.
    MOVE oldkey    TO i_nod_down-oldkey.
    MOVE y_data    TO i_nod_down-data.
    APPEND i_nod_down.

  ENDLOOP.


  LOOP AT inod_notes.
    CLEAR: i_nod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTES'
                                            inod_notes
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTES'   TO i_nod_down-dttyp.
    MOVE oldkey    TO i_nod_down-oldkey.
    MOVE y_data    TO i_nod_down-data.
    APPEND i_nod_down.

  ENDLOOP.


  LOOP AT inod_text.
    CLEAR: i_nod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'TEXT'
                                            inod_text
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'TEXT'    TO i_nod_down-dttyp.
    MOVE oldkey    TO i_nod_down-oldkey.
    MOVE y_data    TO i_nod_down-data.
    APPEND i_nod_down.

  ENDLOOP.

  CLEAR: inod_key, inod_notes, inod_text.
  REFRESH: inod_key, inod_notes, inod_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_PARTNER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PARTNER  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_partner  USING  oldkey
                                     repname
                                     formname.



  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_init.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'INIT'
                                            i_init
                                            y_data
                                            regel_kz.
* Es ist eine Muss-Struktur      MA050808
*    CHECK NOT y_data IS INITIAL
*           OR regel_kz NE '3'.
    MOVE 'INIT' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_ekun.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EKUN'
                                            i_ekun
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EKUN' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but000.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT000'
                                            i_but000
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
       OR regel_kz NE '3'.
    MOVE 'BUT000' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_butcom.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                  USING 'BUTCOM'
                                  i_butcom
                                  y_data
                                  regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUTCOM' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but001.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT001'
                                            i_but001
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT001' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but0bk.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT0BK'
                                            i_but0bk
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT0BK' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but020.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT020'
                                            i_but020
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT020' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but021.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT021'
                                            i_but021
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT021' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_but0cc.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'BUT0CC'
                                            i_but0cc
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT0CC' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_shipto.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'SHIPTO'
                                            i_shipto
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'SHIPTO' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_taxnum.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'TAXNUM'
                                            i_taxnum
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'TAXNUM' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_eccard.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ECCARD'
                                            i_eccard
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ECCARD' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  LOOP AT i_eccrdh.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ECCRDH'
                                            i_eccrdh
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ECCRDH' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.


  LOOP AT i_but0is.
    CLEAR: i_par_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                         USING 'BUT0IS'
                                                i_but0is
                                                y_data
                                                regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'BUT0IS' TO i_par_down-dttyp.
    MOVE oldkey TO i_par_down-oldkey.
    MOVE y_data TO i_par_down-data.
    APPEND i_par_down.
  ENDLOOP.

  CLEAR:  i_init,
          i_ekun,
          i_but000,
          i_but001,
          i_but0bk,
          i_but020,
          i_but021,
          i_but0cc,
          i_shipto,
          i_taxnum,
          i_eccard,
          i_eccrdh,
          i_but0is,
          i_butcom.

  REFRESH:  i_init,
          i_ekun,
          i_but000,
          i_but001,
          i_but0bk,
          i_but020,
          i_but021,
          i_but0cc,
          i_shipto,
          i_taxnum,
          i_eccard,
          i_eccrdh,
          i_but0is,
          i_butcom.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_PNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PNO  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_pno  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_notkey.
    CLEAR: i_pno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTKEY'
                                            i_notkey
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTKEY'  TO i_pno_down-dttyp.
    MOVE oldkey    TO i_pno_down-oldkey.
    MOVE y_data    TO i_pno_down-data.
    APPEND i_pno_down.

  ENDLOOP.


  LOOP AT i_notlin.
    CLEAR: i_pno_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'NOTLIN'
                                            i_notlin
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'NOTLIN'  TO i_pno_down-dttyp.
    MOVE oldkey    TO i_pno_down-oldkey.
    MOVE y_data    TO i_pno_down-data.
    APPEND i_pno_down.

  ENDLOOP.

  CLEAR: i_notkey, i_notlin.
  REFRESH: i_notkey, i_notlin.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_POD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_POD  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_pod  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ipod_uihead.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIHEAD'
                                            ipod_uihead
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIHEAD'  TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.

  LOOP AT ipod_uisrc.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UISRC'
                                            ipod_uisrc
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UISRC'   TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.

  LOOP AT ipod_uitanl.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UITANL'
                                            ipod_uitanl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UITANL'  TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.

  LOOP AT ipod_zwnumm.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'ZWNUMM'
                                            ipod_zwnumm
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'ZWNUMM'  TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.

  LOOP AT ipod_uiext.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIEXT'
                                            ipod_uiext
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIEXT'   TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.

  LOOP AT ipod_uigrid.
    CLEAR: i_pod_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIGRID'
                                            ipod_uigrid
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIGRID'  TO i_pod_down-dttyp.
    MOVE oldkey    TO i_pod_down-oldkey.
    MOVE y_data    TO i_pod_down-data.
    APPEND i_pod_down.

  ENDLOOP.


  CLEAR: ipod_uihead, ipod_uisrc, ipod_uitanl, ipod_zwnumm,
         ipod_uiext, ipod_uigrid.
  REFRESH: ipod_uihead, ipod_uisrc, ipod_uitanl, ipod_zwnumm,
         ipod_uiext, ipod_uigrid.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_POC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_POC  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_poc  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ipoc_uihead.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIHEAD'
                                            ipoc_uihead
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIHEAD'  TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.

  LOOP AT ipoc_uisrc.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UISRC'
                                            ipoc_uisrc
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UISRC'   TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.

  LOOP AT ipoc_uitanl.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UITANL'
                                            ipoc_uitanl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UITANL'  TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.

  LOOP AT ipoc_uitlzw.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UITLZW'
                                            ipoc_uitlzw
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UITLZW'  TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.

  LOOP AT ipoc_uiext.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIEXT'
                                            ipoc_uiext
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIEXT'   TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.

  LOOP AT ipoc_uigrid.
    CLEAR: i_poc_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'UIGRID'
                                            ipoc_uigrid
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'UIGRID'  TO i_poc_down-dttyp.
    MOVE oldkey    TO i_poc_down-oldkey.
    MOVE y_data    TO i_poc_down-data.
    APPEND i_poc_down.

  ENDLOOP.


  CLEAR: ipoc_uihead, ipoc_uisrc, ipoc_uitanl, ipoc_uitlzw,
         ipoc_uiext, ipoc_uigrid.
  REFRESH: ipoc_uihead, ipoc_uisrc, ipoc_uitanl, ipoc_uitlzw,
         ipoc_uiext, ipoc_uigrid.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_POS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_POS  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_pos  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT ipos_podsrv.
    CLEAR: i_pos_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'PODSRV'
                                            ipos_podsrv
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'PODSRV'  TO i_pos_down-dttyp.
    MOVE oldkey    TO i_pos_down-oldkey.
    MOVE y_data    TO i_pos_down-data.
    APPEND i_pos_down.

  ENDLOOP.

  LOOP AT ipos_psvsel.
    CLEAR: i_pos_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'PSVSEL'
                                            ipos_psvsel
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'PSVSEL'  TO i_pos_down-dttyp.
    MOVE oldkey    TO i_pos_down-oldkey.
    MOVE y_data    TO i_pos_down-data.
    APPEND i_pos_down.

  ENDLOOP.

  CLEAR: ipos_podsrv, ipos_psvsel.
  REFRESH: ipos_podsrv, ipos_psvsel.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ERST_MIG_DATEI_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_POS_DOWN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_IDTTYP  text
*      -->P_BEL_FILE  text
*----------------------------------------------------------------------*
FORM erst_mig_datei_2  TABLES   idown STRUCTURE /adesso/mt_down_mig_obj
                       USING   p_firma
                               p_object
                               p_idttyp
                               p_bel_file.

  FIELD-SYMBOLS: <f>.
  DATA: wa_info LIKE teminfo.
  DATA: s_laenge(2) TYPE x.  "Satzlänge (HEX)
  DATA: s_oldkey LIKE /adesso/mt_down_mig_obj-oldkey.

  DATA: BEGIN OF wa_satz,
          reclength(2) TYPE c.
          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
  DATA: END OF wa_satz.

  DATA: check_old LIKE /adesso/mt_down_mig_obj-oldkey.


  OPEN DATASET p_bel_file FOR OUTPUT IN BINARY MODE.

*> Kopf der Datei erzeugen
  CLEAR wa_info.
  wa_info-firma  = p_firma.
  wa_info-object = p_object.
  wa_info-uname  = sy-uname.
  wa_info-datum  = sy-datum.
  wa_info-uzeit  = sy-uzeit.
  CLEAR wa_satz.
  wa_satz-oldkey   = space.
  wa_satz-dttyp    = '&INFO'.
  wa_satz-data     = wa_info.
  s_laenge         = strlen( wa_satz ).
  wa_satz-reclength = s_laenge.
  ASSIGN wa_satz(s_laenge) TO <f>.
  TRANSFER <f>   TO p_bel_file.
* <

* Datensätze mit jeweiligem Satzende erzeugen
  LOOP AT idown.

    IF sy-tabix > 1.
*      IF idown-dttyp EQ p_idttyp.
* jetzt Abfrage auf Oldkey weil p_idttyp mehrmals pro Kunde sein kann
* (multiple)
      IF idown-oldkey NE check_old.
*>     Endesatz erzeugen
        wa_satz-oldkey   = s_oldkey.
        wa_satz-dttyp    = '&ENDE'.
        wa_satz-data     = space.
        s_laenge         = strlen( wa_satz ).
        wa_satz-reclength = s_laenge.
        ASSIGN wa_satz(s_laenge) TO <f>.
        TRANSFER <f>   TO p_bel_file.
*<
      ENDIF.
    ENDIF.

*> Datensätze erzeugen
    s_oldkey         = idown-oldkey.
    wa_satz-oldkey   = idown-oldkey.
    wa_satz-dttyp    = idown-dttyp.
    wa_satz-data     = idown-data.
    s_laenge         = strlen( wa_satz ).
    wa_satz-reclength = s_laenge.
    ASSIGN wa_satz(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file.

    check_old        = idown-oldkey.

*<
  ENDLOOP.

  IF sy-subrc EQ 0.
* Endedatensatz des letzten Altsystemschlüssels erzeugen
    wa_satz-oldkey   = s_oldkey.
    wa_satz-dttyp    = '&ENDE'.
    wa_satz-data     = space.
    s_laenge         = strlen( wa_satz ).
    wa_satz-reclength = s_laenge.
    ASSIGN wa_satz(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file.
*<
  ENDIF.


  CLOSE DATASET p_bel_file.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_PRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_PRE  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_pre  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_evbsd.
    CLEAR: i_pre_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EVBSD'
                                            i_evbsd
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EVBSD'  TO i_pre_down-dttyp.
    MOVE oldkey   TO i_pre_down-oldkey.
    MOVE y_data   TO i_pre_down-data.
    APPEND i_pre_down.

  ENDLOOP.

  CLEAR: i_evbsd.
  REFRESH: i_evbsd.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_RVA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_RVA  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_rva  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  SORT irva_ettifb BY operand oplfdnr ab.

  READ TABLE irva_ettifb INDEX 1.
*Key
  MOVE-CORRESPONDING irva_ettifb TO irva_key.
  MOVE '99991231' TO irva_key-bis.
  CLEAR: i_rva_down, y_data, regel_kz.
  PERFORM (formname) IN PROGRAM (repname)
                                          USING 'KEY'
                                          irva_key
                                          y_data
                                          regel_kz.
  CHECK NOT y_data IS INITIAL
         OR regel_kz NE '3'.
  MOVE 'KEY'     TO i_rva_down-dttyp.
  MOVE oldkey    TO i_rva_down-oldkey.
  MOVE y_data    TO i_rva_down-data.
  APPEND i_rva_down.


* ETTIFB-Daten zuweisen
  LOOP AT irva_ettifb.
* irva_refva
    MOVE-CORRESPONDING irva_ettifb TO irva_refval.
    CLEAR: i_rva_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'REFVAL'
                                            irva_refval
                                            y_data
                                            regel_kz.
    IF NOT y_data IS INITIAL
        OR regel_kz NE '3'.
      MOVE 'REFVAL'  TO i_rva_down-dttyp.
      MOVE oldkey    TO i_rva_down-oldkey.
      MOVE y_data    TO i_rva_down-data.
      APPEND i_rva_down.
    ENDIF.


** irva_tre
*    MOVE-CORRESPONDING irva_ettifb TO irva_tre.
*    MOVE irva_ettifb-equnr TO irva_tre-equnr_t.
*    CLEAR: i_rva_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'TRE'
*                                            irva_tre
*                                            y_data.
*    IF NOT y_data IS INITIAL.
*      MOVE 'TRE'     TO i_rva_down-dttyp.
*      MOVE oldkey    TO i_rva_down-oldkey.
*      MOVE y_data    TO i_rva_down-data.
*      APPEND i_rva_down.
*    ENDIF.

** irva_bart
*    MOVE-CORRESPONDING irva_ettifb TO irva_bart.
*    CLEAR: i_rva_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'BART'
*                                            irva_bart
*                                            y_data.
*    IF NOT y_data IS INITIAL.
*      MOVE 'BART'    TO i_rva_down-dttyp.
*      MOVE oldkey    TO i_rva_down-oldkey.
*      MOVE y_data    TO i_rva_down-data.
*      APPEND i_rva_down.
*    ENDIF.

* irva_hist
    MOVE-CORRESPONDING irva_ettifb TO irva_hist.
    CLEAR: i_rva_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'HIST'
                                            irva_hist
                                            y_data
                                            regel_kz.
    IF NOT y_data IS INITIAL
        OR regel_kz NE '3'.
      MOVE 'HIST'    TO i_rva_down-dttyp.
      MOVE oldkey    TO i_rva_down-oldkey.
      MOVE y_data    TO i_rva_down-data.
      APPEND i_rva_down.
    ENDIF.

** irva_hzg
*    MOVE-CORRESPONDING irva_ettifb TO irva_hzg.
*    CLEAR: i_rva_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'HZG'
*                                            irva_hzg
*                                            y_data.
*    IF NOT y_data IS INITIAL.
*      MOVE 'HZG'     TO i_rva_down-dttyp.
*      MOVE oldkey    TO i_rva_down-oldkey.
*      MOVE y_data    TO i_rva_down-data.
*      APPEND i_rva_down.
*    ENDIF.


** irva_addr
*    MOVE-CORRESPONDING irva_ettifb TO irva_addr.
*    CLEAR: i_rva_down, y_data.
*    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'ADDR'
*                                            irva_addr
*                                            y_data.
*    IF NOT y_data IS INITIAL.
*      MOVE 'ADDR'    TO i_rva_down-dttyp.
*      MOVE oldkey    TO i_rva_down-oldkey.
*      MOVE y_data    TO i_rva_down-data.
*      APPEND i_rva_down.
*    ENDIF.


  ENDLOOP.

  CLEAR: irva_key, irva_refval, irva_tre, irva_bart,
         irva_hist, irva_hzg, irva_addr, irva_ettifb.

  REFRESH: irva_key, irva_refval, irva_tre, irva_bart,
           irva_hist, irva_hzg, irva_addr, irva_ettifb.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_SRT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_SRT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_srt  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT isrt_mru.
    CLEAR: i_srt_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'MRU'
                                            isrt_mru
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'MRU'     TO i_srt_down-dttyp.
    MOVE oldkey    TO i_srt_down-oldkey.
    MOVE y_data    TO i_srt_down-data.
    APPEND i_srt_down.

  ENDLOOP.

  LOOP AT isrt_equnr.
    CLEAR: i_srt_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EQUNR'
                                            isrt_equnr
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EQUNR'   TO i_srt_down-dttyp.
    MOVE oldkey    TO i_srt_down-oldkey.
    MOVE y_data    TO i_srt_down-data.
    APPEND i_srt_down.

  ENDLOOP.

  CLEAR: isrt_mru, isrt_equnr.
  REFRESH: isrt_mru, isrt_equnr.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DEVICEREL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DVR  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_devicerel  USING    oldkey
                                          repname
                                          formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  LOOP AT i_int.
    CLEAR: i_dvr_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                    USING 'INT'
                                          i_int
                                          y_data
                                          regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'INT' TO i_dvr_down-dttyp.
    MOVE oldkey TO i_dvr_down-oldkey.
    MOVE y_data TO i_dvr_down-data.
    APPEND i_dvr_down.
  ENDLOOP.


* DEV

  LOOP AT i_reg.
    CLEAR: i_dvr_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                              USING 'REG'
                                     i_reg
                                     y_data
                                     regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'REG' TO i_dvr_down-dttyp.
    MOVE oldkey TO i_dvr_down-oldkey.
    MOVE y_data TO i_dvr_down-data.
    APPEND i_dvr_down.
  ENDLOOP.


  CLEAR: i_int,
         i_reg.

  REFRESH: i_int,
           i_reg.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DEVINFOREC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DIR  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_devinforec  USING  oldkey
                                         repname
                                         formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  LOOP AT i_dvmint.
    CLEAR: i_dir_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                      USING 'DVMINT'
                                            i_dvmint
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DVMINT' TO i_dir_down-dttyp.
    MOVE oldkey TO i_dir_down-oldkey.
    MOVE y_data TO i_dir_down-data.
    APPEND i_dir_down.
  ENDLOOP.

  LOOP AT i_dvmdev.
    CLEAR: i_dir_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                      USING 'DVMDEV'
                                            i_dvmdev
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DVMDEV' TO i_dir_down-dttyp.
    MOVE oldkey TO i_dir_down-oldkey.
    MOVE y_data TO i_dir_down-data.
    APPEND i_dir_down.
  ENDLOOP.

  LOOP AT i_dvmdfl.
    CLEAR: i_dir_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                      USING 'DVMDFL'
                                            i_dvmdfl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DVMDFL' TO i_dir_down-dttyp.
    MOVE oldkey TO i_dir_down-oldkey.
    MOVE y_data TO i_dir_down-data.
    APPEND i_dir_down.
  ENDLOOP.

  LOOP AT i_dvmreg.
    CLEAR: i_dir_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                      USING 'DVMREG'
                                            i_dvmreg
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DVMREG' TO i_dir_down-dttyp.
    MOVE oldkey TO i_dir_down-oldkey.
    MOVE y_data TO i_dir_down-data.
    APPEND i_dir_down.
  ENDLOOP.

  LOOP AT i_dvmrfl.
    CLEAR: i_dir_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                      USING 'DVMRFL'
                                            i_dvmrfl
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DVMRFL' TO i_dir_down-dttyp.
    MOVE oldkey TO i_dir_down-oldkey.
    MOVE y_data TO i_dir_down-data.
    APPEND i_dir_down.
  ENDLOOP.

  CLEAR: i_dvmint,
         i_dvmdev,
         i_dvmdfl,
         i_dvmreg,
         i_dvmrfl.

  REFRESH: i_dvmint,
           i_dvmdev,
           i_dvmdfl,
           i_dvmreg,
           i_dvmrfl.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_REG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_REG  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_reg  USING    oldkey_reg
                                    repname
                                    formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT i_co_str.
    CLEAR: i_reg_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'STREET'
                                            i_co_str
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
*    MOVE 'CO_STR'  TO i_reg_down-dttyp.
    MOVE 'STREET'  TO i_reg_down-dttyp.
    MOVE oldkey_reg    TO i_reg_down-oldkey.
    MOVE y_data    TO i_reg_down-data.
    APPEND i_reg_down.

  ENDLOOP.

  LOOP AT i_co_pcd.
    CLEAR: i_reg_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_PCD'
                                            USING 'STRSEC'
                                            i_co_pcd
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
*    MOVE 'CO_PCD'  TO i_reg_down-dttyp.
    MOVE 'STRSEC'  TO i_reg_down-dttyp.
    MOVE oldkey_reg    TO i_reg_down-oldkey.
    MOVE y_data    TO i_reg_down-data.
    APPEND i_reg_down.

  ENDLOOP.


  CLEAR: i_co_pcd, i_co_str.
  REFRESH: i_co_pcd, i_co_str.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_RAG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_RAG  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_rag  USING    oldkey_rag
                                    repname
                                    formname.
  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


* neu 21.04.08
  LOOP AT i_co_ist.
    CLEAR: i_rag_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'STREET'
                                            i_co_ist
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
*    MOVE 'ISU'  TO i_rag_down-dttyp.
    MOVE 'STREET'  TO i_rag_down-dttyp.
    MOVE oldkey_rag    TO i_rag_down-oldkey.
    MOVE y_data    TO i_rag_down-data.
    APPEND i_rag_down.

  ENDLOOP.
* bis hier 21.04.08

  LOOP AT i_co_isu.
    CLEAR: i_rag_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'ISU'
                                            i_co_isu
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
*    MOVE 'CO_STR'  TO i_reg_down-dttyp.
    MOVE 'ISU'  TO i_rag_down-dttyp.
    MOVE oldkey_rag    TO i_rag_down-oldkey.
    MOVE y_data    TO i_rag_down-data.
    APPEND i_rag_down.

  ENDLOOP.

  LOOP AT i_co_mru.
    CLEAR: i_rag_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'MRU'
                                            i_co_mru
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
       OR regel_kz NE '3'.
*    MOVE 'CO_STR'  TO i_reg_down-dttyp.
    MOVE 'MRU'  TO i_rag_down-dttyp.
    MOVE oldkey_rag    TO i_rag_down-oldkey.
    MOVE y_data    TO i_rag_down-data.
    APPEND i_rag_down.

  ENDLOOP.

  LOOP AT i_co_con.
    CLEAR: i_rag_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'KON'
                                            i_co_con
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
       OR regel_kz NE '3'.
*    MOVE 'CO_STR'  TO i_reg_down-dttyp.
    MOVE 'KON'  TO i_rag_down-dttyp.
    MOVE oldkey_rag    TO i_rag_down-oldkey.
    MOVE y_data    TO i_rag_down-data.
    APPEND i_rag_down.

  ENDLOOP.

  LOOP AT i_co_css.
    CLEAR: i_rag_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
*                                            USING 'CO_STR'
                                            USING 'CCS'
                                            i_co_css
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
*    MOVE 'CO_STR'  TO i_reg_down-dttyp.
    MOVE 'CCS'  TO i_rag_down-dttyp.
    MOVE oldkey_rag    TO i_rag_down-oldkey.
    MOVE y_data    TO i_rag_down-data.
    APPEND i_rag_down.

  ENDLOOP.



  CLEAR: i_co_isu, i_co_mru, i_co_css, i_co_con, i_co_ist.
  REFRESH: i_co_isu, i_co_mru, i_co_css, i_co_con, i_co_ist.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_MOH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOH  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_moh  USING    oldkey
*                                   pvercount
*                                   pveranz
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.


  LOOP AT imoh_ever.
    CLEAR: i_moh_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EVER'
                                            imoh_ever
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'EVER'   TO i_moh_down-dttyp.
    MOVE oldkey   TO i_moh_down-oldkey.
    MOVE y_data   TO i_moh_down-data.
    APPEND i_moh_down.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_MOO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_MOO  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_moo  USING    oldkey
                                    repname
                                    formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  LOOP AT imoo_eausd.
    CLEAR: i_moo_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'EAUSD'
                                            imoo_eausd
                                            y_data
                                            regel_kz.

    CHECK NOT y_data IS INITIAL
        OR regel_kz NE '3'.
    MOVE 'EAUSD' TO i_moo_down-dttyp.
    MOVE oldkey    TO i_moo_down-oldkey.
    MOVE y_data    TO i_moo_down-data.
    APPEND i_moo_down.
  ENDLOOP.

  LOOP AT imoo_eausvd.
    CLEAR: i_moo_down, y_data, regel_kz.

    PERFORM (formname) IN PROGRAM (repname)
                                           USING 'EAUSVD'
                                            imoo_eausvd
                                            y_data
                                            regel_kz.

    CHECK NOT y_data IS INITIAL
        OR regel_kz NE '3'.
    MOVE 'EAUSVD' TO i_moo_down-dttyp.
    MOVE oldkey    TO i_moo_down-oldkey.
    MOVE y_data    TO i_moo_down-data.
    APPEND i_moo_down.

  ENDLOOP.

  CLEAR: imoo_eausd, imoo_eausvd.
  REFRESH: imoo_eausd, imoo_eausvd.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_DUN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_DUN  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_dun  USING    oldkey
                                    repname
                                    formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

  LOOP AT idun_key.
    CLEAR: idun_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            idun_key
                                            y_data
                                            regel_kz.

    CHECK NOT y_data IS INITIAL
        OR regel_kz NE '3'.
    MOVE 'KEY'     TO idun_down-dttyp.
    MOVE oldkey    TO idun_down-oldkey.
    MOVE y_data    TO idun_down-data.
    APPEND idun_down.
  ENDLOOP.

  LOOP AT idun_fkkma.
    CLEAR: idun_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'FKKMA'
                                            idun_fkkma
                                            y_data
                                            regel_kz.

    CHECK NOT y_data IS INITIAL
        OR regel_kz NE '3'.
    MOVE 'FKKMA'   TO idun_down-dttyp.
    MOVE oldkey    TO idun_down-oldkey.
    MOVE y_data    TO idun_down-data.
    APPEND idun_down.
  ENDLOOP.

  CLEAR: idun_key, idun_fkkma.
  REFRESH: idun_key, idun_fkkma.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_INN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_INN  text
*      -->P_ANLANZ  text
*      -->P_ANLCOUNT  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_inn  USING    oldkey
                                   panlanz
                                   panlcount
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.

*  DATA: op_old LIKE /adesso/mt_facts-operand.


  LOOP AT inn_key.
    CLEAR: i_inn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            inn_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_inn_down-dttyp.
    MOVE oldkey    TO i_inn_down-oldkey.
    MOVE y_data    TO i_inn_down-data.
    APPEND i_inn_down.

  ENDLOOP.

  LOOP AT inn_data.
    CLEAR: i_inn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DATA'
                                            inn_data
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DATA'    TO i_inn_down-dttyp.
    MOVE oldkey    TO i_inn_down-oldkey.
    MOVE y_data    TO i_inn_down-data.
    APPEND i_inn_down.

  ENDLOOP.

  LOOP AT inn_rcat.
    CLEAR: i_inn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'RCAT'
                                            inn_rcat
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'RCAT'    TO i_inn_down-dttyp.
    MOVE oldkey    TO i_inn_down-oldkey.
    MOVE y_data    TO i_inn_down-data.
    APPEND i_inn_down.

  ENDLOOP.

* POD (muss zuletzt)
  LOOP AT inn_pod.
    CLEAR: i_inn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'POD'
                                            inn_pod
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'POD'     TO i_inn_down-dttyp.
    MOVE oldkey    TO i_inn_down-oldkey.
    MOVE y_data    TO i_inn_down-data.
    APPEND i_inn_down.

  ENDLOOP.


  IF panlcount >= panlanz.


    CLEAR: inn_key, inn_data, inn_rcat, inn_pod.

    REFRESH: inn_key, inn_data, inn_rcat, inn_pod.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  AUFBEREITUNG_DAT_ICN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLDKEY_ICN  text
*      -->P_REP_NAME  text
*      -->P_FORM_NAME  text
*----------------------------------------------------------------------*
FORM aufbereitung_dat_icn  USING    oldkey
                                   repname
                                   formname.

  DATA: y_data(1500) TYPE c,
        regel_kz     TYPE c.



  LOOP AT icn_key.
    CLEAR: i_icn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'KEY'
                                            icn_key
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'KEY'     TO i_icn_down-dttyp.
    MOVE oldkey    TO i_icn_down-oldkey.
    MOVE y_data    TO i_icn_down-data.
    APPEND i_icn_down.

  ENDLOOP.

  LOOP AT icn_data.
    CLEAR: i_icn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'DATA'
                                            icn_data
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'DATA'    TO i_icn_down-dttyp.
    MOVE oldkey    TO i_icn_down-oldkey.
    MOVE y_data    TO i_icn_down-data.
    APPEND i_icn_down.

  ENDLOOP.

  LOOP AT icn_rcat.
    CLEAR: i_icn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                            USING 'RCAT'
                                            icn_rcat
                                            y_data
                                            regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'RCAT'    TO i_icn_down-dttyp.
    MOVE oldkey    TO i_icn_down-oldkey.
    MOVE y_data    TO i_icn_down-data.
    APPEND i_icn_down.

  ENDLOOP.

  LOOP AT icn_pod.
    CLEAR: i_icn_down, y_data, regel_kz.
    PERFORM (formname) IN PROGRAM (repname)
                                           USING 'POD'
                                           icn_pod
                                           y_data
                                           regel_kz.
    CHECK NOT y_data IS INITIAL
           OR regel_kz NE '3'.
    MOVE 'POD'    TO i_icn_down-dttyp.
    MOVE oldkey    TO i_icn_down-oldkey.
    MOVE y_data    TO i_icn_down-data.
    APPEND i_icn_down.

  ENDLOOP.

  CLEAR: icn_key, icn_data, icn_rcat, icn_pod.

  REFRESH: ich_key, ich_data, ich_rcat, icn_pod.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ERST_MIG_DATEI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_ACC_DOWN  text
*      -->P_FIRMA  text
*      -->P_OBJECT  text
*      -->P_IDTTYP  text
*      -->P_BEL_FILE  text
*----------------------------------------------------------------------*
FORM erst_mig_datei_alt  TABLES   idown STRUCTURE /adesso/mt_down_mig_obj
                             USING    p_firma
                             p_object
                             p_idttyp
                             p_bel_file.

  FIELD-SYMBOLS: <f>.
  DATA: wa_info LIKE teminfo.
  DATA: s_laenge(2) TYPE x.  "Satzlänge (HEX)
  DATA: s_oldkey LIKE /adesso/mt_down_mig_obj-oldkey.

* --> Nuss 14.09.2015
  DATA: BEGIN OF wa_header,
          field(1) TYPE c.
          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
  DATA: END OF wa_header.

  DATA: BEGIN OF wa_ende,
            reclength(4) TYPE c.           "Test Nuss 15.09.2015
          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
  DATA: END OF wa_ende.
* <-- Nuss 14.09.2015

  DATA: BEGIN OF wa_satz,
          reclength(4) TYPE c.              "Test Nuss 14.09.2015
*          reclength(2)  TYPE c.            "Test Nuss 14.09.2015
          INCLUDE STRUCTURE /adesso/mt_down_mig_obj.
  DATA: END OF wa_satz.



  OPEN DATASET p_bel_file FOR OUTPUT IN BINARY MODE.


*> Kopf der Datei erzeugen

* --> Nuss 14.09.2015
*  CLEAR wa_info.
*  wa_info-firma  = p_firma.
*  wa_info-object = p_object.
*  wa_info-uname  = sy-uname.
*  wa_info-datum  = sy-datum.
*  wa_info-uzeit  = sy-uzeit.
*  CLEAR wa_satz.
*  wa_satz-oldkey   = space.
*  wa_satz-dttyp    = '&INFO'.
*  wa_satz-data     = wa_info.
*  s_laenge         = strlen( wa_satz ).
*  wa_satz-reclength = s_laenge.
*  ASSIGN wa_satz(s_laenge) TO <f>.
*  TRANSFER <f>   TO p_bel_file.
*  COMMIT WORK.

  CLEAR wa_info.
  wa_info-firma  = p_firma.
  wa_info-object = p_object.
  wa_info-uname  = sy-uname.
  wa_info-datum  = sy-datum.
  wa_info-uzeit  = sy-uzeit.
  CLEAR wa_header.
  wa_header-oldkey   = space.
  wa_header-dttyp    = '&INFO'.
  wa_header-data     = wa_info.
  s_laenge         = strlen( wa_header ).
*  wa_satz-reclength = s_laenge.
  ASSIGN wa_header(s_laenge) TO <f>.
  TRANSFER <f>   TO p_bel_file.
  COMMIT WORK.
* <
*  <-- Nuss 14.09.2015

* Datensätze mit jeweiligem Satzende erzeugen
  LOOP AT idown.

    IF sy-tabix > 1.
      IF idown-dttyp EQ p_idttyp.
*>     Endesatz erzeugen
*        --> Nuss 14.09.2015
*        wa_satz-oldkey   = s_oldkey.
*        wa_satz-dttyp    = '&ENDE'.
*        wa_satz-data     = space.
*        s_laenge         = strlen( wa_satz ).
*        wa_satz-reclength = s_laenge.
*        ASSIGN wa_satz(s_laenge) TO <f>.
*        TRANSFER <f>   TO p_bel_file.
*        COMMIT WORK.                            "Nuss 14.09.2015
        wa_ende-oldkey   = s_oldkey.
        wa_ende-dttyp    = '&ENDE'.
        wa_ende-data     = space.
        s_laenge         = strlen( wa_ende ).
        wa_ende-reclength = s_laenge.
        ASSIGN wa_ende(s_laenge) TO <f>.
        TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
        COMMIT WORK.                            "Nuss 14.09.2015
*      <-- Nuss 14.09.2015
*<
      ENDIF.
    ENDIF.

*> Datensätze erzeugen
    s_oldkey         = idown-oldkey.
    wa_satz-oldkey   = idown-oldkey.
    wa_satz-dttyp    = idown-dttyp.
    wa_satz-data     = idown-data.
    s_laenge         = strlen( wa_satz ).
    wa_satz-reclength = s_laenge.           "Nuss 15.09.2015  auskommentier, da Feld draußen
    ASSIGN wa_satz(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
    COMMIT WORK.                             "Nuss 14.09.2015
*<
  ENDLOOP.

  IF sy-subrc EQ 0.
* Endedatensatz des letzten Altsystemschlüssels erzeugen
*   --> Nuss 14.09.2015
*    wa_satz-oldkey   = s_oldkey.
*    wa_satz-dttyp    = '&ENDE'.
*    wa_satz-data     = space.
*    s_laenge         = strlen( wa_satz ).
*    wa_satz-reclength = s_laenge.
*    ASSIGN wa_satz(s_laenge) TO <f>.
*    TRANSFER <f>   TO p_bel_file.
*    COMMIT WORK.                            "Nuss 14.09.2015
    wa_ende-oldkey   = s_oldkey.
    wa_ende-dttyp    = '&ENDE'.
    wa_ende-data     = space.
    s_laenge         = strlen( wa_ende ).
    wa_ende-reclength = s_laenge.
    ASSIGN wa_ende(s_laenge) TO <f>.
    TRANSFER <f>   TO p_bel_file LENGTH s_laenge.
    COMMIT WORK.                            "Nuss 14.09.2015
*      <-- Nuss 14.09.2015

*<
  ENDIF.


  CLOSE DATASET p_bel_file.

ENDFORM.                    "erst_mig_datei


*&---------------------------------------------------------------------*
*&      Form  CHECK_CP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_QCP  text
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM check_cp  USING p_qcp
                    rc.

* local data defintions
  TABLES: tcp00.

* do some initializations
  rc = 0.
  SELECT SINGLE * FROM tcp00 WHERE cpcodepage = p_qcp.
  IF sy-subrc NE 0.
    rc = 1.
    EXIT.
  ENDIF.

ENDFORM.
