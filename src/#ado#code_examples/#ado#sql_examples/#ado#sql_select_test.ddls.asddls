@AbapCatalog.sqlViewName: '/ADO/SQL_SEL_TST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Select *'
define view /ADO/SQL_SELECT_TEST as select from /ado/sql_test {
  id_911,
  id_actor,
  id_movie,
  latitude,
  longitude,
  description_of_emergency,
  zip,
  title_of_emergency,
  data_and_time_of_the_call,
  township,
  general_adress,
  actor_name,
  total_gross,
  number_of_movies,
  average_per_movie,
  fst_movie,
  gross,
  yearx,
  length,
  title,
  subject,
  actor,
  actress,
  director,
  popularity,
  awards,
  imagex
  
}
