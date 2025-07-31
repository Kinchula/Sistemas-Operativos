## Hardware 1: CPU Ryzen 5 3600, RAM 32GB 3200Mhz
### Quantum a 10000
`iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 155 | 2365 | 6591 |
| 4 | [iobench] | 161 | 8970 | 6328 |
| 4 | [iobench] | 162 | 15311 | 6319 |
| 4 | [iobench] | 161 | 21643 | 6326 |

`$ iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 14 | [iobench] | 189 | 90850 | 5405 |
| 16 | [iobench] | 187 | 90836 | 5464 |
| 10 | [iobench] | 107 | 87503 | 9547 |
| 17 | [iobench] | 136 | 90833 | 7520 |
| 11 | [iobench] | 81 | 87518 | 12560 |
| 16 | [iobench] | 138 | 96324 | 7404 |
| 14 | [iobench] | 134 | 96282 | 7610 |
| 10 | [iobench] | 123 | 97085 | 8279 |
| 17 | [iobench] | 126 | 98395 | 8100 |
| 11 | [iobench] | 121 | 100115 | 8448 |
| 16 | [iobench] | 145 | 103780 | 7016 |
| 14 | [iobench] | 125 | 103928 | 8136 |
| 10 | [iobench] | 126 | 105401 | 8121 |
| 17 | [iobench] | 126 | 106533 | 8116 |
| 11 | [iobench] | 119 | 108606 | 8602 |
| 16 | [iobench] | 125 | 110840 | 8167 |
| 14 | [iobench] | 130 | 112097 | 7846 |
| 10 | [iobench] | 133 | 113561 | 7673 |
| 17 | [iobench] | 150 | 114681 | 6813 |
| 11 | [iobench] | 154 | 117243 | 6621 |

`$ cpubench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 20 | [cpubench] | 57292 | 416676 | 937 |
| 20 | [cpubench] | 57049 | 417628 | 941 |
| 20 | [cpubench] | 57600 | 418584 | 932 |
| 20 | [cpubench] | 57661 | 419532 | 931 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 8 | [cpubench] | 19131 | 15| 26 7 || 2 [c806pub |
ench] | 18955 | 1529 | 2832 |
| 5 | [cpubench] | 18365 | 1557 | 2923 |
| 8 | [cpubench] | 19077 | 4374 | 2814 |
| 7 | [cpubench] | 18875 | 4403 | 2844 |
| 5 | [cpubench] | 19016 | 4519 | 2823 |
| 8 | [cpubench] | 19016 | 7227 | 2823 |
| 7 | [cpubench] | 19077 | 7289 | 2814 |
| 5 | [cpubench] | 19036 | 7381 | 2820 |
| 8 | [cpubench] | 19097 | 10086 | 2811 |
| 7 | [cpubench] | 19124 | 10142 | 2807 |
| 5 | [cpubench] | 19436 | 10237 | 2762 |

`iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 17 | [cpubench] | 160| 1056 | |  [c518pub54 enc| 3h] 354| 1 |
5943 | 51864 | 3367 |
| 14 | [cpubench] | 10794 | 51859 | 4973 |
| 17 | [cpubench] | 16135 | 55261 | 3327 |
| 16 | [cpubench] | 16000 | 55285 | 3355 |
| 14 | [cpubench] | 10909 | 56903 | 4921 |
| 17 | [cpubench] | 16223 | 58637 | 3309 |
| 16 | [cpubench] | 16101 | 58689 | 3334 |
| 17 | [cpubench] | 16015 | 61996 | 3352 |
| 16 | [cpubench] | 15724 | 62072 | 3414 |
| 14 | [cpubench] | 12589 | 61895 | 4264 |
| 14 | [cpubench] | 24568 | 66199 | 2185 |
| 12 | [iobench] | 56 | 51906 | 18070 |
| 12 | [iobench] | 160 | 69990 | 6388 |
| 12 | [iobench] | 160 | 76392 | 6385 |
| 12 | [iobench] | 161 | 82790 | 6357 |

