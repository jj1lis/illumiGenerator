#include <EEPROM.h>
#include <avr/wdt.h>

const int ADDR_MODE = 0;
const unsigned int FLASH_CYCLE = 2000;
const unsigned byte DUTY_MAX = 100;
const unsigned byte DUTY_RATIO = 10;
const unsigned byte OUT_MIN = 2
const unsigned byte OUT_MAX = 13
const char SW_MODE = A1

typedef enum{
	xmas = 0;
	mochi = 1;
	oni = 2;
}Mode;

float Default_pin2(float phase){
	return 1;
}

float Default_pin3(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin4(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin5(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin6(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin7(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin8(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float Default_pin9(float phase){
	return 0;
}

float Default_pin10(float phase){
	return 0;
}

float Default_pin11(float phase){
	return 0;
}

float Default_pin12(float phase){
	return 0;
}

float Default_pin13(float phase){
	return 0;
}

float xmas_pin2(float phase){
	return 1;
}

float xmas_pin3(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin4(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin5(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin6(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin7(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin8(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float xmas_pin9(float phase){
	return 1;
}

float xmas_pin10(float phase){
	return 1;
}

float xmas_pin11(float phase){
	return 0;
}

float xmas_pin12(float phase){
	return 0;
}

float xmas_pin13(float phase){
	return 0;
}

float mochi_pin2(float phase){
	return 1;
}

float mochi_pin3(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin4(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin5(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin6(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin7(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin8(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float mochi_pin9(float phase){
	return 0;
}

float mochi_pin10(float phase){
	return 0;
}

float mochi_pin11(float phase){
	return 0;
}

float mochi_pin12(float phase){
	return 1;
}

float mochi_pin13(float phase){
	return 0;
}

float oni_pin2(float phase){
	return 1;
}

float oni_pin3(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin4(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin5(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin6(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin7(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin8(float phase){
	if(0 <= phase && phase <= PI){return 1;}else{return 0;}
}

float oni_pin9(float phase){
	return 1;
}

float oni_pin10(float phase){
	return 0;
}

float oni_pin11(float phase){
	return 1;
}

float oni_pin12(float phase){
	return 0;
}

float oni_pin13(float phase){
	return 0;
}

float (*xmasFunctions[])(float) = { xmas_pin2, xmas_pin3, xmas_pin4, xmas_pin5, xmas_pin6, xmas_pin7, xmas_pin8, xmas_pin9, xmas_pin10, xmas_pin11, xmas_pin12, xmas_pin13 };
float (*mochiFunctions[])(float) = { mochi_pin2, mochi_pin3, mochi_pin4, mochi_pin5, mochi_pin6, mochi_pin7, mochi_pin8, mochi_pin9, mochi_pin10, mochi_pin11, mochi_pin12, mochi_pin13 };
float (*DefaultFunctions[])(float) = { Default_pin2, Default_pin3, Default_pin4, Default_pin5, Default_pin6, Default_pin7, Default_pin8, Default_pin9, Default_pin10, Default_pin11, Default_pin12, Default_pin13 };
float (*oniFunctions[])(float) = { oni_pin2, oni_pin3, oni_pin4, oni_pin5, oni_pin6, oni_pin7, oni_pin8, oni_pin9, oni_pin10, oni_pin11, oni_pin12, oni_pin13 };

float (*getFunctions(Mode mode, unsigned byte index))(float){
	switch(mode){
		case xmas:
			return xmasFunctions[index];
		case mochi:
			return mochiFunctions[index];
		case oni:
			return oniFunctions[index];
		default:
			return NULL;
	}
}

void reset(){
	wdt_dusable();
	wdt_enable(WDTO_15MS);
	while(1);
}

void setup(){
	for(unsigned byte cnt = OUT_MIN; cnt <= OUT_MAX; cnt++){
		pinMode(cnt, OUTPUT);
	}
	delay(1000);
}

void loop(){
	Mode mode = (Mode)EEPROM.read(ADDR_MODE);

	if(mode > oni)
		mode = xmas;

	float phase_now = 0;

	while(1){
		if(digitalRead(SW_MODE) == HIGH){
			EEPROM.write(ADDR_MODE, mode + 1);
			reset();
		}

		pahse_now = (float)(mills() % FLASH_CYCLE)/(float)FLASH_CYCLE * 2. * PI;

		for(unsigned byte pwm_count = 0; pwm_count <= DUTY_MAX; pwm_count++){
			for(unsigned byte pin = OUT_MIN; pin <= OUT_MAX; pin++){
				if(pwm_count > DUTY_RATIO)
					digitalWrite(pin, LOW);
				else{
					if((float)pwm_count <= (float)DUTY_RATIO*getFunctions(mode, pin-OUT_MIN)(phase_now))
						digitalWrite(pin + OUT_MIN, HIGH);
					else
						digitalWrite(pin + OUT_MIN, LOW);
				}
			}
		}
	}
}
