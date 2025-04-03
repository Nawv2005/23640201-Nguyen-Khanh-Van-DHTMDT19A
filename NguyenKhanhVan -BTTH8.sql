-- Nguyen Khanh Van DHTMDT19A - Bai 8
USE BANHANG;
GO


--1.Các product có đơn giá bán lớn hơn đơn giá bán trung bình của các product. Thông tin gồm ProductID, ProductName, Unitprice (Bên bảng Order Details). 
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
GROUP BY IDSP, TENSP, GIADONVI
HAVING GIADONVI > (SELECT AVG(GIADONVI) FROM SANPHAM);
--2. Các product có đơn giá bán lớn hơn đơn giá bán trung bình của các product có.  ProductName bắt đầu là ‘N’
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
WHERE GIADONVI > (
    SELECT AVG(GIADONVI)
    FROM SANPHAM
    WHERE TENSP LIKE 'N%'
);
--3. Cho biết những sản phẩm có tên bắt đầu bằng chữ N và đơn giá bán > đơn giá bán của sản phẩm khác 
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM s
WHERE TENSP LIKE 'N%' 
AND GIADONVI > (SELECT MAX(GIADONVI) FROM SANPHAM WHERE IDSP != s.IDSP);
--4. Danh sách các products đã có khách hàng đặt hàng (tức là ProductId có trong Order Details). Thông tin bao gồm ProductId, ProductName, Unitprice 
SELECT DISTINCT s.IDSP, s.TENSP, s.GIADONVI
FROM SANPHAM s
JOIN CT_DONHANG c ON s.IDSP = c.IDSP;
--5. Danh sách các products có đơn giá nhập lớn hơn đơn giá bán nhỏ nhất của tất cả các Products 
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
WHERE GIADONVI > (SELECT MIN(GIADONVI) FROM SANPHAM);
--6. Danh sách các hóa đơn của những Customers mà Customers ở thành phố LonDon và Madrid. 
SELECT DISTINCT o.OrderID
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.City IN ('London', 'Madrid');
--7. Danh sách các products có đơn vị tính có chữ Box và có đơn giá mua nhỏ hơn đơn giá bán trung bình của tất cả các Products. 
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
WHERE GIADONVI < (SELECT AVG(GIADONVI) FROM SANPHAM)
AND DONVITRONGKHO LIKE '%Box%';
--8. Danh sách các Products có số lượng (Quantity) bán được lớn nhất. 
SELECT TOP 1 s.IDSP, s.TENSP, SUM(c.SOLUONG) AS TONGSOLUONG
FROM CT_DONHANG c
JOIN SANPHAM s ON c.IDSP = s.IDSP
GROUP BY s.IDSP, s.TENSP
ORDER BY TONGSOLUONG DESC;
--9. Danh sách các Customer chưa từng lập hóa đơn (viết bằng ba cách: dùng NOT EXISTS, dùng  LEFT JOIN, dùng NOT IN ) 

-- Cách 1: Dùng NOT EXISTS
SELECT IDKHACHHANG, TENCONGTY
FROM KHACHHANG k
WHERE NOT EXISTS (SELECT 1 FROM DONHANG d WHERE d.IDKHACHHANG = k.IDKHACHHANG);

-- Cách 2: Dùng LEFT JOIN
SELECT k.IDKHACHHANG, k.TENCONGTY
FROM KHACHHANG k
LEFT JOIN DONHANG d ON k.IDKHACHHANG = d.IDKHACHHANG
WHERE d.IDDONHANG IS NULL;

