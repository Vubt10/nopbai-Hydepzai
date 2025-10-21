use QLDA
GO


---------
---------LAB 5

--Bài 1: (3 điểm)
--Viết stored-procedure: 
--➢ In ra dòng ‘Xin chào’ + @ten
--với @ten là tham số đầu vào là tên Tiếng Việtcó dấu của bạn. Gợi ý: 
--o sử dụng UniKey để gõ Tiếng Việt ♦ 
--o chuỗi unicode phải bắt đầu bởi N (vd: N’Tiếng Việt’)  ♦  
--o dùng hàm cast (<biểuThức> as <kiểu>) để đổi thành kiểu <kiểu> của<biểuThức>.
CREATE OR ALTER PROC XinChao
    @ten NVARCHAR(50)
AS
BEGIN
    PRINT N'Xin chào ' + @ten
END
GO

-- Chạy thử:
EXEC XinChao N'Nguyễn Hữu Thịnh'
GO


--➢ Nhập vào 2 số @s1,@s2. In ra câu ‘Tổng là : @tg với @tg=@s1+@s2.
CREATE OR ALTER PROC TinhTong
    @s1 INT,
    @s2 INT
AS
BEGIN
    DECLARE @tg INT
    SET @tg = @s1 + @s2
    PRINT N'Tổng là: ' + CAST(@tg AS NVARCHAR(10))
END
GO

-- Chạy thử:
EXEC TinhTong 5, 7
GO

--➢ Nhập vào số nguyên @n. In ra tổng các số chẵn từ 1 đến @n. 
CREATE OR ALTER PROC TongChan
    @n INT
AS
BEGIN
    DECLARE @i INT = 1, @tong INT = 0
    WHILE @i <= @n
    BEGIN
        IF @i % 2 = 0
            SET @tong = @tong + @i
        SET @i = @i + 1
    END
    PRINT N'Tổng các số chẵn từ 1 đến ' + CAST(@n AS NVARCHAR(10)) + N'là: ' + CAST(@tong AS NVARCHAR(10))
END
GO

-- Chạy thử:
EXEC TongChan 10
GO

--➢ Nhập vào 2 số. In ra ước chung lớn nhất của chúng theo gợi ý dưới đây: 
--o b1. Không mất tính tổng quát giả sử a <= A  
--o b2. Nếu A chia hết cho a thì : (a,A) = a  
--ngược lại : (a,A) = (A%a,a) hoặc (a,A) = (a,A-a)  
--o b3. Lặp lại b1,b2 cho đến khi điều kiện trong b2 được thỏa

CREATE OR ALTER PROC UCLN
    @a INT,
    @b INT
AS
BEGIN
    DECLARE @TAM INT

    -- b1: đảm bảo a <= b
    IF @a > @b
    BEGIN
        SET @TAM = @a
        SET @a = @b
        SET @b = @TAM
    END

    -- b2, b3
    WHILE @a <> 0
    BEGIN
        SET @TAM = @b % @a
        SET @b = @a
        SET @a = @TAM
    END

    PRINT N'Ước chung lớn nhất là: ' + CAST(@b AS NVARCHAR(10))
END
GO

-- Chạy thử:
EXEC UCLN 18, 24
GO



--Bài 2: (3 điểm)******************************************************************** 
--Sử dụng cơ sở dữ liệu QLDA, Viết các Proc: 
--➢ Nhập vào @Manv, xuất thông tin các nhân viên theo @Manv. 
CREATE OR ALTER PROC ThongTinNhanVien
    @Manv CHAR(9)
AS
BEGIN
    SELECT * FROM NHANVIEN WHERE MANV = @Manv
END
GO

EXEC ThongTinNhanVien '001'
GO


--➢ Nhập vào @MaDa (mã đề án), cho biết số lượng nhân viên tham gia đề án đó 
CREATE OR ALTER PROC SoLuongNV_TheoDA
    @MaDa INT
AS
BEGIN
    SELECT COUNT(MA_NVIEN) AS SoLuongNV
    FROM PHANCONG
    WHERE MADA = @MaDa
END
GO

-- Chạy thử:
EXEC SoLuongNV_TheoDA 1
GO



--➢ Nhập vào @MaDa và @Ddiem_DA (địa điểm đề án),
--cho biết số lượng nhân viên tham gia đề án
--có mã đề án là @MaDa và địa điểm đề án là @Ddiem_DA 
CREATE OR ALTER PROC SoLuongNV_TheoDA_DiaDiem
    @MaDa INT,
    @Ddiem_DA NVARCHAR(30)
AS
BEGIN
    SELECT COUNT(DISTINCT PC.MA_NVIEN) AS SoLuongNV
    FROM PHANCONG PC
    JOIN DEAN DA ON PC.MADA = DA.MADA
    WHERE DA.MADA = @MaDa AND DA.DDIEM_DA = @Ddiem_DA
END
GO

-- 🧪 Chạy thử:
EXEC SoLuongNV_TheoDA_DiaDiem 1, N'Vũng Tàu'
GO


--➢ Nhập vào @Trphg (mã trưởng phòng),
--xuất thông tin các nhân viên có trưởng phòng là @Trphg
--và các nhân viên này không có thân nhân. 
CREATE OR ALTER PROC NV_KhongThanNhan
    @Trphg CHAR(9)
AS
BEGIN
    SELECT NV.*
    FROM NHANVIEN NV
    JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
    WHERE PB.TRPHG = @Trphg
      AND NV.MANV NOT IN (SELECT DISTINCT MA_NVIEN FROM THANNHAN)
END
GO

--
EXEC NV_KhongThanNhan '005'
go



