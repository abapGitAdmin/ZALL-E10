CLASS ycl_frst_accrual_repo_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM ycl_frst_accrual_repo_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS accrualreports_get_entity REDEFINITION.
    METHODS accrualreports_get_entityset REDEFINITION.
    METHODS companies_get_entity REDEFINITION.
    METHODS companies_get_entityset REDEFINITION.

  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_frst_accrual_repo_dpc_ext IMPLEMENTATION.
  METHOD accrualreports_get_entity.
    er_entity = VALUE #(
                    ar_id           = '1000000001'
                    settlement_date = sy-datum ).
  ENDMETHOD.

  METHOD accrualreports_get_entityset.
    et_entityset = VALUE #(
                    ( ar_id = '1000000001'
                      settlement_date = sy-datum )
                    ( ar_id = '1000000002'
                      settlement_date = sy-datum - 1 ) ).
  ENDMETHOD.

  METHOD companies_get_entity.
    er_entity = VALUE #(
                   company_code    = '0500'
                   name_of_company = 'Testcompany'
                   city            = 'Hilden' ).
  ENDMETHOD.

  METHOD companies_get_entityset.
    et_entityset = VALUE #(
                      ( company_code    = '0500'
                        name_of_company = 'Testcompany'
                        city            = 'Hilden' )
                      ( company_code    = '0501'
                        name_of_company = 'Testcompany 1'
                        city            = 'Essen' )
                    ).
  ENDMETHOD.

ENDCLASS.
