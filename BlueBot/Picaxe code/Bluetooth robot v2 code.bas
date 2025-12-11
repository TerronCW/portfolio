


;    ===========================    ;
;    ||  MRC Bluetooth Robot  ||    ;
;    ||       V2 redux        ||    ;
;    ||     Terron Wright     ||    ;
;    ===========================    ;



setfreq M32

symbol Version = 20

;ASSIGN variable names
symbol RightF = B.4
symbol RightB = B.5
symbol LeftB = C.0
symbol LeftF = C.1
symbol Light1 = B.2
symbol Light2 = B.3
symbol Piezo = C.2

symbol Directive = w0 ; b0, b1
symbol MathTemp = b2
symbol MathTemp2 = b3

symbol RightValue = b4
symbol LeftValue = b5
symbol RightDrive = b6
symbol LeftDrive = b7
symbol RightPause = b8
symbol LeftPause = b9

symbol AccelStep = b10
symbol ExtraStuff = b11
symbol JoyMode = b12

symbol ExtraTalkCount = b13
symbol ExtraTalk = b14

;INITIALIZE values to STOPPED
LET RightValue = 60
LET LeftValue = 60
LET RightDrive = 60
LET LeftDrive = 60
LET RightPause = 0
LET LeftPause = 0

;SET acceleration speed
LET AccelStep = 12	; 1, 2, 3, 4, 5, 6, 12


;================================ START PROGRAM ================================;


;------------------------------- Initialization --------------------------------;
for MathTemp = 1 to 5
	HIGH Light1, Light2
	pause 500
	LOW Light1, Light2
	pause 500
next MathTemp

	hsersetup B9600_32, %00000
	;Setup hardware serial input (non-blocking)
	;Reads into serial buffer in the background


;--------------------------------- Main loop -----------------------------------;
main:	;Main loop
	
	;Start motors forward or backward or neither, according to RightDrive and LeftDrive
	IF RightDrive > 60 THEN high RightF
	ELSEIF RightDrive < 60 THEN high RightB
	ENDIF
	IF LeftDrive > 60 THEN high LeftF
	ELSEIF LeftDrive < 60 THEN high LeftB
	ENDIF
	
	;Do time consuming things while motors are on to prevent jiterry driving
	gosub readData 	;Get new data from Bluetooth
	gosub driveMath	;Calculate DriveValues from data
	gosub extras	;Do other fun things
	
	;Stops motors after their pause value in miliseconds
	IF RightPause > LeftPause THEN	;If left stops first
		Pause LeftPause
		let MathTemp = RightPause - LeftPause
		low LeftF, LeftB
		Pause MathTemp
		low RightF, RightB
		let MathTemp = 120 - RightPause
		pause MathTemp
	ELSE						;If right stops first or at the same time
		Pause RightPause
		let MathTemp = LeftPause - RightPause
		low RightF, RightB
		Pause MathTemp
		low LeftF, LeftB
		let MathTemp = 120 - LeftPause
		pause MathTemp
	ENDIF
	
	
goto main

;-------------------------------- Subroutines ----------------------------------;

