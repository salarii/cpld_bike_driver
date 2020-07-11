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
P 4700 3000
F 0 "U5" H 4675 3425 50  0000 C CNN
F 1 "LF33CDT" H 4675 3334 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:TO-252-2" H 4400 3300 50  0001 C CNN
F 3 "" H 4400 3300 50  0001 C CNN
	1    4700 3000
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5E4C4519
P 4000 3050
AR Path="/5E4C4519" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4C4519" Ref="C12"  Part="1" 
F 0 "C12" H 4115 3096 50  0000 L CNN
F 1 "0.1u" H 4115 3005 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4038 2900 50  0001 C CNN
F 3 "~" H 4000 3050 50  0001 C CNN
	1    4000 3050
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5E4C451F
P 5350 3050
AR Path="/5E4C451F" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5E4C451F" Ref="C14"  Part="1" 
F 0 "C14" H 5468 3096 50  0000 L CNN
F 1 "10u" H 5468 3005 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 5388 2900 50  0001 C CNN
F 3 "~" H 5350 3050 50  0001 C CNN
	1    5350 3050
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR044
U 1 1 5E4C4EBD
P 5350 2800
F 0 "#PWR044" H 5350 2650 50  0001 C CNN
F 1 "+3.3V" H 5365 2973 50  0000 C CNN
F 2 "" H 5350 2800 50  0001 C CNN
F 3 "" H 5350 2800 50  0001 C CNN
	1    5350 2800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR045
U 1 1 5E4C551E
P 5350 3400
F 0 "#PWR045" H 5350 3150 50  0001 C CNN
F 1 "GND" H 5355 3227 50  0000 C CNN
F 2 "" H 5350 3400 50  0001 C CNN
F 3 "" H 5350 3400 50  0001 C CNN
	1    5350 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3200 4000 3350
Wire Wire Line
	4000 3350 4700 3350
Wire Wire Line
	5350 3350 5350 3400
Wire Wire Line
	4700 3300 4700 3350
Connection ~ 4700 3350
Wire Wire Line
	4700 3350 5350 3350
Wire Wire Line
	5350 3200 5350 3350
Connection ~ 5350 3350
Wire Wire Line
	5100 2800 5350 2800
Wire Wire Line
	5350 2800 5350 2900
Wire Wire Line
	4000 2900 4000 2800
Wire Wire Line
	4000 2800 4250 2800
Connection ~ 5350 2800
$Comp
L Device:LED D9
U 1 1 5E546CFA
P 4950 5250
F 0 "D9" H 4943 5466 50  0000 C CNN
F 1 "5V_led" H 4943 5375 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 4950 5250 50  0001 C CNN
F 3 "~" H 4950 5250 50  0001 C CNN
	1    4950 5250
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E546D00
P 4950 4850
AR Path="/5E546D00" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5E546D00" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5E546D00" Ref="R45"  Part="1" 
F 0 "R45" H 5020 4896 50  0000 L CNN
F 1 "1k" H 5020 4805 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 4880 4850 50  0001 C CNN
F 3 "~" H 4950 4850 50  0001 C CNN
	1    4950 4850
	-1   0    0    1   
$EndComp
Wire Wire Line
	4950 5000 4950 5100
$Comp
L power:GND #PWR035
U 1 1 5E54A7C7
P 4950 5450
F 0 "#PWR035" H 4950 5200 50  0001 C CNN
F 1 "GND" H 4955 5277 50  0000 C CNN
F 2 "" H 4950 5450 50  0001 C CNN
F 3 "" H 4950 5450 50  0001 C CNN
	1    4950 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 5400 4950 5450
Wire Wire Line
	4950 4700 4950 4600
$Comp
L Device:LED D10
U 1 1 5E54D623
P 5450 5250
F 0 "D10" H 5443 5466 50  0000 C CNN
F 1 "3.3V_led" H 5443 5375 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 5450 5250 50  0001 C CNN
F 3 "~" H 5450 5250 50  0001 C CNN
	1    5450 5250
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5E54D629
P 5450 4850
AR Path="/5E54D629" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5E54D629" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5E54D629" Ref="R46"  Part="1" 
F 0 "R46" H 5520 4896 50  0000 L CNN
F 1 "1k" H 5520 4805 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 5380 4850 50  0001 C CNN
F 3 "~" H 5450 4850 50  0001 C CNN
	1    5450 4850
	-1   0    0    1   
$EndComp
Wire Wire Line
	5450 5000 5450 5100
$Comp
L power:GND #PWR037
U 1 1 5E54D630
P 5450 5450
F 0 "#PWR037" H 5450 5200 50  0001 C CNN
F 1 "GND" H 5455 5277 50  0000 C CNN
F 2 "" H 5450 5450 50  0001 C CNN
F 3 "" H 5450 5450 50  0001 C CNN
	1    5450 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 5400 5450 5450
Wire Wire Line
	5450 4700 5450 4600
