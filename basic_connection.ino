unsigned int ADCValue;
void setup(){
   Serial.begin(9600);
}

void loop(){

   int val = analogRead(0);
   val = map(val, 0, 300, 0, 255);
   Serial.print(val);
   Serial.print(",");
   Serial.println(val);
   delay(50);
}