readData:	;Subroutine for reading data from Bluetooth

	;=+=+=+=+=+= JOYSTICK MODE =+=+=+=+=+=;
	
	IF JoyMode = 1 THEN ;If we're in joystick mode read directly to drive values
	
		;Since 0 is full reverse, set directives to something else, in case there's no data
		let Directive = 125
		hserin Directive ;Read data from the serial buffer into Directive
		
		IF Directive = 124 THEN ;Joystick mode off
			let JoyMode = 0
			let RightValue = 60
			let LeftValue = 60
			let ExtraStuff = 7
		ELSEIF Directive = 125 THEN
			;ignore data, there was none
		ELSE
			;Get Directive mod 11 (Right motor value)
			let MathTemp2 = Directive // 11
			;Change range from [0 to 10] to [0 to 120]
			let MathTemp2 = MathTemp2 * 12
			let RightValue = MathTemp2
			
			;Get Directive remainder 11 (Left motor value)
			let MathTemp2 = Directive / 11
			;Change range from [0 to 10] to [0 to 120]
			let MathTemp2 = MathTemp2 * 12
			let LeftValue = MathTemp2
			
		ENDIF
		let Directive = 0
	
	;=+=+=+=+=+= DIRECT COMMAND MODE =+=+=+=+=+=;
	
	ELSE ;If we're not in joystick mode read normal commands
	
		hserin Directive ;Read data from the serial buffer into Directive
		
		IF Directive > 0 THEN ;If there was data

			IF Directive = 123 THEN ;Joystick mode ON
				let JoyMode = 1
			ELSE				;Any other command
				let ExtraStuff = 7;Blink the lights
				
			;Assign motor values in the form of; 120 = 100%, 60 = 0%, 0 = -100%
				IF     Directive = 64   THEN 
					let RightValue = 120 : let LeftValue = 120 ;Forward
				ELSEIF Directive = 96   THEN 
					let RightValue = 60 : let LeftValue = 120 ;Turn Right
				ELSEIF Directive = 32   THEN 
					let RightValue = 0 : let LeftValue = 0 ;Backwards
				ELSEIF Directive = 112  THEN 
					let RightValue = 120 : let LeftValue = 60 ;Turn Left
				ELSEIF Directive = 65   THEN 
					let RightValue = 60 : let LeftValue = 60 ;Stop 
					
									; Gsr app code
				ELSEIF Directive = 127  THEN 
					let RightValue = 120 : let LeftValue = 120 ;Forward
				ELSEIF Directive = 63   THEN 
					let RightValue = 60 : let LeftValue = 120 ;Turn Right
				ELSEIF Directive = 126  THEN
					let RightValue = 0 : let LeftValue = 0 ;Backwards
				ELSEIF Directive = 31   THEN 
					let RightValue = 120 : let LeftValue = 60 ;Turn Left
				ELSEIF Directive = 125  THEN 
					let RightValue = 60 : let LeftValue = 60 ;Stop
				
				;Other commands
				ELSEIF Directive = 10 THEN ;AccelDown
					IF AccelStep > 1 AND AccelStep < 7 THEN
						dec AccelStep
					ELSEIF AccelStep >= 7 THEN
						let AccelStep = 6
					ENDIF
				
				ELSEIF Directive = 20 THEN ;AccelUp
					IF AccelStep < 6 THEN
						inc AccelStep
					ELSEIF AccelStep = 6 THEN
						let AccelStep = 12
					ENDIF
				
				ELSEIF Directive = 30 THEN ;Version
					hserout 1, (17, Version) ;Report version with key "17"
					
				ELSEIF Directive = 40 THEN ;Extra
					let ExtraTalk = 1		;Say something in Extras
					inc ExtraTalkCount 	;Say the next thing
					
				ENDIF
			ENDIF
		ENDIF
		let Directive = 0 ;reset Directive
	ENDIF
	return
	
	
drivemath:	;do value conversions and some logic

	;Run delays for smooth acceleration
		IF RightDrive < RightValue THEN 
			let RightDrive = RightDrive + AccelStep 
			IF RightDrive > RightValue THEN let RightDrive = RightValue ENDIF
		ENDIF
		IF RightDrive > RightValue THEN 
			let RightDrive = RightDrive - AccelStep 
			IF RightDrive < RightValue THEN let RightDrive = RightValue ENDIF
		ENDIF
		IF LeftDrive < LeftValue THEN 
			let LeftDrive = LeftDrive + AccelStep 
			IF LeftDrive > LeftValue THEN let LeftDrive = LeftValue ENDIF
		ENDIF
		IF LeftDrive > LeftValue THEN 
			let LeftDrive = LeftDrive - AccelStep 
			IF LeftDrive < LeftValue THEN let LeftDrive = LeftValue ENDIF
		ENDIF
		
	;Convert drive values to pause values
	;right
	LET MathTemp = RightDrive * 2
	IF RightDrive < 60 THEN
		LET RightPause = 120 - MathTemp
	ELSE
		LET RightPause = MathTemp - 120
	ENDIF

	;left
	LET MathTemp = LeftDrive * 2
	IF LeftDrive < 60 THEN
		LET LeftPause = 120 - MathTemp
	ELSE
		LET LeftPause = MathTemp - 120
	ENDIF
	return

extras:	;Do fun stuff
	IF ExtraStuff > 0 THEN
		IF ExtraStuff = 1 THEN low Light1, Light2 
			IF RightDrive = 60 AND LeftDrive = 60 THEN sound Piezo, (55, 100, 45, 100) : low Piezo ENDIF 	;If stopped, play sound
		ELSEIF ExtraStuff = 3 THEN low Light1
		ELSEIF ExtraStuff = 5 THEN high Light1, Light2
		ELSEIF ExtraStuff = 7 THEN high Light1
		
		ELSEIF ExtraStuff = 9 THEN sound Piezo,(25,80, 0,20, 95,80, 0,40, 60,200) : low Piezo ENDIF 		;Play tune
		dec ExtraStuff
	ENDIF
	IF ExtraTalk = 1 THEN 	;We can say something
		IF ExtraTalkCount = 1 THEN 		;Say 1
			hserout 1, (2, "I'm Fitchie!")                  					  ; <---- Robot Name
		ELSEIF ExtraTalkCount = 2 THEN	;Say 2
			hserout 1, (2, "I can talk now!")
		ELSEIF ExtraTalkCount = 3 THEN	;Say 3
			hserout 1, (2, "Yay! :D")
			let ExtraStuff = 9		;Blink lights and tune
			let ExtraTalkCount = 0		;loop back to 1
		ENDIF
		let ExtraTalk = 0	;We don't need to say it again
	ENDIF
	return