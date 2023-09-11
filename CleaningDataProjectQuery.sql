/*
Cleaning Data
*/

select * 
from [Nashville Housing Data ]
-----------------------------------------------

--Standardize Date Format

select SaleDate, CONVERT(Date,SaleDate)
from [Nashville Housing Data ]

Update Nashville Housing Data
SET SaleDate = CONVERT(Date,SaleDate)


-----------------------------------------------

-- Populate Property Address Data

select *
from [Nashville Housing Data ]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data ] a
join [Nashville Housing Data ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data ] a
join [Nashville Housing Data ] b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-----------------------------------------------

--Breaking Out Address into Individual Columns (Address, City)

select PropertyAddress
from [Nashville Housing Data ]

select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress) ) as City
from [Nashville Housing Data ]


Alter Table [Nashville Housing Data ]
Add PropertySplitAddress varchar(50);

update [Nashville Housing Data ]
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) - 1)


Alter Table [Nashville Housing Data ]
Add PropertySplitCity varchar(50);

update [Nashville Housing Data ]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress) )

-----------------------------------------------

-- Split Owner Address

select OwnerAddress
from [Nashville Housing Data ]

select PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
from [Nashville Housing Data ]

Alter Table [Nashville Housing Data ]
Add OwnerSplitAddress varchar(50);

update [Nashville Housing Data ]
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table [Nashville Housing Data ]
Add OwnerSplitCity varchar(50);

update [Nashville Housing Data ]
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table [Nashville Housing Data ]
Add OwnerSplitState varchar(50);

update [Nashville Housing Data ]
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from [Nashville Housing Data ]


-----------------------------------------------
--Change 1 and 0 to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing Data ]
group by SoldAsVacant

select SoldAsVacant, 
Case When SoldAsVacant = 0 Then 'No'
	 When SoldAsVacant = 1 Then 'Yes'
End
from [Nashville Housing Data ]

-- Because "Sold as Vacant" is a bit data type i needed a new column
Alter Table [Nashville Housing Data ]
Add Sold_As_Vacant varchar(50);

update [Nashville Housing Data ]
SET Sold_As_Vacant = 
	Case When SoldAsVacant = 0 Then 'No'
		When SoldAsVacant = 1 Then 'Yes'
	End

select SoldAsVacant, Sold_As_Vacant 
from [Nashville Housing Data ]

-- code to get rid of original SoldAsVacant.
alter table [Nashville Housing Data ]
drop column SoldAsVacant


-----------------------------------------------

--remove Duplicates

with RowNumCTE as(

select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
				UniqueID) row_num

from [Nashville Housing Data ] 
)
--select *
Delete
From RowNumCTE
where row_num > 1 
 


-----------------------------------------------
--Delete Unused Columns

select*
from [Nashville Housing Data ] 


Alter Table [Nashville Housing Data ]
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


