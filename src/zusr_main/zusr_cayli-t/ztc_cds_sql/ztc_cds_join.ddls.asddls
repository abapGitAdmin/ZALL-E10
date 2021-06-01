////"Schwer1      ohne where   746472x37  18 sekunden          |        mit where    10 sekunden     411384x37
@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS  JOIN'
define view ZTC_CDS_JOIN
as select from /ado/sql_all as large
left outer join /ado/sql_salerec as salerec on salerec.id_salerec = large.id_actor
left outer join ztc_db_medium as medium on medium.id_salerec = salerec.id_salerec
left outer join /ado/sql_911 as emerg   on emerg.id_911 = large.id_salerec
{
//large.yearx,
large.length,
large.title, 
large.subject, 
large.actor, 
large.actress, 
large.director, 
large.popularity, 
large.awards,
case large.imagex when 'NicholasCage.png' then 'Example.com' else large.imagex end as case_image, 
salerec.region, 
salerec.country, 
salerec.item_type,
salerec.sales_channel, 
salerec.order_priority,
salerec.order_date, 
medium.order_id, 
medium.ship_date, 
medium.unit_price,
medium.unit_cost,
medium.total_revenue,
medium.total_cost,
medium.total_profit, 
emerg.latitude,
emerg.longitude,
emerg.description_of_emergency, 
emerg.zip, 
emerg.title_of_emergency,
emerg.data_and_time_of_the_call, 
emerg.township, 
emerg.general_adress,
max( medium.total_profit ) as max_profit, 
avg( emerg.latitude ) as avg_latitude, 
min( medium.unit_price ) as min_unit_price,
sum( case when medium.unit_cost <= 200 then medium.unit_cost * 1000 end ) as sum_cost, 
sum( case when medium.units_sold >= 100000000 then 10000000 else 100000 end ) as sum_sold,
max( case when medium.unit_price >= 10000 then 111111 * 99 else medium.unit_price end ) as max_case_unit_price

}
//WHERE medium.sales_channel = 'Online' AND emerg.latitude >= 401065
group by large.yearx,
large.length, 
large.title, 
large.subject, 
large.actor, 
large.actress, 
large.director, 
large.popularity, 
large.awards, 
large.imagex,
salerec.region, 
salerec.country, 
salerec.item_type,
salerec.sales_channel, 
salerec.order_priority,
salerec.order_date,
medium.order_id, 
medium.ship_date, 
medium.unit_price,
medium.unit_cost,
medium.total_revenue, 
medium.total_cost,
medium.total_profit,
emerg.latitude,
emerg.longitude,
emerg.description_of_emergency,
emerg.zip,
emerg.title_of_emergency, 
emerg.data_and_time_of_the_call, 
emerg.township, 
emerg.general_adress





//"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



//*" Version 1 "Schwer2           Ausgabewert: 983675x6 5 Sekunden
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as large
//    left outer join /ado/sql_salerec as salerec
//    on salerec.id_salerec = large.id_actor
//    {
//        large.title as k1,
//        large.subject as k2, 
//        large.actor as k3, 
//        large.actress as k4, 
//        large.director as k5,
//        case large.imagex when 'NicholasCage.png' then 'Example.com' 
//        else large.imagex end as k6 
//    }
//    
//    where large.yearx > '1950'
//                
//    union all
//
//select from ztc_db_medium as medium
//    left outer join /ado/sql_911 as emerg
//    on emerg.id_911 = medium.id_salerec
//    {
//        medium.region as k1, 
//        medium.item_type as k2, 
//        emerg.description_of_emergency as k3, 
//        emerg.title_of_emergency as k4, 
//        emerg.township as k5,
//        case emerg.general_adress when 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' then 'Examplestreet' else emerg.general_adress end as k6
//    }
//    where  medium.unit_price > 10.00
//    




//"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""







//*" Version 2  Schwer2            Ausgabewert: 99365x10   1 sekunde           wieso Groub by
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as large
//    left outer join /ado/sql_salerec as salerec
//    on salerec.id_salerec = large.id_actor
//    {
//        large.title as k1,
//        large.subject as k2, 
//        large.actor as k3, 
//        large.actress as k4, 
//        large.director as k5,
//        case large.imagex when 'NicholasCage.png' then 'Example.com' else large.imagex end as k6,
//        min( large.unit_price ) as k7,
//        max( salerec.total_profit ) as k8,
//        avg( large.latitude ) as k9,
//        sum( case when large.unit_cost <= 200 then large.unit_cost * 1000 end ) as k10
//        
//    }
//    where       large.zip >= '19090'
//    group by    large.title, 
//                large.subject, 
//                large.actor, 
//                large.actress, 
//                large.director, 
//                large.imagex
//                
//union all 
//
//select from ztc_db_medium as medium
//    left outer join /ado/sql_911 as emerg
//    on emerg.id_911 = medium.id_salerec
//    {
//        medium.region as k1, 
//        medium.item_type as k2, 
//        emerg.description_of_emergency as k3, 
//        emerg.title_of_emergency as k4, 
//        emerg.township as k5,
//        case emerg.general_adress when 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' then 'Examplestreet' else emerg.general_adress end as k6,
//        min( medium.unit_price ) as k7,
//        max( medium.units_sold ) as k8,
//        avg( emerg.latitude ) as k9,
//        sum( case when medium.total_profit <= 200 then medium.total_profit * 1000 end ) as k10
//    }
//    where       emerg.latitude >= 401065
//    group by    medium.region, 
//                medium.item_type, 
//                emerg.description_of_emergency, 
//                emerg.title_of_emergency, 
//                emerg.township, 
//                emerg.general_adress
//   
//    
//                
//              














