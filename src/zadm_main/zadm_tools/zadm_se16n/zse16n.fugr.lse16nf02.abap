*----------------------------------------------------------------------*
***INCLUDE LSE16NF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_MAX_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_max_lines USING VALUE(p_message).

  DATA: ld_max_size TYPE p LENGTH 16.
  DATA: ld_valmin   LIKE t811flags-valmin.
  STATICS: s_max_lines LIKE sy-tabix.

*.only if table is already entered
  CHECK gd-offset > 0.

*.check if function is deactivated
  SELECT SINGLE valmin FROM t811flags INTO ld_valmin
         WHERE tab   = 'SE16H'
           AND FIELD = 'SELSIZE_MAX_OFF'.
  IF sy-subrc = 0 AND
     ld_valmin = true.
    EXIT.
  ENDIF.

*.check if special value for max size is set
  SELECT SINGLE valmin FROM t811flags INTO ld_valmin
    WHERE tab   = 'SE16H'
      AND field = 'SELSIZE_MAX'.
  IF sy-subrc > 0 OR
     ld_valmin < 10000.
    ld_max_size = c_max_size.
  ELSE.
    MOVE ld_valmin TO ld_max_size.
  ENDIF.

  IF gd-max_lines > 0.
    IF ( gd-offset * gd-max_lines ) > ld_max_size.
*.....avoid field overflow
      IF trunc( ld_max_size / gd-offset ) > 2147483647.
        gd-max_lines = 2147483647.
      ELSE.
        gd-max_lines = trunc( ld_max_size / gd-offset ).
      ENDIF.
      MESSAGE s130(wusl).
    ELSE.
      IF gd-max_lines > c_max_lines.
*.......only send the message once
        IF s_max_lines <> gd-max_lines.
          MESSAGE s114(wusl).
        ENDIF.
        s_max_lines = gd-max_lines.
      ENDIF.
    ENDIF.
*..number of lines is blank, calculate max number allowed
  ELSE.
*...avoid field overflow
    IF trunc( ld_max_size / gd-offset ) > 2147483647.
      gd-max_lines = 2147483647.
    ELSE.
      gd-max_lines = trunc( ld_max_size / gd-offset ).
    ENDIF.
    MESSAGE s130(wusl).
  ENDIF.

ENDFORM.
