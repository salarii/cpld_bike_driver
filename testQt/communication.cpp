#include "communication.h"
#include <math.h>
#include "serialport.h"

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
    HANDLE h = openSerialPort("COM3",B9600,one,even);
    unsigned char readbuffer[10];
    int index = 0;
    forever {
        int bytesRead = readFromSerialPort(h,readbuffer+index,8);
        if (bytesRead  == 0 )
            continue;

        if (bytesRead < 4)
        {
            index += bytesRead;
        }
        if (index >= 4)
        {
            index =0;
        }
        int shift8 = 8;
        float value = (readbuffer[0] << shift8)+
                    readbuffer[1];
        value *=(2.048/32768.0);
        float time = (readbuffer[2] << shift8)+
                    readbuffer[3];


        emit  overflow(value);

    }
    closeSerialPort(h);
}
