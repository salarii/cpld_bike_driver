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

enum class CommandCodes { StopOpCodeTermistor = 0, TriggerOpCodeTermistor = 1,LoadFlash = 2,GetFlash =3 };


#endif // DATA_TYPES_H
