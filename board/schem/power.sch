EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L fpgaRelatedLib:LF33CDT U5
U 1 1 5E4C331E
P 5400 2750
F 0 "U5" H 5375 3175 50  0000 C CNN
F 1 "LF33CDT" H 5375 3084 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:TO-252-2" H 5100 3050 50  0001 C CNN
F 3 "" H 5100 3050 50  0001 C CNN
	1    5400 2750
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E4C4519
P 4700 2800
AR Path="/5E4C4519" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4C4519" Ref="C12"  Part="1" 
F 0 "C12" H 4815 2846 50  0000 L CNN
F 1 "0.1u" H 4815 2755 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4738 2650 50  0001 C CNN
F 3 "~" H 4700 2800 50  0001 C CNN
	1    4700 2800
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5E4C451F
P 6050 2800
AR Path="/5E4C451F" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4C451F" Ref="C14"  Part="1" 
F 0 "C14" H 6168 2846 50  0000 L CNN
F 1 "10u" H 6168 2755 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 6088 2650 50  0001 C CNN
F 3 "~" H 6050 2800 50  0001 C CNN
	1    6050 2800
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR044
U 1 1 5E4C4EBD
P 6050 2550
F 0 "#PWR044" H 6050 2400 50  0001 C CNN
F 1 "+3.3V" H 6065 2723 50  0000 C CNN
F 2 "" H 6050 2550 50  0001 C CNN
F 3 "" H 6050 2550 50  0001 C CNN
	1    6050 2550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR045
U 1 1 5E4C551E
P 6050 3150
F 0 "#PWR045" H 6050 2900 50  0001 C CNN
F 1 "GND" H 6055 2977 50  0000 C CNN
F 2 "" H 6050 3150 50  0001 C CNN
F 3 "" H 6050 3150 50  0001 C CNN
	1    6050 3150
	1    0    0    -1  
$EndComp
$Comp
L power:+36V #PWR033
U 1 1 5E4C5973
P 2300 2500
F 0 "#PWR033" H 2300 2350 50  0001 C CNN
F 1 "+36V" H 2315 2673 50  0000 C CNN
F 2 "" H 2300 2500 50  0001 C CNN
F 3 "" H 2300 2500 50  0001 C CNN
	1    2300 2500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR040
U 1 1 5E4C6206
P 3850 2500
F 0 "#PWR040" H 3850 2350 50  0001 C CNN
F 1 "+5V" H 3865 2673 50  0000 C CNN
F 2 "" H 3850 2500 50  0001 C CNN
F 3 "" H 3850 2500 50  0001 C CNN
	1    3850 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 2950 4700 3100
Wire Wire Line
	4700 3100 5400 3100
Wire Wire Line
	6050 3100 6050 3150
Wire Wire Line
	5400 3050 5400 3100
Connection ~ 5400 3100
Wire Wire Line
	5400 3100 6050 3100
Wire Wire Line
	6050 2950 6050 3100
Connection ~ 6050 3100
Wire Wire Line
	5800 2550 6050 2550
Wire Wire Line
	6050 2550 6050 2650
Wire Wire Line
	4700 2650 4700 2550
Wire Wire Line
	4700 2550 4950 2550
Connection ~ 6050 2550
$Comp
L fpgaRelatedLib:IFX27001TFV50 U4
U 1 1 5E4CDDC8
P 3200 2650
F 0 "U4" H 3175 3025 50  0000 C CNN
F 1 "IFX27001TFV50" H 3175 2934 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:TO-252-2" H 3200 2900 50  0001 C CNN
F 3 "" H 3200 2900 50  0001 C CNN
	1    3200 2650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E4D0E13
