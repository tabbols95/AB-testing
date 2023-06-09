/*
Образовательные курсы состоят из различных уроков, каждый из которых состоит из нескольких маленьких заданий.
Каждое такое маленькое задание называется "горошиной".
Назовём очень усердным учеником того пользователя, который хотя бы раз за текущий месяц правильно решил 20 горошин.

Необходимо написать оптимальный запрос, который даст информацию о количестве очень усердных студентов.
NB! Под усердным студентом мы понимаем студента, который правильно решил 20 задач за текущий месяц.
*/

/* 
Формируем таблицу, содержащую: 
	* id студента,
	* дату (приведенную к началу месяца),
	* кол-во правильно решенных задач за месяц.
*/
WITH t AS (
	SELECT st_id
		  ,DATE_TRUNC('month', timest) AS date_to_month
		  ,SUM(correct::INT) OVER (PARTITION BY st_id, DATE_TRUNC('month', timest)) as ball_of_month
	  FROM default.peas
)

/* 
Отбираем студентов по следующим условиям:
	* текущий месяц - самая последняя дата, имеющаяся в нашей БД
	* кол-во правильно решенных задач за текущий месяц равное 20
*/
SELECT COUNT(DISTINCT st_id) AS count_diligent_student
  FROM t
  WHERE date_to_month = (SELECT MAX(date_to_month) FROM t)
    AND ball_of_month = 20;
    -- AND ball_of_month >= 20;