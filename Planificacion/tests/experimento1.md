## Hardware 1: CPU Ryzen 5 3600, RAM 32GB 3200Mhz

### Parámetros
- interval = 100000  
- N = 4  
- metrica_cpu = (total_iops * 100) / elapsed_ticks  
- metric_io = (total_cpu_kops * 1000) / elapsed_ticks  

`$ iobench 4 &`

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4   | [iobench]        | 5818 | 286 | 176 |
| 4   | [iobench]        | 5595 | 463 | 183 |
| 4   | [iobench]        | 5657 | 646 | 181 |
| 4   | [iobench]        | 5720 | 827 | 179 |

`$ iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 11 | [iobench] | 8126 | 2634 | 126 |
| 8  | [iobench] | 6781 | 2633 | 151 |
| 10 | [iobench] | 5505 | 2635 | 186 |
| 11 | [iobench] | 5720 | 2761 | 179 |
| 8  | [iobench] | 5305 | 2784 | 193 |
| 10 | [iobench] | 5885 | 2824 | 174 |
| 11 | [iobench] | 6095 | 2940 | 168 |
| 8  | [iobench] | 6131 | 2977 | 167 |
| 10 | [iobench] | 7013 | 2998 | 146 |
| 10 | [iobench] | 6692 | 3145 | 153 |
| 11 | [iobench] | 5417 | 3109 | 189 |
| 8  | [iobench] | 6131 | 3144 | 167 |

`$ cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 14 | [cpubench] | 789458 | 4196 | 68 |
| 14 | [cpubench] | 813381 | 4265 | 66 |
| 14 | [cpubench] | 646785 | 4332 | 83 |
| 14 | [cpubench] | 506445 | 4415 | 106 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 18 | [cpubench] | 265758 | 5601 | 202 |
| 20 | [cpubench] | 267080 | 5603 | 201 |
| 21 | [cpubench] | 263152 | 5604 | 204 |
| 18 | [cpubench] | 263152 | 5803 | 204 |
| 20 | [cpubench] | 267080 | 5807 | 201 |
| 21 | [cpubench] | 267080 | 5811 | 201 |
| 18 | [cpubench] | 267080 | 6007 | 201 |
| 20 | [cpubench] | 267080 | 6008 | 201 |
| 21 | [cpubench] | 267080 | 6015 | 201 |
| 20 | [cpubench] | 267080 | 6209 | 201 |
| 18 | [cpubench] | 261869 | 6211 | 205 |
| 21 | [cpubench] | 267080 | 6216 | 201 |

`$ iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 29 | [cpubench] | 263152 | 10500 | 204 |
| 30 | [cpubench] | 263152 | 10501 | 204 |
| 27 | [cpubench] | 248533 | 10499 | 216 |
| 29 | [cpubench] | 259339 | 10704 | 207 | 
| 30 | [cpubench] | 259339 | 10705 | 207 |
| 27 | [cpubench] | 248533 | 10718 | 216 |
| 29 | [cpubench] | 267080 | 10914 | 201 |
| 30 | [cpubench] | 263152 | 10912 | 204 |
| 27 | [cpubench] | 252033 | 10934 | 213 |
| 29 | [cpubench] | 263152 | 11118 | 204 |
| 30 | [cpubench] | 261869 | 11119 | 205 |
| 27 | [cpubench] | 284038 | 11147 | 189 |
| 25 | [iobench]  | 1031   | 10514 | 993 |
| 25 | [iobench]  | 5785   | 11507 | 177 |
| 25 | [iobench]  | 5752   | 11684 | 178 |
| 25 | [iobench]  | 5785   | 11862 | 177 |

`$ cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  
  
| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 34 | [cpubench] | 679534 | 16071 | 79  |
| 34 | [cpubench] | 688246 | 16151 | 78  |
| 34 | [cpubench] | 756101 | 16230 | 71  |
| 34 | [cpubench] | 725448 | 16301 | 74  |
| 39 | [iobench]  | 2461   | 16074 | 416 |
| 36 | [iobench]  | 2285   | 16073 | 448 |
| 38 | [iobench]  | 2280   | 16073 | 449 |
| 36 | [iobench]  | 9142   | 16521 | 112 |
| 38 | [iobench]  | 6606   | 16524 | 155 |
| 39 | [iobench]  | 5417   | 16490 | 189 |
| 36 | [iobench]  | 8192   | 16633 | 125 |
| 39 | [iobench]  | 7641   | 16682 | 134 |
| 36 | [iobench]  | 8605   | 16758 | 119 |
| 38 | [iobench]  | 4675   | 16679 | 219 |
| 39 | [iobench]  | 6736   | 16817 | 152 |
| 38 | [iobench]  | 7529   | 16898 | 136 |

