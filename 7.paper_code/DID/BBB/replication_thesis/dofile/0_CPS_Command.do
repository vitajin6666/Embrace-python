/*==================================================
project:       CPS_command
Author:        VitaJin 
----------------------------------------------------
Creation Date:    17 Feb 2025 - 18:09:14
==================================================*/

/*==================================================
***   Read raw CPS data and transform it to STATA format   ***
*** 以下内容从cps-- my data -- Command Files -- STATA中下载***
==================================================*/


cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data" //修改文件地址

************************复制全部command，粘贴到下面*****************************
set more off

clear
quietly infix                  ///
  int     year        1-4      ///
  long    serial      5-9      ///
  double  asecwth     10-20    ///
  double  asecwth04   21-28    ///
  byte    gq          29-29    ///
  byte    statefip    30-31    ///
  double  hhincome    32-39    ///
  double  asecwt      40-50    ///
  int     relate      51-54    ///
  byte    age         55-56    ///
  byte    sex         57-57    ///
  int     race        58-60    ///
  int     hispan      61-63    ///
  byte    empstat     64-65    ///
  int     educ        66-68    ///
  int     higrade     69-71    ///
  byte    educ99      72-73    ///
  double  asecwt04    74-81    ///
  byte    classwly    82-83    ///
  byte    wkswork1    84-85    ///
  int     uhrsworkly  86-88    ///
  double  inctot      89-97    ///
  double  incwage     98-105   ///
  double  incbus      106-113  ///
  using `"raw_cps.dat"'

replace asecwth    = asecwth    / 10000
replace asecwth04  = asecwth04  / 100
replace asecwt     = asecwt     / 10000
replace asecwt04   = asecwt04   / 100

format asecwth    %11.4f
format asecwth04  %8.2f
format hhincome   %8.0f
format asecwt     %11.4f
format asecwt04   %8.2f
format inctot     %9.0f
format incwage    %8.0f
format incbus     %8.0f

label var year       `"Survey year"'
label var serial     `"Household serial number"'
label var asecwth    `"Annual Social and Economic Supplement Household weight"'
label var asecwth04  `"Household weight 2004"'
label var gq         `"Group Quarters status"'
label var statefip   `"State (FIPS code)"'
label var hhincome   `"Total household income"'
label var asecwt     `"Annual Social and Economic Supplement Weight"'
label var relate     `"Relationship to household head"'
label var age        `"Age"'
label var sex        `"Sex"'
label var race       `"Race"'
label var hispan     `"Hispanic origin"'
label var empstat    `"Employment status"'
label var educ       `"Educational attainment recode"'
label var higrade    `"Highest grade of school "'
label var educ99     `"Educational attainment, 1990"'
label var asecwt04   `"Person weight 2004"'
label var classwly   `"Class of worker last year"'
label var wkswork1   `"Weeks worked last year"'
label var uhrsworkly `"Usual hours worked per week (last yr)"'
label var inctot     `"Total personal income"'
label var incwage    `"Wage and salary income"'
label var incbus     `"Non-farm business income"'

label define gq_lbl 0 `"NIU (Vacant units)"'
label define gq_lbl 1 `"Households"', add
label define gq_lbl 2 `"Group Quarters"', add
label values gq gq_lbl

