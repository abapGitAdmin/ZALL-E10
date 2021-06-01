************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zy_02_flights.
DATA it_flight TYPE TABLE OF spfli.
DATA wa_flight TYPE spfli.
*SQL statement
SELECT * FROM spfli INTO TABLE it_flight.
IF sy-subrc = 0.
  LOOP AT it_flight INTO wa_flight.
    WRITE :/ wa_flight-connid,wa_flight-cityfrom ,wa_flight-countryfr,wa_flight-cityto,wa_flight-countryto.
  ENDLOOP.
ELSE.
  WRITE : 'the SQL statement was not excuted successfully.please try again later.'.
ENDIF.
