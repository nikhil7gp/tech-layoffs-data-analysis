-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Dulplicates
-- 2. Standardize the Data
-- 3. Null Values OR blank values
-- 4. Remove Any Columns




CREATE TABLE layoff_staging
LIKE layoffs;


SELECT *
FROM layoff_staging;

INSERT layoff_staging
SELECT *
FROM layoffs;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoff_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoff_staging
WHERE company = 'Oda';

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoff_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2
;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`,
stage, country, funds_raised_millions) AS row_num
FROM layoff_staging;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data


SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'Crypto%';

SELECT distinct country, trim(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE  'United States%';

SELECT *
FROM layoffs_staging2
;

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Null Values OR blank values


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off is NULL; 

SELECT *
FROM layoffs_staging2
WHERE industry is NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
WHERE (t1.industry is null OR t1.industry = '')
and t2.industry is not null;

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is null 
and t2.industry is not null;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off is NULL; 

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off is NULL; 


-- Remove Any Columns


SELECT *
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;