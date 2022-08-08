/* Nashville Housing DATA CLEANING
*/

-- Check the data

SELECT *
FROM NashvilleHousing..NHData;

-- Change date format

ALTER TABLE NashvilleHousing..NHData
ADD SaleDateConverted date;

UPDATE NashvilleHousing..NHData
SET SaleDateConverted = CONVERT(date, SaleDate);

-- Populate Property Address data

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing..NHData a
JOIN NashvilleHousing..NHData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Breaking out Property Address into individual columns (Address, City)

--SELECT
--	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
--	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City 
--FROM NashvilleHousing..NHData;

ALTER TABLE NashvilleHousing..NHData
ADD Address nvarchar(255);

UPDATE NashvilleHousing..NHData
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing..NHData
ADD City nvarchar(255);

UPDATE NashvilleHousing..NHData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

-- Breaking out Owner Address into individual columns (Address, City, State)

--SELECT
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--FROM NashvilleHousing..NHData;

ALTER TABLE NashvilleHousing..NHData
ADD Owner_Address nvarchar(255);

UPDATE NashvilleHousing..NHData
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing..NHData
ADD Owner_City nvarchar(255);

UPDATE NashvilleHousing..NHData
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing..NHData
ADD Owner_State nvarchar(255);

UPDATE NashvilleHousing..NHData
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Change Y and N to Yes and No respectively in SoldAsVacant column

--SELECT
--	SoldAsVacant,
--	CASE
--		WHEN SoldAsVacant = 'Y' THEN 'Yes'
--		WHEN SoldAsVacant = 'N' THEN 'No'
--		ELSE SoldAsVacant
--	END
--FROM NashvilleHousing..NHData


UPDATE NashvilleHousing..NHData
SET SoldAsVacant = 	CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

-- Remove Duplicates
-- Note that it's not a standard to practice to delete data that's present in the database but it will be done just to show off some queries

WITH RowNum_Dupl AS
(
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY
								ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								ORDER BY UniqueID) row_num
FROM NashvilleHousing..NHData
)

--SELECT *
--FROM RowNum_Dupl
--WHERE row_num > 1

DELETE
FROM RowNum_Dupl
WHERE row_num > 1;

-- Delete unused columns
-- Note that it's not a standard to practice to delete data that's present in the database but it will be done just to show off some queries

ALTER TABLE NashvilleHousing..NHData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
