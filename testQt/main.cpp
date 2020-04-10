#include "widget.h"
#include "communication.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("Support tool");
    QApplication a(argc, argv);
    Widget w;
    Communication comm;
    w.show();

    QObject::connect(&comm, &Communication::passMeasurement,
                     &w, &Widget::serviceMeasurement);


    QObject::connect(&comm, &Communication::noSerial,
                     &w, &Widget::serialProblem);

    QObject::connect(&w, &Widget::sendToHardware,
                     &comm, &Communication::addToSendQueue);
    comm.start();
    return a.exec();
}