P 2300 2750
AR Path="/5E4D0E13" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4D0E13" Ref="C10"  Part="1" 
F 0 "C10" H 2415 2796 50  0000 L CNN
F 1 "0.1u" H 2415 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 2338 2600 50  0001 C CNN
F 3 "~" H 2300 2750 50  0001 C CNN
	1    2300 2750
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5E4D0E19
P 3850 2750
AR Path="/5E4D0E19" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4D0E19" Ref="C11"  Part="1" 
F 0 "C11" H 3968 2796 50  0000 L CNN
F 1 "10u" H 3968 2705 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 3888 2600 50  0001 C CNN
F 3 "~" H 3850 2750 50  0001 C CNN
	1    3850 2750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR041
U 1 1 5E4D0E25
P 3850 3100
F 0 "#PWR041" H 3850 2850 50  0001 C CNN
F 1 "GND" H 3855 2927 50  0000 C CNN
F 2 "" H 3850 3100 50  0001 C CNN
F 3 "" H 3850 3100 50  0001 C CNN
	1    3850 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 2900 2300 3050
Wire Wire Line
	3850 3050 3850 3100
Wire Wire Line
	3200 3000 3200 3050
Wire Wire Line
	3200 3050 3850 3050
Wire Wire Line
	3850 2900 3850 3050
Connection ~ 3850 3050
Wire Wire Line
	3600 2500 3850 2500
Wire Wire Line
	3850 2500 3850 2600
Wire Wire Line
	2300 2600 2300 2500
Connection ~ 3850 2500
$Comp
L power:+5V #PWR042
U 1 1 5E4D8B1D
P 4700 2550
F 0 "#PWR042" H 4700 2400 50  0001 C CNN
F 1 "+5V" H 4715 2723 50  0000 C CNN
F 2 "" H 4700 2550 50  0001 C CNN
F 3 "" H 4700 2550 50  0001 C CNN
	1    4700 2550
	1    0    0    -1  
$EndComp
Connection ~ 4700 2550
$Comp
L Device:LED D9
U 1 1 5E546CFA
P 2700 5200
F 0 "D9" H 2693 5416 50  0000 C CNN
F 1 "5V_led" H 2693 5325 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 2700 5200 50  0001 C CNN
F 3 "~" H 2700 5200 50  0001 C CNN
	1    2700 5200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E546D00
P 2700 4800
AR Path="/5E546D00" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5E546D00" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5E546D00" Ref="R45"  Part="1" 
F 0 "R45" H 2770 4846 50  0000 L CNN
F 1 "1k" H 2770 4755 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 2630 4800 50  0001 C CNN
F 3 "~" H 2700 4800 50  0001 C CNN
	1    2700 4800
	-1   0    0    1   
$EndComp
Wire Wire Line
	2700 4950 2700 5050
$Comp
L power:GND #PWR035
U 1 1 5E54A7C7
P 2700 5400
F 0 "#PWR035" H 2700 5150 50  0001 C CNN
F 1 "GND" H 2705 5227 50  0000 C CNN
F 2 "" H 2700 5400 50  0001 C CNN
F 3 "" H 2700 5400 50  0001 C CNN
	1    2700 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	2700 5350 2700 5400
Wire Wire Line
	2700 4650 2700 4550
$Comp
L Device:LED D10
U 1 1 5E54D623
P 3200 5200
F 0 "D10" H 3193 5416 50  0000 C CNN
F 1 "3.3V_led" H 3193 5325 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 3200 5200 50  0001 C CNN
F 3 "~" H 3200 5200 50  0001 C CNN
	1    3200 5200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E54D629
P 3200 4800
AR Path="/5E54D629" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5E54D629" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5E54D629" Ref="R46"  Part="1" 
F 0 "R46" H 3270 4846 50  0000 L CNN
F 1 "1k" H 3270 4755 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 3130 4800 50  0001 C CNN
F 3 "~" H 3200 4800 50  0001 C CNN
	1    3200 4800
	-1   0    0    1   
$EndComp
Wire Wire Line
	3200 4950 3200 5050
$Comp
L power:GND #PWR037
U 1 1 5E54D630
P 3200 5400
F 0 "#PWR037" H 3200 5150 50  0001 C CNN
F 1 "GND" H 3205 5227 50  0000 C CNN
F 2 "" H 3200 5400 50  0001 C CNN
F 3 "" H 3200 5400 50  0001 C CNN
	1    3200 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 5350 3200 5400