-- Cách 3: Dùng NOT IN
SELECT IDKHACHHANG, TENCONGTY
FROM KHACHHANG
WHERE IDKHACHHANG NOT IN (SELECT IDKHACHHANG FROM DONHANG);
--10. Cho biết các sản phẩm có đơn vị tính có chứa chữ box và có đơn giá bán cao nhất. 
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
WHERE DONVITRONGKHO LIKE '%Box%'
AND GIADONVI = (SELECT MAX(GIADONVI) FROM SANPHAM WHERE DONVITRONGKHO LIKE '%Box%');
--11. Danh sách các products có đơn giá bán lớn hơn đơn giá bán trung bình của các Products có ProductId<=5.
SELECT IDSP, TENSP, GIADONVI
FROM SANPHAM
WHERE GIADONVI > (SELECT AVG(GIADONVI) FROM SANPHAM WHERE IDSP <= 5);
--12. Cho biết những sản phẩm nào có tổng số lượng bán được lớn hơn số lượng trung bình bán ra. 
SELECT s.IDSP, s.TENSP, SUM(c.SOLUONG) AS TONGSOLUONG
FROM CT_DONHANG c
JOIN SANPHAM s ON c.IDSP = s.IDSP
GROUP BY s.IDSP, s.TENSP
HAVING SUM(c.SOLUONG) > (SELECT AVG(SOLUONG) FROM CT_DONHANG);
--13. Liệt kê danh sách các khách hàng mua các hóa đơn mà các hóa đơn này chỉ mua những sản phẩm có mã >=3  
SELECT DISTINCT k.IDKHACHHANG, k.TENCONGTY
FROM KHACHHANG k
JOIN DONHANG d ON k.IDKHACHHANG = d.IDKHACHHANG
JOIN CT_DONHANG c ON d.IDDONHANG = c.IDDONHANG
WHERE c.IDSP >= 3
GROUP BY k.IDKHACHHANG, k.TENCONGTY
HAVING COUNT(DISTINCT c.IDSP) = 
    (SELECT COUNT(DISTINCT c_sub.IDSP)
     FROM CT_DONHANG c_sub
     WHERE c_sub.IDDONHANG IN (SELECT IDDONHANG FROM DONHANG WHERE IDKHACHHANG = k.IDKHACHHANG));
--14. Liệt kê các sản phẩm có trên 20 đơn hàng trong quí 3 năm 1998, thông tin gồm [ProductID], [ProductName] 
SELECT c.IDSP, s.TENSP
FROM CT_DONHANG c
JOIN DONHANG d ON c.IDDONHANG = d.IDDONHANG
JOIN SANPHAM s ON c.IDSP = s.IDSP
WHERE d.NGAYDATHANG BETWEEN '1998-07-01' AND '1998-09-30'
GROUP BY c.IDSP, s.TENSP
HAVING COUNT(c.IDDONHANG) > 20;
--15. Liệt kê danh sách các sản phẩm Producrs chưa bán được trong tháng 6 năm 1996 
SELECT s.IDSP, s.TENSP
FROM SANPHAM s
WHERE NOT EXISTS (
    SELECT 1 FROM CT_DONHANG c
    JOIN DONHANG d ON c.IDDONHANG = d.IDDONHANG
    WHERE d.NGAYDATHANG BETWEEN '1996-06-01' AND '1996-06-30' AND c.IDSP = s.IDSP
);
--16. Liệt kê danh sách các Employes không lập hóa đơn vào ngày hôm nay 
SELECT IDNHANVIEN, HO, TEN
FROM NHANVIEN
WHERE IDNHANVIEN NOT IN (
    SELECT IDNHANVIEN
    FROM DONHANG
    WHERE NGAYDATHANG = CAST(GETDATE() AS DATE)
);
--17. Liệt kê danh sách các Customers chưa mua hàng trong năm 1997
SELECT IDKHACHHANG, TENCONGTY
FROM KHACHHANG
WHERE IDKHACHHANG NOT IN (
    SELECT IDKHACHHANG
    FROM DONHANG
    WHERE YEAR(NGAYDATHANG) = 1997
);
--18. Tìm tất cả các Customers mua các sản phẩm có tên bắt đầu bằng chữ T trong tháng 7. 
SELECT DISTINCT c.IDKHACHHANG, c.TENCONGTY
FROM KHACHHANG c
JOIN DONHANG d ON c.IDKHACHHANG = d.IDKHACHHANG
JOIN CT_DONHANG cd ON d.IDDONHANG = cd.IDDONHANG
JOIN SANPHAM s ON cd.IDSP = s.IDSP
WHERE s.TENSP LIKE 'T%' AND MONTH(d.NGAYDATHANG) = 7;
--19. Danh sách các City có nhiều hơn 3 customer. 
SELECT THANHPHO, COUNT(IDKHACHHANG) AS SoLuongKhachHang
FROM KHACHHANG
GROUP BY THANHPHO
HAVING COUNT(IDKHACHHANG) > 3;
--20. Bạn hãy đưa ra câu hỏi cho 3 câu truy vấn sau và cho biết sự khác nhau của 3 câu truy vấn này: 
SELECT IDSP, TENSP, GIADONVI 
FROM SANPHAM 
WHERE GIADONVI > ALL (
    SELECT GIADONVI 
    FROM SANPHAM 
    WHERE IDNHACUNGCAP = (SELECT IDNHACUNGCAP FROM NHACUNGCAP WHERE TENNHACUNGCAP LIKE 'Nhà Cung Cấp A%')
)

