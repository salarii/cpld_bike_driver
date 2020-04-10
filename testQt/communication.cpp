#include "communication.h"
#include <math.h>
#include "serialport.h"
#include <QMessageBox>

Communication::Communication(QObject *parent)
    : QThread(parent)
{
}

Communication::~Communication()
{
}




void Communication::run()
{
    int const oneGoBytes =5;
    float  dest = 0.0;
    HANDLE h;
    try {
        h = openSerialPort("COM3",B9600,one,even);


        unsigned char readbuffer[10];
        int index = 0;

        Measurement measurement;
        forever {
            int bytesRead = readFromSerialPort(h,readbuffer+index,8);
            if (bytesRead  == 0 )
                continue;

            if (bytesRead < oneGoBytes)
            {
                index += bytesRead;
            }
            if (index >= oneGoBytes)
            {
                index =0;
            }
            int shift8 = 8;
            float voltage = (readbuffer[0] << shift8)+
                        readbuffer[1];
            voltage *=(2.048/32768.0);
            int time = (readbuffer[2] << shift8)+
                        readbuffer[3];
            measurement.temperature = readbuffer[4];
            measurement.voltage = voltage;
            measurement.time = time;
            emit  passMeasurement(&measurement);

            mutex.lock();

            writeToSerialPort(h,messages.constData(), messages.size());

            mutex.unlock();
        }
        closeSerialPort(h);
    }catch (int e) {
        emit noSerial();
    }
}

void
Communication::addToSendQueue(unsigned char _data)
{
    mutex.lock();
    messages.push_back(_data);
    mutex.unlock();
}