Wire Wire Line
	3200 4650 3200 4550
$Comp
L power:+5V #PWR034
U 1 1 5E54E2A7
P 2700 4550
F 0 "#PWR034" H 2700 4400 50  0001 C CNN
F 1 "+5V" H 2715 4723 50  0000 C CNN
F 2 "" H 2700 4550 50  0001 C CNN
F 3 "" H 2700 4550 50  0001 C CNN
	1    2700 4550
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR036
U 1 1 5E54FE90
P 3200 4550
F 0 "#PWR036" H 3200 4400 50  0001 C CNN
F 1 "+3.3V" H 3215 4723 50  0000 C CNN
F 2 "" H 3200 4550 50  0001 C CNN
F 3 "" H 3200 4550 50  0001 C CNN
	1    3200 4550
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J?
U 1 1 5E3DB971
P 1200 2950
AR Path="/5E3A0664/5E3DB971" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5E3DB971" Ref="J8"  Part="1" 
F 0 "J8" V 1072 3030 50  0000 L CNN
F 1 "POWER_IN" V 1163 3030 50  0000 L CNN
F 2 "Connector_Phoenix_MSTB:PhoenixContact_MSTBA_2,5_2-G-5,08_1x02_P5.08mm_Horizontal" H 1200 2950 50  0001 C CNN
F 3 "~" H 1200 2950 50  0001 C CNN
	1    1200 2950
	-1   0    0    1   
$EndComp
$Comp
L power:+36V #PWR056
U 1 1 5E3DFEAE
P 1400 2150
F 0 "#PWR056" H 1400 2000 50  0001 C CNN
F 1 "+36V" H 1415 2323 50  0000 C CNN
F 2 "" H 1400 2150 50  0001 C CNN
F 3 "" H 1400 2150 50  0001 C CNN
	1    1400 2150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR057
U 1 1 5E3E0B6E
P 1400 3050
F 0 "#PWR057" H 1400 2800 50  0001 C CNN
F 1 "GND" H 1405 2877 50  0000 C CNN
F 2 "" H 1400 3050 50  0001 C CNN
F 3 "" H 1400 3050 50  0001 C CNN
	1    1400 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 2250 1400 2150
Wire Wire Line
	1400 3050 1400 2950
$Comp
L Device:Fuse F2
U 1 1 5E403FCF
P 2550 2500
F 0 "F2" V 2353 2500 50  0000 C CNN
F 1 "3A" V 2444 2500 50  0000 C CNN
F 2 "Fuse:Fuse_2512_6332Metric" V 2480 2500 50  0001 C CNN
F 3 "~" H 2550 2500 50  0001 C CNN
	1    2550 2500
	0    1    1    0   
$EndComp
Wire Wire Line
	2750 2500 2700 2500
Wire Wire Line
	2400 2500 2300 2500
Connection ~ 2300 2500
Wire Wire Line
	2300 3050 3200 3050
Connection ~ 3200 3050
$Comp
L power:+36V #PWR088
U 1 1 5EA28155
P 7150 2500
F 0 "#PWR088" H 7150 2350 50  0001 C CNN
F 1 "+36V" H 7165 2673 50  0000 C CNN
F 2 "" H 7150 2500 50  0001 C CNN
F 3 "" H 7150 2500 50  0001 C CNN
	1    7150 2500
	1    0    0    -1  
$EndComp
$Comp
L fpgaRelatedLib:IFX27001TFV50 U8
U 1 1 5EA28161
P 8050 2650
F 0 "U8" H 8025 3025 50  0000 C CNN
F 1 "IFX27001TFV50" H 8025 2934 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:TO-252-2" H 8050 2900 50  0001 C CNN
F 3 "" H 8050 2900 50  0001 C CNN
	1    8050 2650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5EA28167
