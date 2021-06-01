FUNCTION Z_BONUS_TEST_EX.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SRSC_S_IF_SIMPLE-REQUNR
*"     VALUE(I_DSOURCE) TYPE  SRSC_S_IF_SIMPLE-DSOURCE OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SRSC_S_IF_SIMPLE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SRSC_S_IF_SIMPLE-INITFLAG OPTIONAL
*"     VALUE(I_READ_ONLY) TYPE  SRSC_S_IF_SIMPLE-READONLY OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SRSC_S_IF_SIMPLE-T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SRSC_S_IF_SIMPLE-T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  ZABE_TEST_BONUS OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"----------------------------------------------------------------------


*****************************************************************************
*Definition
*****************************************************************************

  data:  ld_idx_min    type i value '1',
         ld_idx_max    type i.

  "Zwischentabelle als static definieren
  statics: gt_global_result like table of e_t_data.

*****************************************************************************
*INIT Daten selektieren
*****************************************************************************

  if i_initflag = sbiwa_c_flag_on.

        select
          df~opbel,
          df~vkont,
          df~vtref,
          dpk~HKONT,
          dpk~betrh

          into corresponding fields of table @gt_global_result
          from dfkkop as df

          left join dfkkopk as dpk
                on df~opbel = dpk~opbel
          where dpk~opupk = '2'.



        if sy-subrc <> 0.
          raise error_passed_to_mess_handler.
        endif.

   else.

*****************************************************************************
*Datensätze übertragen
*****************************************************************************

    describe table gt_global_result lines ld_idx_max.

    if ld_idx_max = 0.
      raise no_more_data. "Es sind keine Daten mehr vorhanden
    endif.

    if ld_idx_max => i_maxsize.
      ld_idx_max = i_maxsize. "Es sind noch genug Sätze für ein weiteres Paket vorhanden.
    endif.

     check ld_idx_max > 0.
    insert lines of gt_global_result from ld_idx_min to ld_idx_max
           into table e_t_data[].
    delete gt_global_result from ld_idx_min to ld_idx_max.

  endif.

ENDFUNCTION.
