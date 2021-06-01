*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LV_BPM_RDF01.
*----------------------------------------------------------------------*
FORM /adesso/set_dp_class.
  "SELECT SINGLE ad_bpm_dp_cl_rul FROM /adesso/bpm_gen INTO /adesso/v_bpm_rd-dp_class WHERE bparea = /adesso/v_bpm_rd-bparea.
ENDFORM.