P 7150 2750
AR Path="/5EA28167" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EA28167" Ref="C17"  Part="1" 
F 0 "C17" H 7265 2796 50  0000 L CNN
F 1 "0.1u" H 7265 2705 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7188 2600 50  0001 C CNN
F 3 "~" H 7150 2750 50  0001 C CNN
	1    7150 2750
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5EA2816D
P 8700 2750
AR Path="/5EA2816D" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EA2816D" Ref="C18"  Part="1" 
F 0 "C18" H 8818 2796 50  0000 L CNN
F 1 "10u" H 8818 2705 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 8738 2600 50  0001 C CNN
F 3 "~" H 8700 2750 50  0001 C CNN
	1    8700 2750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR089
U 1 1 5EA28173
P 8700 3100
F 0 "#PWR089" H 8700 2850 50  0001 C CNN
F 1 "GND" H 8705 2927 50  0000 C CNN
F 2 "" H 8700 3100 50  0001 C CNN
F 3 "" H 8700 3100 50  0001 C CNN
	1    8700 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 2900 7150 3050
Wire Wire Line
	8700 3050 8700 3100
Wire Wire Line
	8050 3000 8050 3050
Wire Wire Line
	8050 3050 8700 3050
Wire Wire Line
	8700 2900 8700 3050
Connection ~ 8700 3050
Wire Wire Line
	8450 2500 8700 2500
Wire Wire Line
	8700 2500 8700 2600
Wire Wire Line
	7150 2600 7150 2500
Wire Wire Line
	7150 3050 8050 3050
Connection ~ 8050 3050
$Comp
L Connector:Conn_01x02_Male J?
U 1 1 5EA2C98B
P 9400 2650
AR Path="/5E3A0905/5EA2C98B" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5EA2C98B" Ref="J21"  Part="1" 
F 0 "J21" H 9508 2831 50  0000 C CNN
F 1 "lamp" H 9508 2740 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 9400 2650 50  0001 C CNN
F 3 "~" H 9400 2650 50  0001 C CNN
	1    9400 2650
	-1   0    0    1   
$EndComp
Wire Wire Line
	8700 2500 9200 2500
Wire Wire Line
	9200 2500 9200 2550
Connection ~ 8700 2500
Wire Wire Line
	9200 3050 9200 2650
$Comp
L Device:Fuse F1
U 1 1 5E3C35A6
P 1400 2600
F 0 "F1" V 1203 2600 50  0000 C CNN
F 1 "50A" V 1294 2600 50  0000 C CNN
F 2 "Fuse:Fuse_2512_6332Metric" V 1330 2600 50  0001 C CNN
F 3 "~" H 1400 2600 50  0001 C CNN
	1    1400 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 2350 1400 2450
Wire Wire Line
	1400 2750 1400 2850
Wire Wire Line
	8700 3050 9200 3050
$Comp
L Connector:Screw_Terminal_01x02 J?
U 1 1 5EA1D5AE
P 1200 2350
AR Path="/5E3A0664/5EA1D5AE" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5EA1D5AE" Ref="J20"  Part="1" 
F 0 "J20" V 1072 2430 50  0000 L CNN
F 1 "ON/OFF" V 1163 2430 50  0000 L CNN
F 2 "Connector_Phoenix_MSTB:PhoenixContact_MSTBA_2,5_2-G-5,08_1x02_P5.08mm_Horizontal" H 1200 2350 50  0001 C CNN
F 3 "~" H 1200 2350 50  0001 C CNN
	1    1200 2350
	-1   0    0    1   
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9B7
P 7100 4300
AR Path="/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9B7" Ref="C21"  Part="1" 
F 0 "C21" H 7215 4346 50  0000 L CNN
F 1 "0.1u" H 7215 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7138 4150 50  0001 C CNN
F 3 "~" H 7100 4300 50  0001 C CNN
	1    7100 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9BD
P 7500 4300
AR Path="/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9BD" Ref="C22"  Part="1" 
F 0 "C22" H 7615 4346 50  0000 L CNN
F 1 "0.1u" H 7615 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7538 4150 50  0001 C CNN
F 3 "~" H 7500 4300 50  0001 C CNN
	1    7500 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9C3
