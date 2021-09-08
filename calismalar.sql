
--Query

--Adý Nancy olan personelin yaptýðý satýþlar ve tarihleri(Sorgu1)
Select s.SatisID,s.SatisTarihi from Personeller p 
inner join Satislar s on p.PersonelID=s.PersonelID Where Adi='Nancy'
  
-- Bir personele ait seçilen bir bölgedeki satýþlarýn rakamlarý(Sorgu2)
Select b.BolgeID Bolge,COUNT(s.SatisID) [Satýþ Rakamlarý] From Satislar s 
INNER JOIN Personeller p on s.PersonelID=p.PersonelID
INNER JOIN PersonelBolgeler pb on p.PersonelID=pb.PersonelID
INNER JOIN  Bolgeler br on br.TerritoryID=pb.TerritoryID
INNER JOIN Bolge b on b.BolgeID=br.BolgeID
Group By b.BolgeID

--Bir personele ait seçilen bir bölgedeki nakliye ücretleri. (Sorgu3)
SELECT p.PersonelID, p.Adi, p.SoyAdi, s.MusteriID, s.SevkAdresi, s.SevkAdi, s.ShipVia, s.NakliyeUcreti, b.TerritoryTanimi,b.TerritoryID
FROM Personeller p
INNER JOIN Satislar s on s.PersonelID  = p.PersonelID
INNER JOIN PersonelBolgeler pb on pb.PersonelID = p.PersonelID
INNER JOIN Bolgeler b on b.TerritoryID = pb.TerritoryID 
where p.PersonelID = 5
and b.TerritoryID = '02903'

--Personelin yaptýðý satýþlarýn toplam fiyatlarý(Azdan çoða sýralý).(Sorgu4)
Select p.PersonelID,p.Adi,SUM(sd.BirimFiyati*sd.Miktar) From [Satis Detaylari] sd 
INNER JOIN  Satislar s on sd.SatisID=s.SatisID 
INNER JOIN Personeller p on p.PersonelID=s.PersonelID 
Group by p.PersonelID,p.Adi order by SUM(sd.BirimFiyati*sd.Miktar)

--Ayný kategorideki ürünlerin toplam nakliye ücretleri(Sorgu5)
Select k.KategoriID,k.KategoriAdi,SUM(s.NakliyeUcreti) [Toplam Fiyat] from Kategoriler k 
INNER JOIN Urunler u on k.KategoriID=u.KategoriID 
INNER JOIN [Satis Detaylari] sd on sd.UrunID=u.UrunID 
INNER JOIN Satislar s on sd.SatisID=s.SatisID 
Group By k.KategoriID,k.KategoriAdi

--Belirli bir þehrinde bulunan müþterilerin toplam nakliye ücreti (Sorgu6)
Select m.Sehir,SUM(s.NakliyeUcreti) from Musteriler m 
INNER JOIN Satislar s on m.MusteriID=s.MusteriID 
where m.Sehir='Berlin' Group By m.Sehir

--Ayný kategoride olan ürünlerin toplam satýþ sayýsý(Sorgu7)
Select k.KategoriID,COUNT(s.SatisID) From Kategoriler k 
INNER JOIN Urunler u on k.KategoriID=u.KategoriID
INNER JOIN [Satis Detaylari] sd on u.UrunID=sd.UrunID
INNER JOIN Satislar s on s.SatisID=sd.SatisID Group By k.KategoriID

--Belirli bir personelin 1997 yýlýnda sattýðý ürünlerin adý ve sayýsý(Sorgu8)
Select u.UrunAdi,sd.Miktar From [Satis Detaylari] sd 
INNER JOIN Satislar s on sd.SatisID=s.SatisID
INNER JOIN Urunler u on sd.UrunID=u.UrunID 
where YEAR(s.SatisTarihi)=1997 and s.PersonelID=2

--En çok satýlan ürünün kategorisi ve tedarikçisi(Sorgu9)
Select top 1 u.UrunAdi,k.KategoriAdi,t.SirketAdi,Miktar from [Satis Detaylari] sd --Top 1 dediðimizde tablodaki 1. veriyi getirir
INNER JOIN Urunler u on sd.UrunID=u.UrunID 
INNER JOIN Kategoriler k on k.KategoriID=u.KategoriID
INNER JOIN Tedarikciler t on t.TedarikciID=u.TedarikciID 
order by Miktar desc --DESC büyükten küçüðe sýralar

--Stored Procedure 
--Ýdsi verilen personeli getirme
CREATE PROCEDURE sp_PersonelGetir
	@Id int 
As 
Select * from Personeller where PersonelID=@Id

Exec sp_PersonelGetir 3

--(Sorgu3) için SP oluþturalým------Bir personele ait seçilen bir bölgedeki nakliye ücretleri.

CREATE PROCEDURE bolgeNakliyeUcreti(
	@BolgeId nvarchar(20),
	@PersId int

)As
Select p.PersonelID, p.Adi, p.SoyAdi, s.MusteriID, s.SevkAdresi, s.SevkAdi, s.ShipVia, s.NakliyeUcreti, b.TerritoryTanimi,b.TerritoryID
FROM Personeller p
INNER JOIN Satislar s on s.PersonelID  = p.PersonelID
INNER JOIN PersonelBolgeler pb on pb.PersonelID = p.PersonelID
INNER JOIN Bolgeler b on b.TerritoryID = pb.TerritoryID 
where p.PersonelID = @PersId
and b.TerritoryID = @BolgeId

Exec bolgeNakliyeUcreti '02903', 5

--(Sorgu6) için SP oluþturalým------Belirli bir þehrinde bulunan müþterilerin toplam nakliye ücreti 
CREATE PROCEDURE SehirNakliyeUcreti(
	@Sehir varchar(15)
)As
Select m.Sehir,SUM(s.NakliyeUcreti) from Musteriler m 
INNER JOIN Satislar s on m.MusteriID=s.MusteriID 
where m.Sehir=@Sehir Group By m.Sehir

Exec SehirNakliyeUcreti 'Berlin'


--(Sorgu8) için SP oluþturalým------Belirli bir personelin belirli bir yýlda sattýðý ürünlerin adý ve sayýsý

CREATE PROCEDURE personelSatis(
	@persId int,
	@Yil int
)As
Select u.UrunAdi,sd.Miktar From [Satis Detaylari] sd 
INNER JOIN Satislar s on sd.SatisID=s.SatisID
INNER JOIN Urunler u on sd.UrunID=u.UrunID 
where YEAR(s.SatisTarihi)=@Yil and s.PersonelID=@persId

Exec personelSatis 2,1997

