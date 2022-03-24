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

--Select *
--From Housing.dbo.NashvilleHousing