P 5750 4300
AR Path="/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9C3" Ref="C20"  Part="1" 
F 0 "C20" H 5865 4346 50  0000 L CNN
F 1 "0.1u" H 5865 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 5788 4150 50  0001 C CNN
F 3 "~" H 5750 4300 50  0001 C CNN
	1    5750 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9C9
P 5350 4300
AR Path="/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9C9" Ref="C19"  Part="1" 
F 0 "C19" H 5465 4346 50  0000 L CNN
F 1 "0.1u" H 5465 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 5388 4150 50  0001 C CNN
F 3 "~" H 5350 4300 50  0001 C CNN
	1    5350 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9CF
P 7900 4300
AR Path="/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9CF" Ref="C23"  Part="1" 
F 0 "C23" H 8015 4346 50  0000 L CNN
F 1 "0.1u" H 8015 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7938 4150 50  0001 C CNN
F 3 "~" H 7900 4300 50  0001 C CNN
	1    7900 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9D5
P 4950 4300
AR Path="/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9D5" Ref="C13"  Part="1" 
F 0 "C13" H 5065 4346 50  0000 L CNN
F 1 "0.1u" H 5065 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4988 4150 50  0001 C CNN
F 3 "~" H 4950 4300 50  0001 C CNN
	1    4950 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4450 5750 4450
Wire Wire Line
	5750 4450 6150 4450
Connection ~ 5750 4450
Wire Wire Line
	7100 4450 7500 4450
Wire Wire Line
	7500 4450 7900 4450
Connection ~ 7500 4450
Wire Wire Line
	7900 4150 7500 4150
Wire Wire Line
	7500 4150 7100 4150
Connection ~ 7500 4150
Wire Wire Line
	6150 4150 5750 4150
Wire Wire Line
	5350 4150 5750 4150
Connection ~ 5750 4150
Connection ~ 7900 4150
Connection ~ 7900 4450
Wire Wire Line
	4600 4450 4950 4450
Wire Wire Line
	4600 4150 4950 4150
Connection ~ 8300 4450
Wire Wire Line
	8300 4550 8300 4450
Connection ~ 8300 4150
Wire Wire Line
	8300 4150 8300 4050
Wire Wire Line
	8300 4150 7900 4150
Wire Wire Line
	7900 4450 8300 4450
$Comp
L Device:C C?
U 1 1 5F28A9F3
P 4600 4300
AR Path="/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9F3" Ref="C9"  Part="1" 
F 0 "C9" H 4715 4346 50  0000 L CNN
F 1 "0.1u" H 4715 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4638 4150 50  0001 C CNN
F 3 "~" H 4600 4300 50  0001 C CNN
	1    4600 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9F9
P 8300 4300
AR Path="/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9F9" Ref="C24"  Part="1" 
F 0 "C24" H 8415 4346 50  0000 L CNN
F 1 "0.1u" H 8415 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 8338 4150 50  0001 C CNN
F 3 "~" H 8300 4300 50  0001 C CNN
	1    8300 4300
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR?
U 1 1 5F28A9FF
P 8300 4050
AR Path="/5E3A0905/5F28A9FF" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5F28A9FF" Ref="#PWR0122"  Part="1" 
F 0 "#PWR0122" H 8300 3900 50  0001 C CNN
F 1 "+3.3V" H 8315 4223 50  0000 C CNN
F 2 "" H 8300 4050 50  0001 C CNN
F 3 "" H 8300 4050 50  0001 C CNN
	1    8300 4050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F28AA05
P 8300 4550
AR Path="/5E3A0905/5F28AA05" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5F28AA05" Ref="#PWR0123"  Part="1" 
F 0 "#PWR0123" H 8300 4300 50  0001 C CNN
F 1 "GND" H 8305 4377 50  0000 C CNN
F 2 "" H 8300 4550 50  0001 C CNN
F 3 "" H 8300 4550 50  0001 C CNN
	1    8300 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 4150 5350 4150
