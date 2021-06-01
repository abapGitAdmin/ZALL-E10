FUNCTION /ADZ/HMV_INTERESTS_2090.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_RFKI1) LIKE  RFKI1 STRUCTURE  RFKI1
*"     VALUE(I_CLDATE) LIKE  SY-DATUM
*"     VALUE(I_FKKOP) LIKE  FKKOP STRUCTURE  FKKOP
*"     VALUE(I_FKKIR) LIKE  FKKIR STRUCTURE  FKKIR OPTIONAL
*"     VALUE(I_FKKOP_OR) TYPE  FKKOPKEY OPTIONAL
*"  CHANGING
*"     VALUE(I_FKKOP_ABDAT) LIKE  FKKIR-ABDAT OPTIONAL
*"     VALUE(I_FKKOP_BISDAT) LIKE  FKKIR-BISDAT OPTIONAL
*"     VALUE(I_FKKOP_TODSP) LIKE  FKKIR-TODSP OPTIONAL
*"     VALUE(I_FKKOP_CLRSP) LIKE  FKKIR-CLRSP OPTIONAL
*"     VALUE(I_FKKOP_POAVB) LIKE  FKKIR-POAVB OPTIONAL
*"     VALUE(I_FKKOP_SPZUS) LIKE  FKKIR-SPZUS OPTIONAL
*"     VALUE(I_FKKOP_IKEYD) TYPE  IKEYD_KK OPTIONAL
*"  EXCEPTIONS
*"      SERIOUS_ERROR
*"--------------------------------------------------------------------
* HMV interest key should be set in event 0380 into the item
* HMV in dunning procedure interest should only be calculated
* HMV posting of interest via interest run
* HMV start of interest calculation is printdate of first dunning + 1
* HMV for first interest calculation todate is the print date of 3. dunning
*
  DATA: t_fkkmaze LIKE TABLE OF fkkmaze WITH HEADER LINE.
  DATA: x_1mdrkd LIKE fkkmaze-mdrkd.
  DATA: x_3mdrkd LIKE fkkmaze-mdrkd.
  CONSTANTS:
    co_herkf_intrun(2)  TYPE c   VALUE '27',
    co_herkf_dunning(2) TYPE c   VALUE '28'.

* Aufruf des bisher verwendeten Funktionsbaustein
  CALL FUNCTION 'ISU_TOLERANCE_DAYS_2090'
    EXPORTING
      i_rfki1        = i_rfki1
      i_cldate       = i_cldate
      i_fkkop        = i_fkkop
      i_fkkir        = i_fkkir
      i_fkkop_or     = i_fkkop_or
    CHANGING
      i_fkkop_abdat  = i_fkkop_abdat
      i_fkkop_bisdat = i_fkkop_bisdat
      i_fkkop_todsp  = i_fkkop_todsp
      i_fkkop_clrsp  = i_fkkop_clrsp
      i_fkkop_poavb  = i_fkkop_poavb
      i_fkkop_spzus  = i_fkkop_spzus
      i_fkkop_ikeyd  = i_fkkop_ikeyd
    EXCEPTIONS
      serious_error  = 1
      OTHERS         = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

* select dunnhist
  SELECT * FROM fkkmaze
    INTO TABLE t_fkkmaze
    WHERE opbel = i_fkkop-opbel
    AND   opupw = i_fkkop-opupw
    AND   opupk = i_fkkop-opupk
    AND   opupz = i_fkkop-opupz
    AND   xmsto = space.

* get printing date of 1./3. Dunning
  CLEAR x_1mdrkd.
  CLEAR x_3mdrkd.
  LOOP AT t_fkkmaze.
    CASE  t_fkkmaze-mahns.
      WHEN '01'.
        x_1mdrkd = t_fkkmaze-mdrkd.
      WHEN '03'.
        x_3mdrkd = t_fkkmaze-mdrkd.
    ENDCASE.
  ENDLOOP.

  CASE i_rfki1-herkf.
*   document source is dunning proc.
    WHEN co_herkf_dunning.
      IF x_1mdrkd IS NOT INITIAL.
* this should be first time interest is calculated
* so set the date of the dunning runs
        i_fkkop_abdat  = x_1mdrkd + 1.
        i_fkkop_bisdat = i_rfki1-ausdt.
      ELSE.
        i_fkkop_todsp = 'X'.
      ENDIF.
    WHEN co_herkf_intrun.
* for first interest run (vordate initial) set dates of dunning runs
      IF i_fkkir-vordat IS INITIAL.
        IF x_1mdrkd IS NOT INITIAL AND
           x_3mdrkd IS NOT INITIAL.
          i_fkkop_abdat  = x_1mdrkd + 1.
          i_fkkop_bisdat = x_3mdrkd.
        ELSE.
          i_fkkop_todsp = 'X'.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
