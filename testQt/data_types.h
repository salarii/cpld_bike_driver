#ifndef DATA_TYPES_H
#define DATA_TYPES_H

#include <QVector>

struct Measurement
{
  float  voltage;
  int time;
  int temperature;
};

struct MotorData
{
  float  speed;
  int time;
  int rot_cnt;
};

struct FlashData
{
  QVector<unsigned char> data;
  unsigned char address;
};


enum class DataCodes { termistor = 0, flash = 1, motor = 2};

enum class CommandCodes { StopOpCode = 0, ChangeADCChannel = 1,WriteFlashOpCode = 2,ReadFlashOpCode =3, EraseFlashOpCode =4, StartMotorOpCode = 5 };


#endif // DATA_TYPES_H
