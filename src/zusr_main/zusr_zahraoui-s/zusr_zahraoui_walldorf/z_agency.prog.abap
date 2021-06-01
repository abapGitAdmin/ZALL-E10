*&---------------------------------------------------------------------*
*&  Include           Z_AGENCY
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZBC_AGENCYYY
*&---------------------------------------------------------------------*

INTERFACE lif_partner.

  METHODS display_partner.
ENDINTERFACE.

"aufga12 frage 2 klasse lokale deklarieren
CLASS lcl_travel_agency DEFINITION.

  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_name TYPE string,
      add_partner IMPORTING io_partner TYPE REF TO lif_partner,
      display_agency_partners,
      display_attributes.
  PRIVATE SECTION.
    DATA:
      mv_name     TYPE string,
      mt_partners TYPE TABLE OF REF TO lif_partner.
ENDCLASS.

CLASS lcl_travel_agency IMPLEMENTATION.
  " frage 5 seite 196
  METHOD display_attributes.
    WRITE: / icon_private_files AS ICON,
    'Travel Reisbuüro agence :', mv_name.
    ULINE.

    display_agency_partners( ).
  ENDMETHOD.


  METHOD display_agency_partners.
    DATA:
          lo_partner TYPE   REF TO lif_partner.
    WRITE 'Hier sind die Partners von dem Reisbüro: '(008).
    LOOP AT mt_partners INTO lo_partner.
      lo_partner->display_partner( ).
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    mv_name = iv_name.
  ENDMETHOD.

  METHOD add_partner.
    APPEND io_partner TO  mt_partners.
  ENDMETHOD.

ENDCLASS.