label define statefip_lbl 01 `"Alabama"'
label define statefip_lbl 02 `"Alaska"', add
label define statefip_lbl 04 `"Arizona"', add
label define statefip_lbl 05 `"Arkansas"', add
label define statefip_lbl 06 `"California"', add
label define statefip_lbl 08 `"Colorado"', add
label define statefip_lbl 09 `"Connecticut"', add
label define statefip_lbl 10 `"Delaware"', add
label define statefip_lbl 11 `"District of Columbia"', add
label define statefip_lbl 12 `"Florida"', add
label define statefip_lbl 13 `"Georgia"', add
label define statefip_lbl 15 `"Hawaii"', add
label define statefip_lbl 16 `"Idaho"', add
label define statefip_lbl 17 `"Illinois"', add
label define statefip_lbl 18 `"Indiana"', add
label define statefip_lbl 19 `"Iowa"', add
label define statefip_lbl 20 `"Kansas"', add
label define statefip_lbl 21 `"Kentucky"', add
label define statefip_lbl 22 `"Louisiana"', add
label define statefip_lbl 23 `"Maine"', add
label define statefip_lbl 24 `"Maryland"', add
label define statefip_lbl 25 `"Massachusetts"', add
label define statefip_lbl 26 `"Michigan"', add
label define statefip_lbl 27 `"Minnesota"', add
label define statefip_lbl 28 `"Mississippi"', add
label define statefip_lbl 29 `"Missouri"', add
label define statefip_lbl 30 `"Montana"', add
label define statefip_lbl 31 `"Nebraska"', add
label define statefip_lbl 32 `"Nevada"', add
label define statefip_lbl 33 `"New Hampshire"', add
label define statefip_lbl 34 `"New Jersey"', add
label define statefip_lbl 35 `"New Mexico"', add
label define statefip_lbl 36 `"New York"', add
label define statefip_lbl 37 `"North Carolina"', add
label define statefip_lbl 38 `"North Dakota"', add
label define statefip_lbl 39 `"Ohio"', add
label define statefip_lbl 40 `"Oklahoma"', add
label define statefip_lbl 41 `"Oregon"', add
label define statefip_lbl 42 `"Pennsylvania"', add
label define statefip_lbl 44 `"Rhode Island"', add
label define statefip_lbl 45 `"South Carolina"', add
label define statefip_lbl 46 `"South Dakota"', add
label define statefip_lbl 47 `"Tennessee"', add
label define statefip_lbl 48 `"Texas"', add
label define statefip_lbl 49 `"Utah"', add
label define statefip_lbl 50 `"Vermont"', add
label define statefip_lbl 51 `"Virginia"', add
label define statefip_lbl 53 `"Washington"', add
label define statefip_lbl 54 `"West Virginia"', add
label define statefip_lbl 55 `"Wisconsin"', add
label define statefip_lbl 56 `"Wyoming"', add
label define statefip_lbl 61 `"Maine-New Hampshire-Vermont"', add
label define statefip_lbl 65 `"Montana-Idaho-Wyoming"', add
label define statefip_lbl 68 `"Alaska-Hawaii"', add
label define statefip_lbl 69 `"Nebraska-North Dakota-South Dakota"', add
label define statefip_lbl 70 `"Maine-Massachusetts-New Hampshire-Rhode Island-Vermont"', add
label define statefip_lbl 71 `"Michigan-Wisconsin"', add
label define statefip_lbl 72 `"Minnesota-Iowa"', add
label define statefip_lbl 73 `"Nebraska-North Dakota-South Dakota-Kansas"', add
label define statefip_lbl 74 `"Delaware-Virginia"', add
label define statefip_lbl 75 `"North Carolina-South Carolina"', add
label define statefip_lbl 76 `"Alabama-Mississippi"', add
label define statefip_lbl 77 `"Arkansas-Oklahoma"', add
label define statefip_lbl 78 `"Arizona-New Mexico-Colorado"', add
label define statefip_lbl 79 `"Idaho-Wyoming-Utah-Montana-Nevada"', add
label define statefip_lbl 80 `"Alaska-Washington-Hawaii"', add
label define statefip_lbl 81 `"New Hampshire-Maine-Vermont-Rhode Island"', add
label define statefip_lbl 83 `"South Carolina-Georgia"', add
label define statefip_lbl 84 `"Kentucky-Tennessee"', add
label define statefip_lbl 85 `"Arkansas-Louisiana-Oklahoma"', add
label define statefip_lbl 87 `"Iowa-N Dakota-S Dakota-Nebraska-Kansas-Minnesota-Missouri"', add
label define statefip_lbl 88 `"Washington-Oregon-Alaska-Hawaii"', add
label define statefip_lbl 89 `"Montana-Wyoming-Colorado-New Mexico-Utah-Nevada-Arizona"', add
label define statefip_lbl 90 `"Delaware-Maryland-Virginia-West Virginia"', add
label define statefip_lbl 99 `"State not identified"', add
label values statefip statefip_lbl

label define relate_lbl 0101 `"Head/householder"'
label define relate_lbl 0201 `"Spouse"', add
label define relate_lbl 0202 `"Opposite sex spouse"', add
label define relate_lbl 0203 `"Same sex spouse"', add
label define relate_lbl 0301 `"Child"', add
label define relate_lbl 0303 `"Stepchild"', add
label define relate_lbl 0501 `"Parent"', add
label define relate_lbl 0701 `"Sibling"', add
label define relate_lbl 0901 `"Grandchild"', add
label define relate_lbl 1001 `"Other relatives, n.s."', add
label define relate_lbl 1113 `"Partner/roommate"', add
label define relate_lbl 1114 `"Unmarried partner"', add
label define relate_lbl 1116 `"Opposite sex unmarried partner"', add
label define relate_lbl 1117 `"Same sex unmarried partner"', add
label define relate_lbl 1115 `"Housemate/roomate"', add
label define relate_lbl 1241 `"Roomer/boarder/lodger"', add
label define relate_lbl 1242 `"Foster children"', add
label define relate_lbl 1260 `"Other nonrelatives"', add
label define relate_lbl 9900 `"Relationship unknown"', add
label define relate_lbl 9999 `"NIU"', add
label values relate relate_lbl

label define age_lbl 00 `"Under 1 year"'
label define age_lbl 01 `"1"', add
label define age_lbl 02 `"2"', add
label define age_lbl 03 `"3"', add
label define age_lbl 04 `"4"', add
label define age_lbl 05 `"5"', add
label define age_lbl 06 `"6"', add
label define age_lbl 07 `"7"', add
label define age_lbl 08 `"8"', add
label define age_lbl 09 `"9"', add
label define age_lbl 10 `"10"', add
label define age_lbl 11 `"11"', add
label define age_lbl 12 `"12"', add
label define age_lbl 13 `"13"', add
label define age_lbl 14 `"14"', add
label define age_lbl 15 `"15"', add
label define age_lbl 16 `"16"', add
label define age_lbl 17 `"17"', add
label define age_lbl 18 `"18"', add
label define age_lbl 19 `"19"', add
label define age_lbl 20 `"20"', add
label define age_lbl 21 `"21"', add
label define age_lbl 22 `"22"', add
label define age_lbl 23 `"23"', add
label define age_lbl 24 `"24"', add
label define age_lbl 25 `"25"', add
label define age_lbl 26 `"26"', add
label define age_lbl 27 `"27"', add
label define age_lbl 28 `"28"', add
label define age_lbl 29 `"29"', add
label define age_lbl 30 `"30"', add
label define age_lbl 31 `"31"', add
label define age_lbl 32 `"32"', add
label define age_lbl 33 `"33"', add
label define age_lbl 34 `"34"', add
label define age_lbl 35 `"35"', add
label define age_lbl 36 `"36"', add
label define age_lbl 37 `"37"', add
label define age_lbl 38 `"38"', add
label define age_lbl 39 `"39"', add
label define age_lbl 40 `"40"', add
label define age_lbl 41 `"41"', add
label define age_lbl 42 `"42"', add
label define age_lbl 43 `"43"', add
label define age_lbl 44 `"44"', add
label define age_lbl 45 `"45"', add
label define age_lbl 46 `"46"', add
label define age_lbl 47 `"47"', add
label define age_lbl 48 `"48"', add
label define age_lbl 49 `"49"', add
label define age_lbl 50 `"50"', add
label define age_lbl 51 `"51"', add
label define age_lbl 52 `"52"', add
label define age_lbl 53 `"53"', add
label define age_lbl 54 `"54"', add
label define age_lbl 55 `"55"', add
label define age_lbl 56 `"56"', add
label define age_lbl 57 `"57"', add
label define age_lbl 58 `"58"', add
label define age_lbl 59 `"59"', add
label define age_lbl 60 `"60"', add
label define age_lbl 61 `"61"', add
label define age_lbl 62 `"62"', add
label define age_lbl 63 `"63"', add
label define age_lbl 64 `"64"', add
label define age_lbl 65 `"65"', add
label define age_lbl 66 `"66"', add
label define age_lbl 67 `"67"', add
label define age_lbl 68 `"68"', add
label define age_lbl 69 `"69"', add
label define age_lbl 70 `"70"', add
label define age_lbl 71 `"71"', add
label define age_lbl 72 `"72"', add
label define age_lbl 73 `"73"', add
label define age_lbl 74 `"74"', add
label define age_lbl 75 `"75"', add
label define age_lbl 76 `"76"', add
label define age_lbl 77 `"77"', add
label define age_lbl 78 `"78"', add
label define age_lbl 79 `"79"', add
label define age_lbl 80 `"80"', add
label define age_lbl 81 `"81"', add
label define age_lbl 82 `"82"', add
label define age_lbl 83 `"83"', add
label define age_lbl 84 `"84"', add
label define age_lbl 85 `"85"', add
label define age_lbl 86 `"86"', add
label define age_lbl 87 `"87"', add
label define age_lbl 88 `"88"', add
label define age_lbl 89 `"89"', add
label define age_lbl 90 `"90 (90+, 1988-2002)"', add
label define age_lbl 91 `"91"', add
label define age_lbl 92 `"92"', add
label define age_lbl 93 `"93"', add
label define age_lbl 94 `"94"', add
label define age_lbl 95 `"95"', add
label define age_lbl 96 `"96"', add
label define age_lbl 97 `"97"', add
label define age_lbl 98 `"98"', add
label define age_lbl 99 `"99+"', add
label values age age_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 9 `"NIU"', add
label values sex sex_lbl

