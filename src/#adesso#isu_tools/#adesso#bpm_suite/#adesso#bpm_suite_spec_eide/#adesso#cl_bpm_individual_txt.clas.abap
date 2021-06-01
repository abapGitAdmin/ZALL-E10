class /ADESSO/CL_BPM_INDIVIDUAL_TXT definition
  public
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_CCAT type EMMA_CCAT
      !IV_CASE_NR type CHAR10
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_INDIVIDUAL_TXT .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_INDIVIDUAL_TXT IMPLEMENTATION.


  METHOD constructor.



  ENDMETHOD.


  method DETERMINE_INDIVIDUAL_TXT.
  endmethod.
ENDCLASS.
