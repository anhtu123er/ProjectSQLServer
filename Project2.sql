Use Sakila
GO

-- Cau 1
SELECT M1.title TEN_PHIM, M5.name TYPEFILM , COUNT(M4.rental_id) SO_LAN_THUE
FROM dbo.film M1
LEFT JOIN dbo.film_category M2
ON M1.film_id = M2.film_id
LEFT JOIN dbo.inventory M3
ON M1.film_id = M3.film_id
LEFT JOIN dbo.rental M4
ON M3.inventory_id = M4.inventory_id
LEFT JOIN dbo.category M5
ON M2.category_id = M5.category_id
WHERE M5.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY M1.title, M5.name
ORDER BY M5.name, M1.title
GO

-- Cau 2
WITH CTE AS (SELECT M1.title TEN_PHIM, M3.name TYPEFILM, SUM(DATEDIFF(DAY, M5.rental_date, M5.return_date)) SO_NGAY
FROM dbo.film M1
JOIN dbo.film_category M2
ON M1.film_id = M2.film_id
JOIN dbo.category M3
ON M2.category_id = M3.category_id
JOIN dbo.inventory M4
ON M1.film_id = M4.film_id
JOIN dbo.rental M5
ON M4.inventory_id = M5.inventory_id
GROUP BY M1.title, M3.name)

SELECT(SELECT SUM(SO_NGAY) FROM CTE WHERE CTE.TYPEFILM IN('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))*100/(SELECT SUM(SO_NGAY) FROM CTE) AS N'Phần trăm'
-- Câu 3:
SELECT M1.name, COUNT(m4.rental_id) SO_LAN_THUE, SUM(DATEDIFF(DAY, M4.rental_date, M4.return_date)) THOI_GIAN_THUE
FROM dbo.category M1
LEFT JOIN dbo.film_category M2
ON M1.category_id = M2.category_id
LEFT JOIN dbo.inventory M3
ON M2.film_id = M3.film_id
LEFT JOIN dbo.rental M4
ON M3.inventory_id = M4.inventory_id
GROUP BY M1.name
ORDER BY M1.name
GO

-- Cau 4
WITH CTE AS (SELECT M1.customer_id, M1.first_name +' '+ M1.last_name full_name, SUM(DATEDIFF(DAY, M3.rental_date, M3.return_date)) THOI_GIAN_THUE
FROM dbo.customer M1
LEFT JOIN dbo.payment M2
ON M1.customer_id = M2.customer_id
LEFT JOIN dbo.rental M3
ON M2.rental_id = M3.rental_id
GROUP BY M1.customer_id, M1.first_name +' '+ M1.last_name)

SELECT T1.full_name, YEAR(T2.payment_date) Nam, MONTH(T2.payment_date) Thang,T1.THOI_GIAN_THUE, SUM(T2.amount) TONG_CHI_TIEU
FROM CTE T1
LEFT JOIN dbo.payment T2
ON T1.customer_id = T2.customer_id
WHERE YEAR(T2.payment_date) = 2007
GROUP BY T1.full_name, YEAR(T2.payment_date) , MONTH(T2.payment_date),T1.THOI_GIAN_THUE
ORDER BY SUM(T2.amount) DESC
GO
--- CACH 2: LAM MENH DE SO 2
SELECT M1.customer_id, M1.first_name +' '+ M1.last_name, YEAR(M2.payment_date) Nam, MONTH(M2.payment_date) Thang, SUM(M2.amount) TONG_CHI_TIEU
FROM dbo.customer M1
LEFT JOIN dbo.payment M2
ON M1.customer_id = M2.customer_id
WHERE YEAR(M2.payment_date) = 2007
GROUP BY M1.customer_id, YEAR(M2.payment_date), MONTH(M2.payment_date), M1.first_name +' '+ M1.last_name 
ORDER BY SUM(M2.amount) DESC
GO
--Cau 5:
SELECT M1.first_name +' '+ M1.last_name N'Tên khách hàng', M7.phone N'Số điện thoại liên hệ', M5.title N'Tên phim', M3.rental_date N'Ngày thuê'
FROM dbo.customer M1
LEFT JOIN dbo.payment M2
ON M1.customer_id = M2.customer_id
LEFT JOIN dbo.rental M3
ON M2.rental_id = M3.rental_id
LEFT JOIN dbo.inventory M4
ON M3.inventory_id = M4.inventory_id
LEFT JOIN dbo.film M5
ON M4.film_id = M5.film_id
LEFT JOIN dbo.store M6
ON M1.store_id = M6.store_id
LEFT JOIN dbo.address M7
ON M6.address_id = M7.address_id
WHERE M3.return_date IS NULL
ORDER BY M1.first_name +' '+ M1.last_name
GO

--Cau 6:
SELECT COUNT(M1.rental_id) AS N'Số lần thuê', 
CASE
WHEN DATEDIFF(DAY,M1.rental_date,M1.return_date) < M3.rental_duration THEN 'EARLY'
WHEN DATEDIFF(DAY,M1.rental_date,M1.return_date) = M3.rental_duration THEN 'ONTIME'
ELSE 'LATE'
END AS N'Thể loại trả'
FROM dbo.rental M1
LEFT JOIN dbo.inventory M2
ON M1.inventory_id = M2.inventory_id
LEFT JOIN dbo.film M3
ON M2.film_id = M3.film_id
GROUP BY CASE
WHEN DATEDIFF(DAY,M1.rental_date,M1.return_date) < M3.rental_duration THEN 'EARLY'
WHEN DATEDIFF(DAY,M1.rental_date,M1.return_date) = M3.rental_duration THEN 'ONTIME'
ELSE 'LATE'
END
GO


-- Cau 7:
SELECT T1.country, COUNT(DISTINCT T4.customer_id) SO_KH, COUNT(DISTINCT T6.rental_id) SO_LAN_THUE, SUM(T5.amount) SO_TIEN_THU_DUOC
FROM dbo.country T1
LEFT JOIN dbo.city T2
ON T1.country_id = T2.country_id
LEFT JOIN dbo.address T3
ON T2.city_id = T3.city_id
LEFT JOIN dbo.customer T4
ON T3.address_id = T4.address_id
LEFT JOIN dbo.payment T5
ON T4.customer_id = T5.customer_id
LEFT JOIN dbo.rental T6
ON T5.rental_id = T6.rental_id
GROUP BY T1.country
ORDER BY SUM(T5.amount) DESC
GO


-- CAU 8
SELECT M3.rating THEO_MPAA, M1.name N'Thể loại phim', AVG(M3.rental_rate) N'Mức đánh giá trung bình'
FROM dbo.category M1
LEFT JOIN dbo.film_category M2
ON M1.category_id = M2.category_id
LEFT JOIN dbo.film M3
ON M2.film_id = M3.film_id
GROUP BY M3.rating, M1.name
ORDER BY M3.rating
GO