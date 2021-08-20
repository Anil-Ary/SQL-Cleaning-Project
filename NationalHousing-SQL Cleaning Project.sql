/*

Cleaning Data in SQl Queries

*/

Select *
From [sql-PortfolioProject]..NationalHousing

----------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleConvertedDate,Convert(Date,SaleDate)
From [sql-PortfolioProject]..NationalHousing

Update NationalHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NationalHousing
ADD SaleConvertedDate Date;

Update NationalHousing
SET SaleConvertedDate = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From [sql-PortfolioProject]..NationalHousing
--WHERE PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From [sql-PortfolioProject]..NationalHousing a
JOIN [sql-PortfolioProject]..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [sql-PortfolioProject]..NationalHousing a
JOIN [sql-PortfolioProject]..NationalHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------

-- Breaking Address into Individual Columns (Address,State,City) Using SUBSTRING

Select PropertyAddress
From [sql-PortfolioProject]..NationalHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) As Address
From [sql-PortfolioProject]..NationalHousing

ALTER TABLE NationalHousing
ADD PropertySplitAddress Nvarchar(255);

Update NationalHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NationalHousing
ADD PropertySplitCity Nvarchar(255);

Update NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NationalHousing
ADD PropertySplitCity Nvarchar(255);

Update NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NationalHousing
ADD PropertySplitCity Nvarchar(255);

Update NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



--------------------------------------------------------------------------------------------------------------------------------------

-- Breaking Owner Address Using PARSENAME

SELECT OwnerAddress
FROM [sql-PortfolioProject]..NationalHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) ,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [sql-PortfolioProject]..NationalHousing



ALTER TABLE NationalHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NationalHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NationalHousing
ADD OwnerSplitCity Nvarchar(255);

Update NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NationalHousing
ADD OwnerSplitState Nvarchar(255);

Update NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [sql-PortfolioProject]..NationalHousing

-----------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO "SoldasVacant" feild Using CASE Statement

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From [sql-PortfolioProject]..NationalHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'YES'
	     When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant 
	END
FROM [sql-PortfolioProject]..NationalHousing


UPDATE NationalHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	     When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant 
	END

SELECT *
FROM [sql-PortfolioProject]..NationalHousing


------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates Using CTE and WINDOWS Function

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [sql-PortfolioProject]..NationalHousing
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

SELECT *
FROM [sql-PortfolioProject]..NationalHousing

ALTER TABLE [sql-PortfolioProject]..NationalHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [sql-PortfolioProject]..NationalHousing
DROP COLUMN SaleDate