## Hardware 2:CPU Ryzen 3 3200G 3.6Ghz, RAM 32GB 3200Mhz
### Parámetros
- interval = 100000 
- N = 4 
- metrica_cpu = (total_iops * 100) / elapsed_ticks 
- metric_io = (total_cpu_kops * 1000) / elapsed_ticks 

`$ iobench 4 &`

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 4 | [iobench] | 3864 | 1730 | 265 |
| 4 | [iobench] | 3938 | 1995 | 260 |
| 4 | [iobench] | 3893 | 2256 | 263 |
| 4 | [iobench] | 3806 | 2519 | 269 |


`iobench 4 &; iobench 4 &; iobench 4 &` 

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 7 | [iobench] | 6522 | 3281 | 157 |
| 10| [iobench] | 5145 | 3283 | 199 |
| 9 | [iobench] | 3893 | 3283 | 263 |
| 7 | [iobench] | 5145 | 3438 | 199 |
| 9 | [iobench] | 5535 | 3546 | 185 |
| 10| [iobench] | 4162 | 3485 | 246 |
| 9 | [iobench] | 9061 | 3731 | 113 |
| 7 | [iobench] | 4357 | 3638 | 235 |
| 10| [iobench] | 4876 | 3733 | 210 |
| 7 | [iobench] | 4876 | 3845 | 239 |
| 9 | [iobench] | 4284 | 3873 | 210 |
| 10| [iobench] | 5720 | 3943 | 179 |


`cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 12 | [cpubench] | 409795 | 5104 | 131 |
| 12 | [cpubench] | 412947 | 5235 | 130 |
| 12 | [cpubench] | 416148 | 5366 | 129 |
| 12 | [cpubench] | 412947 | 5496 | 130 |

`$ cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 16 | [cpubench] | 138358 | 6692 | 388 |
| 18 | [cpubench] | 137649 | 6694 | 390 |
| 19 | [cpubench] | 136598 | 6695 | 393 |
| 16 | [cpubench] | 139800 | 7083 | 384 |
| 18 | [cpubench] | 138716 | 7084 | 387 |
| 19 | [cpubench] | 137649 | 7088 | 390 |
| 16 | [cpubench] | 139800 | 7470 | 384 |
| 18 | [cpubench] | 138716 | 7474 | 387 |
| 19 | [cpubench] | 137649 | 7478 | 390 |
| 16 | [cpubench] | 138716 | 7854 | 387 |
| 18 | [cpubench] | 139075 | 7861 | 386 |
| 19 | [cpubench] | 141271 | 7871 | 380 |


`iobench 4 &; cpubench 4 &; cpubench 4 &; cpubench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 26 | [cpubench] | 139436 | 10863 | 385 |
| 27 | [cpubench] | 136251 | 10864 | 394 |
| 24 | [cpubench] | 128428 | 10862 | 418 |
| 26 | [cpubench] | 138716 | 11251 | 387 |
| 27 | [cpubench] | 137649 | 11258 | 390 |
| 24 | [cpubench] | 128736 | 11280 | 417 |
| 26 | [cpubench] | 138716 | 11641 | 387 |
| 27 | [cpubench] | 138716 | 11651 | 387 |
| 24 | [cpubench] | 128736 | 11697 | 417 |
| 26 | [cpubench] | 139800 | 12031 | 384 |
| 27 | [cpubench] | 139436 | 12041 | 385 |
| 24 | [cpubench] | 156055 | 12117 | 344 |
| 22 | [iobench]  | 567    | 10877 | 1803|
| 22 | [iobench]  | 4112   | 12681 | 249 |
| 22 | [iobench]  | 4063   | 12931 | 252 |
| 22 | [iobench]  | 4047   | 13183 | 253 |

`cpubench 4 &; iobench 4 &; iobench 4 &; iobench 4 &`  

| PID | Tipo de Procesos | Métrica | Start Tick | Elapsed Ticks |
|-----|------------------|---------|------------|----------------|
| 30 | [cpubench] | 348592 | 15268 | 154 |
| 30 | [cpubench] | 375406 | 15422 | 143 |
| 30 | [cpubench] | 362724 | 15565 | 148 |
| 30 | [cpubench] | 365191 | 15714 | 147 |
| 32 | [iobench]  | 1514   | 15269 | 676 |
| 34 | [iobench]  | 1317   | 15272 | 777 |
| 35 | [iobench]  | 1301   | 15273 | 787 |
| 32 | [iobench]  | 4807   | 15945 | 213 |
| 35 | [iobench]  | 7211   | 16060 | 142 |
| 35 | [iobench]  | 9142   | 16202 | 112 |
| 32 | [iobench]  | 5688   | 16158 | 180 |
| 34 | [iobench]  | 3160   | 16049 | 324 |
| 34 | [iobench]  | 7699   | 16373 | 133 |
| 35 | [iobench]  | 4338   | 16316 | 236 |
| 32 | [iobench]  | 4762   | 16338 | 215 |
| 34 | [iobench]  | 3631   | 16508 | 282 |