//
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN
//as select from /ado/sql_all as large
//left outer join /ado/sql_salerec as salerec on salerec.id_salerec = large.id_actor
//left outer join ztc_db_medium as medium on medium.id_salerec = salerec.id_salerec
//left outer join /ado/sql_911 as emerg   on emerg.id_911 = large.id_salerec
//{
//key emerg.id_911 as Id911,
//key large.id_911 as Id9112,
//key id_actor as IdActor,
//key id_movie as IdMovie,
//key id_psid as IdPsid,
//key large.id_salerec as IdSalerec,
//key id_star as IdStar,
//key salerec.id_salerec as IdSalerec2,
//key medium.id_salerec as IdSalerec3,
//emerg.latitude as Latitude,
//emerg.longitude as Longitude,
//emerg.description_of_emergency as DescriptionOfEmergency,
//emerg.zip as Zip,
//emerg.title_of_emergency as TitleOfEmergency,
//emerg.data_and_time_of_the_call as DataAndTimeOfTheCall,
//emerg.township as Township,
//emerg.general_adress as GeneralAdress,
//large.latitude as Latitude2,
//large.longitude as Longitude3,
//large.description_of_emergency as DescriptionOfEmergency2,
//large.zip as Zip2,
//large.title_of_emergency as TitleOfEmergency2,
//large.data_and_time_of_the_call as DataAndTimeOfTheCall2,
//large.township as Township2,
//large.general_adress as GeneralAdress2,
//actor_name as ActorName,
//total_gross as TotalGross,
//number_of_movies as NumberOfMovies,
//average_per_movie as AveragePerMovie,
//fst_movie as FstMovie,
//gross as Gross,
//yearx as Yearx,
//length as Length,
//title as Title,
//subject as Subject,
//actor as Actor,
//actress as Actress,
//director as Director,
//popularity as Popularity,
//awards as Awards,
//imagex as Imagex,
//participation as Participation,
//xhours as Xhours,
//youngkids as Youngkids,
//oldkids as Oldkids,
//age as Age,
//education as Education,
//wage as Wage,
//repwage as Repwage,
//hhours as Hhours,
//hage as Hage,
//heducation as Heducation,
//hwage as Hwage,
//fincome as Fincome,
//tax as Tax,
//meducation as Meducation,
//feducation as Feducation,
//unemp as Unemp,
//city as City,
//experience as Experience,
//college as College,
//hcollege as Hcollege,
//large.region as Region,
//large.country as Country,
//large.item_type as ItemType,
//large.sales_channel as SalesChannel,
//large.order_priority as OrderPriority,
//large.order_date as OrderDate,
//large.order_id as OrderId,
//large.ship_date as ShipDate,
//large.units_sold as UnitsSold,
//large.unit_price as UnitPrice,
//large.unit_cost as UnitCost,
//large.total_revenue as TotalRevenue,
//large.total_cost as TotalCost,
//large.total_profit as TotalProfit,
//star_number as StarNumber,
//gender as Gender,
//ethnicity as Ethnicity,
//birth as Birth,
//stark as Stark,
//star1 as Star1,
//star2 as Star2,
//star3 as Star3,
//readk as Readk,
//read1 as Read1,
//read2 as Read2,
//read3 as Read3,
//mathk as Mathk,
//math1 as Math1,
//math2 as Math2,
//math3 as Math3,
//lunchk as Lunchk,
//lunch1 as Lunch1,
//lunch2 as Lunch2,
//lunch3 as Lunch3,
//schoolk as Schoolk,
//school1 as School1,
//school2 as School2,
//school3 as School3,
//degreek as Degreek,
//degree1 as Degree1,
//degree2 as Degree2,
//degree3 as Degree3,
//ladderk as Ladderk,
//ladder1 as Ladder1,
//ladder2 as Ladder2,
//ladder3 as Ladder3,
//experiencek as Experiencek,
//experience1 as Experience1,
//experience2 as Experience2,
//experience3 as Experience3,
//tethnicityk as Tethnicityk,
//tethnicity1 as Tethnicity1,
//tethnicity2 as Tethnicity2,
//tethnicity3 as Tethnicity3,
//systemk as Systemk,
//system1 as System1,
//system2 as System2,
//system3 as System3,
//schoolidk as Schoolidk,
//schoolid1 as Schoolid1,
//schoolid2 as Schoolid2,
//schoolid3 as Schoolid3,
//salerec.region as Region2,
//salerec.country as Country2,
//salerec.item_type as ItemType2,
//salerec.sales_channel as SalesChannel2,
//salerec.order_priority as OrderPriority2,
//salerec.order_date as OrderDate2,
//salerec.order_id as OrderId2,
//salerec.ship_date as ShipDate2,
//salerec.units_sold as UnitsSold2,
//salerec.unit_price as UnitPrice2,
//salerec.unit_cost as UnitCost2,
//salerec.total_revenue as TotalRevenue2,
//salerec.total_cost as TotalCost2,
//salerec.total_profit as TotalProfit2,
//medium.region as Region3,
//medium.country as Country3,
//medium.item_type as ItemType3,
//medium.sales_channel as SalesChannel3,
//medium.order_priority as OrderPriority3,
//medium.order_date as OrderDate3,
//medium.order_id as OrderId3,
//medium.ship_date as ShipDate3,
//medium.units_sold as UnitsSold3,
//medium.unit_price as UnitPrice3,
//medium.unit_cost as UnitCost3,
//medium.total_revenue as TotalRevenue3,
//medium.total_cost as TotalCost3,
//medium.total_profit as TotalProfit3
//
//}
//
//
//
//
//
//
//














































































































































































































