`$ cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 21 | [cpubench] | 12123 | 129516 | 4428 |
| 26 | [iobench] | 169 | 129485 | 6025 |
| 25 | [iobench] | 156 | 129496 | 6561 |
| 23 | [iobench] | 114 | 129512 | 8972 |
| 21 | [cpubench] | 10777 | 133983 | 4981 |
| 26 | [iobench] | 171 | 135561 | 5959 |
| 25 | [iobench] | 164 | 136108 | 6226 |
| 21 | [cpubench] | 12557 | 139034 | 4275 |
| 23 | [iobench] | 132 | 138517 | 7751 |
| 21 | [cpubench] | 11597 | 143384 | 46| 25 | [ioben29 c|
h] | 179 | 142361 | 5698 |
| 26 | [iobench] | 151 | 141570 | 6761 |
| 23 | [iobench] | 154 | 146304 | 6619 |
| 26 | [iobench] | 201 | 148362 | 5085 |
| 25 | [iobench] | 173 | 148103 | 5915 |
| 23 | [iobench] | 147 | 152963 | 6922 |

### Quantum a 1000

`$ iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 49 | 3403 | 20883 |
| 4 | [iobench] | 51 | 24355 | 19941 |
| 4 | [iobench] | 51 | 44359 | 19761 |
| 4 | [iobench] | 51 | 64186 | 19862 |

`$ iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 10 | [iobench] | 36 | 201783 | 28232 |
| 8 | [iobench] | 34 | 201822 | 30014 |
| 11 | [iobench] | 32 | 201781 | 31208 |
| 10 | [iobench] | 36 | 230213 | 27855 |
| 8 | [iobench] | 37 | 232027 | 27369 |
| 11 | [iobench] | 34 | 233157 | 29598 |
| 10 | [iobench] | 38 | 258225 | 26590 |
| 8 | [iobench] | 36 | 259523 | 27722 |
| 11 | [iobench] | 37 | 262905 | 27559 |
| 8 | [iobench] | 38 | 287378 | 26940 |
| 10 | [iobench] | 34 | 285005 | 29503 |
| 11 | [iobench] | 42 | 290621 | 24328 |

`$ cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 14 | [cpubench] | 3639 | 491469 | 14749 |
| 14 | [cpubench] | 3778 | 506293 | 14208 |
| 14 | [cpubench] | 4301 | 520571 | 12481 |
| 14 | [cpubench] | 4035 | 533124 | 13302 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 18 | [cpuben|c h]2 0|  1|2 4[4c p|u b7e0n9c0h]7 3|  |1 244231 2|5  7|0
9065 | 43192 |
| 21 | [cpubench] | 1236 | 709090 | 43414 |
||  2108  ||  [[ccppuubbeenncchh]]  ||  11224423  ||  77552327492 8|  4|3 242311 7|0 
|
| 21 | [cpubench] | 1245 | 752665 | 43107 |
| 20 | [cpubench] | 1195 | 795750 | 44912 |
| 21 | [cpubench] | 1192 | 795912 | 45024 |
| 18 | [cpubench] | 1181 | 795746 | 45430 |
| 20 | [cpubench] | 1220 | 840812 | 43970 |
| 21 | [cpubench] | 1220 | 841082 | 44001 |
| 18 | [cpubench] | 1223 | 841342 | 43882 |

