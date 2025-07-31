## Hardware 1: CPU Ryzen 5 3600, RAM 32GB 3200Mhz
### Quantum a 10000

`$ iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 476 | 4491 | 2150 |
| 4 | [iobench] | 483 | 6646 | 2116 |
| 4 | [iobench] | 475 | 8768 | 2153 |
| 4 | [iobench] | 477 | 10927| 2145 |

`$ iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 7 | [iobench] | 491 | 856 | 2085 |
| 5 | [iobench] | 474 | 852 | 2157 |
| 8 | [iobench] | 423 | 858 | 2419 |
| 7 | [iobench] | 433 | 2952 | 2360 |
| 5 | [iobench] | 438 | 3019 | 2334 |
| 8 | [iobench] | 408 | 3290 | 2506 |
| 7 | [iobench] | 474 | 5321 | 2158 |
| 5 | [iobench] | 459 | 5364 | 2229 |
| 8 | [iobench] | 454 | 5806 | 2251 |
| 7 | [iobench] | 439 | 7487 | 2331 |
| 5 | [iobench] | 435 | 7605 | 2354 |
| 8 | [iobench] | 482 | 8066 | 2121 |

`$ cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 14 | [cpubench] | 66439 | 51782 | 808 |
| 14 | [cpubench] | 64756 | 52596 | 829 |
| 14 | [cpubench] | 64678 | 53431 | 830 |
| 14 | [cpubench] | 67272 | 54267 | 798 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 21 | [cpubench] | 22340 | 61190 | 2403 |
| 21 | [cpubench] | 22146 | 63611 | 2424 |
| 20 | [cpubench] | 23421 | 65806 | 2292 |
| 18 | [cpubench] | 23269 | 65811 | 2307 |
| 21 | [cpubench] | 22312 | 66050 | 2406 |
| 20 | [cpubench] | 23545 | 68113 | 2280 |
| 18 | [cpubench] | 23483 | 68133 | 2286 |
| 21 | [cpubench] | 25358 | 68471 | 2117 |

`$ iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 29 | [cpubench] | 23300 | 98185 | 2304 |
| 30 | [cpubench] | 22219 | 98194 | 2416 |
| 29 | [cpubench] | 23249 | 100504 | 2309 |
| 30 | [cpubench] | 22128 | 100628 | 2426 |
| 27 | [cpubench] | 10632 | 98180 | 5049 |
| 29 | [cpubench] | 23421 | 102828 | 2292 |
| 30 | [cpubench] | 22340 | 103069 | 2403 |
| 29 | [cpubench] | 23401 | 105135 | 2294 |
| 30 | [cpubench] | 23774 | 105487 | 2258 |
| 27 | [cpubench] | 11567 | 103265 | 4641 |
| 25 | [iobench]  | 103   | 98187 | 9850 |
| 27 | [cpubench] | 28738 | 107917 | 1868 |
| 25 | [iobench]  | 298   | 108047 | 3425 |
| 27 | [cpubench] | 29080 | 109799 | 1846 |
| 25 | [iobench]  | 475   | 111482 | 2155 |
| 25 | [iobench]  | 483   | 113643 | 2120 |

`$ cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 34 | [cpubench] | 28135| 151187 | 1908 |
| 34 | [cpubench] | 26072| 153114 | 2059 |
| 36 | [iobench]  | 240  | 151188 | 4260 |
| 39 | [iobench]  | 187  | 151201 | 5456 |
| 34 | [cpubench] | 27236| 155190 | 1971 |
| 38 | [iobench]  | 170  | 151192 | 6002 |
| 36 | [iobench]  | 266  | 155458 | 3845 |
| 34 | [cpubench] | 25144| 157184 | 2135 |
| 39 | [iobench]  | 268 | 156681 | 3807 |
| 38 | [iobench]  | 298 | 157204 | 3429 |
| 36 | [iobench]  | 413 | 159314 | 2475 |
| 39 | [iobench]  | 420 | 160497 | 2436 |
| 38 | [iobench]  | 386 | 160644 | 2650 |
| 36 | [iobench]  | 432 | 161799 | 2367 |
| 38 | [iobench]  | 518 | 163306 | 1976 |
| 39 | [iobench]  | 437 | 162947 | 2340 |

### Quantum a 1000

`iobench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 38 | 9180 | 26519 |
| 4 | [iobench] | 38 | 35807 | 26317 |
| 4 | [iobench] | 39 | 62209 | 25916 |
| 4 | [iobench] | 38 | 88230 | 26313 |