SELECT IDSP, TENSP, GIADONVI 
FROM SANPHAM 
WHERE GIADONVI > ANY (
    SELECT GIADONVI 
    FROM SANPHAM 
    WHERE IDNHACUNGCAP = (SELECT IDNHACUNGCAP FROM NHACUNGCAP WHERE TENNHACUNGCAP LIKE 'Nhà Cung Cấp A%')
)
SELECT IDSP, TENSP, GIADONVI 
FROM SANPHAM 
WHERE GIADONVI = ANY (
    SELECT GIADONVI 
    FROM SANPHAM 
    WHERE IDNHACUNGCAP = (SELECT IDNHACUNGCAP FROM NHACUNGCAP WHERE TENNHACUNGCAP LIKE 'Nhà Cung Cấp A%')
)
--Câu hỏi 1: Tìm tất cả các sản phẩm có đơn giá bán lớn hơn tất cả các sản phẩm có tên bắt đầu bằng chữ "B".

--Câu hỏi 2: Tìm tất cả các sản phẩm có đơn giá bán lớn hơn ít nhất một trong số các sản phẩm có tên bắt đầu bằng chữ "B".

--Câu hỏi 3: Tìm tất cả các sản phẩm có đơn giá bán bằng ít nhất một trong số các sản phẩm có tên bắt đầu bằng chữ "B".
--ALL: Yêu cầu so sánh với tất cả các giá trị trong danh sách con. Tất cả các giá trị trong danh sách con phải thỏa mãn điều kiện so sánh với giá trị của sản phẩm.

--ANY (với >): Yêu cầu so sánh với ít nhất một giá trị trong danh sách con. Chỉ cần có một giá trị trong danh sách con thỏa mãn điều kiện so sánh.

---ANY (với =): Tương tự như trên, nhưng so sánh bằng, nghĩa là giá trị trong danh sách con có thể bằng với giá trị của sản phẩm đang xét.

--1. Kết danh sách các Customer và Employee lại với nhau.
SELECT 
    KH.IDKHACHHANG AS CodeID, 
    KH.TENCONGTY AS Name, 
    KH.DIACHI AS Address, 
    KH.QUOCGIA AS Phone
FROM 
    KHACHHANG KH

UNION

SELECT 
    CAST(NV.IDNHANVIEN AS NCHAR(5)) AS CodeID,  -- Chuyển IDNHANVIEN thành NCHAR(5)
    NV.HO + ' ' + NV.TEN AS Name, 
    NV.THANHPHO AS Address, 
    NV.THANHPHO AS Phone
FROM 
    NHANVIEN NV;

--2. Dùng lệnh SELECT…INTO tạo bảng HDKH_71997 cho biết tổng tiền khách hàng đã mua trong tháng 7 năm 1997 gổm CustomerID, CompanyName, Address, ToTal =sum(quantity*Unitprice) 
SELECT 
    DH.IDKHACHHANG, 
    KH.TENCONGTY, 
    KH.DIACHI, 
    SUM(CT.SOLUONG * CT.DONGIA) AS Total
INTO 
    HDKH_71997
FROM 
    DONHANG DH
JOIN 
    CT_DONHANG CT ON DH.IDDONHANG = CT.IDDONHANG
JOIN 
    KHACHHANG KH ON DH.IDKHACHHANG = KH.IDKHACHHANG
WHERE 
    DH.NGAYDATHANG BETWEEN '1997-07-01' AND '1997-07-31'
GROUP BY 
    DH.IDKHACHHANG, KH.TENCONGTY, KH.DIACHI;
--3. Dùng lệnh SELECT…INTO tạo bảng LuongNV cho biết tổng lương của nhân viên trong tháng 12 năm 1996 gổm EmployeeID, Name là LastName + FirstName, Address, ToTal =sum(quantity*Unitprice) 
SELECT 
    NV.IDNHANVIEN, 
    NV.HO + ' ' + NV.TEN AS Name, 
    NV.THANHPHO AS Address, 
    SUM(CT.SOLUONG * CT.DONGIA) AS Total
