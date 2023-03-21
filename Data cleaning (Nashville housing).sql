
-- CLEANING DATA

SELECT *
FROM [Portfolio project].dbo.UsaHousing


-- STANDARDIZING DATE FORMAT (removing hours)

SELECT SaleDate , CONVERT(DATE , SaleDate)
from UsaHousing

UPDATE UsaHousing
SET SaleDate = CONVERT(DATE , SaleDate)


-- UPDATING PROPERTY ADDRESSES (NULL VALUES)

SELECT PropertyAddress
FROM [Portfolio project].dbo.UsaHousing
WHERE PropertyAddress IS NULL

SELECT PropertyAddress
FROM [Portfolio project].dbo.UsaHousing
ORDER BY ParcelID

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM [Portfolio project].dbo.UsaHousing a
JOIN [Portfolio project].dbo.UsaHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress ,b.PropertyAddress)
FROM [Portfolio project].dbo.UsaHousing a
JOIN [Portfolio project].dbo.UsaHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- BREAKING DOWN ADDRESS COLUMNS (Adding delimiters)

SELECT PropertyAddress
FROM [Portfolio project].dbo.UsaHousing

SELECT
SUBSTRING(PropertyAddress,1 , CHARINDEX(',' , PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1  , LEN (PropertyAddress))
FROM [Portfolio project].dbo.UsaHousing

ALTER TABLE [Portfolio project].dbo.UsaHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE [Portfolio project].dbo.UsaHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1 , CHARINDEX(',' , PropertyAddress)-1) 

ALTER TABLE [Portfolio project].dbo.UsaHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE [Portfolio project].dbo.UsaHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1  , LEN (PropertyAddress)) 

--UPDATING OWNER ADDRESS
SELECT OwnerAddress
FROM [Portfolio project].dbo.UsaHousing

SELECT PARSENAME(REPLACE(OwnerAddress ,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress ,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress ,',','.'), 1)
FROM [Portfolio project].dbo.UsaHousing

ALTER TABLE [Portfolio project].dbo.UsaHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [Portfolio project].dbo.UsaHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress ,',','.'), 3)

ALTER TABLE [Portfolio project].dbo.UsaHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [Portfolio project].dbo.UsaHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress ,',','.'), 2) 

ALTER TABLE [Portfolio project].dbo.UsaHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE [Portfolio project].dbo.UsaHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress ,',','.'), 1)


--UPDATING SOLD AS VACANT COLUMN

SELECT DISTINCT(SoldAsVacant)
FROM [Portfolio project].dbo.UsaHousing

SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio project].dbo.UsaHousing

UPDATE UsaHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


--REMOVING DUPLICATES


WITH RowNo_CTE as (
SELECT * ,
	ROW_NUMBER() 
	OVER(PARTITION BY ParcelID , PropertyAddress , Saleprice ,SaleDate , LegalReference
	ORDER BY UniqueID) Row_num
		
FROM [Portfolio project].dbo.UsaHousing)

DELETE 
FROM RowNo_CTE
WHERE Row_num >1



--DELETING UNFIXED COLUMNS( STANDARDIZED COLUMNS CREATED EARLIER)

ALTER TABLE [Portfolio project].dbo.UsaHousing
DROP COLUMN OwnerAddress , PropertyAddress , SaleDate















