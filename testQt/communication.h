#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include <QThread>
#include <QMutex>
#include "data_types.h"

class Communication : public QThread
{
    Q_OBJECT

public:
    Communication(QObject *parent = nullptr);
    ~Communication();

signals:
    void passMeasurement(Measurement const * _measurement);
    void passFlashData(FlashData const * _flashData);
    void passMotorData(MotorData const * _motorData);

    void noSerial();
public slots:
    void addToSendQueue(unsigned char * _data, unsigned  _size);
protected:
    void run() override;
    QMutex mutex;
    QVector<unsigned char> messages;

};

#endif // COMMUNICATION_H