INTO 
    LuongNV
FROM 
    NHANVIEN NV
JOIN 
    DONHANG DH ON NV.IDNHANVIEN = DH.IDNHANVIEN
JOIN 
    CT_DONHANG CT ON DH.IDDONHANG = CT.IDDONHANG
WHERE 
    DH.NGAYDATHANG BETWEEN '1996-12-01' AND '1996-12-31'
GROUP BY 
    NV.IDNHANVIEN, NV.HO, NV.TEN, NV.THANHPHO;

--4. Liệt kê các khách hàng có đơn hàng chuyển đến các quốc gia ([ShipCountry]) là 'Germany' và 'USA' trong quý 1 năm 1998, do công ty vận chuyển (CompanyName) Speedy Express thực hiện, thông tin gồm [CustomerID], [CompanyName] (tên khách hàng), tổng tiền.
SELECT 
    DH.IDKHACHHANG AS CustomerID, 
    KH.TENCONGTY AS CompanyName, 
    KH.DIACHI AS Address, 
    SUM(CT.SOLUONG * CT.DONGIA) AS Total
FROM 
    DONHANG DH
JOIN 
    KHACHHANG KH ON DH.IDKHACHHANG = KH.IDKHACHHANG
JOIN 
    CT_DONHANG CT ON DH.IDDONHANG = CT.IDDONHANG
WHERE 
    DH.NGAYDATHANG BETWEEN '1998-01-01' AND '1998-03-31'  -- Quý 1 năm 1998
    AND KH.QUOCGIA IN ('Germany', 'USA')  -- Quốc gia là Germany hoặc USA
GROUP BY 
    DH.IDKHACHHANG, KH.TENCONGTY, KH.DIACHI;
--5
CREATE TABLE dbo.HoaDonBanHang 
( 
orderid INT NOT NULL, 
orderdate DATE NOT NULL, 
empid INT NOT NULL, 
custid VARCHAR(5) NOT NULL, 
qty INT NOT NULL, 
CONSTRAINT PK_Orders PRIMARY KEY(orderid) 
)
INSERT INTO  dbo.HoaDonBanHang(orderid, orderdate, empid, custid, qty)
VALUES (30001, '20070802', 3, 'A', 10), 
       (10001, '20071224', 2, 'A', 12), 
       (10005, '20071224', 1, 'B', 20), 
       (40001, '20080109', 2, 'A', 40), 
       (10006, '20080118', 1, 'C', 14), 
       (20001, '20080212', 2, 'B', 12), 
       (40005, '20090212', 3, 'A', 10), 
       (20002, '20090216', 1, 'C', 20), 
       (30003, '20090418', 2, 'B', 15), 
       (30004, '20070418', 3, 'C', 22), 
       (30007, '20090907', 3, 'D', 30) 
--a) Tính tổng Qty cho mỗi nhân viên. Thông tin gồm empid, custid 
SELECT empid, custid, SUM(qty) AS TotalQty
FROM dbo.HoaDonBanHang
GROUP BY empid, custid;
--b) Tạo bảng Pivot có dạng sau 
SELECT empid, [A], [B], [C], [D]
FROM (
    SELECT empid, custid, qty
    FROM dbo.HoaDonBanHang
) AS SourceTable
PIVOT (
    SUM(qty)
    FOR custid IN ([A], [B], [C], [D])
) AS PivotTable;
--c) Tạo 1 query lấy dữ liệu từ bảng dbo.HoaDonBanHang trả về số hóa đơn đã lập của nhân viên employee trong mỗi năm.
SELECT empid, YEAR(orderdate) AS OrderYear, COUNT(orderid) AS TotalOrders
FROM dbo.HoaDonBanHang
GROUP BY empid, YEAR(orderdate); 
--d) Tạo bảng pivot hiển thị số đơn đặt hàng được thực hiện bởi nhân viên có mã 164, 198, 223, 231, and 233.
SELECT *
FROM (
    SELECT empid, orderid
    FROM dbo.HoaDonBanHang
    WHERE empid IN (164, 198, 223, 231, 233) -- lọc những nhân viên có mã cụ thể
) AS SourceTable
PIVOT (
    COUNT(orderid) -- đếm số đơn hàng
    FOR empid IN ([164], [198], [223], [231], [233]) -- PIVOT theo các mã nhân viên
) AS PivotTable;