label define race_lbl 100 `"White"'
label define race_lbl 200 `"Black"', add
label define race_lbl 300 `"American Indian/Aleut/Eskimo"', add
label define race_lbl 650 `"Asian or Pacific Islander"', add
label define race_lbl 651 `"Asian only"', add
label define race_lbl 652 `"Hawaiian/Pacific Islander only"', add
label define race_lbl 700 `"Other (single) race, n.e.c."', add
label define race_lbl 801 `"White-Black"', add
label define race_lbl 802 `"White-American Indian"', add
label define race_lbl 803 `"White-Asian"', add
label define race_lbl 804 `"White-Hawaiian/Pacific Islander"', add
label define race_lbl 805 `"Black-American Indian"', add
label define race_lbl 806 `"Black-Asian"', add
label define race_lbl 807 `"Black-Hawaiian/Pacific Islander"', add
label define race_lbl 808 `"American Indian-Asian"', add
label define race_lbl 809 `"Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 810 `"White-Black-American Indian"', add
label define race_lbl 811 `"White-Black-Asian"', add
label define race_lbl 812 `"White-American Indian-Asian"', add
label define race_lbl 813 `"White-Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 814 `"White-Black-American Indian-Asian"', add
label define race_lbl 815 `"American Indian-Hawaiian/Pacific Islander"', add
label define race_lbl 816 `"White-Black--Hawaiian/Pacific Islander"', add
label define race_lbl 817 `"White-American Indian-Hawaiian/Pacific Islander"', add
label define race_lbl 818 `"Black-American Indian-Asian"', add
label define race_lbl 819 `"White-American Indian-Asian-Hawaiian/Pacific Islander"', add
label define race_lbl 820 `"Two or three races, unspecified"', add
label define race_lbl 830 `"Four or five races, unspecified"', add
label define race_lbl 999 `"Blank"', add
label values race race_lbl

