#ifndef DATA_TYPES_H
#define DATA_TYPES_H

#include <QVector>

struct Measurement
{
  float  voltage;
  int time;
  int temperature;
};

struct FlashData
{
  QVector<unsigned char> data;
  unsigned char address;
};

enum class CommandCodes { StopOpCode = 0, TriggerTermistorOpCode = 1,WriteFlashOpCode = 2,ReadFlashOpCode =3, EraseFlashOpCode =4, StartMotorOpCode = 5 };


#endif // DATA_TYPES_H
