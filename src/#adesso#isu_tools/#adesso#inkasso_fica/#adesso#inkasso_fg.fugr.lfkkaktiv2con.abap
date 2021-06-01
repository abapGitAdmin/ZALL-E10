*----------------------------------------------------------------------*
*   INCLUDE LFKKAKTIV2CON                                              *
*----------------------------------------------------------------------*

* Current parameter set version
constants gc_ma_version_451               type fkk_para_version value '19990706'.
constants gc_ma_version_461               type fkk_para_version value '20000204'.
constants gc_ma_version_462               type fkk_para_version value '20000728'.
constants gc_ma_version_464               type fkk_para_version value '20011123'.
constants gc_ma_version_471               type fkk_para_version value '20021113'.
constants gc_ma_version_472               type fkk_para_version value '20031205'.
constants gc_ma_version_ERP2005           type fkk_para_version value '20050501'.
constants gc_ma_version_ERP2005_EhP2      type fkk_para_version value '20070413'.
constants gc_ma_version_ERP2005_EhP4      type fkk_para_version value '20080531'.
constants gc_ma_version_ERP2005_EhP5      type fkk_para_version value '20081101'.
constants gc_ma_version_ERP2005_EhP7      type fkk_para_version value '20120101'.
constants gc_ma_version_ERP2005_EhP7_SP4  type fkk_para_version value '20140423'.
constants gc_ma_version_ERP2005_EhP8      type fkk_para_version value '20150701'.
constants gc_ma_version_erp2007           type fkk_para_version value '20070501'.
* if you change here: Please change also LFKKCORR_GLOBAL_DATACON !
* (-> ABA, correspondence) -> where-used list of versions in FKKCORR_CONST_VERSION
* does not show any code lines where those are used (SBS 2014-01-20)
* if you change here: Please check also function module:
*                     FKK_AKTIV2_RUN_STATUS_READ
constants gc_current_version type fkk_para_version
          value gc_ma_version_erp2005_ehp8.

* Programnames
* dispatcher
constants gc_mad_dispatcher type prognam_kk
          value 'RFKK_MASS_ACT_DISPATCHER'.
* Run parameter deactivator
constants gc_mad_deactivator type prognam_kk
          value 'RFKK_MASS_ACT_PARAMETER_HIDE'.

* Job status
constants gc_fkkaktiv2_status_stopped type xfeld value 'S'.

* Constants for application log
constants gc_appl_log_object type balobj_d value 'FICA'.
constants gc_appl_log_subobject_prefix(2) type c value 'MA'.
constants gc_appl_log_extid_sort_A type c value 'A'. "2586744 replace text-507
constants gc_appl_log_extid_sort_B type c value 'B'. "2586744 replace text-508
constants gc_appl_log_extid_sort_C type c value 'C'. "2586744 replace text-509
constants gc_appl_log_extid_sort_D type c value 'D'. "2586744 replace text-510
constants gc_appl_log_extid_sort_E type c value 'E'. "2586744 replace text-511
constants gc_appl_log_lev1 type i value 1.
constants gc_appl_log_lev2 type i value 2.
constants gc_appl_log_lev3 type i value 3.
constants gc_appl_log_lev4 type i value 4.
constants gc_appl_log_lev5 type i value 5.
constants gc_appl_log_event_1796 type i value gc_appl_log_lev1.
constants gc_appl_log_event_1797 type i value gc_appl_log_lev2.
constants gc_appl_log_interval type i value gc_appl_log_lev3.
constants gc_appl_log_event_1798 type i value gc_appl_log_lev4.
constants gc_appl_log_event_1799 type i value gc_appl_log_lev5.

* Constants for selection from RFDT
constants gc_rfdt_relid type sychar02 value 'KK'.

* constants for edit modes
constants gc_wmode_disp type wmode_kk value '03'.
constants gc_wmode_edit type wmode_kk value '02'.

* constants for activities for authority check
constants gc_actvt_alig type activ_auth value '50'.
constants gc_actvt_copy type activ_auth value '01'.   "Change to D1 ????
constants gc_actvt_dbdele type activ_auth value '41'.
constants gc_actvt_dele type activ_auth value '06'.
constants gc_actvt_disp type activ_auth value '16'.
* authority object F_KKMA: display = 03, edit = 02 ->
* gc_actvt_display and gc_actvt_edit seems to be wrong
constants gc_actvt_display type activ_auth value '02'.
constants gc_actvt_edit type activ_auth value '03'.
constants gc_actvt_hide type activ_auth value 'B4'.
constants gc_actvt_nocontainer type activ_auth value '52'.
constants gc_actvt_save type activ_auth value '32'.
constants gc_actvt_simu type activ_auth value '48'.
constants gc_actvt_stop type activ_auth value '69'.

* constants for search help
constants gc_shlp_maxrecords type ddshmaxrec value 9999.

* constants for values of basic parameters
constants gc_fkkaktiv2_tech_limit_init type dblimit_kk value 1000.
constants gc_fkkaktiv2_tech_xilimit_init type xilimit_kk value 500.

* constants for parameter storage in RFDT
* actual paramater displayable via F4
constants gc_rfdtrelid_mapara_act like rfdt-relid value 'KK'.
* backup of parameters which are version switched
constants gc_rfdtrelid_mapara_vers like rfdt-relid value 'KC'.
* backup of parameters which should be hidden in F4-Help
constants gc_rfdtrelid_mapara_hide like rfdt-relid value 'KH'.
