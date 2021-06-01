*&---------------------------------------------------------------------*
*&  Include           ZISU_MD_BPARTNER_IMPORT_E01
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM file_value_request.

AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
    WHEN /idexgg/cl_isu_co=>co_fcode_fc01.
      PERFORM download_template.
    WHEN OTHERS.
  ENDCASE.

INITIALIZATION.
  PERFORM initialization.

START-OF-SELECTION.
  PERFORM run_application.
