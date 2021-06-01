FUNCTION /adesso/hmv_interests_0380.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_FKKMAKO) LIKE  FKKMAKO STRUCTURE  FKKMAKO
*"  TABLES
*"      T_FKKMAZE STRUCTURE  FKKMAZE
*"      T_FIMSG STRUCTURE  FIMSG
*"      T_FKKIA STRUCTURE  FKKIA OPTIONAL
*"      T_FKKIH STRUCTURE  FKKIH OPTIONAL
*"----------------------------------------------------------------------

  DATA: l_tfk047b LIKE tfk047b.
  FIELD-SYMBOLS <fkkmaze> TYPE fkkmaze.

* interest was posted --> nothing to be done
  IF i_fkkmako-mibel IS NOT INITIAL.
    EXIT.
  ENDIF.

* no interest was calculated --> nothing to be done
  IF t_fkkia[] IS INITIAL.
    EXIT.
  ENDIF.

* Determine customizing ikey
  CALL FUNCTION 'FKK_GET_TFK047'
    EXPORTING
      i_mahnv   = i_fkkmako-mahnv
      i_mahns   = i_fkkmako-mahns
    IMPORTING
      e_tfk047b = l_tfk047b
    EXCEPTIONS
      OTHERS    = 4.

* Customizing: interest to be calculated and interest key set
  CHECK sy-subrc = 0.
  CHECK l_tfk047b-icalc = 'X'.
  CHECK l_tfk047b-ikey IS NOT INITIAL.

* set interest key into dfkkop item
  LOOP AT t_fkkia.
    UPDATE   dfkkop
       SET   ikey  = l_tfk047b-ikey
       WHERE opbel = t_fkkia-opbel
       AND   opupw = t_fkkia-opupw
       AND   opupk = t_fkkia-opupk
       AND   opupz = t_fkkia-opupz.

    IF sy-subrc <> 0.
      CLEAR t_fimsg.
      t_fimsg-msgid = '/ADESSO/HMV'.
      t_fimsg-msgty = 'E'.
      t_fimsg-msgno = '001'.
      t_fimsg-msgv1 = t_fkkia-opbel.
      t_fimsg-msgv2 = t_fkkia-opupw.
      t_fimsg-msgv3 = t_fkkia-opupk.
      t_fimsg-msgv4 = t_fkkia-opupz.
      APPEND t_fimsg.
* <<< ET
      IF 1 = 2.
        MESSAGE e001(/adesso/hmv).
      ENDIF.
* >>> ET
    ENDIF.
  ENDLOOP.

* complete fkkmaze with aditional values
  LOOP AT t_fkkmaze ASSIGNING <fkkmaze>.
    CLEAR <fkkmaze>-mintm.
*   "OPUPZ of T_FKKIA is always 000 because of the merge
*   "in FKK_DUNNING_OPEN_ITEMS
    LOOP AT t_fkkia WHERE opbel  = <fkkmaze>-opbel AND
                          opupw  = <fkkmaze>-opupw AND
                          opupk  = <fkkmaze>-opupk.
*     " The dunning interest is always inserted into the FKKMAZE with lowest OPUPZ
*     " The reason is the merge in  FKK_DUNNING_OPEN_ITEMS
      IF <fkkmaze>-opupz = '000'.
         <fkkmaze>-mintm = <fkkmaze>-mintm + t_fkkia-ibtrg.
      ELSE.
*       Check if this is the line with the lowest OPUPZ
        LOOP AT t_fkkmaze WHERE opbel = <fkkmaze>-opbel AND
                                opupw = <fkkmaze>-opupw AND
                                opupk = <fkkmaze>-opupk AND
                                opupz < <fkkmaze>-opupz.
          EXIT.
        ENDLOOP.
*       " If this is the lowest OPUPZ, than take the interest amount
        IF sy-subrc <> 0.
          <fkkmaze>-mintm = <fkkmaze>-mintm + t_fkkia-ibtrg.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFUNCTION.
