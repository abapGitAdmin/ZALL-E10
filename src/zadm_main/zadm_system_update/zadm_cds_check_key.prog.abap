*&---------------------------------------------------------------------*
*& Report  ZCDS_CHECK_KEY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZADM_CDS_CHECK_KEY.

PARAMETERS:
   " name of DDL Source. If initial all cds views are selected
   ddlname  TYPE ddddlsrc-ddlname default '*'.

class   lcl_check_cdsviews definition.

   public section.
    types:
          Begin of t_ddl,
            ddlname type ddddlsrc-ddlname,
             devclass type tadir-devclass,
          end of t_ddl,
           Begin of t_ddlsrc,
              ddlname type ddddlsrc-ddlname,
             devclass type tadir-devclass,
              source type ddddlsrc-source,
           end of t_ddlsrc,
           t_ddlt type standard table of t_ddl with key ddlname,
           t_ddlsrct type standard table of t_ddlsrc with key ddlname  .

   class-methods:
     main importing ddlname type ddddlsrc-ddlname
         returning value(cdsddls) type t_ddlt.

endclass.


class  lcl_check_cdsviews implementation.
  method main.

   data: l_parser type ref to cl_ddl_parser,
         l_ddlstmt type ref to cl_qlast_ddlstmt,
         l_viewdef type ref to cl_qlast_view_definition,
         l_exc type ref to cx_ddl_parser_exception,

         l_selectListEntry type ref to cl_qlast_selectlist_entry,
         l_stdSelectListEntry type ref to cl_qlast_stdselectlist_entry,
         l_keyfound type c,
         ddls type t_ddlsrct.

   if ddlname is initial or ddlname = '*'.

    SELECT src~ddlname, tadir~devclass AS package, src~source
      FROM ddddlsrc as src left outer JOIN tadir ON tadir~obj_name = src~ddlname
      INTO TABLE @ddls
      WHERE  tadir~pgmid = 'R3TR' AND tadir~object = 'DDLS'
      AND src~as4local = 'A'
      order by ddlname .

   else.

   SELECT src~ddlname, tadir~devclass AS package, src~source
      FROM ddddlsrc as src left outer JOIN tadir ON tadir~obj_name = src~ddlname
      INTO TABLE @ddls
      WHERE src~ddlname = @ddlname
      AND src~as4local = 'A'
      and tadir~object = 'DDLS'
     .
   endif.

      create object l_parser.
      loop at ddls assigning field-symbol(<fs_ddl>).
        try.
         l_ddlstmt = l_parser->PARSE_DDL(
              exporting
                SOURCE                  = <fs_ddl>-source
                SEMANTIC_CHECK          = 'X'
            ) .
         catch cx_ddl_parser_exception into l_exc.
         ENDTRY.
         if l_ddlstmt is bound.
            if l_ddlstmt->get_type( ) = cl_qlast_constants=>ddlstmt_type_view_definition.
              l_viewdef = cast cl_qlast_view_definition( l_ddlstmt ).
              l_keyfound = 'B'.
              loop at l_viewdef->get_select( )->get_selectlist( )->get_entries( ) into l_selectlistentry.
                if l_selectlistentry->get_type( ) = cl_qlast_constants=>selectlist_entry_std.
                 l_stdselectlistentry = cast cl_qlast_stdselectlist_entry( l_selectlistentry ).
                 if l_stdselectlistentry->iskeyelement( ) = ABAP_TRUE.
                  if sy-tabix = 1 .
                    " begin of select
                     l_keyfound = 'K'.
                  else.
                     if l_keyfound = 'C'.
                       l_keyfound = 'K'.
                     elseif l_keyfound <> 'K'.
                      " error
                      insert value t_ddl( ddlname = <fs_ddl>-ddlname devclass = <fs_ddl>-devclass ) into table cdsddls.
                      exit.
                    endif.
                  endif.
                 else.
                  if sy-tabix = 1 .
                    " begin of select
                    if l_stdselectlistentry->if_qlast_annotable~get_annotations( ) is bound and l_stdselectlistentry->if_qlast_annotable~get_annotations( )->get( 'ABAPCATALOG.INTERNAL.ISMANDT' ) is bound.
                       l_keyfound = 'C'.
                    endif.
                  else.
                   if l_keyfound = 'K' or l_keyfound = 'C' .
                     l_keyfound = 'A'.
                   endif.
                   endif.
                 endif.
                 endif.
              endloop.
            endif.
         endif.
      endloop.
      sort cdsddls by devclass ascending ddlname ascending.
  endmethod.
endclass.


start-of-SELECTION.
  data(ddls) = lcl_check_cdsviews=>main( ddlname = ddlname ).
  cl_demo_output=>display_data( value = ddls  name = |2362658 - ABAP CDS Views: Key must be contiguous and start at the first position. The following CDS-Source are not compliant:| ).
