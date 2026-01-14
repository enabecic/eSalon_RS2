# **eSalon_RS2**
---

Seminarski rad iz predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija u Mostaru.

---

## **Upute za pokretanje**

### **Backend setup**
1. Klonirati repozitorij
2. Extractovati: `fit-build-2026-01-14 - env`
3. Postaviti `.env` fajl u: `\eSalon_RS2\eSalon`
4. Otvoriti `\eSalon_RS2\eSalon` u terminalu i pokrenuti komandu:  
   `docker-compose up --build`
   
### **Frontend setup**
1. Vratiti se u root folder i locirati `fit-build-2026-01-14.zip` arhivu.
2. Extract arhive daje dva foldera: `Release` i `flutter-apk`.
3. U `Release` folderu pokrenuti: `esalon_desktop.exe`
4. Prije pokretanja mobilne aplikacije pobrinuti se da aplikacija već ne postoji na android emulatoru, ukoliko postoji, uraditi deinstalaciju iste
5. U `flutter-apk` folderu nalazi se fajl: `app-release.apk` Prenijeti ga na Android emulator. 

---

## **Kredencijali za prijavu**
---

### **Desktop aplikacija**

#### **Admin**
- Korisničko ime: `admin`
- Lozinka: `test`

#### **Frizer 1**
- Korisničko ime: `frizer`
- Lozinka: `test`

#### **Frizer 2**
- Korisničko ime: `frizer2`
- Lozinka: `test`

#### **Frizer 3**
- Korisničko ime: `frizer3`
- Lozinka: `test`

---

### **Mobilna aplikacija**

#### **Klijent 1**
- Korisničko ime: `klijent`
- Lozinka: `test`

#### **Klijent 2**
- Korisničko ime: `klijent2`
- Lozinka: `test`

---

## **Paypal kredencijali**
- Email: `sb-d743nv48690045@personal.example.com`
- Lozinka: `zt/bT"0=`

---

## **RabbitMQ**
---

RabbitMQ je korišten za slanje mailova dobrodošlice klijentima i frizerima prilikom registracije.
