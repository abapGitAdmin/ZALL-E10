*----------------------------------------------------------------------*
*   INCLUDE LFICA_MACROS003                                            *
*----------------------------------------------------------------------*

* OBSOLETE
* Please use function module FKK_AKTIV2_APPL_LOG_MSG instead!


* Write one single message to the application log.
DEFINE mac_appl_log_msg.

* if desired problemclass is not given, determine it
  if &9 eq space.
    call function 'FKK_AKTIV2_APPL_LOG_PRCL_GET'
      importing
        e_probclass = _mac_h_desired_probclass.
  else.
    _mac_h_desired_probclass = &9.
  endif.

  call function 'FKK_AKTIV_GET_CURRENT_ACTIVITY'
    importing
      e_aktyp             = _mac_h_aktyp
    exceptions
      unable_to_determine = 1
      others              = 2.
  case sy-subrc.
    when others.
      " Do nothing, but ensure that extended syntax check
      " will not lead to entries.
  endcase.

  clear _mac_h_message.
  _mac_h_message-msgty = &1.
  _mac_h_message-msgid = &2.
  _mac_h_message-msgno = &3.

* initialize problem class
  _mac_h_probclass_this_message = &8.
  _mac_h_changed_probclass = _mac_h_probclass_this_message.

* change problem class of message according to customizing
* if switch for EhP4 is active
* Switch check exchanged - SBS
  if cl_fkk_switch_check=>fica_ehp4( ) eq 'X'.

    call function 'FKK_MESSAGE_CHECK'
      exporting
        i_aktyp                  = _mac_h_aktyp
        i_msgid                  = _mac_h_message-msgid
        i_msgno                  = _mac_h_message-msgno
        i_probclass_this_message = _mac_h_probclass_this_message
      importing
        e_probclass_this_message = _mac_h_changed_probclass.

  endif.

* if message is in desired problemclass write it to application log
  set extended check off.
  if ( _mac_h_changed_probclass le
       _mac_h_desired_probclass ).
    set extended check on.
    clear _mac_h_subobject.
    concatenate gc_appl_log_subobject_prefix
                _mac_h_aktyp into _mac_h_subobject.

* Hand over variables left-justified.
    write &4 to _mac_h_message-msgv1 left-justified.
    write &5 to _mac_h_message-msgv2 left-justified.
    write &6 to _mac_h_message-msgv3 left-justified.
    write &7 to _mac_h_message-msgv4 left-justified.
    _mac_h_message-probclass = _mac_h_changed_probclass.

* Only write to application log if msgid, msgty and
* msgno are given. Otherwise it may lead to errors.
    if ( ( not ( _mac_h_message-msgid is initial ) ) and
         ( not ( _mac_h_message-msgty is initial ) ) ).     "1656869
* 1656869 - 000 is legal message number, which can be inserted into the log
*        ( not ( _mac_h_message-msgno is initial ) ) ).     1656869
      call function 'APPL_LOG_WRITE_SINGLE_MESSAGE'
        exporting
          object           = gc_appl_log_object
          subobject        = _mac_h_subobject
          message          = _mac_h_message
          update_or_insert = 'I'
        exceptions
          OTHERS           = 1.                        ">>>1447805, 1669876
      IF sy-subrc <> 0.
        CALL FUNCTION 'FKK_AKTIV2_APPL_LOG_OVERFLOW'
          CHANGING
            c_overflow_flag = overflow.
        IF overflow IS INITIAL.
          CALL FUNCTION 'BP_SET_MSG_HANDLING'
          exporting
            handlingtype = 1
          exceptions
            others       = 0.
        message S252(BL).
        call function 'BP_SET_MSG_HANDLING'
          exporting
            handlingtype = 2
          exceptions
            others       = 0.
          overflow = 'X'.
          CALL FUNCTION 'FKK_AKTIV2_APPL_LOG_OVERFLOW'
            EXPORTING
              i_set_overflow_flag = 'X'
            CHANGING
              c_overflow_flag     = overflow.
        ENDIF.
      ENDIF.                                 "<<<1447805, 1669876
    endif.
  endif.
END-OF-DEFINITION.
