class ZCL_FOR_RAISE_EVENT definition
  public
  create public .

public section.

  events PEAK_SPEED_REACHED
    exporting
      value(E_SPEED) type NUM .

  methods GET_SPEED_OF_BIKE
    importing
      !I_SPEED type NUM .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FOR_RAISE_EVENT IMPLEMENTATION.


  METHOD get_speed_of_bike.


    IF i_speed <= 80.

      WRITE:/ 'The Speed', i_speed, 'ist OK'.
    ELSE.

      RAISE EVENT peak_speed_reached
        EXPORTING
          e_speed =  i_speed            " Laufende Nummer
        .

    ENDIF.


  ENDMETHOD.
ENDCLASS.