$Comp
L power:+5V #PWR034
U 1 1 5E54E2A7
P 4950 4600
F 0 "#PWR034" H 4950 4450 50  0001 C CNN
F 1 "+5V" H 4965 4773 50  0000 C CNN
F 2 "" H 4950 4600 50  0001 C CNN
F 3 "" H 4950 4600 50  0001 C CNN
	1    4950 4600
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR036
U 1 1 5E54FE90
P 5450 4600
F 0 "#PWR036" H 5450 4450 50  0001 C CNN
F 1 "+3.3V" H 5465 4773 50  0000 C CNN
F 2 "" H 5450 4600 50  0001 C CNN
F 3 "" H 5450 4600 50  0001 C CNN
	1    5450 4600
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 J?
U 1 1 5E3DB971
P 1150 2050
AR Path="/5E3A0664/5E3DB971" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5E3DB971" Ref="J8"  Part="1" 
F 0 "J8" V 1022 2130 50  0000 L CNN
F 1 "POWER_IN" V 1113 2130 50  0000 L CNN
F 2 "Connector_Phoenix_MSTB:PhoenixContact_MSTBVA_2,5_2-G-5,08_1x02_P5.08mm_Vertical" H 1150 2050 50  0001 C CNN
F 3 "~" H 1150 2050 50  0001 C CNN
	1    1150 2050
	-1   0    0    1   
$EndComp
$Comp
L power:+36V #PWR056
U 1 1 5E3DFEAE
P 1350 1450
F 0 "#PWR056" H 1350 1300 50  0001 C CNN
F 1 "+36V" H 1365 1623 50  0000 C CNN
F 2 "" H 1350 1450 50  0001 C CNN
F 3 "" H 1350 1450 50  0001 C CNN
	1    1350 1450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR057
U 1 1 5E3E0B6E
P 1350 2150
F 0 "#PWR057" H 1350 1900 50  0001 C CNN
F 1 "GND" H 1355 1977 50  0000 C CNN
F 2 "" H 1350 2150 50  0001 C CNN
F 3 "" H 1350 2150 50  0001 C CNN
	1    1350 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	1350 2150 1350 2050
$Comp
L Connector:Conn_01x02_Male J?
U 1 1 5EA2C98B
P 10300 2950
AR Path="/5E3A0905/5EA2C98B" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5EA2C98B" Ref="J21"  Part="1" 
F 0 "J21" H 10408 3131 50  0000 C CNN
F 1 "lamp" H 10408 3040 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_1x02_P2.54mm_Vertical" H 10300 2950 50  0001 C CNN
F 3 "~" H 10300 2950 50  0001 C CNN
	1    10300 2950
	-1   0    0    1   
$EndComp
Wire Wire Line
	10100 2800 10100 2850
$Comp
L Device:Fuse F1
U 1 1 5E3C35A6
P 1350 1700
F 0 "F1" V 1153 1700 50  0000 C CNN
F 1 "50A" V 1244 1700 50  0000 C CNN
F 2 "Fuse:Fuse_2512_6332Metric" V 1280 1700 50  0001 C CNN
F 3 "~" H 1350 1700 50  0001 C CNN
	1    1350 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	1350 1850 1350 1950
$Comp
L Connector:Screw_Terminal_01x02 J?
U 1 1 5EA1D5AE
P 2900 3050
AR Path="/5E3A0664/5EA1D5AE" Ref="J?"  Part="1" 
AR Path="/5E4C3088/5EA1D5AE" Ref="J20"  Part="1" 
F 0 "J20" V 2772 3130 50  0000 L CNN
F 1 "ON/OFF" V 2863 3130 50  0000 L CNN
F 2 "Connector_Phoenix_MSTB:PhoenixContact_MSTBVA_2,5_2-G-5,08_1x02_P5.08mm_Vertical" H 2900 3050 50  0001 C CNN
F 3 "~" H 2900 3050 50  0001 C CNN
	1    2900 3050
	0    1    1    0   
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9B7
P 8350 2900
AR Path="/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9B7" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9B7" Ref="C21"  Part="1" 
F 0 "C21" H 8465 2946 50  0000 L CNN
F 1 "0.1u" H 8465 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 8388 2750 50  0001 C CNN
F 3 "~" H 8350 2900 50  0001 C CNN
	1    8350 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9BD
P 8750 2900
AR Path="/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9BD" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9BD" Ref="C22"  Part="1" 
F 0 "C22" H 8865 2946 50  0000 L CNN
F 1 "0.1u" H 8865 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 8788 2750 50  0001 C CNN
F 3 "~" H 8750 2900 50  0001 C CNN
	1    8750 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9C3
P 7000 2900
AR Path="/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9C3" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9C3" Ref="C20"  Part="1" 
F 0 "C20" H 7115 2946 50  0000 L CNN
F 1 "0.1u" H 7115 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7038 2750 50  0001 C CNN
F 3 "~" H 7000 2900 50  0001 C CNN
	1    7000 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9C9