Connection ~ 4950 4150
Connection ~ 5350 4150
Wire Wire Line
	4950 4450 5350 4450
Connection ~ 4950 4450
Connection ~ 5350 4450
$Comp
L Device:C C?
U 1 1 5F5728C0
P 4700 1300
AR Path="/5F5728C0" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F5728C0" Ref="C8"  Part="1" 
F 0 "C8" H 4815 1346 50  0000 L CNN
F 1 "0.1u" H 4815 1255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4738 1150 50  0001 C CNN
F 3 "~" H 4700 1300 50  0001 C CNN
	1    4700 1300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0124
U 1 1 5F5728D2
P 6050 1650
F 0 "#PWR0124" H 6050 1400 50  0001 C CNN
F 1 "GND" H 6055 1477 50  0000 C CNN
F 2 "" H 6050 1650 50  0001 C CNN
F 3 "" H 6050 1650 50  0001 C CNN
	1    6050 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 1450 4700 1600
Wire Wire Line
	4700 1600 5400 1600
Wire Wire Line
	6050 1600 6050 1650
Connection ~ 5400 1600
Wire Wire Line
	5400 1600 6050 1600
Wire Wire Line
	6050 1450 6050 1600
Connection ~ 6050 1600
Wire Wire Line
	5800 1050 6050 1050
Wire Wire Line
	6050 1050 6050 1150
Wire Wire Line
	4700 1150 4700 1050
$Comp
L Device:C C?
U 1 1 5F5728F7
P 2300 1250
AR Path="/5F5728F7" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F5728F7" Ref="C6"  Part="1" 
F 0 "C6" H 2415 1296 50  0000 L CNN
F 1 "1u" H 2415 1205 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 2338 1100 50  0001 C CNN
F 3 "~" H 2300 1250 50  0001 C CNN
	1    2300 1250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0125
U 1 1 5F572903
P 3850 1600
F 0 "#PWR0125" H 3850 1350 50  0001 C CNN
F 1 "GND" H 3855 1427 50  0000 C CNN
F 2 "" H 3850 1600 50  0001 C CNN
F 3 "" H 3850 1600 50  0001 C CNN
	1    3850 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 1400 2300 1550
Wire Wire Line
	3850 1550 3850 1600
Wire Wire Line
	3200 1550 3850 1550
Wire Wire Line
	3850 1400 3850 1550
Connection ~ 3850 1550
Wire Wire Line
	3850 1000 3850 1100
Wire Wire Line
	2300 1100 2300 1000
Wire Wire Line
	2300 1550 3200 1550
Connection ~ 3200 1550
$Comp
L power:+2V5 #PWR0128
U 1 1 5F57E641
P 3850 950
F 0 "#PWR0128" H 3850 800 50  0001 C CNN
F 1 "+2V5" H 3865 1123 50  0000 C CNN
F 2 "" H 3850 950 50  0001 C CNN
F 3 "" H 3850 950 50  0001 C CNN
	1    3850 950 
	1    0    0    -1  
$EndComp
$Comp
L power:+1V2 #PWR0129
U 1 1 5F57EE0B
P 6050 1000
F 0 "#PWR0129" H 6050 850 50  0001 C CNN
F 1 "+1V2" H 6065 1173 50  0000 C CNN
F 2 "" H 6050 1000 50  0001 C CNN
F 3 "" H 6050 1000 50  0001 C CNN
	1    6050 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3850 1000 3850 950 
Connection ~ 3850 1000
Wire Wire Line
	6050 1050 6050 1000
Connection ~ 6050 1050
$Comp
L fpgaRelatedLib:AP2138 U10
U 1 1 5EBED04C
P 3200 1000
F 0 "U10" H 3200 1315 50  0000 C CNN
F 1 "AP2138" H 3200 1224 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 3400 750 50  0001 C CNN
F 3 "" H 3400 750 50  0001 C CNN
	1    3200 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	2300 1000 2850 1000
Wire Wire Line
	3200 1300 3200 1550
