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

    QObject::connect(&comm, &Communication::overflow,
                     &w, &Widget::setValue);
    comm.start();
    return a.exec();
}