label define hispan_lbl 000 `"Not Hispanic"'
label define hispan_lbl 100 `"Mexican"', add
label define hispan_lbl 102 `"Mexican American"', add
label define hispan_lbl 103 `"Mexicano/Mexicana"', add
label define hispan_lbl 104 `"Chicano/Chicana"', add
label define hispan_lbl 108 `"Mexican (Mexicano)"', add
label define hispan_lbl 109 `"Mexicano/Chicano"', add
label define hispan_lbl 200 `"Puerto Rican"', add
label define hispan_lbl 300 `"Cuban"', add
label define hispan_lbl 400 `"Dominican"', add
label define hispan_lbl 500 `"Salvadoran"', add
label define hispan_lbl 600 `"Other Hispanic"', add
label define hispan_lbl 610 `"Central/South American"', add
label define hispan_lbl 611 `"Central American, (excluding Salvadoran)"', add
label define hispan_lbl 612 `"South American"', add
label define hispan_lbl 901 `"Do not know"', add
label define hispan_lbl 902 `"N/A (and no response 1985-87)"', add
label values hispan hispan_lbl

label define empstat_lbl 00 `"NIU"'
label define empstat_lbl 01 `"Armed Forces"', add
label define empstat_lbl 10 `"At work"', add
label define empstat_lbl 12 `"Has job, not at work last week"', add
label define empstat_lbl 20 `"Unemployed"', add
label define empstat_lbl 21 `"Unemployed, experienced worker"', add
label define empstat_lbl 22 `"Unemployed, new worker"', add
label define empstat_lbl 30 `"Not in labor force"', add
label define empstat_lbl 31 `"NILF, housework"', add
label define empstat_lbl 32 `"NILF, unable to work"', add
label define empstat_lbl 33 `"NILF, school"', add
label define empstat_lbl 34 `"NILF, other"', add
label define empstat_lbl 35 `"NILF, unpaid, lt 15 hours"', add
label define empstat_lbl 36 `"NILF, retired"', add
label values empstat empstat_lbl

label define educ_lbl 000 `"NIU or no schooling"'
label define educ_lbl 001 `"NIU or blank"', add
label define educ_lbl 002 `"None or preschool"', add
label define educ_lbl 010 `"Grades 1, 2, 3, or 4"', add
label define educ_lbl 011 `"Grade 1"', add
label define educ_lbl 012 `"Grade 2"', add
label define educ_lbl 013 `"Grade 3"', add
label define educ_lbl 014 `"Grade 4"', add
label define educ_lbl 020 `"Grades 5 or 6"', add
label define educ_lbl 021 `"Grade 5"', add
label define educ_lbl 022 `"Grade 6"', add
label define educ_lbl 030 `"Grades 7 or 8"', add
label define educ_lbl 031 `"Grade 7"', add
label define educ_lbl 032 `"Grade 8"', add
label define educ_lbl 040 `"Grade 9"', add
label define educ_lbl 050 `"Grade 10"', add
label define educ_lbl 060 `"Grade 11"', add
label define educ_lbl 070 `"Grade 12"', add
label define educ_lbl 071 `"12th grade, no diploma"', add
label define educ_lbl 072 `"12th grade, diploma unclear"', add
label define educ_lbl 073 `"High school diploma or equivalent"', add
label define educ_lbl 080 `"1 year of college"', add
label define educ_lbl 081 `"Some college but no degree"', add
label define educ_lbl 090 `"2 years of college"', add
label define educ_lbl 091 `"Associate's degree, occupational/vocational program"', add
label define educ_lbl 092 `"Associate's degree, academic program"', add
label define educ_lbl 100 `"3 years of college"', add
label define educ_lbl 110 `"4 years of college"', add
label define educ_lbl 111 `"Bachelor's degree"', add
label define educ_lbl 120 `"5+ years of college"', add
label define educ_lbl 121 `"5 years of college"', add
label define educ_lbl 122 `"6+ years of college"', add
label define educ_lbl 123 `"Master's degree"', add
label define educ_lbl 124 `"Professional school degree"', add
label define educ_lbl 125 `"Doctorate degree"', add
label define educ_lbl 999 `"Missing/Unknown"', add
label values educ educ_lbl

label define higrade_lbl 000 `"NIU"'
label define higrade_lbl 010 `"None"', add
label define higrade_lbl 031 `"Did not finish 1st grade"', add
label define higrade_lbl 040 `"1st grade"', add
label define higrade_lbl 041 `"Did not finish 2nd grade"', add
label define higrade_lbl 050 `"2nd grade"', add
label define higrade_lbl 051 `"Did not finish 3rd grade"', add
label define higrade_lbl 060 `"3rd grade"', add
label define higrade_lbl 061 `"Did not finish 4th grade"', add
label define higrade_lbl 070 `"4th grade"', add
label define higrade_lbl 071 `"Did not finish 5th grade"', add
label define higrade_lbl 080 `"5th grade"', add
label define higrade_lbl 081 `"Did not finish 6th grade"', add
label define higrade_lbl 090 `"6th grade"', add
label define higrade_lbl 091 `"Did not finish 7th grade"', add
label define higrade_lbl 100 `"7th grade"', add
label define higrade_lbl 101 `"Did not finish 8th grade"', add
label define higrade_lbl 110 `"8th grade"', add
label define higrade_lbl 111 `"Did not finish 9th grade"', add
label define higrade_lbl 120 `"9th grade"', add
label define higrade_lbl 121 `"Did not finish 10th grade"', add
label define higrade_lbl 130 `"10th grade"', add
label define higrade_lbl 131 `"Did not finish 11th grade"', add
label define higrade_lbl 140 `"11th grade"', add
label define higrade_lbl 141 `"Did not finish 12th grade"', add
label define higrade_lbl 150 `"12th grade"', add
label define higrade_lbl 151 `"Did not finish 1st year college"', add
label define higrade_lbl 160 `"1st year college"', add
label define higrade_lbl 161 `"Did not finish 2nd year"', add
label define higrade_lbl 170 `"2nd year college"', add
label define higrade_lbl 171 `"Did not finish 3rd year"', add
label define higrade_lbl 180 `"3rd year college"', add
label define higrade_lbl 181 `"Did not finish 4th year"', add
label define higrade_lbl 190 `"4th year college"', add
label define higrade_lbl 191 `"Did not finish 5th year"', add
label define higrade_lbl 200 `"5th year college"', add
label define higrade_lbl 201 `"Did not finish 6th year"', add
label define higrade_lbl 210 `"6th year college"', add
label define higrade_lbl 999 `"Missing/Unknown"', add
label values higrade higrade_lbl

