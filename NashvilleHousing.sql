/*

Cleaning data in SQL queries

*/

Select *
from Housing.dbo.NashvilleHousing

------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, convert(date, SaleDate)
from Housing.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = convert(date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = convert(date,SaleDate)

Select SaleDateConverted
from Housing.dbo.NashvilleHousing

---------------------------------------------------------------------------------
--Populate Property Address data (there are null values but repeated parcel Ids with the same address)

Select *
from Housing.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.NashvilleHousing a
join Housing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.NashvilleHousing a
join Housing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------

--Breaking out Address into individual Colums (Address, City, State)

Select PropertyAddress
from Housing.dbo.NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as State
from Housing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From Housing.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------

-- Cleaning OwnerAddress Data with PARSENAME

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM Housing.dbo.NashvilleHousing


ALTER TABLE Housing.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update Housing.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Housing.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update Housing.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housing.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update Housing.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From  Housing.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From Housing.dbo.NashvilleHousing

Update  Housing.dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END


---------------------------------------------------------------------------------

-- Remove Duplicates


WITH row_num as (
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From  Housing.dbo.NashvilleHousing
)
--DELETE
Select *
From row_num
where row_num > 1

--------------------------------------------------------------------------

--Delete Unused Columns

ALTER Table Housing.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Select *
From Housing.dbo.NashvilleHousing

