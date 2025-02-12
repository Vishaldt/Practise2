-- dt_inovar_prod_edw.v_aberdeen_jobcost source

-- On 24-12 moved to datamart


CREATE OR REPLACE VIEW dt_inovar_prod_edw.v_aberdeen_jobcost



create TABLE dt_inovar_prod_datamart.u_mat_aberdeen_jobcost
as SELECT *  FROM dt_inovar_prod_datamart.v_aberdeen_jobcost

drop table dt_inovar_prod_datamart.u_mat_aberdeen_jobcost

create or replace view dt_inovar_prod_datamart.v_aberdeen_jobcost
AS WITH date_series AS (
         SELECT date(generate_series('2022-01-01 00:00:00'::timestamp without time zone, date_trunc('year'::text, now()::date::timestamp with time zone)::date + '1 year'::interval - '1 day'::interval, '1 day'::interval)) AS dt
        ), bu_dept AS (
         SELECT DISTINCT mfglocation.description AS businessunit,
                CASE
                    WHEN dept.jcdeptdescription IS NULL THEN 'Materials'::text
                    ELSE dept.jcdeptdescription
                END AS department_name
           FROM dt_inovar_prod_stg.in_aberdeen_fact_job job
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_manufacturinglocation mfglocation ON mfglocation.id = job.manufacturinglocation
             JOIN dt_inovar_prod_stg.in_aberdeen_fact_jobcost jc ON jc.ccmasterid = job.ccmasterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act ON act.jcmasterid = jc.jcmasterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_costcenter cc ON cc.jccostcenterid = act.jccostcenterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_department dept ON dept.jcdeptid = cc.jcdeptid
          WHERE job.ccdatesetup >= '2022-01-01'::date
        ), bu_dateseries AS (
         SELECT date_series.dt,
            bu_dept.businessunit,
            bu_dept.department_name
           FROM date_series
             CROSS JOIN bu_dept
        ), act_est AS (
         SELECT mfglocation.description AS businessunit,
            job.ccmasterid AS job,
            job.ccdatesetup AS order_date,
            COALESCE(jc.esmasterid, 'Unmapped'::text) AS estimate_id,
                CASE
                    WHEN dept.jcdeptid IS NULL THEN '000'::text
                    ELSE dept.jcdeptid
                END AS department_id,
                CASE
                    WHEN dept.jcdeptdescription IS NULL THEN 'Materials'::text
                    ELSE dept.jcdeptdescription
                END AS department_name,
            COALESCE(jc.jcmasterid, 'Unmapped'::text) AS category_id,
            COALESCE(act.jcdescription, act1.jcdescription, act2.jcdescription, act3.jcdescription, act4.jcdescription, act5.jcdescription, 'Unmapped'::text) AS category_name,
            COALESCE(salesperson.arsalesname, 'Unmapped'::text) AS salesperson,
            COALESCE(csr.arcsrname, 'Unmapped'::text) AS csr,
            COALESCE(cust.arcustname, 'Unmapped'::text) AS customer,
            COALESCE(jc.ccjobpart, 'Unmapped'::text) AS part,
            jobpart.qty_shipped,
            jobpart.qty_ordered,
            jobpart.total_act_hours,
            jobpart.material_cost,
            max(
                CASE
                    WHEN jc.jcchargeclass = 1 THEN jc.jcesthours
                    ELSE 0::double precision
                END) AS estimated_hours,
            max(
                CASE
                    WHEN jc.jcchargeclass = 9 THEN jc.jcacthours
                    ELSE 0::double precision
                END) AS actual_hours,
            sum(
                CASE
                    WHEN jc.jcchargeclass = 1 THEN jc.jcestimatedcost
                    ELSE 0::double precision
                END) AS estimated_cost,
            sum(
                CASE
                    WHEN jc.jcchargeclass = 9 THEN jc.jcactcost
                    ELSE 0::double precision
                END) AS actual_cost
           FROM dt_inovar_prod_stg.in_aberdeen_fact_job job
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_manufacturinglocation mfglocation ON mfglocation.id = job.manufacturinglocation
             JOIN dt_inovar_prod_stg.in_aberdeen_fact_jobcost jc ON jc.ccmasterid = job.ccmasterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act ON act.jcmasterid = jc.jcmasterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act1 ON act1.jcmasterid = concat('0', jc.jcmasterid) AND jc.jcmasterid IS NOT NULL
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act2 ON act2.jcmasterid = concat('00', jc.jcmasterid) AND jc.jcmasterid IS NOT NULL
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act3 ON act3.jcmasterid = concat('000', jc.jcmasterid) AND jc.jcmasterid IS NOT NULL
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act4 ON act4.jcmasterid = concat('0000', jc.jcmasterid) AND jc.jcmasterid IS NOT NULL
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_activitycode act5 ON act5.jcmasterid = concat('00000', jc.jcmasterid) AND jc.jcmasterid IS NOT NULL
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_costcenter cc ON cc.jccostcenterid = act.jccostcenterid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_department dept ON dept.jcdeptid = cc.jcdeptid
             LEFT JOIN ( SELECT jobpart_1.ccmasterid,
                    jobpart_1.ccjobpart,
                    sum(jobpart_1.ccqtyshipped) AS qty_shipped,
                    sum(jobpart_1.ccqtyordered) AS qty_ordered,
                    sum(jobpart_1.cctotalhours) AS total_act_hours,
                    sum(jobpart_1.ccjobcost01) AS material_cost
                   FROM dt_inovar_prod_stg.in_aberdeen_fact_jobpart jobpart_1
                  GROUP BY jobpart_1.ccmasterid, jobpart_1.ccjobpart) jobpart ON jobpart.ccmasterid = job.ccmasterid AND jobpart.ccjobpart = jc.ccjobpart
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_salesperson salesperson ON salesperson.arsalesid = job.arsalesid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_csr csr ON csr.arcsrid = job.arcsrid
             LEFT JOIN dt_inovar_prod_stg.in_aberdeen_dim_customer cust ON job.armasterid = cust.armasterid
          WHERE job.ccdatesetup >= '2022-01-01'::date
          GROUP BY mfglocation.description, job.ccmasterid, job.ccdatesetup, (COALESCE(jc.esmasterid, 'Unmapped'::text)), (
                CASE
                    WHEN dept.jcdeptid IS NULL THEN '000'::text
                    ELSE dept.jcdeptid
                END), (
                CASE
                    WHEN dept.jcdeptdescription IS NULL THEN 'Materials'::text
                    ELSE dept.jcdeptdescription
                END), (COALESCE(jc.jcmasterid, 'Unmapped'::text)), (COALESCE(act.jcdescription, act1.jcdescription, act2.jcdescription, act3.jcdescription, act4.jcdescription, act5.jcdescription, 'Unmapped'::text)), (COALESCE(salesperson.arsalesname, 'Unmapped'::text)), (COALESCE(csr.arcsrname, 'Unmapped'::text)), (COALESCE(cust.arcustname, 'Unmapped'::text)), (COALESCE(jc.ccjobpart, 'Unmapped'::text)), jobpart.qty_shipped, jobpart.qty_ordered, jobpart.total_act_hours, jobpart.material_cost
        )
 SELECT bu_dateseries.businessunit,
    act_est.job,
    bu_dateseries.dt,
    act_est.estimate_id,
    act_est.department_id,
    bu_dateseries.department_name,
    act_est.category_id,
    act_est.category_name,
    act_est.salesperson,
    act_est.csr,
    act_est.customer,
    act_est.part,
    act_est.qty_shipped,
    act_est.qty_ordered,
    act_est.total_act_hours,
    act_est.material_cost,
    act_est.estimated_hours,
    act_est.actual_hours,
    act_est.estimated_cost,
    act_est.actual_cost
   FROM bu_dateseries
     LEFT JOIN act_est ON act_est.order_date = bu_dateseries.dt AND act_est.businessunit = bu_dateseries.businessunit AND act_est.department_name = bu_dateseries.department_name
  WHERE bu_dateseries.dt <= (CURRENT_DATE - 1);