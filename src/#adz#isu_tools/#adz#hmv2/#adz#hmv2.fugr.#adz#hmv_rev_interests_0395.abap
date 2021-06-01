FUNCTION /ADZ/HMV_REV_INTERESTS_0395.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_FKKMAKO) LIKE  FKKMAKO STRUCTURE  FKKMAKO
*"  TABLES
*"      IT_FKKMAZE STRUCTURE  FKKMAZE
*"----------------------------------------------------------------------


  DATA: l_tfk047b LIKE tfk047b.
  DATA: t_fkkbl TYPE TABLE OF fkkbl.
  DATA: t_opbel LIKE TABLE OF iropbel.
  DATA: s_opbel LIKE iropbel.
  DATA: t_msgtx TYPE fkk_t_msg_text.
  DATA: s_msgtx TYPE fkk_msg_text.
  DATA: x_ikey LIKE dfkkop-ikey.
  FIELD-SYMBOLS <fkkmaze> TYPE fkkmaze.


* Determine customizing ikey
  CALL FUNCTION 'FKK_GET_TFK047'
    EXPORTING
      i_mahnv   = i_fkkmako-mahnv
      i_mahns   = i_fkkmako-mahns
    IMPORTING
      e_tfk047b = l_tfk047b
    EXCEPTIONS
      OTHERS    = 4.

* only relevant if interest to be calculated and interest key set
  CHECK sy-subrc = 0.
  CHECK l_tfk047b-icalc = 'X'.
  CHECK l_tfk047b-ikey IS NOT INITIAL.

  REFRESH t_opbel.

* only relevant for items w/ dunning level w/ interest
  LOOP AT it_fkkmaze ASSIGNING <fkkmaze>
       WHERE mahns = i_fkkmako-mahns.

* check if interest already posted for doc
    REFRESH t_fkkbl.
    CALL FUNCTION 'FKK_INTEREST_HISTORY_FOR_DOC'
      EXPORTING
        i_opbel      = <fkkmaze>-opbel
        i_no_message = 'X'
      TABLES
        e_fkkbl      = t_fkkbl.

    IF t_fkkbl[] IS NOT INITIAL.
      CLEAR s_opbel.
      s_opbel-option = 'EQ'.
      s_opbel-sign   = 'I'.
      s_opbel-low    = <fkkmaze>-opbel.
      COLLECT s_opbel INTO t_opbel.

    ENDIF.

* reset interest key for item
    UPDATE   dfkkop
       SET   ikey  = x_ikey
       WHERE opbel = <fkkmaze>-opbel
       AND   opupw = <fkkmaze>-opupw
       AND   opupk = <fkkmaze>-opupk
       AND   opupz = <fkkmaze>-opupz.

    IF sy-subrc <> 0.
      CALL FUNCTION 'FKK_AKTIV2_APPL_LOG_MSG'
        EXPORTING
          i_msgty                  = 'E'
          i_msgid                  = '/ADZ/HMV'
          i_msgno                  = '002'
          i_msgv1                  = <fkkmaze>-opbel
          i_msgv2                  = <fkkmaze>-opupw
          i_msgv3                  = <fkkmaze>-opupk
          i_msgv4                  = <fkkmaze>-opupz
          i_probclass_this_message = '2'.
      IF 1 = 2.  MESSAGE e002(/adz/hmv). ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK t_opbel[] IS NOT INITIAL.

  CALL FUNCTION 'FKK_INTEREST_REVERSE'
    IMPORTING
      e_message = t_msgtx
    TABLES
      tp_opbel  = t_opbel.

  LOOP AT t_msgtx INTO s_msgtx.
    CALL FUNCTION 'FKK_AKTIV2_APPL_LOG_MSG'
      EXPORTING
        i_msgty                  = s_msgtx-msgty
        i_msgid                  = s_msgtx-msgid
        i_msgno                  = s_msgtx-msgno
        i_msgv1                  = s_msgtx-msgv1
        i_msgv2                  = s_msgtx-msgv2
        i_msgv3                  = s_msgtx-msgv3
        i_msgv4                  = s_msgtx-msgv3
        i_probclass_this_message = '2'.
  ENDLOOP.
ENDFUNCTION.
