SELECT *
FROM PortfolioProjects..HAICleaned


-- Filter for only Lower and Upper Confidence Limit
SELECT *
FROM PortfolioProjects..HAICleaned
WHERE MeasureID LIKE '%LOWER'
OR MeasureID LIKE '%UPPER'

-- Convert NULL values into 0
SELECT ISNULL(Score, 0)
FROM PortfolioProjects..HAICleaned
WHERE MeasureID LIKE '%LOWER'
OR MeasureID LIKE '%UPPER'

-- Retrieve Only Miami Information
SELECT *
FROM PortfolioProjects..HAICleaned
WHERE City = 'MIAMI'

--Retrieve Only For Miami-Dade
SELECT *
FROM PortfolioProjects..HAICleaned
WHERE CountyName = 'MIAMI-DADE'

--Retrieve Only For Los Angeles
SELECT *
FROM PortfolioProjects..HAICleaned
WHERE CountyName = 'Los Angeles'


-- Retrieve the Predicted Cases to Calculate Observed/Predicted

SELECT *
FROM PortfolioProjects..HAICleaned
WHERE MeasureName LIKE '%Predicted%'


--Convert NULL values into 0 for Predicted Cases

SELECT ISNULL(Score, 0)
FROM PortfolioProjects..HAICleaned
WHERE MeasureName LIKE '%Predicted%'

-- Join Cases and Predicted 
SELECT ca.FacilityID, ca.MeasureName, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID=pc.MeasureID


---- For Central Line 
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_1%'
AND pc.MeasureID LIKE 'HAI_1%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_1%'
AND pc.MeasureID LIKE 'HAI_1%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_1%'
AND pc.MeasureID LIKE 'HAI_1%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1

---- For Catheter Associated Infections
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_2%'
AND pc.MeasureID LIKE 'HAI_2%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_2%'
AND pc.MeasureID LIKE 'HAI_2%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_2%'
AND pc.MeasureID LIKE 'HAI_2%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1

---- For SSI-Colon Surgery
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_3%'
AND pc.MeasureID LIKE 'HAI_3%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_3%'
AND pc.MeasureID LIKE 'HAI_3%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1


SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_3%'
AND pc.MeasureID LIKE 'HAI_3%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1


---- For SSI-Abdominal Hysterectomy
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_4%'
AND pc.MeasureID LIKE 'HAI_4%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_4%'
AND pc.MeasureID LIKE 'HAI_4%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_4%'
AND pc.MeasureID LIKE 'HAI_4%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1

---- For MRSA Bacteremia
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_5%'
AND pc.MeasureID LIKE 'HAI_5%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_5%'
AND pc.MeasureID LIKE 'HAI_5%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_5%'
AND pc.MeasureID LIKE 'HAI_5%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1

---- For Clostridium Difficle 
SELECT ca.FacilityID, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_6%'
AND pc.MeasureID LIKE 'HAI_6%'

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_6%'
AND pc.MeasureID LIKE 'HAI_6%'
AND ca.CountyName = 'MIAMI-DADE'
ORDER BY 1

SELECT ca.FacilityID,ca.FacilityName, ca.MeasureName,ca.MeasureID,pc.MeasureID,pc.Score, (ca.score/pc.Score)*100 as 'Observed/PredictedScore'
FROM PortfolioProjects..Cases ca
INNER JOIN PortfolioProjects..PredictedCases pc 
ON ca.FacilityID = pc.FacilityID
WHERE pc.Score != 0
AND ca.MeasureName LIKE '%Observed%'
AND ca.MeasureID LIKE 'HAI_6%'
AND pc.MeasureID LIKE 'HAI_6%'
AND ca.CountyName = 'Los Angeles'
ORDER BY 1

--Average Per Different Cases Miami-Dade

SELECT MeasureName ,AVG(Score) as 'AverageScore'
FROM PortfolioProjects..Cases
WHERE CountyName = 'MIAMI-DADE'
GROUP BY MeasureName
ORDER By 1

--Average Per Different Cases Los Angeles

SELECT MeasureName ,AVG(Score) as 'AverageScore'
FROM PortfolioProjects..Cases
WHERE CountyName = 'Los Angeles'
GROUP BY MeasureName
ORDER BY 1

--Insert Score for the Different Values

---- Facility Observed Cases Surpassed It's Upper Confidence Limit
SELECT
FROM PortfolioProjects..Cases
WHERE 



--CTE


SELECT *
FROM PortfolioProjects..HAICleaned
GROUP BY FacilityID


SELECT *
FROM PortfolioProjects..HAICleaned
WHERE MeasureID LIKE '%DOPC'
OR MeasureID LIKE '%CASES'
OR MeasureID LIKE '%RATOR'


SELECT ISNULL(Score,0)
FROM PortfolioProjects..HAICleaned
WHERE MeasureID LIKE '%DOPC'
OR MeasureID LIKE '%CASES'
OR MeasureID LIKE '%RATOR'

SELECT *
FROM PortfolioProjects..Cases
