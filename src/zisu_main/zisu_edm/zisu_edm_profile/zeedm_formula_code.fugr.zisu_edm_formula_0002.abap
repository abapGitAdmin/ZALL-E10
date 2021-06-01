FUNCTION ZISU_EDM_FORMULA_0002.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  CHANGING
*"     REFERENCE(XY_CNTR) TYPE  EEDMFORMULACTR
*"     REFERENCE(XY_INP) TYPE  TEEDMFORMPARLIST_I
*"     REFERENCE(XY_OUT) TYPE  TEEDMFORMPARLIST_O
*"  EXCEPTIONS
*"      GENERAL_FAULT
*"----------------------------------------------------------------------

*Deklaration der Spitzenmittel u. Hilfsgrössen:
  TYPES: t_spm   TYPE profval.
  DATA:  h_spm1 TYPE t_spm,
         h_spm2 TYPE t_spm.
*interne Tabelle mit den Monatsspitzen:
*dies ist ein Test
  TYPES: BEGIN OF t_prof,
           profval   TYPE profval,
           jjjjmm(6) TYPE c,
           day       TYPE profvalday,
           time      TYPE profvaltime,
         END OF t_prof.
  DATA: lt_prof TYPE TABLE OF t_prof.
  DATA: ls_prof TYPE t_prof.
*Arbeitsbereich Profilwerte.
  TYPES: t_profvalues TYPE eformprofval.
  DATA: ls_profvalues TYPE t_profvalues.
  DATA: tablines TYPE i.
  DATA: idx TYPE i.
  DATA: tzone TYPE sy-zonlo.
*Arbeitsbereiche u. Tabelle
  DATA: ls_eprofass        TYPE eprofass.
  DATA: ls_zrlmbrennwzustd TYPE zrlmbrennwzustd.

  edm_formula_init.

* Measured volume
  edm_def_par_input 1.

* Energy
  edm_def_par_output 1.
* Volume correction factor
  edm_def_par_output 2.
* Standard volume
  edm_def_par_output 3.
* Compressibility
  edm_def_par_output 4.
* Betriebsvolumen
  edm_def_par_output 5.
* 1. Spitze
  edm_def_par_output 6.
* 2. Spitze
  edm_def_par_output 7.
* Zweispitzenmittel
  edm_def_par_output 8.
* Brennwert
  edm_def_par_output 9.


*  EDM_FORMULA_CHECK.

  DATA: vcfn TYPE profval,
        vcfd TYPE profval.

  edm_formula_check.

  edm_reset_index.

  CLEAR: ls_prof, idx.
*Anzahl eingelesener Sätze zu xval1:
  DESCRIBE TABLE <px1>-profvalues LINES tablines.
*
  DO.
    ADD '1' TO idx.
*   read measured value
    edm_read_input 1.
* Die eprofval-Werte sind immer im  U T C - F o r m a t
    CLEAR tzone.
*
    tzone = sy-zonlo.
*
    CALL FUNCTION 'ISU_DATE_TIME_CONVERT_TIMEZONE'
      EXPORTING
        x_date_utc    = valday
        x_time_utc    = valtime
        x_timezone    = tzone
      IMPORTING
        y_date_lcl    = valday
        y_time_lcl    = valtime
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
*
    IF idx > 1.
      IF ls_prof-day(6) NE valday(6).
        APPEND ls_prof TO lt_prof.
        CLEAR ls_prof.
      ENDIF.

    ENDIF.
*   Ermittlung der Spitzenmittel:
    IF ls_prof-profval LT xval1.
      ls_prof-profval = xval1.
      ls_prof-jjjjmm  = valday(6).
      ls_prof-day  = valday.
      ls_prof-time = valtime.
    ENDIF.
* für den letzten Satz:
    IF idx = tablines.
      APPEND ls_prof TO lt_prof.
      CLEAR ls_prof.
    ENDIF.