Wire Wire Line
	3550 1000 3850 1000
$Comp
L power:+3.3V #PWR0126
U 1 1 5EBFF6B6
P 2300 1000
F 0 "#PWR0126" H 2300 850 50  0001 C CNN
F 1 "+3.3V" H 2315 1173 50  0000 C CNN
F 2 "" H 2300 1000 50  0001 C CNN
F 3 "" H 2300 1000 50  0001 C CNN
	1    2300 1000
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR0127
U 1 1 5EC035DE
P 4700 1050
F 0 "#PWR0127" H 4700 900 50  0001 C CNN
F 1 "+3.3V" H 4715 1223 50  0000 C CNN
F 2 "" H 4700 1050 50  0001 C CNN
F 3 "" H 4700 1050 50  0001 C CNN
	1    4700 1050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5EC07CB6
P 3850 1250
AR Path="/5EC07CB6" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC07CB6" Ref="C7"  Part="1" 
F 0 "C7" H 3965 1296 50  0000 L CNN
F 1 "1u" H 3965 1205 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 3888 1100 50  0001 C CNN
F 3 "~" H 3850 1250 50  0001 C CNN
	1    3850 1250
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5EC12AAA
P 6050 1300
AR Path="/5EC12AAA" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC12AAA" Ref="C15"  Part="1" 
F 0 "C15" H 6168 1346 50  0000 L CNN
F 1 "10u" H 6168 1255 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 6088 1150 50  0001 C CNN
F 3 "~" H 6050 1300 50  0001 C CNN
	1    6050 1300
	1    0    0    -1  
$EndComp
$Comp
L fpgaRelatedLib:LD1117 U11
U 1 1 5EC1499F
P 5400 1100
F 0 "U11" H 5400 1465 50  0000 C CNN
F 1 "LD1117" H 5400 1374 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-223" H 5600 900 50  0001 C CNN
F 3 "" H 5600 900 50  0001 C CNN
	1    5400 1100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 1050 5000 1050
Wire Wire Line
	5400 1350 5400 1600
$Comp
L Device:Fuse F3
U 1 1 5EC1ED3F
P 7400 2500
F 0 "F3" V 7203 2500 50  0000 C CNN
F 1 "3A" V 7294 2500 50  0000 C CNN
F 2 "Fuse:Fuse_2512_6332Metric" V 7330 2500 50  0001 C CNN
F 3 "~" H 7400 2500 50  0001 C CNN
	1    7400 2500
	0    1    1    0   
$EndComp
Wire Wire Line
	7550 2500 7600 2500
Connection ~ 7600 2500
Wire Wire Line
	7600 2500 7650 2500
Wire Wire Line
	7250 2500 7150 2500
Connection ~ 7150 2500
$Comp
L Device:LED D14
U 1 1 5EC26486
P 3700 5200
F 0 "D14" H 3693 5416 50  0000 C CNN
F 1 "3.3V_led" H 3693 5325 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 3700 5200 50  0001 C CNN
F 3 "~" H 3700 5200 50  0001 C CNN
	1    3700 5200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5EC2648C
P 3700 4800
AR Path="/5EC2648C" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5EC2648C" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5EC2648C" Ref="R47"  Part="1" 
F 0 "R47" H 3770 4846 50  0000 L CNN
F 1 "1k" H 3770 4755 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 3630 4800 50  0001 C CNN
F 3 "~" H 3700 4800 50  0001 C CNN
	1    3700 4800
	-1   0    0    1   
$EndComp
Wire Wire Line
	3700 4950 3700 5050
$Comp
L power:GND #PWR0130
U 1 1 5EC26493
P 3700 5400
F 0 "#PWR0130" H 3700 5150 50  0001 C CNN
F 1 "GND" H 3705 5227 50  0000 C CNN
F 2 "" H 3700 5400 50  0001 C CNN
F 3 "" H 3700 5400 50  0001 C CNN
	1    3700 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 5350 3700 5400
Wire Wire Line
	3700 4650 3700 4550
