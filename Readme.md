# ThreeBusMultiplier - VHDL Project

## 📘 Description

Ce projet implémente un **multiplicateur de trois bus de données 8 bits** en VHDL.  
Le composant reçoit trois valeurs (`A`, `B`, `C`) sur trois cycles d'horloge consécutifs, calcule les produits `(A×B)`, `(A×C)` et `(B×C)`, puis les fournit sur un **bus de sortie 16 bits** sur trois cycles consécutifs.

L'entrée `valid_in` signale le début d'une séquence d'entrée (`A` valide), et la sortie `valid_out` signale le début d'une séquence de résultats.

## 📐 Fonctionnement

- **Entrées** :
  - `A_in`, `B_in`, `C_in` : Données 8 bits
  - `clk` : Horloge
  - `reset` : Réinitialisation
  - `valid_in` : Signal d’indication de validité de `A`

- **Sorties** :
  - `result` : Produit (16 bits)
  - `valid_out` : Signal haut pendant le 1er résultat

- **Séquence temporelle** :

| Cycle | Entrées         | État      | Sortie       |
|-------|------------------|-----------|--------------|
| T0    | `valid_in = 1`, A | IDLE → STORE_B | -            |
| T1    | B                | STORE_B → STORE_C | -         |
| T2    | C                | STORE_C → CALC1 | -            |
| T3    | -                | CALC1     | A × B (valid_out = 1) |
| T4    | -                | CALC2     | A × C        |
| T5    | -                | CALC3     | B × C        |
| T6    | -                | Retour à IDLE   | -        |

## 📁 Fichiers

- `ThreeBusMultiplier.vhd` : Composant principal
- `tb_ThreeBusMultiplier.vhd` : Testbench
- `README.md` : Documentation du projet

## 🚀 Simulation

### Avec GHDL (exemple ligne de commande)

```bash
ghdl -a ThreeBusMultiplier.vhd
ghdl -a tb_ThreeBusMultiplier.vhd
ghdl -e tb_ThreeBusMultiplier
ghdl -r tb_ThreeBusMultiplier --vcd=wave.vcd
gtkwave wave.vcd
