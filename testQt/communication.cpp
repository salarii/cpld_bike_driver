#include <QMessageBox>
#include <QFile>
#include <QDir>
#include <math.h>
#include <QTextStream>
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

    QString path("C:/Users/artur/Documents/cpld_bike_driver/testQt/");
    QDir dir;
    if (!dir.exists(path))
        dir.mkpath(path);

    QFile file(path+"out.txt");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;
       QTextStream out(&file);
    try {
        h = openSerialPort("COM3",B9600,one,even);


        unsigned char readbuffer[1024];


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

            out << "packet size: " << bytesToRead << "\n";

            if ( bytesToRead >= 10 || bytesToRead < 1 )
            {
                file.close();
                readFromSerialPort(h,readbuffer,3);
                printf("problem");

            }

            int  index = 0;
            while (bytesToRead)
            {
                int bytesRead = readFromSerialPort(h,readbuffer+index,bytesToRead);
                if (bytesRead  == 0 )
                    continue;
                index += bytesRead;
                if (bytesRead < bytesToRead)
                {

                    bytesToRead -= bytesRead;
                }
                else
                {
                    break;
                }

            }
            for (int i = 0 ;i <bytesToRead ;i++)
            {
                out << "index: " << i << "  val: "<< readbuffer[i]<< "\n";
            }

            int shift8 = 8, shift16 = 16;

            if (readbuffer[0] == (unsigned char)DataCodes::termistor )
                {

                    float voltage = (readbuffer[1] << shift8)+
                                readbuffer[2];
                    //voltage *=(2.048/32768.0);
                    int time = (readbuffer[3] << shift16)+
                                (readbuffer[4] << shift8)+
                                readbuffer[5];
                    measurement.temperature = readbuffer[6];
                    measurement.voltage = voltage;
                    measurement.time = time;
                    emit  passMeasurement(&measurement);



                }
                else if(readbuffer[0] == (unsigned char)DataCodes::flash )
                {

                    flashData.data.clear();
                    flashData.idx = readbuffer[1];

                    flashData.data.push_back(readbuffer[2]);
                    flashData.data.push_back(readbuffer[3]);
                    flashData.data.push_back(readbuffer[4]);
                    emit  passFlashData(&flashData);

                }
                else if(readbuffer[0] == (unsigned char)DataCodes::motor )
                {
                    float speed = 0;

                    speed = (float)(readbuffer[1]<< shift8)
                            +(float)readbuffer[2];
                    motorData.speed = speed;

                    motorData.time = (readbuffer[3] << shift16)+
                            (readbuffer[4] << shift8)+
                            readbuffer[5];

                    motorData.rot_cnt = (readbuffer[6] << shift16)+
                            (readbuffer[7] << shift8)+
                            readbuffer[8];
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
