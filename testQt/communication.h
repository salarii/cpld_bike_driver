#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include <QThread>
#include <QMutex>


struct Measurement;


class Communication : public QThread
{
    Q_OBJECT

public:
    Communication(QObject *parent = nullptr);
    ~Communication();

signals:
    void passMeasurement(Measurement const * _measurement);
    void noSerial();
public slots:
    void addToSendQueue(unsigned char * _data, unsigned  _size);
protected:
    void run() override;
    QMutex mutex;
    QVector<unsigned char> messages;

};

#endif // COMMUNICATION_H
