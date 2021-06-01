CLASS ltc_bcrypt DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    DATA mo_cut TYPE REF TO zcl_bcrypt.

    METHODS setup.
    METHODS checkpw FOR TESTING.

ENDCLASS.

CLASS ltc_bcrypt IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW zcl_bcrypt( ).

  ENDMETHOD.

  METHOD checkpw.

    DATA:
      lv_plaintext TYPE string,
      lv_hashed    TYPE string.

    lv_plaintext = 'abc'.
    lv_hashed = '$2a$10$WvvTPHKwdBJ3uk0Z37EMR.hLA2W6N9AEBhEgrAOljy2Ae5MtaSIUi'.

    cl_abap_unit_assert=>assert_true( mo_cut->checkpw( iv_plaintext = lv_plaintext iv_hashed = lv_hashed ) ).

  ENDMETHOD.


ENDCLASS.
