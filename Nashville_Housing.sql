Select * from `NashvilleHouseDataset.Nashville_Data`;

-- Adding new column to table that provides correct format for SaleDate column

ALTER Table `NashvilleHouseDataset.Nashville_Data`Add Column New_SaleDate Date;

Update `NashvilleHouseDataset.Nashville_Data`
Set New_SaleDate = PARSE_DATE('%B %d, %Y', SaleDate)
Where SaleDate is not null;

Select * from `NashvilleHouseDataset.Nashville_Data`;

-- Let's check the null values in table

Select * from `NashvilleHouseDataset.Nashville_Data`
--Where PropertyAddress is null;
Order By ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) As New_Address
from `NashvilleHouseDataset.Nashville_Data` a
Join `NashvilleHouseDataset.Nashville_Data` b on a.ParcelID = b.ParcelID And a.UniqueID != b.UniqueID
Where a.PropertyAddress is null; 

-- Now we will try to update the null values with the above addresss

Update `NashvilleHouseDataset.Nashville_Data`
SET propertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
from `NashvilleHouseDataset.Nashville_Data` a
Join `NashvilleHouseDataset.Nashville_Data` b on a.ParcelID = b.ParcelID And a.UniqueID != b.UniqueID
Where a.PropertyAddress is null;

----------------------------------------------------------
MERGE `NashvilleHouseDataset.Nashville_Data` AS target
USING (
  SELECT DISTINCT a.UniqueID, b.PropertyAddress
  FROM `NashvilleHouseDataset.Nashville_Data` a
  JOIN `NashvilleHouseDataset.Nashville_Data` b 
  ON a.ParcelID = b.ParcelID 
  AND a.UniqueID != b.UniqueID
  WHERE a.PropertyAddress IS NULL
  LIMIT 1  -- Ensures at most one match per row
) AS source
ON target.UniqueID = source.UniqueID
WHEN MATCHED THEN
UPDATE SET target.PropertyAddress = source.PropertyAddress;


select * from `NashvilleHouseDataset.Nashville_Data`
Where PropertyAddress is null;
---------------------------------------------------------------- We are waiting on updating the null values of the Property address.

Alter Table `NashvilleHouseDataset.Nashville_Data`
Drop column Coma_Seperated_Address;

Alter Table `NashvilleHouseDataset.Nashville_Data` Drop Column if exists New_Property_Address;
Alter Table `NashvilleHouseDataset.Nashville_Data` Add Column New_Property_Address STRING;

UPDATE `NashvilleHouseDataset.Nashville_Data` a
SET a.New_Property_Address = (
  SELECT b.PropertyAddress
  FROM `NashvilleHouseDataset.Nashville_Data` b
  WHERE a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
    AND b.PropertyAddress IS NOT NULL
  LIMIT 1  -- Ensures only one value is returned
)
WHERE a.PropertyAddress IS NULL;
---------------------------------------------------------------------- BigQuery is not supporting Updating the table directly. Let's dive into next one.

---- Now let's try a new way: As Bigquery isn't supporting updateing the table directly, I will create a new table and directly add columns by performing necessary requirements/ cleaning.



-- Step 1: Create a new table with cleaned structure
CREATE OR REPLACE TABLE `NashvilleHouseDataset.Nashville_Data` AS
SELECT
    -- UniqueID: Standardizing to 10-digit by padding with zeros
    LPAD(CAST(UniqueID AS STRING), 10, '0') AS UniqueID,
    
    -- ParcelID: Removing '.00' from ParcelID
    CAST(REGEXP_REPLACE(ParcelID, r'[^0-9]', '') AS INT64) AS ParcelID,

    -- Property Address: Splitting into two columns (Address, City)
    SPLIT(PropertyAddress, ',')[OFFSET(0)] AS Property_Street,
    SPLIT(PropertyAddress, ',')[SAFE_OFFSET(1)] AS Property_City,

    -- Sale Date: Standardizing date format to YYYY-MM-DD
    PARSE_DATE('%B %d, %Y', SaleDate) AS Sale_Date,

    -- Sale Price: Formatting with '.00' and adding currency ($)
    ---FORMAT('$%,.2f', SalePrice) AS Sale_Price,
    CONCAT('$', FORMAT('%2f', Cast(SalePrice As Float64))) AS Sale_Price,

    -- SoldAsVacant: Converting 'True' to 'YES' and 'False' to 'NO'
    CASE 
        WHEN SoldAsVacant THEN 'YES'  -- If TRUE, return 'YES'
        ELSE 'NO'                     -- If FALSE, return 'NO'
    END AS Sold_As_Vacant,

    -- Owner Address: Splitting into three columns (Street, City, State)
    SPLIT(OwnerAddress, ',')[OFFSET(0)] AS Owner_Street,
    SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)] AS Owner_City,
    SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)] AS Owner_State,

    -- Land Value, Building Value, Total Value: Formatting with '.00' and currency
    Concat('$', FORMAT('%2f', cast(LandValue As Float64))) AS Land_Value,
    Concat('$', FORMAT('%2f', Cast(BuildingValue As Float64))) AS Building_Value,
    concat('$', FORMAT('%2f', Cast(TotalValue As Float64))) AS Total_Value,

    -- Keeping Acreage column unchanged
    Acreage

FROM `NashvilleHouseDataset.Nashville_Data`;

--- Now I have successfully replaced the whole table with nely calculated columns based on the changes required.

Select * From `NashvilleHouseDataset.Nashville_Data`;

-- Project 3 Completed.....




-------------------------