P 6600 2900
AR Path="/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9C9" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9C9" Ref="C19"  Part="1" 
F 0 "C19" H 6715 2946 50  0000 L CNN
F 1 "0.1u" H 6715 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6638 2750 50  0001 C CNN
F 3 "~" H 6600 2900 50  0001 C CNN
	1    6600 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9CF
P 9150 2900
AR Path="/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9CF" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9CF" Ref="C23"  Part="1" 
F 0 "C23" H 9265 2946 50  0000 L CNN
F 1 "0.1u" H 9265 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 9188 2750 50  0001 C CNN
F 3 "~" H 9150 2900 50  0001 C CNN
	1    9150 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9D5
P 6200 2900
AR Path="/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9D5" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9D5" Ref="C13"  Part="1" 
F 0 "C13" H 6315 2946 50  0000 L CNN
F 1 "0.1u" H 6315 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6238 2750 50  0001 C CNN
F 3 "~" H 6200 2900 50  0001 C CNN
	1    6200 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6600 3050 7000 3050
Wire Wire Line
	7000 3050 7400 3050
Connection ~ 7000 3050
Wire Wire Line
	8350 3050 8750 3050
Wire Wire Line
	8750 3050 9150 3050
Connection ~ 8750 3050
Wire Wire Line
	9150 2750 8750 2750
Wire Wire Line
	8750 2750 8350 2750
Connection ~ 8750 2750
Wire Wire Line
	7400 2750 7000 2750
Wire Wire Line
	6600 2750 7000 2750
Connection ~ 7000 2750
Connection ~ 9150 2750
Connection ~ 9150 3050
Wire Wire Line
	5850 3050 6200 3050
Wire Wire Line
	5850 2750 6200 2750
Connection ~ 9550 3050
Wire Wire Line
	9550 3150 9550 3050
Connection ~ 9550 2750
Wire Wire Line
	9550 2750 9550 2650
Wire Wire Line
	9550 2750 9150 2750
Wire Wire Line
	9150 3050 9550 3050
$Comp
L Device:C C?
U 1 1 5F28A9F3
P 5850 2900
AR Path="/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9F3" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9F3" Ref="C9"  Part="1" 
F 0 "C9" H 5965 2946 50  0000 L CNN
F 1 "0.1u" H 5965 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 5888 2750 50  0001 C CNN
F 3 "~" H 5850 2900 50  0001 C CNN
	1    5850 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F28A9F9
P 9550 2900
AR Path="/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5F28A9F9" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F28A9F9" Ref="C24"  Part="1" 
F 0 "C24" H 9665 2946 50  0000 L CNN
F 1 "0.1u" H 9665 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 9588 2750 50  0001 C CNN
F 3 "~" H 9550 2900 50  0001 C CNN
	1    9550 2900
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR?
U 1 1 5F28A9FF
P 9550 2650
AR Path="/5E3A0905/5F28A9FF" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5F28A9FF" Ref="#PWR0122"  Part="1" 
F 0 "#PWR0122" H 9550 2500 50  0001 C CNN
F 1 "+3.3V" H 9565 2823 50  0000 C CNN
F 2 "" H 9550 2650 50  0001 C CNN
F 3 "" H 9550 2650 50  0001 C CNN
	1    9550 2650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F28AA05
P 9550 3150
AR Path="/5E3A0905/5F28AA05" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5F28AA05" Ref="#PWR0123"  Part="1" 
F 0 "#PWR0123" H 9550 2900 50  0001 C CNN
F 1 "GND" H 9555 2977 50  0000 C CNN
F 2 "" H 9550 3150 50  0001 C CNN
F 3 "" H 9550 3150 50  0001 C CNN
	1    9550 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 2750 6600 2750
Connection ~ 6200 2750
Connection ~ 6600 2750
Wire Wire Line
	6200 3050 6600 3050
Connection ~ 6200 3050
Connection ~ 6600 3050
$Comp
L Device:C C?
U 1 1 5F5728C0
P 6300 1550
AR Path="/5F5728C0" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F5728C0" Ref="C8"  Part="1" 
F 0 "C8" H 6415 1596 50  0000 L CNN
F 1 "0.1u" H 6415 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 6338 1400 50  0001 C CNN
F 3 "~" H 6300 1550 50  0001 C CNN
	1    6300 1550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0124
U 1 1 5F5728D2
P 7650 1900
F 0 "#PWR0124" H 7650 1650 50  0001 C CNN
F 1 "GND" H 7655 1727 50  0000 C CNN
F 2 "" H 7650 1900 50  0001 C CNN
F 3 "" H 7650 1900 50  0001 C CNN
	1    7650 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 1700 6300 1850
Wire Wire Line
	6300 1850 7000 1850
Wire Wire Line
	7650 1850 7650 1900
Connection ~ 7000 1850
Wire Wire Line
	7000 1850 7450 1850
Wire Wire Line
	7650 1700 7650 1850
Connection ~ 7650 1850
Wire Wire Line
	7400 1300 7450 1300
Wire Wire Line
	7650 1300 7650 1400
Wire Wire Line
	6300 1400 6300 1300
$Comp
L Device:C C?
U 1 1 5F5728F7
P 3900 1500
AR Path="/5F5728F7" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5F5728F7" Ref="C6"  Part="1" 
F 0 "C6" H 4015 1546 50  0000 L CNN
F 1 "1u" H 4015 1455 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 3938 1350 50  0001 C CNN
F 3 "~" H 3900 1500 50  0001 C CNN
	1    3900 1500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0125
U 1 1 5F572903
P 5450 1850
F 0 "#PWR0125" H 5450 1600 50  0001 C CNN
F 1 "GND" H 5455 1677 50  0000 C CNN
F 2 "" H 5450 1850 50  0001 C CNN
F 3 "" H 5450 1850 50  0001 C CNN
	1    5450 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3900 1650 3900 1800
Wire Wire Line
	5450 1800 5450 1850
Wire Wire Line
	4800 1800 5450 1800
Wire Wire Line
	5450 1650 5450 1800
Connection ~ 5450 1800
Wire Wire Line
	5450 1250 5450 1350
Wire Wire Line
	3900 1350 3900 1250
Wire Wire Line
	3900 1800 4800 1800
Connection ~ 4800 1800
$Comp
L power:+2V5 #PWR0128
U 1 1 5F57E641
P 5450 1200
F 0 "#PWR0128" H 5450 1050 50  0001 C CNN
F 1 "+2V5" H 5465 1373 50  0000 C CNN
F 2 "" H 5450 1200 50  0001 C CNN
F 3 "" H 5450 1200 50  0001 C CNN
	1    5450 1200
	1    0    0    -1  
$EndComp
$Comp
L power:+1V2 #PWR0129
U 1 1 5F57EE0B
P 7650 1250
F 0 "#PWR0129" H 7650 1100 50  0001 C CNN
F 1 "+1V2" H 7665 1423 50  0000 C CNN
F 2 "" H 7650 1250 50  0001 C CNN
F 3 "" H 7650 1250 50  0001 C CNN
	1    7650 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 1250 5450 1200
Connection ~ 5450 1250
Wire Wire Line
	7650 1300 7650 1250
Connection ~ 7650 1300
$Comp
L fpgaRelatedLib:AP2138 U10
U 1 1 5EBED04C
P 4800 1250
F 0 "U10" H 4800 1565 50  0000 C CNN
F 1 "AP2138" H 4800 1474 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 5000 1000 50  0001 C CNN
F 3 "" H 5000 1000 50  0001 C CNN
	1    4800 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3900 1250 4450 1250
Wire Wire Line
	4800 1550 4800 1800
Wire Wire Line
	5150 1250 5450 1250
$Comp
L power:+3.3V #PWR0126
U 1 1 5EBFF6B6
P 3900 1250
F 0 "#PWR0126" H 3900 1100 50  0001 C CNN
F 1 "+3.3V" H 3915 1423 50  0000 C CNN
F 2 "" H 3900 1250 50  0001 C CNN
F 3 "" H 3900 1250 50  0001 C CNN
	1    3900 1250
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR0127
U 1 1 5EC035DE
P 6300 1300
F 0 "#PWR0127" H 6300 1150 50  0001 C CNN
F 1 "+3.3V" H 6315 1473 50  0000 C CNN
F 2 "" H 6300 1300 50  0001 C CNN
F 3 "" H 6300 1300 50  0001 C CNN
	1    6300 1300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5EC07CB6
P 5450 1500
AR Path="/5EC07CB6" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC07CB6" Ref="C7"  Part="1" 
F 0 "C7" H 5565 1546 50  0000 L CNN
F 1 "1u" H 5565 1455 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 5488 1350 50  0001 C CNN
F 3 "~" H 5450 1500 50  0001 C CNN
	1    5450 1500
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5EC12AAA
P 7650 1550
AR Path="/5EC12AAA" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC12AAA" Ref="C15"  Part="1" 
F 0 "C15" H 7768 1596 50  0000 L CNN
F 1 "10u" H 7768 1505 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 7688 1400 50  0001 C CNN
F 3 "~" H 7650 1550 50  0001 C CNN
	1    7650 1550
	1    0    0    -1  
$EndComp
$Comp
L fpgaRelatedLib:LD1117 U11
U 1 1 5EC1499F
P 7000 1350
F 0 "U11" H 7000 1715 50  0000 C CNN
F 1 "LD1117" H 7000 1624 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-223" H 7200 1150 50  0001 C CNN
F 3 "" H 7200 1150 50  0001 C CNN
	1    7000 1350
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 1300 6600 1300
Wire Wire Line
	7000 1600 7000 1850
$Comp
L Device:LED D14
U 1 1 5EC26486
P 5950 5250
F 0 "D14" H 5943 5466 50  0000 C CNN
F 1 "2.5V_led" H 5943 5375 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 5950 5250 50  0001 C CNN
F 3 "~" H 5950 5250 50  0001 C CNN
	1    5950 5250
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5EC2648C
P 5950 4850
AR Path="/5EC2648C" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5EC2648C" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5EC2648C" Ref="R47"  Part="1" 
F 0 "R47" H 6020 4896 50  0000 L CNN
F 1 "1k" H 6020 4805 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 5880 4850 50  0001 C CNN
F 3 "~" H 5950 4850 50  0001 C CNN
	1    5950 4850
	-1   0    0    1   
$EndComp
Wire Wire Line
	5950 5000 5950 5100
$Comp
L power:GND #PWR0130
U 1 1 5EC26493
P 5950 5450
F 0 "#PWR0130" H 5950 5200 50  0001 C CNN
F 1 "GND" H 5955 5277 50  0000 C CNN
F 2 "" H 5950 5450 50  0001 C CNN
F 3 "" H 5950 5450 50  0001 C CNN
	1    5950 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5950 5400 5950 5450
Wire Wire Line
	5950 4700 5950 4600
$Comp
L Device:LED D15
U 1 1 5EC2999E
P 7000 4700
F 0 "D15" H 6993 4916 50  0000 C CNN
F 1 "1.2V_led" H 6993 4825 50  0000 C CNN
F 2 "LED_SMD:LED_1206_3216Metric" H 7000 4700 50  0001 C CNN
F 3 "~" H 7000 4700 50  0001 C CNN
	1    7000 4700
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R?
U 1 1 5EC299A4
P 7000 4250
AR Path="/5EC299A4" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5EC299A4" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5EC299A4" Ref="R48"  Part="1" 
F 0 "R48" H 7070 4296 50  0000 L CNN
F 1 "1k" H 7070 4205 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 6930 4250 50  0001 C CNN
F 3 "~" H 7000 4250 50  0001 C CNN
	1    7000 4250
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR0131
U 1 1 5EC299AB
P 7000 5550
F 0 "#PWR0131" H 7000 5300 50  0001 C CNN
F 1 "GND" H 7005 5377 50  0000 C CNN
F 2 "" H 7000 5550 50  0001 C CNN
F 3 "" H 7000 5550 50  0001 C CNN
	1    7000 5550
	1    0    0    -1  
$EndComp
$Comp
L power:+2V5 #PWR0132
U 1 1 5EC2C662
P 5950 4600
F 0 "#PWR0132" H 5950 4450 50  0001 C CNN
F 1 "+2V5" H 5965 4773 50  0000 C CNN
F 2 "" H 5950 4600 50  0001 C CNN
F 3 "" H 5950 4600 50  0001 C CNN
	1    5950 4600
	1    0    0    -1  
$EndComp
$Comp
L power:+1V2 #PWR0133
U 1 1 5EC2F6D9
P 6550 4650
F 0 "#PWR0133" H 6550 4500 50  0001 C CNN
F 1 "+1V2" H 6565 4823 50  0000 C CNN
F 2 "" H 6550 4650 50  0001 C CNN
F 3 "" H 6550 4650 50  0001 C CNN
	1    6550 4650
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5ECB3F0E
P 7800 2900
AR Path="/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5ECB3F0E" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5ECB3F0E" Ref="C26"  Part="1" 
F 0 "C26" H 7915 2946 50  0000 L CNN
F 1 "0.1u" H 7915 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7838 2750 50  0001 C CNN
F 3 "~" H 7800 2900 50  0001 C CNN
	1    7800 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5ECB3F14
P 7400 2900
AR Path="/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E3A0664/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E3A0905/5ECB3F14" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5ECB3F14" Ref="C25"  Part="1" 
F 0 "C25" H 7515 2946 50  0000 L CNN
F 1 "0.1u" H 7515 2855 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 7438 2750 50  0001 C CNN
F 3 "~" H 7400 2900 50  0001 C CNN
	1    7400 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 2750 7400 2750
Connection ~ 7400 2750
Wire Wire Line
	7400 3050 7800 3050
Connection ~ 7400 3050
$Comp
L power:+1V2 #PWR0134
U 1 1 5ECBBECB
P 7800 2700
F 0 "#PWR0134" H 7800 2550 50  0001 C CNN
F 1 "+1V2" H 7815 2873 50  0000 C CNN
F 2 "" H 7800 2700 50  0001 C CNN
F 3 "" H 7800 2700 50  0001 C CNN
	1    7800 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 2750 7800 2700
Connection ~ 7800 2750
Wire Wire Line
	7800 3150 7800 3050
$Comp
L power:GND #PWR?
U 1 1 5ECC17E4
P 7800 3150
AR Path="/5E3A0905/5ECC17E4" Ref="#PWR?"  Part="1" 
AR Path="/5E4C3088/5ECC17E4" Ref="#PWR0135"  Part="1" 
F 0 "#PWR0135" H 7800 2900 50  0001 C CNN
F 1 "GND" H 7805 2977 50  0000 C CNN
F 2 "" H 7800 3150 50  0001 C CNN
F 3 "" H 7800 3150 50  0001 C CNN
	1    7800 3150
	1    0    0    -1  
$EndComp
Connection ~ 3900 1250
Connection ~ 6300 1300
Connection ~ 7800 3050
$Comp
L fpgaRelatedLib:A8498 U8
U 1 1 5EC7139C
P 2050 4100
F 0 "U8" H 2025 4515 50  0000 C CNN
F 1 "A8498" H 2025 4424 50  0000 C CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 2250 3650 50  0001 C CNN
F 3 "" H 2250 3650 50  0001 C CNN
	1    2050 4100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5EC7648C
P 1450 3650
AR Path="/5EC7648C" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC7648C" Ref="C10"  Part="1" 
F 0 "C10" H 1565 3696 50  0000 L CNN
F 1 "0.01u" H 1565 3605 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 1488 3500 50  0001 C CNN
F 3 "~" H 1450 3650 50  0001 C CNN
	1    1450 3650
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C?
U 1 1 5EC78F75
P 2950 3500
AR Path="/5EC78F75" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC78F75" Ref="C11"  Part="1" 
F 0 "C11" H 3068 3546 50  0000 L CNN
F 1 "220u" H 3068 3455 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 2988 3350 50  0001 C CNN
F 3 "~" H 2950 3500 50  0001 C CNN
	1    2950 3500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR039
U 1 1 5EC7B7CF
P 2450 5300
F 0 "#PWR039" H 2450 5050 50  0001 C CNN
F 1 "GND" H 2455 5127 50  0000 C CNN
F 2 "" H 2450 5300 50  0001 C CNN
F 3 "" H 2450 5300 50  0001 C CNN
	1    2450 5300
	1    0    0    -1  
$EndComp
$Comp
L power:+36V #PWR046
U 1 1 5EC7EFEC
P 2800 2750
F 0 "#PWR046" H 2800 2600 50  0001 C CNN
F 1 "+36V" H 2815 2923 50  0000 C CNN
F 2 "" H 2800 2750 50  0001 C CNN
F 3 "" H 2800 2750 50  0001 C CNN
	1    2800 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	1650 3950 1450 3950
Wire Wire Line
	1450 3950 1450 3800
Wire Wire Line
	1450 3500 1450 3400
$Comp
L Device:C C?
U 1 1 5EC91EFD
P 3350 3500
AR Path="/5EC91EFD" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5EC91EFD" Ref="C18"  Part="1" 
F 0 "C18" H 3465 3546 50  0000 L CNN
F 1 "0.22u" H 3465 3455 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 3388 3350 50  0001 C CNN
F 3 "~" H 3350 3500 50  0001 C CNN
	1    3350 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	2950 3350 2950 3250
Wire Wire Line
	2950 3250 3350 3250
Wire Wire Line
	3350 3350 3350 3250
Connection ~ 3350 3250
Wire Wire Line
	2950 3650 3350 3650
$Comp
L power:GND #PWR047
U 1 1 5ECB02FD
P 3350 3650
F 0 "#PWR047" H 3350 3400 50  0001 C CNN
F 1 "GND" H 3355 3477 50  0000 C CNN
F 2 "" H 3350 3650 50  0001 C CNN
F 3 "" H 3350 3650 50  0001 C CNN
	1    3350 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 3250 2950 3250
Connection ~ 2950 3250
$Comp
L Device:CP C?
U 1 1 5ECB7A1F
P 3200 4800
AR Path="/5ECB7A1F" Ref="C?"  Part="1" 
AR Path="/5E4C3088/5ECB7A1F" Ref="C17"  Part="1" 
F 0 "C17" H 3318 4846 50  0000 L CNN
F 1 "220u" H 3318 4755 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm" H 3238 4650 50  0001 C CNN
F 3 "~" H 3200 4800 50  0001 C CNN
	1    3200 4800
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5ECDA1CC
P 2800 4450
AR Path="/5ECDA1CC" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5ECDA1CC" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5ECDA1CC" Ref="R56"  Part="1" 
F 0 "R56" H 2870 4496 50  0000 L CNN
F 1 "10.5k" H 2870 4405 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 2730 4450 50  0001 C CNN
F 3 "~" H 2800 4450 50  0001 C CNN
	1    2800 4450
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 5ECE9126
P 2800 4850
AR Path="/5ECE9126" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5ECE9126" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5ECE9126" Ref="R57"  Part="1" 
F 0 "R57" H 2870 4896 50  0000 L CNN
F 1 "2k" H 2870 4805 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 2730 4850 50  0001 C CNN
F 3 "~" H 2800 4850 50  0001 C CNN
	1    2800 4850
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR041
U 1 1 5ECF4E4A
P 2800 5100
F 0 "#PWR041" H 2800 4850 50  0001 C CNN
F 1 "GND" H 2805 4927 50  0000 C CNN
F 2 "" H 2800 5100 50  0001 C CNN
F 3 "" H 2800 5100 50  0001 C CNN
	1    2800 5100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR043
U 1 1 5ECF86FC
P 3200 5100
F 0 "#PWR043" H 3200 4850 50  0001 C CNN
F 1 "GND" H 3205 4927 50  0000 C CNN
F 2 "" H 3200 5100 50  0001 C CNN
F 3 "" H 3200 5100 50  0001 C CNN
	1    3200 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 5100 2800 5000
Wire Wire Line
	3200 5100 3200 4950
Wire Wire Line
	2800 4250 2800 4300
Wire Wire Line
	2800 4250 3200 4250
Connection ~ 2800 4250
Wire Wire Line
	2800 4600 2800 4650
Wire Wire Line
	2450 5300 2450 5200
Wire Wire Line
	2550 4400 2550 4650
Wire Wire Line
	2550 4650 2800 4650
Wire Wire Line
	2400 4400 2550 4400
Connection ~ 2800 4650
Wire Wire Line
	2800 4650 2800 4700
$Comp
L Device:R R?
U 1 1 5ED4A4DC
P 1400 4450
AR Path="/5ED4A4DC" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5ED4A4DC" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5ED4A4DC" Ref="R55"  Part="1" 
F 0 "R55" H 1470 4496 50  0000 L CNN
F 1 "63.4k" H 1470 4405 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 1330 4450 50  0001 C CNN
F 3 "~" H 1400 4450 50  0001 C CNN
	1    1400 4450
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR033
U 1 1 5ED4F503
P 1400 4700
F 0 "#PWR033" H 1400 4450 50  0001 C CNN
F 1 "GND" H 1405 4527 50  0000 C CNN
F 2 "" H 1400 4700 50  0001 C CNN
F 3 "" H 1400 4700 50  0001 C CNN
	1    1400 4700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR038
U 1 1 5ED5427C
P 1600 4450
F 0 "#PWR038" H 1600 4200 50  0001 C CNN
F 1 "GND" H 1605 4277 50  0000 C CNN
F 2 "" H 1600 4450 50  0001 C CNN
F 3 "" H 1600 4450 50  0001 C CNN
	1    1600 4450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR032
U 1 1 5ED5900B
P 1250 4100
F 0 "#PWR032" H 1250 3850 50  0001 C CNN
F 1 "GND" H 1255 3927 50  0000 C CNN
F 2 "" H 1250 4100 50  0001 C CNN
F 3 "" H 1250 4100 50  0001 C CNN
	1    1250 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 4250 1400 4300
Wire Wire Line
	1400 4250 1650 4250
Wire Wire Line
	1650 4400 1600 4400
Wire Wire Line
	1600 4400 1600 4450
Wire Wire Line
	1400 4600 1400 4700
Wire Wire Line
	1250 4100 1650 4100
Wire Wire Line
	2850 4100 3200 4100
Wire Wire Line
	3200 4100 3200 4250
Connection ~ 3200 4250
Wire Wire Line
	3200 4250 3200 4650
Wire Wire Line
	10100 2950 10100 3000
$Comp
L power:GND #PWR089
U 1 1 5EA28173
P 10100 3000
F 0 "#PWR089" H 10100 2750 50  0001 C CNN
F 1 "GND" H 10105 2827 50  0000 C CNN
F 2 "" H 10100 3000 50  0001 C CNN
F 3 "" H 10100 3000 50  0001 C CNN
	1    10100 3000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR074
U 1 1 5EE230DB
P 10100 2800
F 0 "#PWR074" H 10100 2650 50  0001 C CNN
F 1 "+5V" H 10115 2973 50  0000 C CNN
F 2 "" H 10100 2800 50  0001 C CNN
F 3 "" H 10100 2800 50  0001 C CNN
	1    10100 2800
	1    0    0    -1  
$EndComp
$Comp
L Device:Fuse F2
U 1 1 5EE34CA6
P 3400 4100
F 0 "F2" V 3203 4100 50  0000 C CNN
F 1 "3A" V 3294 4100 50  0000 C CNN
F 2 "Fuse:Fuse_2512_6332Metric" V 3330 4100 50  0001 C CNN
F 3 "~" H 3400 4100 50  0001 C CNN
	1    3400 4100
	0    1    1    0   
$EndComp
Wire Wire Line
	3250 4100 3200 4100
Connection ~ 3200 4100
Connection ~ 3350 3650
$Comp
L fpgaRelatedLib:B350B U9
U 1 1 5EEA2045
P 2450 5050
F 0 "U9" V 2404 5138 50  0000 L CNN
F 1 "B350B" V 2495 5138 50  0000 L CNN
F 2 "Diode_SMD:D_SMB" H 2600 4950 50  0001 C CNN
F 3 "" H 2600 4950 50  0001 C CNN
	1    2450 5050
	0    1    1    0   
$EndComp
Wire Wire Line
	2400 4100 2450 4100
$Comp
L fpgaRelatedLib:HPI1260 U12
U 1 1 5EEB78DF
P 2700 4100
F 0 "U12" H 2700 4325 50  0000 C CNN
F 1 "68u" H 2700 4234 50  0000 C CNN
F 2 "Inductor_SMD:L_12x12mm_H4.5mm" H 2850 4000 50  0001 C CNN
F 3 "" H 2850 4000 50  0001 C CNN
	1    2700 4100
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0113
U 1 1 5F42AD1C
P 3600 4050
F 0 "#PWR0113" H 3600 3900 50  0001 C CNN
F 1 "+5V" H 3615 4223 50  0000 C CNN
F 2 "" H 3600 4050 50  0001 C CNN
F 3 "" H 3600 4050 50  0001 C CNN
	1    3600 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3550 4100 3600 4100
Wire Wire Line
	3600 4100 3600 4050
$Comp
L power:+5V #PWR0115
U 1 1 5F4B91A9
P 4000 2750
F 0 "#PWR0115" H 4000 2600 50  0001 C CNN
F 1 "+5V" H 4015 2923 50  0000 C CNN
F 2 "" H 4000 2750 50  0001 C CNN
F 3 "" H 4000 2750 50  0001 C CNN
	1    4000 2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 2800 4000 2750
Connection ~ 4000 2800
Wire Wire Line
	2400 3950 2800 3950
Wire Wire Line
	2800 3250 2800 3950
Wire Wire Line
	2500 3400 2500 4100
Connection ~ 2500 4100
Wire Wire Line
	2500 4100 2550 4100
Wire Wire Line
	2400 4250 2800 4250
Wire Wire Line
	2450 4900 2450 4100
Connection ~ 2450 4100
Wire Wire Line
	2450 4100 2500 4100
Wire Wire Line
	1450 3400 2500 3400
$Comp
L Device:R R?
U 1 1 5F490E5A
P 7450 1550
AR Path="/5F490E5A" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5F490E5A" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5F490E5A" Ref="R68"  Part="1" 
F 0 "R68" H 7520 1596 50  0000 L CNN
F 1 "120" H 7520 1505 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 7380 1550 50  0001 C CNN
F 3 "~" H 7450 1550 50  0001 C CNN
	1    7450 1550
	-1   0    0    1   
$EndComp
Wire Wire Line
	7450 1400 7450 1300
Connection ~ 7450 1300
Wire Wire Line
	7450 1300 7650 1300
Wire Wire Line
	7450 1700 7450 1850
Connection ~ 7450 1850
Wire Wire Line
	7450 1850 7650 1850
$Comp
L Transistor_BJT:BC817 Q?
U 1 1 5F31DFF2
P 6900 5150
AR Path="/5E3A0664/5F31DFF2" Ref="Q?"  Part="1" 
AR Path="/5E4C3088/5F31DFF2" Ref="Q13"  Part="1" 
F 0 "Q13" H 7091 5196 50  0000 L CNN
F 1 "BC817" H 7091 5105 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 7100 5075 50  0001 L CIN
F 3 "http://www.fairchildsemi.com/ds/BC/BC817.pdf" H 6900 5150 50  0001 L CNN
	1    6900 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7000 4400 7000 4550
Wire Wire Line
	7000 4850 7000 4950
Wire Wire Line
	7000 4100 7000 4000
$Comp
L power:+3.3V #PWR0176
U 1 1 5F34AD58
P 7000 4000
F 0 "#PWR0176" H 7000 3850 50  0001 C CNN
F 1 "+3.3V" H 7015 4173 50  0000 C CNN
F 2 "" H 7000 4000 50  0001 C CNN
F 3 "" H 7000 4000 50  0001 C CNN
	1    7000 4000
	1    0    0    -1  
$EndComp
$Comp
L Device:R R?
U 1 1 5F34F113
P 6550 4950
AR Path="/5F34F113" Ref="R?"  Part="1" 
AR Path="/5E3A0664/5F34F113" Ref="R?"  Part="1" 
AR Path="/5E4C3088/5F34F113" Ref="R74"  Part="1" 
F 0 "R74" H 6620 4996 50  0000 L CNN
F 1 "50k" H 6620 4905 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric" V 6480 4950 50  0001 C CNN
F 3 "~" H 6550 4950 50  0001 C CNN
	1    6550 4950
	-1   0    0    1   
$EndComp
Wire Wire Line
	6550 4650 6550 4800
Wire Wire Line
	6700 5150 6550 5150
Wire Wire Line
	6550 5150 6550 5100
Wire Wire Line
	7000 5350 7000 5550
Wire Wire Line
	2900 2850 3350 2850
Wire Wire Line
	3350 2850 3350 3250
Wire Wire Line
	2800 2750 2800 2850
Wire Wire Line
	1350 1450 1350 1550
$EndSCHEMATC
