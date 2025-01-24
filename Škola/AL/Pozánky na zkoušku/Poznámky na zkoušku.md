# Poznámky na zkoušku

## Algoritmus

- Všeobecná pravidla určující transformaci vstupních dat na výstupní.
- Přesné znění definice algoritmu zní: „Algoritmus je procedura proveditelná Turingovým strojem."

## Program
- Realizace algoritmu !

## Základní vlastnosti algoritmu

- **Hromadnost**
	- Algoritmus je použitelný na libovolné vstupní údaje splňující požadované podmínky
	-  Algoritmus neřeší jeden konkrétní problém, ale obecnou třídu obdobných problému
	- Např. nikoliv výpočet 2x8, ale součin dvou celých čísel
- **Determinismus**
	- Každý krok algoritmu musí být jednoznačně a přesně definován; v každé situaci musí být naprosto zřejmé, co a jak se má provést, jak má provádění algoritmu pokračovat.
- **Rezultativnost** (**konečnost**)
	- Algoritmus při zadání vstupních dat vždy vrátí nějaký výsledek (může se jednat i jen o chybové hlášení). V konečném poctu kroku musí algoritmus vrátit výsledek
- **Efektivní** (**efektivnost**)
	- Obecně požadujeme, aby algoritmus byl efektivní, v tom smyslu, že požadujeme, aby každá operace požadovaná algoritmem, byla dostatečně jednoduchá na to, aby mohla být alespoň v principu provedena v konečném čase pouze s použitím tužky a papíru. (tj. byla elementární).
- **Efektivita**
	- časová - spotřeba času, důležitější - měl by být rychlejší?
	- paměťová - spotřeba paměti
	- přehlednost a srozumitelnost
- **Správný** (**správnost**)
	- Algoritmus je správný tehdy, když pro všechny údaje splňující vstupní podmínku se proces zastaví a výstupní údaje splňují výstupní podmínku.
- Algoritmus nesmí být závislý na prostředí, ve kterém je realizován.

## Etapy řešení algoritmické úlohy

1. **Zadání** - Formulace problému, stanovení cílů.
2. **Rozbor**, **analýza** - volba strategie, navržení postupu.
	- specifikace
	- vstupy - identifikátor, popis, typ proměnné, vstupní podmínky
	- výstupy - identifikátor, popis, typ proměnné
	- (další proměnné)
 3. **Algoritmus** – návrh – můžeme použít různý zápis
	- Pseudokód
	- vývojový diagram
	- Zápis v programovacím jazyce
	- Strukturovaný zápis v přirozením jazyce
4. **Testování**, ověření správnosti.
5. Přepis do progr. jazyka (**kódování**).
	- Ladění
	- Optimalizace
6. **Dokumentace**.

## Klasifikace algoritmu podle složitosti

**Big-Oh** notace

- **O(1)** – Konstantní čas
- **O(log n)** – Logaritmická složitost
- **O(n)** – Lineární složitost
- **O(n log n)** – Lineárně logaritmická složitost
- **O(n²)** – Kvadratická složitost
- **O(n³)** – Kubická složitost
- **O(2^n)** – Exponenciální složitost
- **O(n!)** – Faktoriální složitost

![](Big_O_graf.jpeg)

## Rekurze
 - volání podprogramu opětovně v jeho těle v době, kdy předchozí volání ještě nebylo ukončeno

### Přímá rekurze

-  podprogram volá  sám sebe

```c
void A(…)
{

  A();

}
```

### Nepřímá rekurze

- aktivují se vzájemně dva podprogramy

```c
void A(…)
{
  B();
}

void B(…)
{
  A();
}
```


## Insertion sort

- Složitost: **O(n²)**

![](Insertion-sort-example-300px.gif)

### Výhody

- jednoduchá implementace
- efektivní na malých množinách
- efektivní na částečně seřazených množinách (běží v čase O ( N + d ) ![{\displaystyle O(N+d)}](https://wikimedia.org/api/rest_v1/media/math/render/svg/abcc6a026004c60caa2973e9e6e3c6b4971c63b0) , kde d ![{\displaystyle d}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e85ff03cbe0c7341af6b982e47e9f90d235c66ab) je počet transpozic prvků množiny)
- efektivnější než většina ostatních O ( N 2 ) ![{\displaystyle O(N^{2})}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e5d43a3df904fa4d7220f5b86285298aa36d969b) algoritmů ([řazení výběrem](https://cs.wikipedia.org/wiki/%C5%98azen%C3%AD_v%C3%BDb%C4%9Brem), [bublinkové řazení](https://cs.wikipedia.org/wiki/Bublinkov%C3%A9_%C5%99azen%C3%AD "Bublinkové řazení")), průměrný čas je N 2 4 ![{\displaystyle {\frac {N^{2}}{4}}}](https://wikimedia.org/api/rest_v1/media/math/render/svg/73058bc9aa37a8dd0e64990c18bdb062e4c5cf56) a v nejlepším případě je dokonce lineární
- řadí [stabilně](https://cs.wikipedia.org/wiki/Stabiln%C3%AD_%C5%99azen%C3%AD "Stabilní řazení") (nemění vzájemné pořadí prvků se stejnými klíči)
- vyžaduje pouze O ( 1 ) paměti (kromě vlastního vstupu)
- je [online algoritmem](https://cs.wikipedia.org/w/index.php?title=Online_algoritmus&action=edit&redlink=1 "Online algoritmus (stránka neexistuje)"), tzn. dokáže řadit data tak, jak přicházejí na vstup

## Bubble sort

- Složitost: **O(n²)**
- Založený na postupném porovnání a případné záměně sousedních prvků

![](Bubble-sort-example-300px.gif)

### Výhody

- z hlediska naprogramování nejjednodušším algoritmem pro řazení

### Nevýhody

- Pro řazení opravdu velkých polí je bublinkové řazení naprosto nevhodné

## Merge sort

- Složisott: **O(n log n)** 


![](Merge-sort-example-300px.gif)
![](Merge_sort_algorithm_diagram.svg)

### Výhody

- Dobré pro velké datové sady

### Nevýhody

- Vyšší paměťová náročnost
- Komplikovanější implementace
-  Nevýhodné pro malé množiny dat

## Quick sort

- Složitost: **O(n log n)**

![](quick-sort.webp)

## Heap sort

- Složisott: **O(n log n)** 

### Postup heap sortu:

1. **Vytvoření max-heapu**: Nejprve přeorganizujeme pole do podoby max-heapu, což znamená, že největší prvek bude na začátku pole. To děláme pomocí operace zvané **heapify**.
    
2. **Třídění**:
    
    - Vyměníme první prvek (největší) s posledním prvkem.
    - Zmenšíme rozsah "haldy" (ignorujeme poslední prvek, protože je již správně na svém místě).
    - Znovu aplikujeme **heapify**, abychom obnovili vlastnost max-heapu.
    - Tento proces opakujeme, dokud není celé pole setříděné.

![](Heapsort-example.gif)