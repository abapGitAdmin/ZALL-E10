@AbapCatalog.sqlViewName: '/ADO/SQL_SEL_ALL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Select *'
define view /ADO/SQL_SELECT_ALL 
  as select from /ado/sql_all 
{
  *
}            
where order_id < '100477540'
  
//  id_911,
//  id_actor,
//  id_movie,
//  id_psid,
//  id_salerec,
//  id_star,
//  latitude,
//  longitude,
//  description_of_emergency,
//  zip,
//  title_of_emergency,
//  data_and_time_of_the_call,
//  township,
//  general_adress,
//  actor_name,
//  total_gross,
//  number_of_movies,
//  average_per_movie,
//  fst_movie,
//  gross,
//  yearx,
//  length,
//  title,
//  subject,
//  actor,
//  actress,
//  director,
//  popularity,
//  awards,
//  imagex,
//  participation,
//  xhours,
//  youngkids,
//  oldkids,
//  age,
//  education,
//  wage,
//  repwage,
//  hhours,
//  hage,
//  heducation,
//  hwage,
//  fincome,
//  tax,
//  meducation,
//  feducation,
//  unemp,
//  city,
//  experience,
//  college,
//  hcollege,
//  region,
//  country,
//  item_type,
//  sales_channel,
//  order_priority,
//  order_date,
//  order_id,
//  ship_date,
//  units_sold,
//  unit_price,
//  unit_cost,
//  total_revenue,
//  total_cost,
//  total_profit,
//  star_number,
//  gender,
//  ethnicity,
//  birth,
//  stark,
//  star1,
//  star2,
//  star3,
//  readk,
//  read1,
//  read2,
//  read3,
//  mathk,
//  math1,
//  math2,
//  math3,
//  lunchk,
//  lunch1,
//  lunch2,
//  lunch3,
//  schoolk,
//  school1,
//  school2,
//  school3,
//  degreek,
//  degree1,
//  degree2,
//  degree3,
//  ladderk,
//  ladder1,
//  ladder2,
//  ladder3,
//  experiencek,
//  experience1,
//  experience2,
//  experience3,
//  tethnicityk,
//  tethnicity1,
//  tethnicity2,
//  tethnicity3,
//  systemk,
//  system1,
//  system2,
//  system3,
//  schoolidk,
//  schoolid1,
//  schoolid2,                 
//  schoolid3    
