

------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, CONVERT(date,SaleDate)
FROM [Portfolio Project]..DataClean

UPDATE DataClean
	SET SaleDate = CONVERT(date,SaleDate)
ALTER TABLE DataClean
	ADD SaleDateConverted date;
UPDATE DataClean
	SET SaleDateConverted = CONVERT(date,SaleDate)

------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..DataClean a
JOIN [Portfolio Project]..DataClean b
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..DataClean a
JOIN [Portfolio Project]..DataClean b
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City)
--First Using Substrings

SELECT PropertyAddress
FROM [Portfolio Project]..DataClean

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project]..DataClean

ALTER TABLE DataClean
	ADD PropertySplitAddress Nvarchar(255);
ALTER TABLE DataClean
	ADD PropertySplitCity Nvarchar(255);
UPDATE DataClean
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
UPDATE DataClean
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)
--Second Using PARSENAME

SELECT OwnerAddress
FROM [Portfolio Project]..DataClean

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project]..DataClean

ALTER TABLE DataClean
	ADD OwnerSplitAddress Nvarchar(255);
ALTER TABLE DataClean
	ADD OwnerSplitCity Nvarchar(255);
ALTER TABLE DataClean
	ADD OwnerSplitState Nvarchar(255);
UPDATE DataClean
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
UPDATE DataClean
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE DataClean
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

SELECT *
FROM [Portfolio Project]..DataClean

------------------------------------------------------------------------------------------------------------------------

--Change Y and N to "Yes" and "No" in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..DataClean
GROUP BY SoldAsVacant
ORDER BY 2


Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..DataClean

UPDATE DataClean
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

------------------------------------------------------------------------------------------------------------------------

--Remove Duplicate rows
--Creating a CTE to first identify the duplicated rows then using the DELETE Command to remove ONLY the duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Portfolio Project]..DataClean
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

ALTER TABLE [Portfolio Project]..DataClean
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..DataClean
DROP COLUMN SaleDate

SELECT *
FROM [Portfolio Project]..DataClean