`iobench 4 &; iobench 4 &; iobench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 10 | [iobench] | 36 | 149284 | 28293 |
| 8 | [iobench]  | 34 | 149295 | 29525 |
| 11 | [iobench] | 33 | 149444 | 30300 |
| 10 | [iobench] | 34 | 177791 | 29260 |
| 8 | [iobench]  | 33 | 179066 | 30211 |
| 11 | [iobench] | 33 | 179977 | 30136 |
| 10 | [iobench] | 36 | 207249 | 28392 |
| 8 | [iobench]  | 37 | 209497 | 27300 |
| 11 | [iobench] | 36 | 210270 | 28030 |
| 10 | [iobench] | 36 | 235843 | 27754 |
| 8 | [iobench]  | 35 | 237006 | 28506 |
| 11 | [iobench] | 37 | 238461 | 27483 |

`$ cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 14 | [cpubench] | 1267 | 429500 | 42370 |
| 14 | [cpubench] | 1363 | 471992 | 39382 |
| 14 | [cpubench] | 1208 | 511488 | 44409 |
| 14 | [cpubench] | 1217 | 555995 | 44102 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 18 | [cpubench] | 1462 | 694313 | 36698 |
| 20 | [cpubench] | 1452 | 694410 | 36967 |
| 18 | [cpubench] | 1408 | 731177 | 38118 |
| 20 | [cpubench] | 1412 | 731585 | 38016 |
| 18 | [cpubench] | 1441 | 769435 | 37241 |
| 20 | [cpubench] | 1433 | 769774 | 37444 |
| 21 | [cpubench] | 460 | 694601 | 116454 |
| 18 | [cpubench] | 1342 | 806820 | 39986 |
| 20 | [cpubench] | 1352 | 807413 | 39703 |
| 21 | [cpubench] | 812 | 811379 | 66047 |
| 21 | [cpubench] | 1222 | 877523 | 43922 |
| 21 | [cpubench] | 1382 | 921560 | 38826 |

`$ iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 25 | [iobench]  | 17 | 1054466 | 59919 |
| 27 | [cpubench] | 883 | 1054375 | 607|91  |
|29  | [cpubench] | 882 | 1054472 | 60856 |
| 25 | [iobench]  | 17 | 1114594 | 59787 |
| 27 | [cpubench] | 906 | 1115396 | 59230 |
| 29 | [cpubench] | 877 | 1115657 | 61152 |
| 30 | [cpubench] | 406 | 1054706 | 131970 |
| 25 | [iobench]  | 16 | 1174549 | 61133 |
| 27 | [cpubench] | 867 | 1174939 | 61908 |
| 29 | [cpubench] | 855 | 1177046 | 62785 |
| 25 | [iobench]  | 17 | 1235851 | 59935 |
| 27 | [cpubench] | 895 | 1237050 | 59976 |
| 29 | [cpubench] | 917 | 1240092 | 58493 |
| 30 | [cpubench] | 451 | 1187011 | 118901 |
| 30 | [cpubench] | 1261 | 1306027 | 42554 |
| 30 | [cpubench] | 1317 | 1348689 | 40745 |

`$ cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 36 | [iobench] | 26 | 1480471 | 38411 |
| 38 | [iobench] | 25 | 1480509 | 40186 |
| 39 | [iobench] | 22 | 1480763 | 44985 |
| 34 | [cpubench] | 791 | 1480525 | 67806 |
| 36 | [iobench] | 24 | 1519140 | 42404 |
| 38 | [iobench] | 24 | 1520970 | 41745 |
| 39 | [iobench] | 22 | 1525990 | 45871 |
| 36 | [iobench] | 26 | 1561779 | 38342 |
| 38 | [iobench] | 26 | 1562959 | 38889 |
| 39 | [iobench] | 24 | 1572122 | 42260 |
| 34 | [cpubench] | 751 | 1548508 | 71425 |
| 36 | [iobench] | 25 | 1600375 | 39414 |
| 38 | [iobench] | 26 | 1602052 | 38459 |
| 39 | [iobench] | 26 | 1614655 | 38613 |
| 34 | [cpubench] | 959 | 1620099 | 55962 |
| 34 | [cpubench] | 1331 | 1676169 | 40330 |

