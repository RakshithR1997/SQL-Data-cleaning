Select *
From Portfolio_Project.dbo.NashvilleHousing

--- Standardize Date Format

Select SaleDate, CONVERT(Date,saledate)
From Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project.dbo.NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter Table Portfolio_Project.dbo.NashvilleHousing
Add SaleDateConverted Date
Update Portfolio_Project.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)

--- Populate Property Address data
Select *
From Portfolio_Project.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---Breaking out Address into Individual columns (Address , City , State)

Select PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing

ALTER Table Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) -1)

ALTER Table Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))

Select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.') ,3),
PARSENAME(Replace(OwnerAddress, ',','.') ,2),
PARSENAME(Replace(OwnerAddress, ',','.') ,1)
From Portfolio_Project.dbo.NashvilleHousing


ALTER Table Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.') ,3)

ALTER Table Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.') ,2)

ALTER Table Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

Update Portfolio_Project.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.') ,1)

---Change Y and N to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsvacant = 'Y' then 'Yes'
	 When SoldAsvacant = 'N' then 'No'
	 ELSE SoldAsvacant
	 END
From Portfolio_Project.dbo.NashvilleHousing


Update Portfolio_Project.dbo.NashvilleHousing
SET SoldAsvacant = case When SoldAsvacant = 'Y' then 'Yes'
	 When SoldAsvacant = 'N' then 'No'
	 ELSE SoldAsvacant
	 END

Select 

---Remove Duplicates
with RowNumCTE As(
Select *,
	Row_Number() OVER(
	PARTITION By ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By UniqueID
					) row_num
From Portfolio_Project.dbo.NashvilleHousing
---order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1

----Delete unused Columns


ALTER Table Portfolio_Project.dbo.NashvilleHousing
Drop Column OwnerAddress , TaxDistrict, PropertyAddress

ALTER Table Portfolio_Project.dbo.NashvilleHousing
Drop Column SaleDate







