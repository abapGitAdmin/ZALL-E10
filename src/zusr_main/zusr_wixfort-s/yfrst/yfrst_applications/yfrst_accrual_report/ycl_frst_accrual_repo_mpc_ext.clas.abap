CLASS ycl_frst_accrual_repo_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM ycl_frst_accrual_repo_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS define REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_frst_accrual_repo_mpc_ext IMPLEMENTATION.
  METHOD define.
    super->define( ).
  ENDMETHOD.

ENDCLASS.
