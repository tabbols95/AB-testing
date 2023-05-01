-- Revenue from control/pilot
WITH table_revenue AS (
SELECT studs.test_grp as test_grp
      ,uniq(studs.st_id) as count_pay_user
      ,sum(fpch.money) as revenue
FROM default.studs studs
    INNER JOIN default.final_project_check fpch ON studs.st_id=fpch.st_id
GROUP BY test_grp),

-- Count user from control/pilot
table_count_user AS (
SELECT test_grp
      ,uniq(st_id) as uniq_user
FROM default.studs
GROUP BY test_grp),

-- Count active user from control/pilot
table_count_active_user AS (
SELECT studs.test_grp as test_grp
      ,count(DISTINCT t.st_id) as count_active_user
FROM (
    SELECT st_id
          ,subject
          ,sum(correct) as count_correct
    FROM default.peas
    GROUP BY st_id, subject
    HAVING count_correct > 10) t
    INNER JOIN default.studs studs ON t.st_id=studs.st_id
GROUP BY test_grp),

-- Revenue math from control/pilot
table_uniq_user_pay_math AS (
SELECT studs.test_grp as test_grp
      ,uniq(studs.st_id) as count_pay_user_math
FROM default.studs studs
    INNER JOIN default.final_project_check fpch ON studs.st_id=fpch.st_id
WHERE fpch.subject='Math'
GROUP BY test_grp),

-- Count active user math from control/pilot
table_count_active_user_math AS (
SELECT studs.test_grp as test_grp
      ,count(DISTINCT t.st_id) as count_active_user_math
FROM (
    SELECT st_id
          ,sum(correct) as count_correct
    FROM default.peas
    WHERE subject='Math'
    GROUP BY st_id
    HAVING count_correct >= 2) t
    INNER JOIN default.studs studs ON t.st_id=studs.st_id
GROUP BY test_grp)

-- Result query
SELECT table_revenue.test_grp as test_grp
      ,table_revenue.revenue / table_count_user.uniq_user as ARPU
      ,table_revenue.revenue / table_count_active_user.count_active_user as ARPAU
      ,table_revenue.count_pay_user / table_count_user.uniq_user * 100 as "CR,%"
      ,table_revenue.count_pay_user / table_count_active_user.count_active_user * 100 as "CR_active,%"
      ,table_uniq_user_pay_math.count_pay_user_math / table_count_active_user_math.count_active_user_math * 100 as "CR_active_math,%"
FROM table_revenue
    INNER JOIN table_count_user ON table_revenue.test_grp=table_count_user.test_grp
    INNER JOIN table_count_active_user ON table_revenue.test_grp=table_count_active_user.test_grp
    INNER JOIN table_uniq_user_pay_math ON table_revenue.test_grp=table_uniq_user_pay_math.test_grp
    INNER JOIN table_count_active_user_math ON table_revenue.test_grp=table_count_active_user_math.test_grp
