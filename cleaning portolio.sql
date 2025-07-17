 -- Cleaning data in SQL
SELECT *
FROM   housing_data

--Formatting the SaleDate
SELECT saledate,
       CONVERT(DATE, saledate)
FROM   housing_data

UPDATE housing_data
SET    saledate = CONVERT(DATE, saledate)

ALTER TABLE housing_data
  ADD date_new DATE

UPDATE housing_data
SET    date_new = CONVERT(DATE, saledate)

--Populate Missing PropertyAddress Data
SELECT a.parcelid,
       a.propertyaddress,
       b.parcelid,
       b.propertyaddress,
       Isnull (a.propertyaddress, b.propertyaddress)
FROM   housing_data a
       JOIN housing_data b
         ON a.parcelid = b.parcelid
            AND a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULL

UPDATE a
SET    propertyaddress = Isnull (a.propertyaddress, b.propertyaddress)
FROM   housing_data a
       JOIN housing_data b
         ON a.parcelid = b.parcelid
            AND a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULL

-- Breaking Address into address,city,state
SELECT Substring (propertyaddress, 1, Charindex (',', propertyaddress) - 1) AS
       address,
       Substring (propertyaddress, Charindex(',', propertyaddress) + 1, Len(
       propertyaddress))                                                    AS
       address
FROM   housing_data

ALTER TABLE housing_data
  ADD streetname NVARCHAR(255)

ALTER TABLE housing_data
  ADD city NVARCHAR(255)

UPDATE housing_data
SET    streetname = Substring (propertyaddress, 1,
                    Charindex (',', propertyaddress) - 1
                           )

UPDATE housing_data
SET    city = Substring (propertyaddress, Charindex(',', propertyaddress) + 1,
              Len(
                            propertyaddress))

-- breaking owner address 
SELECT Parsename (Replace(owneraddress, ',', '.'), 3),
       Parsename (Replace(owneraddress, ',', '.'), 2),
       Parsename (Replace(owneraddress, ',', '.'), 1)
FROM   housing_data;

ALTER TABLE housing_data
  ADD ownerstreet NVARCHAR(255)

ALTER TABLE housing_data
  ADD ownercity NVARCHAR(255)

ALTER TABLE housing_data
  ADD ownerstate NVARCHAR(255)

UPDATE housing_data
SET    ownerstreet = Parsename (Replace(owneraddress, ',', '.'), 3)

UPDATE housing_data
SET    ownercity = Parsename (Replace(owneraddress, ',', '.'), 2)

UPDATE housing_data
SET    ownerstate = Parsename (Replace(owneraddress, ',', '.'), 1)

--changing y to yes and no to vacant in SoldasVacant
SELECT soldasvacant,
       CASE
         WHEN soldasvacant = 'Y' THEN 'Yes'
         WHEN soldasvacant = 'N' THEN 'No'
         ELSE soldasvacant
       END
FROM   housing_data

UPDATE housing_data
SET    soldasvacant = CASE
                        WHEN soldasvacant = 'Y' THEN 'Yes'
                        WHEN soldasvacant = 'N' THEN 'No'
                        ELSE soldasvacant
                      END

SELECT DISTINCT soldasvacant
FROM   housing_data
GROUP  BY soldasvacant;

--removing duplicates
WITH rownumcte
     AS (SELECT *,
                Row_number()
                  OVER(
                    partition BY parcelid, propertyaddress, saleprice, saledate,
                  legalreference
                    ORDER BY uniqueid) AS row_num
         FROM   housing_data)
SELECT *
FROM   rownumcte
WHERE  row_num > 1;

WITH rownumcte2
     AS (SELECT *,
                Row_number()
                  OVER(
                    partition BY parcelid, propertyaddress, saleprice, saledate,
                  legalreference
                    ORDER BY uniqueid) AS row_num
         FROM   housing_data)
DELETE FROM rownumcte2
WHERE  row_num > 1

--deleting unused column
SELECT *
FROM   housing_data

ALTER TABLE housing_data
  DROP COLUMN propertyaddress, owneraddress

ALTER TABLE housing_data
  DROP COLUMN saledate  
