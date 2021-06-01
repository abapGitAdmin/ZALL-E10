FUNCTION /ADZ/ISU_DUNNING_0340.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_FKKMAZE STRUCTURE  FKKMAZE
*"      T_FIMSG STRUCTURE  FIMSG
*"  CHANGING
*"     REFERENCE(C_FKKMAKO) LIKE  FKKMAKO STRUCTURE  FKKMAKO
*"----------------------------------------------------------------------


  DATA ls_fkkmaze LIKE LINE OF t_fkkmaze.
  DATA:
    t_hmv_cons        TYPE TABLE OF /adz/hmv_cons,
    s_hmv_cons        TYPE          /adz/hmv_cons,
    c_idxmm_sp03_dunn TYPE char1.

  FIELD-SYMBOLS: <fkkop>   TYPE fkkop,
                 <memidoc> TYPE /idxmm/memidoc.
* Konstanten Tabelle lesen
  SELECT *
    FROM /adz/hmv_cons
    INTO TABLE t_hmv_cons.

* HMV2 - Mahnprozess nach MMMA SP03 aktiv?
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_IDXMM_SP03_DUNN'.
  c_idxmm_sp03_dunn = s_hmv_cons-attvalue.



  CALL FUNCTION 'ISU_DUNNING_READ_ITEMS_0340'
    TABLES
      t_fkkmaze = t_fkkmaze
      t_fimsg   = t_fimsg
    CHANGING
      c_fkkmako = c_fkkmako.


  IF c_idxmm_sp03_dunn IS INITIAL.

    LOOP AT t_fkkmaze INTO ls_fkkmaze.
      SELECT COUNT( * ) FROM /idxmm/memidoc WHERE doc_id = ls_fkkmaze-opbel.
      IF sy-subrc = 0.
        c_fkkmako-nrzas = TEXT-001.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.



ENDFUNCTION.
