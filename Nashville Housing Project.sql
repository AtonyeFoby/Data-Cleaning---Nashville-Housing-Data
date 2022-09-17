-- Cleaning Data in SQL

-- Changing SaleDate from datetime format to just date
-- add a new column called SaleDateConverted

ALTER TABLE Nashville
Add SaleDateConverted Date;

-- populate the table by converting the SaleDate column from datetime to date
UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.Nashville

-- Populate the nulls in the Property Address with the right address

-- do a self join and replace all the null alues in the a with the corresponding values in b 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville a
JOIN PortfolioProject.dbo.Nashville b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

SELECT *
FROM PortfolioProject.dbo.Nashville 

-- Extracting the city and state from the address column and giving them their individual columns

-- first the PropertyAddress column

SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashville 

-- use substring to split the string by the delimiter
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.Nashville 

-- add a new column
ALTER TABLE Nashville
Add PropertySplitAddress nvarchar(255);

-- populate it with the split address
UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--add a new column
ALTER TABLE Nashville
Add City nvarchar(255);

-- populate it with the city split from the property address
UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- verify these changes
SELECT *
FROM PortfolioProject.dbo.Nashville

-- NOW also splitting the OwnerAddress column

SELECT OwnerAddress
FROM PortfolioProject.dbo.Nashville

-- replace the delimeter , with . so we can use parsename to split the owner address into 3
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.Nashville


-- add a new column 
ALTER TABLE Nashville
Add OwnerSplitAddress nvarchar(255);

-- populated it with the splot owner address
UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--add a new column
ALTER TABLE Nashville
Add OwnerCity nvarchar(255);

--populate it with the owner's city extracted from owner address
UPDATE Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


-- add a new column
ALTER TABLE Nashville
Add OwnerState nvarchar(255);

--populate it with the owner's state extracted from owner address
UPDATE Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- confirm these changes
SELECT *
FROM PortfolioProject.dbo.Nashville

-- Change Y and N to Yes an No in SoldasVacant

-- Check for the distinct entries in the SoldAsVacant column
SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashville

-- use a case statement to change y to yes and n to no
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM PortfolioProject.dbo.Nashville

--  update the SoldAsVacant column with the case statement
UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END


-- confirm the changes were executed
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashville
GROUP BY SoldAsVacant
ORDER BY 2 



-- Remove Duplicates in the data set
-- use row_number to identify duplicate records
-- use a CTE (Common Table Expression) to perform the delete function on the created row_num column
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM PortfolioProject.dbo.Nashville
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- confirm that the duplicates were deleted
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM PortfolioProject.dbo.Nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- delete columns not used

ALTER TABLE PortfolioProject.dbo.Nashville
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject.dbo.Nashville