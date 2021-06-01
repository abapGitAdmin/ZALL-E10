FUNCTION /ADZ/ISU_DEREG_DUNNING_0311.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(PARA_0300) TYPE  FKKMA_0300
*"     VALUE(I_FAEDN_LOW) TYPE  FAEDN_KK OPTIONAL
*"     VALUE(I_FAEDN_HIGH) TYPE  FAEDN_KK OPTIONAL
*"  EXPORTING
*"     VALUE(E_FLAG) LIKE  BOOLE-BOOLE
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"      T_FKKVKP STRUCTURE  FKKVKP
*"      T_FIMSG STRUCTURE  FIMSG
*"  EXCEPTIONS
*"      NO_DEREG_DUNNING
*"      INTERNAL_ERROR
*"----------------------------------------------------------------------

  CONSTANTS: co_herkf_77 TYPE herkf_kk VALUE '77'.

  DATA: lt_fkkko   TYPE fkkko_t,
        ls_fkkop   TYPE fkkop,
        lt_fkkop   TYPE TABLE OF fkkop,
        lt_memidoc TYPE /idxmm/t_memi_doc.
  DATA:
        t_hmv_cons TYPE TABLE OF /ADZ/hmv_cons,
        s_hmv_cons TYPE          /ADZ/hmv_cons,
        c_idxmm_sp03_dunn TYPE char1.

  FIELD-SYMBOLS: <fkkop>   TYPE fkkop,
                 <memidoc> TYPE /idxmm/memidoc.
* Konstanten Tabelle lesen
  SELECT *
    FROM /ADZ/hmv_cons
    INTO TABLE t_hmv_cons.

* HMV2 - Mahnprozess nach MMMA SP03 aktiv?
  READ TABLE t_hmv_cons INTO s_hmv_cons WITH KEY konstante = 'C_IDXMM_SP03_DUNN'.
  c_idxmm_sp03_dunn = s_hmv_cons-attvalue.



    CALL FUNCTION 'ISU_DEREG_INV_DUNNING_0311'
      EXPORTING
        para_0300    = para_0300
        i_faedn_low  = i_faedn_low
        i_faedn_high = i_faedn_high
      IMPORTING
        e_flag       = e_flag
      TABLES
        t_fkkop      = t_fkkop
        t_fkkvkp     = t_fkkvkp
        t_fimsg      = t_fimsg
    EXCEPTIONS
       NO_DEREG_DUNNING = 1
       INTERNAL_ERROR   = 2
       OTHERS           = 1
      .

    IF c_idxmm_sp03_dunn IS INITIAL.

*    -------------- fill int. table for the document headers --------------*
      CLEAR: lt_fkkko[], lt_fkkop.
      IF NOT t_fkkop[] IS INITIAL.
        SELECT DISTINCT opbel herkf FROM dfkkko
                           INTO CORRESPONDING FIELDS OF TABLE lt_fkkko
                           FOR ALL ENTRIES IN t_fkkop
                           WHERE opbel EQ t_fkkop-opbel.
        IF sy-subrc NE 0.
          RAISE internal_error.
        ENDIF.
      ENDIF.

*    ------------ check the origin key of the document header -------------*
      LOOP AT t_fkkop ASSIGNING <fkkop>.
        READ TABLE lt_fkkko WITH KEY opbel = <fkkop>-opbel
                                     herkf = co_herkf_77
                            TRANSPORTING NO FIELDS.

*    ------- do not process documents with origin 77 ---------*
        IF sy-subrc = 0.
          MOVE-CORRESPONDING <fkkop> TO ls_fkkop.
          APPEND ls_fkkop TO lt_fkkop.
          DELETE t_fkkop.
        ENDIF.
      ENDLOOP.

      IF lt_fkkop IS NOT INITIAL.

        CALL FUNCTION '/ADZ/FM_GET_MEMIDOC_TO_DUN'
          IMPORTING
            et_memidoc = lt_memidoc
          TABLES
            t_fkkop    = lt_fkkop.

        IF lt_memidoc IS NOT INITIAL.

          LOOP AT lt_fkkop ASSIGNING <fkkop>.
            LOOP AT lt_memidoc ASSIGNING <memidoc>
              WHERE ci_fica_doc_no = <fkkop>-opbel
              AND   opupk = <fkkop>-opupk.

              CLEAR: ls_fkkop.
              MOVE-CORRESPONDING <fkkop> TO ls_fkkop.
              ls_fkkop-opbel = <memidoc>-doc_id.
              CLEAR: ls_fkkop-opupk.
              ls_fkkop-betrw = <memidoc>-gross_amount.
              "Belege mit Mahnsperre ausschließen
              SELECT COUNT( * ) FROM /adz/mem_mloc WHERE doc_id = <memidoc>-doc_id AND fdate <= para_0300-ausdt AND tdate >= para_0300-ausdt AND lvorm = ' '.
              if sy-subrc <> 0.
              APPEND ls_fkkop TO t_fkkop.
              ENDIF.
            ENDLOOP.
          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDIF.

ENDFUNCTION.
