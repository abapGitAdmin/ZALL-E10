*----------------------------------------------------------------------*
*   INCLUDE LFICA_MACROS001                                            *
*----------------------------------------------------------------------*
***************************************************************
***
*** Macro for application determination
***
***************************************************************

define mac_applk_get.
* OBSOLETE
* Please use function module FKK_GET_APPLICATION directly!

  call function 'FKK_GET_APPLICATION'
       exporting
            i_set_new        = ' '
            i_no_dialog      = ' '
       importing
            e_applk          = &1
       exceptions
            no_appl_selected = 1
            others           = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
end-of-definition.