## Hardware 2: 
### Quantum a 10000

`$ iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 291 | 6634 | 3511 |
| 4 | [iobench] | 293 | 10153 | 3486 |
| 4 | [iobench] | 297 | 13649 | 3447 |
| 4 | [iobench] | 305 | 17103 | 3350 |


`iobench 4 &; iobench 4 &; iobench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
 | 10 | [iobench] | 271 | 22255 | 3766 |
| 9 | [iobench] | 266 | 22250 | 3836 |
| 7 | [iobench] | 263 | 22249 | 3883 |
| 7 | [iobench] | 308 | 26154 | 3324 |
| 9 | [iobench] | 302 | 26110 | 3389 |
| 10 | [iobench] | 293 | 26048 | 3492 |
| 9 | [iobench] | 288 | 29526 | 3548 |
| 7 | [iobench] | 266 | 29504 | 3843 |
| 10 | [iobench] | 259 | 29563 | 3950 |
| 9 | [iobench] | 297 | 33097 | 3437 |
| 7 | [iobench] | 296 | 33363 | 3449 |
| 10 | [iobench] | 271 | 33532 | 3775 |

`cpubench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 12 | [cpubench] | 27872 | 80169 | 1926 |
| 12 | [cpubench] | 27887 | 82107 | 1925 |
| 12 | [cpubench] | 27930 | 84042 | 1922 |
| 12 | [cpubench] | 27930 | 85973 | 1922 |

`cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 15 | [cpubench] | 10060 | 97076 | 5336 |
| 17 | [cpubench] | 9998 | 97083 | 5369 |
| 18 | [cpubench] | 9424 | 97093 | 5696 |
| 15 | [cpubench] | 10009 | 102442  5363 |
| 18 | [cpubench] | 9352 | 102819 | 5740 |
| 15 | [cpubench] | 10004 | 107830 | 5366 |
| 17 | [cpubench] | 9954 | 107849 | 5393 |
| 18 | [cpubench] | 9411 | 108589 | 5704 |

| 18 | [cpubench] | 11287 | 114320 | 4756 |

`cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 21 | [cpubench] | 10161 | 131775 | 5283 |
| 23 | [cpubench] | 10064 | 131782 | 5334 |
| 24 | [cpubench] | 9310 | 131795 | 5766 |
| 21 | [cpubench] | 10070 | 137085 | 5331 |
| 23 | [cpubench] | 10070 | 137143 | 5331 |
| 24 | [cpubench] | 9383 | 137588 | 5721 |
| 21 | [cpubench] | 10138 | 142440 | 5295 |
| 23 | [cpubench] | 10047 | 142501 | 5343 |
| 24 | [cpubench] | 9446 | 143333 | 5683 |
| 21 | [cpubench] | 10070 | 147756 | 5331 |
| 23 | [cpubench] | 10203 | 147860 | 5261 |
| 24 | [cpubench] | 11557 | 149040 | 4645 |

`iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 31 | [cpubench] | 7810 | 169206 | 6873  |
| 29 | [cpubench] | 7709 | 169202 | 6963  |
| 32 | [cpubench] | 7017 | 169221 | 7650  |
| 40 | [cpubench] | 4884 | 173243 | 10991 |
| 39 | [cpubench] | 4787 | 173241 | 11214 |
| 31 | [cpubench] | 4925 | 176123 | 10900 |
| 29 | [cpubench] | 4905 | 176214 | 10944 |
| 32 | [cpubench] | 4628 | 176933 | 11599 |
| 40 | [cpubench] | 4925 | 184284 | 10899 |
| 39 | [cpubench] | 4807 | 184504 | 11166 |
| 35 | [iobench]  | 42  | 173192 | 24141 |
| 37 | [cpubench] | 2086 | 173199 | 25733 |
| 32 | [cpubench] | 4540 | 188586 | 11823 |
| 40 | [cpubench] | 4845 | 195232 | 11080 |
| 39 | [cpubench] | 4733 | 195713 | 11342 |
| 31 | [cpubench] | 4915 | 198269 | 10921 |
| 29 | [cpubench] | 4870 | 198262 | 11023 |
| 32 | [cpubench] | 5008 | 200464 | 10718 |
| 40 | [cpubench] | 6953 | 206362 | 7720 |
| 39 | [cpubench] | 7466 | 207105 | 7190 |
| 35 | [iobench]  | 58   | 197382 | 17576 |
| 37 | [cpubench] | 3231 | 199055 | 16610 |
| 35 | [iobench]  | 210  | 214974 | 4856 |
| 37 | [cpubench] | 10369 | 215679 | 5177 |
| 35 | [iobench]  | 208 | 219848 | 4911 |
| 37 | [cpubench] | 12516 | 220883 | 4289 |


`cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 45 | [iobench] | 251 | 244942 | 4078 |
| 47 | [iobench] | 245 | 244947 | 4171 |
| 48 | [iobench] | 176 | 244956 | 5814 |
| 43 | [cpubench] | 8664 | 244930 | 6196 |
| 45 | [iobench] | 266 | 249048 | 3838 |
| 47 | [iobench] | 239 | 249153 | 4273 |
| 48 | [iobench] | 208 | 250808 | 4921 |
| 45 | [iobench] | 277 | 252908 | 3694 |
| 43 | [cpubench] | 8622 | 251144 | 6226 |
| 47 | [iobench] | 212 | 253442 | 4828 |
| 45 | [iobench] | 264 | 256616 | 3866 |
| 48 | [iobench] | 193 | 255763 | 5281 |
| 47 | [iobench] | 254 | 258300 | 4030 |
| 43 | [cpubench] | 9033 | 257399 | 5943 |
| 48 | [iobench] | 237 | 261082 | 4313 |
| 43 | [cpubench] | 16844 | 263353 | 3187 |

### Quantum a 1000

`iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|-------------------|--------|------------|---------------|
| 8 | [iobench] | 28 | 76447 | 35464 |
| 8 | [iobench] | 28 | 112011 | 35940 |
| 8 | [iobench] | 28 | 148126 | 36352 |
| 8 | [iobench] | 28 | 184668 | 36092 |

`$ iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|-------------------|--------|------------|---------------|
| 5 | [iobench] | 25 | 11632 | 39690 |
| 8 | [iobench] | 24 | 11877 | 41180 |
| 7 | [iobench] | 24 | 11801 | 42452 |
| 5 | [iobench] | 25 | 51643 | 40355 |
| 8 | [iobench] | 26 | 53598 | 38874 |
| 7 | [iobench] | 24 | 54634 | 41791 |
| 8 | [iobench] | 29 | 92829 | 34804 |
| 5 | [iobench] | 28 | 92347 | 36469 |
| 7 | [iobench] | 30 | 96642 | 33658 |
| 8 | [iobench] | 36 | 127750 | 28239 |
| 5 | [iobench] | 33 | 129057 | 30219 |
| 7 | [iobench] | 34 | 130430 | 29799 |

`cpubench 4 &`

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|-------------------|--------|------------|---------------|
| 10 | [cpubench] | 608 | 352739 | 88235 |
| 10 | [cpubench] | 465 | 441220 | 115382 |
| 10 | [cpubench] | 644 | 556797 | 83322 |
| 10 | [cpubench] | 700 | 640341 | 76605 |

