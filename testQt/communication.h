#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include <QThread>

class Communication : public QThread
{
    Q_OBJECT

public:
    Communication(QObject *parent = nullptr);
    ~Communication();

signals:
    void overflow(float _value);
protected:
    void run() override;

};

#endif // COMMUNICATION_H
