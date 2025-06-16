# FIIT STU LS 2024/25: WHERE AMAZING HAPPENS (NBA)

**Autor:** Martin Kvietok  
**Predmet:** Database Systems  
**Fakulta:** Fakulta informatiky a informačných technológií, STU Bratislava

---

## Popis projektu

Cieľom zadania bolo vytvoriť komplexné SQL dotazy nad reálnym datasetom z NBA, pričom dôraz bol kladený na správnosť, efektivitu a dodržanie formátu. Úlohy simulujú analýzu športových štatistík ako výkony hráčov, prestupy, zápasové štatistiky a historické údaje tímov.

---

## Dataset

Dataset vychádza z [Kaggle NBA datasetu](https://www.kaggle.com/datasets/wyattowalsh/basketball) a obsahuje nasledovné tabuľky:

- `play_records`
- `games`
- `players`
- `teams`
- `team_history`

---

## Riešené úlohy

### 1. Rebound → Field Goal bez iných udalostí (1 bod)
- Vyhľadanie situácií, kde hráč po doskoku okamžite skóroval.
- Výstup: `player_id`, `first_name`, `last_name`, `period`, `period_time`.

### 2. Zmeny tímov počas sezóny (3 body)
- Detekcia hráčov, ktorí počas sezóny zmenili tím.
- Výpočet: `PPG`, `APG`, `games` pre každý tím.
- Zoradenie: podľa počtu zmien, aktivity hráča, mena.

### 3. Podrobné štatistiky hráčov v zápase (3 body)
- Výpočet:
  - `points`, `2PM`, `3PM`, `missed shots`
  - `shooting %`, `FTM`, `missed free throws`, `FT %`

### 4. Triple Double a série (3 body)
- Hráči, ktorí dosiahli triple double (body, asistencie, doskoky).
- Výpočet najdlhšej nepretržitej série.

### 5. Domáce vs. vonkajšie zápasy tímov (2 body)
- Výpočet počtu domácich a vonkajších zápasov + ich percentuálne zastúpenie.
- Zohľadnenie historických názvov tímov.

### 6. Stabilita výkonu hráča (2 body)
- Vyhľadanie sezón, kde hráč odohral aspoň 50 zápasov.
- Výpočet sezónnej stability na základe striedania úspešnosti streľby.

---

## Technické poznámky

- Každá úloha je riešená v samostatnom `.sql` súbore (`1.sql`, `2.sql`, ...).
- Nepoužíva sa `LATERAL JOIN` ani rekurzívne dotazy.
