************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: XXXXX-X                                      Datum: TT.MM.JJJJ
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_08_c_machine.

type-pools: abap.

class lcl_wasserbehaelter definition.
  public section.
    constants:
      gc_wasser_haerte_grenze type f value '14.0'.
    methods:
      check_wasser_haerte,
      set_wasserstand
        importing value(id_wasserstand) type i,
      get_wasserstand
*        exporting ed_wasserstand type i.
        returning value(rd_wasserstand) type i.
  protected section.
  private section.
    data:
      gd_wasserstand  type i,
      gd_wasserhaerte type f.
endclass.
class lcl_wasserbehaelter implementation.
  method check_wasser_haerte.
    if me->gd_wasserhaerte > gc_wasser_haerte_grenze.
      message 'AU, das tut weh!' type 'I'.
    endif.
  endmethod.

  method set_wasserstand.
    me->gd_wasserstand = id_wasserstand.
  endmethod.

  method get_wasserstand.
    rd_wasserstand = me->gd_wasserstand.
  endmethod.
endclass.

class lcl_kaffevollautomat definition.
  public section.
    class-data:
      anz_kva type i.
    methods:
      constructor,
      ein_kaffe_sil_vous_plait
        importing
          value(id_espresso)      type abap_bool optional
          value(id_verlaengerter) type abap_bool optional.
    class-methods:
      add_1_to_anz_kva.
  protected section.
  private section.
    data:
      gd_wasserstand     type i,
      gr_wasserbehaelter type ref to lcl_wasserbehaelter.
endclass.
class lcl_kaffevollautomat implementation.
  method constructor.
*    anz_kva = anz_kva + 1.
*    add 1 to lcl_kaffevollautomat=>anz_kva.
    call method add_1_to_anz_kva.
*    call method me->add_1_to_anz_kva.
*    call method lcl_kaffevollautomat=>add_1_to_anz_kva.
*    me->add_1_to_anz_kva( ).
*    lcl_kaffevollautomat=>add_1_to_anz_kva( ).
    create object me->gr_wasserbehaelter.
    me->gr_wasserbehaelter->set_wasserstand( id_wasserstand = 1000 ).
  endmethod.

  method ein_kaffe_sil_vous_plait.
    write: gr_wasserbehaelter->get_wasserstand( ).
  endmethod.

  method add_1_to_anz_kva.
  endmethod.
endclass.

data gd_zubereitungsart type char40.
data gr_rolands_kva type ref to lcl_kaffevollautomat.
data gr_mein_kva type ref to lcl_kaffevollautomat.

start-of-selection.
  create object gr_rolands_kva.
  create object gr_mein_kva.
  gr_mein_kva->ein_kaffe_sil_vous_plait(
    id_espresso = abap_true
    id_verlaengerter = abap_true
  ).
