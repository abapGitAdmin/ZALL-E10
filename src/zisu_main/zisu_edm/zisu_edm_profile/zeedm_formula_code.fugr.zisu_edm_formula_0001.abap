FUNCTION ZISU_EDM_FORMULA_0001.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  CHANGING
*"     REFERENCE(XY_CNTR) TYPE  EEDMFORMULACTR
*"     REFERENCE(XY_INP) TYPE  TEEDMFORMPARLIST_I
*"     REFERENCE(XY_OUT) TYPE  TEEDMFORMPARLIST_O
*"  EXCEPTIONS
*"      GENERAL_FAULT
*"--------------------------------------------------------------------

*$*$ 1. initialisation

  edm_formula_init.

*$*$ 2. declare input parameters

* measured value
  edm_def_par_input 1.
* limit 1
  edm_def_par_input 2.
* limit 2
  edm_def_par_input 3.

*$*$ 3. declare output parameters

* part of the value under limit 1
  edm_def_par_output 1.
* part of the value over limit 1
  edm_def_par_output 2.
* part of the value over limit 2
  edm_def_par_output 3.
* part of the value over limit 1 (copy)
  edm_def_par_output 4.

*$*$ 4. consistency checks

  edm_formula_check.

*$*$ 5. declare temporary variables


*$*$ 6. implementation

  edm_reset_index.
  DO.
*   read measured value
    edm_read_input 1.
*   read limit 1 value
    edm_read_input 2.
*   read limit 2 value
    edm_read_input 3.
*   check if measured value exceeds limit 1
    IF xval1 > xval2.
      yval1 = xval2.
      yval2 = xval1 - xval2.
    ELSE.
      yval1 = xval1.
      yval2 = 0.
    ENDIF.
*   check if measured value exceeds limit 2
    IF xval1 > xval3.
      yval3 = xval1 - xval3.
    ELSE.
      yval3 = 0.
    ENDIF.
*   fill value under limit 1
    edm_append_output 1.
*   fill value over limit 1
    edm_append_output 2.
*   fill value over limit 2
    edm_append_output 3.
*   copy of input 1 as a demand value
    IF xmod1 = co_calcmod_use.
      yval4 = yval2.
    ELSE.
      yval4 = 0.
    ENDIF.
    edm_quant_to_demand yval4.
    edm_append_output 4.
*   next index of profile
    edm_next_index.
  ENDDO.
  edm_check_all_values.

ENDFUNCTION.
