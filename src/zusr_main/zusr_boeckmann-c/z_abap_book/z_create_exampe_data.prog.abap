*&---------------------------------------------------------------------*
*& Report  Z_CREATE_EXAMPE_DATA
*&
*&---------------------------------------------------------------------*
*&
*& Hello World!
*&---------------------------------------------------------------------*
REPORT Z_CREATE_EXAMPE_DATA.

*&---------------------------------------------------------------------*
*& GLOBAL Declarations
*&
*&---------------------------------------------------------------------*

DATA: customer_wa TYPE zcustomers,
      customer_tab TYPE HASHED TABLE OF zcustomers
                      WITH UNIQUE KEY id.

DATA: car_wa TYPE zcars,
      car_tab TYPE HASHED TABLE OF zcars
                      WITH UNIQUE KEY license_plate.

*&---------------------------------------------------------------------*
*& Implementations
*&
*&---------------------------------------------------------------------*

START-OF-SELECTION.

* FILL INTERNAL CUSTOMER TABLE

customer_wa-id = '00000001'.
customer_wa-name = 'Maximilien Vomcat'.
INSERT customer_wa INTO TABLE customer_tab.

customer_wa-id = '00000002'.
customer_wa-name = 'Benjacomin Bozart'.
INSERT customer_wa INTO TABLE customer_tab.

customer_wa-id = '00000003'.
customer_wa-name = 'Johanna Gnade'.
INSERT customer_wa INTO TABLE customer_tab.

customer_wa-id = '00000004'.
customer_wa-name = 'Dolores Oh'.
INSERT customer_wa INTO TABLE customer_tab.

customer_wa-id = '00000005'.
customer_wa-name = 'Max Mustermann'.
INSERT customer_wa INTO TABLE customer_tab.

customer_wa-id = '00000006'.
customer_wa-name = 'Erika Musterfrau'.
INSERT customer_wa INTO TABLE customer_tab.

* UPDATE CUSTOMER DATABASE TABLE FROM INTERNAL TABLE

TRY.
  DELETE FROM zcustomers.
  INSERT zcustomers
      FROM TABLE customer_tab.
  IF sy-subrc = 0.
    MESSAGE 'Customer table updated' TYPE 'I'.
  ENDIF.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Customer table could not be updated' TYPE 'I'
        DISPLAY LIKE 'E'.
ENDTRY.

* FILL INTERNAL CAR TABLE
car_wa-license_plate = '124XX CA'.
car_wa-category = 'A'.
INSERT car_wa INTO TABLE car_tab.

car_wa-license_plate = '5678YY NY'.
car_wa-category = 'A'.
INSERT car_wa INTO TABLE car_tab.

car_wa-license_plate = '4321ZZ NV'.
car_wa-category = 'A'.
INSERT car_wa INTO TABLE car_tab.

car_wa-license_plate = '5522HH NC'.
car_wa-category = 'B'.
INSERT car_wa INTO TABLE car_tab.

car_wa-license_plate = '1717WW AZ'.
car_wa-category = 'C'.
INSERT car_wa INTO TABLE car_tab.


TRY.
  DELETE FROM zcars.
  INSERT zcars
      FROM TABLE car_tab.
  IF sy-subrc = 0.
    MESSAGE 'Car table updated' TYPE 'I'.
  ENDIF.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Car table could not be updated' TYPE 'I'
        DISPLAY LIKE 'E'.
ENDTRY.
