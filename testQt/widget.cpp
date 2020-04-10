#include "widget.h"
#include <QVBoxLayout>
#include <QPushButton>
#include "communication.h"

using namespace QtCharts;

QString const labelText = "Current Voltage: ";

Widget::Widget(QWidget *parent)
    : QWidget(parent)
{


    QVBoxLayout *layout = new QVBoxLayout;

    QHBoxLayout *interfaceLayout = new QHBoxLayout;

    this->setLayout(layout);

    chartView = new  QChartView(this);

    series = new QLineSeries();
    label = new QLabel("");

    chartView->setChart(createChart());
    layout->addLayout(interfaceLayout);
    layout->addWidget(chartView);
    layout->addWidget(label);

    idx = 0;
    this->setFixedSize(800, 800);
    this->adjustSize();

    auto title = new QLabel("Unit step");

    force = new QSpinBox();

    force->setRange(10, 100);
    force->setSingleStep(10);
    force->setValue(100);
    auto percent = new QLabel(" % ");

    QPushButton * startButton= new QPushButton( "Start" );
    interfaceLayout->addWidget(title);
    interfaceLayout->addWidget(force);
    interfaceLayout->addWidget(percent);
    interfaceLayout->addWidget(startButton);
    startButton->setCheckable(true);
    QObject::connect(startButton, &QPushButton::clicked,
                     this, &Widget::startMeasurement);


}

void
Widget::serialProblem()
{
    QMessageBox msgBox;
    msgBox.setText("Missing serial port communication.\n Setup some kind of \n"
                   "serial port <--> your hardware (cpld/fpga) communication.\n"
                   "for example use CP2102 chips based hardware as a bridge");
    msgBox.setIcon(QMessageBox::Critical );

    msgBox.addButton("Ok", QMessageBox::AcceptRole);
    msgBox.exec();
}


void
Widget::startMeasurement(bool _checked)
{


    series = new QLineSeries();
    //emit sendToHardware(force->value());
}


QChart * Widget::createChart()
{
    QLineSeries * tmp = new QLineSeries();
    auto list = series->points();
    if ( list.size() > 100 )
    {
        list.removeFirst();
    }

    tmp->append(list);
    series = tmp;
    QChart * newChart = new QChart;
    series->setName("temperature");
    newChart->setTitle("Voltage");
    newChart->addSeries(series);

    QValueAxis *axisX = new QValueAxis;
    //axisX->setTickInterval(10);

    newChart->addAxis(axisX, Qt::AlignBottom);

    QValueAxis *axisY = new QValueAxis;

    newChart->addAxis(axisY, Qt::AlignLeft);
    series->attachAxis(axisX);
    series->attachAxis(axisY);
    axisX->applyNiceNumbers();
    axisY->setRange(25.0, 130.0);
    axisY->applyNiceNumbers();
    return newChart;
}


void Widget::serviceMeasurement(Measurement const * _measurement)
{

    series->append(idx,_measurement->temperature);
    idx++;

    auto message = labelText + QString().setNum(_measurement->voltage, 'g', 4) + QString(" V ");
    message += QString(" Temperature:") + QString().setNum(_measurement->temperature) + QString(" Celsius");

    label->setText(message);
    QChart* chartToDelete=NULL;
    if(chartView->chart())
    {
        chartToDelete=chartView->chart();
    }
    chartView->setChart(createChart());

    delete chartToDelete;

}

Widget::~Widget()
{
}