`$ iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 30 | [cpubench] | 947 | 1068831 | 56632 |
| 29 | [cpubench] | 874 | 1068842 | 61384 |
| 25 | [iobench] | 16 | 1068888 | 63883 |
| 27 | [cpubench] | 652 | 1068853 | 82333 |
| 30 | [cpubench] | 935 | 1125667 | 57379 |
| 29 | [cpubench] | 863 | 1130441 | 62175 |
| 25 | [iobench] | 16 | 1132977 | 61061 |
| 30 | [cpubench] | 844 | 1183223 | 63553 |
| 27 | [cpubench] | 550 | 1151449 | 97562 |
| 25 | [iobench] | 16 | 1194216 | 61711 |
| 29 | [cpubench] | 756 | 1192805 | 70952 |
| 30 | [cpubench] | 819 | 1246971 | 65525 |
| 25 | [iobench] | 16 | 1256104 | 60309 |
| 29 | [cpubench] | 902 | 1263980 | 59475 |
| 27 | [cpubench] | 706 | 1249325 | 76022 |
| 27 | [cpubench] | 3425 | 1325409 | 15672 |

`$ cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 39 | [iobench] | 28 | 1703064 | 35419 |
| 36 | [iobench] | 28 | 1|70 31013 8|  3|6 0[7i2o b|e
nch] | 28 | 1703047 | 36253 |
| 36 | [iobench] | 34 | 1739400 | 29822 |
| 39 | [iobench] | 33 | 1738738 | 30967 |
| 38 | [iobench] | 28 | 1739646 | 35379 |
| 34 | [cpubench] | 611 | 1703145 | 87763 |
| 36 | [iobench] | 32 | 1769408 | 31597 |
| 39 | [iobench] | 32 | 1769929 | 31415 |
| 38 | [iobench] | 28 | 1775243 | 36451 |
| 36 | [iobench] | 27 | 1801177 | 36700 |
| 39 | [iobench] | 27 | 1801603 | 37060 |
| 38 | [iobench] | 27 | 1811866 | 36785 |
| 34 | [cpubench] | 862 | 1791152 | 62242 |
| 34 | [cpubench] | 3376 | 1853452 | 15900 |
| 34 | [cpubench] | 3359 | 1869414 | 15979 |

## Hardware 2: CPU Ryzen 3200G, 32GB Ram  

`$ iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 1514 | 382 | 676 |
| 4 | [iobench] | 1497 | 1059 | 684 |
| 4 | [iobench] | 1535 | 1744 | 667 |
| 4 | [iobench] | 1530 | 2413 | 669 |

`iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 10 | [iobench] | 2364 | 3616 | 433 |
| 9 | [iobench] | 1625 | 3617 | 630 |
| 7 | [iobench] | 1055 | 3615 | 970 |
| 10 | [iobench] | 1503 | 4051 | 681 |
| 9 | [iobench] | 1414 | 4248 | 724 |
| 7 | [iobench] | 2295 | 4586 | 446 |
| 10 | [iobench] | 1481 | 4733 | 691 |
| 9 | [iobench] | 2265 | 4973 | 452 |
| 7 | [iobench] | 1570 | 5033 | 652 |
| 10 | [iobench] | 3065 | 5425 | 334 |
| 9 | [iobench] | 1885 | 5431 | 543 |
| 7 | [iobench] | 2000 | 5686 | 512 |

`cpubench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 12 | [cpubench] | 365191 | 14598 | 147 |
| 12 | [cpubench] | 365191 | 14746 | 147 |
| 12 | [cpubench] | 365191 | 14895 | 147 |
| 12 | [cpubench] | 365191 | 15043 | 147 |

`cpubench 4 &; cpubench 4 &;`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 17 | [cpubench] || 182595 | 18178 | 294 |
|15  | [cpubench] | 180751 | 18176 | 297 |
| 17 | [cpubench] | 1813| 15 62 | 18474 | 296 |
| [cpubench] | 182595 | 18477 | 294 |
| 17 | [cpubench] | 182595 | 18772 | 294 |
| 15 | [cpubench] | 181362 | 18775 | 296 |
| 17 | [cpubench] | 182595 | 19070 | 294 |
| 15 | [cpubench] | 180751 | 19073 | 297 |

`cpubench 4 &; cpubench 4 &; cpubench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 2| 23 | [cpubench] | 120636 |0 | [cpubench] | 121730 | 202| 22 20242 | 445 |
44 | 441 |
 | [cpubench] | 120908 | 20245 | 444 |
