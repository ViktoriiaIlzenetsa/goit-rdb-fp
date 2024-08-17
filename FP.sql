-- 1. Завантажте дані:

	-- Створіть схему pandemic у базі даних за допомогою SQL-команди.
DROP SCHEMA IF EXISTS pandemic;
CREATE SCHEMA pandemic;
	-- Оберіть її як схему за замовчуванням за допомогою SQL-команди.
USE pandemic;
	-- Імпортуйте дані за допомогою Import wizard так, як ви вже робили це у темі 3.
	-- infectious_cases.csv

-- Продивіться дані, щоб бути у контексті.
SELECT * FROM infectious_cases;



-- 2. Нормалізуйте таблицю infectious_cases до 3ї нормальної форми. Збережіть у цій же схемі дві таблиці з нормалізованими даними.
DROP TABLE IF EXISTS entities;
CREATE TABLE entities (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	entity_name VARCHAR(100),
    entity_code VARCHAR(10));
    
INSERT entities (entity_name, entity_code)
SELECT DISTINCT Entity, Code FROM infectious_cases;

SELECT * FROM entities;

DROP TABLE IF EXISTS infectious_cases_norm;
CREATE TABLE infectious_cases_norm (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	Entity VARCHAR(100),
    Code VARCHAR(10),
    Year YEAR,
    Number_yaws INT,
    polio_cases INT,
    cases_guinea_worm INT,
    Number_rabies FLOAT,
    Number_malaria FLOAT,
    Number_hiv FLOAT,
    Number_tuberculosis FLOAT,
    Number_smallpox FLOAT,
    Number_cholera_cases FLOAT, 
    entity_id INT);

INSERT infectious_cases_norm (
Entity, Code, Year, Number_yaws, polio_cases, cases_guinea_worm, Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis, Number_smallpox, Number_cholera_cases, entity_id)
SELECT infectious_cases.*, entities.id 
FROM infectious_cases
LEFT JOIN entities ON infectious_cases.Entity = entities.entity_name;

ALTER TABLE infectious_cases_norm
DROP COLUMN Entity, 
DROP COLUMN Code; 
        
SELECT * FROM infectious_cases_norm;

-- 3. Проаналізуйте дані:

	-- Для кожної унікальної комбінації Entity та Code або їх id порахуйте середнє, мінімальне, максимальне значення та суму для атрибута Number_rabies.
		-- 💡 Врахуйте, що атрибут Number_rabies може містити порожні значення ‘’ — вам попередньо необхідно їх відфільтрувати.
	-- Результат відсортуйте за порахованим середнім значенням у порядку спадання.
	-- Оберіть тільки 10 рядків для виведення на екран.
    
SELECT 
	entity_id,
	AVG(Number_rabies) AS avg,
	MIN(Number_rabies) AS min,
	MAX(Number_rabies) AS max,
    SUM(Number_rabies) AS sum
FROM infectious_cases_norm
WHERE Number_rabies IS NOT NULL
GROUP BY entity_id
ORDER BY avg DESC
LIMIT 10;

-- 4. Побудуйте колонку різниці в роках.
	-- Для оригінальної або нормованої таблиці для колонки Year побудуйте з використанням вбудованих SQL-функцій:
		-- атрибут, що створює дату першого січня відповідного року,
			-- 💡 Наприклад, якщо атрибут містить значення ’1996’, то значення нового атрибута має бути ‘1996-01-01’.
		-- атрибут, що дорівнює поточній даті,
		-- атрибут, що дорівнює різниці в роках двох вищезгаданих колонок.
			-- 💡 Перераховувати всі інші атрибути, такі як Number_malaria, не потрібно.

SELECT 
	id, 
	Year, 
    MAKEDATE(Year, 1) AS first_january, 
    CURDATE() AS current_data, 
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS diff_year  
FROM infectious_cases_norm;

-- 5. Побудуйте власну функцію.
	-- Створіть і використайте функцію, що будує такий же атрибут, як і в попередньому завданні: 
	-- функція має приймати на вхід значення року, а повертати різницю в роках між поточною датою та датою, створеною з атрибута року (1996 рік → ‘1996-01-01’).
    
DROP FUNCTION IF EXISTS YearDiff;

DELIMITER //

CREATE FUNCTION YearDiff(year YEAR)
RETURNS INT 
NO SQL
BEGIN
	 RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE());
END//

DELIMITER ;

SELECT id, Year, YearDiff(Year) FROM infectious_cases_norm;

		-- 💡 Якщо ви не виконали попереднє завдання, то можете побудувати іншу функцію — функцію, що рахує кількість захворювань за певний період. 
-- Для цього треба поділити кількість захворювань на рік на певне число: 12 — для отримання середньої кількості захворювань на місяць, 4 — на квартал або 2 — на півріччя. 
-- Таким чином, функція буде приймати два параметри: кількість захворювань на рік та довільний дільник. Ви також маєте використати її — запустити на даних. 
-- Оскільки не всі рядки містять число захворювань, вам необхідно буде відсіяти ті, що не мають чисельного значення (≠ ‘’).

DROP FUNCTION IF EXISTS DividingTwoNumbers;

DELIMITER //

CREATE FUNCTION DividingTwoNumbers(divided FLOAT, divisor FLOAT)
RETURNS FLOAT 
DETERMINISTIC
NO SQL
BEGIN
	IF divisor = 0 THEN  
		RETURN NULL;
	ELSE 
		RETURN divided/divisor;
	END IF;
END//

DELIMITER ;

SELECT Year, Number_malaria, DividingTwoNumbers(Number_malaria, 12) AS number_malaria_by_month 
FROM infectious_cases_norm
WHERE Number_malaria IS NOT NULL;