label define educ99_lbl 00 `"NIU"'
label define educ99_lbl 01 `"No school completed"', add
label define educ99_lbl 04 `"1st-4th grade"', add
label define educ99_lbl 05 `"5th-8th grade"', add
label define educ99_lbl 06 `"9th grade"', add
label define educ99_lbl 07 `"10th grade"', add
label define educ99_lbl 08 `"11th grade"', add
label define educ99_lbl 09 `"12th grade, no diploma"', add
label define educ99_lbl 10 `"High school graduate, or GED"', add
label define educ99_lbl 11 `"Some college, no degree"', add
label define educ99_lbl 12 `"Associate degree, type of program not specified"', add
label define educ99_lbl 13 `"Associate degree, occupational program"', add
label define educ99_lbl 14 `"Associate degree, academic program"', add
label define educ99_lbl 15 `"Bachelors degree"', add
label define educ99_lbl 16 `"Masters degree"', add
label define educ99_lbl 17 `"Professional degree"', add
label define educ99_lbl 18 `"Doctorate degree"', add
label values educ99 educ99_lbl

label define classwly_lbl 00 `"NIU"'
label define classwly_lbl 10 `"Self-employed"', add
label define classwly_lbl 13 `"Self-employed, not incorporated"', add
label define classwly_lbl 14 `"Self-employed, incorporated"', add
label define classwly_lbl 20 `"Works for wages or salary"', add
label define classwly_lbl 22 `"Wage/salary, private"', add
label define classwly_lbl 24 `"Wage/salary, government"', add
label define classwly_lbl 25 `"Federal government employee"', add
label define classwly_lbl 27 `"State government employee"', add
label define classwly_lbl 28 `"Local government employee"', add
label define classwly_lbl 29 `"Unpaid family worker"', add
label define classwly_lbl 99 `"Missing/Unknown"', add
label values classwly classwly_lbl

************************结束粘贴*****************************

save cps_to_stata, replace //修改文件名


/* End of do-file */