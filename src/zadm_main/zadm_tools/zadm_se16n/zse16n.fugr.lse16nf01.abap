*----------------------------------------------------------------------*
***INCLUDE LSE16NF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CRIT_NEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1071   text
*----------------------------------------------------------------------*
FORM crit_next USING VALUE(p_screen).

  DATA: ls_selfields TYPE se16n_selfields.
  DATA: ld_tabix     LIKE sy-tabix.

  CASE p_screen.
    WHEN '0111'.
      GET CURSOR LINE ld_line.
      ld_line = multi_or_tc-current_line
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < multi_or_tc-current_line.
        EXIT.
      ENDIF.

      ADD 1 TO ld_line.
      LOOP AT gt_multi_or INTO ls_selfields FROM ld_line
           WHERE NOT low    IS INITIAL OR
                 NOT high   IS INITIAL OR
                 NOT option IS INITIAL.
        ld_tabix = sy-tabix.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        multi_or_tc-top_line = ld_tabix.
        multi_or_tc-current_line = ld_tabix.
        gd_cursor_line = 1.
      ENDIF.
    WHEN '0100'.
      GET CURSOR LINE ld_line.
      ld_line = selfields_tc-current_line
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < selfields_tc-current_line.
        EXIT.
      ENDIF.

      ADD 1 TO ld_line.
      LOOP AT gt_selfields INTO ls_selfields FROM ld_line
           WHERE NOT low    IS INITIAL OR
                 NOT high   IS INITIAL OR
                 NOT option IS INITIAL.
        ld_tabix = sy-tabix.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        selfields_tc-top_line = ld_tabix.
        selfields_tc-current_line = ld_tabix.
        gd_cursor_line = 1.
      ENDIF.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CRIT_PREV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1077   text
*----------------------------------------------------------------------*
FORM crit_prev USING VALUE(p_screen).

  DATA: ls_selfields TYPE se16n_selfields.
  DATA: ld_tabix     LIKE sy-tabix.

  CASE p_screen.
    WHEN '0111'.
      GET CURSOR LINE ld_line.
      ld_line = multi_or_tc-current_line
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < multi_or_tc-current_line.
        EXIT.
      ENDIF.

      CHECK ld_line > 1.
      SUBTRACT 1 FROM ld_line.
*.now search upwards
      LOOP AT gt_multi_or INTO ls_selfields FROM 1
                                            TO ld_line
           WHERE NOT low    IS INITIAL OR
                 NOT high   IS INITIAL OR
                 NOT option IS INITIAL.
        ld_tabix = sy-tabix.
      ENDLOOP.
*.the last found is automatically the nearest previous to current one
      IF sy-subrc = 0.
        multi_or_tc-top_line = ld_tabix.
        multi_or_tc-current_line = ld_tabix.
        gd_cursor_line = 1.
      ENDIF.
    WHEN '0100'.
      GET CURSOR LINE ld_line.
      ld_line = selfields_tc-current_line
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < selfields_tc-current_line.
        EXIT.
      ENDIF.

      CHECK ld_line > 1.
      SUBTRACT 1 FROM ld_line.
*.now search upwards
      LOOP AT gt_selfields INTO ls_selfields FROM 1
                                             TO ld_line
           WHERE NOT low    IS INITIAL OR
                 NOT high   IS INITIAL OR
                 NOT option IS INITIAL.
        ld_tabix = sy-tabix.
      ENDLOOP.
*.the last found is automatically the nearest previous to current one
      IF sy-subrc = 0.
        selfields_tc-top_line = ld_tabix.
        selfields_tc-current_line = ld_tabix.
        gd_cursor_line = 1.
      ENDIF.
  ENDCASE.

ENDFORM.