| 23 | [cpub| 20 | [cpubencench] | 120908 | 20690 | 444 |
h] | 120908 | 20691 | 444 |
| 22 | [cpubench] | 120908 | 20695 | 444 |
| 23 | | 20 | [cpubench] | 120908[cpubench] | 121730 | 21140 |  | 21138 | 444 |
|441 |
 22 | [cpubench] | 121730 | 21145 | 441 |
| 20 | [cpubench] || 23 | 121730 | 21585 | 441 |
 [cpubench] | 121730 | 21587 | 441 |
| 22 | [cpubench] | 121455 | 21592 | 442 |
iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &
| 30 | [cpubench] | 1| 31 | [cpubench] | 12090821455 | 37958 | 442 |
 | 37957 | 444 |
| 28 | [cpubench] | 98501 | 37962 | 545 |
| 30 | [cpubench] | 122564 | 38| 31 | [cpubench] 403 | 438 |
| 121730 | 38404 | 441 |
| 28 | [cpubench] | 98320 | 38513 | 546 |
| 30 | [cpubench] | 122564 | 38847 | 438 |
| 31 | [cpubench] | 120908 | 38848 | 444 |
| 28 | [cpubench] | 96726 | 39062 | 555 |
| 30 | [cpubench] | 122564 | 39291 | 438 |
| 31 | [cpubench] | 121455 | 39295 | 442 |
| 28 | [cpubench] | 205682 | 39623 | 261 |
| 26 | [iobench] | 416 | 37974 | 2461 |
| 26 | [iobench] | 1517 | 40436 | 675 |
| 26 | [iobench] | 1537 | 41112 | 666 |
| 26 | [iobench] | 1523 | 41780 | 672 |

`cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 34 | [cpubench] | 244014 | 44637 | 220 |
| 34 | [cpubench] | 258092 | 44859 | 208 |
| 34 | [cpubench] | 265758 | 45069 | 202 |
| 34 | [cpubench] | 256857 | 45273 | 209 |
| 39 | [iobench] | 929 | 44640 | 1102 |
| 36 | [iobench] | 882 | 44639 | 1160 |
| 38 | [iobench] | 805 | 44641 | 1272 |
| 39 | [iobench] | 1899 | 45743 | 539 |
| 36 | [iobench] | 1715 | 45800 | 597 |
| 38 | [iobench] | 1452 | 45914 | 705 |
| 39 | [iobench] | 2455 | 46288 | 417 |
| 38 | [iobench] | 2708 | 46621 | 378 |
| 36 | [iobench] | 1194 | 46398 | 857 |
| 38 | [iobench] | 2968 | 47000 | 345 |
| 39 | [iobench] | 1444 | 46707 | 709 |
| 36 | [iobench] | 1354 | 47256 | 756 |


### quantum: 10000
Se pausó la prueba de experimentos por tener un resultado ilegible.  

`cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| 30 | [cpubench] | 7292 | 532870 | 736| 1 29| 
||  [27cp |u [becpncubh]en ch| ] 72| 4872 |32 5 |32 8537828 |74 7 |4 70642 |2 
|
| 2| 309 | | [ [cpcpububenenchch] ] | | 72733301 | | 5 54040362980  ||  7735422 1 |
|
| 27 | [cpubench] | 7207 | 540365 | 7448 |
| 30 | [cpub| e29nc |h] [ |cp 7ub20en1 ch| ] 54| 77718584 | | 7 545474 78|
4 | 7472 |
| 27 | [cpubench] | 7167 | 547879 | 7490 |
| 30 | 2| 9 [c| pu[cbpuenbechnc]h] | | 7 7192075  ||  555553530522 | | 7 7445590  ||

| 27 | [cpubench] | 7229 | 555438 | 7426 |
