#include <QMessageBox>
#include <math.h>

#include "communication.h"
#include "serialport.h"
#include "data_types.h"

Communication::Communication(QObject *parent)
    : QThread(parent)
{
}

Communication::~Communication()
{
}


void Communication::run()
{
    float  dest = 0.0;
    HANDLE h;
    try {
        h = openSerialPort("COM3",B9600,one,even);


        unsigned char readbuffer[10];


        Measurement measurement;
        FlashData flashData;
        MotorData motorData;
        forever {
            mutex.lock();
            if ( messages.size() > 0 )
            {
                writeToSerialPort(h,messages.constData(), messages.size());
            }
            messages.clear();
            mutex.unlock();

            int bytesRead = readFromSerialPort(h,readbuffer,1);
            if (bytesRead  == 0 )
                continue;

            int bytesToRead = readbuffer[0];
            if ( bytesToRead > 10 || bytesToRead < 1 )
            {
                readFromSerialPort(h,readbuffer,3);
                printf("problem");

            }

            int index = 0;
            while (bytesToRead)
            {
                int bytesRead = readFromSerialPort(h,readbuffer+index,bytesToRead);
                if (bytesRead  == 0 )
                    continue;
                if (bytesRead < bytesToRead)
                {
                    index += bytesRead;
                    bytesToRead -= bytesRead;
                }
                else
                {
                    break;
                }

            }
            int shift8 = 8;
            if (readbuffer[0] == (unsigned char)DataCodes::termistor )
            {

                float voltage = (readbuffer[1] << shift8)+
                            readbuffer[2];
                voltage *=(2.048/32768.0);
                int time = (readbuffer[3] << shift8)+
                            readbuffer[4];
                measurement.temperature = readbuffer[5];
                measurement.voltage = voltage;
                measurement.time = time;
                emit  passMeasurement(&measurement);



            }
            else if(readbuffer[0] == (unsigned char)DataCodes::flash )
            {
                flashData.data.clear();
                flashData.address = readbuffer[1];

                flashData.data.push_back(readbuffer[2]);
                flashData.data.push_back(readbuffer[3]);
                flashData.data.push_back(readbuffer[4]);

                emit  passFlashData(&flashData);
            }
            else if(readbuffer[0] == (unsigned char)DataCodes::motor )
            {
                float speed = 0;

                speed = (float)(readbuffer[1]<< shift8);
                speed = (float)readbuffer[2];
                motorData.speed = speed*60/10;

                motorData.time = ((readbuffer[3] << shift8)+
                            readbuffer[4])/500;

                emit  passMotorData(&motorData);
            }

        }
        closeSerialPort(h);
    }catch (int e) {
        emit noSerial();
    }
}

void
Communication::addToSendQueue(unsigned char * _data, unsigned  _size)
{
    mutex.lock();
    for ( int i = 0; i < _size; i++)
    {
        messages.push_back(_data[i]);
    }
    mutex.unlock();
}