$Comp
L Device:LED D15
U 1 1 5EC2999E
P 4150 5200
F 0 "D15" H 4143 5416 50  0000 C CNN
F 1 "3.3V_led" H 4143 5325 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 4150 5200 50  0001 C CNN
F 3 "~" H 4150 5200 50  0001 C CNN
	1    4150 5200
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5EC299A4
P 4150 4800
AR Path="/5EC299A4" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5EC299A4" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5EC299A4" Ref="R48"  Part="1" 
F 0 "R48" H 4220 4846 50  0000 L CNN
F 1 "1k" H 4220 4755 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 4080 4800 50  0001 C CNN
F 3 "~" H 4150 4800 50  0001 C CNN
	1    4150 4800
	-1   0    0    1   
$EndComp
Wire Wire Line
	4150 4950 4150 5050
$Comp
L power:GND #PWR0131
U 1 1 5EC299AB
P 4150 5400
F 0 "#PWR0131" H 4150 5150 50  0001 C CNN
F 1 "GND" H 4155 5227 50  0000 C CNN
F 2 "" H 4150 5400 50  0001 C CNN
F 3 "" H 4150 5400 50  0001 C CNN
	1    4150 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 5350 4150 5400
Wire Wire Line
	4150 4650 4150 4550
$Comp
L power:+2V5 #PWR0132
U 1 1 5EC2C662
P 3700 4550
F 0 "#PWR0132" H 3700 4400 50  0001 C CNN
F 1 "+2V5" H 3715 4723 50  0000 C CNN
F 2 "" H 3700 4550 50  0001 C CNN
F 3 "" H 3700 4550 50  0001 C CNN
	1    3700 4550
	1    0    0    -1  
$EndComp
$Comp
L power:+1V2 #PWR0133
U 1 1 5EC2F6D9
P 4150 4550
F 0 "#PWR0133" H 4150 4400 50  0001 C CNN
F 1 "+1V2" H 4165 4723 50  0000 C CNN
F 2 "" H 4150 4550 50  0001 C CNN
F 3 "" H 4150 4550 50  0001 C CNN
	1    4150 4550
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5ECB3F0E
P 6550 4300
AR Path="/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5ECB3F0E" Ref="C26"  Part="1" 
F 0 "C26" H 6665 4346 50  0000 L CNN
F 1 "0.1u" H 6665 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6588 4150 50  0001 C CNN
F 3 "~" H 6550 4300 50  0001 C CNN
	1    6550 4300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5ECB3F14
P 6150 4300
AR Path="/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5ECB3F14" Ref="C25"  Part="1" 
F 0 "C25" H 6265 4346 50  0000 L CNN
F 1 "0.1u" H 6265 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6188 4150 50  0001 C CNN
F 3 "~" H 6150 4300 50  0001 C CNN
	1    6150 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4150 6150 4150
Connection ~ 6150 4150
Wire Wire Line
	6150 4450 6550 4450
Connection ~ 6150 4450
$Comp
L power:+1V2 #PWR0134
U 1 1 5ECBBECB
P 6550 4100
F 0 "#PWR0134" H 6550 3950 50  0001 C CNN
F 1 "+1V2" H 6565 4273 50  0000 C CNN
F 2 "" H 6550 4100 50  0001 C CNN
F 3 "" H 6550 4100 50  0001 C CNN
	1    6550 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4150 6550 4100
Connection ~ 6550 4150
Wire Wire Line
	6550 4550 6550 4450
$Comp
L power:GND #PWR?
U 1 1 5ECC17E4
P 6550 4550
AR Path="/5E3A0905/5ECC17E4" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5ECC17E4" Ref="#PWR0135"  Part="1" 
F 0 "#PWR0135" H 6550 4300 50  0001 C CNN
F 1 "GND" H 6555 4377 50  0000 C CNN
F 2 "" H 6550 4550 50  0001 C CNN
F 3 "" H 6550 4550 50  0001 C CNN
	1    6550 4550
	1    0    0    -1  
$EndComp
$EndSCHEMATC
