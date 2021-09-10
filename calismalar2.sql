
--Triggerlar =======Ýkiye ayrýlýr

--DML Triggerlar insert, update, delete 

CREATE TRIGGER OrnekTrigger on Personeller
after insert as 
Select * from Personeller  --Personel Tablosuna Insert iþlemi yapýlýrken Personeller Tablosunu getiriyor.

Insert Personeller(Adi,SoyAdi) Values('Ýlayda','Çetin')

--Tedarikçiler tablosundan bir veri silindiðinde tüm ürünlerin fiyatý 10 artsýn
CREATE TRIGGER TedarikciTrigger on Tedarikciler
after delete as 
Update Urunler Set BirimFiyati+=10
Select * from Urunler

Delete from Tedarikciler where TedarikciID=30

--Personeller tablosunda bir veri güncellendiðinde OrnekPersoneller tablosuna o veriyi ekle
CREATE TRIGGER UpdatePersonel on Personeller
after Update as 
Declare @EskiAdi nvarchar(MAX), @EskiSoyAdi nvarchar(MAX),@YeniAdi nvarchar(MAX),@YeniSoyAdi nvarchar(MAX) 
Select @EskiAdi=Adi,@EskiSoyAdi=SoyAdi from deleted
Select @YeniAdi=Adi,@YeniSoyAdi=SoyAdi from inserted --update iþleminde önce eski veri silinir sonra yenisi eklenir mantýðý vardýr.
Insert OrnekPersoneller(Adi,SoyAdi) Values(@YeniAdi,@YeniSoyAdi)

Update Personeller Set Adi='Selin',SoyAdi='Yýlmaz' where PersonelID=11

--Instead of Trigger

--Personeller tablosunda bir veri güncellenmek istendðinde o veriyi güncellemeden OrnekPersoneller tablosuna ekle
CREATE TRIGGER OrnekUpdatePersonel on Personeller
Instead of update as
Declare @EskiAdi nvarchar(MAX), @EskiSoyAdi nvarchar(MAX),@YeniAdi nvarchar(MAX),@YeniSoyAdi nvarchar(MAX) 
Select @EskiAdi=Adi,@EskiSoyAdi=SoyAdi from deleted
Select @YeniAdi=Adi,@YeniSoyAdi=SoyAdi from inserted
Insert OrnekPersoneller(Adi,SoyAdi) Values(@YeniAdi,@YeniSoyAdi)

Update Personeller Set Adi='Ýrem', SoyAdi='Olgun' where PersonelID=10

--Personeller tablosunda adý Çaðla olan kaydýn silinmesini engelleyen triggerý yazalým

CREATE TRIGGER CaglaTrigger on Personeller 
after delete as 
Declare @Adi nvarchar(max)
Select @Adi=Adi from deleted
If @Adi='Çaðla'
	Begin
		print 'Bu kayýt silinemez!'
		rollback --Transaction
	End

Delete from Personeller where PersonelID=11

--DDL Trigger create,alter,drop

CREATE TRIGGER DDLTtrigger 
on database for drop_table, alter_table,create_function,create_procedure --vs
as print 'Bu iþlem gerçekleþemez!'
Rollback

Drop table OrnekPersoneller


--Transaction Örneði
Create database BankaDb
Go
Use BankaDb
Go
Create table ABankasi
(
	HesapNo int,
	Bakiye money
)
Go 
Create table BBankasi
(
	HesapNo int,
	Bakiye money
)
Insert ABankasi Values  (10,1000),
						(20,2500)
Go
Insert BBankasi Values  (30,2300),
						(40,760)

Create procedure HavaleYap
(
	@Banka nvarchar(MAX),
	@GonderenHesap int,
	@AlanHesap int,
	@Tutar money
)as 
Begin Tran 
Declare @ABakiye int,@BBakiye int,@HesaptakiPara money
If @Banka='ABankasi'
Begin
	Select @HesaptakiPara=Bakiye from ABankasi Where HesapNo=@GonderenHesap
	If @Tutar>@HesaptakiPara
	Begin
		print('Bakiye yetersiz')
		rollback
	End
	Else
	Update ABankasi Set Bakiye=Bakiye -@Tutar Where HesapNo=@GonderenHesap
	Update BBankasi Set Bakiye=Bakiye+@Tutar Where HesapNo=@AlanHesap
	Commit
	End
Else
Begin
	Select @HesaptakiPara=Bakiye from BBankasi Where HesapNo=@GonderenHesap
	If @Tutar>@HesaptakiPara
	Begin
		print('Bakiye yetersiz')
		rollback
	End
	Else
	Update BBankasi Set Bakiye=Bakiye -@Tutar Where HesapNo=@GonderenHesap
	Update ABankasi Set Bakiye=Bakiye+@Tutar Where HesapNo=@AlanHesap
	Commit
	End
Exec HavaleYap 'ABankasi',10,30,100
Exec HavaleYap 'BBankasi',30,10,400

