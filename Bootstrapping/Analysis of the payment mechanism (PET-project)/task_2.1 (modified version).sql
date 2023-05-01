/*
Образовательные курсы состоят из различных уроков, каждый из которых состоит из нескольких маленьких заданий.
Каждое такое маленькое задание называется "горошиной".
Назовём очень усердным учеником того пользователя, который хотя бы раз за текущий месяц правильно решил 20 горошин.

Необходимо написать оптимальный запрос, который даст информацию о количестве очень усердных студентов.
NB! Под усердным студентом мы понимаем студента, который правильно решил 20 задач за текущий месяц.
*/

/*
	ДАННЫЙ ЗАПРОС ЯВЛЯЕТСЯ МОДИФИЦИРОВАННОЙ ВЕРСИЕЙ ОСНОВНОГО ЗАДАНИЯ
	
	ЗДЕСЬ УЧИТЫВАЕТСЯ УСЛОВИЕ, ЧТО СТУДЕНТ ДОЛЖЕН НАБРАТЬ 20 ГОРОШИН ЗА ТЕКУЩИЙ МЕСЯЦ НЕ В СОВОКУПНОСТИ,
		А ХОТЯ БЫ ПО ОДНОЙ ИЗ ДИСЦИПЛИН
*/

/* 
Формируем таблицу, содержащую: 
	* id студента,
	* дату (приведенную к началу месяца),
	* кол-во правильно решенных задач за месяц в разрезе дисциплин.
*/
WITH t AS (
	SELECT st_id
		  ,DATE_TRUNC('month', timest) AS date_to_month
		  ,SUM(correct::INT) OVER (PARTITION BY st_id, DATE_TRUNC('month', timest), subject) as ball_of_month
	  FROM default.peas
)

/* 
Отбираем студентов по следующим условиям:
	* текущий месяц - самая последняя дата, имеющаяся в нашей БД
	* кол-во правильно решенных задач за текущий месяц равное 20 по одной из дисциплин
*/
SELECT COUNT(DISTINCT st_id) as count_diligent_student
  FROM t
  WHERE date_to_month = (SELECT MAX(date_to_month) FROM t)
    AND ball_of_month = 20;
    -- AND ball_of_month >= 20;