--➢ Nhập vào @Manv và @Mapb,
--kiểm tra nhân viên có mã @Manv
--có thuộc phòng ban có mã @Mapb hay không 
CREATE OR ALTER PROC KiemTra_NV_PB
    @Manv CHAR(9),
    @Mapb INT
AS
BEGIN
    IF EXISTS (SELECT * FROM NHANVIEN WHERE MANV = @Manv AND PHG = @Mapb)
        PRINT N'Nhân viên thuộc phòng ban này.'
    ELSE
        PRINT N'Nhân viên KHÔNG thuộc phòng ban này.'
END
GO

--
EXEC KiemTra_NV_PB 'NV001', 4
go



--Bài 3: (3 điểm) *********************************************************************
--Sử dụng cơ sở dữ liệu QLDA, Viết các Proc 

--➢ Thêm phòng ban có tên CNTT vào csdl QLDA,
--các giá trị được thêm vào dưới dạng tham số đầu vào,
--kiếm tra nếu trùng Maphg thì thông báo thêm thất bại. 
CREATE OR ALTER PROC SP_ThemPhongBan
    @Maphg INT,
    @Tenphg NVARCHAR(30),
    @Trphg CHAR(9),
    @Ng_Nhanchuc DATE
AS
BEGIN
    IF EXISTS (SELECT * FROM PHONGBAN WHERE MAPHG = @Maphg)
        PRINT N'Thêm thất bại: Mã phòng ban đã tồn tại.'
    ELSE
    BEGIN
        INSERT INTO PHONGBAN(MAPHG, TENPHG, TRPHG, NG_NHANCHUC)
        VALUES(@Maphg, @Tenphg, @Trphg, @Ng_Nhanchuc)
        PRINT N'Thêm thành công phòng ban ' + @Tenphg
    END
END
GO

-- 🧪 Chạy thử:
EXEC SP_ThemPhongBan 6, N'CNTT', '001', '2022-05-01'
GO



--➢ Cập nhật phòng ban có tên CNTT thành phòng IT.
    CREATE OR ALTER PROC CapNhatTenPhong
    AS
    BEGIN
        UPDATE PHONGBAN
        SET TENPHG = N'IT'
        WHERE TENPHG = N'CNTT'

        IF @@ROWCOUNT > 0
            PRINT N'Cập nhật thành công: CNTT → IT.'
        ELSE
            PRINT N'Không tìm thấy phòng ban CNTT để cập nhật.'
    END
    GO

-- 🧪 Chạy thử:
EXEC CapNhatTenPhong
GO




--➢ Thêm một nhân viên vào bảng NhanVien, 
--tất cả giá trị đều truyền dưới dạng tham số đầu vào với điều kiện: 
--o  nhân viên này trực thuộc phòng IT 
--o Nhận @luong làm tham số đầu vào cho cột Luong, 
--nếu @luong<25000 thì nhân viên này do nhân viên có mã 009 quản lý, 
--ngươc lại do nhân viên có mã 005 quản lý 
--o Nếu là nhân viên nam thi nhân viên phải nằm trong độ tuổi 18-65,
--nếu là nhân viên nữ thì độ tuổi phải từ 18-60.
CREATE OR ALTER PROC SP_ThemNhanVien
    @Manv CHAR(9),
    @Honv NVARCHAR(15),
    @Tenlot NVARCHAR(15),
    @Tennv NVARCHAR(15),
    @NgSinh DATE,
    @Diachi NVARCHAR(30),
    @Phai NVARCHAR(3),
    @Luong FLOAT,
    @Phg INT
AS
BEGIN
    DECLARE @Tuoi INT, @NVQL CHAR(9)

    -- Tính tuổi
    SET @Tuoi = YEAR(GETDATE()) - YEAR(@NgSinh)

    -- Kiểm tra điều kiện tuổi theo giới tính
    IF (@Phai = N'Nam' AND (@Tuoi < 18 OR @Tuoi > 65))
    BEGIN
        PRINT N'Lỗi: Tuổi nhân viên nam phải trong khoảng 18–65.'
        RETURN
    END

    IF (@Phai = N'Nữ' AND (@Tuoi < 18 OR @Tuoi > 60))
    BEGIN
        PRINT N'Lỗi: Tuổi nhân viên nữ phải trong khoảng 18–60.'
        RETURN
    END

    -- Xác định mã nhân viên quản lý
    IF @Luong < 25000
        SET @NVQL = '009'
    ELSE
        SET @NVQL = '005'

    -- Lấy mã phòng ban IT
    DECLARE @MaPHG_IT INT
    SELECT @MaPHG_IT = MAPHG FROM PHONGBAN WHERE TENPHG = N'IT'

    IF @MaPHG_IT IS NULL
    BEGIN
        PRINT N'Lỗi: Không tồn tại phòng ban IT.'
        RETURN
    END

    -- Thêm nhân viên
    INSERT INTO NHANVIEN(MANV, HONV, TENLOT, TENNV, NGSINH, DCHI, PHAI, LUONG, MA_NQL, PHG)
    VALUES(@Manv, @Honv, @Tenlot, @Tennv, @NgSinh, @Diachi, @Phai, @Luong, @NVQL, @MaPHG_IT)

    PRINT N'Thêm nhân viên thành công vào phòng IT.'
END
GO

-- 🧪 Chạy thử:
EXEC SP_ThemNhanVien
    @Manv = 'NV999',
    @Honv = N'Nguyễn',
    @Tenlot = N'Hữu',
    @Tennv = N'Thịnh',
    @NgSinh = '1999-10-10',
    @Diachi = N'Hà Nội',
    @Phai = N'Nam',
    @Luong = 23000,
    @Phg = 6  -- Phòng IT
