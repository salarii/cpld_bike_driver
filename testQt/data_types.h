#ifndef DATA_TYPES_H
#define DATA_TYPES_H

struct Measurement
{
  float  voltage;
  int time;
  int temperature;
};


const char TriggerOpCode = 0x01;
const char StopOpCode = 0x00;

#endif // DATA_TYPES_H
