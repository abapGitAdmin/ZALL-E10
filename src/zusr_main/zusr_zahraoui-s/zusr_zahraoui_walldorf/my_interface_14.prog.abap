*&---------------------------------------------------------------------*
*&  Include           MY_INTERFACE
*&---------------------------------------------------------------------*

INTERFACE lif_partner.
  METHODS: display_partner.
ENDINTERFACE.
CLASS travel_agency DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor IMPORTING iv_name TYPE string,
      add_partner IMPORTING io_partner TYPE REF TO lif_partner,
      dispaly_agency_partners,
      display_attributes.
  PRIVATE SECTION.
    DATA: mt_partners TYPE TABLE OF REF TO lif_partner,
          mv_name     TYPE string.
ENDCLASS.
CLASS travel_agency IMPLEMENTATION.
  METHOD constructor.
    mv_name = iv_name.
  ENDMETHOD.
  METHOD add_partner.
    APPEND io_partner TO mt_partners.
  ENDMETHOD.
  METHOD dispaly_agency_partners.
    DATA: lo_partner TYPE REF TO lif_partner.
    WRITE: /'Hier sind die Partners von der Agenc Reise der  Agence:'(007).
    ULINE.
    LOOP AT mt_partners INTO lo_partner.
      lo_partner->display_partner( ).
    ENDLOOP.
  ENDMETHOD.
  METHOD display_attributes.
    "info überreisebüro +über dessen Geschäftspartners
    WRITE:/ icon_private_files as ICON,
          'reise agence '(008), mv_name.
    "info über reisbüro
      dispaly_agency_partners( ).
    ENDMETHOD.
ENDCLASS.