*   next index of profile
    edm_next_index.
  ENDDO.
*
* Monatsspitzenwerte sortieren:
  SORT lt_prof BY profval DESCENDING.
* Spitzenwerte ermitteln:
  CLEAR: ls_prof, h_spm1, h_spm2.
* 1 Spitzenmittel:
  READ TABLE lt_prof INDEX 1 INTO ls_prof.
  IF sy-subrc > 0.
    yval6 = 0.
  ELSE.
    h_spm1 = ls_prof-profval.
    yval6 = h_spm1.
* Umrechnung auf kW (Leistung)
    yval5 = yval5 * 1 .
  ENDIF.
* 2 Spitzenmittel:
  CLEAR ls_prof.
  READ TABLE lt_prof INDEX 2 INTO ls_prof.
  IF sy-subrc > 0.
    yval8 = 0.
  ELSE.
    h_spm2 = ls_prof-profval.
* 2. Spitze
    yval7 = h_spm2.
    yval8 = ( h_spm1 + h_spm2 ) / 2 .
* Umrechnung auf kW (Leistung)
    yval8 = yval8 * 1 .
  ENDIF.
*   once again
  edm_reset_index.

  DO.
    edm_read_input 1.

* kWh-Werte durchreichen
    yval1 = xval1.
    edm_append_output 1.

* In der ZRLMBRENNWZUSTD stehen nur Werte vom ersten bis zum letzten Tag eines Monats.
* Es werden aber Werte abgefragt, die einige Stunden in den Folgemonat reichen.
* In der ZRLMBRENNWZUSTD sind diese Werte aber dem Monatsletzten des Abrechnungsmonats zugeordnet.
    IF vx1-prof_date = xy_cntr-dateto.
      vx1-prof_date = vx1-prof_date - 1.
    ENDIF.

* Ermittlung Z-Zahl und Brennwert
    SELECT SINGLE * FROM eprofass INTO ls_eprofass WHERE
      profile   = vx1-profile1 AND
      dateto   >= vx1-prof_date AND
      datefrom <= vx1-prof_date.

    SELECT SINGLE * FROM zrlmbrennwzustd INTO ls_zrlmbrennwzustd WHERE
      logikzw  = ls_eprofass-logikzw AND
      glt_von <= vx1-prof_date AND
      glt_bis >= vx1-prof_date.

    IF sy-subrc <> 0
      OR ls_zrlmbrennwzustd-gasfactor = 0
      OR ls_zrlmbrennwzustd-calorific_val = 0.
      CALL FUNCTION 'ISU_MSG_PUT'
        EXPORTING
          x_msg_id = 'ZAIS_EDM'
          x_msg_no = '001'
          x_msg_v1 = 'Fehler beim Lesen der Tabelle ZRLMBRENNWZUSTD!'
          x_msg_v2 = space
          x_msg_v3 = space
          x_msg_v4 = space.

      RAISE general_fault.
    ENDIF.

    yval2 = ls_zrlmbrennwzustd-gasfactor.
    edm_append_output 2.

    yval9 = ls_zrlmbrennwzustd-calorific_val.
    edm_append_output 9.

* Normvolumen
    IF yval9 = 0.
      yval3 = 0.
      RAISE general_fault.
    ELSE.
      yval3 = yval1 / yval9.
    ENDIF.
    edm_append_output 3.

* Kompressibilitätszahl (nicht mehr relevant)
    yval4 = 1.
    edm_append_output 4.

* Betriebsvolumen.
    IF yval2 = 0.
      yval5 = 0.
      RAISE general_fault.
    ELSE.
      yval5 = yval3 / yval2.
    ENDIF.

    edm_append_output 5.

* spitzenmittel ausgeben:
*   append values to the output profile
    edm_append_output 6.
    edm_append_output 7.
    edm_append_output 8.
* get index of next interval
    edm_next_index.
  ENDDO.

  edm_check_all_values.



ENDFUNCTION.
