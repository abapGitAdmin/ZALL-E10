class ZTC_GCL_KUNDE definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !NAME type STRING .
  methods EINZAHLEN
    importing
      !BETRAG type I .
  methods AUSZAHLEN
    importing
      !BETRAG type I .
  methods GETGUTHABEN
    returning
      value(RGUTHABEN) type I .
protected section.
private section.

  data NAME type STRING .
  data KUNDENID type I .
  class-data ANZ_KUNDEN type I .
  data GUTHABEN type I .
ENDCLASS.



CLASS ZTC_GCL_KUNDE IMPLEMENTATION.


  method AUSZAHLEN.

    "mit me?     ohne Changing versuchen
  guthaben = guthaben - betrag.


  endmethod.


  method CONSTRUCTOR.





  endmethod.


  method EINZAHLEN.

  "mit me?     ohne Changing versuchen
  guthaben = guthaben + betrag.


  endmethod.


  method GETGUTHABEN.

    "So richtig?????
    rguthaben = guthaben.

  endmethod.
ENDCLASS.
