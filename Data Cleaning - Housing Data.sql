

/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHoushing

-----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProject..NashvilleHoushing

ALTER TABLE NashvilleHoushing
Add SaleDateConverted date;

UPDATE NashvilleHoushing
SET SaleDateConverted = CONVERT(date, SaleDate)



-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHoushing a
JOIN PortfolioProject..NashvilleHoushing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHoushing a
JOIN PortfolioProject..NashvilleHoushing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------------------------------

-- Breakdown Address

Select PropertyAddress
From PortfolioProject..NashvilleHoushing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHoushing

ALTER TABLE NashvilleHoushing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHoushing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHoushing
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHoushing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
From PortfolioProject..NashvilleHoushing

-- Owner Address 

Select OwnerAddress 
From PortfolioProject..NashvilleHoushing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHoushing

ALTER TABLE NashvilleHoushing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHoushing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHoushing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHoushing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHoushing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHoushing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)




-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant) 
From PortfolioProject..NashvilleHoushing

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
From PortfolioProject..NashvilleHoushing

Update NashvilleHoushing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END


---- Remove Duplicates

WITH RowCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHoushing
--Order by ParcelID
)
DELETE
From RowCTE 
Where row_num > 1
--Order by [UniqueID ]


Select * 
From PortfolioProject..NashvilleHoushing


---- Delete unneccesory Columns

ALTER TABLE PortfolioProject..NashvilleHoushing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate