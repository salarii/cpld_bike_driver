EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 5000 1200 2200 1850
U 5E3A0664
F0 "DriveAndSens" 50
F1 "bikeDrivSens.sch" 50
F2 "A_p" I L 5000 1550 50 
F3 "A_n" I L 5000 1700 50 
F4 "B_p" I L 5000 1900 50 
F5 "B_n" I L 5000 2050 50 
F6 "C_p" I L 5000 2300 50 
F7 "C_n" I L 5000 2450 50 
$EndSheet
$Sheet
S 1550 1250 2750 1400
U 5E3A0905
F0 "control" 50
F1 "control.sch" 50
F2 "A_p" O R 4300 1450 50 
F3 "A_n" O R 4300 1650 50 
F4 "B_p" O R 4300 1900 50 
F5 "B_n" O R 4300 2100 50 
F6 "C_p" O R 4300 2300 50 
F7 "C_n" O R 4300 2450 50 
$EndSheet
$Sheet
S 3150 4750 2100 2100
U 5E4C3088
F0 "power" 50
F1 "power.sch" 50
$EndSheet
Wire Wire Line
	4500 2100 4300 2100
Wire Wire Line
	4300 1450 4850 1450
Wire Wire Line
	4850 1450 4850 1550
Wire Wire Line
	4850 1550 5000 1550
Wire Wire Line
	4850 1650 4850 1700
Wire Wire Line
	4850 1700 5000 1700
Wire Wire Line
	4300 1650 4850 1650
Wire Wire Line
	4300 1900 5000 1900
Wire Wire Line
	4500 2100 4500 2050
Wire Wire Line
	4500 2050 5000 2050
Wire Wire Line
	4300 2300 5000 2300
Wire Wire Line
	4300 2450 5000 2450
$EndSCHEMATC