//// Version 2  Schwer2 
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as large
//    left outer join /ado/sql_salerec as salerec
//    on salerec.id_salerec = large.id_actor
//    {
//        large.title as k1,
//        large.subject as k2, 
//        large.actor as k3, 
//        large.actress as k4, 
//        large.director as k5,
//        case large.imagex when 'NicholasCage.png' then 'Example.com' else large.imagex end as k6,
//        min( large.unit_price ) as k7,
//        max( salerec.total_profit ) as k8,
//        avg( large.latitude ) as k9,
//        sum( case when large.unit_cost <= 200 then large.unit_cost * 1000 end ) as k10
//        
//    }
//    where       large.zip >= '19090'
//    group by    large.title, 
//                large.subject, 
//                large.actor, 
//                large.actress, 
//                large.director, 
//                large.imagex
//                
//union
//
//select from ztc_db_medium as medium
//    left outer join /ado/sql_911 as emerg
//    on emerg.id_911 = medium.id_salerec
//    {
//        medium.region as k1, 
//        medium.item_type as k2, 
//        emerg.description_of_emergency as k3, 
//        emerg.title_of_emergency as k4, 
//        emerg.township as k5,
//        case emerg.general_adress when 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' then 'Examplestreet' else emerg.general_adress end as k6,
//        min( medium.unit_price ) as k7,
//        max( medium.units_sold ) as k8,
//        avg( emerg.latitude ) as k9,
//        sum( case when medium.total_profit <= 200 then medium.total_profit * 1000 end ) as k10
//    }
//    where       emerg.latitude >= 401065
//    group by    medium.region, 
//                medium.item_type, 
//                emerg.description_of_emergency, 
//                emerg.title_of_emergency, 
//                emerg.township, 
//                emerg.general_adress
//   
//    
//                
//              





































































































































































//3. Aggregation mit Inner Join
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as alltable
// inner join ztc_db_medium as mediumtable
//    on alltable.id_salerec = mediumtable.id_salerec {
//   
//        alltable.township,
//        max(mediumtable.total_profit) as max_total_profit
//
//  
//}
//
//group by township, mediumtable.total_profit














//2. Inner Join mit Where
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as alltable
//    inner join ztc_db_medium as mediumtable
//    on alltable.id_salerec = mediumtable.id_salerec 
//    {
//   
//       key id_911 as Id911,
//       key id_actor as IdActor,
//       key id_movie as IdMovie, 
//       key alltable.id_salerec as IdSalerec,
//       alltable.latitude,
//       alltable.longitude,
//       alltable.zip,
//       alltable.township,
//       alltable.actor,
//       alltable.number_of_movies,
//       alltable.yearx,
//       alltable.age,
//       mediumtable.region,
//       mediumtable.sales_channel,
//       mediumtable.unit_price,
//       mediumtable.total_profit
//
//  
//}
//
//where mediumtable.sales_channel = 'Online'






//1. Left Outer Join
//@AbapCatalog.sqlViewName: 'ZTC_VIEW_JOIN'
//@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
//@AccessControl.authorizationCheck: #CHECK
//@EndUserText.label: 'CDS  JOIN'
//define view ZTC_CDS_JOIN as select from /ado/sql_all as alltable
// left outer join ztc_db_medium as mediumtable
//    on alltable.id_salerec = mediumtable.id_salerec {
//   
//       key id_911 as Id911,
//       key id_actor as IdActor,
//       key id_movie as IdMovie, 
//       key alltable.id_salerec as IdSalerec,
//       alltable.latitude,
//       alltable.longitude,
//       alltable.zip,
//       alltable.township,
//       alltable.actor,
//       alltable.number_of_movies,
//       alltable.yearx,
//       alltable.age,
//       mediumtable.region,
//       mediumtable.sales_channel,
//       mediumtable.unit_price,
//       mediumtable.total_profit
//
//  
//}
