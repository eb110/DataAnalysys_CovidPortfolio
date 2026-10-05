--Nashville Housing

select *
from PortfolioProject..NashvilleHousing

--standarize data format

select SaleDate, SaleDateConverted
from PortfolioProject..NashvilleHousing

--it does not work for every occasion - this is why new column has been created
update PortfolioProject..NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

--populate property address data
--for some records property address is null
--there are records where the same parcellId has got address and null values
--the solution is to combine them - grab the address from records and put them into records with null values

select pa1.UniqueID, pa1.ParcelID, pa1.PropertyAddress, pa2.PropertyAddress, 
isnull(pa2.PropertyAddress, pa1.PropertyAddress) as updatedAddress
from PortfolioProject..NashvilleHousing as pa1
join PortfolioProject..NashvilleHousing as pa2
on pa1.ParcelID = pa2.ParcelID 
--and pa1.PropertyAddress <> pa2.PropertyAddress
where pa1.PropertyAddress is not null and pa2.PropertyAddress is null

update pa2
set PropertyAddress = isnull(pa2.PropertyAddress, pa1.PropertyAddress)
from PortfolioProject..NashvilleHousing as pa1
join PortfolioProject..NashvilleHousing as pa2
on pa1.ParcelID = pa2.ParcelID 
where pa1.PropertyAddress is not null and pa2.PropertyAddress is null

select PropertyAddress 
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--breaking out address into individual columns (address, city, state)
--the property address ALWAYS delimiters address and city -> by usage of ',' -> coma

select PropertyAddress, 
substring(trim(PropertyAddress), 1, charindex(',', PropertyAddress) - 1) as address,
substring(trim(PropertyAddress), charindex(',', PropertyAddress) + 1, len(trim(PropertyAddress))) as state
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress varchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(trim(PropertyAddress), 1, charindex(',', PropertyAddress) - 1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity varchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(trim(PropertyAddress), charindex(',', PropertyAddress) + 1, len(trim(PropertyAddress)))

select PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing


-- owner address consists null values
-- the task is to split no null values to address, city and state

select OwnerAddress, 
parsename(replace(trim(OwnerAddress), ',', '.'), 1) as OwnerSplitState,
parsename(replace(trim(OwnerAddress), ',', '.'), 2) as OwnerSplitCity,
parsename(replace(trim(OwnerAddress), ',', '.'), 3) as OwnerSplitAddress
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState varchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(trim(OwnerAddress), ',', '.'), 1)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity varchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(trim(OwnerAddress), ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress varchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(trim(OwnerAddress), ',', '.'), 3)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject..NashvilleHousing

-- change y and n to Yes and No in 'sold as vacant' field

select distinct(SoldAsVacant)
from PortfolioProject..NashvilleHousing

select
distinct(
case 
	 when SoldAsVacant = 'N' then 'No'
	 when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
end) as NewSoldAsVacant
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = 
case 
	 when SoldAsVacant = 'N' then 'No'
	 when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
end

-- remove duplicates


select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,
ROW_NUMBER() over (
partition by ParcelID, trim(PropertyAddress), SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
from PortfolioProject..NashvilleHousing
order by row_num desc


with RowNumCTE as(
select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference,
ROW_NUMBER() over (
partition by ParcelID, trim(PropertyAddress), SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num
from PortfolioProject..NashvilleHousing
)
--delete 
--from RowNumCTE
--where row_num > 1
select * from RowNumCTE
where row_num > 1

--delete unused columns

alter table PortfolioProject..NashvilleHousing
drop column SaleDate

select * from PortfolioProject..NashvilleHousing