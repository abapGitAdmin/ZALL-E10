*&---------------------------------------------------------------------*
*& Report  /ADESSO/MT_JVL_ABB_BARZ_WECHS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /ADESSO/MTD_JVL_ABB_BARZ_WECHS.



TABLES: fkkvkp,
        dfkkop.
DATA: ifkkvkp LIKE TABLE OF fkkvkp WITH HEADER LINE.

SELECT-OPTIONS: sezawe FOR fkkvkp-ezawe NO INTERVALS NO-EXTENSION,
                stvorg FOR dfkkop-tvorg NO INTERVALS NO-EXTENSION.

SELECT * FROM fkkvkp INTO TABLE ifkkvkp WHERE ezawe IN sezawe.

LOOP AT ifkkvkp.
  IF stvorg-low = '0010'.
    SELECT SINGLE * FROM dfkkop WHERE gpart = ifkkvkp-gpart
                                AND   vkont = ifkkvkp-vkont
                                AND   augst = '9'
                                AND   augrd = '19'
                                AND   hvorg = '0045'
                                AND   tvorg IN stvorg.

    IF sy-subrc = 0.
      WRITE : / ifkkvkp-vkont.
    ENDIF.

  ELSEIF stvorg-low = '0030'.


    SELECT SINGLE * FROM dfkkop WHERE gpart = ifkkvkp-gpart
                                AND   vkont = ifkkvkp-vkont
                                AND   augst = space
                                AND   hvorg = '0045'
                                AND   tvorg IN stvorg.
    IF sy-subrc = 0.
      WRITE : / ifkkvkp-vkont.
    ENDIF.
  ENDIF.
ENDLOOP.
