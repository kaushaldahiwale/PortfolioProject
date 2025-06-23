-- Cleaning data in sql

Select *
from housing_data


--Formating the SaleDate

Select SaleDate, CONVERT(date,SaleDate)
from housing_data

Update housing_data
set SaleDate = CONVERT(date,SaleDate)

Alter Table housing_data
add Date_New Date

Update housing_data
set Date_New = CONVERT(date,SaleDate)

--Populate Missing PropertyAddress Data

select a.parcelID,a.propertyaddress,b.parcelId,b.propertyaddress,isnull (a.propertyaddress,b.PropertyAddress)
from housing_data a
join housing_data b
on a.parcelID = b.parcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set propertyaddress = isnull (a.propertyaddress,b.PropertyAddress)
from housing_data a
	join housing_data b
	on a.parcelID = b.parcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

-- Breaking Address into address,city,state
select 
substring (propertyaddress, 1, CHARINDEX (',',propertyaddress) -1) as address,
substring (Propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress)) as address
from housing_data

alter table housing_data
add StreetName nvarchar(255)

alter table housing_data
add City nvarchar(255)

update housing_data
set StreetName = substring (propertyaddress, 1, CHARINDEX (',',propertyaddress) -1)

update housing_data
set City = substring (Propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress))

-- breaking owner address 

select 
parsename (replace(OwnerAddress,',','.') ,3),
parsename (replace(OwnerAddress,',','.') ,2),
parsename (replace(OwnerAddress,',','.') ,1)
from housing_data;

alter table housing_data
add OwnerStreet nvarchar(255)

alter table housing_data
add OwnerCity nvarchar(255)

Alter table housing_data
add OwnerState nvarchar(255)

update housing_data
set OwnerStreet = parsename (replace(OwnerAddress,',','.') ,3)

update housing_data
set OwnerCity = parsename (replace(OwnerAddress,',','.') ,2)

update housing_data
set OwnerState = parsename (replace(OwnerAddress,',','.') ,1)


--changing y to yes and no to vacant in SoldasVacant

select SoldAsVacant, 
	case when SoldAsVacant = 'Y' then 'Yes' 
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant 
		 end
from housing_data

update housing_data
set soldasvacant = case when SoldAsVacant = 'Y' then 'Yes' 
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant 
		 end

select distinct soldasvacant
from housing_data
group by SoldAsVacant;

--removing duplicates
with RowNumCTE as (
select *, row_number() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference 
order by uniqueid) as row_num
from housing_data
)

select *
from RowNumCTE 
where row_num > 1;

with RowNumCTE2 as (
select *, row_number() over(partition by parcelid,propertyaddress,saleprice,saledate,legalreference 
order by uniqueid) as row_num
from housing_data
)
delete 
from RowNumCTE2
where row_num > 1

--deleting unused column

select *
from housing_data

alter table housing_data
drop column propertyaddress,owneraddress

alter table housing_data
drop column saledate