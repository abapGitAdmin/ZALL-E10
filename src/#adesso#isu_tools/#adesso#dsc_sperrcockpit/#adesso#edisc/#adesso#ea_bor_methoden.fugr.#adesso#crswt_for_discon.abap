FUNCTION /ADESSO/CRSWT_FOR_DISCON.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_INT_UI) TYPE  EIDESWTDOC-POD
*"     REFERENCE(X_ANLAGE) TYPE  EANL-ANLAGE
*"     REFERENCE(X_EXT_UI) TYPE  EUITRANS-EXT_UI
*"     REFERENCE(X_MOVEOUTDAT) TYPE  EIDESWTDOC-MOVEOUTDATE
*"     REFERENCE(X_MOVEINDAT) TYPE  EIDESWTDOC-MOVEINDATE
*"     REFERENCE(X_COMMIT) TYPE  REGEN-KENNZX DEFAULT 'X'
*"     REFERENCE(X_REASON) TYPE  REGEN-KENNZX DEFAULT '1'
*"     REFERENCE(X_TRANSREASON) TYPE  EIDESWTMSGDATA-TRANSREASON
*"       DEFAULT 'Z27'
*"     REFERENCE(X_CATEGORY) TYPE  EIDESWTMSGDATA-CATEGORY DEFAULT
*"       'E02'
*"     REFERENCE(X_COMMENTTXT) TYPE  EIDESWTMSGDATACO-COMMENTTXT
*"     REFERENCE(X_KENNZX_EDISCDOC) TYPE  REGEN-KENNZX
*"  EXPORTING
*"     REFERENCE(BAPIRETURN) TYPE  BAPIRETURN1
*"     REFERENCE(Y_SWITCHNUM) TYPE  EIDESWTDOC-SWITCHNUM
*"     REFERENCE(Y_ERROR) TYPE  REGEN-KENNZX
*"----------------------------------------------------------------------

*Zu der übergebenen Anlage wird ein Wechselbeleg erzeugt
* Makros
  DEFINE set_message.
    move &1 to bapireturn-type.
    move &2 to bapireturn-id.
    move &3 to bapireturn-number.
    move &4 to bapireturn-message_v1.
    move &5 to bapireturn-message_v2.
    move &6 to bapireturn-message_v3.
    move &7 to bapireturn-message_v4.

    message id &2 type &1 number &3 into bapireturn-message
       with &4 &5 &6 &7 .
  END-OF-DEFINITION.

  DATA:
    ld_rcode LIKE sy-subrc,
    lf_eideswtdoc TYPE eideswtdoc,
    lf_eideswtmsgdata TYPE eideswtmsgdata,
    lt_msgdataco TYPE teideswtmsgdataco,
    ld_COMMENTTXT TYPE  EIDESWTMSGDATACO-COMMENTTXT,
    ld_discreason type EDISCDOC-discreason.

  DATA: ld_sperrdat TYPE dats, "Gewünschtes Sperrdatem
        ld_wib_dat TYPE dats. "Gewünschtes WIB-Datum

        ld_commenttxt = X_COMMENTTXT.

  CASE x_reason.
    WHEN 1.
* Sperre am Tag nach Ende der Ersatzversorgung
      COMPUTE ld_sperrdat = x_moveoutdat + 1.

      ld_discreason = '02'.

*Kommentar im Bemerkungsfeld füllen
      CALL FUNCTION '/ADESSO/LW_COMMENT_EDISCDOC'
        EXPORTING
          X_WMODE             = '3'
          X_DISCREASON        = ld_discreason
        CHANGING
          XY_COMMENTTXT       = ld_commenttxt.


    WHEN 2.
* Datum nicht verändern
      ld_sperrdat = x_moveoutdat.
      ld_wib_dat  = x_moveindat.
    WHEN OTHERS.
      COMPUTE ld_sperrdat = x_moveoutdat + 1.
  ENDCASE.


*  IF ld_sperrdat IS INITIAL.
*    ld_sperrdat = ld_wib_dat.
*  ENDIF.

  CLEAR: y_error, ld_rcode.

* Das Anlegen von Wechselbelegen zu Leerstandsanlagen erfolgt nur im Netzmandanten
  IF x_kennzx_ediscdoc IS INITIAL.   " Pürfung bei Sperrbelegverarbeitung nicht durchführen
    IF sy-mandt NE gc_vertriebsmandant.
      EXIT.
    ENDIF.
  ENDIF.

* Wechselbelegkopfdaten erzeugen
  PERFORM baue_wbkopf_sperre     USING  ld_sperrdat
                                        ld_wib_dat
                                        x_int_ui
                                        x_category
                                        x_transreason
                                        ld_discreason
                               CHANGING lf_eideswtdoc
                                        ld_rcode.

* WNachrichtendaten erzeugen
  PERFORM baue_msgdata_sperre    USING ld_sperrdat
                                       ld_wib_dat
                                       x_int_ui
                                       lf_eideswtdoc
                                       x_transreason
                                       x_category
                              CHANGING lf_eideswtmsgdata
                                       ld_rcode.


* Kommentare zu den Nachrichtendaten erzeugen
  PERFORM baue_msgdata_comment_ediscdoc
                             USING    ld_commenttxt
                             CHANGING lt_msgdataco.


* Anlegen eines Wechselbelegs
  PERFORM create_from_msgdata USING lf_eideswtdoc
                                    lf_eideswtmsgdata
                                    lt_msgdataco
                           CHANGING ld_rcode
                                    y_switchnum.



* Auswertung Fehlercodes
  CASE ld_rcode.
    WHEN 0.
      set_message gc_erfolg gc_nakl '080' y_switchnum x_anlage x_ext_ui ld_sperrdat.
      MOVE gc_false TO y_error.
      PERFORM set_erfolg_leer USING x_int_ui ld_sperrdat y_switchnum 'L' x_commit.
    WHEN gc_rcode_wb_general_fault.
      set_message gc_fehler gc_nakl '069' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_wb_foreign_lock.
      set_message gc_fehler gc_nakl '070' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_wb_pod_missing.
      set_message gc_fehler gc_nakl '071' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit..
    WHEN gc_rcode_wb_not_authorized.
      set_message gc_fehler gc_nakl '072' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_wb_others.
      set_message gc_fehler gc_nakl '069' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_sperre_no_servprov.
      set_message gc_fehler gc_nakl '081' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_sperre_no_gpart .
      set_message gc_fehler gc_nakl '082' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_sperre_no_distributor.
      set_message gc_fehler gc_nakl '075' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN gc_rcode_sperre_no_spartentyp.
      set_message gc_fehler gc_nakl '077' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
    WHEN OTHERS.
      set_message gc_fehler gc_nakl '069' x_anlage x_ext_ui space space.
      MOVE gc_true TO y_error.
      PERFORM set_fehler_leer USING x_int_ui ld_sperrdat bapireturn 'L' x_commit.
  ENDCASE.


ENDFUNCTION.
