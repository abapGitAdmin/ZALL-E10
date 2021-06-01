FUNCTION Z_K_COLL_AG_SAMPLE_5060.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FKKOP) LIKE  FKKOP STRUCTURE  FKKOP
*"  EXPORTING
*"     VALUE(E_INKGP) LIKE  DFKKCOLL-INKGP
*"     VALUE(E_MAN_SEL) LIKE  BOOLE-BOOLE
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"  EXCEPTIONS
*"      NO_INKGP_FOUND
*"      OTHER_PROBLEM
*"----------------------------------------------------------------------

  DATA: l_f_bup          TYPE but000,
        l_f_bua          TYPE bus020_ext,
        l_f_fkkvkp       TYPE fkkvkp,
        l_f_fkkcollag    TYPE fkkcollag,
        l_xhandled       TYPE boole_d,
        l_loc_lang       TYPE boole-boole.

* When using transaction FP03E, the collection agency will be manually
* selected, otherwise the derivation tool will be used.
*  IF ( sy-tcode EQ 'FP03E' OR sy-tcode EQ 'ZINKMON' OR sy-tcode EQ 'ZINKMON_LS' ) AND
*     answer IS INITIAL OR
*     answer EQ 'A'.
*    CALL FUNCTION 'POPUP_TO_DECIDE'
*      EXPORTING
*        textline1      = text-001
*        textline2      = text-002
*        text_option1   = text-003
*        text_option2   = text-004
*        titel          = text-005
*        cancel_display = 'X '
*      IMPORTING
*        answer         = answer.
*  ENDIF.

  IF ( sy-tcode EQ 'FP03E' OR sy-tcode EQ 'ZINKMON' OR sy-tcode EQ 'ZINKMON_LS' ).
    answer = '1'.
    ENDIF.

* answer = '1'.

  IF answer = '1'.
    e_man_sel = 'X'.
    PERFORM get_ibvalues(saplfka6) CHANGING e_inkgp.
  ELSEIF answer EQ 'A'.
* nothing happen if answer = 'cancel'
  ELSE.
* Prio 1: Adresse aus Vertragskonto
    IF  i_fkkop-vkont <> space.
* Lesen des Vertragskontos
      CALL FUNCTION 'FKK_ACCOUNT_READ'
        EXPORTING
          i_vkont      = i_fkkop-vkont
          i_gpart      = i_fkkop-gpart
          i_only_gpart = 'X'
        IMPORTING
          e_fkkvkp     = l_f_fkkvkp
        EXCEPTIONS
          not_found    = 1
          foreign_lock = 2
          OTHERS       = 3.
      IF sy-subrc = 0.
        IF l_f_fkkvkp-adrnb <> space.
          l_f_bua-addrnumber = l_f_fkkvkp-adrnb.
        ENDIF.
      ENDIF.
    ENDIF.

* GP: Allgemeine Daten I
    CALL FUNCTION 'BUP_BUT000_SELECT_SINGLE'
      EXPORTING
        i_partner = i_fkkop-gpart
      IMPORTING
        e_but000  = l_f_bup
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING other_problem.
    ENDIF.

* Prio 2: Standard-Adresse aus Geschäftspartners
    IF l_f_bua-addrnumber = space.
* Lesen der Standardadresse
      CALL FUNCTION 'BUA_ADDRESS_GET'
        EXPORTING
          i_partner        = i_fkkop-gpart
        IMPORTING
          e_address        = l_f_bua
        EXCEPTIONS
          no_address_found = 1
          internal_error   = 2
          wrong_parameters = 3
          OTHERS           = 4.
    ELSE.
* Lesen der speziellen Adresse
      CALL FUNCTION 'BUA_ADDRESS_GET'
        EXPORTING
          i_partner        = l_f_bup-partner
          i_addrnumber     = l_f_bua-addrnumber
        IMPORTING
          e_address        = l_f_bua
        EXCEPTIONS
          no_address_found = 1
          internal_error   = 2
          wrong_parameters = 3
          OTHERS           = 4.
    ENDIF.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING other_problem.
    ENDIF.

    MOVE-CORRESPONDING i_fkkop TO l_f_fkkcollag.
    MOVE-CORRESPONDING l_f_bup TO l_f_fkkcollag.
    MOVE-CORRESPONDING l_f_bua TO l_f_fkkcollag.

    CLEAR l_loc_lang.
    IF l_f_bua-langu_crea <> sy-langu.
      SET LOCALE LANGUAGE l_f_bua-langu_crea.
      l_loc_lang = 'X'.
    ENDIF.

    TRANSLATE l_f_fkkcollag-post_code1 TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-city1      TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-city2      TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-home_city  TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-street     TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-house_num1 TO UPPER CASE.    "#EC TRANSLANG
    TRANSLATE l_f_fkkcollag-taxjurcode TO UPPER CASE.    "#EC TRANSLANG

    IF l_loc_lang = 'X'.
      SET LOCALE LANGUAGE space.
    ENDIF.

* Ableitung über das Derivation Tool
    CALL FUNCTION 'FKK_COLL_AG_DERIVATION_TOOL'
      EXPORTING
        i_fkkcollag       = l_f_fkkcollag
        i_derivation_date = sy-datum
      IMPORTING
        e_inkgp           = e_inkgp
        e_xhandled        = l_xhandled.

* Keine erfolgreiche Ableitung über das Derivation Tool ??
    IF l_xhandled = space OR e_inkgp = space.
* dann bisheriges Vorgehen (FKK_SAMPLE_5060) als "letzte Rettung"
      CALL FUNCTION 'FKK_SAMPLE_5060'
        EXPORTING
          i_fkkop        = i_fkkop
        IMPORTING
          e_inkgp        = e_inkgp
        TABLES
          t_fkkop        = t_fkkop
        EXCEPTIONS
          no_inkgp_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING no_inkgp_found.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
