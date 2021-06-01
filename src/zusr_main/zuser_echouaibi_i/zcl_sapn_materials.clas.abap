class ZCL_SAPN_MATERIALS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_mara,

             matnr TYPE mara-matnr,
             ersda TYPE mara-ersda,
             mtart TYPE mara-mtart,
             matkl TYPE mara-matkl,
             meins TYPE mara-meins,
           END OF ty_mara .

  data:
    tt_mara TYPE TABLE OF ty_mara .
  data LANGUAGE type MAKT-SPRAS .

  events NO_MATERIAL_FOUND .

  methods CONSTRUCTOR
    importing
      !IM_SPRAS type MAKT-SPRAS .
  methods GET_MATERIAL_DETAILS
    importing
      !IM_MATNR type MARA-MATNR
    exporting
      !EX_MARA type MARA .
  methods GET_MATERIALS_FOR_TYPE
    importing
      !IM_MTART type MARA-MTART
    exporting
      !ET_MARA type ZSAPNUTS_MARA .
  methods GET_MATERIAL_FOR_DATE
    importing
      !IM_DATE type MARA-ERSDA
    exporting
      !ET_MARA like TT_MARA .
  methods NO_MATRIAL_FOUND_HANDLER
    for event NO_MATERIAL_FOUND of ZCL_SAPN_MATERIALS .
  methods GET_MATERIAL_DESCRIPTION
    importing
      !IM_MATNR type MARA-MATNR
    exporting
      !EX_MAKT type MAKT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SAPN_MATERIALS IMPLEMENTATION.


  method CONSTRUCTOR.


     language = im_spras.

  endmethod.


  method GET_MATERIALS_FOR_TYPE.
    SELECT * from mara
      INTO TABLE et_mara
      WHERE mtart = im_mtart.
  endmethod.


  method GET_MATERIAL_DESCRIPTION.

    select SINGLE * from makt into ex_makt
      WHERE matnr = im_matnr
      and spras = language.

      IF ex_makt is INITIAL.

        raise EVENT no_material_found.

      ENDIF.

  endmethod.


  method GET_MATERIAL_DETAILS.


            select SINGLE * from mara
                    into ex_mara WHERE matnr = im_matnr.
              IF ex_mara is INITIAL.

                RAISE EVENT no_material_found.

              ENDIF.



  endmethod.


  method GET_MATERIAL_FOR_DATE.


    select matnr ersda mtart matkl meins from mara
      into TABLE et_mara
      where ersda = im_date.


  endmethod.


  method NO_MATRIAL_FOUND_HANDLER.

         WRITE:/ 'NO_ metarial gefunden. ich schwöre es!'.

  endmethod.
ENDCLASS.
